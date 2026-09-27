// A3C_server_fnc_registerConvoyRuntime

/*
 * Creates or updates the authoritative server-local runtime state of
 * a convoy.
 *
 * _orderedGroups is the complete permanent group order currently
 * stored for the convoy. _newGroups contains only groups that have
 * just been appended to that convoy.
 *
 * Existing vehicle entries are never rebuilt. New vehicle entries
 * are created only from _newGroups and appended to the frozen order.
 *
 * Returns the runtime ID locally on the server, or "" on failure.
 */

params [
	["_orderedGroups", [], [[]]],
	["_newGroups", [], [[]]]
];

if (!isServer) exitWith {
	""
};

private _validOrderedGroups = [];

{
	if (
		_x isEqualType grpNull
		&& {!isNull _x}
	) then {
		_validOrderedGroups pushBackUnique
			_x;
	};
} forEach _orderedGroups;

if (_validOrderedGroups isEqualTo []) exitWith {
	""
};

private _validNewGroups = [];

{
	if (
		_x in _validOrderedGroups
	) then {
		_validNewGroups pushBackUnique
			_x;
	};
} forEach _newGroups;

if (isNil "A3C_CONVOY_RUNTIME_STATES") then {
	A3C_CONVOY_RUNTIME_STATES =
		createHashMap;
};

if (isNil "A3C_CONVOY_RUNTIME_UID_COUNTER") then {
	A3C_CONVOY_RUNTIME_UID_COUNTER = 0;
};

private _runtimeIDs = [];

{
	private _runtimeID =
		_x getVariable [
			"A3C_Convoy_RuntimeID",
			""
		];

	if (_runtimeID != "") then {
		private _runtimeState =
			A3C_CONVOY_RUNTIME_STATES getOrDefault [
				_runtimeID,
				createHashMap
			];

		if (count _runtimeState > 0) then {
			_runtimeIDs pushBackUnique
				_runtimeID;
		} else {
			/*
			 * Remove a stale server-local reference left by a runtime
			 * that no longer exists.
			 */
			_x setVariable [
				"A3C_Convoy_RuntimeID",
				nil
			];
		};
	};
} forEach _validOrderedGroups;

if (count _runtimeIDs > 1) exitWith {
	diag_log format [
		"[A3C CONVOY RUNTIME] Registration rejected: groups belong to multiple runtimes. Groups: %1 | Runtime IDs: %2",
		_validOrderedGroups,
		_runtimeIDs
	];

	""
};

private _createVehicleState = {
	params [
		"_vehicleEntry"
	];

	_vehicleEntry params [
		"_vehicle",
		"_group"
	];

	createHashMapFromArray [
		["vehicle", _vehicle],
		["group", _group],

		/*
		 * Projection onto the runtime's shared master route.
		 *
		 * "mode" retains the existing operational/tracking state.
		 * projectionValid separately states whether the stored route
		 * coordinate can safely participate in longitudinal control.
		 */
		["mode", "INITIALIZING"],
		["projectionValid", false],
		["projectionReason", "NOT_EVALUATED"],
		["routeGeneration", -1],
		["routeCoordinateGeneration", -1],
		["segmentIndex", -1],
		["routeProgress", -1],
		["distanceFromRoute", -1],
		["projectedPosition", []],
		["segmentFraction", -1],
		["usedFullRouteSearch", false],
		["lastProjectionTime", -1],
		["nextFullRouteSearchTime", 0],

		/*
		* Longitudinal relationship to the nearest preceding living,
		* non-retired vehicle in the permanent convoy order.
		*
		* The predecessor is resolved once by the projection updater.
		* The evaluator and UI must consume this exact stored identity
		* instead of independently selecting another array entry.
		*/
		["vehicleAheadStateIndex", -1],
		["vehicleAhead", objNull],
		["vehicleAheadGroup", grpNull],

		/*
		* gapToVehicleAhead is the authoritative resolved centre gap
		* consumed by the evaluator. The two source-specific values
		* remain available for diagnostics.
		*/
		["gapToVehicleAhead", -1],
		["masterRouteGapToVehicleAhead", -1],
		["commonAnchorGapToVehicleAhead", -1],
		["gapReferenceValid", false],
		["gapReferenceMode", "NONE"],
		["gapReferenceReason", "NOT_EVALUATED"],
		["gapReferenceAnchor", []],
		["distanceToGapReference", -1],
		["distanceAheadToGapReference", -1],
		["gapReferenceUpdatedAt", -1],
		["gapReferenceMissingSince", -1],

		/*
		 * The last confirmed pair relationship may be used only as
		 * a short fail-safe while a new common reference is being
		 * resolved. It must never become an indefinitely stale gap.
		 */
		["lastValidGapToVehicleAhead", -1],
		["lastValidGapTime", -1],

		/*
		 * Server-local common-anchor route cache. It belongs to this
		 * follower because every follower has exactly one active
		 * predecessor at a time.
		 */
		["pairRouteCache", createHashMap],

		/*
		 * Evaluated physical and control state.
		 */
		["centreGapToVehicleAhead", -1],
		["bumperGapToVehicleAhead", -1],
		["desiredGap", -1],
		["currentSpeed", 0],
		["speedAhead", -1],
		["recommendedSpeed", -1],
		["timeToCollision", -1],
		["modelAcceleration", 0],
		["freeSpeedTarget", -1],
		["controlMode", "INITIALIZING"],
		["lastEvaluationTime", -1],

		/*
		 * Applied command state.
		 */
		["lastLimitSpeed", -1],
		["lastLimitCommandTime", -1],
		["appliedSpeedLimit", -1],
		["requestedSpeedLimit", -1],
		["speedControlActive", false],
		["hardHoldActive", false],
		["hardHoldReason", ""],
		["movementSuppressed", false],
		["movementSuppressedDriver", objNull],
		["driverMissingSince", -1],

		["retired", false]
	]
};

private _runtimeID = "";
private _runtimeState =
	createHashMap;

if (_runtimeIDs isEqualTo []) then {
	_runtimeID = format [
		"A3C_CONVOY_RUNTIME_%1",
		A3C_CONVOY_RUNTIME_UID_COUNTER
	];

	A3C_CONVOY_RUNTIME_UID_COUNTER =
		A3C_CONVOY_RUNTIME_UID_COUNTER + 1;

	private _vehicleEntries = [
		_validOrderedGroups
	] call A3C_main_fnc_buildConvoyVehicleOrder;

	private _vehicleStates =
		_vehicleEntries apply {
			[_x] call _createVehicleState
		};

	_runtimeState = createHashMapFromArray [
		["runtimeID", _runtimeID],
		["groups", +_validOrderedGroups],
		["vehicleStates", _vehicleStates],
		["status", "REGISTERED"],
		["controllerHandle", scriptNull],
		["runtimeControlActive", false],
		["controllerMode", "SHADOW"],
		["regroupActive", false],
		["regroupDistance", -1],
		["regroupThreshold", -1],
		["route", []],
		["routeGeneration", 0],
		["routeCoordinateGeneration", 0],
		["routeBuildMode", "NONE"],
		["routeRetryAfter", 0],
		["routeOrderValid", false],
		["gapResolutionAllowed", false],
		["temporaryRouteFailure", false],
		["gapResolutionUpdatedAt", -1],
		["destinationGroup", grpNull],
		["destinationIndex", -1],
		["destinationName", ""],
		["destinationPosition", []],
		["pendingDestinationPosition", []],
		["pendingDestinationSince", -1],
		["createdAt", serverTime],
		["updatedAt", serverTime]
	];

	A3C_CONVOY_RUNTIME_STATES set [
		_runtimeID,
		_runtimeState
	];
} else {
	_runtimeID =
		_runtimeIDs select 0;

	_runtimeState =
		A3C_CONVOY_RUNTIME_STATES get _runtimeID;

	private _vehicleStates =
		_runtimeState getOrDefault [
			"vehicleStates",
			[]
		];

	private _registeredVehicles =
		_vehicleStates apply {
			_x getOrDefault [
				"vehicle",
				objNull
			]
		};

	private _newVehicleEntries = [
		_validNewGroups
	] call A3C_main_fnc_buildConvoyVehicleOrder;

	{
		private _vehicle =
			_x select 0;

		if !(
			_vehicle
				in _registeredVehicles
		) then {
			_vehicleStates pushBack (
				[_x] call _createVehicleState
			);

			_registeredVehicles pushBack
				_vehicle;
		};
	} forEach _newVehicleEntries;

	/*
	* Existing runtime order is frozen. Registration may append genuinely
	* new groups, but supplied external order must never reorder groups
	* already belonging to this runtime.
	*/
	private _frozenGroups =
		+(
			_runtimeState getOrDefault [
				"groups",
				[]
			]
		);

	{
		if (
			!isNull _x
			&& {!(_x in _frozenGroups)}
		) then {
			_frozenGroups pushBack
				_x;
		};
	} forEach _validNewGroups;

	_runtimeState set [
		"groups",
		_frozenGroups
	];

	_runtimeState set [
		"vehicleStates",
		_vehicleStates
	];

	_runtimeState set [
		"updatedAt",
		serverTime
	];
};

{
	_x setVariable [
		"A3C_Convoy_RuntimeID",
		_runtimeID
	];
} forEach _validOrderedGroups;

[
	_runtimeID
] call A3C_server_fnc_startConvoyRuntimeController;

if (
	missionNamespace getVariable [
		"A3C_DEBUG_CONVOY_RUNTIME",
		false
	]
) then {
	diag_log format [
		"[A3C CONVOY RUNTIME] Registered: %1 | Groups: %2 | Vehicle states: %3",
		_runtimeID,
		_runtimeState get "groups",
		count (_runtimeState get "vehicleStates")
	];
};

_runtimeID

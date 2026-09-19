// A3C_server_fnc_updateConvoyRuntimeRoute

/*
 * Resolves and caches the road route currently relevant to one
 * server-authoritative convoy runtime.
 *
 * The initial route begins at the convoy's rearmost registered
 * vehicle. Sequential waypoint changes extend the established route
 * so vehicles retain one stable route coordinate system.
 *
 * No vehicle commands are issued.
 *
 * Returns the compiled road route, or [] when unavailable.
 */

params [
	["_runtimeID", "", [""]],
	["_forceRebuild", false, [true]]
];

if (
	!isServer
	|| {_runtimeID == ""}
	|| {isNil "A3C_CONVOY_RUNTIME_STATES"}
) exitWith {
	[]
};

private _runtimeState =
	A3C_CONVOY_RUNTIME_STATES getOrDefault [
		_runtimeID,
		createHashMap
	];

if (count _runtimeState == 0) exitWith {
	[]
};

private _commitState = {
	_runtimeState set [
		"updatedAt",
		serverTime
	];

	A3C_CONVOY_RUNTIME_STATES set [
		_runtimeID,
		_runtimeState
	];
};

private _groups =
	_runtimeState getOrDefault [
		"groups",
		[]
	];

private _vehicleStates =
	_runtimeState getOrDefault [
		"vehicleStates",
		[]
	];

private _destinationGroup =
	grpNull;

{
	if (
		!isNull _x
		&& {
			{alive _x} count units _x > 0
		}
	) exitWith {
		_destinationGroup = _x;
	};
} forEach _groups;

if (isNull _destinationGroup) exitWith {
	_runtimeState set [
		"status",
		"NO_ACTIVE_GROUP"
	];

	_runtimeState set [
		"route",
		[]
	];

	_runtimeState set [
		"destinationGroup",
		grpNull
	];

	_runtimeState set [
		"destinationIndex",
		-1
	];

	_runtimeState set [
		"destinationName",
		""
	];

	_runtimeState set [
		"destinationPosition",
		[]
	];

	call _commitState;

	[]
};

private _destinationIndex =
	currentWaypoint _destinationGroup;

private _destinationWaypoints =
	waypoints _destinationGroup;

if (
	_destinationIndex < 0
	|| {
		_destinationIndex
			>= count _destinationWaypoints
	}
) exitWith {
	_runtimeState set [
		"status",
		"NO_DESTINATION"
	];

	_runtimeState set [
		"route",
		[]
	];

	_runtimeState set [
		"destinationGroup",
		_destinationGroup
	];

	_runtimeState set [
		"destinationIndex",
		-1
	];

	_runtimeState set [
		"destinationName",
		""
	];

	_runtimeState set [
		"destinationPosition",
		[]
	];

	call _commitState;

	[]
};

private _destinationWaypoint = [
	_destinationGroup,
	_destinationIndex
];

private _destinationPosition =
	waypointPosition _destinationWaypoint;

private _destinationName =
	waypointName _destinationWaypoint;

private _storedDestinationGroup =
	_runtimeState getOrDefault [
		"destinationGroup",
		grpNull
	];

private _storedDestinationIndex =
	_runtimeState getOrDefault [
		"destinationIndex",
		-1
	];

private _storedDestinationName =
	_runtimeState getOrDefault [
		"destinationName",
		""
	];

private _storedDestinationPosition =
	_runtimeState getOrDefault [
		"destinationPosition",
		[]
	];

private _sameDestinationIdentity =
	if (
		_destinationName != ""
		&& {_storedDestinationName != ""}
	) then {
		_destinationGroup
			isEqualTo _storedDestinationGroup
		&& {
			_destinationName
				isEqualTo _storedDestinationName
		}
	} else {
		_destinationGroup
			isEqualTo _storedDestinationGroup
		&& {
			_destinationIndex
				== _storedDestinationIndex
		}
	};

private _destinationMoved =
	_sameDestinationIdentity
	&& {
		count _storedDestinationPosition >= 2
	}
	&& {
		_storedDestinationPosition
			distance2D _destinationPosition
				> 2
	};

private _existingRoute =
	_runtimeState getOrDefault [
		"route",
		[]
	];

/*
 * A moved waypoint must remain stable briefly before rebuilding.
 * This prevents repeated path searches while the waypoint is being
 * dragged.
 */
private _pendingReady = true;

if (
	_destinationMoved
	&& {!_forceRebuild}
) then {
	private _pendingDestinationPosition =
		_runtimeState getOrDefault [
			"pendingDestinationPosition",
			[]
		];

	private _pendingDestinationSince =
		_runtimeState getOrDefault [
			"pendingDestinationSince",
			-1
		];

	if (
		count _pendingDestinationPosition < 2
		|| {
			_pendingDestinationPosition
				distance2D _destinationPosition
					> 1
		}
	) then {
		_runtimeState set [
			"pendingDestinationPosition",
			+_destinationPosition
		];

		_runtimeState set [
			"pendingDestinationSince",
			serverTime
		];

		_runtimeState set [
			"status",
			"DESTINATION_PENDING"
		];

		_pendingReady = false;
	} else {
		if (
			serverTime - _pendingDestinationSince
				< 1.5
		) then {
			_pendingReady = false;
		};
	};
} else {
	_runtimeState set [
		"pendingDestinationPosition",
		[]
	];

	_runtimeState set [
		"pendingDestinationSince",
		-1
	];
};

if (!_pendingReady) exitWith {
	call _commitState;

	_existingRoute
};

private _storedVehicleCount =
	_runtimeState getOrDefault [
		"routeVehicleCount",
		-1
	];

private _routeRetryAfter =
	_runtimeState getOrDefault [
		"routeRetryAfter",
		0
	];

private _needsRebuild =
	_forceRebuild
	|| {!_sameDestinationIdentity}
	|| {_destinationMoved}
	|| {
		_storedVehicleCount
			!= count _vehicleStates
	}
	|| {
		_existingRoute isEqualTo []
		&& {
			serverTime >= _routeRetryAfter
		}
	};

if (!_needsRebuild) exitWith {
	_runtimeState set [
		"status",
		if (_existingRoute isEqualTo []) then {
			"ROUTE_RETRY_PENDING"
		} else {
			"ROUTE_READY"
		}
	];

	call _commitState;

	_existingRoute
};

private _routeStartVehicle =
	objNull;

if !(_vehicleStates isEqualTo []) then {
	for "_i" from ((count _vehicleStates) - 1) to 0 step -1 do {
		private _vehicleState =
			_vehicleStates select _i;

		private _vehicle =
			_vehicleState getOrDefault [
				"vehicle",
				objNull
			];

		private _retired =
			_vehicleState getOrDefault [
				"retired",
				false
			];

		if (
			!_retired
			&& {!isNull _vehicle}
			&& {alive _vehicle}
		) exitWith {
			_routeStartVehicle = _vehicle;
		};
	};
};

if (isNull _routeStartVehicle) exitWith {
	_runtimeState set [
		"status",
		"NO_ACTIVE_VEHICLE"
	];

	_runtimeState set [
		"route",
		[]
	];

	_runtimeState set [
		"routeRetryAfter",
		serverTime + 5
	];

	call _commitState;

	[]
};

private _routeStartPosition =
	getPosATL _routeStartVehicle;

private _committedRouteStartPosition =
	+_routeStartPosition;

private _newRoute = [];
private _routeBuildMode = "FULL";

/*
 * Preserve the established route when the leading group advances to
 * a later waypoint. Only the new section is calculated and appended.
 *
 * This keeps every vehicle on the same route coordinate system and
 * prevents a fresh shortest-path calculation from selecting another
 * road branch behind the convoy.
 */
private _canExtendExistingRoute =
	!_forceRebuild
	&& {!_destinationMoved}
	&& {!_sameDestinationIdentity}
	&& {
		_destinationGroup
			isEqualTo _storedDestinationGroup
	}
	&& {_storedDestinationIndex >= 0}
	&& {
		_destinationIndex
			> _storedDestinationIndex
	}
	&& {
		_storedVehicleCount
			== count _vehicleStates
	}
	&& {count _existingRoute >= 4}
	&& {
		!(
			(_existingRoute select 0)
				isEqualTo []
		)
	};

if (_canExtendExistingRoute) then {
	private _existingRoadPath =
		+(_existingRoute select 0);

	private _lastExistingRoad =
		_existingRoadPath select (
			(count _existingRoadPath) - 1
		);

	private _extensionRoute = [
		position _lastExistingRoad,
		_destinationPosition
	] call A3C_main_fnc_buildRoadRoute;

	if !(_extensionRoute isEqualTo []) then {
		private _extensionRoadPath =
			+(_extensionRoute select 0);

		/*
		 * Both routes normally contain the boundary road. Include it
		 * only once.
		 */
		if (
			!(_extensionRoadPath isEqualTo [])
			&& {
				(_existingRoadPath select (
					(count _existingRoadPath) - 1
				))
					isEqualTo
				(_extensionRoadPath select 0)
			}
		) then {
			_extensionRoadPath deleteAt 0;
		};

		_existingRoadPath =
			_existingRoadPath
				+ _extensionRoadPath;

		_newRoute = [
			_existingRoadPath
		] call A3C_main_fnc_compileRoadRoute;

		if !(_newRoute isEqualTo []) then {
			_routeBuildMode = "EXTEND";

			_committedRouteStartPosition =
				+(
					_runtimeState getOrDefault [
						"routeStartPosition",
						position (
							_existingRoadPath select 0
						)
					]
				);
		};
	};
};

/*
 * Initial routes, changed vehicle counts, moved waypoints and failed
 * extensions use a complete rebuild.
 */
if (_newRoute isEqualTo []) then {
	_newRoute = [
		_routeStartPosition,
		_destinationPosition
	] call A3C_main_fnc_buildRoadRoute;
};

_runtimeState set [
	"destinationGroup",
	_destinationGroup
];

_runtimeState set [
	"destinationIndex",
	_destinationIndex
];

_runtimeState set [
	"destinationName",
	_destinationName
];

_runtimeState set [
	"destinationPosition",
	+_destinationPosition
];

_runtimeState set [
	"routeStartPosition",
	+_committedRouteStartPosition
];

_runtimeState set [
	"routeVehicleCount",
	count _vehicleStates
];

_runtimeState set [
	"pendingDestinationPosition",
	[]
];

_runtimeState set [
	"pendingDestinationSince",
	-1
];

if (_newRoute isEqualTo []) exitWith {
	_runtimeState set [
		"status",
		"NO_ROUTE"
	];

	_runtimeState set [
		"route",
		[]
	];

	_runtimeState set [
		"routeRetryAfter",
		serverTime + 5
	];

	call _commitState;

	if (
		missionNamespace getVariable [
			"A3C_DEBUG_CONVOY_RUNTIME",
			false
		]
	) then {
		diag_log format [
			"[A3C CONVOY ROUTE] No route | Runtime: %1 | Start: %2 | Destination: %3",
			_runtimeID,
			_routeStartPosition,
			_destinationPosition
		];
	};

	[]
};

private _routeGeneration =
	(
		_runtimeState getOrDefault [
			"routeGeneration",
			0
		]
	) + 1;

/*
 * Sequential extension preserves the existing route coordinate
 * system. A full rebuild creates a new coordinate system and requires
 * every vehicle to reacquire its position.
 */
private _routeCoordinateGeneration =
	_runtimeState getOrDefault [
		"routeCoordinateGeneration",
		0
	];

if (_routeBuildMode == "FULL") then {
	_routeCoordinateGeneration =
		_routeCoordinateGeneration + 1;
};

_runtimeState set [
	"route",
	_newRoute
];

_runtimeState set [
	"routeGeneration",
	_routeGeneration
];

_runtimeState set [
	"routeCoordinateGeneration",
	_routeCoordinateGeneration
];

_runtimeState set [
	"routeBuildMode",
	_routeBuildMode
];

_runtimeState set [
	"routeRetryAfter",
	0
];

_runtimeState set [
	"status",
	"ROUTE_READY"
];

call _commitState;

if (
	missionNamespace getVariable [
		"A3C_DEBUG_CONVOY_RUNTIME",
		false
	]
) then {
	diag_log format [
		"[A3C CONVOY ROUTE] Ready | Runtime: %1 | Generation: %2 | Coordinate generation: %3 | Nodes: %4 | Distance: %5 | Start vehicle: %6 | Destination group: %7 | WP: %8 | Build: %9",
		_runtimeID,
		_routeGeneration,
		_routeCoordinateGeneration,
		count (_newRoute select 0),
		_newRoute select 3,
		_routeStartVehicle,
		_destinationGroup,
		_destinationIndex,
		_routeBuildMode
	];
};

_newRoute
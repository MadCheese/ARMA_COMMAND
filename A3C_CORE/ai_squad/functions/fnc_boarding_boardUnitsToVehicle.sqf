// A3C_ai_squad_fnc_boarding_boardUnitsToVehicle

/*
	Executes one protected engine-level boarding transaction for units in the
	player's squad.

	This function must only be called by
	A3C_ai_squad_fnc_boarding_processBoardUnitsToVehicleQueue. The queue
	guarantees that two player-group switching transactions cannot overlap.

	Input rows:
	[
		_unit,
		_role,
		_seatIndexPath
	]

	_role is case-insensitive:
	- driver: seatIndexPath is ignored
	- cargo: seatIndexPath is the cargo index
	- gunner/commander/turret: seatIndexPath is the turret path

	Returns:
	[
		_acceptedUnits,
		_failedUnits
	]

	An accepted unit reported GET IN at least once, entered the target vehicle,
	died, or ceased to exist before the transaction ended. A failed unit had an
	invalid assignment, was not in the current player squad, or failed to
	accept GET IN before the acceptance-stall watchdog expired.
*/

params [
	["_unitsAndRoles", [], [[]]],
	["_vehicle", objNull, [objNull]]
];

private _debug = missionNamespace getVariable ["a3c_debug", false];
private _acceptedUnits = [];
private _failedUnits = [];

if (
	isNull _vehicle
	|| {!alive _vehicle}
	|| {_unitsAndRoles isEqualTo []}
) exitWith {
	{
		if (_x isEqualType [] && {count _x > 0}) then {
			private _unit = _x select 0;

			if (_unit isEqualType objNull && {!isNull _unit}) then {
				_failedUnits pushBackUnique _unit;
			};
		};
	} forEach _unitsAndRoles;

	[_acceptedUnits, _failedUnits]
};

private _playerUnit = player;
private _playerGroup = group _playerUnit;

if (isNull _playerGroup) exitWith {
	[_acceptedUnits, _failedUnits]
};

private _validAssignments = [];

{
	private _assignment = _x;

	if !(_assignment isEqualType [] && {count _assignment >= 3}) then {
		continue;
	};

	_assignment params [
		"_unit",
		"_role",
		"_seatIndexPath"
	];

	private _requestId = _assignment param [3, -1, [0]];

	if !(
		_unit isEqualType objNull
		&& {_role isEqualType ""}
	) then {
		continue;
	};

	private _roleLower = toLower _role;
	private _seatDataValid = switch (_roleLower) do {
		case "driver": {
			true
		};

		case "cargo": {
			_seatIndexPath isEqualType 0
			&& {_seatIndexPath >= 0}
		};

		case "gunner";
		case "commander";
		case "turret": {
			_seatIndexPath isEqualType []
		};

		default {
			false
		};
	};

	if (
		isNull _unit
		|| {!alive _unit}
		|| {isPlayer _unit}
		|| {group _unit != _playerGroup}
		|| {!_seatDataValid}
		|| {
			_requestId >= 0
			&& {_unit getVariable ["A3C_boardingRequestId", -1] != _requestId}
		}
	) then {
		if (!isNull _unit) then {
			_failedUnits pushBackUnique _unit;
		};

		continue;
	};

	_validAssignments pushBack [
		_unit,
		_roleLower,
		if (_seatIndexPath isEqualType []) then {
			+_seatIndexPath
		} else {
			_seatIndexPath
		},
		_requestId
	];
} forEach _unitsAndRoles;

if (_validAssignments isEqualTo []) exitWith {
	[_acceptedUnits, _failedUnits]
};

if (A3C_BOARDING_TRANSACTION_ACTIVE) exitWith {
	{
		_failedUnits pushBackUnique (_x select 0);
	} forEach _validAssignments;

	if (_debug) then {
		systemChat "Rejected overlapping boardUnitsToVehicle transaction";
	};

	[_acceptedUnits, _failedUnits]
};

private _tempGroup = createGroup [side _playerGroup, true];

if (isNull _tempGroup) exitWith {
	{
		_failedUnits pushBackUnique (_x select 0);
	} forEach _validAssignments;

	[_acceptedUnits, _failedUnits]
};

A3C_BOARDING_TRANSACTION_ACTIVE = true;
A3C_BOARDING_PLAYER_GROUP = _playerGroup;

[_playerUnit] joinSilent _tempGroup;

private _fakeGroupUnits = _playerGroup call A3C_ai_squad_fnc_boarding_createPlayerGroupUIProxy;

if (_debug) then {
	systemChat format [
		"Created boarding UI proxy units: %1",
		count _fakeGroupUnits
	];
};

private _orderedAssignments = [];

{
	_x params [
		"_unit",
		"_role",
		"_seatIndexPath",
		"_requestId"
	];

	private _assignmentStillCurrent = _requestId < 0 || {
		_unit getVariable ["A3C_boardingRequestId", -1] == _requestId
	};

	if (!_assignmentStillCurrent) then {
		continue;
	};

	_orderedAssignments pushBack _x;
} forEach _validAssignments;

private _orderedUnits = _orderedAssignments apply {
	_x select 0
};

/*
	After the player leaves, the original group is AI-led and its ownership can
	be different in multiplayer. Execute the complete assign+order sequence
	where that AI leader is local. BIS_fnc_call is already used elsewhere in
	the project for this locality pattern.
*/
if (_orderedAssignments isNotEqualTo []) then {
	private _orderTarget = leader _playerGroup;

	if (isNull _orderTarget) then {
		{
			_failedUnits pushBackUnique _x;
		} forEach _orderedUnits;

		_orderedAssignments = [];
		_orderedUnits = [];
	} else {
		[
			[
				_orderedAssignments,
				_vehicle
			],
			{
				params [
					"_orderedAssignments",
					"_vehicle"
				];

				private _orderedUnits = [];

				{
					_x params [
						"_unit",
						"_role",
						"_seatIndexPath",
						"_requestId"
					];

					private _assignmentStillCurrent = _requestId < 0 || {
						_unit getVariable ["A3C_boardingRequestId", -1] == _requestId
					};

					if (_assignmentStillCurrent) then {
						switch (_role) do {
							case "driver": {
								_unit assignAsDriver _vehicle;
							};

							case "cargo": {
								_unit assignAsCargoIndex [
									_vehicle,
									_seatIndexPath
								];
							};

							case "gunner";
							case "commander";
							case "turret": {
								_unit assignAsTurret [
									_vehicle,
									_seatIndexPath
								];
							};
						};

						_orderedUnits pushBackUnique _unit;
					};
				} forEach _orderedAssignments;

				if (_orderedUnits isNotEqualTo []) then {
					_orderedUnits allowGetIn true;
					_orderedUnits orderGetIn true;
				};
			}
		] remoteExec [
			"BIS_fnc_call",
			_orderTarget
		];
	};
};

//-- This is a stall watchdog, not a total boarding timeout. Each newly
//-- accepted unit resets it.
private _acceptanceStallTimeout = 10;

private _pendingAssignments = _orderedAssignments select {
	private _unit = _x select 0;

	!isNull _unit
	&& {alive _unit}
	&& {vehicle _unit != _vehicle}
};

private _previousPendingCount = count _pendingAssignments;
private _lastProgressAt = diag_tickTime;

waitUntil {
	_pendingAssignments = _pendingAssignments select {
		private _unit = _x select 0;
		private _requestId = _x select 3;
		private _assignmentStillCurrent = _requestId < 0 || {
			_unit getVariable ["A3C_boardingRequestId", -1] == _requestId
		};

		_assignmentStillCurrent
		&& {!isNull _unit}
		&& {alive _unit}
		&& {vehicle _unit != _vehicle}
		&& {
			assignedVehicle _unit != _vehicle
			|| {currentCommand _unit != "GET IN"}
		}
	};

	private _pendingCount = count _pendingAssignments;

	if (_pendingCount < _previousPendingCount) then {
		_previousPendingCount = _pendingCount;
		_lastProgressAt = diag_tickTime;
	};

	_pendingCount == 0
	|| {isNull _vehicle}
	|| {!alive _vehicle}
	|| {
		diag_tickTime - _lastProgressAt
			>= _acceptanceStallTimeout
	}
};

private _pendingUnits = _pendingAssignments apply {
	_x select 0
};

{
	_failedUnits pushBackUnique _x;
} forEach _pendingUnits;

_acceptedUnits = _orderedUnits - _failedUnits;

if (_pendingUnits isNotEqualTo [] && {_debug}) then {
	systemChat format [
		"GET IN acceptance stalled for units: %1",
		_pendingUnits
	];
};

//-- Capture cancellation commands issued through the proxy group before
//-- returning the player to the real group.
private _proxyCancellationRequests = [];

{
	private _proxyUnit = _x;

	if (!isNull _proxyUnit && {alive _proxyUnit}) then {
		private _sourceUnit = _proxyUnit getVariable [
			"A3C_boardingProxySourceUnit",
			objNull
		];

		private _assignmentIndex = _orderedAssignments findIf {
			(_x select 0) == _sourceUnit
		};

		if (
			!isNull _sourceUnit
			&& {_assignmentIndex >= 0}
		) then {
			private _expectedDestinationData =
				expectedDestination _proxyUnit;

			private _planningMode = toLower (
				_expectedDestinationData param [1, ""]
			);

			private _proxyCancelledBoarding =
				currentCommand _proxyUnit == "STOP"
				|| {(_planningMode find "form") >= 0};

			if (_proxyCancelledBoarding) then {
				private _assignment =
					_orderedAssignments select _assignmentIndex;

				_proxyCancellationRequests pushBack [
					_sourceUnit,
					_assignment select 3
				];
			};
		};
	};
} forEach _fakeGroupUnits;

//-- From this point onward, keep cleanup linear. Do not add exitWith paths
//-- between the player leaving the original group and this restoration.
if (!isNull _playerGroup && {!isNull _playerUnit}) then {
	[_playerUnit] joinSilent _playerGroup;
};

//-- Transfer proxy cancellation requests to the corresponding real units.
//-- Request IDs prevent delayed requests from cancelling newer assignments.
{
	_x params [
		"_unit",
		"_requestId"
	];

	if (!isNull _unit) then {
		[
			[
				_unit,
				_vehicle,
				_requestId
			],
			{
				params [
					"_unit",
					"_vehicle",
					"_requestId"
				];

				if (
					!isNull _unit
					&& {alive _unit}
					&& {!isNull _vehicle}
					&& {vehicle _unit != _vehicle}
					&& {assignedVehicle _unit == _vehicle}
					&& {
						_unit getVariable [
							"A3C_boardingRequestId",
							-1
						] == _requestId
					}
				) then {
					unassignVehicle _unit;
				};
			}
		] remoteExecCall [
			"BIS_fnc_call",
			_unit
		];
	};
} forEach _proxyCancellationRequests;

{
	if (!isNull _x) then {
		deleteVehicle _x;
	};
} forEach _fakeGroupUnits;

if (
	!isNull _playerGroup
	&& {!isNull _playerUnit}
	&& {_playerUnit in units _playerGroup}
) then {
	_playerGroup selectLeader _playerUnit;
};

A3C_BOARDING_PLAYER_GROUP = grpNull;
A3C_BOARDING_TRANSACTION_ACTIVE = false;

deleteGroup _tempGroup;

if (_debug) then {
	sleep 0.5;

	systemChat format [
		"Remaining boarding UI proxy units: %1",
		{!isNull _x} count _fakeGroupUnits
	];
};

[_acceptedUnits, _failedUnits]
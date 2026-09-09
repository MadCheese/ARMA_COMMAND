// A3C_ai_squad_fnc_boarding_boardUnitsToVehicle

/*
	Validates and issues one queued boarding batch.

	The temporary-leadership period is owned by
	A3C_ai_squad_fnc_boarding_processBoardUnitsToVehicleQueue.

	If external mission code restores player leadership while this batch is
	awaiting acceptance, this function restores the worker-supplied AI leader
	and reissues only the still-pending boarding orders.

	Returns:
	[
		_acceptedUnits,
		_failedUnits,
		_issuedUnits
	]

	_issuedUnits contains every unit whose MOVE AI was enabled and whose
	assignAs/orderGetIn sequence was issued. The queue worker uses this array
	to exclude those units from stationary-unit restoration.
*/

params [
	["_unitsAndRoles", [], [[]]],
	["_vehicle", objNull, [objNull]],
	["_playerGroup", grpNull, [grpNull]],
	["_playerUnit", objNull, [objNull]],
	["_temporaryLeader", objNull, [objNull]]
];

private _debug =
	missionNamespace getVariable ["a3c_debug", false];

private _acceptedUnits = [];
private _failedUnits = [];
private _issuedUnits = [];

if (
	isNull _vehicle
	|| {!alive _vehicle}
	|| {_unitsAndRoles isEqualTo []}
) exitWith {
	{
		if (_x isEqualType [] && {count _x > 0}) then {
			private _unit = _x select 0;

			if (
				_unit isEqualType objNull
				&& {!isNull _unit}
			) then {
				_failedUnits pushBackUnique _unit;
			};
		};
	} forEach _unitsAndRoles;

	[
		_acceptedUnits,
		_failedUnits,
		_issuedUnits
	]
};

if (isNull _playerGroup) then {
	_playerGroup = group player;
};

if (isNull _playerGroup) exitWith {
	[
		_acceptedUnits,
		_failedUnits,
		_issuedUnits
	]
};

if (isNull _playerUnit) then {
	_playerUnit = player;
};

private _validAssignments = [];

{
	private _assignment = _x;

	if !(
		_assignment isEqualType []
		&& {count _assignment >= 3}
	) then {
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
			&& {
				_unit getVariable [
					"A3C_boardingRequestId",
					-1
				] != _requestId
			}
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
	[
		_acceptedUnits,
		_failedUnits,
		_issuedUnits
	]
};

private _temporaryLeaderIsValid =
	!isNull _temporaryLeader
	&& {alive _temporaryLeader}
	&& {!isPlayer _temporaryLeader}
	&& {group _temporaryLeader == _playerGroup};

private _groupLeader = leader _playerGroup;

//-- Mission code may restore player leadership between the worker's
//-- validation and this function beginning execution.
if (
	_groupLeader == _playerUnit
	&& {_temporaryLeaderIsValid}
) then {
	_playerGroup selectLeader _temporaryLeader;

	_groupLeader = leader _playerGroup;
};

if (
	isNull _groupLeader
	|| {isPlayer _groupLeader}
) exitWith {
	{
		_failedUnits pushBackUnique (_x select 0);
	} forEach _validAssignments;

	[
		_acceptedUnits,
		_failedUnits,
		_issuedUnits
	]
};

//-- Preserve compatibility with callers that did not explicitly supply
//-- the temporary leader.
if (!_temporaryLeaderIsValid) then {
	_temporaryLeader = _groupLeader;
};

//-- Recheck request ownership immediately before changing engine assignment.
private _orderedAssignments = _validAssignments select {
	private _unit = _x select 0;
	private _requestId = _x select 3;

	_requestId < 0
	|| {
		_unit getVariable [
			"A3C_boardingRequestId",
			-1
		] == _requestId
	}
};

if (_orderedAssignments isEqualTo []) exitWith {
	[
		_acceptedUnits,
		_failedUnits,
		_issuedUnits
	]
};

private _issuedAssignments = [];

{
	_x params [
		"_unit",
		"_role",
		"_seatIndexPath",
		"_requestId"
	];

	private _assignmentStillCurrent =
		_requestId < 0
		|| {
			_unit getVariable [
				"A3C_boardingRequestId",
				-1
			] == _requestId
		};

	if (
		_assignmentStillCurrent
		&& {!isNull _unit}
		&& {alive _unit}
		&& {group _unit == _playerGroup}
	) then {
		//-- A unit may currently belong to the worker's protected stationary
		//-- set. Boarding always requires MOVE to be enabled.
		_unit enableAI "MOVE";

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

		_issuedUnits pushBackUnique _unit;
		_issuedAssignments pushBack _x;
	} else {
		_failedUnits pushBackUnique _unit;
	};
} forEach _orderedAssignments;

//-- Each assignment remains pending until that individual unit reports
//-- GET IN once, enters the target vehicle, dies, leaves the group, or its
//-- request ceases to be current.
//
//-- Accepted assignments are permanently removed, so all units do not need
//-- to report GET IN simultaneously.
private _pendingAssignments = +_issuedAssignments;
private _leadershipInterrupted = false;

if (_issuedUnits isNotEqualTo []) then {
	_issuedUnits allowGetIn true;
	_issuedUnits orderGetIn true;

	private _acceptanceTimeoutAt =
		diag_tickTime + 10;

	waitUntil {
		//-- Detect only the original player reclaiming leadership of the
		//-- original group. Do not interfere with a group the player has left.
		if (
			!isNull _playerUnit
			&& {_playerUnit in units _playerGroup}
			&& {leader _playerGroup == _playerUnit}
		) then {
			_leadershipInterrupted = true;

			if (
				!isNull _temporaryLeader
				&& {alive _temporaryLeader}
				&& {!isPlayer _temporaryLeader}
				&& {group _temporaryLeader == _playerGroup}
			) then {
				_playerGroup selectLeader _temporaryLeader;
			};
		};

		_pendingAssignments = _pendingAssignments select {
			private _unit = _x select 0;
			private _requestId = _x select 3;

			private _assignmentStillCurrent =
				_requestId < 0
				|| {
					_unit getVariable [
						"A3C_boardingRequestId",
						-1
					] == _requestId
				};

			_assignmentStillCurrent
			&& {!isNull _unit}
			&& {alive _unit}
			&& {group _unit == _playerGroup}
			&& {vehicle _unit != _vehicle}
			&& {currentCommand _unit != "GET IN"}
		};

		//-- Seat assignments remain valid across the leadership interruption.
		//-- Only the engine boarding order needs to be reissued.
		if (
			_leadershipInterrupted
			&& {_pendingAssignments isNotEqualTo []}
			&& {!isNull _temporaryLeader}
			&& {alive _temporaryLeader}
			&& {group _temporaryLeader == _playerGroup}
			&& {leader _playerGroup == _temporaryLeader}
		) then {
			private _pendingUnitsToReissue =
				_pendingAssignments apply {
					_x select 0
				};

			_pendingUnitsToReissue allowGetIn true;
			_pendingUnitsToReissue orderGetIn true;

			_leadershipInterrupted = false;
		};

		_pendingAssignments isEqualTo []
		|| {isNull _vehicle}
		|| {!alive _vehicle}
		|| {diag_tickTime >= _acceptanceTimeoutAt}
	};
};

private _pendingUnits = _pendingAssignments apply {
	_x select 0
};

//-- Only issued units that never registered GET IN are failed.
{
	_failedUnits pushBackUnique _x;
} forEach _pendingUnits;

//-- Every issued unit removed from the pending array registered its command
//-- or otherwise ceased to require acknowledgement.
{
	if !(_x in _pendingUnits) then {
		_acceptedUnits pushBackUnique _x;
	};
} forEach _issuedUnits;

if (
	_pendingUnits isNotEqualTo []
	&& {_debug}
) then {
	systemChat format [
		"GET IN acceptance failed for units: %1",
		_pendingUnits
	];
};

[
	_acceptedUnits,
	_failedUnits,
	_issuedUnits
]
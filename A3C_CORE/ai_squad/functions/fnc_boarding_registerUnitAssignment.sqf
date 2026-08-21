// A3C_ai_squad_fnc_boarding_registerUnitAssignment

/*
	Synchronously reserves a unit and seat before a queued task can yield.
	Returns the unique request ID used to invalidate stale asynchronous work.
*/

params [
	["_unit", objNull, [objNull]],
	["_vehicle", objNull, [objNull]],
	["_role", "", [""]],
	["_seatIndexPath", -1, [0, []]],
	["_buttonImageControl", controlNull, [controlNull]]
];

if (isNull _unit || {isNull _vehicle}) exitWith {
	-1
};

if ((_unit getVariable ["A3C_assignedVehicleSeat", []]) isNotEqualTo []) exitWith {
	-1
};

private _roleLower = toLower _role;
private _canonicalRole = if (
	_roleLower in ["gunner", "commander", "turret"]
) then {
	"turret"
} else {
	_roleLower
};

private _seatSnapshot = if (_seatIndexPath isEqualType []) then {
	+_seatIndexPath
} else {
	_seatIndexPath
};

private _seatDataValid = switch (_roleLower) do {
	case "driver": {
		_seatSnapshot isEqualType 0
	};

	case "cargo": {
		_seatSnapshot isEqualType 0
		&& {_seatSnapshot >= 0}
	};

	case "gunner";
	case "commander";
	case "turret": {
		_seatSnapshot isEqualType []
	};

	default {
		false
	};
};

if (!_seatDataValid) exitWith {
	-1
};

private _fnc_matchesSeat = {
	params [
		"_testedRole",
		"_testedSeatIndexPath"
	];

	private _testedRoleLower = toLower _testedRole;
	private _testedCanonicalRole = if (
		_testedRoleLower in ["gunner", "commander", "turret"]
	) then {
		"turret"
	} else {
		_testedRoleLower
	};

	_testedCanonicalRole == _canonicalRole
	&& {_testedSeatIndexPath isEqualTo _seatSnapshot}
};

private _assignedVehicleCrew = _vehicle getVariable [
	"A3C_AssignedVehicleCrew",
	[]
];

if (
	_assignedVehicleCrew findIf {
		[
			_x param [1, ""],
			_x param [2, -2]
		] call _fnc_matchesSeat
	} != -1
) exitWith {
	-1
};

private _seatOccupiedOrEngineAssigned = fullCrew [_vehicle, "", true] findIf {
	private _occupant = _x param [0, objNull];
	private _engineAssignedUnit = _x param [5, objNull];
	private _testedRole = _x param [1, ""];
	private _cargoIndex = _x param [2, -2];
	private _turretPath = _x param [3, []];
	private _testedRoleLower = toLower _testedRole;
	private _testedSeatIndexPath = if (
		_testedRoleLower in ["driver", "cargo"]
	) then {
		_cargoIndex
	} else {
		_turretPath
	};

	[
		_testedRole,
		_testedSeatIndexPath
	] call _fnc_matchesSeat
	&& {
		(!isNull _occupant && {alive _occupant})
		|| {!isNull _engineAssignedUnit && {alive _engineAssignedUnit}}
	}
} != -1;

if (_seatOccupiedOrEngineAssigned) exitWith {
	-1
};

A3C_BOARDING_REQUEST_ID = A3C_BOARDING_REQUEST_ID + 1;

private _requestId = A3C_BOARDING_REQUEST_ID;

A3C_BOARD_UNITS_ACTIVE pushBackUnique _unit;

_assignedVehicleCrew = _assignedVehicleCrew select {
	_x param [0, objNull] != _unit
};

_assignedVehicleCrew pushBack [
	_unit,
	_role,
	_seatSnapshot
];

_vehicle setVariable [
	"A3C_AssignedVehicleCrew",
	_assignedVehicleCrew,
	true
];

_unit setVariable [
	"A3C_assignedVehicleSeat",
	[
		_vehicle,
		_roleLower,
		_seatSnapshot,
		_requestId,
		_buttonImageControl
	]
];

//-- The complete assignment is deliberately local because it contains a UI
//-- control, which cannot be serialized. Only the scalar request token needs
//-- to be visible where the AI group becomes local in multiplayer.
_unit setVariable [
	"A3C_boardingRequestId",
	_requestId,
	true
];

_requestId

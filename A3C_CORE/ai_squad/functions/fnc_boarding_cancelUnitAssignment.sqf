// A3C_ai_squad_fnc_boarding_cancelUnitAssignment

params [
	["_unit", objNull, [objNull]],
	["_buttonColor", [1, 1, 1, 1], [[]]]
];

if (isNull _unit) exitWith {
	false
};

private _assignmentData = _unit getVariable [
	"A3C_assignedVehicleSeat",
	[]
];

if (_assignmentData isEqualTo []) exitWith {
	false
};

private _requestId = _assignmentData param [3, -1];

[
	_unit,
	_requestId,
	true,
	_buttonColor
] call A3C_ai_squad_fnc_boarding_finishUnitAssignment

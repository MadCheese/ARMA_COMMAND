// A3C_ai_shared_fnc_resetUnit
// Reverts unit AI/order state and deletes stored route/order data.

params ["_unit"];

if (isNull _unit) exitWith {};

private _vehicle = vehicle _unit;
private _plotData = _unit getVariable ["A3C_PLOT", []];

// Clear assigned-but-not-boarded units from aircraft.
if (_vehicle isKindOf "Air") then {
	{
		if (
			assignedVehicle _x == _vehicle &&
			{ !(_x in _vehicle) }
		) then {
			[[_x], A3C_ai_shared_fnc_unitGetOut] remoteExec ["BIS_fnc_call", _x];
		};
	} forEach allUnits;
};

// Re-enable AI systems.
{
	_unit enableAI _x;
} forEach [
	"MOVE",
	"TARGET",
	"AUTOTARGET",
	"FSM",
	"AUTOCOMBAT"
];

// Restore stored skill values.
private _skillData = _unit getVariable ["A3C_SKILLDATA", []];

{
	if (_forEachIndex < count _skillData) then {
		_unit setSkill [_x, _skillData select _forEachIndex];
	};
} forEach [
	"commanding",
	"spotDistance",
	"spotTime"
];

// Clear plot data.
_unit setVariable ["A3C_PLOT", [], true];
_unit setVariable ["A3C_PLOT_TEMP", [], true];

// Unlock vehicle.
[_vehicle, "UNLOCKED"] remoteExec ["setVehicleLock", _vehicle];

// Reset unit speed.
_unit forceSpeed -1;

// Reset driven vehicle speed.
private _parentVehicle = objectParent _unit;

if (!isNull _parentVehicle) then {
	if (_unit == driver _parentVehicle) then {
		_parentVehicle limitSpeed false;
	};
};
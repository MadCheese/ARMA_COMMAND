params ["_unit", "_dest"];

if (isPlayer _unit) exitWith {};

if (isNil 'A3C_main_fnc_setVehicleVarname') exitWith {};

_unit forceSpeed 0;

[_unit] call A3C_main_fnc_setVehicleVarname;

private _holdPos = position vehicle _unit;

[_unit, _holdPos] remoteExec ["doMove", _unit]; //-- prevent unit from any autonomous movement
[_unit, _holdPos] remoteExec ["moveTo", _unit];

sleep random 0.3;

private _rail = [
	_unit,
	ATLToASL _dest,
	false
] spawn A3C_ai_rail_fnc_infantryForceDestination;

waitUntil {
	scriptDone _rail
};

_unit setPos _dest;

private _unitPosASL = getPosASL _unit;

private _surfaceHits = lineIntersectsSurfaces [
	_unitPosASL,
	(_unitPosASL select [0, 2]) + [0],
	_unit,
	objNull,
	true,
	1,
	"GEOM",
	"NONE"
];

if (_surfaceHits isNotEqualTo []) then {
	_unit setPosASL ((_surfaceHits select 0) select 0);
};

_unit forceSpeed -1;

[_unit, objNull] remoteExec ["lookAt", _unit];
[_unit, _dest] remoteExec ["doMove", _unit];
[_unit, _dest] remoteExec ["moveTo", _unit];

_dest spawn {
	sleep 15;
	A3C_OCC_BPOSES = A3C_OCC_BPOSES - [_this];
};
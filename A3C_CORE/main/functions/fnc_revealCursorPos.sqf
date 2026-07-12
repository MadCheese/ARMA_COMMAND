// A3C_main_fnc_revealCursorPos

params ["_caller", "_pos"];

if (isNull _caller) exitWith {};

private _startPosASL = [_caller] call MCSS_fnc_getViewPosASL;
private _endPosASL = ATLToASL _pos;

private _intersections = lineIntersectsSurfaces [
	_startPosASL,
	_endPosASL,
	_caller
];

if (_intersections isEqualTo []) exitWith {};

private _collider = (_intersections select 0) select 2;

if (isNull _collider) exitWith {};

if ([_caller, _collider] call MCSS_fnc_lineOfFire) then {
	_caller reveal [_collider, 4];
};
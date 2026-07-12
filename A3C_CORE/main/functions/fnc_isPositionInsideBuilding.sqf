// A3C_main_fnc_isPositionInsideBuilding
// Checks whether a vertical ray above the given position intersects the specified building.

params ["_clickPos", "_building"];

if ((count _clickPos) < 3) exitWith {
	false
};

if (isNull _building) exitWith {
	false
};

private _groundPosATL = +_clickPos;
_groundPosATL set [2, 0];

private _rayStartASL = ATLToASL [
	_groundPosATL select 0,
	_groundPosATL select 1,
	30
];

private _rayEndASL = ATLToASL _groundPosATL;

private _intersectedObjects = lineIntersectsWith [
	_rayStartASL,
	_rayEndASL,
	objNull,
	objNull
];

_building in _intersectedObjects
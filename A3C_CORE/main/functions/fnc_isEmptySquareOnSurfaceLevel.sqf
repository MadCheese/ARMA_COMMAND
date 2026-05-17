// A3C_main_fnc_isEmptySquareOnSurfaceLevel

params ["_testPos","_building","_bDir","_highestZ_ASL"];

private _isUsable = true;

private _ints_Z = lineIntersectsSurfaces
[
	_testPos,
	[_testPos select 0, _testPos select 1, 0],
	objNull,
	objNull,
	true,
	1,
	"GEOM",
	"NONE"
];

if (count _ints_Z == 0) exitWith {false};

private _intsPos = (_ints_Z select 0) select 0;

if (abs ((_intsPos select 2) - _highestZ_ASL) > 0.5) exitWith {false};

for "_i" from 0 to 7 do {

	private _checkLength = if (_i % 2 == 0) then {0.353553} else {0.5}; //-- 0.353553 is half the diameter of a 1m square, 0.5 is half a side-length

	private _refPos = _testPos getPos [_checkLength,(_bDir + 45) * _i];
	_refPos set [2, _highestZ_ASL];

	private _isIntersects = lineIntersects [_testPos, _refPos,objNull,objNull];

	if (_isIntersects) exitWith {
		_isUsable = false;
	};
};

_isUsable
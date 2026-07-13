// A3C_ai_shared_fnc_gtiGrenade_getRelativePos
//-- #ToDo - can be replaced with getPos or BIS_fnc_relPos once altitude usage but requires clarification of z-value usage

params [
	"_originPos",
	"_direction",
	"_distance",
	["_altitude", 0]
];

private _relativePos = _originPos getPos [_distance, _direction];
_relativePos set [2, _altitude];

_relativePos
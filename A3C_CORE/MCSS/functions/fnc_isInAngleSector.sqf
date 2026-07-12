// MCSS_fnc_isInAngleSector

params ["_center", "_dir", "_sector", "_pos"];

private _dirTo = _center getDir _pos;

acos ([sin _dir, cos _dir, 0] vectorCos [sin _dirTo, cos _dirTo, 0]) <= _sector

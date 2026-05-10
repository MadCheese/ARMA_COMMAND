/*
    Returns the azimuth of the surface normal from a lineIntersectsSurfaces hit.

    Default:
        returns direction pointing away from the surface.

    If _reverse is true:
        returns the opposite direction, pointing into/towards the surface.

    Returns:
        Number 0-360, or -1 if no hit / no meaningful horizontal direction.
*/

params ["_startPosASL", "_endPosASL"];

private _objIgnore1 = if (count _this > 2) then { _this select 2 } else { objNull };
private _objIgnore2 = if (count _this > 3) then { _this select 3 } else { objNull };
private _reverse    = if (count _this > 4) then { _this select 4 } else { false };

private _hit = lineIntersectsSurfaces [
    _startPosASL,
    _endPosASL,
    _objIgnore1,
    _objIgnore2,
    true,
    1,
    "GEOM",
    "NONE"
];

if (_hit isEqualTo []) exitWith { -1 };

private _normal = (_hit # 0) # 1;

// Default: surface normal, pointing away from the surface.
// Reverse: opposite direction, pointing into/towards the surface.
private _vec = if (_reverse) then {
    _normal vectorMultiply -1
} else {
    _normal
};

// No meaningful azimuth for near-vertical normals, e.g. floor/ceiling.
if (((abs (_vec # 0)) + (abs (_vec # 1))) < 0.001) exitWith { -1 };

private _azimuth = ((_vec # 0) atan2 (_vec # 1) + 360) % 360;

_azimuth
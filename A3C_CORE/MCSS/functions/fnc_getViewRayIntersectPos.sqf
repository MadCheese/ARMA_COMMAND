// MCSS_fnc_getViewRayIntersectPos
// Returns the first surface intersection position from a player camera / unit view ray.
// NOTE: Intersection result is ASL. Original fallback behaviour is preserved.

params [
	"_unit",
	["_ignore", objNull],
	["_endPos", []]
];

private _isPlayerView = _unit == player;

private _startPos = if (_isPlayerView) then {
	AGLToASL (positionCameraToWorld [0, 0, 0])
} else {
	[_unit] call MCSS_fnc_getViewPosASL
};

if (_endPos isEqualTo []) then {
	_endPos = if (_isPlayerView) then {
		AGLToASL (positionCameraToWorld [0, 0, viewDistance])
	} else {
		ATLToASL (_unit getPos [viewDistance, getDir vehicle _unit])
	};
};

private _intersections = lineIntersectsSurfaces [
	_startPos,
	_endPos,
	vehicle _unit,
	_ignore,
	true,
	1,
	"GEOM",
	"NONE"
];

if (_intersections isEqualTo []) exitWith {
	if (_isPlayerView) then {
		screenToWorld [0.5, 0.5]
	} else {
		_unit getPos [viewDistance, getDir vehicle _unit]
	}
};

(_intersections select 0) select 0
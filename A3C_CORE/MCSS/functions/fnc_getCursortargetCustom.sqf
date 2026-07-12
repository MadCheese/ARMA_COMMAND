// MCSS_fnc_getCursorTargetCustom

private _player = player;
private _vehicle = vehicle _player;
private _cursorTarget = cursorTarget;

if (
	!isNull _cursorTarget &&
	{ _player == driver _vehicle } &&
	{ _cursorTarget != _vehicle }
) then {
	private _startPos = AGLToASL (positionCameraToWorld [0, 0, 0]);
	private _endPos = AGLToASL (positionCameraToWorld [0, 0, viewDistance]);

	// Preserve original behavior:
	// if the view ray points downward, clamp the end height to the camera height.
	_endPos set [2, (_startPos select 2) max (_endPos select 2)];

	private _intersections = lineIntersectsSurfaces [
		_startPos,
		_endPos,
		vehicle cameraOn,
		cameraOn,
		true,
		1,
		"GEOM",
		"NONE"
	];

	if !(_intersections isEqualTo []) then {
		_cursorTarget = (_intersections select 0) select 2;
	};
};

_cursorTarget
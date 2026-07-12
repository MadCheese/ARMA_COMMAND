// MCSS_fnc_getViewPosASL
// Get ASL view/reference position.
// Infantry: eyePos.
// Vehicle crew: vehicle ASL position raised above vehicle bounding-box height.
// Player/UAV camera: current camera position.

params ["_unit"];

if ((unitIsUAV cameraOn) or { _unit == player }) exitWith {
	ATLtoASL (positionCameraToWorld [0, 0, 0])
};

private _vehicle = objectParent _unit;

if (isNull _vehicle) exitWith {
	eyePos _unit
};

private _viewPosASL = getPosASL _vehicle;
private _boundingBox = boundingBoxReal _vehicle;
private _maxBounds = _boundingBox select 1;

_viewPosASL set [2, (_viewPosASL select 2) + (_maxBounds select 2) + 1];

_viewPosASL
// MCSS_fnc_lineOfSightCover
// Returns true if _object does NOT block LOS at any tested height.
// Returns false if _object blocks LOS at one or more tested heights.

params ["_pos", "_observer", "_object"];

private _observerEyePosASL = eyePos _observer;
private _testHeights = [0.2, 1];

private _objectBlocksLOS = (_testHeights findIf {
	private _testPosATL = +_pos;
	_testPosATL set [2, _x];

	private _testPosASL = ATLtoASL _testPosATL;

	private _intersectedObjects = lineIntersectsObjs [
		_testPosASL,
		_observerEyePosASL,
		_observer,
		objNull
	];

	_object in _intersectedObjects
}) != -1;

!_objectBlocksLOS
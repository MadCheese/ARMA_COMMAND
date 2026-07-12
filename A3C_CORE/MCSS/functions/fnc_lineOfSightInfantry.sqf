// MCSS_fnc_lineOfSightInfantry

params ["_target", "_observer", "_dirMode"];

private _targetVehicle = vehicle _target;

private _observerEyeDirVector = eyeDirection _observer;
private _observerEyeDir = (_observerEyeDirVector select 0) atan2 (_observerEyeDirVector select 1);

if (_dirMode == "AREA") then {
	_observerEyeDir = getDir _observer;
};

if (_observerEyeDir < 0) then {
	_observerEyeDir = 360 + _observerEyeDir;
};

private _dirToTarget = [_observer, _targetVehicle] call BIS_fnc_dirTo;

private _observerEyePosASL = eyePos _observer;
private _targetEyePosASL = eyePos _targetVehicle;

private _dirDifference = abs (_dirToTarget - _observerEyeDir);

private _targetOutsideViewArc = if ((_targetVehicle distance _observer) < 20) then {
	_dirDifference >= 90 && { _dirDifference <= 270 }
} else {
	_dirDifference >= 60 && { _dirDifference <= 240 }
};

private _isBlocked = (
	lineIntersects [_observerEyePosASL, _targetEyePosASL] ||
	{ terrainIntersectASL [_observerEyePosASL, _targetEyePosASL] }
);

private _hasLineOfSight = !(_targetOutsideViewArc || { _isBlocked });

_hasLineOfSight
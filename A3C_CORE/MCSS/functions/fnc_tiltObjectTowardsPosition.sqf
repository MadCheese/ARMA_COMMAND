// MCSS_fnc_tiltObjectTowardsPosition
// Calculate vectorDir/vectorUp arrays to orient an object toward a target position.
// Returns: [vectorDir, vectorUp]

params ["_object", "_targetPos"];

private _objectPos = getPosATL _object;

private _posDiff = _objectPos vectorDiff _targetPos;
private _verticalRatio = if ((_posDiff select 1) == 0) then {
	0
} else {
	(_posDiff select 2) / (_posDiff select 1)
};

private _tiltAngle = abs atan _verticalRatio;
private _distance = _objectPos distance _targetPos;

if ((_objectPos select 2) > (_targetPos select 2)) then {
	_tiltAngle = _tiltAngle * -1;

	if (_distance > 200) then {
		// _tiltAngle = _tiltAngle max 10;
	};

	if ((_objectPos select 2) < 25) then {
		// _tiltAngle = _tiltAngle max 10;
	};
};

if ((_objectPos select 2) < 2) then {
	// _tiltAngle = _tiltAngle max 2;
};

private _direction = _objectPos getDir _targetPos;
private _pitch = 0;

private _vectorDirX = sin _direction * cos _tiltAngle;
private _vectorDirY = cos _direction * cos _tiltAngle;
private _vectorDirZ = sin _tiltAngle;

private _vectorUpX = cos _direction * cos _tiltAngle * sin _pitch;
private _vectorUpY = sin _direction * cos _tiltAngle * sin _pitch;
private _vectorUpZ = cos _tiltAngle * cos _pitch;

[
	[_vectorDirX, _vectorDirY, _vectorDirZ],
	[_vectorUpX, _vectorUpY, _vectorUpZ]
]
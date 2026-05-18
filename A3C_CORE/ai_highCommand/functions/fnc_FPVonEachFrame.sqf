// A3C_ai_highCommand_fnc_FPVonEachFrame

// onEachFrame handler
params ["_drone", "_target", "_vUp"];

// Desired altitude above target (in meters)
private _altitudeOffset = 1;

// Desired speed in m/s
private _speed = 150 / 3.6;

private _dronePosASL = getPosASL _drone;
private _targetDriver = driver _target;

private _hitPointNames = (getAllHitPointsDamage _target) select 1;

private _priorityHitPoints = _hitPointNames select {
	private _hitPointName = toLower _x;

	{_x in _hitPointName} count ["fuel","motor","engine","tank"] > 0
};

_priorityHitPoints = _priorityHitPoints select {
	!((_target selectionPosition _x) isEqualTo [0,0,0])
};

private _targetPosASL = if (_priorityHitPoints isEqualTo []) then {
	if (!isNull _targetDriver) then {
		getPosASL _targetDriver
	} else {
		getPosASL _target
	}
} else {
	private _selectedHitPoint = _priorityHitPoints select 0;
	_target modelToWorldVisual (_target selectionPosition _selectedHitPoint)
};

// Adjust for altitude offset.
// Copy the array so the original target position is not mutated.
private _adjustedTargetPosASL = +_targetPosASL;
_adjustedTargetPosASL set [2, (_adjustedTargetPosASL select 2) + _altitudeOffset];

private _vectorToTarget = _adjustedTargetPosASL vectorDiff _dronePosASL;
private _distanceToTarget = vectorMagnitude _vectorToTarget;

if (_distanceToTarget > 0) then {
	private _velocity = _vectorToTarget vectorMultiply (_speed / _distanceToTarget);

	_drone setVectorUp _vUp;
	_drone setVelocity _velocity;
};
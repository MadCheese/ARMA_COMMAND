// MCSS_fnc_lineOfSightVehicle
// Checks whether an ATL position is within the vehicle main turret's horizontal aiming arc.
// NOTE: This does not perform an actual LOS/intersection test.

params ["_targetPosATL", "_gunner"];

private _rangeDeg = if ((count _this) > 2) then {
	_this select 2
} else {
	13
};

private _vehicle = vehicle _gunner;

private _targetPosFlatATL = +_targetPosATL;
_targetPosFlatATL set [2, 0];

private _vehiclePosASL = getPosASL _vehicle;
private _vehicleDir = getDir _vehicle;

private _mainTurretDeg = deg (_vehicle animationPhase "mainTurret");
private _aimingDir = _vehicleDir - _mainTurretDeg;

if (_aimingDir > 360) then {
	_aimingDir = _aimingDir - 360;
};

private _rangeLeft = 360 - _rangeDeg;

private _dirToTarget = [_vehiclePosASL, _targetPosFlatATL] call BIS_fnc_dirTo;

if (_dirToTarget < 0) then {
	_dirToTarget = _dirToTarget + 360;
};

private _dirDifference = abs (_dirToTarget - _aimingDir);

private _inRange = (_dirDifference <= _rangeDeg) or {
	_dirDifference >= _rangeLeft
};

_inRange
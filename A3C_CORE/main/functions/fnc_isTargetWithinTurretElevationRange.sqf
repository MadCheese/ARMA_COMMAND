// A3C_main_fnc_isTargetWithinTurretElevationRange

params ["_target", "_vehicle"];

if (isNull _target || { isNull _vehicle }) exitWith {
	false
};

private _gunner = gunner _vehicle;

if (isNull _gunner) exitWith {
	false
};

private _targetPosASL = getPosASL _target;
private _vehiclePosASL = getPosASL _vehicle;

private _distance2D = _target distance2D _vehicle;

if (_distance2D <= 0.1) exitWith {
	false
};

private _heightDifference = (_targetPosASL select 2) - (_vehiclePosASL select 2);

// Required turret elevation in radians.
// atan returns degrees, so convert to radians.
private _requiredElevationRad = rad (atan (_heightDifference / _distance2D));

// Preserved assumption from original:
// animationPhase "maingun" is used as current elevation in radians.
private _currentElevationRad = _vehicle animationPhase "maingun";

private _elevationDifference = _requiredElevationRad - _currentElevationRad;
private _inRange = (abs _elevationDifference) < 0.05;

if (!_inRange) then {
	private _aimAdjust = _vehicle getVariable ["A3C_AIM_ADJUST", 0];

	if (_elevationDifference >= 0) then {
		_aimAdjust = _aimAdjust + 0.01;
	} else {
		_aimAdjust = _aimAdjust - 0.01;
	};

	_vehicle setVariable ["A3C_AIM_ADJUST", _aimAdjust, true];

	private _aimPos = getPosATL _target;
	_aimPos set [2, (_aimPos select 2) + _aimAdjust];

	_gunner doWatch _aimPos;
};

_inRange
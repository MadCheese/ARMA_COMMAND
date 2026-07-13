// A3C_ai_shared_fnc_gtiGrenade_onEachFrameTick

if (isNull A3C_GTI_UNIT) exitWith {};

private _throwUnit = A3C_GTI_UNIT;
private _isPlayerControlled = _throwUnit == player;

private _screenTargetPos = screenToWorld [0.5, 0.5];

if (!_isPlayerControlled) then {
	A3C_DISABLE_RADIAL = true;
};

// Calculate needed launch speed.
private _maxLaunchSpeed = 19;
_maxLaunchSpeed = _maxLaunchSpeed - ((getFatigue _throwUnit) * BR_A3C_TACV_fatEff * _maxLaunchSpeed);

private _eyeHeightATL = (ASLToATL eyePos _throwUnit) select 2;

if (_eyeHeightATL < 1.4) then {
	if (_eyeHeightATL < 0.8) then {
		_maxLaunchSpeed = _maxLaunchSpeed * BR_A3C_TACV_GV0MaxP;
	} else {
		_maxLaunchSpeed = _maxLaunchSpeed * BR_A3C_TACV_GV0MaxC;
	};
};

private _targetPos = [];
private _aimVectorZ = (eyeDirection _throwUnit) select 2;

private _useCameraHouseAim = (
	_isPlayerControlled &&
	{
		cursorTarget isKindOf "House" &&
		{
			!weaponLowered player ||
			{ ([_aimVectorZ, 2] call BIS_fnc_cutDecimals) != 0 }
		}
	}
);

if (_useCameraHouseAim) then {
	_targetPos = positionCameraToWorld [0, 0, viewDistance];

	_aimVectorZ = if ((abs _aimVectorZ) > 0.01) then {
		_aimVectorZ
	} else {
		(_throwUnit weaponDirection currentWeapon _throwUnit) select 2
	};

	private _launchAngleFromView = atan _aimVectorZ;
	_launchAngleFromView = (_launchAngleFromView + 13) max 0.01;

	BR_A3C_TACV_throwTheta = ((_launchAngleFromView + BR_A3C_TACV_throwTheta_Add) max 0.01) min 89.9;
} else {
	BR_A3C_TACV_throwTheta = ((45 + BR_A3C_TACV_throwTheta_Add) max 0.01) min 89.9;

	if (_screenTargetPos distance2D cameraOn >= viewDistance) then {
		_targetPos = positionCameraToWorld [0, 0, viewDistance];
	} else {
		_targetPos = _screenTargetPos;
	};
};

if (!_isPlayerControlled && { A3C_GREN_ALLOW_UNITSWITCH }) then {
	private _suitableUnits = ((units player) - [player]) select {
		alive _x &&
		{ A3C_GREN_MUZZLE in magazines _x }
	};

	_suitableUnits = [
		_suitableUnits,
		[],
		{ _x distance _screenTargetPos },
		"ASCEND"
	] call BIS_fnc_sortBy;

	if !(_suitableUnits isEqualTo []) then {
		A3C_GTI_UNIT = _suitableUnits select 0;
		_throwUnit = A3C_GTI_UNIT;
	};
};

private _targetRange = _targetPos distance _throwUnit;
private _launchSpeed = sqrt (_targetRange * 9.81 / sin (2 * BR_A3C_TACV_throwTheta));

// Maximize launch speed and recalculate range.
if (_launchSpeed > _maxLaunchSpeed) then {
	_launchSpeed = _maxLaunchSpeed;
	_targetRange = (_launchSpeed ^ 2 * sin (2 * BR_A3C_TACV_throwTheta)) / 9.81;
};

private _horizontalVelocity = cos BR_A3C_TACV_throwTheta * _launchSpeed;
private _verticalVelocity = sin BR_A3C_TACV_throwTheta * _launchSpeed;

private _throwOriginModelOffset = switch (stance _throwUnit) do {
	case "STAND": {
		[0.232422, 0.803711, 1.61945]
	};

	case "CROUCH": {
		[0.230469, 0.808594, 1.1555]
	};

	case "PRONE": {
		[0.314453, 0.65332, 0.926847]
	};
};

private _throwOriginATL = _throwUnit modelToWorld _throwOriginModelOffset;

private _throwDir = [_throwUnit, _targetPos] call BIS_fnc_dirTo;
private _throwDirSin = sin _throwDir;
private _throwDirCos = cos _throwDir;

private _originX = _throwOriginATL select 0;
private _originY = _throwOriginATL select 1;

private _previousTrajectoryPosATL = +_throwOriginATL;
private _previousIconSize = 0;

private _trajectoryPosASL = [];
private _trajectoryPosATL = [];
private _trajectoryBaseASL = (getPosASL _throwUnit) select 2;

BR_A3C_TACV_throwVel = [
	_throwDirSin * _horizontalVelocity,
	_throwDirCos * _horizontalVelocity,
	_verticalVelocity
];

BR_A3C_TACV_throwV0 = _launchSpeed;

// Draw trajectory.
for "_time" from 0.1 to 5 step 0.1 do {
	private _horizontalDistance = _horizontalVelocity * _time;
	private _verticalDistance = _verticalVelocity * _time - (4.905 * _time ^ 2) + 1.4;

	_trajectoryPosASL = [
		_originX + (_throwDirSin * _horizontalDistance),
		_originY + (_throwDirCos * _horizontalDistance),
		_trajectoryBaseASL + _verticalDistance
	];

	_trajectoryPosATL = ASLToATL _trajectoryPosASL;

	private _collisionState = 0;

	if ((_trajectoryPosATL select 2) <= 0) then {
		_collisionState = 1;
	} else {
		if (lineIntersects [ATLToASL _previousTrajectoryPosATL, _trajectoryPosASL]) then {
			_collisionState = 2;
		};
	};

	private _iconSize = (((1 / ((getPosATL player) distance _trajectoryPosATL)) * 4) max 0.08) min 0.3;
	_iconSize = _iconSize * 3;

	private _iconColor = if (_collisionState == 0) then {
		[1, 1, 1, 1]
	} else {
		if (_collisionState == 1) then {
			[0, 1, 0, 1]
		} else {
			[1, 0, 0, 1]
		};
	};

	if (_collisionState != 2 && { lineIntersects [eyePos player, _trajectoryPosASL] }) then {
		_iconColor set [3, 0.2];
	};

	if (A3C_GTI_UNIT != player || { _collisionState == 0 }) then {
		drawIcon3D [
			"\a3\ui_f\data\Map\Markers\Military\dot_ca.paa",
			_iconColor,
			_trajectoryPosATL,
			_iconSize,
			_iconSize,
			0
		];
	};

	if (_collisionState > 0) exitWith {};

	_previousTrajectoryPosATL = _trajectoryPosATL;
	_previousIconSize = _iconSize;
};

if (_isPlayerControlled) then {
	private _impactIconSize = _previousIconSize * 1.5;

	private _throwIcon = if (A3C_WAIT_THROW_P in [0, -1]) then {
		private _currentThrowableMagazine = (currentThrowable player) select 0;

		getText (
			configFile >> "CfgMagazines" >> _currentThrowableMagazine >> "picture"
		)
	} else {
		format [
			"\a3\ui_f\data\IGUI\Cfg\HoldActions\progress\progress_%1_ca.paa",
			round ((1 - A3C_WAIT_THROW_P) * 20)
		]
	};

	drawIcon3D [
		_throwIcon,
		[1, 1, 1, 0.7],
		_trajectoryPosATL,
		_impactIconSize,
		_impactIconSize,
		0
	];
};

A3C_GTI_UNIT doWatch _trajectoryPosATL;
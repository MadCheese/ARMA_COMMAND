// A3C_ai_shared_fnc_gtiGrenade_getLaunchVelocity
// Function adapted from ZAPAT: Get Grenade Velocity

params [
	"_unit",
	"_targetPosATL",
	["_maxDist", 30],
	["_mode", 0],
	["_uglSpeed", 76],
	["_originPosATL", []],
	["_highArc", false],
	["_uglSpeedCoef", 1.0]
];

private _gravity = 9.81;

// _targetPosATL is ATL, so origin must also be ATL.
if (_originPosATL isEqualTo []) then {
	_originPosATL = ASLToATL eyePos _unit;
};

// UGL should not inherit thrown grenade range limit.
if (_mode == 1 && { _maxDist < 300 }) then {
	_maxDist = 300;
};

private _horizontalOffsetX = (_targetPosATL select 0) - (_originPosATL select 0);
private _horizontalOffsetY = (_targetPosATL select 1) - (_originPosATL select 1);
private _verticalOffset = (_targetPosATL select 2) - (_originPosATL select 2);

private _horizontalRange = sqrt (
	(_horizontalOffsetX * _horizontalOffsetX) +
	(_horizontalOffsetY * _horizontalOffsetY)
);

if (_horizontalRange < 0.01) exitWith {
	[0, 0, 0]
};

if (_horizontalRange > _maxDist) then {
	private _rangeScale = _maxDist / _horizontalRange;

	_horizontalOffsetX = _horizontalOffsetX * _rangeScale;
	_horizontalOffsetY = _horizontalOffsetY * _rangeScale;
	_horizontalRange = _maxDist;
};

private _horizontalDirX = _horizontalOffsetX / _horizontalRange;
private _horizontalDirY = _horizontalOffsetY / _horizontalRange;

if (_mode == 1) exitWith {
	/*
		UGL mode:
		Fixed projectile speed, solve angle to hit exact ATL target height.

		_lowArc  = flatter trajectory
		_highArc = lobbed trajectory
	*/

	private _launchSpeed = _uglSpeed * _uglSpeedCoef;
	private _launchSpeedSquared = _launchSpeed * _launchSpeed;
	private _launchSpeedFourth = _launchSpeedSquared * _launchSpeedSquared;
	private _horizontalRangeSquared = _horizontalRange * _horizontalRange;

	private _discriminant = _launchSpeedFourth - (
		_gravity * (
			(_gravity * _horizontalRangeSquared) +
			(2 * _verticalOffset * _launchSpeedSquared)
		)
	);

	if (_discriminant < 0) exitWith {
		// No physical solution at this speed.
		// Increase _uglSpeed or _uglSpeedCoef.
		[0, 0, 0]
	};

	private _sqrtDiscriminant = sqrt _discriminant;

	private _tanLaunchAngle = if (_highArc) then {
		(_launchSpeedSquared + _sqrtDiscriminant) / (_gravity * _horizontalRange)
	} else {
		(_launchSpeedSquared - _sqrtDiscriminant) / (_gravity * _horizontalRange)
	};

	private _launchAngle = atan _tanLaunchAngle;

	private _horizontalVelocity = cos _launchAngle * _launchSpeed;
	private _verticalVelocity = sin _launchAngle * _launchSpeed;

	[
		_horizontalDirX * _horizontalVelocity,
		_horizontalDirY * _horizontalVelocity,
		_verticalVelocity
	]
};

/*
	Throw mode:
	Chosen angle, solve speed needed to hit exact ATL target height.
*/

private _launchAngle = 45;

if (_maxDist == 300) then {
	_launchAngle = 20;

	if (_horizontalRange > 80) then {
		_launchAngle = 30;
	};

	if (_horizontalRange > 150) then {
		_launchAngle = 45;
	};
};

private _cosLaunchAngle = cos _launchAngle;
private _tanLaunchAngle = tan _launchAngle;
private _horizontalRangeSquared = _horizontalRange * _horizontalRange;

private _denominator = 2 * (_cosLaunchAngle * _cosLaunchAngle) * ((_horizontalRange * _tanLaunchAngle) - _verticalOffset);

if (_denominator <= 0) exitWith {
	// Current angle cannot reach the target height.
	[0, 0, 0]
};

private _launchSpeed = sqrt ((_gravity * _horizontalRangeSquared) / _denominator);

private _horizontalVelocity = _cosLaunchAngle * _launchSpeed;
private _verticalVelocity = sin _launchAngle * _launchSpeed;

[
	_horizontalDirX * _horizontalVelocity,
	_horizontalDirY * _horizontalVelocity,
	_verticalVelocity
]
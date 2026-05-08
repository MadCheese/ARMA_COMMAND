/*
	Scripted hover-capable aircraft approach rail.

	Guides a helicopter, VTOL, or other hover-capable air vehicle toward a target
	position using direct velocity control. The vehicle slows near the target,
	adjusts vertical velocity toward the target altitude, and climbs if geometry
	blocks the approach path.

	This is not intended for conventional fixed-wing aircraft that require
	forward airspeed.
*/

params ["_vehicle", "_targetPos", "_inside"];

if (_inside) then {
	private _traceStartPos = ATLToASL _targetPos;
	_traceStartPos set [2, (_traceStartPos select 2) + 50];

	private _traceEndPos = (_traceStartPos select [0, 2]) + [0];

	private _intersections = lineIntersectsSurfaces [
		_traceStartPos,
		_traceEndPos,
		objNull,
		objNull,
		true
	];

	if (count _intersections > 0) then {
		_targetPos = (_intersections select 0) select 0;
	};

	_targetPos set [2, (_targetPos select 2) + 15];
};

waitUntil {
	_vehicle distance2D _targetPos < 2500
};

[_vehicle, 0] remoteExec ["limitSpeed", _vehicle];

{
	[_x, "ALL"] remoteExec ["disableAI", _x];
} forEach [_vehicle, driver _vehicle];

private _isHelicopter = _vehicle isKindOf "HELICOPTER";

private _speed = speed _vehicle;
private _approachComplete = false;
private _obstacleCheckTime = time;
private _maxSpeed = _speed max 20; //-- default for helicopter (used for SLING-DROP)
private _tickDuration = 0.1;

while {alive _vehicle} do {
	private _vehiclePosASL = getPosASL _vehicle;
	private _distance2D = _vehicle distance2D _targetPos;
	private _targetAltitude = _targetPos select 2;
	private _vehicleAltitude = _vehiclePosASL select 2;

	if (_distance2D < 2) then {
		if (_vehicleAltitude < (_targetAltitude + 2)) then {
			_approachComplete = true;
		};
	};

	if (_approachComplete) exitWith {};

	private _directionToTarget = _vehicle getDir _targetPos;

	private _verticalVelocity = 0;

	if (_vehicleAltitude > _targetAltitude) then {
		_verticalVelocity = -4;
	} else {
		if (_vehicleAltitude < (_targetAltitude - 2)) then {
			_verticalVelocity = 4;
		};
	};

	if (time - _obstacleCheckTime > 5) then {
		private _intersections = lineIntersectsSurfaces [
			_vehiclePosASL,
			_targetPos,
			_vehicle,
			objNull,
			true,
			1,
			"GEOM",
			"NONE",
			true
		];

		if (count _intersections > 0) then {
			_verticalVelocity = 4;
		};

		_obstacleCheckTime = time;
	};

	if !(_isHelicopter) then {
		_maxSpeed = 350;

		if (_distance2D < 800) then {
			_maxSpeed = 200;
		};

		if (_distance2D < 400) then {
			_maxSpeed = 150;
		};

		if (_distance2D < 200) then {
			_maxSpeed = 100;
		};

		if (_distance2D < 100) then {
			_maxSpeed = 70;
		};
	};

	if (_distance2D < 50) then {
		_maxSpeed = 30;
	};

	if (_distance2D < 10) then {
		_maxSpeed = 10;
	};

	if (_distance2D < 2) then {
		_maxSpeed = 0;
	};

	_speed = (_speed - 5) max _maxSpeed;

	private _adjustedSpeed = 0;

	if (_speed > 0) then {
		_adjustedSpeed = _speed / 3.6;
	};

	/*
		Prevent overshooting the target in a single update tick.

		Without this, the direction to target can flip by ~180 degrees after
		overshoot, causing visible back-and-forth jank near the target.
	*/
	private _maxSafeHorizontalSpeed = _distance2D / _tickDuration;
	_adjustedSpeed = _adjustedSpeed min _maxSafeHorizontalSpeed;

	if (_speed >= 0) then {
		private _newVelocity = [
			sin _directionToTarget * _adjustedSpeed,
			cos _directionToTarget * _adjustedSpeed,
			_verticalVelocity
		];

		[_vehicle, _newVelocity] remoteExec ["setVelocity", _vehicle];
	};

	sleep _tickDuration;
};

[_vehicle, 10000] remoteExec ["limitSpeed", _vehicle];

{
	[_x, "ALL"] remoteExec ["enableAI", _x];
} forEach [_vehicle, driver _vehicle];
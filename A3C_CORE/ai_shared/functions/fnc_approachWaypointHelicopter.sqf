// A3C_ai_shared_fnc_approachWaypointHelicopter

params [
	"_group",
	"_movePos",
	["_finalSpeed", 20],              //-- km/h near target
	["_finalAltitude", -1],           //-- ATL hover height near target; -1 keeps current AI altitude behavior
	["_approachRadius", 1200],        //-- distance where slowdown starts
	["_hardBrakeRadius", 250]         //-- distance where anti-overshoot damping can start
];

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;

if (!alive _leaderVehicle) exitWith {
	// (format ["%1: Leader vehicle not alive",groupID _group]) remoteExec ["systemchat", 0];
};

private _effectiveCommander = effectiveCommander _leaderVehicle;
private _driver = driver _leaderVehicle;



private _groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;



// if !(_effectiveCommander in units _group) exitWith {};

private _movementControllers = [_effectiveCommander];

if (_driver != _effectiveCommander && {!isNull _driver && {_driver in units _group}}) then {
	_movementControllers pushBackUnique _driver;
};

private _distance2D = _leaderVehicle distance2D _movePos;
private _currentSpeed = abs speed _leaderVehicle; //-- speed returns km/h

private _destination = expectedDestination _effectiveCommander select 0;

// (format ["%1: destination: %2",groupID _group, _movePos]) remoteExec ["systemchat", 0];

if (_destination distance2D _movePos > 5 || {_currentSpeed < 5}) then {
	{
		[_x, _movePos] call A3C_ai_shared_fnc_doMove;
		// (format ["%1: doMove issued for %2 - destination: %3",groupID _group, _x, _movePos]) remoteExec ["systemchat", 0];
	} forEach _movementControllers;
};

{
	private _vehicle = vehicle _x;
	{
		_x enableAI "MOVE";
		_x enableAI "PATH";
		_x enableAI "ANIM";
	} foreach [_x, _vehicle];
	_vehicle land "NONE";
} forEach units _group;

/*
	Altitude shaping.

	This intentionally uses flyInHeight instead of forcing vertical velocity.
	The aircraft remains AI-flown, but starts converging toward the final
	hover altitude as it enters the approach envelope.
*/
if (_finalAltitude >= 0) then {
	private _currentAltitude = (getPosATL _leaderVehicle) select 2;

	if (_currentAltitude < 5) then {
		_currentAltitude = _leaderVehicle getVariable ["A3C_FLYINHEIGHT", 75]
	};

	private _desiredAltitude = if (_distance2D > _approachRadius) then {
		_currentAltitude
	} else {

		// private _testArray = [
		// 	_approachRadius,
		// 	75,
		// 	_distance2D,
		// 	_currentAltitude,
		// 	_finalAltitude,
		// 	true
		// ];
		// (str _testArray) remoteExec ["hint", 0];

		linearConversion [
			_approachRadius,
			75,
			_distance2D,
			_currentAltitude,
			_finalAltitude,
			true
		]
	};

	// (format ["%1: _desiredAltitude %2",groupID _group, _desiredAltitude]) remoteExec ["systemchat", 0];
	
	{
		_x flyInHeight _desiredAltitude;
	} foreach _groupVehicles;
};

private _cruiseSpeed = getNumber (configFile >> "CfgVehicles" >> typeOf _leaderVehicle >> "maxSpeed");
_cruiseSpeed = _cruiseSpeed max 120;

private _desiredSpeed = switch (true) do {
	case (_distance2D > _approachRadius): {
		_cruiseSpeed
	};

	case (_distance2D > 800): {
		linearConversion [_approachRadius, 800, _distance2D, _cruiseSpeed, 120, true]
	};

	case (_distance2D > 400): {
		linearConversion [800, 400, _distance2D, 120, 80, true]
	};

	case (_distance2D > 200): {
		linearConversion [400, 200, _distance2D, 80, 50, true]
	};

	case (_distance2D > 75): {
		linearConversion [200, 75, _distance2D, 50, _finalSpeed, true]
	};

	default {
		_finalSpeed
	};
};

_leaderVehicle limitSpeed _desiredSpeed;

/*
	Anti-overshoot damping.

	This does not rail the aircraft toward the target. It only soft-scales
	current horizontal velocity if the vehicle is moving faster than a
	conservative stop/approach envelope near the waypoint.

	The correction is intentionally blended so it does not visibly fight the
	AI pilot as much as a direct velocity clamp.
*/
if (_distance2D < _hardBrakeRadius && {_currentSpeed > (_desiredSpeed + 15)}) then {
	private _velocity = velocity _leaderVehicle;
	private _velocityHorizontal = [_velocity select 0, _velocity select 1, 0];
	private _horizontalSpeedMS = vectorMagnitude _velocityHorizontal;

	private _desiredSpeedMS = _desiredSpeed / 3.6;
	private _maxSafeSpeedMS = (_distance2D max 10) / 6;
	private _targetSpeedMS = _desiredSpeedMS min _maxSafeSpeedMS;

	if (_horizontalSpeedMS > _targetSpeedMS && {_horizontalSpeedMS > 0.1}) then {
		private _targetScale = _targetSpeedMS / _horizontalSpeedMS;

		private _correctionStrength = linearConversion [
			_hardBrakeRadius,
			50,
			_distance2D,
			0.15,
			0.45,
			true
		];

		private _softScale = linearConversion [
			0,
			1,
			_correctionStrength,
			1,
			_targetScale,
			true
		];

		private _newVelocity = [
			(_velocity select 0) * _softScale,
			(_velocity select 1) * _softScale,
			_velocity select 2
		];

		[_leaderVehicle, _newVelocity] remoteExec ["setVelocity", _leaderVehicle];
		// (format ["%1: newVelocity %2",groupID _group, _newVelocity]) remoteExec ["systemchat", 0];
	};
};

private _pilotsToRejoin = (units _group) select {
	_x == driver vehicle _x
	&& {!(_x in _movementControllers)}
	&& {_x != _leader}
};



if (_pilotsToRejoin isNotEqualTo []) then {
	// (format ["%1: pilotsToRejoin %2",groupID _group, _pilotsToRejoin]) remoteExec ["systemchat", 0];
	_pilotsToRejoin doFollow _leader;
};

// (format ["%1: desiredSpeed %2",groupID _group, _desiredSpeed]) remoteExec ["systemchat", 0];

_desiredSpeed
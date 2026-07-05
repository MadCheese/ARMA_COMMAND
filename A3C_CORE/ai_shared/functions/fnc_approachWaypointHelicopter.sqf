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
private _groupHelicopters = _groupVehicles select {
	_x isKindOf "HELICOPTER"
};



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
	Altitude / speed / anti-overshoot shaping.

	Only the leader vehicle receives the doMove command above.
	Every helicopter in the group receives the full approach profile:
	- flyInHeight
	- limitSpeed
	- soft anti-overshoot velocity damping

	This keeps vanilla formation movement intact while preventing follower helicopters
	from staying too high or too fast during the approach.
*/
private _leaderDesiredSpeed = _finalSpeed;

{
	private _vehicle = _x;

	private _vehicleDistance2D = _vehicle distance2D _movePos;
	private _vehicleCurrentSpeed = abs speed _vehicle; //-- speed returns km/h

	if (_finalAltitude >= 0) then {
		private _currentAltitude = (getPosATL _vehicle) select 2;

		if (_currentAltitude < 5) then {
			_currentAltitude = _vehicle getVariable ["A3C_FLYINHEIGHT", 75]
		};

		private _desiredAltitude = if (_vehicleDistance2D > _approachRadius) then {
			_currentAltitude
		} else {
			linearConversion [
				_approachRadius,
				75,
				_vehicleDistance2D,
				_currentAltitude,
				_finalAltitude,
				true
			]
		};

		_vehicle flyInHeight _desiredAltitude;
	};

	private _cruiseSpeed = getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "maxSpeed");
	_cruiseSpeed = _cruiseSpeed max 120;

	private _desiredSpeed = switch (true) do {
		case (_vehicleDistance2D > _approachRadius): {
			_cruiseSpeed
		};

		case (_vehicleDistance2D > 800): {
			linearConversion [_approachRadius, 800, _vehicleDistance2D, _cruiseSpeed, 120, true]
		};

		case (_vehicleDistance2D > 400): {
			linearConversion [800, 400, _vehicleDistance2D, 120, 80, true]
		};

		case (_vehicleDistance2D > 200): {
			linearConversion [400, 200, _vehicleDistance2D, 80, 50, true]
		};

		case (_vehicleDistance2D > 75): {
			linearConversion [200, 75, _vehicleDistance2D, 50, _finalSpeed, true]
		};

		default {
			_finalSpeed
		};
	};

	_vehicle limitSpeed _desiredSpeed;

	if (_vehicle == _leaderVehicle) then {
		_leaderDesiredSpeed = _desiredSpeed;
	};

	/*
		Anti-overshoot damping.

		This does not rail the aircraft toward the target. It only soft-scales
		current horizontal velocity if the vehicle is moving faster than a
		conservative stop/approach envelope near the waypoint.

		The correction is intentionally blended so it does not visibly fight the
		AI pilot as much as a direct velocity clamp.
	*/
	if (_vehicleDistance2D < _hardBrakeRadius && {_vehicleCurrentSpeed > (_desiredSpeed + 15)}) then {
		private _velocity = velocity _vehicle;
		private _velocityHorizontal = [_velocity select 0, _velocity select 1, 0];
		private _horizontalSpeedMS = vectorMagnitude _velocityHorizontal;

		private _desiredSpeedMS = _desiredSpeed / 3.6;
		private _maxSafeSpeedMS = (_vehicleDistance2D max 10) / 6;
		private _targetSpeedMS = _desiredSpeedMS min _maxSafeSpeedMS;

		if (_horizontalSpeedMS > _targetSpeedMS && {_horizontalSpeedMS > 0.1}) then {
			private _targetScale = _targetSpeedMS / _horizontalSpeedMS;

			private _correctionStrength = linearConversion [
				_hardBrakeRadius,
				50,
				_vehicleDistance2D,
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

			[_vehicle, _newVelocity] remoteExec ["setVelocity", _vehicle];
			// (format ["%1: newVelocity %2",groupID _group, _newVelocity]) remoteExec ["systemchat", 0];
		};
	};
} forEach _groupHelicopters;

private _pilotsToRejoin = (units _group) select {
	_x == driver vehicle _x
	&& {!(_x in _movementControllers)}
	&& {_x != _leader}
};



if (_pilotsToRejoin isNotEqualTo []) then {
	// (format ["%1: pilotsToRejoin %2",groupID _group, _pilotsToRejoin]) remoteExec ["systemchat", 0];
	_pilotsToRejoin doFollow _leader;
};

// (format ["%1: desiredSpeed %2",groupID _group, _leaderDesiredSpeed]) remoteExec ["systemchat", 0];

_leaderDesiredSpeed
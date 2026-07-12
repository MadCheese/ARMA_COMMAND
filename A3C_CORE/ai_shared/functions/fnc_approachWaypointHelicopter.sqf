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

if (!alive _leaderVehicle) exitWith {};

private _effectiveCommander = effectiveCommander _leaderVehicle;
private _driver = driver _leaderVehicle;

private _groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;
private _groupHelicopters = _groupVehicles select {
	_x isKindOf "HELICOPTER"
};

private _movementControllers = [_effectiveCommander];

if (_driver != _effectiveCommander && {!isNull _driver && {_driver in units _group}}) then {
	_movementControllers pushBackUnique _driver;
};

private _distance2D = _leaderVehicle distance2D _movePos;
private _currentSpeed = abs speed _leaderVehicle; //-- speed returns km/h
private _approachActive = _distance2D < _approachRadius;

private _destination = expectedDestination _effectiveCommander select 0;

if (_destination distance2D _movePos > 5 || {_currentSpeed < 5}) then {
	{
		[_x, _movePos] call A3C_ai_shared_fnc_doMove;
	} forEach _movementControllers;
};

{
	private _vehicle = vehicle _x;
	{
		_x enableAI "MOVE";
		_x enableAI "PATH";
		_x enableAI "ANIM";
	} foreach [_x, _vehicle];

	if (_approachActive) then {
		_vehicle land "NONE";
	};
} forEach units _group;

/*
	Altitude / speed / anti-overshoot shaping.

	Only the leader vehicle receives the doMove command above.
	Every helicopter in the group receives the approach profile once the
	leader enters the approach envelope:
	- flyInHeight
	- limitSpeed
	- soft anti-overshoot velocity damping
	- subordinate-only leader collision brake

	Altitude uses each helicopter's own distance to the move position, but
	the cruise-altitude anchor is taken from the leader vehicle because the
	leader's A3C_FLYINHEIGHT setting is authoritative for the group.
*/
private _leaderDesiredSpeed = _finalSpeed;

if (_approachActive) then {
	{
		private _vehicle = _x;

		private _vehicleDistance2D = _vehicle distance2D _movePos;
		private _vehicleCurrentSpeed = abs speed _vehicle; //-- speed returns km/h

		if (_finalAltitude >= 0) then {
			private _cruiseAltitude = _leaderVehicle getVariable ["A3C_FLYINHEIGHT", 75];

			private _desiredAltitude = if (_vehicleDistance2D > _approachRadius) then {
				_cruiseAltitude
			} else {
				linearConversion [
					_approachRadius,
					75,
					_vehicleDistance2D,
					_cruiseAltitude,
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
			};
		};

		/*
			Subordinate leader-collision brake.

			This does not issue formation or movement commands. It only soft-scales
			the subordinate helicopter's horizontal velocity if it is closing on the
			leader inside a short safety envelope.

			The leader vehicle is never braked here.

			The brake is tick-time aware because this helper is called at dynamic
			intervals by the waypoint scripts.
		*/
		if (_vehicle != _leaderVehicle) then {
			private _safeSeparation = _group getVariable ["A3C_HELI_APPROACH_SAFE_SEPARATION", 90];
			private _criticalSeparation = _group getVariable ["A3C_HELI_APPROACH_CRITICAL_SEPARATION", 35];

			private _vehiclePos = getPosASL _vehicle;
			private _leaderPos = getPosASL _leaderVehicle;

			private _toLeader = [
				(_leaderPos select 0) - (_vehiclePos select 0),
				(_leaderPos select 1) - (_vehiclePos select 1),
				0
			];

			private _separation = vectorMagnitude _toLeader;

			if (_separation > 0.1 && {_separation < _safeSeparation}) then {
				private _toLeaderDir = _toLeader vectorMultiply (1 / _separation);

				private _vehicleVelocity = velocity _vehicle;
				private _leaderVelocity = velocity _leaderVehicle;

				private _relativeVelocity = [
					(_vehicleVelocity select 0) - (_leaderVelocity select 0),
					(_vehicleVelocity select 1) - (_leaderVelocity select 1),
					0
				];

				private _closingSpeed = _relativeVelocity vectorDotProduct _toLeaderDir;

				if (_closingSpeed > 0.5) then {
					private _tickTime = (([_leaderVehicle, _distance2D] call A3C_ai_highCommand_fnc_getHeliWaypointSleep) min 1) max 0.1;

					private _brakeStrength = linearConversion [
						_safeSeparation,
						_criticalSeparation,
						_separation,
						0.03,
						0.25,
						true
					];

					private _closingBrakeBase = linearConversion [
						0.5,
						12,
						_closingSpeed,
						0,
						_brakeStrength,
						true
					];

					private _closingBrake = _closingBrakeBase * _tickTime;
					private _scale = 1 - _closingBrake;

					private _newVelocity = [
						(_vehicleVelocity select 0) * _scale,
						(_vehicleVelocity select 1) * _scale,
						_vehicleVelocity select 2
					];

					[_vehicle, _newVelocity] remoteExec ["setVelocity", _vehicle];
				};
			};
		};
	} forEach _groupHelicopters;
};

_leaderDesiredSpeed
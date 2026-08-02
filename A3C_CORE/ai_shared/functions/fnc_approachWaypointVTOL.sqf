// A3C_ai_shared_fnc_approachWaypointVTOL

params [
	"_group",
	"_movePos",
	["_finalSpeed", 90],              //-- km/h near the approach destination
	["_finalAltitude", 60],           //-- ATL approach height near target; -1 keeps current AI altitude behavior
	["_approachRadius", 3000],        //-- distance where VTOL slowdown starts
	["_hardBrakeRadius", 1000]        //-- minimum anti-overshoot damping envelope
];

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;

if !(alive _leaderVehicle && {canMove _leaderVehicle}) exitWith {
	_finalSpeed
};

private _groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;

private _groupVTOLs = _groupVehicles select {
	alive _x &&
	{canMove _x} &&
	{getNumber (configOf _x >> "vtol") > 0}
};

/*
	This helper is deliberately VTOL-only.

	If it is called for a group whose current leader vehicle is not a VTOL,
	it must not alter any aircraft settings. This keeps it safe to dispatch
	alongside the existing helicopter helper later.
*/
if !(_leaderVehicle in _groupVTOLs) exitWith {
	_finalSpeed
};

private _distance2D = _leaderVehicle distance2D _movePos;
private _approachActive = _distance2D < _approachRadius;

/*
	This helper deliberately issues no movement or destination command.

	The active waypoint remains solely responsible for moving the group.

	In particular, this helper must not call:
	- A3C_ai_shared_fnc_doMove
	- group move
	- doMove
	- moveTo
	- setDestination

	The waypoint script ends the approach when the VTOL enters the landing
	envelope, before an explicit movement order would necessarily complete.
	Leaving such an order active can make the aircraft resume its old approach
	path after landing instead of following its next waypoint.
*/
{
	private _unit = _x;
	private _vehicle = vehicle _unit;

	{
		_x enableAI "MOVE";
		_x enableAI "PATH";
		_x enableAI "ANIM";
	} forEach [
		_unit,
		_vehicle
	];
} forEach units _group;

if (_approachActive) then {
	{
		_x land "NONE";
	} forEach _groupVTOLs;
};

/*
	VTOL approach shaping.

	The existing helicopter helper remains unchanged. Only aircraft with a
	non-zero CfgVehicles >> vtol value are processed here.

	The profile intentionally keeps forward speed during the scripted approach.
	It is intended to deliver the VTOL to a controlled landAt handoff envelope,
	not to force airplaneX aircraft into a helicopter-like stop over _movePos.

	The speed-stage radii are proportional to _approachRadius so callers can tune
	the overall approach distance without invalidating fixed internal thresholds.
*/
private _farRadius = _approachRadius * 0.70;
private _midRadius = _approachRadius * 0.45;
private _nearRadius = _approachRadius * 0.25;
private _finalRadius = _approachRadius * 0.10;

private _altitudeFinalRadius = _approachRadius * 0.20;
private _leaderDesiredSpeed = _finalSpeed;

/*
	The correction is normalized against the waypoint helper's dynamic sleep so
	dedicated-server scheduling differences do not multiply the damping strength.
*/
private _tickTime = (
	(
		[
			_leaderVehicle,
			_distance2D
		] call A3C_ai_highCommand_fnc_getHeliWaypointSleep
	) min 1
) max 0.1;

if (_approachActive) then {
	{
		private _vehicle = _x;

		private _vehicleDistance2D =
			_vehicle distance2D _movePos;

		private _vehicleVelocity =
			velocity _vehicle;

		private _vehicleVelocityHorizontal = [
			_vehicleVelocity select 0,
			_vehicleVelocity select 1,
			0
		];

		private _horizontalSpeedMS =
			vectorMagnitude _vehicleVelocityHorizontal;

		private _vehicleCurrentSpeed =
			_horizontalSpeedMS * 3.6;

		private _horizontalVelocityScale = 1;

		if (_finalAltitude >= 0) then {
			private _cruiseAltitude =
				_leaderVehicle getVariable [
					"A3C_FLYINHEIGHT",
					75
				];

			private _desiredAltitude = if (
				_vehicleDistance2D > _approachRadius
			) then {
				_cruiseAltitude
			} else {
				linearConversion [
					_approachRadius,
					_altitudeFinalRadius,
					_vehicleDistance2D,
					_cruiseAltitude,
					_finalAltitude,
					true
				]
			};

			_vehicle flyInHeight _desiredAltitude;
		};

		private _cruiseSpeed =
			getNumber (configOf _vehicle >> "maxSpeed");

		_cruiseSpeed =
			_cruiseSpeed max (_finalSpeed max 220);

		private _farSpeed =
			((_finalSpeed max 220) min _cruiseSpeed);

		private _midSpeed =
			((_finalSpeed max 160) min _farSpeed);

		private _nearSpeed =
			((_finalSpeed max 120) min _midSpeed);

		private _desiredSpeed = switch (true) do {
			case (
				_vehicleDistance2D > _approachRadius
			): {
				_cruiseSpeed
			};

			case (
				_vehicleDistance2D > _farRadius
			): {
				linearConversion [
					_approachRadius,
					_farRadius,
					_vehicleDistance2D,
					_cruiseSpeed,
					_farSpeed,
					true
				]
			};

			case (
				_vehicleDistance2D > _midRadius
			): {
				linearConversion [
					_farRadius,
					_midRadius,
					_vehicleDistance2D,
					_farSpeed,
					_midSpeed,
					true
				]
			};

			case (
				_vehicleDistance2D > _nearRadius
			): {
				linearConversion [
					_midRadius,
					_nearRadius,
					_vehicleDistance2D,
					_midSpeed,
					_nearSpeed,
					true
				]
			};

			case (
				_vehicleDistance2D > _finalRadius
			): {
				linearConversion [
					_nearRadius,
					_finalRadius,
					_vehicleDistance2D,
					_nearSpeed,
					_finalSpeed,
					true
				]
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
			Momentum-aware anti-overshoot damping.

			The configured hard-brake radius is the minimum envelope. A faster
			aircraft receives a larger envelope, based on the distance required to
			reduce its current horizontal speed toward the requested speed using a
			conservative nominal deceleration.

			The correction only scales existing horizontal velocity. It preserves
			vertical velocity and does not steer or rail the aircraft toward target.
		*/
		private _desiredSpeedMS =
			_desiredSpeed / 3.6;

		private _speedDifferenceSquared = (
			(_horizontalSpeedMS * _horizontalSpeedMS) -
			(_desiredSpeedMS * _desiredSpeedMS)
		) max 0;

		private _nominalDeceleration = 4; //-- m/s^2; used only to size the soft-brake envelope

		private _estimatedBrakeDistance = (
			_speedDifferenceSquared /
			(2 * _nominalDeceleration)
		) * 1.25;

		private _brakeEnvelope = (
			_hardBrakeRadius max
			_estimatedBrakeDistance
		) min _approachRadius;

		private _vehiclePosASL =
			getPosASL _vehicle;

		private _toTarget = [
			(_movePos select 0) -
				(_vehiclePosASL select 0),
			(_movePos select 1) -
				(_vehiclePosASL select 1),
			0
		];

		private _targetDistance =
			vectorMagnitude _toTarget;

		private _closingSpeedMS = 0;

		if (_targetDistance > 0.1) then {
			private _toTargetDirection =
				_toTarget vectorMultiply (
					1 / _targetDistance
				);

			_closingSpeedMS =
				_vehicleVelocityHorizontal
				vectorDotProduct
				_toTargetDirection;
		};

		private _movingAwayFromTarget =
			_closingSpeedMS < -1;

		private _excessSpeed =
			_vehicleCurrentSpeed >
			(_desiredSpeed + 10);

		if (
			_vehicleDistance2D < _brakeEnvelope &&
			{
				_excessSpeed ||
				{
					_movingAwayFromTarget &&
					{
						_vehicleDistance2D <
							_hardBrakeRadius
					}
				}
			}
		) then {
			private _distanceLimitedSpeedMS =
				(_vehicleDistance2D max 75) / 6;

			private _targetSpeedMS =
				_desiredSpeedMS min
				_distanceLimitedSpeedMS;

			if (_movingAwayFromTarget) then {
				_targetSpeedMS =
					_targetSpeedMS min
					(_finalSpeed / 3.6);
			};

			if (
				_horizontalSpeedMS >
					_targetSpeedMS &&
				{
					_horizontalSpeedMS > 0.1
				}
			) then {
				private _targetScale =
					_targetSpeedMS /
					_horizontalSpeedMS;

				private _baseCorrectionStrength =
					linearConversion [
						_brakeEnvelope,
						_finalRadius,
						_vehicleDistance2D,
						0.04,
						0.20,
						true
					];

				if (_movingAwayFromTarget) then {
					_baseCorrectionStrength =
						_baseCorrectionStrength max
						0.18;
				};

				private _correctionStrength = (
					_baseCorrectionStrength *
					_tickTime
				) min 0.25;

				private _softScale =
					linearConversion [
						0,
						1,
						_correctionStrength,
						1,
						_targetScale,
						true
					];

				_horizontalVelocityScale =
					_horizontalVelocityScale min
					_softScale;
			};
		};

		/*
			Subordinate leader-collision brake.

			VTOL defaults are intentionally larger than helicopter defaults because
			the airframes and their turning/braking envelopes are substantially larger.
			The leader is never braked by this section.
		*/
		if (_vehicle != _leaderVehicle) then {
			private _safeSeparation =
				_group getVariable [
					"A3C_VTOL_APPROACH_SAFE_SEPARATION",
					250
				];

			private _criticalSeparation =
				_group getVariable [
					"A3C_VTOL_APPROACH_CRITICAL_SEPARATION",
					100
				];

			private _vehiclePos =
				getPosASL _vehicle;

			private _leaderPos =
				getPosASL _leaderVehicle;

			private _toLeader = [
				(_leaderPos select 0) -
					(_vehiclePos select 0),
				(_leaderPos select 1) -
					(_vehiclePos select 1),
				0
			];

			private _separation =
				vectorMagnitude _toLeader;

			if (
				_separation > 0.1 &&
				{
					_separation < _safeSeparation
				}
			) then {
				private _toLeaderDirection =
					_toLeader vectorMultiply (
						1 / _separation
					);

				private _leaderVelocity =
					velocity _leaderVehicle;

				private _relativeVelocity = [
					(_vehicleVelocity select 0) -
						(_leaderVelocity select 0),
					(_vehicleVelocity select 1) -
						(_leaderVelocity select 1),
					0
				];

				private _closingSpeed =
					_relativeVelocity
					vectorDotProduct
					_toLeaderDirection;

				if (_closingSpeed > 0.5) then {
					private _brakeStrength =
						linearConversion [
							_safeSeparation,
							_criticalSeparation,
							_separation,
							0.02,
							0.18,
							true
						];

					private _closingBrakeBase =
						linearConversion [
							0.5,
							20,
							_closingSpeed,
							0,
							_brakeStrength,
							true
						];

					private _closingBrake =
						_closingBrakeBase *
						_tickTime;

					private _scale =
						1 - _closingBrake;

					_horizontalVelocityScale =
						_horizontalVelocityScale min
						_scale;
				};
			};
		};

		if (_horizontalVelocityScale < 0.999) then {
			private _newVelocity = [
				(_vehicleVelocity select 0) *
					_horizontalVelocityScale,
				(_vehicleVelocity select 1) *
					_horizontalVelocityScale,
				_vehicleVelocity select 2
			];

			[
				_vehicle,
				_newVelocity
			] remoteExec [
				"setVelocity",
				_vehicle
			];
		};
	} forEach _groupVTOLs;
};

_leaderDesiredSpeed
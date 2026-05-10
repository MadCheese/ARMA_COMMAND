params ["_unit", "_destination", ["_doRotate", true]];

if (isNull _unit || {!alive _unit}) exitWith {};

if (!local _unit) exitWith {
	_this remoteExecCall [
		"A3C_ai_rail_fnc_infantryForceDestination",
		_unit
	];
};

private _unitPos = getPos _unit;
private _directionToDestination = [_unitPos, _destination] call BIS_fnc_dirTo;

if (
	((_unitPos select 2) > 1) &&
	{abs ((_unitPos select 2) - (_destination select 2)) > 0.2}
) exitWith {};

{
	_unit disableAI _x;
} forEach ["ANIM", "MOVE", "PATH"];

_unit setPhysicsCollisionFlag false;

private _damageHandler = _unit addEventHandler [
	"HandleDamage",
	{
		params ["_unit", "_hitSelection", "_damage", "_source"];

		private _effectiveDamage = if (
			isNull _source ||
			{side _source == civilian ||
			{side _source getFriend side _unit >= 0.6}}
		) then {
			0
		} else {
			_damage
		};

		_effectiveDamage
	}
];

private _getAnimations = {
	params ["_unit"];

	private _animationIndex = switch (stance _unit) do {
		case "CROUCH": {1};
		case "PRONE": {2};
		default {0};
	};

	private _moveAnimations = [
		"amovpercmwlksraswrfldf",
		"amovpknlmwlkslowwrfldf",
		"amovppnemevaslowwrfldf"
	];

	private _idleAnimations = [
		"aidlpercmstpsraswrfldnon_ai",
		"aidlpknlmstpsraswrfldnon_ai",
		"aidlppnemstpsraswrfldnon_ai"
	];

	[
		_moveAnimations select _animationIndex,
		_idleAnimations select _animationIndex
	]
};

private _animations = [_unit] call _getAnimations;
private _moveAnimation = _animations select 0;
private _idleAnimation = _animations select 1;

if (_doRotate) then {
	private _unitPosASL = getPosASL _unit;

	private _rotationDuration = linearConversion [
		0,
		180,
		abs (180 - (_unit getRelDir _destination)),
		0,
		1
	];

	private _rotationHandle = [
		_unit,
		_unitPosASL,
		_unitPosASL,
		vectorDirVisual _unit,
		[_unit getDir _destination] call MCSS_fnc_DegreeToVector,
		vectorUpVisual _unit,
		[0, 0, 1],
		_rotationDuration
	] spawn A3C_ai_rail_fnc_vehicleOrient;

	waitUntil {
		scriptDone _rotationHandle
	};
} else {
	(vehicle _unit) setDir _directionToDestination;
};

{
	_unit disableAI _x;
} forEach ["MOVE", "PATH", "ANIM"];

private _frameFunction = {
	params ["_moveAnimation", "_unit", "_destination"];

	private _allowMovement = true;

	//-- KEEP THIS FOR ENHANCED MOVEMENT VAULTING - currently preferring the normal version.
	// private _enhancedMovementAvailable = (
	// 	!isNil "A3C_EHM" &&
	// 	{A3C_EHM} &&
	// 	{!isNil "A3C_Babe_fnc_detect"}
	// );

	private _enhancedMovementAvailable = false;

	if (_enhancedMovementAvailable) then {
		if (_unit getVariable ["A3C_EM_ACTIVE", false]) then {
			//-- Enhanced Movement is currently handling the obstacle.
			_allowMovement = false;
		} else {
			if (
				_unit distance2D _destination > 1.5 &&
				{[_unit, _destination] call A3C_Babe_fnc_detect}
			) then {
				{
					_unit enableAI _x;
				} forEach ["ANIM", "MOVE", "PATH"];

				_unit setVariable ["A3C_EM_ACTIVE", true, true];
				_allowMovement = false;
			};
		};
	};

	if (!isTouchingGround _unit) then {
		_allowMovement = false;
	};

	if (_allowMovement) then {
		{
			_unit disableAI _x;
		} forEach ["ANIM", "MOVE", "PATH"];

		if !(isTouchingGround _unit) then {
			private _surfaceProbeStart = +getPosASL _unit;
			private _surfaceProbeEnd = +_surfaceProbeStart;

			_surfaceProbeEnd set [2, (_surfaceProbeEnd select 2) - 1];

			private _surfaceHits = lineIntersectsSurfaces [
				_surfaceProbeStart,
				_surfaceProbeEnd,
				_unit,
				objNull
			];

			if (_surfaceHits isNotEqualTo []) then {
				_surfaceProbeEnd set [2, ((_surfaceHits select 0) select 0) select 2];
				_unit setPosASL _surfaceProbeEnd;
			};
		};

		private _currentDirectionToDestination = _unit getDir _destination;
		private _directionVector = [_currentDirectionToDestination] call MCSS_fnc_DegreeToVector;

		_unit setVectorDir _directionVector;
		_unit lookAt (_destination getPos [100, _currentDirectionToDestination]);

		private _currentMoveTime = moveTime _unit;

		if (_currentMoveTime == 0) then {
			_unit playMoveNow _moveAnimation;
		};

		if (_currentMoveTime > 0) then {
			private _railSpeed = 10 / 3.6;

			private _velocity = [
				_railSpeed * sin _currentDirectionToDestination,
				_railSpeed * cos _currentDirectionToDestination,
				0
			];

			_unit setVelocity _velocity;
		};
	};
};

private _eventId = format [
	"A3C_INF_RAIL_%1_%2",
	netId _unit,
	floor (diag_tickTime * 1000)
];

[
	_eventId,
	"onEachFrame",
	compile format [
		"
			[
				%1,
				%2,
				%3
			] call %4;
		",
		_moveAnimation,
		_unit,
		_destination,
		_frameFunction
	]
] call BIS_fnc_addStackedEventHandler;

private _initialPosASL = getPosASL _unit;
private _originalDistance = _unit distance2D _destination;
private _stuckCounter = 0;
private _lastCheckedPositionASL = getPosASL _unit;
private _lastMoveTime = 0;

while {alive _unit} do {
	private _distanceToDestination = _unit distance2D _destination;

	if (_distanceToDestination < 0.3) exitWith {};
	if ({_unit distance2D _x > _originalDistance} count [_initialPosASL, _destination] > 1) exitWith {};
	if ("ladder" in animationState _unit) exitWith {};

	sleep 0.1;

	private _currentMoveTime = moveTime _unit;
	private _hasMovedSinceLastCheck = (_unit distance2D _lastCheckedPositionASL) >= 0.2;
	private _enhancedMovementActive = _unit getVariable ["A3C_EM_ACTIVE", false];

	if (
		_lastMoveTime == _currentMoveTime ||
		{!_hasMovedSinceLastCheck && {!_enhancedMovementActive}}
	) then {
		_stuckCounter = _stuckCounter + 1;
	} else {
		_stuckCounter = 0;
	};

	if (_stuckCounter > 30) exitWith {};

	_lastCheckedPositionASL = getPosASL _unit;
	_lastMoveTime = _currentMoveTime;
};

//-- Stop fake walking.
[_eventId, "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

_unit setVelocity [0, 0, 0];
_unit playMoveNow _idleAnimation;

sleep 1;

{
	_unit enableAI _x;
} forEach ["ANIM", "MOVE", "PATH"];

[_unit, _damageHandler] spawn {
	params ["_unit", "_damageHandler"];

	sleep 5;

	if (!isNull _unit) then {
		_unit removeEventHandler ["HandleDamage", _damageHandler];
		_unit setPhysicsCollisionFlag true;
	};
};
//-- #TODO morph this fnc and fnc_helicopter.sqf into one ANIMATEFLIGHT fnc. First attempt failed, this is a placeholder

params [
	"_vehicle",
	"_startPos",
	"_endPos",
	"_vectorDirFrom",
	"_vectorDirTo",
	"_vectorUpFrom",
	"_vectorUpTo",
	"_duration"
];

if (isTouchingGround _vehicle && {_vehicle isKindOf "AIR"}) exitWith {};

private _startTime = time;
private _endTimeEstimated = time + _duration;

[_vehicle] call MCSS_fnc_setVehicleVarname;

{
	_x disableAI "ALL";
} forEach [_vehicle, driver _vehicle];

_vehicle setVariable ["A3C_AI_RAIL", true, true];

private _eventHandlerId = format ["A3C_EH_RAIL_%1", str _vehicle];

[
	_eventHandlerId,
	"onEachFrame",
	{
		params [
			"_vehicle",
			"_startPos",
			"_endPos",
			"_vectorDirFrom",
			"_vectorDirTo",
			"_vectorUpFrom",
			"_vectorUpTo",
			"_startTime",
			"_endTimeEstimated",
			"_eventHandlerId"
		];

		private _orientationProgress = linearConversion [
			_startTime,
			_endTimeEstimated,
			time,
			0,
			1,
			true
		];

		private _railCompleted = time >= _endTimeEstimated;
		private _railInterrupted = !alive _vehicle;

		private _velocityTransformation = [
			_startPos,
			_endPos,
			[0, 0, 0],
			[0, 0, 0],
			_vectorDirFrom,
			_vectorDirTo,
			_vectorUpFrom,
			_vectorUpTo,
			_orientationProgress
		];

		[_vehicle, _velocityTransformation] remoteExec ["setVelocityTransformation", _vehicle];

		if (_railCompleted || {_railInterrupted}) exitWith {
			[_eventHandlerId, "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

			{
				[_x, "ALL"] remoteExec ["enableAI", _x];
			} forEach [_vehicle, driver _vehicle];

			_vehicle setVariable ["A3C_AI_RAIL", false, true];
			_vehicle setVectorUp [0, 0, 1];
		};
	},
	[
		_vehicle,
		_startPos,
		_endPos,
		_vectorDirFrom,
		_vectorDirTo,
		_vectorUpFrom,
		_vectorUpTo,
		_startTime,
		_endTimeEstimated,
		_eventHandlerId
	]
] call BIS_fnc_addStackedEventHandler;

waitUntil {
	!(_vehicle getVariable ["A3C_AI_RAIL", false])
};
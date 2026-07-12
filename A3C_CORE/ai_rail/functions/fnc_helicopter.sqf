//-- function to rail a helicopter towards a precise position linearly

params ["_vehicle", "_startPos", "_endPos", "_speed", "_endDir"];

if (isNil "_endDir") then {
	_endDir = [_vehicle getDir _endPos] call MCSS_fnc_degreeToVector;
};

private _totalDistance = _startPos distance _endPos;
private _travelDuration = (((_totalDistance / _speed) * 0.001) * 60) * 60;
private _startTime = time;
private _initialEndTimeEstimated = time + _travelDuration;

[_vehicle] call A3C_main_fnc_setVehicleVarname;

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
			"_startTime",
			"_initialEndTimeEstimated",
			"_endDir",
			"_eventHandlerId"
		];

		private _remainingDistance = _vehicle distance _endPos;
		private _remainingTravelDuration = (((_remainingDistance / 80) * 0.001) * 60) * 60;
		private _currentEndTimeEstimated = time + _remainingTravelDuration;

		private _railCompleted = time >= _initialEndTimeEstimated;
		private _railInterrupted = isTouchingGround _vehicle || {!canMove _vehicle};

		private _movementProgress = linearConversion [
			_startTime,
			_initialEndTimeEstimated,
			time,
			0,
			1,
			true
		];

		private _velocityTransformation = [
			_startPos,
			_endPos,
			[10, 0, 0],
			[10, 0, 0],
			vectorDirVisual _vehicle,
			_endDir,
			vectorUpVisual _vehicle,
			[0, 0, 1],
			_movementProgress
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
		_startTime,
		_initialEndTimeEstimated,
		_endDir,
		_eventHandlerId
	]
] call BIS_fnc_addStackedEventHandler;

waitUntil {
	!(_vehicle getVariable ["A3C_AI_RAIL", false])
};
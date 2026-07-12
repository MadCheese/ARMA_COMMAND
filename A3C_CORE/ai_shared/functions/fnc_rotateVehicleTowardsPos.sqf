// A3C_ai_shared_fnc_rotateVehicleTowardsPos

params ["_unit", "_destination"];

if (isNull _unit) exitWith {};

// Best case: run the rotation loop where the object is local.
// If this function is not whitelisted for remoteExec in your mission,
// remove this guard and keep the direct setDir logic local to caller.
if (!local _unit) exitWith {
	[_unit, _destination] remoteExecCall ["A3C_ai_shared_fnc_rotateVehicleTowardsPos", _unit];
};

private _timeout = 10;
private _startTime = time;

// Helicopters: preserve original concept.
// Do not force setDir; order forward movement and wait until aligned.
if (_unit isKindOf "Helicopter") exitWith {
	private _vehicle = vehicle _unit;
	private _movePos = _vehicle getPos [100, _vehicle getDir _destination];

	[driver _vehicle, _movePos] call A3C_ai_shared_fnc_doMove;

	while { canMove _vehicle } do {
		private _relDir = _vehicle getRelDir _destination;
		private _angleDiff = _relDir min (360 - _relDir);

		if (_angleDiff <= 30) exitWith {};
		if (time > _startTime + _timeout) exitWith {};

		sleep 0.05;
	};
};

// Degrees per second.
// These are intentionally explicit, because the old version's speed depended on loop execution rate.
private _turnRate = switch (true) do {
	case (_unit isKindOf "Man"): {
		75
	};

	case (_unit isKindOf "Tank"): {
		30
	};

	default {
		60
	};
};

private _endDiff = 3;
private _sleepTime = 0.01;

private _isOnGradient = {
	params ["_vehicle"];

	([0, 90, 180, 270] findIf {
		abs ([_vehicle, (getDir _vehicle) + _x] call BIS_fnc_terrainGradAngle) > 5
	}) >= 0
};

private _gradient = (_unit isKindOf "Tank") && { [_unit] call _isOnGradient };
private _vectorUp = vectorUp _unit;

if (_gradient) then {
	_endDiff = 15;
	_turnRate = 110;
	_sleepTime = 0.05;
};

private _lastTick = diag_tickTime;

while { true } do {
	private _relDir = _unit getRelDir _destination;
	private _angleDiff = _relDir min (360 - _relDir);

	if (_angleDiff <= _endDiff) exitWith {};
	if (time > _startTime + _timeout) exitWith {};

	private _currentTick = diag_tickTime;
	private _deltaTime = (_currentTick - _lastTick) max 0.001;
	_lastTick = _currentTick;

	// getRelDir:
	// 0..180 = target to the right/front side
	// 180..360 = target to the left side
	private _turnSign = if (_relDir > 180) then {
		-1
	} else {
		1
	};

	private _step = (_turnRate * _deltaTime * accTime) min _angleDiff;
	private _newDir = (getDir _unit) + (_step * _turnSign);

	_unit setDir _newDir;

	if (_gradient) then {
		_unit setVectorUp _vectorUp;
	};

	sleep _sleepTime;
};
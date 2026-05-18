// A3C_ai_rail_fnc_FPV

params ["_drone", "_target"];

if !(local _drone) exitWith {};

private _droneSpeed = 100;              // Max speed of the drone
private _lastVelocity = velocity _drone; // Start with the drone's natural velocity
private _lastFrame = diag_frameNo;
private _transitionTime = 3;            // Time (in seconds) for the smooth transition phase
private _startTime = 0;                 // Will be set when hijacking starts
private _isTransitioning = false;       // Flag for the transition phase
private _controlDistance = 200;         // Distance to target for script hijacking

// Function to blend velocities
private _fnc_blendVelocity = {
	params ["_currentVelocity", "_targetVelocity", "_factor"];

	[
		(_currentVelocity select 0) * (1 - _factor) + (_targetVelocity select 0) * _factor,
		(_currentVelocity select 1) * (1 - _factor) + (_targetVelocity select 1) * _factor,
		(_currentVelocity select 2) * (1 - _factor) + (_targetVelocity select 2) * _factor
	]
};

while {alive _drone} do {
	waitUntil {diag_frameNo > _lastFrame};

	_lastFrame = diag_frameNo;

	// Update target position
	private _targetPosASL = getPosASL _target;
	private _dronePosASL = getPosASL _drone;
	private _vectorToTarget = _targetPosASL vectorDiff _dronePosASL;
	private _distanceToTarget = vectorMagnitude _vectorToTarget;

	// Calculate the desired velocity based on the moving target
	private _desiredVelocity = if (_distanceToTarget > 0) then {
		_vectorToTarget vectorMultiply (_droneSpeed / _distanceToTarget)
	} else {
		[0, 0, 0]
	};

	// Script takeover within control distance
	if (_distanceToTarget < _controlDistance) then {
		if (!_isTransitioning) then {
			_isTransitioning = true;
			_startTime = time; // Start the timer for transition
		};

		// Time elapsed since the transition began
		private _elapsedTime = time - _startTime;

		// Calculate interpolation factor with quadratic ease-in
		private _factor = ((_elapsedTime / _transitionTime) min 1)^2;

		// Apply blending between current and desired velocity
		_lastVelocity = [_lastVelocity, _desiredVelocity, _factor] call _fnc_blendVelocity;

		// Check if the transition is complete
		if (_elapsedTime >= _transitionTime) then {
			_isTransitioning = false; // End the transition
		};
	} else {
		// Before takeover, maintain the drone's natural velocity
		_lastVelocity = velocity _drone;
	};

	// Apply the blended or railed velocity to the drone
	_drone setVelocity _lastVelocity;

	// Exit when close enough to target
	if (_distanceToTarget < 5) exitWith {
		// Final burst of speed for impact
		private _currentVelocity = velocity _drone;
		private _droneDirection = getDir _drone;

		_drone setVelocity [
			(_currentVelocity select 0) + (sin _droneDirection * 300),
			(_currentVelocity select 1) + (cos _droneDirection * 300),
			_currentVelocity select 2
		];
	};
};
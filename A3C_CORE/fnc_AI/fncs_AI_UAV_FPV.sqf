
// [] execVM "A3C_CORE\fnc_AI\fncs_AI_UAV_FPV.sqf"; 


// Initialize drone and target
// private _drone = fpvDrone; // Your drone object
// private _target = targetTruck; // Target vehicle object



// onEachFrame handler
A3C_oef_fpv = {
    params ["_drone", "_target", "_vUp"];

	
    // Desired altitude above target (in meters)
    private _altitudeOffset = 1;

    // Desired speed in m/s (30 km/h)
    private _speed = 150 / 3.6;

    // Get current positions
    private _dronePos = getPosASL _drone;
	private _targetDriver = driver _target;

	

	private _specialHitSelection = ((getAllHitPointsDamage _target) select 1) select {
		private _hp = _x;
		{_x in toLower _hp} count ["fuel","motor","engine","tank"] > 0
	};

	_specialHitSelection = _specialHitSelection select {
		!( (_target selectionposition _x) isEqualTo [0,0,0] )
	};

	// systemchat format ["_specialHitSelection: %1", _specialHitSelection];

	private _targetPos = if (_specialHitSelection isEqualTo []) then {
		if (!isNull _targetDriver) then {getPosASL _targetDriver} else {getPosASL _target}
	} else {
		private _selectedHitpoint = _specialHitSelection select 0;
		// systemchat format ["SPECIAL POS SELECTED - %1", _selectedHitpoint];
		_target modelToWorldVisual (_target selectionposition _selectedHitpoint);
	};

	
	

    // private _targetPos = if (_specialHitPos isEqualTo [0,0,0]) then {
	// 	if (!isNull _targetDriver) then {getPosASL _targetDriver} else {getPosASL _target}
	// } else {
	// 	systemchat "MOTOR POS SELECTED";
	// 	_target modelToWorldVisual _specialHitPos
	// };

	

    // Adjust for altitude offset
    private _adjustedTargetPos = _targetPos;
    _adjustedTargetPos set [2, (_adjustedTargetPos select 2) + _altitudeOffset];

    // Calculate 2D distance (horizontal) and vertical difference
    private _distance2D = _dronePos distance2D _adjustedTargetPos;
    private _verticalDifference = (_adjustedTargetPos select 2) - (_dronePos select 2);

    // Calculate total distance using Pythagoras
    private _totalDistance = sqrt (_distance2D^2 + _verticalDifference^2);

    // Proximity check to stop near the target
    // if (_totalDistance < 5) exitWith {
    //     // Stop the drone when close enough to the target
    //     _drone setVelocity [0, 0, 0];
    //     player commandChat "Drone has reached the target!";
    // };
	// _drone setVectorUp [0,0,1];
    // Normalize vector to target
    private _vectorToTarget = _adjustedTargetPos vectorDiff _dronePos;

    // Scale the velocity proportionally to the speed
    private _horizontalDirection = [_vectorToTarget select 0, _vectorToTarget select 1, 0];
    private _normalizedHorizontal = vectorNormalized _horizontalDirection;
    private _horizontalVelocity = _normalizedHorizontal vectorMultiply _speed;

    // Add vertical velocity
    private _verticalSpeed = (_verticalDifference / _totalDistance) * _speed;
    
	// if (_drone distance2D _target > 150) then {
	// 	_verticalSpeed = 0;
	// };
	// _verticalSpeed = -30; //_verticalSpeed * 20;
	
	private _velocity = [_horizontalVelocity select 0, _horizontalVelocity select 1, _verticalSpeed];
	
	// if (diag_frameNo % 2 == 0) then {
	// 	private _relDir = _drone getReldir _target;
	// 	if (_relDir > 2 && {_reldir < 362}) then {
	// 		_drone setdir (_drone getdir _target);
	// 		systemchat str ('adjust ' + (str time));
	// 	};
	// };
	
	_drone setVectorUp _vUp;
    // Apply velocity to the drone
    _drone setVelocity _velocity;
	// systemchat str time;

    // // Debug output
    // hintSilent format [
    //     "Distance 2D: %1\nVertical Difference: %2\nTotal Distance: %3\nVelocity: %4\nDrone Position: %5\nTarget Position: %6",
    //     _distance2D, _verticalDifference, _totalDistance, _velocity, _dronePos, _adjustedTargetPos
    // ];
};

// _drone setdir (_drone getdir _target);

A3C_UAV_FPV_V1 = {
    params ["_drone", "_target"];

    _tilt_to = [_drone, position _target] call MCSS_fnc_TiltTowardsPos;
    _tilt_to params ["_vDi","_vUp"];
    _drone setVectorDirAndUp [_vDi,_vUp];

    private _ehString = format ["A3C_EH_FPV_%1", _drone];
    // systemChat str _ehString;

    [ // Add onEachFrame event handler
        _ehString,
        "onEachFrame",
        compile format ["[%1, %2] call A3C_oef_fpv", _drone, _target, _vUp]
    ] call BIS_fnc_addStackedEventHandler;

    waitUntil {!alive _drone};
    _kaboom = "Bo_GBU12_LGB" createVehicle  (position _target);


    // systemChat "FPV done - Removing Stacked EH";

    [ // Remove onEachFrame event handler
        _ehString,
        "onEachFrame"
    ] call BIS_fnc_removeStackedEventHandler;
};


// [fpvDrone, targetTruck] spawn A3C_FPV_RAIL;

A3C_FPV_RAIL = {
    params ["_drone", "_target"];
    if !(local _drone) exitWith {};
    
    private _dronespeed = 100;            // Max speed of the drone
    private _lastVelocity = velocity _drone; // Start with the drone's natural velocity
    private _lastFrame = diag_frameNo;
    private _transitionTime = 3;         // Time (in seconds) for the smooth transition phase
    private _startTime = 0;              // Will be set when hijacking starts
    private _isTransitioning = false;    // Flag for the transition phase
    private _controlDistance = 200;      // Distance to target for script hijacking

    // Function to blend velocities
    private _blendVelocity = {
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
        private _vd = _targetPosASL vectorDiff (getPosASL _drone);
        private _distance = vectorMagnitude _vd;

        // Calculate the desired velocity based on the moving target
        private _desiredVelocity = if (_distance > 0) then {
            [
                (_vd select 0) / _distance * _dronespeed,
                (_vd select 1) / _distance * _dronespeed,
                (_vd select 2) / _distance * _dronespeed
            ]
        } else {
            [0, 0, 0];
        };

        // Script takeover within control distance
        if (_distance < _controlDistance) then {
            if (!_isTransitioning) then {
                _isTransitioning = true;
                _startTime = time; // Start the timer for transition
            };

            // Time elapsed since the transition began
            private _elapsedTime = time - _startTime;

            // Calculate interpolation factor with quadratic ease-in
            private _factor = ((_elapsedTime / _transitionTime) min 1)^2;

            // Apply blending between current and desired velocity
            _lastVelocity = [_lastVelocity, _desiredVelocity, _factor] call _blendVelocity;

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
        if (_distance < 5) exitWith {
            // Final burst of speed for impact
            private _vel = velocity _drone;
            private _dir = getDir _drone;
            _drone setVelocity [
                (_vel select 0) + (sin _dir * 300),
                (_vel select 1) + (cos _dir * 300),
                (_vel select 2)
            ];
        };
    };
};





//[fpvDrone] spawn A3C_drone_test; 
A3C_drone_test = {
	// params ["_drone"];

	
	

	drone = _this select 0;
	A3C_DV = [0,30,0]; //[0,70,0];

	_pos = (getPosASL player) vectorAdd [0,10,3];

	drone setPosASL _pos;

	drone disableAI "ALL";
	// drone enableSimulation false;

	onEachFrame {
		_drone = drone;
		// _drone setvectorUp [0,0.5,1];
		_pointPos = _drone getPos [5,0];
		_tilt = [_drone, _pointPos] call MCSS_fnc_TiltTowardsPos;
		_tilt params ["_newVectorDir","_newVectorUp"];
		if (diag_frameNo % 5 == 0) then {
			_drone setVectorDirAndUp _tilt;
		};
		
		// _drone setVectorUp [0,0.5,1];
		_drone setVelocity A3C_DV;
		
	};
};


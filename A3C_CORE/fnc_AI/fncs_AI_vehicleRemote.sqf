
A3C_GP_RC_RemoveHandlers = {
    params ["_display"]; //-- we could get the display from visiblemap but it's tidier this way... assumably
    if (!visiblemap) then {
        // systemchat '3d';
        BR_A3C_DISABLE_RADIAL = false;
        _display displayRemoveEventHandler ["KeyDown",a3c_tank_remote_down];
        _display displayRemoveEventHandler ["KeyUp",a3c_tank_remote_up];
        _display displayRemoveEventHandler ["MouseButtonDown",a3c_tank_remote_MD];
    } else {
        // systemchat 'map';
        _display ctrlRemoveEventHandler ["KeyDown",a3c_tank_remote_down];
        _display ctrlRemoveEventHandler ["KeyUp",a3c_tank_remote_up];
        _display ctrlRemoveEventHandler ["MouseButtonDown",a3c_tank_remote_MD];
    };
    a3c_is_HC_remote = false;
    a3c_remote_tank_obj disableBrakes false;
    a3c_remote_tank_obj = objNull;
    hintSilent "";
};



A3C_GP_RC_UIVehicleRemoteFnc = {

    private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
    private _isRadial = _a3c_dsp == 100040;

    if (_isRadial) then {
        BR_A3C_DISABLE_RADIAL = true;
        [] call A3C_RADIAL_CloseDisplay;
    };
    a3c_is_HC_remote = true;
    hint "CONTROL THE VEHICLE WITH ARROW KEYS. CANCEL REMOTE WITH CTRL+RMB";

    a3c_remote_tank_obj = vehicle (leader (A3C_SELECTED_HC_GROUPS_SETTINGS select 0));


    [
        [a3c_remote_tank_obj],
        {
            params ["_veh"];
            _veh action ["engineOn", _veh];
            _veh engineOn true;
            // _veh disableBrakes true; 
        }
    ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];

    a3c_tank_speed = 0;
    a3c_tank_speed_max = 5;

    _disp = if (_isRadial) then {findDisplay 46} else {findDisplay 12 displayCtrl 51};

    //a3c_tank_remote_down = _disp displayAddEventHandler
    _a3c_rva1 =
    [
        "KeyDown",
        {
            params ["_display","_key","_shift","_ctrl","_alt"];

            if (_key in [15]) exitWith {
                //-- TAB
                if (_alt) then {
                    [_display] call A3C_GP_RC_RemoveHandlers;
                    // systemchat "alt tab";
                };
                true
            };

            if (!alive (driver a3c_remote_tank_obj)) exitWith {
                [_display] call A3C_GP_RC_RemoveHandlers;
                // systemchat "no driver";
            };

            // systemchat str _key;
            //
            _block = false;
            
            _tankVelo = (velocityModelSpace a3c_remote_tank_obj) select 1;

            hint "CONTROL THE VEHICLE WITH ARROW KEYS. CANCEL REMOTE WITH CTRL+RMB";

            //if (_key in [1]) exitWith {false};


            a3c_tank_speed_max = if (_shift) then {15} else {5};
            _rotation = 1; //if (_shift) then {2} else {1};

            systemchat format ["", "ingamePause", "showMap"];

            _doExit = false;

            {
                _action = inputaction _x;
                if (_action > 0) exitWith {
                    _doExit = true;
                    // systemchat format ["EXIT INPUT %1 (%2)", _x, _action];
                    // if (_key in [1,50]) exitWith { //-- ESC, M //-- stop functionality
                        // hint "SECURITY: EXITING VEHICLE-REMOTE";
                        [_display] call A3C_GP_RC_RemoveHandlers;
                        
                    // }; 
                };
            } foreach ["ingamePause", "showMap"];

            if (_doExit) exitWith {a3c_is_HC_remote = false;};

            

            

            // if (_key in [1,50]) exitWith { //-- replaced by inputAction version for changing keybinds

            //     hint "SECURITY: EXITING VEHICLE-REMOTE";

            //     [_display] call A3C_GP_RC_RemoveHandlers;
                
            // }; 


            if !(_key in [200,203,205,208]) exitWith {};

            // systemchat 'whut';

            // if () exitWith {};

            private _moveVector = [0,0,0];

            hint "CONTROL THE VEHICLE WITH ARROW KEYS. CANCEL REMOTE WITH CTRL+RMB";

			//engine = "[_this select 0,_this select 1,20] call rhs_fnc_engineStartupDelay;_this call rhs_fnc_engineCheckDamage";

            private _fnc_turn = {
                params ["_vehicle","_angleDiff"];

				if !(isEngineOn _vehicle) exitWith {
					_vehicle engineOn true;
				};

				if (!(_vehicle isKindOf "TANK") && {abs ((velocityModelSpace _vehicle) select 1) < 4}) exitWith {}; //-- only tracked vehicles can rotate while stationary

                private _currentVelocity = velocity _vehicle;
				//private _vectorUp = vectorUp _vehicle;

                private _newDir = [getDir _vehicle + _angleDiff] call MCSS_fnc_CorrectDir;

				private _terrainVectors = [getPos _vehicle, _newDir] call MCSS_fnc_TerrainTilt;
				// systemchat str [_terrainVectors];
                    // Calculate new velocity components after rotation
                private _newVx = (_currentVelocity select 0) * cos(_angleDiff) - (_currentVelocity select 1) * sin(_angleDiff);
                private _newVy = (_currentVelocity select 0) * sin(_angleDiff) + (_currentVelocity select 1) * cos(_angleDiff);
                private _newVelocity = [_newVx, _newVy, _currentVelocity select 2];

                // _vehicle setDir _newDir;                // Rotate the vehicle
				_vehicle setVectorDirAndUp _terrainVectors; //_vectorUp; // (surfaceNormal _weaponPos); //
				_vehicle setVectorUp (surfaceNormal (getPos _vehicle));
                _vehicle setVelocity _newVelocity;      
            };

			// a3c_remote_tank_obj setVariable ["rhs_engine_last", time, true];
			// a3c_remote_tank_obj setVariable ["rhs_engine_completed", time, true];

            switch (_key) do {
                case (203) : { //-- LEFT ARROW
                    // // _moveVector = [-7,0,0];
                    // // a3c_remote_tank_obj sendSimpleCommand "LEFT";
					if (_alt) then {
						[a3c_remote_tank_obj,"LEFT"] remoteExec ["sendSimpleCommand",a3c_remote_tank_obj];
					} else {
						[[a3c_remote_tank_obj, -.5],_fnc_turn] remoteExec ["bis_fnc_call", a3c_remote_tank_obj];
					};
                    
                    
            
                }; 
                case (205) : { // -- RIGHT ARROW
                    // // _moveVector = [7,0,0];
                    // // a3c_remote_tank_obj sendSimpleCommand "RIGHT";
					if (_alt) then {
						[a3c_remote_tank_obj,"RIGHT"] remoteExec ["sendSimpleCommand",a3c_remote_tank_obj];
					} else {
						[[a3c_remote_tank_obj, .5],_fnc_turn] remoteExec ["bis_fnc_call", a3c_remote_tank_obj];						
					};
                    
                    
                }; 
                // case (200) : { //--- UP ARROW
                //     _moveVector = [0,11,0];	
                // }; 
                // case (208) : { //-- DOWN ARROW
                //     _moveVector = [0,-11,0];	
                // };
            };

            if (_key == 208) then { //-- DOWN ARROW
                
                [
                    [a3c_remote_tank_obj, [0, -5, 0]],
                    {
                        params ["_veh","_vel"];
						_veh engineOn true;
                        _veh disableBrakes true;
                        // _veh setVelocityModelSpace _vel;
                        _vms = velocityModelSpace _veh;
                        _forwardForce = _vms select 1;
                        _forwardForce = (_forwardForce - 0.2) max -5;
                        // systemchat str _forwardForce;
                        _vms set [1, _forwardForce];
                        [_veh,_vms] remoteExec ["setVelocityModelSpace",_veh];
                        // _veh setVelocityModelSpace _vms;
                    }
                ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];	
                
                //true
            };

            if (_key == 200) then { //-- UP ARROW
                // //-- METHOD 1: does not work alongside 'Left' and 'right'
                // [
                // 	[a3c_remote_tank_obj,_moveVector],
                // 	{
                // 		params ["_veh","_moveVector"];
                // 		_movePos = _veh modelToWorld _moveVector;
                // 		// _veh setDriveOnPath [getPos _veh, _movePos];
                // 		[_veh, [getPos _veh, _movePos]] remoteExec ["setDriveOnPath",_veh];
                // 	}
                // ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];

                // //-- METHOD 2: requires player to be in vehicle
                // [a3c_remote_tank_obj,"FAST"] remoteExec ["sendSimpleCommand",a3c_remote_tank_obj];

                //-- METHOD 3: Works with turning
                [
                    [a3c_remote_tank_obj, [0, 25, 0]],
                    {
                        params ["_veh","_vel"];
						_veh engineOn true;
                        _veh disableBrakes true;
                        // _veh setVelocityModelSpace _vel;
                        _vms = velocityModelSpace _veh;
                        _forwardForce = _vms select 1;
                        _forwardForce = (_forwardForce + 0.2) min 5;
                        // systemchat str _forwardForce;
                        _vms set [1, _forwardForce];
                        [_veh,_vms] remoteExec ["setVelocityModelSpace",_veh];
                        // _veh setVelocityModelSpace _vms;
                    }
                ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];		
            };	

                                
            true //_block  //-- _block no longer needed as we exited
        }
    ];


    _a3c_rva2 =
    [
        "KeyUp",
        {
            params ["_display","_key","_shift","_ctrl","_alt"];
            //if (_key == 1) exitWith {};
            //_block = false;
            //a3c_remote_tank_obj engineOn true;

            [
                [a3c_remote_tank_obj,a3c_tank_speed],
                {
                    params ["_veh","_tankVelo"];
                    _veh sendSimpleCommand "STOPTURNING";
                    {
                        _x enableAI "MOVE";
                    } foreach [driver _veh, _veh];
                    _veh disableBrakes false;
                    // _vd = vectorDir ct;
                    // _vms = velocityModelSpace _veh;
                    // for "_t" from 0 to 70 do {
                        
                    // 	sleep 0.01;
                    // 	_veh setVectorDir _vd;
                    // 	_veh setVelocityModelSpace _vms;
                    // };
                    // systemchat 'up';
                    //_veh setVelocityModelSpace [0, 0, 0];
                }
            ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];


            // [
            // 	[a3c_remote_tank_obj,a3c_tank_speed],
            // 	{
            // 		params ["_veh","_tankVelo"];
            // 		_veh disableBrakes true;
            // 		_veh setVelocityModelSpace [0, _tankVelo, 0];
            // 		{
            // 			_x enableAI "MOVE";
            // 		} foreach [driver _veh, _veh];
            // 		//_veh setVelocityModelSpace [0, 0, 0];
            // 	}
            // ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];
            
            
            
            // if (_key in [200,208]) then {
            // 	[] spawn {

            // 		while {a3c_tank_speed > 0} do {
            // 			a3c_tank_speed = a3c_tank_speed - 0.1;
            // 			[a3c_remote_tank_obj,[0, a3c_tank_speed, 0]] remoteExec ["setVelocityModelSpace",a3c_remote_tank_obj];
            // 			sleep 0.01;
            // 		};
            // 		while {a3c_tank_speed < 0} do {
            // 			a3c_tank_speed = a3c_tank_speed + 0.1;
            // 			[a3c_remote_tank_obj,[0, a3c_tank_speed, 0]] remoteExec ["setVelocityModelSpace",a3c_remote_tank_obj];
            // 			sleep 0.01;
            // 		};
            // 		[a3c_remote_tank_obj,[0, 0, 0]] remoteExec ["setVelocityModelSpace",a3c_remote_tank_obj];
            // 		a3c_tank_speed = 0;
            // 		[a3c_remote_tank_obj,false] remoteExec ["disableBrakes",a3c_remote_tank_obj];


            // 	};
                
            // };
            
            false
            //_block
        }
    ];

    //a3c_tank_remote_MD = _disp displayAddEventHandler
    _a3c_rva3 =
    [
        "MouseButtonDown",
        {
            params ["_disp","_button","_sX","_sY","_shift","_ctrl","_alt"];
            //systemchat str _this;
            if (_button == 1 && {_ctrl} ) then {
                
                

                [
                    [a3c_remote_tank_obj],
                    {
                        params ["_veh"];
                        {
                            _x enableAI "MOVE";
                        } foreach [driver _veh, _veh];
                        _veh setVelocityModelSpace [0, 0, 0]; //??
                        _veh disableBrakes false;
                    }
                ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];
                [_display] call A3C_GP_RC_RemoveHandlers;
                hint "";
            };
        }
    ];

    if (visibleMap) then {

        {(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
        a3c_tank_remote_down = _disp ctrlAddEventHandler _a3c_rva1;
        a3c_tank_remote_up = _disp ctrlAddEventHandler _a3c_rva2;
        a3c_tank_remote_MD = _disp ctrlAddEventHandler _a3c_rva3;

        // [] spawn {
        //     sleep 1;
        //     waitUntil {!(a3c_is_HC_remote) OR {!visibleMap}};
        //     if (a3c_is_HC_remote) then {
        //         (findDisplay 12 displayCtrl 51)  ctrlRemoveEventHandler ["KeyDown",a3c_tank_remote_down];
        //         (findDisplay 12 displayCtrl 51)  ctrlRemoveEventHandler ["KeyUp",a3c_tank_remote_up];
        //         (findDisplay 12 displayCtrl 51)  ctrlRemoveEventHandler ["MouseButtonDown",a3c_tank_remote_MD];
        //         // systemchat 'wat';
        //         [
        //             [a3c_remote_tank_obj],
        //             {
        //                 params ["_veh"];
        //                 {
        //                     _x enableAI "MOVE";
        //                 } foreach [driver _veh, _veh];
        //                 _veh setVelocityModelSpace [0, 0, 0]; //??
        //                 _veh disableBrakes false;
        //             }
        //         ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];
        //         hint "";
        //         //systemchat "REMOVED";
        //         a3c_is_HC_remote = false;
        //     };
        //     //systemchat "HMM";
            
            
        // };
    } else {
        a3c_tank_remote_down = _disp displayAddEventHandler _a3c_rva1;
        a3c_tank_remote_up = _disp displayAddEventHandler _a3c_rva2;
        a3c_tank_remote_MD = _disp displayAddEventHandler _a3c_rva3;
    };

};
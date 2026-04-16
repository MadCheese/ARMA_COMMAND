
A3C_GP_RC_RemoveHandlers = {
    params ["_display"]; //-- we could get the display from visiblemap but it's tidier this way... assumably
    if (!visiblemap) then {
        // systemchat '3d';
        A3C_DISABLE_RADIAL = false;
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
        A3C_DISABLE_RADIAL = true;
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

    /*
        WIP NOTE: #CLEANUP

        what we should do instead of adding these eventhandlers is creating a manager that is at the beginning of 
        the default binds (MAP AND HUD).

        condition for this particular area is a3c_is_HC_remote

        So we create a function: _this call A3C_UI_SHARED_HandlerFNC_vehicleRemote


    */


    _disp = if (_isRadial) then {findDisplay 46} else {findDisplay 12 displayCtrl 51};

    // _a3c_rva1 =
    // [
    //     "KeyDown",
    //     {
    //         params ["_display","_key","_shift","_ctrl","_alt"];

            // if (_key in [15]) exitWith {
            //     //-- TAB
            //     if (_alt) then {
            //         [_display] call A3C_GP_RC_RemoveHandlers;
            //     };
            //     true
            // };

            // if (!alive (driver a3c_remote_tank_obj)) exitWith {
            //     [_display] call A3C_GP_RC_RemoveHandlers;
            // };


            // _block = false;
            
            // _tankVelo = (velocityModelSpace a3c_remote_tank_obj) select 1;

            // hint "CONTROL THE VEHICLE WITH ARROW KEYS. CANCEL REMOTE WITH CTRL+RMB";


            // a3c_tank_speed_max = if (_shift) then {15} else {5};
            // _rotation = 1; 


            // _doExit = false;

            // {
            //     _action = inputaction _x;
            //     if (_action > 0) exitWith {
            //         _doExit = true;

            //         [_display] call A3C_GP_RC_RemoveHandlers;
                        

            //     };
            // } foreach ["ingamePause", "showMap"];

            // if (_doExit) exitWith {a3c_is_HC_remote = false;};

            
            // if !(_key in [200,203,205,208]) exitWith {};



            // private _moveVector = [0,0,0];

            // hint "CONTROL THE VEHICLE WITH ARROW KEYS. CANCEL REMOTE WITH CTRL+RMB";


            

            // switch (_key) do {
            //     case (203) : { //-- LEFT ARROW
			// 		if (_alt) then {
			// 			[a3c_remote_tank_obj,"LEFT"] remoteExec ["sendSimpleCommand",a3c_remote_tank_obj];
			// 		} else {
			// 			[[a3c_remote_tank_obj, -.5],A3C_AI_FNC_remoteSteer] remoteExec ["bis_fnc_call", a3c_remote_tank_obj];
			// 		};
                    
                    
            
            //     }; 
            //     case (205) : { // -- RIGHT ARROW
			// 		if (_alt) then {
			// 			[a3c_remote_tank_obj,"RIGHT"] remoteExec ["sendSimpleCommand",a3c_remote_tank_obj];
			// 		} else {
			// 			[[a3c_remote_tank_obj, .5],A3C_AI_FNC_remoteSteer] remoteExec ["bis_fnc_call", a3c_remote_tank_obj];						
			// 		};  
            //     }; 

            // };

            // if (_key == 208) then { //-- DOWN ARROW
                
            //     [
            //         [a3c_remote_tank_obj, [0, -5, 0]],
            //         {
            //             params ["_veh","_vel"];
			// 			_veh engineOn true;
            //             _veh disableBrakes true;
            //             // _veh setVelocityModelSpace _vel;
            //             _vms = velocityModelSpace _veh;
            //             _forwardForce = _vms select 1;
            //             _forwardForce = (_forwardForce - 0.2) max -5;
            //             // systemchat str _forwardForce;
            //             _vms set [1, _forwardForce];
            //             [_veh,_vms] remoteExec ["setVelocityModelSpace",_veh];
            //             // _veh setVelocityModelSpace _vms;
            //         }
            //     ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];	
                

            // };

            // if (_key == 200) then { //-- UP ARROW

            //     //-- METHOD 3: Works with turning
            //     [
            //         [a3c_remote_tank_obj, [0, 25, 0]],
            //         {
            //             params ["_veh","_vel"];
			// 			_veh engineOn true;
            //             _veh disableBrakes true;
            //             // _veh setVelocityModelSpace _vel;
            //             _vms = velocityModelSpace _veh;
            //             _forwardForce = _vms select 1;
            //             _forwardForce = (_forwardForce + 0.2) min 5;
            //             // systemchat str _forwardForce;
            //             _vms set [1, _forwardForce];
            //             [_veh,_vms] remoteExec ["setVelocityModelSpace",_veh];
            //             // _veh setVelocityModelSpace _vms;
            //         }
            //     ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];		
            // };	

                                
    //         true //_block  //-- _block no longer needed as we exited
    //     }
    // ];


    _a3c_rva2 =
    [
        "KeyUp",
        {
            params ["_display","_key","_shift","_ctrl","_alt"];

            [
                [a3c_remote_tank_obj,a3c_tank_speed],
                {
                    params ["_veh","_tankVelo"];
                    _veh sendSimpleCommand "STOPTURNING";
                    {
                        _x enableAI "MOVE";
                    } foreach [driver _veh, _veh];
                    _veh disableBrakes false;
                }
            ] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];
            
            false
  
        }
    ];

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
    } else {
        a3c_tank_remote_down = _disp displayAddEventHandler _a3c_rva1;
        a3c_tank_remote_up = _disp displayAddEventHandler _a3c_rva2;
        a3c_tank_remote_MD = _disp displayAddEventHandler _a3c_rva3;
    };

};
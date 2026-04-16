A3C_UI_Shared_FNC_AddDownkey = {
	//-- purpose: exclude ALT from downkey collection in order to prevent lingering in A3C_UI_DOWNKEYS
	params ["_key"];
	if (_key != 56) then {
		A3C_UI_DOWNKEYS set [count A3C_UI_DOWNKEYS, _key];
	};
};



A3C_UI_Shared_FNC_EventDispatcher_KeyDown = {
	params ["_display", "_key", "_shift", "_ctrl", "_alt"];
	private _didResolve = false;
	private _blockDefault = false;

	//-- #TODO: Decide if switch or if >> exitWith blocks?
	switch (true) do {
		case 
		(
			a3c_is_HC_remote
			&& {_key in 200,203,205,208}
		) : {
			//-- vehicle remote: prepare action:
			private _remoteDriver = driver a3c_remote_tank_obj;
			if (alive _remoteDriver && {!(isPLayer _remoteDriver)}) then {

				_didResolve = true;
				_blockDefault = true;

				private _rotation = 1;
				private _moveVector = [0,0,0];
				private _tankVelo = (velocityModelSpace a3c_remote_tank_obj) select 1;

				hint "CONTROL THE VEHICLE WITH ARROW KEYS. CANCEL REMOTE WITH CTRL+RMB";

				a3c_tank_speed_max = if (_shift) then {15} else {5};

				

				//-- steering
				switch (_key) do {
					case (203) : { //-- LEFT ARROW
						if (_alt) then {
							[a3c_remote_tank_obj,"LEFT"] remoteExec ["sendSimpleCommand",a3c_remote_tank_obj];
						} else {
							[[a3c_remote_tank_obj, -.5],A3C_AI_FNC_remoteSteer] remoteExec ["bis_fnc_call", a3c_remote_tank_obj];
						};
					}; 
					case (205) : { // -- RIGHT ARROW
						if (_alt) then {
							[a3c_remote_tank_obj,"RIGHT"] remoteExec ["sendSimpleCommand",a3c_remote_tank_obj];
						} else {
							[[a3c_remote_tank_obj, .5],A3C_AI_FNC_remoteSteer] remoteExec ["bis_fnc_call", a3c_remote_tank_obj];						
						};  
					};
					case (208) : { //-- DOWN ARROW
						[
							[a3c_remote_tank_obj],
							{
								params ["_veh"];
								private _veh engineOn true;
								_veh disableBrakes true;
								private _vms = velocityModelSpace _veh;
								private _forwardForce = _vms select 1;
								_forwardForce = (_forwardForce - 0.2) max -5;
								_vms set [1, _forwardForce];
								[_veh,_vms] remoteExec ["setVelocityModelSpace",_veh];
							}
						] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];	
					};
					case (200) : { //-- UP ARROW
						[
							[a3c_remote_tank_obj],
							{
								params ["_veh"];
								_veh engineOn true;
								_veh disableBrakes true;
								private _vms = velocityModelSpace _veh;
								private _forwardForce = _vms select 1;
								_forwardForce = (_forwardForce + 0.2) min 5;
								_vms set [1, _forwardForce];
								[_veh,_vms] remoteExec ["setVelocityModelSpace", _veh];

							}
						] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];	
					}; 
				};
            };	
		};
		// case () : {};
		default {};
	};

	[_didResolve, _blockDefault]
};


A3C_UI_Shared_FNC_EventDispatcher_KeyUp = {
	params ["_display", "_key", "_shift", "_ctrl", "_alt"];
	private _didResolve = false;
	private _blockDefault = false;

	[_didResolve, _blockDefault]
};

A3C_UI_Shared_FNC_EventDispatcher_mouseButtonDown = {
	params ["_display","_button","_sX","_sY","_shift","_ctrl", "_alt"];
	private _didResolve = false;
	private _blockDefault = false;

	[_didResolve, _blockDefault]
};

A3C_UI_Shared_FNC_EventDispatcher_mouseButtonDown = {
	params ["_display","_button","_sX","_sY","_shift","_ctrl", "_alt"];
	private _didResolve = false;
	private _blockDefault = false;

	[_didResolve, _blockDefault]
};

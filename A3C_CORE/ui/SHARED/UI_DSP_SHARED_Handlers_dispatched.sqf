/*//---------------------------------  HANDLER-DISPATCHERS [SHARED]  ----------------------------------

These functions are shared by dispatchers for MAP and HUD

*///------------------------------------------------------------------------------------------------


//--------------------------------- KeyDown Dispatchers:

A3C_UI_SHARED_onKeyDown_remoteVehicle = {
	params ["_display", "_key", "_shift", "_ctrl", "_alt"];

	//-- vehicle remote: prepare action:
	private _remoteDriver = driver a3c_remote_tank_obj;

	
	if (alive _remoteDriver && {(!isPLayer _remoteDriver)}) then {

		_blockDefault = true;

		private _rotation = 1;
		private _moveVector = [0,0,0];
		private _tankVelo = (velocityModelSpace a3c_remote_tank_obj) select 1;

		hint "CONTROL THE VEHICLE WITH ARROW KEYS. CANCEL REMOTE WITH CTRL+RMB";

		a3c_tank_speed_max = if (_shift) then {15} else {5};	

		//-- steering
		switch (true) do {
			case (_key == 203) : { //-- LEFT ARROW
				if (_alt) then {
					[a3c_remote_tank_obj,"LEFT"] remoteExec ["sendSimpleCommand",a3c_remote_tank_obj];
				} else {
					[[a3c_remote_tank_obj, -.5],A3C_AI_FNC_remoteSteer] remoteExec ["bis_fnc_call", a3c_remote_tank_obj];
				};
			}; 
			case (_key == 205) : { // -- RIGHT ARROW
				if (_alt) then {
					[a3c_remote_tank_obj,"RIGHT"] remoteExec ["sendSimpleCommand",a3c_remote_tank_obj];
				} else {
					[[a3c_remote_tank_obj, .5],A3C_AI_FNC_remoteSteer] remoteExec ["bis_fnc_call", a3c_remote_tank_obj];						
				};  
			};
			case (_key == 208) : { //-- DOWN ARROW

				[
					[a3c_remote_tank_obj],
					{
						params ["_veh"];
						_veh engineOn true;
						_veh disableBrakes true;
						private _vms = velocityModelSpace _veh;
						private _forwardForce = _vms select 1;
						_forwardForce = (_forwardForce - 0.2) max -5;
						_vms set [1, _forwardForce];
						[_veh,_vms] remoteExec ["setVelocityModelSpace",_veh];
					}
				] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];	
			};
			case (_key == 200) : { //-- UP ARROW
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



//--------------------------------- KeyUp Dispatchers:

A3C_UI_SHARED_onKeyUp_remoteVehicle = {
	params ["_display", "_key", "_shift", "_ctrl", "_alt"];
	[
		[a3c_remote_tank_obj, a3c_tank_speed],
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
};

A3C_UI_SHARED_OnMouseButtonDown_remoteVehicle = {
	params ["_display","_button","_sX","_sY","_shift","_ctrl", "_alt"];
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
	a3c_remote_tank_obj = objNull;
	a3c_is_HC_remote = false;
	a3c_tank_speed = 0;
	hint "";

};
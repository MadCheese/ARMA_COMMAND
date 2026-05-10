hint "CONTROL THE VEHICLE WITH ARROW KEYS. CANCEL REMOTE WITH CTRL+RMB";

a3c_is_HC_remote = true;
a3c_remote_tank_obj = vehicle (leader (A3C_SELECTED_HC_GROUPS_SETTINGS select 0));

[
	[a3c_remote_tank_obj],
	{
		params ["_veh"];
		_veh action ["engineOn", _veh];
		_veh engineOn true;
	}
] remoteExec ["bis_fnc_call",a3c_remote_tank_obj];

a3c_tank_speed = 0;
a3c_tank_speed_max = 5;

params ["_mode"]; //-- 0: On | 1: Off

{
	private _group = _x;
	private _groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;
	{
		[_x, _mode] call A3C_ai_shared_fnc_actionSwitchVehicleLights;
	} foreach _groupVehicles;
} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;


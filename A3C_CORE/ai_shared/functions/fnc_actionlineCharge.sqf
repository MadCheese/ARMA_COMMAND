// A3C_ai_shared_fnc_actionLineCharge

params ["_group"];

private _groupVehicles = ([_group] call A3C_main_fnc_getGroupVehicles) select {
	private _vehicleType = typeOf _x;
	_vehicleType in ["B_APC_Tracked_01_CRV_F_Fixed", "B_T_APC_Tracked_01_CRV_F_Fixed"]
	&& {(_x getVariable ['MCSS_MCLC_MAGCOUNT', 4]) > 0}
	&& {!(_x getVariable['MCSS_MCLC_RELOADING', false])}
};

private _fnc_MCLC = {
	params ["_vehicle"];
	[_vehicle] execVM '\Bobcat_Fixed\scripts\LineCharge.sqf';
};

{
	[_x, _fnc_MCLC] remoteExec ['bis_fnc_spawn', _x];
} foreach _groupVehicles;

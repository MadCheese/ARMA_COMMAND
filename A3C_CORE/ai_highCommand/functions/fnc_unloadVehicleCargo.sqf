// A3C_ai_highCommand_fnc_unloadVehicleCargo

private _selectedGroups = +A3C_SELECTED_HC_GROUPS_SETTINGS;

{
	private _group = _x;
	private _groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles select {
		private _vehicleCargo = getVehicleCargo _x;
		_vehicleCargo isNotEqualTo []
		&& {(getPosATL _x) select 2 < 1}
	};
	{
		[_x, objNull] remoteExec ["setVehicleCargo", leader _group];
	} foreach _groupVehicles;
} foreach _selectedGroups;
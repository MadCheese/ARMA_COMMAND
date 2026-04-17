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
};
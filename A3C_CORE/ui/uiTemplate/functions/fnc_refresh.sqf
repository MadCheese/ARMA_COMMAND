private _primary = ["primary"] call A3C_UI_templateDialog_fnc_ctrl;
private _secondary = ["secondary"] call A3C_UI_templateDialog_fnc_ctrl;

if !(isNull _primary) then {
    _primary ctrlSetText "BTN";
};

if !(isNull _secondary) then {
    _secondary ctrlSetText "BTN";
};
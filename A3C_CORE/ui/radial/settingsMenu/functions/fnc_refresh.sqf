private _skill = ["skill"] call A3C_settingsMenu_fnc_ctrl;
private _num = ["num"] call A3C_settingsMenu_fnc_ctrl;
private _hudReset = ["hudReset"] call A3C_settingsMenu_fnc_ctrl;
private _aiRail = ["aiRail"] call A3C_settingsMenu_fnc_ctrl;
private _hudLayout = ["hudLayout"] call A3C_settingsMenu_fnc_ctrl;
private _hudObjects = ["hudObjects"] call A3C_settingsMenu_fnc_ctrl;
private _hcResponse = ["hcResponse"] call A3C_settingsMenu_fnc_ctrl;

if !(isNull _skill) then {
    _skill ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_SKILL_VAR", false]));
};

if !(isNull _num) then {
    _num ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_NUM_VAR", false]));
};

if !(isNull _hudReset) then {
    _hudReset ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_HUD_RES_VAR", false]));
};

if !(isNull _aiRail) then {
    _aiRail ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_FORCERAIL_VAR", false]));
};

if !(isNull _hudLayout) then {
    _hudLayout ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_HUD_LAYOUT_CORNER", false]));
};

if !(isNull _hudObjects) then {
    _hudObjects ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_HUD_OBJECTS", false]));
};

if !(isNull _hcResponse) then {
    _hcResponse ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["HC_GROUP_RESPONSE", false]));
};
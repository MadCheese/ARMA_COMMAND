#include "..\dialog_defines.hpp"

params ["_control"];

private _idc = ctrlIDC _control;
private _var = "";

switch (_idc) do {
    case IDC_SETTINGS_MENU_BTN_SKILL: { _var = "A3C_SKILL_VAR"; };
    case IDC_SETTINGS_MENU_BTN_NUM: { _var = "A3C_NUM_VAR"; };
    case IDC_SETTINGS_MENU_BTN_HUD_RESET: { _var = "A3C_HUD_RES_VAR"; };
    case IDC_SETTINGS_MENU_BTN_AI_RAIL: { _var = "A3C_FORCERAIL_VAR"; };
    case IDC_SETTINGS_MENU_BTN_HUD_LAYOUT: { _var = "A3C_HUD_LAYOUT_CORNER"; };
    case IDC_SETTINGS_MENU_BTN_HUD_OBJECTS: { _var = "A3C_HUD_OBJECTS"; };
    case IDC_SETTINGS_MENU_BTN_HC_RESPONSE: { _var = "HC_GROUP_RESPONSE"; };
};

if (_var isEqualTo "") exitWith {};

private _newValue = !(profileNamespace getVariable [_var, false]);
profileNamespace setVariable [_var, _newValue];


switch (_var) do {
    case "A3C_SKILL_VAR": {
        if (_newValue) then {
            {
                _x setSkill 1;
            } forEach units group player;

            if (isServer) then {
                A3C_isHCSkillMaxed = true;
                publicVariable "A3C_isHCSkillMaxed";
            };
        } else {
            if (isServer) then {
                A3C_isHCSkillMaxed = false;
                publicVariable "A3C_isHCSkillMaxed";
            };
        };
    };

    case "A3C_NUM_VAR": {
    };

    case "A3C_HUD_RES_VAR": {
    };

    case "A3C_HUD_OBJECTS": {
    };
};

[] call A3C_settingsMenu_fnc_refresh;
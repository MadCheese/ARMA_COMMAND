#include "..\..\dialog_defines.hpp"

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

[_var] call A3C_UI_settingsMenu_fnc_changeSettings;
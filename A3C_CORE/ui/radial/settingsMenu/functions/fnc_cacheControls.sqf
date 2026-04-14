#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _controls = createHashMapFromArray [
    ["skill", _display displayCtrl IDC_SETTINGS_MENU_BTN_SKILL],
    ["num", _display displayCtrl IDC_SETTINGS_MENU_BTN_NUM],
    ["hudReset", _display displayCtrl IDC_SETTINGS_MENU_BTN_HUD_RESET],
    ["aiRail", _display displayCtrl IDC_SETTINGS_MENU_BTN_AI_RAIL],
    ["hudLayout", _display displayCtrl IDC_SETTINGS_MENU_BTN_HUD_LAYOUT],
    ["hudObjects", _display displayCtrl IDC_SETTINGS_MENU_BTN_HUD_OBJECTS],
    ["hcResponse", _display displayCtrl IDC_SETTINGS_MENU_BTN_HC_RESPONSE]
];

uiNamespace setVariable [QGVAR(controls), _controls];
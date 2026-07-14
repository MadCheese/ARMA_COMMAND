#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

// A3C_UI_customFormation_fnc_manageOnLoad

disableSerialization;

params [
    ["_display", displayNull, [displayNull]]
];

if (isNull _display) exitWith {};

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageDisplay",
    _display
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageDynamicControls",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageCheckBoxes",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageConfirmingDelete",
    false
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageUpdating",
    false
];

private _selectAll = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_SELECT_ALL;

if !(isNull _selectAll) then {
    _selectAll setVariable [
        "A3C_IsSelectAll",
        true
    ];
};

[] call FUNC(populateSavedFormationManager);
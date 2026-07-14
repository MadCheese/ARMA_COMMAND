#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_manageOnUnload

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageDisplay",
    displayNull
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

/*
    Rebuild the filtered loading list in case saved data changed.
*/
private _mainDisplay = uiNamespace getVariable [
    QGVAR(display),
    displayNull
];

if !(isNull _mainDisplay) then {
    [] call FUNC(labelListbox);
};
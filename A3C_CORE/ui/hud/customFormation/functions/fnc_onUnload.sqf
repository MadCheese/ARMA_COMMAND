#include "..\script_component.hpp"

private _saveEdit = uiNamespace getVariable [
    "A3C_C_FORM_SaveBox",
    controlNull
];

if !(isNull _saveEdit) then {
    ctrlDelete _saveEdit;
};

uiNamespace setVariable [
    "A3C_C_FORM_SaveBox",
    controlNull
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Display",
    displayNull
];

uiNamespace setVariable [
    QGVAR(display),
    displayNull
];

uiNamespace setVariable [
    QGVAR(groups),
    nil
];

uiNamespace setVariable [
    QGVAR(controls),
    nil
];

A3C_UI_CustomFormation_SaveOverlayIsOpen = false;
A3C_UI_CustomFormation_BOOL_DRAW = false;
A3C_UI_CustomFormation_BOOL_isMouseUp = false;
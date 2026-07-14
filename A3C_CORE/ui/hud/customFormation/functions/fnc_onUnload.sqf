#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_onUnload
//
// The display owns the dynamically created save-name edit control. The
// engine destroys that control as part of display teardown, so it must not
// be explicitly deleted inside this display's onUnload event handler.

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

uiNamespace setVariable [
    "A3C_UI_CustomFormation_RelativePoints",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Poses",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots",
    []
];

A3C_UI_CustomFormation_SaveOverlayIsOpen = false;
A3C_UI_CustomFormation_BOOL_DRAW = false;
A3C_UI_CustomFormation_BOOL_isMouseUp = false;
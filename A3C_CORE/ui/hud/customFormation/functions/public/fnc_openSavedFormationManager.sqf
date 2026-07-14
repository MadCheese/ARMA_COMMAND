#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_openSavedFormationManager

disableSerialization;

private _parentDisplay = uiNamespace getVariable [
    QGVAR(display),
    displayNull
];

if (isNull _parentDisplay) exitWith {};

private _existingDisplay =
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_ManageDisplay",
        displayNull
    ];

if !(isNull _existingDisplay) exitWith {};

/*
    Close the save-name overlay before opening the modal manager.
*/
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

A3C_UI_CustomFormation_SaveOverlayIsOpen = false;

private _manageDisplay =
    _parentDisplay createDisplay
        "HUD_Formation_Manage";

if (isNull _manageDisplay) exitWith {};
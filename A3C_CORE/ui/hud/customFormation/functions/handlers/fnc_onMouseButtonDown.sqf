#include "..\..\script_component.hpp"

params ["_control", "_button", "_posX", "_posY"];

if (_button isEqualTo 1) exitWith {};

private _gridUnit = missionNamespace getVariable [
    "A3C_UI_CustomFormation_GridUnit",
    0
];

if (_gridUnit <= 0) exitWith {};
if (_posX > (0.5 + (6 * _gridUnit))) exitWith {};

private _selectedUnits = uiNamespace getVariable [
    "A3C_UI_CustomFormation_selectedUnits",
    []
];

if (_selectedUnits isEqualTo []) exitWith {};

A3C_UI_CustomFormation_BOOL_DRAW = true;
A3C_UI_CustomFormation_BOOL_isMouseUp = true;

uiNamespace setVariable [
    "A3C_UI_CustomFormation_lineLength",
    0
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Poses",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_saveLB",
    0
];

// Must execute in missionNamespace.
[] call FUNC(labelListbox);

private _lineColor = uiNamespace getVariable [
    "A3C_C_FORM_LineColor",
    ""
];

private _dotCollectionName = switch (_lineColor) do {
    case "#(argb,8,8,3)color(1,0,0,1)": {
        "A3C_UI_CustomFormation_Dots_RED"
    };

    case "#(argb,8,8,3)color(0,1,0,1)": {
        "A3C_UI_CustomFormation_Dots_GREEN"
    };

    case "#(argb,8,8,3)color(0,0,1,1)": {
        "A3C_UI_CustomFormation_Dots_BLUE"
    };

    case "#(argb,8,8,3)color(1,1,0,1)": {
        "A3C_UI_CustomFormation_Dots_YELLOW"
    };

    case "#(argb,8,8,3)color(1,1,1,1)": {
        "A3C_UI_CustomFormation_Dots_MAIN"
    };

    case "#(argb,8,8,3)color(0.53,0.29,0.69,1)": {
        "A3C_UI_CustomFormation_Dots_ALL"
    };

    default {
        ""
    };
};

if (_dotCollectionName isEqualTo "") exitWith {};

private _dots = uiNamespace getVariable [
    _dotCollectionName,
    []
];

{
    ctrlDelete _x;
} forEach _dots;

uiNamespace setVariable [
    _dotCollectionName,
    []
];
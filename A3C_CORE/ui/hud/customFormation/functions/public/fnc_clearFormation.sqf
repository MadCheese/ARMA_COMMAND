#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_clearFormation

private _dotCollectionNames = [
    "A3C_UI_CustomFormation_Dots_RED",
    "A3C_UI_CustomFormation_Dots_GREEN",
    "A3C_UI_CustomFormation_Dots_BLUE",
    "A3C_UI_CustomFormation_Dots_YELLOW",
    "A3C_UI_CustomFormation_Dots_MAIN",
    "A3C_UI_CustomFormation_Dots_ALL"
];

{
    private _dots = uiNamespace getVariable [_x, []];

    {
        ctrlDelete _x;
    } forEach _dots;

    uiNamespace setVariable [_x, []];
} forEach _dotCollectionNames;

uiNamespace setVariable [
    "A3C_UI_CustomFormation_saveLB",
    0
];

[] call FUNC(labelListbox);

A3C_UI_CustomFormation_BOOL_formationActive = false;

private _activationImage = ["activationImage"] call FUNC(ctrl);
private _activationButton = ["activationButton"] call FUNC(ctrl);

if !(isNull _activationImage) then {
    _activationImage ctrlSetTextColor [1, 0, 0, 1];
};

if !(isNull _activationButton) then {
    _activationButton ctrlSetText "ACTIVATE FORMATION";
};

{
    _x setVariable ["A3C_FORM", [], false];
    _x setVariable ["A3C_FORM_MEMBER", false, false];
} forEach (units player - [player]);
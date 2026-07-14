#include "..\..\script_component.hpp"

params ["_control", "_selectedIndex"];

if (A3C_CurSel) exitWith {};

if (_selectedIndex isEqualTo 0) exitWith {
    uiNamespace setVariable [
        "A3C_UI_CustomFormation_saveLB",
        0
    ];
};

with uiNamespace do {
    private _savedFormations =
        profileNamespace getVariable "A3C_C_FORMATIONS_SAVED";

    private _formationData =
        (_savedFormations select (_selectedIndex - 1)) select 1;

    private _units = units player - [player];

    {
        if (_forEachIndex < count _formationData) then {
            _x setVariable [
                "A3C_FORM",
                _formationData select _forEachIndex,
                false
            ];
        };
    } forEach _units;

    A3C_UI_CustomFormation_saveLB = _selectedIndex;
};

A3C_UI_CustomFormation_BOOL_ALLOW = true;

[] spawn {
    sleep 2;
    A3C_UI_CustomFormation_BOOL_ALLOW = false;
};
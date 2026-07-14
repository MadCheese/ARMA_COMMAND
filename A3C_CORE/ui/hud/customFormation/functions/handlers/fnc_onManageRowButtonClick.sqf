#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_onManageRowButtonClick

params [
    ["_control", controlNull, [controlNull]]
];

if (isNull _control) exitWith {};

private _checkBox =
    _control getVariable [
        "A3C_CheckBox",
        controlNull
    ];

if (isNull _checkBox) exitWith {};

/*
    Make the formation-name area behave like the corresponding checkbox.
*/
_checkBox cbSetChecked !(
    cbChecked _checkBox
);
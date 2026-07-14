#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_isValidFormationData
//
// Returns true only for:
//     [distance, relativeDirection]

params [
    ["_formationData", []]
];

if !(_formationData isEqualType []) exitWith {
    false
};

if ((count _formationData) isNotEqualTo 2) exitWith {
    false
};

private _formationDistance =
    _formationData select 0;

private _relativeDirection =
    _formationData select 1;

(_formationDistance isEqualType 0)
&& {
    _relativeDirection isEqualType 0
}
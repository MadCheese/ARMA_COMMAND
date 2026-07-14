#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_getGridPositionFromRelativeData
//
// Inverse of getRelativeData.
//
// Converts:
//     [relativeDistance, relativeDirection]
//
// Into:
//     [gridX, gridY]

params [
    ["_relativeData", [], [[]]]
];

if !(
    [_relativeData] call FUNC(isValidFormationData)
) exitWith {
    []
};

private _gridUnit = missionNamespace getVariable [
    "A3C_UI_CustomFormation_GridUnit",
    0
];

if (_gridUnit <= 0) exitWith {
    []
};

_relativeData params [
    "_relativeDistance",
    "_relativeDirection"
];

private _screenDistance =
    (_relativeDistance / 5)
    * _gridUnit;

[
    0.5
    + (
        (sin _relativeDirection)
        * _screenDistance
    ),

    0.5
    - (
        (cos _relativeDirection)
        * _screenDistance
    )
]
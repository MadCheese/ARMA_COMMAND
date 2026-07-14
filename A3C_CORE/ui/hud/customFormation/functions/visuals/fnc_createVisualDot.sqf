#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_createVisualDot
//
// Creates one display-local formation visualization dot.
//
// Returns:
//     Created control, or controlNull.

disableSerialization;

params [
    ["_display", displayNull, [displayNull]],
    ["_gridPosition", [], [[]]],
    ["_color", "", [""]]
];

if (isNull _display) exitWith {
    controlNull
};

if ((count _gridPosition) < 2) exitWith {
    controlNull
};

if (_color isEqualTo "") exitWith {
    controlNull
};

private _dot = _display ctrlCreate [
    "RscPicture",
    -1
];

if (isNull _dot) exitWith {
    controlNull
};

_dot ctrlSetText _color;

_dot ctrlSetPosition [
    _gridPosition select 0,
    _gridPosition select 1,
    0.005 * (safeZoneH / safeZoneW),
    0.005 * safeZoneH
];

_dot ctrlCommit 0;

_dot
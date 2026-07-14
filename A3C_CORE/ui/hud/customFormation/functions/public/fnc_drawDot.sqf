#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_drawDot

params ["_gridX", "_gridY"];

private _display = uiNamespace getVariable [
    QGVAR(display),
    displayNull
];

if (isNull _display) exitWith {};

private _relativeData = [
    _gridX,
    _gridY
] call FUNC(getRelativeData);

_relativeData params [
    "_relativeDistance",
    "_relativeDirection"
];

private _dots = uiNamespace getVariable [
    "A3C_UI_CustomFormation_Dots",
    []
];

private _poses = uiNamespace getVariable [
    "A3C_UI_CustomFormation_Poses",
    []
];

// The drawn dots are managed through their control handles;
// no addressable IDC is required.
private _dot = _display ctrlCreate [
    "RscPicture",
    -1
];

if (isNull _dot) exitWith {};

_dots pushBack _dot;

private _relativePosition = player getRelPos [
    _relativeDistance,
    _relativeDirection
];

_relativePosition set [2, 0];

if (_poses isEqualTo []) then {
    _poses = [_relativePosition];
} else {
    _poses pushBack _relativePosition;
};

private _lineColor = uiNamespace getVariable [
    "A3C_C_FORM_LineColor",
    "#(argb,8,8,3)color(0.53,0.29,0.69,1)"
];

_dot ctrlSetText _lineColor;

_dot ctrlSetPosition [
    _gridX,
    _gridY,
    0.005 * (safeZoneH / safeZoneW),
    0.005 * safeZoneH
];

_dot ctrlCommit 0;

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots",
    _dots
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Poses",
    _poses
];
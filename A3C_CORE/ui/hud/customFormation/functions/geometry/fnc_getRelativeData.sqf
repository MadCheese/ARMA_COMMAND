#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_getRelativeData

params ["_posX", "_posY"];

private _gridUnit = missionNamespace getVariable [
    "A3C_UI_CustomFormation_GridUnit",
    0
];

if (_gridUnit <= 0) exitWith {
    [0, 0]
};

private _cursorPosition = [_posX, _posY];
private _centerPosition = [0.5, 0.5];

private _distance =
    (_cursorPosition distance _centerPosition)
    / _gridUnit
    * 5;

private _direction =
    360 - (_cursorPosition getDir _centerPosition);

[_distance, _direction]
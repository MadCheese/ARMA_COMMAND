#include "..\..\script_component.hpp"

params ["_control", "_posX", "_posY"];

if (A3C_UI_CustomFormation_BOOL_DRAW) then {
    [_posX, _posY] call A3C_ui_customFormation_fnc_drawDot;
};
#include "..\..\script_component.hpp"

params ["_control", "_button", "_mouseX", "_mouseY"];

if (A3C_SUP_BOOL_MD) exitWith {
    false
};

if (_button == 1) exitWith {
    [] call FUNC(closeDisplay);
    false
};

A3C_SUP_BOOL_MD = true;
A3C_SUP_CLICKPOS = [_mouseX, _mouseY];

false
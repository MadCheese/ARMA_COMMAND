#include "..\..\script_component.hpp"

params ["_control", "_mouseX", "_mouseY"];

A3C_SUP_MOUSEPOS = [_mouseX, _mouseY];

if !(A3C_SUP_BOOL_MD) exitWith {
    false
};

private _drawBox = ["drawBox"] call FUNC(ctrl);

if (isNull _drawBox) exitWith {
    false
};

private _clickX = A3C_SUP_CLICKPOS select 0;
private _clickY = A3C_SUP_CLICKPOS select 1;
private _w = _mouseX - _clickX;
private _h = _mouseY - _clickY;

_drawBox ctrlSetPosition [_clickX, _clickY, _w, _h];
_drawBox ctrlCommit 0;

false
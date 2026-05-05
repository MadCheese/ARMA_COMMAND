#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

disableSerialization;

private _drawBox = ["drawBox"] call FUNC(ctrl);

if (isNull _drawBox) then {
    private _display = uiNamespace getVariable [QGVAR(display), displayNull];

    if (isNull _display) then {
        _display = findDisplay IDD_SUPPRESSION_AREA_DRAW;
    };

    if !(isNull _display) then {
        _drawBox = _display displayCtrl IDC_SUPPRESSION_AREA_DRAW_BOX;
    };
};

if (isNull _drawBox) exitWith {};

private _ctrlPos = ctrlPosition _drawBox;
private _x = _ctrlPos select 0;
private _y = _ctrlPos select 1;
private _w = _ctrlPos select 2;
private _h = _ctrlPos select 3;

// Form rectangle corner points in screen coordinates.
private _screenP1 = [_x, _y];                 // Top left.
private _screenP2 = [_x + _w, _y];            // Top right.
private _screenP4 = [_x, _y + _h];            // Bottom left.
private _screenP3 = [_x + _w, _y + _h];       // Bottom right.
private _center = [_x + (_w / 2), _y + (_h / 2)];

// Convert screen positions to world positions.
private _p1 = screenToWorld _screenP1;
private _p2 = screenToWorld _screenP2;
private _p3 = screenToWorld _screenP3;
private _p4 = screenToWorld _screenP4;
_center = screenToWorld _center;

// If the rectangle was started in the sky, clamp points to view distance.
private _clampToViewDistance = {
    params ["_pos"];

    if ((_pos distance2D player) > viewDistance) then {
        private _dir = [player, _pos] call BIS_fnc_dirTo;
        _pos = [player, viewDistance, _dir] call BIS_fnc_relPos;
    };

    _pos
};

_p1 = [_p1] call _clampToViewDistance;
_p2 = [_p2] call _clampToViewDistance;
_p3 = [_p3] call _clampToViewDistance;
_p4 = [_p4] call _clampToViewDistance;
_center = [_center] call _clampToViewDistance;

// Create 3D polygon and add data to polygon array.
A3C_SUP_MAIN_POLY = [[_center, ""], [_p1, _p2, _p3, _p4]];

private _dirTo = [vehicle player, _center] call BIS_fnc_dirTo;

A3C_SUP_MAIN_POLY = [[_center, ""]] + (
    [
        A3C_SUP_MAIN_POLY select 1,
        _dirTo,
        "SUPPRESSION",
        true,
        A3C_SUPPRESSION_UNITS_SQ_TEMP
    ] call A3C_SUP_CREATE_POLY
);

// Blink effect to visualize the accepted order.
for "_i" from 1 to 2 do {
    _drawBox ctrlShow false;
    sleep 0.05;
    _drawBox ctrlShow true;
    sleep 0.05;
};

// Close display.
[] call FUNC(closeDisplay);

// Spawn suppression.
{
    _x setVariable ["A3C_UNIT_POLYS", [A3C_SUP_MAIN_POLY], true];
} forEach A3C_SUPPRESSION_UNITS_SQ_TEMP;

[
    A3C_SUPPRESSION_UNITS_SQ_TEMP,
    A3C_SUP_MAIN_POLY,
    "SUPPRESSION",
    true
] spawn A3C_POLY_ACTION_ON;
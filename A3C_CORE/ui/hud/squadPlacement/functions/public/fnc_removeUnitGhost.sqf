#include "..\..\script_component.hpp"

params ["_unit"];

if !(_unit in A3C_UI_squadPlacement_units) exitWith {};

if ((count A3C_UI_squadPlacement_units) > 1) then {
    if (_unit == (A3C_UI_squadPlacement_units select 0)) then {
        private _nextUnit = A3C_UI_squadPlacement_units select 1;
        private _nextHudData = _nextUnit getVariable ["A3C_HUD_DATA", []];

        if ((count _nextHudData) > 0) then {
            private _nextIndicator = _nextHudData select 0;

            if !(isNull _nextIndicator) then {
                _nextIndicator setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,1,0,0.1)"];
            };
        };
    };
};

private _hudData = _unit getVariable ["A3C_HUD_DATA", []];

if ((count _hudData) > 0) then {
    private _indicator = _hudData select 0;

    if !(isNull _indicator) then {
        deleteVehicle _indicator;
        A3C_UI_squadPlacement_unitGhosts = A3C_UI_squadPlacement_unitGhosts - [_indicator];
    };
};

A3C_UI_squadPlacement_units = A3C_UI_squadPlacement_units - [_unit];
_unit setVariable ["A3C_HUD_DATA", [], true];

if ((count A3C_UI_squadPlacement_units) == 1) then {
    private _lastUnit = A3C_UI_squadPlacement_units select 0;
    private _lastHudData = _lastUnit getVariable ["A3C_HUD_DATA", []];

    if ((count _lastHudData) > 0) then {
        private _lastIndicator = _lastHudData select 0;

        if !(isNull _lastIndicator) then {
            _lastIndicator setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,1,0,0.1)"];
        };
    };
};

if ((count A3C_UI_squadPlacement_units) == 0) then {
    {
        inGameUISetEventHandler [_x, "false"];
    } forEach ["PrevAction", "NextAction"];

    profileNamespace setVariable ["A3C_UI_squadPlacement_overlayIsOpen", false];
    ("A3C_UI_squadPlacement_overlay" call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
};

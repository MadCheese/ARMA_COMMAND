#include "..\..\script_component.hpp"

params ["_display", "_key"];

// player globalchat format ["[RADIAL] onKeyUp , %1 (%2)", _key, keyname _key];

A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];

if (_key == (A3C_RadialMenu_KEY_ID select 0)) exitWith {
    [_display] call A3C_UI_Shared_fnc_ReleaseMenuKey;
    if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
        A3C_RD_UNITS = [];
    };
};

if (_key == 16) then {
    [1] call A3C_ui_radialMenu_fnc_ctrlsQuickToggle;
};
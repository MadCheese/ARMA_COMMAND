#include "..\..\script_component.hpp"

params ["_display", "_key"];

private _mods = (_this select [2,5]);
private _bool = false;

// Prevent continuous firing while holding down menu key.
if (A3C_RadialMenu_KEY_ID select 0 == _key) exitWith {};

// Does not need if ([_key] call A3C_UI_Shared_blockKeyDownEvent) condition.
if (_key in A3C_UI_DOWNKEYS) exitWith {};

[_key] call A3C_UI_Shared_FNC_AddDownkey;

// player groupchat format ["[RADIAL] onKeyDown , %1 (%2)", _key, keyname _key];

// Safety: clear A3C_UI_DOWNKEYS - not used in radial.
if ([_key, _mods] isEqualTo ((["A3C", "A3C_KeyFnc_Switch_CommandLevel"] call CBA_fnc_getKeybind) select 5)) exitWith {
    ["COMMAND_LEVEL", "DOWN"] call A3C_UI_mainDisplay_fnc_cbaKeyManager;
    false
};

if (_key == 16) then {
    _bool = [0] call A3C_ui_radialMenu_fnc_ctrlsQuickToggle;
};

//-- prevent opening of map while using radial
private _keyControlsMap = (inputAction "showMap") > 0;
if (_keyControlsMap) exitWith {true};

_bool
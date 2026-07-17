#include "..\..\script_component.hpp"


params ["_display", "_key"];
A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];
if (_key == (A3C_RadialMenu_KEY_ID select 0)) then {
	[_display] call A3C_ui_shared_fnc_releaseMenuKey;
};

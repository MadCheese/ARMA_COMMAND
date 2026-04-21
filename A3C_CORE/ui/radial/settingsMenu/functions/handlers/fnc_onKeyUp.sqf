#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_display", "_key", "_shift", "_ctrl", "_alt"];


if (_key == A3C_RadialMenu_KEY_ID select 0) exitWith {
    (findDisplay IDD_SETTINGS_MENU) closeDisplay 0;
	showCommandingMenu "";
    true
};

false
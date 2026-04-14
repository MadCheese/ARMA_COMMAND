#include "..\script_component.hpp"

params ["_display"];

uiNamespace setVariable [QGVAR(display), _display];

[] call A3C_settingsMenu_fnc_cacheGroups;
[] call A3C_settingsMenu_fnc_cacheControls;
[] call A3C_settingsMenu_fnc_refresh;
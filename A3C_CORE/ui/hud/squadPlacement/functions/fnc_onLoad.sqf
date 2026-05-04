#include "..\script_component.hpp"

params ["_display"];

uiNamespace setVariable [QGVAR(display), _display];

// Temporary legacy namespace support.
// Remove after external scripts stop relying on uiNamespace variable A3C_HUD_MENU.
uiNamespace setVariable ["A3C_HUD_MENU", _display];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
[] call FUNC(refresh);
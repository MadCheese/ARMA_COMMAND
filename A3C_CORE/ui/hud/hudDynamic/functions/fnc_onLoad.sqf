#include "..\script_component.hpp"

params ["_display"];

uiNamespace setVariable [QGVAR(display), _display];

// Temporary legacy namespace support.
// Useful if existing ctrlCreate logic still fetches this display by uiNamespace.
uiNamespace setVariable ["A3C_DSP_HUD_DYNAMIC", _display];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
[] call FUNC(refresh);
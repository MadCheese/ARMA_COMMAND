#include "..\script_component.hpp"

params ["_display"];

uiNamespace setVariable [QGVAR(display), _display];

// Temporary legacy namespace support.
// Remove after external scripts stop relying on uiNamespace variable A3C_UI_squadPlacement_interaction.
uiNamespace setVariable ["A3C_UI_squadPlacement_interaction", _display];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
[] call FUNC(refresh);
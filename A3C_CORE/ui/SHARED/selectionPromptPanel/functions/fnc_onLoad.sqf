#include "..\script_component.hpp"

params ["_display"];

uiNamespace setVariable [QGVAR(display), _display];

// Temporary legacy namespace support.
// Remove after external scripts stop relying on uiNamespace variable HUD_SelectionPromptPanel.
uiNamespace setVariable ["HUD_SelectionPromptPanel", _display];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
[] call FUNC(refresh);
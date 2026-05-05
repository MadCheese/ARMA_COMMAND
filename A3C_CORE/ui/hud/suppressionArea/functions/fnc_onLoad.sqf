#include "..\script_component.hpp"

params ["_display"];

uiNamespace setVariable [QGVAR(display), _display];

// Temporary legacy namespace support, if any external scripts still findDisplay / uiNamespace this display.
uiNamespace setVariable ["A3C_SUPPRESSION_DRAW", _display];

[] call FUNC(cacheControls);
[] call FUNC(cacheGroups);
[] call FUNC(refresh);
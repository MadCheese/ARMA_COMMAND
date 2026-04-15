#include "..\script_component.hpp"

params ["_display"];

uiNamespace setVariable [QGVAR(display), _display];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
[] call FUNC(refresh);
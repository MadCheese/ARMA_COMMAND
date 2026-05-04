#include "..\script_component.hpp"

params ["_display"];

profileNamespace setVariable ["A3C_HUD_isOpen", true];

uiNamespace setVariable [QGVAR(overlayDisplay), _display];
uiNamespace setVariable ["A3C_HUD_MENU_UI", _display];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
[] call FUNC(refresh);
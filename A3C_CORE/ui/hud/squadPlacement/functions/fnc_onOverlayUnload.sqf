#include "..\script_component.hpp"

profileNamespace setVariable ["A3C_HUD_isOpen", false];

uiNamespace setVariable [QGVAR(overlayDisplay), displayNull];
uiNamespace setVariable ["A3C_HUD_MENU_UI", displayNull];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
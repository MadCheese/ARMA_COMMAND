#include "..\script_component.hpp"

profileNamespace setVariable ["A3C_UI_squadPlacement_overlayIsOpen", false];

uiNamespace setVariable [QGVAR(overlayDisplay), displayNull];
uiNamespace setVariable ["A3C_UI_squadPlacement_overlay", displayNull];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
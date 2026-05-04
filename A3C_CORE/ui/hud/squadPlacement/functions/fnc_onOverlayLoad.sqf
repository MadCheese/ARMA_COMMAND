#include "..\script_component.hpp"

params ["_display"];

profileNamespace setVariable ["A3C_UI_squadPlacement_overlayIsOpen", true];

uiNamespace setVariable [QGVAR(overlayDisplay), _display];
uiNamespace setVariable ["A3C_UI_squadPlacement_overlay", _display];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
[] call FUNC(refresh);
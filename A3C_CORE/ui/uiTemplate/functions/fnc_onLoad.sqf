#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

params ["_display"];

uiNamespace setVariable [QGVAR(display), _display];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);

private _buttonActions = createHashMapFromArray [
    [IDC_TEMPLATE_BTN_PRIMARY, "primary"],
    [IDC_TEMPLATE_BTN_SECONDARY, "secondary"],
    [IDC_TEMPLATE_GROUP_CHILD_EXAMPLE, "groupChildExample"]
];

uiNamespace setVariable [QGVAR(buttonActions), _buttonActions];

[] call FUNC(refresh);
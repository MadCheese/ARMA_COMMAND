#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _groups = createHashMapFromArray [
    ["main", _display displayCtrl IDC_TEMPLATE_GROUP_MAIN]
];

uiNamespace setVariable [QGVAR(groups), _groups];
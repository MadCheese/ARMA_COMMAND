#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _controls = createHashMapFromArray [
    ["primary", _display displayCtrl IDC_TEMPLATE_BTN_PRIMARY],
    ["secondary", _display displayCtrl IDC_TEMPLATE_BTN_SECONDARY]
];

uiNamespace setVariable [QGVAR(controls), _controls];
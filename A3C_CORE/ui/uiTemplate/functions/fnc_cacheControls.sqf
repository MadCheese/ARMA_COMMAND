#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _controls = createHashMapFromArray [
    ["header", _display displayCtrl IDC_TEMPLATE_HEADER],
    ["primary", _display displayCtrl IDC_TEMPLATE_BTN_PRIMARY],
    ["secondary", _display displayCtrl IDC_TEMPLATE_BTN_SECONDARY],
    ["status", _display displayCtrl IDC_TEMPLATE_STATUS]
];

private _groups = uiNamespace getVariable [QGVAR(groups), createHashMap];
private _groupMain = _groups getOrDefault ["main", controlNull];

if !(isNull _groupMain) then {
    _controls set ["groupChildExample", _groupMain controlsGroupCtrl IDC_TEMPLATE_GROUP_CHILD_EXAMPLE];
};

uiNamespace setVariable [QGVAR(controls), _controls];
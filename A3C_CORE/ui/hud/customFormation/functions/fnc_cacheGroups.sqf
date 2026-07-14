#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _teamButtons = [
    _display displayCtrl IDC_CUSTOM_FORMATION_TEAM_RED,
    _display displayCtrl IDC_CUSTOM_FORMATION_TEAM_GREEN,
    _display displayCtrl IDC_CUSTOM_FORMATION_TEAM_BLUE,
    _display displayCtrl IDC_CUSTOM_FORMATION_TEAM_YELLOW,
    _display displayCtrl IDC_CUSTOM_FORMATION_TEAM_MAIN,
    _display displayCtrl IDC_CUSTOM_FORMATION_TEAM_ALL
] select {
    !isNull _x
};

private _groups = createHashMapFromArray [
    ["teamButtons", _teamButtons]
];

uiNamespace setVariable [QGVAR(groups), _groups];
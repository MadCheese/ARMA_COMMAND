#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _controls = createHashMapFromArray [
    ["bgCore", _display displayCtrl IDC_RADIAL_BG_CORE],
    ["bgTop", _display displayCtrl IDC_RADIAL_BG_TOP],
    ["bgRight", _display displayCtrl IDC_RADIAL_BG_RIGHT],
    ["bgBottom", _display displayCtrl IDC_RADIAL_BG_BOTTOM],
    ["bgLeft", _display displayCtrl IDC_RADIAL_BG_LEFT]
];

uiNamespace setVariable [QGVAR(controls), _controls];
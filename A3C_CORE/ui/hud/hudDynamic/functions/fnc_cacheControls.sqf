#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

private _controls = createHashMap;

if !(isNull _display) then {
    _controls set ["background", _display displayCtrl IDC_HUD_DYNAMIC_BACKGROUND];
};

uiNamespace setVariable [QGVAR(controls), _controls];
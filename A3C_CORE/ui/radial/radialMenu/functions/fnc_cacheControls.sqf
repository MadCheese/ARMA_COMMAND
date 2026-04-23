#include "..\script_component.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

uiNamespace setVariable [QGVAR(controls), createHashMap];
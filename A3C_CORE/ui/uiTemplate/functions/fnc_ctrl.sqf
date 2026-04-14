#include "..\script_component.hpp"

params ["_name"];

private _controls = uiNamespace getVariable [QGVAR(controls), createHashMap];
_controls getOrDefault [_name, controlNull]
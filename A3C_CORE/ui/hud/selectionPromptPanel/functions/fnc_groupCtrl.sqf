#include "..\script_component.hpp"

params ["_name"];

private _groups = uiNamespace getVariable [QGVAR(groups), createHashMap];
_groups getOrDefault [_name, []];
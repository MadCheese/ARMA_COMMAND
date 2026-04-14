#include "..\script_component.hpp"

params ["_groupName", "_childName"];

private _groups = uiNamespace getVariable [QGVAR(groups), createHashMap];
private _group = _groups getOrDefault [_groupName, controlNull];
if (isNull _group) exitWith {controlNull};

private _controls = uiNamespace getVariable [QGVAR(controls), createHashMap];
_controls getOrDefault [_childName, controlNull]
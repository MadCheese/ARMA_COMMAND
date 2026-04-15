#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_control"];

private _idc = ctrlIDC _control;
private _arg = "";

switch (_idc) do {
    case IDC_TEMPLATE_BTN_PRIMARY: { _arg = "PRIMARY"; };
    case IDC_TEMPLATE_BTN_SECONDARY: { _arg = "SECONDARY"; };
};

if (_arg isEqualTo "") exitWith {};

[_arg] call FUNC(exampleAction);
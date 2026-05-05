#include "..\..\script_component.hpp"

params ["_mode"];

private _controlName = switch (_mode) do {
    case "PERCENTAGE": {"percentageEdit"};
    case "MAGAZINE": {"magazineEdit"};
    case "TIME": {"timeEdit"};
    default {""};
};

if (_controlName isEqualTo "") exitWith {};

private _control = [_controlName] call FUNC(ctrl);
if (isNull _control) exitWith {};

private _default = switch (_mode) do {
    case "PERCENTAGE": {
        str (profileNamespace getVariable ["A3C_SUP_VAL_PERCENTAGE", 25])
    };
    case "MAGAZINE": {
        str (profileNamespace getVariable ["A3C_SUP_VAL_MAGAZINE", 1])
    };
    case "TIME": {
        str (profileNamespace getVariable ["A3C_SUP_VAL_TIME", 30])
    };
    default {
        ""
    };
};

if ((parseNumber (ctrlText _control)) == 0) then {
    _control ctrlSetText _default;
};
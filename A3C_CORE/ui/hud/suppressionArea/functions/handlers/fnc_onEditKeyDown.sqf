#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_control"];

private _type = switch (ctrlIDC _control) do {
    case IDC_SUPPRESSION_AREA_EDIT_PERCENTAGE: {"PERCENTAGE"};
    case IDC_SUPPRESSION_AREA_EDIT_MAGAZINES: {"MAGAZINE"};
    case IDC_SUPPRESSION_AREA_EDIT_TIME: {"TIME"};
    default {""};
};

if (_type isEqualTo "") exitWith {
    false
};

[_type] spawn {
    params ["_type"];

    sleep 0.01;
    [_type] call FUNC(normalizeRestrictionValue);
};

false
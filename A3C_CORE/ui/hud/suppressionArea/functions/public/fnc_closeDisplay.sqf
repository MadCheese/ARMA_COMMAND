#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

disableSerialization;

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) then {
    _display = findDisplay IDD_SUPPRESSION_AREA_DRAW;
};

if (isNull _display) exitWith {};

private _percentageEdit = ["percentageEdit"] call FUNC(ctrl);
private _magazineEdit = ["magazineEdit"] call FUNC(ctrl);
private _timeEdit = ["timeEdit"] call FUNC(ctrl);

if (isNull _percentageEdit) then {
    _percentageEdit = _display displayCtrl IDC_SUPPRESSION_AREA_EDIT_PERCENTAGE;
};

if (isNull _magazineEdit) then {
    _magazineEdit = _display displayCtrl IDC_SUPPRESSION_AREA_EDIT_MAGAZINES;
};

if (isNull _timeEdit) then {
    _timeEdit = _display displayCtrl IDC_SUPPRESSION_AREA_EDIT_TIME;
};

private _readNumber = {
    params ["_control", "_fallback"];

    if (isNull _control) exitWith {
        _fallback
    };

    parseNumber (ctrlText _control)
};

private _percentageValue = [
    _percentageEdit,
    profileNamespace getVariable ["A3C_SUP_VAL_PERCENTAGE", 25]
] call _readNumber;

private _magazineValue = [
    _magazineEdit,
    profileNamespace getVariable ["A3C_SUP_VAL_MAGAZINE", 1]
] call _readNumber;

private _timeValue = [
    _timeEdit,
    profileNamespace getVariable ["A3C_SUP_VAL_TIME", 30]
] call _readNumber;

profileNamespace setVariable ["A3C_SUP_VAL_PERCENTAGE", _percentageValue];
profileNamespace setVariable ["A3C_SUP_VAL_MAGAZINE", _magazineValue];
profileNamespace setVariable ["A3C_SUP_VAL_TIME", _timeValue];

private _mode = (profileNamespace getVariable ["A3C_SUP_RESTRICTIVE", ["UNLIMITED", 0]]) select 0;

private _modeData = switch (_mode) do {
    case "UNLIMITED": {
        0
    };
    case "PERCENTAGE": {
        _percentageValue
    };
    case "MAGAZINE": {
        _magazineValue
    };
    case "TIME": {
        _timeValue
    };
    default {
        0
    };
};

profileNamespace setVariable ["A3C_SUP_RESTRICTIVE", [_mode, _modeData]];

_display closeDisplay 0;
#include "..\..\script_component.hpp"

disableSerialization;

private _drawBox = ["drawBox"] call FUNC(ctrl);
private _percentageEdit = ["percentageEdit"] call FUNC(ctrl);
private _magazineEdit = ["magazineEdit"] call FUNC(ctrl);
private _timeEdit = ["timeEdit"] call FUNC(ctrl);

if (isNull _drawBox) exitWith {
    systemChat "A3C: No Target Area received";
    [] call FUNC(closeDisplay);
};

if (isNull _percentageEdit) exitWith {
    [] call FUNC(closeDisplay);
};

if (isNull _magazineEdit) exitWith {
    [] call FUNC(closeDisplay);
};

if (isNull _timeEdit) exitWith {
    [] call FUNC(closeDisplay);
};

if (A3C_SUP_DRAW_TOGGLE) exitWith {};
if !(A3C_DRAW_ORDER_RELEASE) exitWith {};

private _ctrlPos = ctrlPosition _drawBox;

profileNamespace setVariable [
    "A3C_SUP_VAL_PERCENTAGE",
    parseNumber (ctrlText _percentageEdit)
];

profileNamespace setVariable [
    "A3C_SUP_VAL_MAGAZINE",
    parseNumber (ctrlText _magazineEdit)
];

profileNamespace setVariable [
    "A3C_SUP_VAL_TIME",
    parseNumber (ctrlText _timeEdit)
];

if (({_x > 0} count _ctrlPos) > 0) then {
    [] spawn FUNC(setOrder);
} else {
    systemChat "A3C: No Target Area received";
    [] call FUNC(closeDisplay);
};
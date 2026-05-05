#include "..\..\script_component.hpp"

params ["_mode", ["_override", false]];

private _typePictures = [
    ["UNLIMITED", "typePicUnlimited"],
    ["PERCENTAGE", "typePicPercentage"],
    ["MAGAZINE", "typePicMagazine"],
    ["TIME", "typePicTime"]
];

{
    private _picture = [_x select 1] call FUNC(ctrl);

    if !(isNull _picture) then {
        _picture ctrlSetText "A3C_CORE\ui\pictures\icon_menu_checkbox_Unchecked.paa";
    };
} forEach _typePictures;

private _selectedPictureName = switch (_mode) do {
    case "UNLIMITED": {"typePicUnlimited"};
    case "PERCENTAGE": {"typePicPercentage"};
    case "MAGAZINE": {"typePicMagazine"};
    case "TIME": {"typePicTime"};
    default {""};
};

if !(_selectedPictureName isEqualTo "") then {
    private _selectedPicture = [_selectedPictureName] call FUNC(ctrl);

    if !(isNull _selectedPicture) then {
        _selectedPicture ctrlSetText "A3C_CORE\ui\pictures\icon_menu_checkbox_Checked.paa";
    };
};

private _percentageEdit = ["percentageEdit"] call FUNC(ctrl);
private _magazineEdit = ["magazineEdit"] call FUNC(ctrl);
private _timeEdit = ["timeEdit"] call FUNC(ctrl);

if (_override) then {
    if !(isNull _percentageEdit) then {
        profileNamespace setVariable [
            "A3C_SUP_VAL_PERCENTAGE",
            parseNumber (ctrlText _percentageEdit)
        ];
    };

    if !(isNull _magazineEdit) then {
        profileNamespace setVariable [
            "A3C_SUP_VAL_MAGAZINE",
            parseNumber (ctrlText _magazineEdit)
        ];
    };

    if !(isNull _timeEdit) then {
        profileNamespace setVariable [
            "A3C_SUP_VAL_TIME",
            parseNumber (ctrlText _timeEdit)
        ];
    };
};

private _percentageValue = profileNamespace getVariable ["A3C_SUP_VAL_PERCENTAGE", 25];
private _magazineValue = profileNamespace getVariable ["A3C_SUP_VAL_MAGAZINE", 1];
private _timeValue = profileNamespace getVariable ["A3C_SUP_VAL_TIME", 30];

private _modeData = switch (_mode) do {
    case "UNLIMITED": {
        0
    };
    case "PERCENTAGE": {
        if !(isNull _percentageEdit) then {
            parseNumber (ctrlText _percentageEdit)
        } else {
            _percentageValue
        }
    };
    case "MAGAZINE": {
        if !(isNull _magazineEdit) then {
            parseNumber (ctrlText _magazineEdit)
        } else {
            _magazineValue
        }
    };
    case "TIME": {
        if !(isNull _timeEdit) then {
            parseNumber (ctrlText _timeEdit)
        } else {
            _timeValue
        }
    };
    default {
        0
    };
};

if !(isNull _percentageEdit) then {
    _percentageEdit ctrlSetText str _percentageValue;
};

if !(isNull _magazineEdit) then {
    _magazineEdit ctrlSetText str _magazineValue;
};

if !(isNull _timeEdit) then {
    _timeEdit ctrlSetText str _timeValue;
};

private _percentageButton = ["buttonPercentage"] call FUNC(ctrl);
if !(isNull _percentageButton) then {
    ctrlSetFocus _percentageButton;
};

profileNamespace setVariable ["A3C_SUP_RESTRICTIVE", [_mode, _modeData]];
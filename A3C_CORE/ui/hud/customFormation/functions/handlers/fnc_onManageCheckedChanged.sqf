#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_onManageCheckedChanged

params [
    ["_control", controlNull, [controlNull]],
    ["_state", 0]
];

if (isNull _control) exitWith {};

private _updating =
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_ManageUpdating",
        false
    ];

if (_updating) exitWith {};

private _isSelectAll =
    _control getVariable [
        "A3C_IsSelectAll",
        false
    ];

if (_isSelectAll) then {
    private _checked =
        (_state isEqualTo 1)
        || {
            _state isEqualTo true
        };

    private _checkBoxes =
        uiNamespace getVariable [
            "A3C_UI_CustomFormation_ManageCheckBoxes",
            []
        ];

    uiNamespace setVariable [
        "A3C_UI_CustomFormation_ManageUpdating",
        true
    ];

    {
        if !(isNull _x) then {
            _x cbSetChecked
                _checked;
        };
    } forEach _checkBoxes;

    uiNamespace setVariable [
        "A3C_UI_CustomFormation_ManageUpdating",
        false
    ];
};

[] call FUNC(updateSavedFormationManager);
#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_UI_customFormation_fnc_populateSavedFormationManager
//
// Populates the management display with every stored formation.
//
// Compatibility is intentionally not evaluated here. Legacy, compatible,
// adaptive, malformed, and currently incompatible entries are all shown.
//
// This function deletes dynamically created controls. Call it either:
//     - outside a UI event handler, or
//     - from code spawned by a UI event handler.

disableSerialization;

private _display = uiNamespace getVariable [
    "A3C_UI_CustomFormation_ManageDisplay",
    displayNull
];

if (isNull _display) exitWith {};

private _rowsGroup = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_ROWS_GROUP;

if (isNull _rowsGroup) exitWith {};

/*
    Remove controls created by the previous population pass.
*/
private _oldDynamicControls =
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_ManageDynamicControls",
        []
    ];

{
    if !(isNull _x) then {
        ctrlDelete _x;
    };
} forEach _oldDynamicControls;

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageDynamicControls",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageCheckBoxes",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageConfirmingDelete",
    false
];

private _savedFormations =
    profileNamespace getVariable [
        "A3C_C_FORMATIONS_SAVED",
        []
    ];

if !(_savedFormations isEqualType []) then {
    _savedFormations = [];
};

private _emptyText = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_EMPTY_TEXT;

if !(isNull _emptyText) then {
    _emptyText ctrlShow (
        _savedFormations isEqualTo []
    );
};

private _dynamicControls = [];
private _checkBoxes = [];

private _rowHeight =
    0.046 * safeZoneH;

private _rowWidth =
    0.445 * safeZoneW;

private _checkBoxX =
    0.008 * safeZoneW;

private _checkBoxWidth =
    0.022 * safeZoneW;

private _checkBoxHeight =
    0.03 * safeZoneH;

private _nameX =
    0.038 * safeZoneW;

private _nameWidth =
    0.39 * safeZoneW;

{
    private _profileIndex =
        _forEachIndex;

    private _savedEntry =
        _x;

    private _fallbackName = format [
        "UNNAMED FORMATION %1",
        _profileIndex + 1
    ];

    private _savedName =
        _fallbackName;

    if (_savedEntry isEqualType []) then {
        _savedName =
            _savedEntry param [
                0,
                _fallbackName
            ];
    } else {
        /*
            Preserve access to a malformed top-level entry so the user can
            still select and delete it.
        */
        _savedName = format [
            "INVALID FORMATION ENTRY %1",
            _profileIndex + 1
        ];
    };

    if !(_savedName isEqualType "") then {
        _savedName =
            str _savedName;
    };

    if (_savedName isEqualTo "") then {
        _savedName =
            _fallbackName;
    };

    private _rowY =
        _profileIndex
        * _rowHeight;

    private _rowBackground = _display ctrlCreate [
        "A3C_RscText",
        -1,
        _rowsGroup
    ];

    if !(isNull _rowBackground) then {
        private _backgroundAlpha = if (
            (_profileIndex mod 2)
            isEqualTo
            0
        ) then {
            0.12
        } else {
            0.2
        };

        _rowBackground ctrlSetBackgroundColor [
            1,
            1,
            1,
            _backgroundAlpha
        ];

        _rowBackground ctrlSetPosition [
            0,
            _rowY,
            _rowWidth,
            _rowHeight - (0.002 * safeZoneH)
        ];

        _rowBackground ctrlCommit 0;

        _dynamicControls pushBack
            _rowBackground;
    };

    private _checkBox = _display ctrlCreate [
        "A3C_CustomFormation_CheckBox",
        -1,
        _rowsGroup
    ];

    if !(isNull _checkBox) then {
        _checkBox setVariable [
            "A3C_ProfileIndex",
            _profileIndex
        ];

        _checkBox setVariable [
            "A3C_IsSelectAll",
            false
        ];

        _checkBox ctrlSetPosition [
            _checkBoxX,
            _rowY
            + (
                (_rowHeight - _checkBoxHeight)
                / 2
            ),
            _checkBoxWidth,
            _checkBoxHeight
        ];

        _checkBox ctrlCommit 0;

        /*
            Establish the initial state before installing the event handler.
        */
        _checkBox cbSetChecked false;

        _checkBox ctrlAddEventHandler [
            "CheckedChanged",
            {
                _this call FUNC(onManageCheckedChanged);
            }
        ];

        _checkBoxes pushBack
            _checkBox;

        _dynamicControls pushBack
            _checkBox;
    };

    private _nameText = _display ctrlCreate [
        "A3C_RscText",
        -1,
        _rowsGroup
    ];

    if !(isNull _nameText) then {
        _nameText ctrlSetText
            _savedName;

        _nameText ctrlSetPosition [
            _nameX,
            _rowY,
            _nameWidth,
            _rowHeight - (0.002 * safeZoneH)
        ];

        _nameText ctrlCommit 0;
        _nameText ctrlSetTooltip
            _savedName;

        _dynamicControls pushBack
            _nameText;
    };

    /*
        Clicking the name area toggles the row checkbox.
    */
    private _nameButton = _display ctrlCreate [
        "A3C_RscButton_Invisible",
        -1,
        _rowsGroup
    ];

    if !(isNull _nameButton) then {
        _nameButton setVariable [
            "A3C_CheckBox",
            _checkBox
        ];

        _nameButton ctrlSetPosition [
            _nameX,
            _rowY,
            _nameWidth,
            _rowHeight - (0.002 * safeZoneH)
        ];

        _nameButton ctrlCommit 0;
        _nameButton ctrlSetTooltip
            _savedName;

        _nameButton ctrlAddEventHandler [
            "ButtonClick",
            {
                _this call FUNC(onManageRowButtonClick);
            }
        ];

        _dynamicControls pushBack
            _nameButton;
    };
} forEach _savedFormations;

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageDynamicControls",
    _dynamicControls
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageCheckBoxes",
    _checkBoxes
];

[] call FUNC(updateSavedFormationManager);
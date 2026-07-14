#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_UI_customFormation_fnc_updateSavedFormationManager
//
// Synchronizes:
//     - selected count
//     - select-all state
//     - trash-button availability
//     - normal toolbar / confirmation toolbar visibility

disableSerialization;

private _display = uiNamespace getVariable [
    "A3C_UI_CustomFormation_ManageDisplay",
    displayNull
];

if (isNull _display) exitWith {};

private _checkBoxes = (
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_ManageCheckBoxes",
        []
    ]
) select {
    !(isNull _x)
};

private _selectedCheckBoxes =
    _checkBoxes select {
        cbChecked _x
    };

private _rowCount =
    count _checkBoxes;

private _selectedCount =
    count _selectedCheckBoxes;

private _confirmingDelete =
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_ManageConfirmingDelete",
        false
    ];

if (_selectedCount <= 0) then {
    _confirmingDelete = false;

    uiNamespace setVariable [
        "A3C_UI_CustomFormation_ManageConfirmingDelete",
        false
    ];
};

private _selectAll = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_SELECT_ALL;

private _selectedCountControl = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_SELECTED_COUNT;

private _trashImage = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_TRASH_IMAGE;

private _trashButton = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_TRASH_BUTTON;

private _confirmText = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_CONFIRM_TEXT;

private _confirmCancel = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_CONFIRM_CANCEL;

private _confirmDelete = _display displayCtrl
    IDC_CUSTOM_FORMATION_MANAGE_CONFIRM_DELETE;

/*
    Programmatic checkbox changes fire CheckedChanged. Guard against the
    select-all handler treating this synchronization as a user action.
*/
uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageUpdating",
    true
];

if !(isNull _selectAll) then {
    _selectAll cbSetChecked (
        (_rowCount > 0)
        && {
            _selectedCount
            isEqualTo
            _rowCount
        }
    );

    _selectAll ctrlEnable (
        _rowCount > 0
    );
};

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageUpdating",
    false
];

if !(isNull _selectedCountControl) then {
    private _selectionText = if (
        _selectedCount isEqualTo 1
    ) then {
        "1 selected"
    } else {
        format [
            "%1 selected",
            _selectedCount
        ]
    };

    _selectedCountControl ctrlSetText
        _selectionText;
};

if !(isNull _trashButton) then {
    _trashButton ctrlEnable (
        _selectedCount > 0
    );
};

if !(isNull _trashImage) then {
    private _trashColor = if (
        _selectedCount > 0
    ) then {
        [1,1,1,1]
    } else {
        [1,1,1,0.25]
    };

    _trashImage ctrlSetTextColor
        _trashColor;
};

if !(isNull _confirmText) then {
    private _formationWord = if (
        _selectedCount isEqualTo 1
    ) then {
        "formation"
    } else {
        "formations"
    };

    _confirmText ctrlSetText format [
        "Delete %1 selected %2?",
        _selectedCount,
        _formationWord
    ];
};

{
    if !(isNull _x) then {
        _x ctrlShow
            !_confirmingDelete;
    };
} forEach [
    _selectAll,
    _selectedCountControl,
    _trashImage,
    _trashButton
];

{
    if !(isNull _x) then {
        _x ctrlShow
            _confirmingDelete;
    };
} forEach [
    _confirmText,
    _confirmCancel,
    _confirmDelete
];

if !(isNull _confirmDelete) then {
    _confirmDelete ctrlEnable (
        _selectedCount > 0
    );
};
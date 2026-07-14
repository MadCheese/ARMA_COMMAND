#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_deleteSelectedSavedFormations
//
// Deletes every checked saved-formation entry using its real profile-array
// index.
//
// This function must run in scheduled context because repopulating the
// manager deletes dynamically created controls. It is spawned by the
// confirmation-button handler.
//
// Deleting a stored preset does not alter:
//     - current unit A3C_FORM values,
//     - runtime exact-stroke data,
//     - custom-formation activation state.

disableSerialization;

private _display = uiNamespace getVariable [
    "A3C_UI_CustomFormation_ManageDisplay",
    displayNull
];

if (isNull _display) exitWith {};

private _checkBoxes =
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_ManageCheckBoxes",
        []
    ];

private _profileIndices = [];

{
    if (
        !(isNull _x)
        && {
            cbChecked _x
        }
    ) then {
        private _profileIndex =
            _x getVariable [
                "A3C_ProfileIndex",
                -1
            ];

        if (_profileIndex >= 0) then {
            _profileIndices pushBackUnique
                _profileIndex;
        };
    };
} forEach _checkBoxes;

/*
    The selection may have changed between opening the confirmation state
    and executing this scheduled function.
*/
if (_profileIndices isEqualTo []) exitWith {
    uiNamespace setVariable [
        "A3C_UI_CustomFormation_ManageConfirmingDelete",
        false
    ];

    [] call FUNC(updateSavedFormationManager);
};

/*
    Delete from highest index to lowest. Removing a higher array element
    cannot shift the index of a lower target.
*/
_profileIndices sort false;

private _profileData =
    profileNamespace getVariable [
        "A3C_C_FORMATIONS_SAVED",
        []
    ];

if !(_profileData isEqualType []) then {
    _profileData = [];
};

private _deletedCount = 0;

{
    if (
        (_x >= 0)
        && {
            _x < count _profileData
        }
    ) then {
        _profileData deleteAt
            _x;

        _deletedCount =
            _deletedCount + 1;
    };
} forEach _profileIndices;

if (_deletedCount > 0) then {
    profileNamespace setVariable [
        "A3C_C_FORMATIONS_SAVED",
        _profileData
    ];

    saveProfileNamespace;

    /*
        The filtered loading list must be rebuilt from profile data because
        its visible-row-to-profile-index mapping may have changed.
    */
    uiNamespace setVariable [
        "A3C_UI_CustomFormation_saveLB",
        0
    ];

    uiNamespace setVariable [
        "A3C_UI_CustomFormation_RequestedSaveProfileIndex",
        -1
    ];

    [] call FUNC(labelListbox);
};

uiNamespace setVariable [
    "A3C_UI_CustomFormation_ManageConfirmingDelete",
    false
];

/*
    This deletes and recreates dynamic row controls.

    The function itself was spawned from the UI event handler, so these
    ctrlDelete operations no longer execute inside that handler.
*/
[] call FUNC(populateSavedFormationManager);
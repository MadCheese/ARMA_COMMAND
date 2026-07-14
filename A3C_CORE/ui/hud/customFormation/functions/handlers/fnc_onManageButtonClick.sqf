#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_UI_customFormation_fnc_onManageButtonClick

disableSerialization;

params [
    ["_control", controlNull, [controlNull]]
];

if (isNull _control) exitWith {};

private _display =
    ctrlParent _control;

if (isNull _display) exitWith {};

switch (ctrlIDC _control) do {
    case IDC_CUSTOM_FORMATION_MANAGE_CLOSE_BUTTON: {
        _display closeDisplay 1;
    };

    case IDC_CUSTOM_FORMATION_MANAGE_TRASH_BUTTON: {
        private _checkBoxes =
            uiNamespace getVariable [
                "A3C_UI_CustomFormation_ManageCheckBoxes",
                []
            ];

        private _hasSelection =
            (
                _checkBoxes findIf {
                    !(isNull _x)
                    && {
                        cbChecked _x
                    }
                }
            ) >= 0;

        if (_hasSelection) then {
            uiNamespace setVariable [
                "A3C_UI_CustomFormation_ManageConfirmingDelete",
                true
            ];

            [] call FUNC(updateSavedFormationManager);
        };
    };

    case IDC_CUSTOM_FORMATION_MANAGE_CONFIRM_CANCEL: {
        uiNamespace setVariable [
            "A3C_UI_CustomFormation_ManageConfirmingDelete",
            false
        ];

        [] call FUNC(updateSavedFormationManager);
    };

    case IDC_CUSTOM_FORMATION_MANAGE_CONFIRM_DELETE: {
        /*
            Prevent duplicate confirmation clicks while the scheduled
            deletion operation starts.
        */
        _control ctrlEnable false;

        /*
            The deletion function repopulates the dynamic controls and must
            therefore execute outside this UI event handler.
        */
        [] spawn FUNC(deleteSelectedSavedFormations);
    };
};
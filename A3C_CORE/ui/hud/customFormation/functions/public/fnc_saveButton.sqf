#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_UI_customFormation_fnc_saveButton

params ["_button"];

if (
    !A3C_UI_CustomFormation_BOOL_formationActive
    && {_button isEqualTo 0}
) exitWith {
    systemChat "A3C: Please Engage The Formation First";
};

private _saveEdit = uiNamespace getVariable [
    "A3C_C_FORM_SaveBox",
    controlNull
];

if (_button isEqualTo 0) then {
    if !A3C_UI_CustomFormation_SaveOverlayIsOpen then {
        private _display = uiNamespace getVariable [
            QGVAR(display),
            displayNull
        ];

        if (isNull _display) exitWith {};

        A3C_UI_CustomFormation_SaveOverlayIsOpen = true;

        _saveEdit = _display ctrlCreate [
            "RscEdit",
            IDC_CUSTOM_FORMATION_DYNAMIC_SAVE_NAME_EDIT
        ];

        _saveEdit ctrlSetPosition [
            0.660383 * safezoneW + safezoneX,
            0.709033 * safezoneH + safezoneY,
            0.217662 * safezoneW,
            0.044007 * safezoneH
        ];

        _saveEdit ctrlCommit 0;

        uiNamespace setVariable [
            "A3C_C_FORM_SaveBox",
            _saveEdit
        ];
    } else {
        private _nameString = str parseText ctrlText _saveEdit;

        if !(_nameString isEqualTo "") then {
            private _formationData = [];

            {
                _formationData pushBack (
                    _x getVariable ["A3C_FORM", []]
                );
            } forEach (units player - [player]);

            private _profileData = profileNamespace getVariable [
                "A3C_C_FORMATIONS_SAVED",
                []
            ];

            _profileData pushBack [
                _nameString,
                _formationData
            ];

            profileNamespace setVariable [
                "A3C_C_FORMATIONS_SAVED",
                _profileData
            ];

            if (
                !(isNull _saveEdit)
                && {ctrlShown _saveEdit}
            ) then {
                ctrlDelete _saveEdit;
            };

            // The listbox contains CUSTOM at index 0, so the saved-data
            // count is also the correct listbox selection index.
            uiNamespace setVariable [
                "A3C_UI_CustomFormation_saveLB",
                count _profileData
            ];

            [] call FUNC(labelListbox);
        } else {
            systemChat "A3C: No Name Detected";
        };

        A3C_UI_CustomFormation_SaveOverlayIsOpen = false;
    };
} else {
    private _previousClickTime = missionNamespace getVariable [
        "A3C_LB_TICKTIME",
        0
    ];

    private _clickInterval = time - _previousClickTime;

    if (
        (_clickInterval > 0.07)
        && {_clickInterval < 0.3}
    ) then {
        private _savedSelection = uiNamespace getVariable [
            "A3C_UI_CustomFormation_saveLB",
            0
        ];

        if !(_savedSelection isEqualTo 0) then {
            private _listbox = ["savedFormations"] call FUNC(ctrl);

            if !(isNull _listbox) then {
                private _profileData = profileNamespace getVariable [
                    "A3C_C_FORMATIONS_SAVED",
                    []
                ];

                _profileData deleteAt (
                    (lbCurSel _listbox) - 1
                );

                profileNamespace setVariable [
                    "A3C_C_FORMATIONS_SAVED",
                    _profileData
                ];

                uiNamespace setVariable [
                    "A3C_UI_CustomFormation_saveLB",
                    0
                ];
            };
        };
    };

    A3C_LB_TICKTIME = time;

    if (
        !(isNull _saveEdit)
        && {ctrlShown _saveEdit}
    ) then {
        ctrlDelete _saveEdit;
    };

    [] call FUNC(labelListbox);

    A3C_UI_CustomFormation_SaveOverlayIsOpen = false;
};
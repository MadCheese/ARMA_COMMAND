#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_UI_customFormation_fnc_saveButton

disableSerialization;

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

if !(_button isEqualTo 0) exitWith {
    if !(isNull _saveEdit) then {
        ctrlDelete _saveEdit;
    };

    uiNamespace setVariable [
        "A3C_C_FORM_SaveBox",
        controlNull
    ];

    A3C_UI_CustomFormation_SaveOverlayIsOpen = false;

    [] call FUNC(labelListbox);
};

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
    private _nameString =
        str parseText ctrlText _saveEdit;

    if !(_nameString isEqualTo "") then {
        /*
            Remove stale runtime exact-stroke records before serializing
            the current formation.
        */
        [] call FUNC(restoreFormationVisuals);

        private _allUnits =
            units group player - [player];

        private _currentTeamData =
            [] call FUNC(getCurrentTeamData);

        if (_currentTeamData isEqualTo []) exitWith {
            systemChat "A3C: No Subordinate Units Detected";

            if !(isNull _saveEdit) then {
                ctrlDelete _saveEdit;
            };

            uiNamespace setVariable [
                "A3C_C_FORM_SaveBox",
                controlNull
            ];

            A3C_UI_CustomFormation_SaveOverlayIsOpen = false;
        };

        private _teamSignature =
            _currentTeamData apply {
                [
                    _x select 0,
                    count (_x select 1)
                ]
            };

        /*
            Retain a whole-group snapshot at index 1 for inspection and
            possible future migration. The version-3 loader uses the
            team-oriented records.
        */
        private _formationData =
            _allUnits apply {
                +(
                    _x getVariable [
                        "A3C_FORM",
                        []
                    ]
                )
            };

        private _runtimeVisualData =
            missionNamespace getVariable [
                "A3C_UI_CustomFormation_VisualData",
                createHashMap
            ];

        if !(
            _runtimeVisualData
            isEqualType
            createHashMap
        ) then {
            _runtimeVisualData =
                createHashMap;
        };

        private _savedRecords = [];

        private _allRuntimeRecord =
            _runtimeVisualData getOrDefault [
                "ALL",
                []
            ];

        private _allStrokePoints = [];

        if (
            (_allRuntimeRecord isEqualType [])
            && {
                (count _allRuntimeRecord) >= 4
            }
            && {
                (_allRuntimeRecord param [0, 0])
                isEqualTo
                2
            }
        ) then {
            _allStrokePoints =
                (
                    _allRuntimeRecord param [
                        2,
                        []
                    ]
                )
                apply {
                    +_x
                };
        };

        if !(_allStrokePoints isEqualTo []) then {
            _savedRecords pushBack [
                "ALL",
                count _allUnits,
                _allStrokePoints,
                _formationData apply {
                    +_x
                }
            ];
        } else {
            {
                _x params [
                    "_team",
                    "_teamUnits"
                ];

                private _slotPoints =
                    _teamUnits apply {
                        +(
                            _x getVariable [
                                "A3C_FORM",
                                []
                            ]
                        )
                    };

                private _strokePoints = [];

                private _runtimeRecord =
                    _runtimeVisualData getOrDefault [
                        _team,
                        []
                    ];

                if (
                    (_runtimeRecord isEqualType [])
                    && {
                        (count _runtimeRecord) >= 4
                    }
                    && {
                        (_runtimeRecord param [0, 0])
                        isEqualTo
                        2
                    }
                ) then {
                    _strokePoints =
                        (
                            _runtimeRecord param [
                                2,
                                []
                            ]
                        )
                        apply {
                            +_x
                        };
                };

                _savedRecords pushBack [
                    _team,
                    count _teamUnits,
                    _strokePoints,
                    _slotPoints
                ];
            } forEach _currentTeamData;
        };

        private _profileData =
            profileNamespace getVariable [
                "A3C_C_FORMATIONS_SAVED",
                []
            ];

        _profileData pushBack [
            _nameString,
            _formationData,
            3,
            _teamSignature,
            _savedRecords
        ];

        profileNamespace setVariable [
            "A3C_C_FORMATIONS_SAVED",
            _profileData
        ];

        saveProfileNamespace;

        if !(isNull _saveEdit) then {
            ctrlDelete _saveEdit;
        };

        uiNamespace setVariable [
            "A3C_C_FORM_SaveBox",
            controlNull
        ];

        uiNamespace setVariable [
            "A3C_UI_CustomFormation_RequestedSaveProfileIndex",
            (count _profileData) - 1
        ];

        uiNamespace setVariable [
            "A3C_UI_CustomFormation_saveLB",
            0
        ];

        [] call FUNC(labelListbox);
    } else {
        systemChat "A3C: No Name Detected";
    };

    A3C_UI_CustomFormation_SaveOverlayIsOpen = false;
};
#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_onListboxSelectionChanged

params [
    "_control",
    "_selectedIndex"
];

if (A3C_CurSel) exitWith {};

if (_selectedIndex <= 0) exitWith {
    uiNamespace setVariable [
        "A3C_UI_CustomFormation_saveLB",
        0
    ];
};

private _visibleSaveIndices =
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_VisibleSaveIndices",
        []
    ];

private _mappingIndex =
    _selectedIndex - 1;

private _savedDataIndex =
    _visibleSaveIndices param [
        _mappingIndex,
        -1
    ];

private _savedFormations =
    profileNamespace getVariable [
        "A3C_C_FORMATIONS_SAVED",
        []
    ];

if (
    (_savedDataIndex < 0)
    || {
        _savedDataIndex
        >=
        count _savedFormations
    }
) exitWith {
    uiNamespace setVariable [
        "A3C_UI_CustomFormation_saveLB",
        0
    ];

    [] call FUNC(labelListbox);
};

private _savedEntry =
    _savedFormations select
        _savedDataIndex;

private _currentTeamData =
    [] call FUNC(getCurrentTeamData);

/*
    Revalidate immediately before loading. The squad configuration may have
    changed after the listbox was initially built.
*/
private _compatibility = [
    _savedEntry,
    _currentTeamData
] call FUNC(getSavedFormationCompatibility);

private _compatibilityState =
    _compatibility param [
        0,
        "INCOMPATIBLE"
    ];

if (
    _compatibilityState
    isEqualTo
    "INCOMPATIBLE"
) exitWith {
    uiNamespace setVariable [
        "A3C_UI_CustomFormation_saveLB",
        0
    ];

    [] call FUNC(labelListbox);

    if !(isNil "MCSS_fnc_ShortHint") then {
        "The selected formation is no longer compatible with the current squad configuration."
            spawn MCSS_fnc_ShortHint;
    };
};

private _savedRecords =
    _savedEntry param [
        4,
        []
    ];

private _recordMap =
    createHashMap;

{
    if (
        (_x isEqualType [])
        && {
            (count _x) >= 4
        }
    ) then {
        _recordMap set [
            _x select 0,
            _x
        ];
    };
} forEach _savedRecords;

private _allUnits =
    units group player - [player];

private _assignments = [];

private _runtimeVisualData =
    createHashMap;

private _loadValid =
    true;

private _allRecord =
    _recordMap getOrDefault [
        "ALL",
        []
    ];

if !(_allRecord isEqualTo []) then {
    private _strokePoints =
        _allRecord select 2;

    private _slotPoints =
        _allRecord select 3;

    private _loadedFormationData = if (
        !(_strokePoints isEqualTo [])
    ) then {
        [
            _strokePoints,
            count _allUnits
        ] call FUNC(sampleFormationStroke)
    } else {
        _slotPoints apply {
            +_x
        }
    };

    if (
        (count _loadedFormationData)
        isNotEqualTo
        count _allUnits
    ) then {
        _loadValid = false;
    } else {
        {
            private _formationData =
                _loadedFormationData select
                    _forEachIndex;

            private _validData =
                (_formationData isEqualTo [])
                || {
                    [
                        _formationData
                    ] call FUNC(isValidFormationData)
                };

            if !(_validData) exitWith {
                _loadValid = false;
            };

            _assignments pushBack [
                _x,
                +_formationData
            ];
        } forEach _allUnits;
    };

    if (
        _loadValid
        && {
            !(_strokePoints isEqualTo [])
        }
    ) then {
        _runtimeVisualData set [
            "ALL",
            [
                2,
                +_allUnits,
                _strokePoints apply {
                    +_x
                },
                _loadedFormationData apply {
                    +_x
                }
            ]
        ];
    };
} else {
    /*
        Load each fireteam independently.
    */
    {
        if !(_loadValid) exitWith {};

        _x params [
            "_team",
            "_teamUnits"
        ];

        private _record =
            _recordMap getOrDefault [
                _team,
                []
            ];

        if (_record isEqualTo []) exitWith {
            _loadValid = false;
        };

        private _strokePoints =
            _record select 2;

        private _slotPoints =
            _record select 3;

        private _loadedFormationData = if (
            !(_strokePoints isEqualTo [])
        ) then {
            [
                _strokePoints,
                count _teamUnits
            ] call FUNC(sampleFormationStroke)
        } else {
            _slotPoints apply {
                +_x
            }
        };

        if (
            (count _loadedFormationData)
            isNotEqualTo
            count _teamUnits
        ) exitWith {
            _loadValid = false;
        };

        {
            private _formationData =
                _loadedFormationData select
                    _forEachIndex;

            private _validData =
                (_formationData isEqualTo [])
                || {
                    [
                        _formationData
                    ] call FUNC(isValidFormationData)
                };

            if !(_validData) exitWith {
                _loadValid = false;
            };

            _assignments pushBack [
                _x,
                +_formationData
            ];
        } forEach _teamUnits;

        if (
            _loadValid
            && {
                !(_strokePoints isEqualTo [])
            }
        ) then {
            _runtimeVisualData set [
                _team,
                [
                    2,
                    +_teamUnits,
                    _strokePoints apply {
                        +_x
                    },
                    _loadedFormationData apply {
                        +_x
                    }
                ]
            ];
        };
    } forEach _currentTeamData;
};

if !(_loadValid) exitWith {
    uiNamespace setVariable [
        "A3C_UI_CustomFormation_saveLB",
        0
    ];

    [] call FUNC(labelListbox);

    if !(isNil "MCSS_fnc_ShortHint") then {
        "The selected formation could not be loaded."
            spawn MCSS_fnc_ShortHint;
    };
};

/*
    Do not modify any unit until every required assignment has been built.
*/
private _formationActive =
    A3C_UI_CustomFormation_BOOL_formationActive;

{
    _x params [
        "_unit",
        "_formationData"
    ];

    private _validData = [
        _formationData
    ] call FUNC(isValidFormationData);

    if (_validData) then {
        _unit setVariable [
            "A3C_FORM",
            +_formationData,
            false
        ];

        _unit setVariable [
            "A3C_FORM_UPDATE_REQUESTED",
            _formationActive,
            false
        ];
    } else {
        _unit setVariable [
            "A3C_FORM",
            [],
            false
        ];

        _unit setVariable [
            "A3C_FORM_UPDATE_REQUESTED",
            false,
            false
        ];
    };
} forEach _assignments;

missionNamespace setVariable [
    "A3C_UI_CustomFormation_VisualData",
    _runtimeVisualData
];

[] call FUNC(restoreFormationVisuals);

uiNamespace setVariable [
    "A3C_UI_CustomFormation_saveLB",
    _selectedIndex
];
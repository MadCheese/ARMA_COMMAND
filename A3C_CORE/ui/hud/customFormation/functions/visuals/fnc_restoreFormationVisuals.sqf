#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_restoreFormationVisuals
//
// Recreates formation visualization controls for the current display.
//
// Priority:
//     1. Restore an exact recorded stroke when it still matches the
//        authoritative A3C_FORM data.
//     2. Otherwise reconstruct one point per valid A3C_FORM slot.
//
// Visual policy:
//     - Exact recorded strokes use thick lines only.
//     - Reconstructed fallback geometry uses thick lines plus unit markers.
//     - A point-only or zero-length exact stroke receives one marker so it
//       cannot become invisible.
//
// Persistent geometry is stored in missionNamespace.
// Display control handles remain in uiNamespace.

disableSerialization;

private _display = uiNamespace getVariable [
    QGVAR(display),
    displayNull
];

if (isNull _display) exitWith {};

private _teamMetadata = [
    [
        "RED",
        "#(argb,8,8,3)color(1,0,0,1)",
        "A3C_UI_CustomFormation_Dots_RED"
    ],
    [
        "GREEN",
        "#(argb,8,8,3)color(0,1,0,1)",
        "A3C_UI_CustomFormation_Dots_GREEN"
    ],
    [
        "BLUE",
        "#(argb,8,8,3)color(0,0,1,1)",
        "A3C_UI_CustomFormation_Dots_BLUE"
    ],
    [
        "YELLOW",
        "#(argb,8,8,3)color(1,1,0,1)",
        "A3C_UI_CustomFormation_Dots_YELLOW"
    ],
    [
        "MAIN",
        "#(argb,8,8,3)color(1,1,1,1)",
        "A3C_UI_CustomFormation_Dots_MAIN"
    ]
];

private _allColor =
    "#(argb,8,8,3)color(0.53,0.29,0.69,1)";

private _allCollectionName =
    "A3C_UI_CustomFormation_Dots_ALL";

private _collectionNames = [
    "A3C_UI_CustomFormation_Dots_RED",
    "A3C_UI_CustomFormation_Dots_GREEN",
    "A3C_UI_CustomFormation_Dots_BLUE",
    "A3C_UI_CustomFormation_Dots_YELLOW",
    "A3C_UI_CustomFormation_Dots_MAIN",
    "A3C_UI_CustomFormation_Dots_ALL"
];

/*
    Delete controls belonging to the previous rendering pass.

    These collections may contain line controls and fallback point markers.
*/
{
    private _controls = uiNamespace getVariable [
        _x,
        []
    ];

    {
        if !(isNull _x) then {
            ctrlDelete _x;
        };
    } forEach _controls;

    uiNamespace setVariable [
        _x,
        []
    ];
} forEach _collectionNames;

private _visualData = missionNamespace getVariable [
    "A3C_UI_CustomFormation_VisualData",
    createHashMap
];

if !(_visualData isEqualType createHashMap) then {
    _visualData =
        createHashMap;
};

private _allUnits =
    units player - [player];

private _getUnitTeam = {
    params ["_unit"];

    if (player isEqualTo cameraOn) then {
        assignedTeam _unit
    } else {
        _unit getVariable [
            "A3C_ASSIGNEDTEAM",
            "MAIN"
        ]
    }
};

private _sameUnitSet = {
    params [
        "_storedUnits",
        "_currentUnits"
    ];

    if !(_storedUnits isEqualType []) exitWith {
        false
    };

    if (
        (count _storedUnits)
        isNotEqualTo
        count _currentUnits
    ) exitWith {
        false
    };

    (
        _storedUnits findIf {
            isNull _x
            || {
                !(_x in _currentUnits)
            }
        }
    ) < 0
};

/*
    Runtime record layout:
        [
            2,
            stored unit objects,
            raw relative stroke points,
            exact A3C_FORM snapshot
        ]
*/
private _recordMatchesCurrentData = {
    params [
        "_record",
        "_currentUnits"
    ];

    if !(_record isEqualType []) exitWith {
        false
    };

    if ((count _record) < 4) exitWith {
        false
    };

    private _version = _record param [
        0,
        0
    ];

    if !(_version isEqualTo 2) exitWith {
        false
    };

    private _storedUnits = _record param [
        1,
        []
    ];

    private _relativePoints = _record param [
        2,
        []
    ];

    private _formationSnapshot = _record param [
        3,
        []
    ];

    if (_relativePoints isEqualTo []) exitWith {
        false
    };

    if !(
        [
            _storedUnits,
            _currentUnits
        ] call _sameUnitSet
    ) exitWith {
        false
    };

    if (
        (count _formationSnapshot)
        isNotEqualTo
        count _storedUnits
    ) exitWith {
        false
    };

    private _matches =
        true;

    for "_unitIndex" from 0 to ((count _storedUnits) - 1) do {
        private _unit =
            _storedUnits select _unitIndex;

        if (isNull _unit) exitWith {
            _matches = false;
        };

        private _storedFormationData =
            _formationSnapshot select
                _unitIndex;

        private _currentFormationData =
            _unit getVariable [
                "A3C_FORM",
                []
            ];

        if !(
            [_storedFormationData]
            call FUNC(isValidFormationData)
        ) exitWith {
            _matches = false;
        };

        if !(
            [_currentFormationData]
            call FUNC(isValidFormationData)
        ) exitWith {
            _matches = false;
        };

        if !(
            _currentFormationData
            isEqualTo
            _storedFormationData
        ) exitWith {
            _matches = false;
        };
    };

    _matches
};

/*
    Render relative formation points.

    _showPointMarkers:
        false - exact stroke; render lines only unless no valid segment exists.
        true  - fallback slots; render lines and one marker per unit slot.
*/
private _renderRelativePoints = {
    params [
        "_relativePoints",
        "_color",
        "_collectionName",
        ["_showPointMarkers", false, [false]]
    ];

    private _gridPositions = [];

    {
        private _gridPosition = [
            _x
        ] call FUNC(getGridPositionFromRelativeData);

        if ((count _gridPosition) >= 2) then {
            _gridPositions pushBack
                _gridPosition;
        };
    } forEach _relativePoints;

    private _controls = [];

    /*
        Create thick connecting segments.
    */
    if ((count _gridPositions) > 1) then {
        for "_pointIndex" from 1 to ((count _gridPositions) - 1) do {
            private _lines = [
                _display,
                _gridPositions select (_pointIndex - 1),
                _gridPositions select _pointIndex,
                _color
            ] call FUNC(createVisualLine);

            _controls append
                _lines;
        };
    };

    if (_showPointMarkers) then {
        /*
            Fallback geometry represents actual unit slots, so every slot
            remains explicitly visible.
        */
        {
            private _dot = [
                _display,
                _x,
                _color
            ] call FUNC(createVisualDot);

            if !(isNull _dot) then {
                _controls pushBack
                    _dot;
            };
        } forEach _gridPositions;
    } else {
        /*
            An exact click or a stroke consisting entirely of duplicate
            points produces no valid line controls. Display one marker so
            the valid formation position remains visible.
        */
        if (
            (_controls isEqualTo [])
            && {
                !(_gridPositions isEqualTo [])
            }
        ) then {
            private _dot = [
                _display,
                _gridPositions select 0,
                _color
            ] call FUNC(createVisualDot);

            if !(isNull _dot) then {
                _controls pushBack
                    _dot;
            };
        };
    };

    uiNamespace setVariable [
        _collectionName,
        _controls
    ];

    !(_controls isEqualTo [])
};

/*
    First attempt to restore one exact ALL stroke.
*/
private _allStrokeRestored = false;

private _allRecord =
    _visualData getOrDefault [
        "ALL",
        []
    ];

if (
    [
        _allRecord,
        _allUnits
    ] call _recordMatchesCurrentData
) then {
    private _relativePoints =
        _allRecord param [
            2,
            []
        ];

    _allStrokeRestored = [
        _relativePoints,
        _allColor,
        _allCollectionName,
        false
    ] call _renderRelativePoints;
} else {
    if !(_allRecord isEqualTo []) then {
        _visualData deleteAt
            "ALL";
    };
};

/*
    If there is no valid ALL stroke, restore color teams separately.
*/
if !(_allStrokeRestored) then {
    {
        _x params [
            "_team",
            "_color",
            "_collectionName"
        ];

        private _teamUnits = _allUnits select {
            (
                [_x] call _getUnitTeam
            ) isEqualTo _team
        };

        private _validTeamUnits = _teamUnits select {
            private _formationData =
                _x getVariable [
                    "A3C_FORM",
                    []
                ];

            [_formationData]
            call FUNC(isValidFormationData)
        };

        private _teamRecord =
            _visualData getOrDefault [
                _team,
                []
            ];

        private _exactStrokeRestored =
            false;

        if (
            [
                _teamRecord,
                _teamUnits
            ] call _recordMatchesCurrentData
        ) then {
            private _relativePoints =
                _teamRecord param [
                    2,
                    []
                ];

            _exactStrokeRestored = [
                _relativePoints,
                _color,
                _collectionName,
                false
            ] call _renderRelativePoints;
        } else {
            if !(_teamRecord isEqualTo []) then {
                _visualData deleteAt
                    _team;
            };
        };

        /*
            Without an exact stroke, connect the actual unit slots in group
            order and keep one marker at every authoritative unit position.
        */
        if !(_exactStrokeRestored) then {
            private _slotPoints =
                _validTeamUnits apply {
                    +(
                        _x getVariable [
                            "A3C_FORM",
                            []
                        ]
                    )
                };

            [
                _slotPoints,
                _color,
                _collectionName,
                true
            ] call _renderRelativePoints;
        };
    } forEach _teamMetadata;
};

missionNamespace setVariable [
    "A3C_UI_CustomFormation_VisualData",
    _visualData
];
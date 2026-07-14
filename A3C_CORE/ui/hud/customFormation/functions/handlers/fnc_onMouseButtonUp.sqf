#include "..\..\script_component.hpp"

params [
    "_control",
    "_button",
    "_posX",
    "_posY"
];

if !(A3C_UI_CustomFormation_BOOL_isMouseUp) exitWith {};
if (_button isEqualTo 1) exitWith {};

A3C_UI_CustomFormation_BOOL_isMouseUp = false;
A3C_UI_CustomFormation_BOOL_DRAW = false;

private _selectedUnits = uiNamespace getVariable [
    "A3C_UI_CustomFormation_selectedUnits",
    []
];

private _selectedTeam = uiNamespace getVariable [
    "A3C_UI_CustomFormation_selectedTeam",
    ""
];

private _poses = uiNamespace getVariable [
    "A3C_UI_CustomFormation_Poses",
    []
];

private _relativePoints = uiNamespace getVariable [
    "A3C_UI_CustomFormation_RelativePoints",
    []
];

private _dots = uiNamespace getVariable [
    "A3C_UI_CustomFormation_Dots",
    []
];

private _selectedUnitCount =
    count _selectedUnits;

private _poseCount =
    count _poses;

private _deleteTemporaryStroke = {
    {
        if !(isNull _x) then {
            ctrlDelete _x;
        };
    } forEach _dots;

    uiNamespace setVariable [
        "A3C_UI_CustomFormation_Dots",
        []
    ];

    uiNamespace setVariable [
        "A3C_UI_CustomFormation_Poses",
        []
    ];

    uiNamespace setVariable [
        "A3C_UI_CustomFormation_RelativePoints",
        []
    ];
};

private _collectionByTeam =
    createHashMapFromArray [
        [
            "RED",
            "A3C_UI_CustomFormation_Dots_RED"
        ],
        [
            "GREEN",
            "A3C_UI_CustomFormation_Dots_GREEN"
        ],
        [
            "BLUE",
            "A3C_UI_CustomFormation_Dots_BLUE"
        ],
        [
            "YELLOW",
            "A3C_UI_CustomFormation_Dots_YELLOW"
        ],
        [
            "MAIN",
            "A3C_UI_CustomFormation_Dots_MAIN"
        ],
        [
            "ALL",
            "A3C_UI_CustomFormation_Dots_ALL"
        ]
    ];

private _dotCollectionName =
    _collectionByTeam getOrDefault [
        _selectedTeam,
        ""
    ];

/*
    Invalid stroke. Restore the previous valid visualization.
*/
if (
    (_selectedUnitCount <= 0)
    || {_poseCount <= 0}
    || {_relativePoints isEqualTo []}
    || {_dotCollectionName isEqualTo ""}
) exitWith {
    call _deleteTemporaryStroke;
    [] call FUNC(restoreFormationVisuals);
};

/*
    Calculate the length of every sampled stroke segment.
*/
private _segmentLengths = [];
private _totalLength = 0;

if (_poseCount > 1) then {
    for "_poseIndex" from 1 to (_poseCount - 1) do {
        private _previousPosition =
            _poses select (_poseIndex - 1);

        private _currentPosition =
            _poses select _poseIndex;

        private _segmentLength =
            _previousPosition distance
                _currentPosition;

        _segmentLengths pushBack
            _segmentLength;

        _totalLength =
            _totalLength
            + _segmentLength;
    };
};

/*
    Generate exactly one world position per selected unit.
*/
private _realPoses = [];

if (_selectedUnitCount isEqualTo 1) then {
    _realPoses pushBack
        +(_poses select 0);
} else {
    if (
        (_poseCount isEqualTo 1)
        || {_totalLength <= 0.001}
    ) then {
        private _singlePosition =
            +(_poses select 0);

        for "_unitIndex" from 0 to (_selectedUnitCount - 1) do {
            _realPoses pushBack
                +_singlePosition;
        };
    } else {
        private _spacing =
            _totalLength
            / (_selectedUnitCount - 1);

        for "_unitIndex" from 0 to (_selectedUnitCount - 1) do {
            private _targetDistance =
                _spacing
                * _unitIndex;

            if (
                _unitIndex
                isEqualTo
                (_selectedUnitCount - 1)
            ) then {
                _targetDistance =
                    _totalLength;
            };

            private _samplePosition =
                +(_poses select (_poseCount - 1));

            private _distanceBeforeSegment = 0;

            for "_segmentIndex" from 0 to ((count _segmentLengths) - 1) do {
                private _segmentLength =
                    _segmentLengths select
                        _segmentIndex;

                private _segmentEndDistance =
                    _distanceBeforeSegment
                    + _segmentLength;

                if (
                    (_targetDistance <= _segmentEndDistance)
                    || {
                        _segmentIndex
                        isEqualTo
                        ((count _segmentLengths) - 1)
                    }
                ) exitWith {
                    private _startPosition =
                        _poses select
                            _segmentIndex;

                    private _endPosition =
                        _poses select
                            (_segmentIndex + 1);

                    private _segmentProgress = if (
                        _segmentLength <= 0.001
                    ) then {
                        0
                    } else {
                        (
                            _targetDistance
                            - _distanceBeforeSegment
                        )
                        / _segmentLength
                    };

                    private _startZ =
                        _startPosition param [
                            2,
                            0
                        ];

                    private _endZ =
                        _endPosition param [
                            2,
                            0
                        ];

                    _samplePosition = [
                        (_startPosition select 0)
                        + (
                            (
                                (_endPosition select 0)
                                - (_startPosition select 0)
                            )
                            * _segmentProgress
                        ),

                        (_startPosition select 1)
                        + (
                            (
                                (_endPosition select 1)
                                - (_startPosition select 1)
                            )
                            * _segmentProgress
                        ),

                        _startZ
                        + (
                            (_endZ - _startZ)
                            * _segmentProgress
                        )
                    ];
                };

                _distanceBeforeSegment =
                    _segmentEndDistance;
            };

            _realPoses pushBack
                _samplePosition;
        };
    };
};

if (
    (count _realPoses)
    isNotEqualTo
    _selectedUnitCount
) exitWith {
    call _deleteTemporaryStroke;
    [] call FUNC(restoreFormationVisuals);
};

/*
    Build all assignments before modifying any unit.
*/
private _assignments = [];

{
    private _formationPosition =
        _realPoses select _forEachIndex;

    private _formationDistance =
        player distance _formationPosition;

    private _formationDirection =
        player getRelDir _formationPosition;

    _assignments pushBack [
        _x,
        [
            _formationDistance,
            _formationDirection
        ]
    ];
} forEach _selectedUnits;

private _formationActive =
    A3C_UI_CustomFormation_BOOL_formationActive;

/*
    Commit unit formation data.
*/
{
    _x params [
        "_unit",
        "_formationData"
    ];

    _unit setVariable [
        "A3C_FORM",
        _formationData,
        false
    ];

    _unit setVariable [
        "A3C_FORM_UPDATE_REQUESTED",
        _formationActive,
        false
    ];
} forEach _assignments;

/*
    Store an exact snapshot of the A3C_FORM values produced by this stroke.

    This allows restoreFormationVisuals to detect when another script has
    subsequently changed the authoritative formation data.
*/
private _formationSnapshot =
    _assignments apply {
        +(_x select 1)
    };

private _visualData = missionNamespace getVariable [
    "A3C_UI_CustomFormation_VisualData",
    createHashMap
];

if !(_visualData isEqualType createHashMap) then {
    _visualData = createHashMap;
};

if (_selectedTeam isEqualTo "ALL") then {
    /*
        An ALL stroke replaces every team-specific exact stroke.
    */
    _visualData =
        createHashMap;
} else {
    /*
        A team-specific stroke invalidates a previous ALL stroke.
    */
    _visualData deleteAt
        "ALL";
};

_visualData set [
    _selectedTeam,
    [
        2,
        +_selectedUnits,
        +_relativePoints,
        _formationSnapshot
    ]
];

missionNamespace setVariable [
    "A3C_UI_CustomFormation_VisualData",
    _visualData
];

/*
    Register the temporary controls as the current team collection.

    restoreFormationVisuals will delete these controls and perform one
    authoritative full rendering pass. This also reconstructs unaffected
    teams immediately after an ALL stroke is replaced.
*/
uiNamespace setVariable [
    _dotCollectionName,
    +_dots
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Poses",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_RelativePoints",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_saveLB",
    0
];

[] call FUNC(restoreFormationVisuals);
[] call FUNC(labelListbox);
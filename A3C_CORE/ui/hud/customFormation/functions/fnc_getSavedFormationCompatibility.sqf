#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_getSavedFormationCompatibility
//
// Evaluates whether a saved formation may be loaded into the current squad.
//
// Returns:
//     ["EXACT", ""]
//     ["ADAPTIVE", ""]
//     ["INCOMPATIBLE", reason]
//
// Version-3 save format:
//     [
//         name,
//         legacy whole-group formation data,
//         3,
//         saved team signature,
//         saved records
//     ]
//
// Signature format:
//     [
//         ["RED", 4],
//         ["GREEN", 4]
//     ]
//
// Record format:
//     [
//         team,
//         saved unit count,
//         exact relative stroke points,
//         fallback formation slots
//     ]

params [
    ["_savedEntry", [], [[]]],
    ["_currentTeamData", [], [[]]]
];

if (_currentTeamData isEqualTo []) then {
    _currentTeamData =
        [] call FUNC(getCurrentTeamData);
};

if !(_savedEntry isEqualType []) exitWith {
    [
        "INCOMPATIBLE",
        "INVALID_ENTRY"
    ]
};

private _saveVersion =
    _savedEntry param [
        2,
        0
    ];

/*
    Older saves do not contain a reliable fireteam signature.
*/
if !(_saveVersion isEqualTo 3) exitWith {
    [
        "INCOMPATIBLE",
        "LEGACY_FORMAT"
    ]
};

private _savedSignature =
    _savedEntry param [
        3,
        []
    ];

private _savedRecords =
    _savedEntry param [
        4,
        []
    ];

if (
    !(_savedSignature isEqualType [])
    || {
        _savedSignature isEqualTo []
    }
    || {
        !(_savedRecords isEqualType [])
    }
    || {
        _savedRecords isEqualTo []
    }
) exitWith {
    [
        "INCOMPATIBLE",
        "INVALID_STRUCTURE"
    ]
};

private _teamOrder = [
    "RED",
    "GREEN",
    "BLUE",
    "YELLOW",
    "MAIN"
];

/*
    Validate and normalize the saved signature.
*/
private _signatureValid = true;
private _savedTeamNames = [];

{
    if !(_x isEqualType []) exitWith {
        _signatureValid = false;
    };

    if ((count _x) < 2) exitWith {
        _signatureValid = false;
    };

    private _team =
        _x param [
            0,
            ""
        ];

    private _savedCount =
        _x param [
            1,
            -1
        ];

    if !(_team in _teamOrder) exitWith {
        _signatureValid = false;
    };

    if !(_savedCount isEqualType 0) exitWith {
        _signatureValid = false;
    };

    if (_savedCount <= 0) exitWith {
        _signatureValid = false;
    };

    if (_team in _savedTeamNames) exitWith {
        _signatureValid = false;
    };

    _savedTeamNames pushBack
        _team;
} forEach _savedSignature;

if !(_signatureValid) exitWith {
    [
        "INCOMPATIBLE",
        "INVALID_SIGNATURE"
    ]
};

private _canonicalSavedNames =
    _teamOrder select {
        _x in _savedTeamNames
    };

if !(
    _savedTeamNames
    isEqualTo
    _canonicalSavedNames
) exitWith {
    [
        "INCOMPATIBLE",
        "INVALID_SIGNATURE_ORDER"
    ]
};

private _currentSignature =
    _currentTeamData apply {
        [
            _x select 0,
            count (_x select 1)
        ]
    };

private _currentTeamNames =
    _currentSignature apply {
        _x select 0
    };

/*
    The participating fireteam set must match exactly.
*/
if !(
    _savedTeamNames
    isEqualTo
    _currentTeamNames
) exitWith {
    [
        "INCOMPATIBLE",
        "TEAM_SET_MISMATCH"
    ]
};

/*
    Validate saved records and build direct lookup by team.
*/
private _recordsValid = true;
private _recordMap =
    createHashMap;

{
    if !(_x isEqualType []) exitWith {
        _recordsValid = false;
    };

    if ((count _x) < 4) exitWith {
        _recordsValid = false;
    };

    private _recordTeam =
        _x param [
            0,
            ""
        ];

    private _savedCount =
        _x param [
            1,
            -1
        ];

    private _strokePoints =
        _x param [
            2,
            []
        ];

    private _slotPoints =
        _x param [
            3,
            []
        ];

    if !(
        _recordTeam in [
            "RED",
            "GREEN",
            "BLUE",
            "YELLOW",
            "MAIN",
            "ALL"
        ]
    ) exitWith {
        _recordsValid = false;
    };

    if !(_savedCount isEqualType 0) exitWith {
        _recordsValid = false;
    };

    if (_savedCount <= 0) exitWith {
        _recordsValid = false;
    };

    if !(_strokePoints isEqualType []) exitWith {
        _recordsValid = false;
    };

    if !(_slotPoints isEqualType []) exitWith {
        _recordsValid = false;
    };

    private _invalidStrokePoint =
        _strokePoints findIf {
            !(
                [_x] call FUNC(isValidFormationData)
            )
        };

    if (_invalidStrokePoint >= 0) exitWith {
        _recordsValid = false;
    };

    private _invalidSlotPoint =
        _slotPoints findIf {
            !(_x isEqualTo [])
            && {
                !(
                    [_x] call FUNC(isValidFormationData)
                )
            }
        };

    if (_invalidSlotPoint >= 0) exitWith {
        _recordsValid = false;
    };

    if !(
        (
            _recordMap getOrDefault [
                _recordTeam,
                []
            ]
        )
        isEqualTo
        []
    ) exitWith {
        _recordsValid = false;
    };

    _recordMap set [
        _recordTeam,
        _x
    ];
} forEach _savedRecords;

if !(_recordsValid) exitWith {
    [
        "INCOMPATIBLE",
        "INVALID_RECORD"
    ]
};

private _allRecord =
    _recordMap getOrDefault [
        "ALL",
        []
    ];

/*
    An ALL record represents the complete group as one resampleable stroke.
*/
if !(_allRecord isEqualTo []) exitWith {
    if (
        (count _savedRecords)
        isNotEqualTo
        1
    ) exitWith {
        [
            "INCOMPATIBLE",
            "MIXED_ALL_RECORD"
        ]
    };

    private _savedTotal = 0;

    {
        _savedTotal =
            _savedTotal
            + (_x select 1);
    } forEach _savedSignature;

    private _currentTotal = 0;

    {
        _currentTotal =
            _currentTotal
            + (_x select 1);
    } forEach _currentSignature;

    private _recordSavedCount =
        _allRecord select 1;

    private _strokePoints =
        _allRecord select 2;

    private _slotPoints =
        _allRecord select 3;

    if (
        _recordSavedCount
        isNotEqualTo
        _savedTotal
    ) exitWith {
        [
            "INCOMPATIBLE",
            "ALL_COUNT_MISMATCH"
        ]
    };

    private _countsMatch =
        _savedSignature
        isEqualTo
        _currentSignature;

    if (
        !_countsMatch
        && {
            _strokePoints isEqualTo []
        }
    ) exitWith {
        [
            "INCOMPATIBLE",
            "ALL_STROKE_REQUIRED"
        ]
    };

    if (
        (_strokePoints isEqualTo [])
        && {
            (count _slotPoints)
            isNotEqualTo
            _savedTotal
        }
    ) exitWith {
        [
            "INCOMPATIBLE",
            "INVALID_ALL_FALLBACK"
        ]
    };

    if (_countsMatch) then {
        [
            "EXACT",
            ""
        ]
    } else {
        [
            "ADAPTIVE",
            ""
        ]
    }
};

/*
    Team-oriented records require one record for every saved fireteam.
*/
if (
    (count _savedRecords)
    isNotEqualTo
    count _savedSignature
) exitWith {
    [
        "INCOMPATIBLE",
        "TEAM_RECORD_COUNT_MISMATCH"
    ]
};

private _compatibility =
    "EXACT";

private _compatible =
    true;

private _failureReason =
    "";

{
    if !(_compatible) exitWith {};

    _x params [
        "_team",
        "_savedCount"
    ];

    private _record =
        _recordMap getOrDefault [
            _team,
            []
        ];

    if (_record isEqualTo []) exitWith {
        _compatible = false;
        _failureReason =
            "MISSING_TEAM_RECORD";
    };

    private _recordSavedCount =
        _record select 1;

    private _strokePoints =
        _record select 2;

    private _slotPoints =
        _record select 3;

    if (
        _recordSavedCount
        isNotEqualTo
        _savedCount
    ) exitWith {
        _compatible = false;
        _failureReason =
            "TEAM_COUNT_MISMATCH";
    };

    private _currentTeamIndex =
        _currentTeamData findIf {
            (_x select 0)
            isEqualTo
            _team
        };

    if (_currentTeamIndex < 0) exitWith {
        _compatible = false;
        _failureReason =
            "MISSING_CURRENT_TEAM";
    };

    private _currentCount =
        count (
            (
                _currentTeamData
                select _currentTeamIndex
            )
            select 1
        );

    if (
        _currentCount
        isNotEqualTo
        _savedCount
    ) then {
        if (_strokePoints isEqualTo []) then {
            _compatible = false;
            _failureReason =
                "TEAM_STROKE_REQUIRED";
        } else {
            _compatibility =
                "ADAPTIVE";
        };
    } else {
        if (
            (_strokePoints isEqualTo [])
            && {
                (count _slotPoints)
                isNotEqualTo
                _savedCount
            }
        ) then {
            _compatible = false;
            _failureReason =
                "INVALID_TEAM_FALLBACK";
        };
    };
} forEach _savedSignature;

if !(_compatible) exitWith {
    [
        "INCOMPATIBLE",
        _failureReason
    ]
};

[
    _compatibility,
    ""
]
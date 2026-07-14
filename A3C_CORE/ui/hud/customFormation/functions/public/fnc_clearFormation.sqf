#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_clearFormation

/*
    Invalidate the active manager and any formationTick that may currently
    be sleeping.
*/
private _sessionId =
    (
        missionNamespace getVariable [
            "A3C_UI_CustomFormation_sessionId",
            0
        ]
    )
    + 1;

missionNamespace setVariable [
    "A3C_UI_CustomFormation_sessionId",
    _sessionId
];

missionNamespace setVariable [
    "A3C_UI_CustomFormation_VisualData",
    createHashMap
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_RelativePoints",
    []
];

private _units =
    units group player - [player];

private _customUnits = _units select {
    alive _x
    && {
        (
            _x getVariable [
                "A3C_FORM_STATE",
                "VANILLA"
            ]
        ) isEqualTo "CUSTOM"
        || {
            _x getVariable [
                "A3C_FORM_MEMBER",
                false
            ]
        }
    }
};

private _dotCollectionNames = [
    "A3C_UI_CustomFormation_Dots_RED",
    "A3C_UI_CustomFormation_Dots_GREEN",
    "A3C_UI_CustomFormation_Dots_BLUE",
    "A3C_UI_CustomFormation_Dots_YELLOW",
    "A3C_UI_CustomFormation_Dots_MAIN",
    "A3C_UI_CustomFormation_Dots_ALL"
];

{
    private _dots = uiNamespace getVariable [
        _x,
        []
    ];

    {
        ctrlDelete _x;
    } forEach _dots;

    uiNamespace setVariable [
        _x,
        []
    ];
} forEach _dotCollectionNames;

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Poses",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_saveLB",
    0
];

A3C_UI_CustomFormation_BOOL_formationActive = false;
A3C_UI_CustomFormation_BOOL_ALLOW = false;

private _activationImage = [
    "activationImage"
] call FUNC(ctrl);

private _activationButton = [
    "activationButton"
] call FUNC(ctrl);

if !(isNull _activationImage) then {
    _activationImage ctrlSetTextColor [
        1,
        0,
        0,
        1
    ];
};

if !(isNull _activationButton) then {
    _activationButton ctrlSetText
        "ACTIVATE FORMATION";
};

{
    _x setVariable [
        "A3C_FORM",
        [],
        false
    ];

    _x setVariable [
        "A3C_FORM_STATE",
        "VANILLA",
        false
    ];

    _x setVariable [
        "A3C_FORM_MEMBER",
        false,
        false
    ];

    _x setVariable [
        "A3C_FORM_UPDATE_REQUESTED",
        false,
        false
    ];

    _x setVariable [
        "A3C_FORM_LAST_INTERNAL_DESTINATION",
        [],
        false
    ];

    _x setVariable [
        "A3C_FORM_INTERNAL_ORDER_UNTIL",
        0,
        false
    ];

    _x forceSpeed -1;
} forEach _units;

/*
    Only units that were actually moving under custom-formation control are
    returned to vanilla formation.

    Detached units keep their external destination, although their stored
    custom data is cleared.
*/
if !(_customUnits isEqualTo []) then {
    _customUnits commandFollow player;
};

[] call FUNC(labelListbox);
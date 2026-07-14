#include "..\..\script_component.hpp"

params [
    "_control",
    "_button",
    "_posX",
    "_posY"
];

if (_button isEqualTo 1) exitWith {};

private _gridUnit = missionNamespace getVariable [
    "A3C_UI_CustomFormation_GridUnit",
    0
];

if (_gridUnit <= 0) exitWith {};

if (
    _posX
    >
    (0.5 + (6 * _gridUnit))
) exitWith {};

private _selectedUnits = uiNamespace getVariable [
    "A3C_UI_CustomFormation_selectedUnits",
    []
];

if (_selectedUnits isEqualTo []) exitWith {};

private _selectedTeam = uiNamespace getVariable [
    "A3C_UI_CustomFormation_selectedTeam",
    ""
];

if !(
    _selectedTeam in [
        "RED",
        "GREEN",
        "BLUE",
        "YELLOW",
        "MAIN",
        "ALL"
    ]
) exitWith {};

A3C_UI_CustomFormation_BOOL_DRAW = true;
A3C_UI_CustomFormation_BOOL_isMouseUp = true;

uiNamespace setVariable [
    "A3C_UI_CustomFormation_lineLength",
    0
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

[] call FUNC(labelListbox);

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

private _dotCollectionNames = [];

if (_selectedTeam isEqualTo "ALL") then {
    /*
        A new ALL stroke visually replaces every currently displayed
        team-specific stroke.
    */
    _dotCollectionNames = [
        "A3C_UI_CustomFormation_Dots_RED",
        "A3C_UI_CustomFormation_Dots_GREEN",
        "A3C_UI_CustomFormation_Dots_BLUE",
        "A3C_UI_CustomFormation_Dots_YELLOW",
        "A3C_UI_CustomFormation_Dots_MAIN",
        "A3C_UI_CustomFormation_Dots_ALL"
    ];
} else {
    private _teamCollection =
        _collectionByTeam getOrDefault [
            _selectedTeam,
            ""
        ];

    if !(_teamCollection isEqualTo "") then {
        _dotCollectionNames pushBack
            _teamCollection;
    };

    /*
        A successful team-specific stroke invalidates an ALL stroke.

        Hide the ALL controls while drawing. Persistent ALL geometry is not
        deleted yet, so an invalid stroke can restore it.
    */
    _dotCollectionNames pushBackUnique
        "A3C_UI_CustomFormation_Dots_ALL";
};

{
    private _dots = uiNamespace getVariable [
        _x,
        []
    ];

    {
        if !(isNull _x) then {
            ctrlDelete _x;
        };
    } forEach _dots;

    uiNamespace setVariable [
        _x,
        []
    ];
} forEach _dotCollectionNames;
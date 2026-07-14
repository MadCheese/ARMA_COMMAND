#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_configureTeamButtons
//
// Shows and positions only the team buttons relevant to the current
// group composition. The save controls and saved-formations listbox are
// moved directly below the resulting team-button block.
//
// Returns:
//     Team identifier to select initially.
//     - The single existing team when all units share one team.
//     - "ALL" when multiple teams exist.
//     - "ALL" when no subordinate units exist.

private _buttonData = [
    ["RED",    "teamRed"],
    ["GREEN",  "teamGreen"],
    ["BLUE",   "teamBlue"],
    ["YELLOW", "teamYellow"],
    ["MAIN",   "teamMain"],
    ["ALL",    "teamAll"]
];

private _teamOrder = [
    "RED",
    "GREEN",
    "BLUE",
    "YELLOW",
    "MAIN"
];

private _groupUnits =
    units player - [player];

private _availableTeams = [];

private _useAssignedTeam =
    player isEqualTo cameraOn;

{
    private _team = if (_useAssignedTeam) then {
        assignedTeam _x
    } else {
        _x getVariable [
            "A3C_ASSIGNEDTEAM",
            "MAIN"
        ]
    };

    if (_team in _teamOrder) then {
        _availableTeams pushBackUnique
            _team;
    };
} forEach _groupUnits;

private _orderedTeams =
    _teamOrder select {
        _x in _availableTeams
    };

private _initialTeam = switch (
    count _orderedTeams
) do {
    case 1: {
        _orderedTeams select 0
    };

    default {
        "ALL"
    };
};

private _visibleTeams =
    +_orderedTeams;

if ((count _orderedTeams) > 1) then {
    _visibleTeams pushBack
        "ALL";
};

private _slotControlKeys = [
    "teamRed",
    "teamGreen",
    "teamBlue",
    "teamYellow",
    "teamMain",
    "teamAll",
    "saveButton",
    "savedFormations"
];

private _slotYPositions = [];

{
    private _control = [
        _x
    ] call FUNC(ctrl);

    if (isNull _control) exitWith {};

    _slotYPositions pushBack (
        ctrlPosition _control
        select 1
    );
} forEach _slotControlKeys;

if (
    (count _slotYPositions)
    isNotEqualTo
    count _slotControlKeys
) exitWith {
    _initialTeam
};

{
    _x params [
        "",
        "_controlKey"
    ];

    private _control = [
        _controlKey
    ] call FUNC(ctrl);

    if !(isNull _control) then {
        _control ctrlShow false;
        _control ctrlEnable false;
    };
} forEach _buttonData;

private _anchorControl = [
    "teamRed"
] call FUNC(ctrl);

if (isNull _anchorControl) exitWith {
    _initialTeam
};

private _anchorPosition =
    ctrlPosition _anchorControl;

{
    private _team =
        _x;

    private _buttonIndex =
        _buttonData findIf {
            (_x select 0)
            isEqualTo
            _team
        };

    if (_buttonIndex >= 0) then {
        private _controlKey =
            (
                _buttonData
                select _buttonIndex
            )
            select 1;

        private _control = [
            _controlKey
        ] call FUNC(ctrl);

        if !(isNull _control) then {
            _control ctrlSetPosition [
                _anchorPosition select 0,
                _slotYPositions select
                    _forEachIndex,
                _anchorPosition select 2,
                _anchorPosition select 3
            ];

            _control ctrlCommit 0;
            _control ctrlEnable true;
            _control ctrlShow true;
        };
    };
} forEach _visibleTeams;

private _visibleButtonCount =
    count _visibleTeams;

/*
    SAVE occupies the slot immediately after the final visible team button.
*/
private _saveButton = [
    "saveButton"
] call FUNC(ctrl);

private _saveY = -1;

if !(isNull _saveButton) then {
    private _savePosition =
        ctrlPosition _saveButton;

    _saveY =
        _slotYPositions select
            _visibleButtonCount;

    _savePosition set [
        1,
        _saveY
    ];

    _saveButton ctrlSetPosition
        _savePosition;

    _saveButton ctrlCommit 0;
};

/*
    The management icon and its button remain beside SAVE.
*/
if (_saveY >= 0) then {
    {
        private _control = [
            _x
        ] call FUNC(ctrl);

        if !(isNull _control) then {
            private _position =
                ctrlPosition _control;

            _position set [
                1,
                _saveY
            ];

            _control ctrlSetPosition
                _position;

            _control ctrlCommit 0;
            _control ctrlShow true;
            _control ctrlEnable true;
        };
    } forEach [
        "manageImage",
        "manageButton"
    ];
};

/*
    The listbox occupies the following slot.
*/
private _savedFormations = [
    "savedFormations"
] call FUNC(ctrl);

if !(isNull _savedFormations) then {
    private _listboxPosition =
        ctrlPosition _savedFormations;

    _listboxPosition set [
        1,
        _slotYPositions select (
            _visibleButtonCount + 1
        )
    ];

    _savedFormations ctrlSetPosition
        _listboxPosition;

    _savedFormations ctrlCommit 0;
};

_initialTeam
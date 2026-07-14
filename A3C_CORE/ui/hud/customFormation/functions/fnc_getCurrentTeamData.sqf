#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_getCurrentTeamData
//
// Returns current subordinate units grouped into canonical fireteam order.
//
// Format:
//     [
//         ["RED", [unit1, unit2]],
//         ["GREEN", [unit3, unit4]]
//     ]
//
// Unit order inside each team remains the current group-unit order.

private _teamOrder = [
    "RED",
    "GREEN",
    "BLUE",
    "YELLOW",
    "MAIN"
];

private _groupUnits =
    units group player - [player];

private _useAssignedTeam =
    player isEqualTo cameraOn;

private _teamData = [];

{
    private _team =
        _x;

    private _teamUnits = _groupUnits select {
        private _assignedTeam = if (_useAssignedTeam) then {
            assignedTeam _x
        } else {
            _x getVariable [
                "A3C_ASSIGNEDTEAM",
                "MAIN"
            ]
        };

        _assignedTeam isEqualTo _team
    };

    if !(_teamUnits isEqualTo []) then {
        _teamData pushBack [
            _team,
            _teamUnits
        ];
    };
} forEach _teamOrder;

_teamData
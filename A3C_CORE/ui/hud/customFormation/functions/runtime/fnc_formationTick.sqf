#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_formationTick
//
// Advances one unit through one custom-formation update.
//
// The first invocation may only establish custom-formation control.
// It returns false in that case. The manager will call it again.
//
// Returns:
//     true  - custom destination was issued.
//     false - destination was not issued yet, or the operation is invalid.
//
// This function contains sleep and must run in scheduled context.

params [
    ["_unit", objNull, [objNull]],
    ["_sessionId", -1, [0]]
];

if (isNull _unit) exitWith {
    false
};

if !(alive _unit) exitWith {
    false
};

if (isPlayer _unit) exitWith {
    false
};

private _isCurrentSession = {
    A3C_UI_CustomFormation_BOOL_formationActive
    && {
        (
            missionNamespace getVariable [
                "A3C_UI_CustomFormation_sessionId",
                -1
            ]
        ) isEqualTo _sessionId
    }
};

if !(call _isCurrentSession) exitWith {
    false
};

private _formationData = _unit getVariable [
    "A3C_FORM",
    []
];

if !(
    [_formationData] call FUNC(isValidFormationData)
) exitWith {
    false
};

private _isFormationMember = _unit getVariable [
    "A3C_FORM_MEMBER",
    false
];

/*
    Stage 1: remove the unit from vanilla formation control and start
    the custom movement controller.

    Deliberately do not issue the custom destination during this same
    invocation. The manager will call this function again.
*/
if !(_isFormationMember) exitWith {
    doStop _unit;

    sleep 0.2;

    if !(call _isCurrentSession) exitWith {
        false
    };

    if !(alive _unit) exitWith {
        false
    };

    _unit setVariable [
        "A3C_FORM_MEMBER",
        true,
        false
    ];

    if (isMultiplayer) then {
        /*
            Preserve the legacy multiplayer takeover step.
        */
        _unit moveTo position _unit;
    } else {
        _unit doFSM [
            "A3C_CORE\fsm\doFormation.fsm",
            position _unit,
            _unit
        ];
    };

    false
};

/*
    In singleplayer, wait until the custom FSM has actually established
    SCRIPTED control. Returning false keeps the manager's update request
    alive, so it will retry on the next manager cycle.
*/
if (
    !isMultiplayer
    && {
        (currentCommand _unit)
        isNotEqualTo
        "SCRIPTED"
    }
) exitWith {
    false
};

_formationData params [
    "_formationDistance",
    "_relativeDirection"
];

private _formationDirection =
    (getDir player)
    + _relativeDirection;

private _formationPosition = player getPos [
    _formationDistance,
    _formationDirection
];

private _distance =
    _unit distance _formationPosition;

if (
    (_distance > 2)
    && {(speed player) > 10}
) then {
    _formationPosition = [
        _formationPosition,
        5,
        getDir player
    ] call BIS_fnc_relPos;
};

_distance =
    _unit distance _formationPosition;

/*
    Record the destination before issuing it.

    The manager uses this information to distinguish this scripted
    destination from a later position order issued by the player.
*/
_unit setVariable [
    "A3C_FORM_LAST_INTERNAL_DESTINATION",
    +_formationPosition,
    false
];

_unit setVariable [
    "A3C_FORM_INTERNAL_ORDER_UNTIL",
    diag_tickTime + 0.75,
    false
];

_unit moveTo _formationPosition;

if (
    (_distance < 7)
    && {(speed player) isEqualTo 0}
) then {
    _unit forceSpeed 2;
} else {
    _unit forceSpeed -1;

    if (
        (_distance < 4)
        && {(speed player) < 6}
    ) then {
        _unit forceSpeed 2;
    };
};

true
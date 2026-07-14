#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_formationTick
//
// Executes one complete custom-formation update for one unit.
//
// This function contains sleeps and must execute in scheduled context.
//
// Parameters:
//     0: Unit
//     1: Activation session ID
//     2: Force update
//        false: preserve normal command-state restrictions
//        true:  take control and issue one movement update regardless
//               of whether the player is moving

params [
    ["_unit", objNull, [objNull]],
    ["_sessionId", -1, [0]],
    ["_forceUpdate", false, [false]]
];

if (isNull _unit) exitWith {};
if !(alive _unit) exitWith {};
if (isPlayer _unit) exitWith {};

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

if !(call _isCurrentSession) exitWith {};

private _formationData = _unit getVariable [
    "A3C_FORM",
    []
];

if ((count _formationData) < 2) exitWith {};

private _formationDistance = _formationData select 0;
private _relativeDirection = _formationData select 1;

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

private _isFormationMember = _unit getVariable [
    "A3C_FORM_MEMBER",
    false
];

if !(_isFormationMember) then {
    private _destinationType =
        expectedDestination _unit select 1;

    private _canTakeControl =
        _forceUpdate
        || {
            [
                "form",
                _destinationType
            ] call BIS_fnc_inString
        };

    if (_canTakeControl) then {
        doStop _unit;
        sleep 0.2;

        if (
            (call _isCurrentSession)
            && {alive _unit}
        ) then {
            _unit setVariable [
                "A3C_FORM_MEMBER",
                true,
                false
            ];

            if (isMultiplayer) then {
                _unit moveTo position _unit;
            } else {
                _unit doFSM [
                    "A3C_CORE\fsm\doFormation.fsm",
                    position _unit,
                    _unit
                ];

                /*
                    During the forced activation update, briefly allow the
                    FSM command state to become SCRIPTED before issuing the
                    initial custom position.
                */
                if (_forceUpdate) then {
                    private _timeout = time + 1;

                    waitUntil {
                        sleep 0.01;

                        !(call _isCurrentSession)
                        || {!alive _unit}
                        || {
                            (currentCommand _unit)
                            isEqualTo
                            "SCRIPTED"
                        }
                        || {time >= _timeout}
                    };
                };
            };
        };
    };
};

if !(call _isCurrentSession) exitWith {};
if !(alive _unit) exitWith {};

_isFormationMember = _unit getVariable [
    "A3C_FORM_MEMBER",
    false
];

if (
    _isFormationMember
    && {
        _forceUpdate
        || {
            (currentCommand _unit)
            isEqualTo
            "SCRIPTED"
        }
        || {isMultiplayer}
    }
) then {
    _unit moveTo _formationPosition;
};

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
#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_activateFormation

params ["_mode"];

if (isDedicated) exitWith {};
if !(player isEqualTo leader group player) exitWith {};

private _activationImage = ["activationImage"] call FUNC(ctrl);
private _activationButton = ["activationButton"] call FUNC(ctrl);

if (A3C_UI_CustomFormation_BOOL_formationActive) then {
    A3C_UI_CustomFormation_BOOL_formationActive = false;

    if !(isNull _activationImage) then {
        _activationImage ctrlSetTextColor [1, 0, 0, 1];
    };

    if !(isNull _activationButton) then {
        _activationButton ctrlSetText "ACTIVATE FORMATION";
    };

    {
        _x setVariable ["A3C_FORM_MEMBER", false, false];
    } forEach (units player - [player]);
} else {
    A3C_UI_CustomFormation_BOOL_formationActive = true;
    A3C_UI_CustomFormation_BOOL_ALLOW = true;

    // Preserve the legacy activation-start allowance pulse.
    [] spawn {
        sleep 2;
        A3C_UI_CustomFormation_BOOL_ALLOW = false;
    };

    if !(isNull _activationImage) then {
        _activationImage ctrlSetTextColor [0, 1, 0, 1];
    };

    if !(isNull _activationButton) then {
        _activationButton ctrlSetText "DEACTIVATE FORMATION";
    };

    A3C_UI_CustomFormation_formationDirection = getDir player;

    private _units = (units player - [player]) select {
        !isPlayer _x
    };

    {
        private _formationData = _x getVariable ["A3C_FORM", []];

        if (
            (_mode isEqualTo 1)
            || {(count _formationData) isEqualTo 0}
        ) then {
            _x setVariable [
                "A3C_FORM",
                [
                    _x distance player,
                    player getRelDir _x
                ],
                false
            ];
        };
    } forEach _units;

    A3C_UI_CustomFormation_moveVar = 0;

    [] spawn {
        while {A3C_UI_CustomFormation_BOOL_formationActive} do {
            if ((speed player) isEqualTo 0) then {
                A3C_UI_CustomFormation_moveVar = 0;
            } else {
                if ([] call FUNC(getDirRange)) then {
                    A3C_UI_CustomFormation_moveVar =
                        A3C_UI_CustomFormation_moveVar + 3;
                };

                A3C_UI_CustomFormation_moveVar =
                    A3C_UI_CustomFormation_moveVar + 1;
            };

            if (A3C_UI_CustomFormation_moveVar >= 3) then {
                A3C_UI_CustomFormation_formationDirection = getDir player;
            };

            if ((speed player) isEqualTo 0) then {
                sleep 0.1;
            } else {
                sleep 0.5;
            };
        };
    };

    sleep 0.1;

    {
        [_x] spawn {
            params ["_unit"];

            if (isDedicated) exitWith {};
            if (isPlayer _unit) exitWith {};

            _unit doTarget objNull;
            _unit doWatch objNull;
            _unit lookAt objNull;

            if (isMultiplayer) then {
                doStop _unit;
                sleep 0.2;
            };

            while {
                A3C_UI_CustomFormation_BOOL_formationActive
                && {alive _unit}
            } do {
                if (
                    A3C_UI_CustomFormation_moveVar >= 3
                    || {A3C_UI_CustomFormation_BOOL_ALLOW}
                ) then {
                    private _formationData =
                        _unit getVariable ["A3C_FORM", []];

                    diag_log format [
                        "A3C_FORM %1: %2",
                        _unit,
                        _formationData
                    ];

                    if ((count _formationData) > 0) then {
                        private _formationDistance = _formationData select 0;
                        private _relativeDirection = _formationData select 1;
                        private _formationDirection =
                            (getDir player) + _relativeDirection;

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

                        _distance = _unit distance _formationPosition;

                        if (
                            (currentCommand _unit) isEqualTo "SCRIPTED"
                            || {isMultiplayer}
                        ) then {
                            if (
                                _unit getVariable [
                                    "A3C_FORM_MEMBER",
                                    false
                                ]
                            ) then {
                                _unit moveTo _formationPosition;
                            };
                        };

                        private _destinationType =
                            expectedDestination _unit select 1;

                        if (
                            [
                                "form",
                                _destinationType
                            ] call BIS_fnc_inString
                        ) then {
                            doStop _unit;
                            sleep 0.2;

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
                            };
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
                    };
                };

                if ((speed _unit) isEqualTo 0) then {
                    sleep 0.1;
                } else {
                    sleep 0.2;
                };

                if !(isNull objectParent _unit) then {
                    sleep 1.5;
                };
            };

            _unit setVariable [
                "A3C_FORM_MEMBER",
                false,
                false
            ];

            _unit forceSpeed -1;
        };
    } forEach _units;
};

// Preserve the legacy final allowance pulse for both activation and deactivation.
A3C_UI_CustomFormation_BOOL_ALLOW = true;

[] spawn {
    sleep 2;
    A3C_UI_CustomFormation_BOOL_ALLOW = false;
};
#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_formationManager
//
// One manager runs for each activation session.
//
// Responsibilities:
//     - Update CUSTOM units while the player moves.
//     - Detach CUSTOM units that receive an external position order.
//     - Re-admit DETACHED units when expectedDestination contains "form".
//     - Admit units that receive new formation data from the UI.
//     - Apply formation-data changes immediately while stationary.

params [
    ["_sessionId", -1, [0]]
];

if (isDedicated) exitWith {};

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

while {
    call _isCurrentSession
} do {
    /*
        Preserve the existing movement detector.

        While the player is stationary, moveVar remains zero. Rotating
        while stationary therefore does not continuously reposition units.
    */
    if ((speed player) isEqualTo 0) then {
        A3C_UI_CustomFormation_moveVar = 0;
    } else {
        if ([] call FUNC(getDirRange)) then {
            A3C_UI_CustomFormation_moveVar =
                A3C_UI_CustomFormation_moveVar
                + 3;
        };

        A3C_UI_CustomFormation_moveVar =
            A3C_UI_CustomFormation_moveVar
            + 1;
    };

    private _movementUpdateRequired =
        A3C_UI_CustomFormation_moveVar >= 3;

    if (_movementUpdateRequired) then {
        A3C_UI_CustomFormation_formationDirection =
            getDir player;
    };

    private _units =
        (units group player - [player]) select {
            alive _x
            && {!isPlayer _x}
        };

    {
        private _unit = _x;

        private _formationData = _unit getVariable [
            "A3C_FORM",
            []
        ];

        private _hasFormationData = [
            _formationData
        ] call FUNC(isValidFormationData);

        private _state = _unit getVariable [
            "A3C_FORM_STATE",
            "VANILLA"
        ];

        private _updateRequested = _unit getVariable [
            "A3C_FORM_UPDATE_REQUESTED",
            false
        ];

        private _expectedDestination =
            expectedDestination _unit;

        private _expectedPosition =
            _expectedDestination param [
                0,
                []
            ];

        private _planningMode = toLower (
            _expectedDestination param [
                1,
                ""
            ]
        );

        /*
            This specifically means that Arma currently considers the unit
            to be returning to or participating in vanilla formation.

            It is not the definition of a CUSTOM member.
        */
        private _returnToFormation =
            "form" in _planningMode;

        /*
            A unit with invalid or missing data cannot remain under custom
            formation control.
        */
        if !(_hasFormationData) then {
            if (
                (_state isEqualTo "CUSTOM")
                || {
                    _unit getVariable [
                        "A3C_FORM_MEMBER",
                        false
                    ]
                }
            ) then {
                _unit setVariable [
                    "A3C_FORM_MEMBER",
                    false,
                    false
                ];

                _unit forceSpeed -1;

                /*
                    The unit was being controlled by the custom system but
                    no longer has a valid custom slot. Return it to vanilla
                    formation.
                */
                [_unit] commandFollow player;
            };

            _unit setVariable [
                "A3C_FORM_STATE",
                "VANILLA",
                false
            ];

            _unit setVariable [
                "A3C_FORM_UPDATE_REQUESTED",
                false,
                false
            ];
        } else {
            switch (_state) do {
                case "DETACHED": {
                    /*
                        DETACHED units keep their designated position until:

                        1. They receive return-to-formation; or
                        2. The UI explicitly gives them new custom data.
                    */
                    if (
                        _returnToFormation
                        || {_updateRequested}
                    ) then {
                        _unit setVariable [
                            "A3C_FORM_STATE",
                            "CUSTOM",
                            false
                        ];

                        _unit setVariable [
                            "A3C_FORM_MEMBER",
                            false,
                            false
                        ];

                        _unit setVariable [
                            "A3C_FORM_UPDATE_REQUESTED",
                            true,
                            false
                        ];

                        private _tickCompleted = [
                            _unit,
                            _sessionId
                        ] call FUNC(formationTick);

                        if (_tickCompleted) then {
                            _unit setVariable [
                                "A3C_FORM_UPDATE_REQUESTED",
                                false,
                                false
                            ];
                        };
                    };
                };

                case "CUSTOM": {
                    /*
                        A return-to-formation order received while the unit
                        is already classified as CUSTOM means vanilla has
                        taken control of it.

                        Restart custom takeover and force one custom update.
                    */
                    if (_returnToFormation) then {
                        _unit setVariable [
                            "A3C_FORM_MEMBER",
                            false,
                            false
                        ];

                        _unit setVariable [
                            "A3C_FORM_UPDATE_REQUESTED",
                            true,
                            false
                        ];

                        _updateRequested = true;
                    };

                    private _isExternalPositionOrder = false;

                    /*
                        Do not interpret destination changes while a forced
                        update is pending. The custom system is still taking
                        control during that period.
                    */
                    if (
                        !_updateRequested
                        && {!_returnToFormation}
                    ) then {
                        private _lastInternalDestination =
                            _unit getVariable [
                                "A3C_FORM_LAST_INTERNAL_DESTINATION",
                                []
                            ];

                        private _internalOrderUntil =
                            _unit getVariable [
                                "A3C_FORM_INTERNAL_ORDER_UNTIL",
                                0
                            ];

                        private _hasExpectedPosition =
                            (_expectedPosition isEqualType [])
                            && {
                                (count _expectedPosition) >= 2
                            };

                        private _hasInternalDestination =
                            (_lastInternalDestination isEqualType [])
                            && {
                                (count _lastInternalDestination) >= 2
                            };

                        private _destinationChanged = false;

                        if (_hasExpectedPosition) then {
                            _destinationChanged =
                                !_hasInternalDestination
                                || {
                                    (
                                        _expectedPosition
                                        distance2D
                                        _lastInternalDestination
                                    ) > 5
                                };
                        };

                        /*
                            A designated leader position normally reports a
                            leader-planned destination.

                            The distance comparison prevents the custom
                            system's own moveTo destination from being
                            mistaken for an external order.
                        */
                        private _leaderPlanned =
                            ("leader" in _planningMode)
                            && {
                                "plan" in _planningMode
                            };

                        _isExternalPositionOrder =
                            _leaderPlanned
                            && {_destinationChanged}
                            && {
                                diag_tickTime
                                >
                                _internalOrderUntil
                            };
                    };

                    if (_isExternalPositionOrder) then {
                        /*
                            The player has tasked this unit elsewhere.

                            Stop custom updates, but do not issue commandFollow
                            or otherwise interfere with the external order.
                        */
                        _unit setVariable [
                            "A3C_FORM_STATE",
                            "DETACHED",
                            false
                        ];

                        _unit setVariable [
                            "A3C_FORM_MEMBER",
                            false,
                            false
                        ];

                        _unit setVariable [
                            "A3C_FORM_UPDATE_REQUESTED",
                            false,
                            false
                        ];

                        _unit forceSpeed -1;
                    } else {
                        if (
                            _updateRequested
                            || {_movementUpdateRequired}
                        ) then {
                            private _tickCompleted = [
                                _unit,
                                _sessionId
                            ] call FUNC(formationTick);

                            if (
                                _updateRequested
                                && {_tickCompleted}
                            ) then {
                                _unit setVariable [
                                    "A3C_FORM_UPDATE_REQUESTED",
                                    false,
                                    false
                                ];
                            };
                        };
                    };
                };

                default {
                    /*
                        VANILLA units are admitted only when the UI explicitly
                        gives them new custom data while the system is active.

                        Initial activation separately admits units that were
                        already in vanilla formation.
                    */
                    if (_updateRequested) then {
                        _unit setVariable [
                            "A3C_FORM_STATE",
                            "CUSTOM",
                            false
                        ];

                        _unit setVariable [
                            "A3C_FORM_MEMBER",
                            false,
                            false
                        ];

                        private _tickCompleted = [
                            _unit,
                            _sessionId
                        ] call FUNC(formationTick);

                        if (_tickCompleted) then {
                            _unit setVariable [
                                "A3C_FORM_UPDATE_REQUESTED",
                                false,
                                false
                            ];
                        };
                    };
                };
            };
        };
    } forEach _units;

    sleep 0.1;
};
#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_activateFormation

params ["_mode"];

if (isDedicated) exitWith {};
if !(player isEqualTo leader group player) exitWith {};

/*
    Every activation-state change receives a new session ID.

    Worker loops and scheduled formation ticks capture the ID belonging to
    their activation. Changing it immediately invalidates workers belonging
    to any previous activation.
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

private _activationImage = [
    "activationImage"
] call FUNC(ctrl);

private _activationButton = [
    "activationButton"
] call FUNC(ctrl);

if (A3C_UI_CustomFormation_BOOL_formationActive) then {
    /*
        Capture custom-formation participants before invalidating the
        active session and clearing their membership state.
    */
    private _formationUnits =
        (units group player - [player]) select {
            alive _x
            && {
                _x getVariable [
                    "A3C_FORM_MEMBER",
                    false
                ]
            }
        };

    A3C_UI_CustomFormation_BOOL_formationActive = false;

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
            "A3C_FORM_MEMBER",
            false,
            false
        ];

        _x forceSpeed -1;
    } forEach _formationUnits;

    /*
        Return only units that were participating in the custom formation
        to the standard Arma group formation.
    */
    if !(_formationUnits isEqualTo []) then {
        _formationUnits commandFollow player;
    };
} else {
    A3C_UI_CustomFormation_BOOL_formationActive = true;

    if !(isNull _activationImage) then {
        _activationImage ctrlSetTextColor [
            0,
            1,
            0,
            1
        ];
    };

    if !(isNull _activationButton) then {
        _activationButton ctrlSetText
            "DEACTIVATE FORMATION";
    };

    A3C_UI_CustomFormation_formationDirection =
        getDir player;

    private _groupUnits =
        units group player - [player];

    private _units = _groupUnits select {
        !isPlayer _x
    };

    /*
        Preserve existing custom positions. When no custom position exists,
        or mode 1 explicitly requests regeneration, use the unit's current
        relative position.
    */
    {
        private _formationData = _x getVariable [
            "A3C_FORM",
            []
        ];

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

    // /*
    //     Cancel any previous individual destinations and return the
    //     subordinates to a normal formation command state before the custom
    //     formation takes control.
    // */
    // if !(_groupUnits isEqualTo []) then {
    //     _groupUnits commandFollow player;
    // };

    A3C_UI_CustomFormation_moveVar = 0;

    /*
        Movement detector.

        This retains the existing rule:
        - stationary player: moveVar remains zero;
        - moving player: moveVar rises and enables normal formation ticks;
        - stationary rotation alone does not reposition the formation.
    */
    [_sessionId] spawn {
        params ["_sessionId"];

        while {
            A3C_UI_CustomFormation_BOOL_formationActive
            && {
                (
                    missionNamespace getVariable [
                        "A3C_UI_CustomFormation_sessionId",
                        -1
                    ]
                ) isEqualTo _sessionId
            }
        } do {
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

            if (
                A3C_UI_CustomFormation_moveVar >= 3
            ) then {
                A3C_UI_CustomFormation_formationDirection =
                    getDir player;
            };

            if ((speed player) isEqualTo 0) then {
                sleep 0.1;
            } else {
                sleep 0.5;
            };
        };
    };

    /*
        Give commandFollow one frame window to establish the standard
        formation command before each worker performs its forced initial
        custom-formation tick.
    */
    sleep 0.1;

    {
        [
            _x,
            _sessionId
        ] spawn {
            params [
                "_unit",
                "_sessionId"
            ];

            if (isDedicated) exitWith {};
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

            _unit doTarget objNull;
            _unit doWatch objNull;
            _unit lookAt objNull;

            /*
                Exactly one forced update occurs for this activation.

                It does not depend on player speed or BOOL_ALLOW. The helper
                establishes custom-formation membership and issues the
                initial custom destination.
            */
            [
                _unit,
                _sessionId,
                true
            ] call FUNC(formationTick);

            /*
                After the forced activation tick, return to the normal
                movement-dependent update behavior.

                BOOL_ALLOW remains available for explicit formation-data
                changes caused by drawing or loading a saved formation.
            */
            while {
                (call _isCurrentSession)
                && {alive _unit}
            } do {
                if (
                    A3C_UI_CustomFormation_moveVar >= 3
                    || {A3C_UI_CustomFormation_BOOL_ALLOW}
                ) then {
                    [
                        _unit,
                        _sessionId,
                        false
                    ] call FUNC(formationTick);
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

            /*
                Only the worker belonging to the current session may perform
                normal shutdown cleanup. An obsolete worker must not clear
                state belonging to a newer activation.
            */
            if (
                (
                    missionNamespace getVariable [
                        "A3C_UI_CustomFormation_sessionId",
                        -1
                    ]
                ) isEqualTo _sessionId
            ) then {
                _unit setVariable [
                    "A3C_FORM_MEMBER",
                    false,
                    false
                ];

                _unit forceSpeed -1;
            };
        };
    } forEach _units;
};
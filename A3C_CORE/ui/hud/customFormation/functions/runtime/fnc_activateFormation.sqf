#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_activateFormation

params [
    ["_mode", 0, [0]]
];

if (isDedicated) exitWith {};
if !(A3C_isPlayerLeader) exitWith {};

/*
    Every activation or deactivation invalidates the previous manager and
    any formationTick currently sleeping.
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

private _groupUnits =
    units group player - [player];

private _aiUnits = _groupUnits select {
    alive _x
    && {!isPlayer _x}
};

if (A3C_UI_CustomFormation_BOOL_formationActive) then {
    /*
        Only units currently controlled by custom formation are returned
        to vanilla formation.

        DETACHED units remain at their designated positions.
    */
    private _customUnits = _aiUnits select {
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
    };

    A3C_UI_CustomFormation_BOOL_formationActive = false;
    A3C_UI_CustomFormation_BOOL_ALLOW = false;

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

        _x forceSpeed -1;
    } forEach _customUnits;

    if !(_customUnits isEqualTo []) then {
        _customUnits commandFollow player;
    };
} else {
    A3C_UI_CustomFormation_BOOL_formationActive = true;
    A3C_UI_CustomFormation_BOOL_ALLOW = false;

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

    A3C_UI_CustomFormation_moveVar = 0;

    /*
        Mode 1 preserves the legacy ability to capture the current relative
        arrangement as custom formation data.

        Normal UI activation uses mode 0 and does not generate missing data.
    */
    if (_mode isEqualTo 1) then {
        {
            _x setVariable [
                "A3C_FORM",
                [
                    _x distance player,
                    player getRelDir _x
                ],
                false
            ];
        } forEach _aiUnits;
    };

    /*
        Initial admission.

        Valid data alone is not enough. At activation, the unit must also
        currently be in vanilla formation, identified by expectedDestination
        containing "form".

        Valid units that are currently assigned elsewhere begin DETACHED.
        Units without valid data remain VANILLA.
    */
    {
        private _unit = _x;

        private _formationData = _unit getVariable [
            "A3C_FORM",
            []
        ];

        private _hasFormationData = [
            _formationData
        ] call FUNC(isValidFormationData);

        private _planningMode = toLower (
            (expectedDestination _unit) param [
                1,
                ""
            ]
        );

        private _inVanillaFormation =
            "form" in _planningMode;

        _unit setVariable [
            "A3C_FORM_MEMBER",
            false,
            false
        ];

        _unit setVariable [
            "A3C_FORM_LAST_INTERNAL_DESTINATION",
            [],
            false
        ];

        _unit setVariable [
            "A3C_FORM_INTERNAL_ORDER_UNTIL",
            0,
            false
        ];

        _unit forceSpeed -1;

        if !(_hasFormationData) then {
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
            if (_inVanillaFormation) then {
                _unit setVariable [
                    "A3C_FORM_STATE",
                    "CUSTOM",
                    false
                ];

                /*
                    This causes the manager to perform one initial update
                    even while the player is stationary.
                */
                _unit setVariable [
                    "A3C_FORM_UPDATE_REQUESTED",
                    true,
                    false
                ];
            } else {
                _unit setVariable [
                    "A3C_FORM_STATE",
                    "DETACHED",
                    false
                ];

                _unit setVariable [
                    "A3C_FORM_UPDATE_REQUESTED",
                    false,
                    false
                ];
            };
        };
    } forEach _aiUnits;

    /*
        Activation does not call commandFollow.

        The manager only takes control of units that qualify under the rules
        above.
    */
    [_sessionId] spawn FUNC(formationManager);
};
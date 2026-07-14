#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_UI_customFormation_fnc_spawnDialog

disableSerialization;

A3C_UI_DOWNKEYS = [];

private _parentDisplay = findDisplay 46;
if (isNull _parentDisplay) exitWith {};

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Display",
    displayNull
];

/*
    Reset filtered-save state for this dialog session.
*/
uiNamespace setVariable [
    "A3C_UI_CustomFormation_saveLB",
    0
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_VisibleSaveIndices",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_RequestedSaveProfileIndex",
    -1
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_BlockedSaveCount",
    0
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_IncompatibilityHintShown",
    false
];

/*
    Reset all display-local visualization control collections.
*/
uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots_RED",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots_GREEN",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots_BLUE",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots_YELLOW",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots_MAIN",
    []
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots_ALL",
    []
];

/*
    Reset temporary drawing data.

    Persistent stroke geometry is stored separately in missionNamespace
    and must not be cleared here.
*/
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

private _display =
    _parentDisplay createDisplay
        "HUD_Formation_Menu";

if (isNull _display) exitWith {};

/*
    Preserve this legacy display reference until all dependent functions
    have been migrated to QGVAR(display).
*/
uiNamespace setVariable [
    "A3C_UI_CustomFormation_Display",
    _display
];

A3C_UI_CustomFormation_BOOL_isMouseUp = false;

private _displayHeight =
    (abs safeZoneY)
    + (safeZoneY + safeZoneH);

private _gridUnit =
    _displayHeight / 12;

/*
    Authoritative grid-unit state is stored in missionNamespace.
*/
A3C_UI_CustomFormation_GridUnit =
    _gridUnit;

private _initialTeam =
    [] call FUNC(configureTeamButtons);

[_initialTeam] call FUNC(selectTeam);

[] call FUNC(labelListbox);

/*
    Explain hidden saves once per dialog opening.
*/
private _blockedSaveCount =
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_BlockedSaveCount",
        0
    ];

private _hintShown =
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_IncompatibilityHintShown",
        false
    ];

if (
    (_blockedSaveCount > 0)
    && {!_hintShown}
) then {
    if !(isNil "MCSS_fnc_ShortHint") then {
        "Some saved formations are not compatible with the current squad configuration."
            spawn MCSS_fnc_ShortHint;
    };

    uiNamespace setVariable [
        "A3C_UI_CustomFormation_IncompatibilityHintShown",
        true
    ];
};

private _nextGridIDC =
    IDC_CUSTOM_FORMATION_GRID_START;

private _startX =
    0.5 - (6 * _gridUnit);

private _gridDotWidth =
    0.005 * (safeZoneH / safeZoneW);

private _gridDotHeight =
    0.005 * safeZoneH;

for "_gridY" from safeZoneY to (safeZoneY + safeZoneH) step _gridUnit do {
    for "_gridX" from _startX to (0.5 + (6 * _gridUnit)) step _gridUnit do {
        private _gridDot = _display ctrlCreate [
            "RscPicture",
            _nextGridIDC
        ];

        _gridDot ctrlSetPosition [
            _gridX,
            _gridY,
            _gridDotWidth,
            _gridDotHeight
        ];

        _gridDot ctrlSetText
            "#(argb,8,8,3)color(1,1,1,1)";

        /*
            Preserve the legacy string comparison. It was used because
            direct numeric comparisons did not reliably identify the center.
        */
        if (
            [str _gridX, str _gridY]
            isEqualTo
            ["0.5", "0.5"]
        ) then {
            _gridDot ctrlSetText
                "#(argb,8,8,3)color(1,0,0,1)";
        };

        _gridDot ctrlCommit 0;

        _nextGridIDC =
            _nextGridIDC + 1;
    };
};

/*
    Recreate exact recorded strokes or fallback unit-slot dots.
*/
[] call FUNC(restoreFormationVisuals);

private _activationImage = [
    "activationImage"
] call FUNC(ctrl);

private _activationButton = [
    "activationButton"
] call FUNC(ctrl);

if (A3C_UI_CustomFormation_BOOL_formationActive) then {
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
} else {
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
};
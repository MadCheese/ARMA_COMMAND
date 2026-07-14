#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [
    QGVAR(display),
    displayNull
];

if (isNull _display) exitWith {};

private _controls = createHashMapFromArray [
    [
        "mouseSurface",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_MOUSE_SURFACE
    ],

    [
        "teamRed",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_TEAM_RED
    ],
    [
        "teamGreen",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_TEAM_GREEN
    ],
    [
        "teamBlue",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_TEAM_BLUE
    ],
    [
        "teamYellow",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_TEAM_YELLOW
    ],
    [
        "teamMain",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_TEAM_MAIN
    ],
    [
        "teamAll",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_TEAM_ALL
    ],

    [
        "activationImage",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_ACTIVATION_IMAGE
    ],
    [
        "activationButton",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_ACTIVATION_BUTTON
    ],

    [
        "clearButton",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_CLEAR_BUTTON
    ],
    [
        "saveButton",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_SAVE_BUTTON
    ],
    [
        "manageImage",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_MANAGE_IMAGE
    ],
    [
        "manageButton",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_MANAGE_BUTTON
    ],
    [
        "savedFormations",
        _display displayCtrl
            IDC_CUSTOM_FORMATION_SAVED_LISTBOX
    ]
];

uiNamespace setVariable [
    QGVAR(controls),
    _controls
];
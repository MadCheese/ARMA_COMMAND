#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_UI_customFormation_fnc_onButtonClick

params [
    ["_control", controlNull, [controlNull]]
];

if (isNull _control) exitWith {};

switch (ctrlIDC _control) do {
    case IDC_CUSTOM_FORMATION_TEAM_RED: {
        ["RED"] call FUNC(selectTeam);
    };

    case IDC_CUSTOM_FORMATION_TEAM_GREEN: {
        ["GREEN"] call FUNC(selectTeam);
    };

    case IDC_CUSTOM_FORMATION_TEAM_BLUE: {
        ["BLUE"] call FUNC(selectTeam);
    };

    case IDC_CUSTOM_FORMATION_TEAM_YELLOW: {
        ["YELLOW"] call FUNC(selectTeam);
    };

    case IDC_CUSTOM_FORMATION_TEAM_MAIN: {
        ["MAIN"] call FUNC(selectTeam);
    };

    case IDC_CUSTOM_FORMATION_TEAM_ALL: {
        ["ALL"] call FUNC(selectTeam);
    };

    case IDC_CUSTOM_FORMATION_ACTIVATION_BUTTON: {
        [0] spawn FUNC(activateFormation);
    };

    case IDC_CUSTOM_FORMATION_CLEAR_BUTTON: {
        /*
            clearFormation deletes visualization controls. Execute it
            outside this button's UI event handler.
        */
        [] spawn FUNC(clearFormation);
    };

    case IDC_CUSTOM_FORMATION_MANAGE_BUTTON: {
        /*
            openSavedFormationManager may delete the dynamically created
            save-name edit control. Execute it outside this button's UI
            event handler.
        */
        [] spawn FUNC(openSavedFormationManager);
    };
};
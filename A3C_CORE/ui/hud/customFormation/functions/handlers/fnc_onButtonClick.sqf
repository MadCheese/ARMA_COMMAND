#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_control"];

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
        [] call FUNC(clearFormation);
    };
};
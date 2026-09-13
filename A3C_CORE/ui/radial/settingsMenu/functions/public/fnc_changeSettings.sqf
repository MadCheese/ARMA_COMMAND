#include "..\..\script_component.hpp"

params ["_var"];

if !(_var in [
    "A3C_SKILL_VAR",
    "A3C_NUM_VAR",
    "A3C_HUD_RES_VAR",
    "A3C_FORCERAIL_VAR",
    "A3C_HUD_LAYOUT_CORNER",
    "A3C_HUD_OBJECTS",
    "HC_GROUP_RESPONSE"
]) exitWith {};

private _newValue = !(profileNamespace getVariable [_var, false]);
profileNamespace setVariable [_var, _newValue];

switch (_var) do {
    case "A3C_SKILL_VAR": {
        if (
            _newValue
            && {
                [] call A3C_main_fnc_shouldMaxPlayerGroupSkill
            }
        ) then {
            {
                _x setSkill 1;
            } forEach (
                units group player select {
                    !isPlayer _x
                }
            );
        };
    };

    case "A3C_NUM_VAR": {
    };

    case "A3C_HUD_RES_VAR": {
    };

    case "A3C_HUD_LAYOUT_CORNER": {
        // Immediately reposition any existing squad-placement HUD controls.
        [] call A3C_UI_squadPlacement_fnc_applyLayout;
    };

    case "A3C_HUD_OBJECTS": {
    };
};

[] call FUNC(refresh);
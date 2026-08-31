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
        if (_newValue) then {
            {
                _x setSkill 1;
            } forEach units group player;

            if (isServer) then {
                A3C_isHCSkillMaxed = true;
                publicVariable "A3C_isHCSkillMaxed";
            };
        } else {
            if (isServer) then {
                A3C_isHCSkillMaxed = false;
                publicVariable "A3C_isHCSkillMaxed";
            };
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
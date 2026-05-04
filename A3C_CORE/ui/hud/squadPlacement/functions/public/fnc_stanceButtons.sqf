#include "..\..\script_component.hpp"

params ["_mode", "_btn"];

if (_mode == 0) then {
    if (_btn == 0) then {
        A3C_HUD_STANCE_MODE_TRAVEL = A3C_HUD_STANCE_MODE_TRAVEL - 1;
    } else {
        A3C_HUD_STANCE_MODE_TRAVEL = A3C_HUD_STANCE_MODE_TRAVEL + 1;
    };

    if (A3C_HUD_STANCE_MODE_TRAVEL < 0) then {
        A3C_HUD_STANCE_MODE_TRAVEL = 4;
    };

    if (A3C_HUD_STANCE_MODE_TRAVEL > 4) then {
        A3C_HUD_STANCE_MODE_TRAVEL = 0;
    };
} else {
    if (_btn == 0) then {
        A3C_HUD_STANCE_MODE_DESTINATION = A3C_HUD_STANCE_MODE_DESTINATION - 1;
    } else {
        A3C_HUD_STANCE_MODE_DESTINATION = A3C_HUD_STANCE_MODE_DESTINATION + 1;
    };

    if (A3C_HUD_STANCE_MODE_DESTINATION < 0) then {
        A3C_HUD_STANCE_MODE_DESTINATION = 4;
    };

    if (A3C_HUD_STANCE_MODE_DESTINATION > 4) then {
        A3C_HUD_STANCE_MODE_DESTINATION = 0;
    };
};

profileNamespace setVariable ["A3C_HUD_STANCE_MODE_TRAVEL", A3C_HUD_STANCE_MODE_TRAVEL];
profileNamespace setVariable ["A3C_HUD_STANCE_MODE_DESTINATION", A3C_HUD_STANCE_MODE_DESTINATION];

[_mode] call FUNC(setStance);
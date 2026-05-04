params ["_unitGhost", "_unit"];

if (isNull _unitGhost) exitWith {};
if (isNull _unit) exitWith {};

private _noChangeAnim = switch (stance _unit) do {
    case "STAND": {"A3C_anim_stand"};
    case "CROUCH": {"A3C_anim_crouch"};
    case "PRONE": {"A3C_anim_prone"};
    default {"A3C_anim_stand"};
};

private _anim = switch (A3C_HUD_STANCE_MODE_DESTINATION) do {
    case 4: {_noChangeAnim};
    case 3: {"A3C_anim_stand"};
    case 2: {"A3C_anim_stand"};
    case 1: {"A3C_anim_crouch"};
    case 0: {"A3C_anim_prone"};
    default {_noChangeAnim};
};

_unitGhost enableSimulation true;
_unitGhost switchMove _anim;
_unitGhost enableSimulation false;
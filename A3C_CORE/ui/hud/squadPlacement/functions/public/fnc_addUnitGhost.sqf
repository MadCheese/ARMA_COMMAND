#include "..\..\script_component.hpp"

params ["_unit", "_btn"];

if (isNil "A3C_is_Initialized") exitWith {
    hint "ARMA COMMAND IS INITIALIZING - STAND BY";
    waitUntil {!isNil "A3C_is_Initialized"};
    hint "ARMA COMMAND INITIALIZED";
    sleep 3;
    hint "";
};

if !(alive _unit) exitWith {
    player reveal [_unit, 4];
};

if (isPlayer _unit) exitWith {};
if !(_unit == driver (vehicle _unit)) exitWith {};

A3C_UI_squadPlacement_units pushBack _unit;

private _unitGhostType = if !(profileNamespace getVariable ["A3C_HUD_OBJECTS", false]) then {
    "MCSS_ASM_INDICATOR_F"
} else {
    "C_Soldier_VR_F"
};

private _camVic = vehicle cameraOn;

// Kept for compatibility in case this function has side effects elsewhere.
// It is no longer needed for call compile / object name injection.
[_camVic] call A3C_main_fnc_setVehicleVarname;

private _unitGhost = _unitGhostType createVehicleLocal (position _unit);

// Preserve the old globally addressable variable shape without call compile.
missionNamespace setVariable [
    format ["A3C_HUD_UnitIndicator_%1", A3C_HUD_UnitIndicatorINDEX],
    _unitGhost
];


_unitGhost setPhysicsCollisionFlag false;


_unitGhost enableSimulation false;

if (profileNamespace getVariable ["A3C_HUD_OBJECTS", false]) then {
    private _primaryWeapon = primaryWeapon _unit;
    private _secondaryWeapon = secondaryWeapon _unit;
    private _backpack = backpack _unit;
    private _headgear = headgear _unit;
    private _vest = vest _unit;

    if !(_primaryWeapon isEqualTo "") then {
        _unitGhost addWeapon _primaryWeapon;
    };

    if !(_secondaryWeapon isEqualTo "") then {
        _unitGhost addWeapon _secondaryWeapon;
    };

    if !(_backpack isEqualTo "") then {
        _unitGhost addBackpack _backpack;
    };

    if !(_headgear isEqualTo "") then {
        _unitGhost addHeadgear _headgear;
    };

    if !(_vest isEqualTo "") then {
        _unitGhost addVest _vest;
    };

    [_unitGhost, _unit] call FUNC(switchUnitGhostStance);

    _unitGhost disableCollisionWith cameraOn;
};

_unitGhost allowDamage false;
_unitGhost setVariable ["A3C_ARROW_BPOS", [0, 0], true];

A3C_UI_squadPlacement_unitGhosts pushBack _unitGhost;

_unit setVariable [
    "A3C_HUD_DATA",
    [
        _unitGhost,
        str A3C_HUD_UnitIndicator_TEXTCOUNT
    ],
    true
];

if ((count A3C_UI_squadPlacement_units) == 1) then {
    if (profileNamespace getVariable ["A3C_HUD_RES_VAR", false]) then {
        private _p1 = AGLToASL positionCameraToWorld [0, 0, 0];
        private _p2 = AGLToASL positionCameraToWorld [0, 0, 10];
        private _startDir = _p1 getDir _p2;

        A3C_FORMATION_DIR = [(_startDir - 180)] call MCSS_fnc_correctDir;
        A3C_HUD_FORM = 0;

        [0] call FUNC(formButton);
    };

    if (_unitGhostType == "MCSS_ASM_INDICATOR_F") then {
        _unitGhost setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,1,0,0.1)"];
    };
} else {
    if (_unitGhostType == "MCSS_ASM_INDICATOR_F") then {
        _unitGhost setObjectTextureGlobal [0, "#(argb,8,8,3)color(0.9,0.8,0,0.1)"];
    };
};

if ((count A3C_UI_squadPlacement_units) == 1) then {
    A3C_UI_squadPlacement_positionLoopHandle = [] spawn FUNC(positionUnitGhostsLoop);
    A3C_NUM_DIR = 0;

    if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", true]) then {
        [] call FUNC(refreshOverlay);
    };
};

A3C_HUD_UnitIndicator_TEXTCOUNT = A3C_HUD_UnitIndicator_TEXTCOUNT + 1;
A3C_HUD_UnitIndicatorINDEX = A3C_HUD_UnitIndicatorINDEX + 1;
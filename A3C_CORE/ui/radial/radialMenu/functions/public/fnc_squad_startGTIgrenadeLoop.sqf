#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_squad_startGTIgrenadeLoop

if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") exitWith {};

private _unit = objNull;

{
	private _candidateUnit = _x;

	if ({A3C_GREN_MUZZLE == _x} count (magazines _candidateUnit) > 0) exitWith {
		_unit = _candidateUnit;
		A3C_GTI_UNIT = _candidateUnit;
	};
} forEach A3C_RD_UNITS;

if (isNull _unit) exitWith {};

{
	[_x] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
} forEach A3C_UI_squadPlacement_units;

if (isNil "A3C_GREN_MUZZLE") exitWith {
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_GRENADES_BTN)
		ctrlSetToolTip "currently no items available";
};

BR_A3C_TACV_throwTheta = 45;
BR_A3C_TACV_throwTheta_Add = 0;

A3C_GREN_ALLOW_UNITSWITCH = if (count A3C_RD_UNITS == 1) then {
	false
} else {
	true
};

BR_A3C_TACV_oefId = [
	"BR_A3C_TACV_oefId",
	"onEachFrame",
	"A3C_ai_shared_fnc_gtiGrenade_onEachFrameTick"
] call BIS_fnc_addStackedEventHandler;

[] call A3C_ui_radialMenu_fnc_closeDisplay;

[
	false, //-- isBusy
	"GTI_GRENADE_SQUAD", //-- actionID
	"", //-- Hud-Icon-class
	[1, 1, 1, 0.7], //-- Hud-Icon-color
	"", //-- placer class
	"" //-- placer color-params
] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;

showCommandingMenu "";
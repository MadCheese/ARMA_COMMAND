#include "..\script_component.hpp"

uiNamespace setVariable [QGVAR(display), displayNull];
uiNamespace setVariable [QGVAR(groups), nil];
uiNamespace setVariable [QGVAR(controls), nil];


// //-- #TODO : Clean this up - works for now, but we need a clean system for closing menues
// "ENABLE" call A3C_ui_shared_fnc_toggleActionMenuAbility;
// {
// 	player groupSelectUnit [
// 		_x,
// 		false
// 	];
// } forEach units group player;

// showCommandingMenu "";

// showHUD ([true] + (shownHUD select [1, 10]));

// // A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
// // A3C_UI_HUD_3D_TAG_reposition = false;
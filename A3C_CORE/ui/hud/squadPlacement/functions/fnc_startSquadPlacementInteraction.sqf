#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\..\radial\settingsMenu\dialog_defines.hpp"

// A3C_ui_squadPlacement_fnc_startSquadPlacementInteraction


if  (!isnull findDisplay IDD_RADIAL_MENU) exitWith {};
if  (!isnull (findDisplay IDD_SETTINGS_MENU)) exitWith {};
if  (!isnull (findDisplay IDD_SQUAD_PLACEMENT_INTERACTION)) exitWith {};
if ((count A3C_UI_squadPlacement_unitGhosts) == 0) exitWith {};



if !(A3C_isPlayerLeader) exitWith {};

_data = _this select 0;
_btn = _data select 1;
_shift = _data select 2;
_ctrl = _data select 3;
_alt = _data select 4;



A3C_UI_squadPlacement_interaction_KEY_ID = [_btn,_shift,_ctrl,_alt];

with uiNameSpace do {
	A3C_UI_squadPlacement_interaction = (finddisplay 46) createDisplay "A3C_UI_squadPlacement_interaction";
};

// Position the interaction buttons and title images using the same layout.
[] call FUNC(applyLayout);

if (profileNamespace getVariable ["A3C_HUD_LAYOUT_CORNER", false]) then {
    setMousePosition [0.93, 0.93];
} else {
    setMousePosition [0.5, 0.8];
};

if (profilenamespace getvariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR",true]) then {
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 10) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_OverWrite.paa";
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 11) ctrlSetTooltip "MODE: Override Plans";
} else {
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 10) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_Add.paa";
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 11) ctrlSetTooltip "MODE: Add To Plans";
};

if (profilenamespace getvariable ["A3C_UI_squadPlacement_interactionSHOW_VAR",true]) then {
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 12) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_true.paa";
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 13) ctrlSetTooltip "UI: Shown";
} else {
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 12) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_false.paa";
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 13) ctrlSetTooltip "UI: Hidden";	
};

if (profilenamespace getvariable ["A3C_HUD_SPEED_VAR",-1] == -1) then {
	A3C_HUD_SPEED_ICON = "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 15) ctrlSetTooltip "PACE: FULL";
} else {
	A3C_HUD_SPEED_ICON = "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
	(findDisplay IDD_SQUAD_PLACEMENT_INTERACTION displayCtrl 15) ctrlSetTooltip "PACE: LIMITED";
};
{
	[_x] call A3C_UI_squadPlacement_fnc_setStance;
} foreach [0,1];

if !(profilenamespace getvariable ['A3C_UI_squadPlacement_interactionSHOW_VAR',true]) then {
	[] call A3C_UI_squadPlacement_fnc_refreshOverlay;
};

((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 10) ctrlSetText A3C_HUD_STANCE_ICON_TRAVEL;
((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 10) ctrlSetTextColor [1,1,1,1]; //A3C_HUD_STANCE_ICON_COLOR_TRAVEL;
((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 11) ctrlSetText A3C_HUD_STANCE_ICON_DESTINATION;
((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 11) ctrlSetTextColor [1,1,1,1]; // A3C_HUD_STANCE_ICON_COLOR_DESTINATION;
((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 12) ctrlSetTextColor [1,1,1,0.7];
//((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 15) ctrlSetText "A3C_CORE\ui\pictures\BG_HUD_Menu.paa";

["HUD_MENU"] call A3C_ui_shared_fnc_getBackgroundColor;
[0] call A3C_UI_squadPlacement_fnc_formButton;



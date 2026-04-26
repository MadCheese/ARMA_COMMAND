#include "..\SHARED\shared_ui_defines.hpp"

//---------------------------------------------------------------------------------------------------------
//--------------------  THIS FUNCTION IS SPAWNED EACH TIME THE OVERLAY IS OPENED  -------------------------
//---------------------------------------------------------------------------------------------------------


params ["_display"];


//---------------------------------------------------------------------------------------------
//---------- EXIT BLOCK -----------------------------------------------------------------------
//---------------------------------------------------------------------------------------------

if  (!isnull (finddisplay _display)) exitwith {};

if (isNil 'A3C_is_Initialized') exitWith {
	hint "ARMA COMMAND IS INITIALIZING - STAND BY";
	waituntil {!isNil 'A3C_is_Initialized'};
	hint "ARMA COMMAND INITIALIZED";
	sleep 3;
	hint "";
};


if (isDedicated) exitwith {};
if (isMultiplayer && isServer && !(hasInterface)) exitwith {};
if !(player == leader group player) exitwith {};

if (!isNull findDisplay 100040) exitWith {};

//-- prevent opening overlay when radial is expecting action. Note: should be added to main HUD keyDown and prevent map
//-- from opening because that would swallow the keyUp event
if (A3C_DISABLE_RADIAL) exitWith {}; 

if
(
	!isNil 'A3C_disableMapPlanning'
	&& {A3C_disableMapPlanning}
) exitWith {};

if
(
	!isNil 'A3C_restrictMapPlanning'
	&& { A3C_restrictMapPlanning }
	&& { {["A3C_Terminal", _x] call BIS_fnc_instring} count ((Items player) + (assignedItems player)) == 0 }
) exitWith {};

if (dialog && {_display == 12}) exitwith {}; //-- exit if some dialog is open
if (!visibleMap && {_display == 12}) exitWith {}; //-- only allow when map is open

//---------------------------------------------------------------------------------------------
//---------- PREPARATION ----------------------------------------------------------------------
//---------------------------------------------------------------------------------------------

//-- Hide Hud Squad-Unit-Bar
private _modifiedHud = +(shownHud);
_modifiedHud set [0,true];
_modifiedHud set [6,false];
showHud _modifiedHud;

//-- Clear any HUD unit selection
{[_x] call A3C_HUD_REMOVE_SELECTED} foreach A3C_HUD_UNITS; //-- close eventual HUD selection

{_x setMarkerAlphaLocal 0.5} foreach A3C_HC_MARKERS;
{_x setMarkerAlphaLocal 1} foreach A3C_MARKERS;

//---------------------------------------------------------------------------------------------
//---------- VALUES, BOOLS AND ARRAYS, HAVE TO BE RESET EACH TIME DIALOG IS OPENED ------------
//---------------------------------------------------------------------------------------------


A3C_UI_MAP_Overlay_VAR_isUnFolded = false; //-- closed tree because no selection
A3C_TRACKER_MARKERS = [];
A3C_USERACTION = [];

A3C_DIR = 0;
A3C_OBSV = 0;
A3C_TEMP_ACTION = ["NONE","NONE"];
A3C_TEMP_CONDITION = ["NONE","NONE"];
A3C_SELECTED_UNITS = [];
A3C_CMODE_TEMP = 0;
A3C_FORMMODE_TEMP = 0;
A3C_UNIT_01_BV = 0;
//A3C_LOOP_COUNT = 1;
A3C_WP_SPEED_TEMP = -1;
A3C_DIAG_SPACING = 4;
A3C_UNITCOUNT = ((count (units group player)) -1);

A3C_OFFSET_MARKERPOS = [];
A3C_MARKERS_TEMP = [];
A3C_WAYPOINTS_TEMP = [];
A3C_DIED_IN_PLANNING = [];
A3C_TAB_MARKERS = [];
A3C_ORDER_UNITS = [];
A3C_CLICKPOS_1 = [0,0,0];
A3C_CLICKPOS_2 = [0,0,0];
A3C_CLICKPOS_ROOT = [0,0,0];
A3C_LINECOLOR_DIAG = [A3C_UI_COLOR_BLUE,1] call A3C_UI_fnc_setOpacity;
A3C_LINECOLOR_MAP = [A3C_UI_COLOR_BLUE,A3C_OPACITY] call A3C_UI_fnc_setOpacity; //~~ check which of these vars are no longer needed

A3C_GROUP_NAMING_ACTIVE = nil;

A3C_EXITLOOP = false;

//A3C_LOOP_CONT = false;
A3C_BOOL_DISABLEMAPCTRL = false;

A3C_HC_DETONATION_BOOL = false;

A3C_MAP_BOOL_CT_EDIT_ACTIVE = false;


A3C_TEMP_WP_ID_MAIN = "";
A3C_TEMP_WP_ID_SUB = "";


A3C_TEMP_ACTION = ["NONE","NONE"];
A3C_TEMP_CONDITION = ["NONE","NONE"];

A3C_MAP_X = 0.5;
A3C_MAP_Y = 0.5;

A3C_DIAG_ACTIVE = true;

//-- close map if opened to prevent double map issues
if (_display == 100030) then {
	if (visibleMap) then {
		openMap false;
		sleep 0.2;
	};
} else {
	//-- force map to shut down briefing / diary
	processDiaryLink createDiaryLink ['Map', player, ''];
};

//---------------------------------------------------------------------------------------------
//---------- ADD UI ---------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------


//-- Create Overlay
with uiNameSpace do {
	A3C_DSP_MapOverlay = (finddisplay 46) createDisplay "A3C_DSP_MapOverlay";
	(findDisplay 12 displayCtrl 51) ctrlMapCursor ["Track", "Arrow"];
};

//-- Hide UI-elements
{(findDisplay _display displayCtrl _x) ctrlShow false;} foreach 
[
	404040, //_startBar,
	404041, //_startText,
	A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,
	8008,
	A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_1,
	A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_2,
	A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT
];

private _ceil = (ceil ((count A3C_SELECTED_UNITS) / A3C_UI_MAP_UNITBUTTONCEIL)) - 1;
if (_ceil > A3C_BUTTONPAGE_TABLET) then {
	A3C_BUTTONPAGE_TABLET = 0; //~~ no longer needed?
};



//-- label unit selection tree
[_display] call A3C_UI_MAP_TREE_LABEL; //-- can take long depending on amount of commanded units



private _ct_tree = findDisplay _display displayCtrl IDC_SHARED_UI_TREE_SELECTOR;

//-- overlay step 1: spawn Selector Box
if (_display == 100020 && {!visibleMap}) exitWith {(findDisplay _display) closeDisplay 0};
[_display,"INF"] call A3C_UI_MAP_Overlay_ResizeTeamColorsXWH;
sleep 0.1;

//-- overlay step 2: closed sidebar (waypoint settings)
["COLLAPSE",0] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;

//-- overlay step 3: adjust upper-tree buttons
sleep 0.1;


//-- overlay step 4: edit button settings (in the background)

if (A3C_SELECTED_UNITS isEqualTo []) then {
	["INF"] call A3C_START_TABMODE;
};







[0] call A3C_UI_MAP_FNC_ResetMapClick;


//-- #Unclear - is this necessary? seems to be the little rscCombo?
lbClear (findDisplay _display displayCtrl 8004);
{
	[findDisplay _display displayCtrl 8095, _x] call A3C_addLbEntry;
} foreach ["None","A","B","C","D"];


//-- create enemy force tracker
[] spawn A3C_UI_MAP_FNC_createEnemyForceTracker;

//-- disable Action-Menu2
{inGameUISetEventHandler [_x, "true"]} foreach ["PrevAction","NextAction"];


[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];

{_x setvariable ["A3C_SYNC_PARTNERS",[],true]} foreach units group player;





// //-- Precaution: warn player if he is effectiveCommander of his vehicle while using the tablet
// //-- > when player is commanding a vehicle, A3's engine will issue movement orders unless ALT is held down
// private _inVehicle = false;
// {
// 	if !(_x == (vehicle _x)) then {
// 		if (_x == (driver (vehicle _x))) then {
// 			if (player == (effectivecommander (vehicle _x))) then {
// 				if !(player == (driver (vehicle player))) then {
// 					_inVehicle = true;
// 				};
// 			};
// 		};
// 	};
// } foreach units group player;




[_display] execFSM "A3C_CORE\FSM\A3C_MON_MAPTAB.fsm";












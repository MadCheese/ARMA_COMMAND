// #include "defines.hpp"

private ["_hudStatus"];


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
if (BR_A3C_DISABLE_RADIAL) exitWith {};

_display = _this select 0;

private _exit = false;

if (!isNil 'A3C_restrictMapPlanning') then {
	if (A3C_restrictMapPlanning) then {
		if ({["A3C_Terminal", _x] call BIS_fnc_instring} count ((Items player) + (assignedItems player)) == 0) then {
			_exit = true;
		};
	};
};

if (!isNil 'A3C_disableMapPlanning') then {
	if (A3C_disableMapPlanning) then {
		_exit = true;
	};
};

if (_exit) exitWith {};


{[_x] call A3C_HUD_REMOVE_SELECTED} foreach A3C_HUD_UNITS; //-- close eventual HUD selection

_tD = if (_display == 12) then {100020} else {_display};

if  (!isnull (finddisplay _display)) exitwith {};

_originalHud = +(shownHud);
_originalHud set [0,true];
_originalHud set [6,A3C_SHOWNHUD];

//playSound3D ["A3\Sounds_F\sfx\blip1.wss", player];

//---------------------------------------------------------------------------------------------------------
//--------------------  THIS FUNCTION IS SPAWNED EACH TIME THE TABLET IS OPENED  --------------------------
//---------------------------------------------------------------------------------------------------------

if (dialog && {_display == 12}) exitwith {};
if (!visibleMap && {_display == 12}) exitWith {};

A3C_UI_MAP_Overlay_VAR_isUnFolded = false; //-- closed tree because no selection

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
A3C_TRACKER_MARKERS = [];
A3C_USERACTION = [];



//---------------------------------------------------------------------------------------------
//---------- VALUES, BOOLS AND ARRAYS, HAVE TO BE RESET EACH TIME DIALOG IS OPENED ------------
//---------------------------------------------------------------------------------------------

_formDir = 0;
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
A3C_LINECOLOR_DIAG = [A3C_UI_COLOR_BLUE,1] call A3C_UI_Color_setOpacity;
A3C_LINECOLOR_MAP = [A3C_UI_COLOR_BLUE,A3C_OPACITY] call A3C_UI_Color_setOpacity; //~~ check which of these vars are no longer needed

A3C_GROUP_NAMING_ACTIVE = nil;

_exit = false;
A3C_EXITLOOP = false;

//A3C_LOOP_CONT = false;
A3C_BOOL_DISABLEMAPCTRL = false;

A3C_HC_DETONATION_BOOL = false;

A3C_MAP_BOOL_CT_EDIT_ACTIVE = false;


A3C_TEMP_WP_ID_MAIN = "";
A3C_TEMP_WP_ID_SUB = "";


A3C_TEMP_ACTION = ["NONE","NONE"];
A3C_TEMP_CONDITION = ["NONE","NONE"];

//if (true) exitWith {};

{_x setMarkerAlphaLocal 0.5} foreach A3C_HC_MARKERS;
{_x setMarkerAlphaLocal 1} foreach A3C_MARKERS;


/*
//-- Remove dead/nul units from BEGINNING of A3C-Group-Data
_unitArray = (profileNamespace getvariable "A3C_GROUPUNITS");
for [{_i=  ((count _unitArray) -1)},{_i>=0},{_i=_i-1}] do {
	if (_i >= 0 && {_i < (count _unitArray)}) then {
		private _u = _unitArray select _i;
		
		if (!isnull _u && {alive _u}) then {
			_exit = true;
		} else {
			_unitArray = _unitArray - [_u];
		};
	};
	if (_exit) exitwith {};	
};
profileNamespace setvariable ["A3C_GROUPUNITS",_unitArray];
*/

//--------------------- Create Tablet-Interface. Center Map on player -------------------------
//---------------------------------------------------------------------------------------------


A3C_MAP_X = 0.5;
A3C_MAP_Y = 0.5;


////////////////// -- ADD UI
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////



with uiNameSpace do {

	if (_display == 100030) then {

		A3C_TABLET = (finddisplay 46) createDisplay "A3C_SWPDIALOG";
		(findDisplay 100030 displayCtrl 7043) ctrlAddEventHandler
		[
			"Draw",
			{
				_this call MAP_UI_fnc_drawMapUI;
			}
		];

		if (["tactical",goggles player] call BIS_fnc_instring) then {
			(findDisplay 100030 displayCtrl 10) ctrlSetText "";
			(findDisplay 100030 displayCtrl 7043) ctrlSetBackgroundColor [0.9, 0.9, 0.9, 0.5];
		} else {
			(findDisplay 100030 displayCtrl 10) ctrlSetText (profileNameSpace getVariable "A3C_TABLET_IMG");
			(findDisplay 100030 displayCtrl 7043) ctrlSetBackgroundColor [0.9, 0.9, 0.9, 1];
		};
	} else {
		_hudStatus = shownHud;
		if (_hudStatus select 6) then {
			_newStatus = _hudStatus;
			_newStatus set [6,false];
			showHud _newStatus;
		};
//systemchat '1';
		A3C_MAP = (finddisplay 46) createDisplay "A3C_MAPDIALOG";
		(findDisplay 12 displayCtrl 51) ctrlMapCursor ["Track", "Arrow"];
	};

	//(findDisplay _display displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;

};

//-- Hide UI-elements
{(findDisplay _display displayCtrl _x) ctrlShow false;} foreach 
[
	404040, //_startBar,
	404041, //_startText,
	A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT,
	A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_1,
	A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_2
];





_ceil = (ceil ((count A3C_SELECTED_UNITS) / A3C_UI_MAP_UNITBUTTONCEIL)) - 1;
if (_ceil > A3C_BUTTONPAGE_TABLET) then {
	A3C_BUTTONPAGE_TABLET = 0; //~~ no longer needed?
};




[_display] call A3C_UI_MAP_TREE_LABEL; //-- can take long depending on amount of commanded units



private _ct_tree = findDisplay _display displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL;
//-- overlay step 1: spawn Selector Box


if (_display == 100020 && {!visibleMap}) exitWith {(findDisplay _display) closeDisplay 0};

[_display,"INF"] call A3C_UI_MAP_Overlay_ResizeTeamColorsXWH;
sleep 0.1;


//systemchat '5';
//-- overlay step 2: closed sidebar (waypoint settings)

["COLLAPSE",0] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;
//-- overlay step 3: adjust upper-tree buttons
sleep 0.1;

//systemchat '6';

//-- overlay step 4: edit button settings (in the background)



if (A3C_SELECTED_UNITS isEqualTo []) then {
	["INF"] call A3C_START_TABMODE;
};







[0] call A3C_UI_MAP_FNC_ResetMapClick;



lbClear (findDisplay _display displayCtrl 8004);
{
	[findDisplay _display displayCtrl 8095, _x] call A3C_addLbEntry;
} foreach ["None","A","B","C","D"];

A3C_DIAG_ACTIVE = true;

[] spawn A3C_CREATE_TRACKER;

//-- disable Action-Menu2
{inGameUISetEventHandler [_x, "true"]} foreach ["PrevAction","NextAction"];







///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


A3C_TAB_KEY_U = (findDisplay _display) displayAddEventHandler
[
	"KeyUp",
	{
		_btn1 = _this select 1;
		_shift = _this select 2;
		_ctrl = _this select 3;
		_alt = _this select 4;
		//if (_btn1 == 42) then {
		//	A3C_BUTTON_SHIFT = false;
		//};
		//if !(isnull (finddisplay 100020)) then {
			//-- shift and ctrl checks - otherwise not available. CTRL does not fire from OVERLAY so it happens here instead
			if (_btn1 == 42) then { 
				A3C_MODIFIER_SHIFT = false; //-- needed for UI (TREE EH's do not do CTL/SHIFT)
			};
			
			if (_btn1 == 29) then {
				A3C_MODIFIER_CTRL = false; //-- needed for UI (TREE EH's do not do CTL/SHIFT)
			};
		//};
		//systemchat str ["UP",_btn1,_shift,_ctrl];
		A3C_DOWNKEYS = A3C_DOWNKEYS -  [_btn1];
	}
];





//-- Precaution: MouseButtonUp-handler will additionally remove leftOver "mouseMoving"-handler (drag)
A3C_BU_SAFE = (findDisplay _display displayCtrl 7043) ctrlAddEventHandler
[
	"MouseButtonUP",
	{
		if !(isnil 'A3C_BU2') then {
			(findDisplay _display displayCtrl 7043) ctrlRemoveEventHandler ['MouseMoving',A3C_BU2];
		};
	}
];






///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];

{_x setvariable ["A3C_SYNC_PARTNERS",[],true]} foreach units group player;





//-- Precaution: warn player if he is effectiveCommander of his vehicle while using the tablet
//-- > when player is commanding a vehicle, A3's engine will issue movement orders unless ALT is held down
_inVehicle = false;
{
	if !(_x == (vehicle _x)) then {
		if (_x == (driver (vehicle _x))) then {
			if (player == (effectivecommander (vehicle _x))) then {
				if !(player == (driver (vehicle player))) then {
					_inVehicle = true;
				};
			};
		};
	};
} foreach units group player;


{
	(findDisplay _display displayCtrl _x) ctrlShow false;
} foreach [A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT];

[_display,_originalHud] execFSM "A3C_CORE\FSM\A3C_MON_MAPTAB.fsm";












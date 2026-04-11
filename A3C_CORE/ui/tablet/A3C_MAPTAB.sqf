#include "defines.hpp"

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

if (!isNull findDisplay 7999) exitWith {};
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

_tD = if (_display == 12) then {6998} else {_display};

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

A3C_MAPTAB_OVERLAY_isUnFolded = false; //-- closed tree because no selection

//-- close map if opened to prevent double map issues
if (_display == 6999) then {
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

A3C_GROUP_NAMEING_ACTIVE = nil;

_exit = false;
A3C_EXITLOOP = false;

//A3C_LOOP_CONT = false;
A3C_BOOL_DISABLEMAPCTRL = false;

A3C_HC_DETONATION_BOOL = false;

A3C_MAP_BOOL_CT = false;


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

	if (_display == 6999) then {

		A3C_TABLET = (finddisplay 46) createDisplay "A3C_SWPDIALOG";
		(findDisplay 6999 displayCtrl 7043) ctrlAddEventHandler
		[
			"Draw",
			{
				_this call A3C_MAPTAB_fnc_drawMapUI;
			}
		];

		if (["tactical",goggles player] call BIS_fnc_instring) then {
			(findDisplay 6999 displayCtrl 10) ctrlSetText "";
			(findDisplay 6999 displayCtrl 7043) ctrlSetBackgroundColor [0.9, 0.9, 0.9, 0.5];
		} else {
			(findDisplay 6999 displayCtrl 10) ctrlSetText (profileNameSpace getVariable "A3C_TABLET_IMG");
			(findDisplay 6999 displayCtrl 7043) ctrlSetBackgroundColor [0.9, 0.9, 0.9, 1];
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

	//(findDisplay _display displayCtrl 303030) ctrlShow false;

};

//-- Hide UI-elements
{(findDisplay _display displayCtrl _x) ctrlShow false;} foreach 
[
	404040, //_startBar,
	404041, //_startText,
	A3C_RC_Context,
	A3C_RC_Context_HC_WP,
	A3C_HC_GROUP_MENU_CTRLPARENT,
	A3C_ObjectSelector_Parent,
	PRNT_ACTION_SUBSET_1,
	PRNT_ACTION_SUBSET_2,
	MAP_BG_SUB_BG_1,
	MAP_BG_SUB_BG_2
];


//_startBar = findDisplay _display displayCtrl 404040;
//_startText = findDisplay _display displayCtrl 404041;
//{
//	_x ctrlShow false;
//} foreach [_startBar,_startText];



_ceil = (ceil ((count A3C_SELECTED_UNITS) / A3C_MAPTAB_UNITBUTTONCEIL)) - 1;
if (_ceil > A3C_BUTTONPAGE_TABLET) then {
	A3C_BUTTONPAGE_TABLET = 0; //~~ no longer needed?
};

A3C_TAB_KEY_D = (findDisplay _display) displayAddEventHandler
[
	"KeyDown",
	{
		_btn1 = _this select 1;
		_shift = _this select 2;
		_ctrl = _this select 3;
		_alt = _this select 4;
		
		if (_btn1 in A3C_HUD_DOWNKEYS) exitwith {};

		A3C_HUD_DOWNKEYS pushbackUnique _btn1;
		if (_this call A3C_isMapClosed) exitwith {};
		if (_this call A3C_isOverlayClosed) exitwith {};
		//A3C_BUTTON_SHIFT = _shift;

		//A3C_HUD_DOWNKEYS = A3C_HUD_DOWNKEYS - [_btn1];
		//-- input is OPEN/CLOSE TABLET. -> close tablet.
		if ([_btn1,_shift,_ctrl,_alt] isEqualTo A3C_TAB_KEY_ID) exitWith {
			A3C_HUD_DOWNKEYS = A3C_HUD_DOWNKEYS - [_btn1];
			(findDisplay _display) displayRemoveEventHandler ["KeyDown", A3C_TAB_KEY_D];
			[] call A3C_Btn_fnc_Cancel;
		};

		//-- close map: overlay part (partner edition in map EH)
		if (_btn1 in ([1] + (actionKeys "hidemap"))) then {
			if (isNil "A3C_GROUP_NAMEING_ACTIVE") then {
				openMap false;
				[6998] call A3C_Close_Map_Overlay;
			};	
		};

		



		if (_btn1 == 207) exitWith {
			getMousePosition params ["_sX","_sY"];
			_wpIcons = (["HC_WP",_sx,_sy] call A3C_MAP_iconsAtMapPos);
			if (count _wpIcons > 0) then {
				_wpIcon = _wpIcons select 0;
				_gp = _wpIcon select 0;
				_wpiC = _wpIcon select 3;
				_exit = true; //~~ sure?
				[_gp, _wpiC] call A3C_HC_REMOVE_WP_RC;
			};

		};
		//contents of former A3C_TAB_F_KEYDOWN
		private ["_teamcolor","_exit","_alt"];
		_btn = _this select 1;
		_gpUnits = ((units group player) - [player]);
		_unitCount = count _gpUnits;
		if (_unitCount > 9) then {_unitCount = 9};
		_teamColor = "MAIN";
		_colorTeamUnits = [];
		if (A3C_MAP_BOOL_CT) exitWith {};
		//if (A3C_BOOL_CT_SPACING) exitwith {};
		if (_btn == 2 && {commandingMenu == ""}) exitwith {
			if !(A3C_HELI_INF_MODE == "INF") then {
				A3C_SELECTED_UNITS = [];
			};

			["INF"] call A3C_START_TABMODE;
			A3C_HELI_INF_MODE = "INF";
		};
		if (_btn == 3 && {commandingMenu == ""}) exitwith {
			if !(A3C_HELI_INF_MODE == "AIR") then {
				A3C_SELECTED_UNITS = [];
			};

			["AIR"] call A3C_START_TABMODE;
			A3C_HELI_INF_MODE = "AIR";
		};
		if (_btn == 4 && {commandingMenu == ""}) exitwith {
			if !(A3C_HELI_INF_MODE == "HC") then {
				A3C_SELECTED_UNITS = [];
			};

			["HC"] call A3C_START_TABMODE;
			A3C_HELI_INF_MODE = "HC";
		};

		if (_btn1 == 42) then { 
			A3C_MODIFIER_SHIFT = true; //-- needed for UI (TREE EH's do not do CTL/SHIFT)
		};
		
		if (_btn1 == 29) then {
			A3C_MODIFIER_CTRL = true; //-- needed for UI (TREE EH's do not do CTL/SHIFT)
		};

		/*
		
		_exit = true; // -- TEMP FIX  || Unused after here ///!!!!!!!!!!!!!!

		if (_exit) exitwith {};  

		//-- shorten range of acceptable keystrokes
		if ( (_btn < 59) OR (_btn > 68) ) then {
			if !(_btn == 41) then {
				_exit = true;
			};
		};

		
		//-- .. F1 Key : Selects all units 2-10
		if (_btn == 41) exitwith {};

		_subtractor = 59;
		if (A3C_MODIFIER_CTRL) then {_subtractor = 49};
		_unit = ( (profileNamespace getvariable "A3C_GROUPUNITS") select (_btn - _subtractor) );
		if (isPlayer _unit) exitWith {};
		if !(alive _unit) exitwith {}; // necessary?
		_unitIndex = (_btn - 58); // necessary? better use formation index function?
		_arrowIndex = 0;
		nul = [0,(_btn - _subtractor),(_this select 2),(_this select 3),(_this select 4)] call A3C_BTN_SELECT_UNIT;

		[] spawn {sleep 0.01; showcommandingmenu "";{player groupSelectUnit [_x,false];} foreach groupselectedunits player;};
		*/
	}
];

//sleep 3;


[_display] call A3C_MAPTAB_TREE_LABEL; //-- can take long depending on amount of commanded units



private _ct_tree = findDisplay _display displayCtrl A3C_SELECTOR_TREE;
//-- overlay step 1: spawn Selector Box


if (_display == 6998 && {!visibleMap}) exitWith {(findDisplay _display) closeDisplay 0};
//systemchat '4';
[_display,"INF"] call A3C_MAPTAB_RESIZE_TEAMCOLORS_XWH;
sleep 0.1;


//systemchat '5';
//-- overlay step 2: closed sidebar (waypoint settings)

["COLLAPSE",0] call A3C_MAPTAB_OVERLAY_TOGGLE_FOLD;
//-- overlay step 3: adjust upper-tree buttons
sleep 0.1;

//systemchat '6';

//-- overlay step 4: edit button settings (in the background)



if (A3C_SELECTED_UNITS isEqualTo []) then {
	["INF"] call A3C_START_TABMODE;
};







[0] call A3C_MAP_ResetMapClick;



lbClear (findDisplay _display displayCtrl 8004);
{
	[findDisplay _display displayCtrl 8095, _x] call A3C_addLbEntry;
} foreach ["None","A","B","C","D"];

A3C_DIAG_ACTIVE = true;

[] spawn A3C_CREATE_TRACKER;

//-- disable Action-Menu2
{inGameUISetEventHandler [_x, "true"]} foreach ["PrevAction","NextAction"];


/*
//-- Add main MouseButton-Down-Event
if !(isNull findDisplay 6999) then {

	A3C_BU0 = (findDisplay _display displayCtrl 7043) ctrlAddEventHandler
	[
		"MouseButtonDown",
		{	//with uiNameSpace do {
				_this spawn A3C_TAB_UI_Handlers_OnMouseButtonDown;
			//};
		}
	];
	A3C_BU1 = (findDisplay _display displayCtrl 7043) ctrlAddEventHandler
	[
		"MouseButtonUP",
		{
			_this spawn A3C_TAB_UI_Handlers_OnMouseButtonUp;
			A3C_BOOL_MOUSEMOVING = false;
		}
	];
	A3C_BU2 = (findDisplay _display displayCtrl 7043) ctrlAddEventHandler
	[
		'MouseMoving',
		{
			A3C_MAP_X = _this select 1;
			A3C_MAP_Y = _this select 2;
			if (A3C_MapSel_Field_Active) then {
				A3C_MapSel_Field_DEST = (findDisplay 6999 displayCtrl 7043) posscreentoworld [A3C_MAP_X,A3C_MAP_Y];
			};
			//systemchat str A3C_MAP_X;
			if (A3C_BOOL_MOUSEMOVING) then {
				_this spawn A3C_MMCode
			};
		}
	];
	//-- Main Tablet "keyDown"-Handler (no need to name as it is destroyed with the dialog .(A3C_TAB_KEY_D = )
	
};

*/




////////////////////////////       NEW BUTTONS !!!!!!!! ///////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

//player setGroupID ["GODFATHER"];
















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
		//if !(isnull (finddisplay 6998)) then {
			//-- shift and ctrl checks - otherwise not available. CTRL does not fire from OVERLAY so it happens here instead
			if (_btn1 == 42) then { 
				A3C_MODIFIER_SHIFT = false; //-- needed for UI (TREE EH's do not do CTL/SHIFT)
			};
			
			if (_btn1 == 29) then {
				A3C_MODIFIER_CTRL = false; //-- needed for UI (TREE EH's do not do CTL/SHIFT)
			};
		//};
		//systemchat str ["UP",_btn1,_shift,_ctrl];
		A3C_HUD_DOWNKEYS = A3C_HUD_DOWNKEYS -  [_btn1];
	}
];





//-- Precaution: MouseButtonUp-handler will additionally remove leftOver "mouseMoving"-handler (drag)
A3C_BU_SAFE = (findDisplay _display displayCtrl 7043) ctrlAddEventHandler
[
	"MouseButtonUP",
	"
		if !(isnil 'A3C_BU2') then {
			(findDisplay _display displayCtrl 7043) ctrlRemoveEventHandler ['MouseMoving',A3C_BU2];
		};
	"
];


//-- Precation: player may get killed during WIP
//A3C_KILLED_WIP = player addEventHandler
//[
//	"killed",
//	{
//		A3C_SELECTED_UNITS = [];
//		[] call A3C_Btn_fnc_Cancel;
//		{_x setvariable ["A3C_PLOT_TEMP",[],true];} foreach units group player;
//		(_this select 0) removeEventHandler ["killed", A3C_KILLED_WIP];
//	}
//];

//-- center map on player, set FOV
//(findDisplay _display displayCtrl 7043) ctrlMapAnimAdd [0, 0.05, position player];
//ctrlMapAnimCommit (findDisplay _display displayCtrl 7043);










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
} foreach [A3C_RC_Context,A3C_RC_Context_HC_WP];

[_display,_originalHud] execFSM "A3C_CORE\FSM\A3C_MON_MAPTAB.fsm";












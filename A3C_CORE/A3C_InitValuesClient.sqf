#include "ui\mapOverlay\dialog_defines.hpp"

//----------------------------- playerVariables
A3C_CurrentPlayerObject = player;
A3C_UNITCOUNTER =  (count (units group player));
A3C_PLAYERGROUP = group player;
A3C_UNITCOUNT = ((count (units group player)) -1);
A3C_isPlayerLeader = player == leader group player;

//----------------------------- Supported Addon Variables
A3C_IsTAO = if (isClass(configFile/"CfgPatches"/"tao_foldmap_a3")) then {true} else {false}; //-- detect if TAO Folding Map is running
A3C_LaxMount = if (isClass(configFile/"CfgPatches"/"L_MOUNT")) then {true} else {false}; //-- detect if L-MOUNT is running



//----------------------------- profileNameSpace Variables
//-- A3C Version Check:
//checks the current version of A3C and hints if new version is detected
with profilenamespace do {
	_giveHint = false;
	if (isnil "A3C_CHECKVERSION") then {
		_giveHint = true;
		profileNameSpace setvariable ["A3C_CHECKVERSION","BUILD 1.0.0.02"];
	} else {
		if !( (profileNameSpace getvariable "A3C_CHECKVERSION") == "BUILD 1.0.0.02") then {
			_giveHint = true;
			profileNameSpace setvariable ["A3C_CHECKVERSION","BUILD 1.0.0.02"];
		};
	};

	if (_giveHint) then {
		[] spawn {
			waituntil {alive player};
			"ARMA COMMAND DLC" hintC [
				"You are playing a new build (#1.0.0.02) for the first time!",
				"Please refer to the changelog (STEAM or DISCORD)        ",
				">>>>>>>   NEWS:   <<<<<<<                               ",
				"1.0.0.02"
			];		
		};	
	};
};

//----------------------------- UI VARIABLES
//----------------------------- Main Display Variables

A3C_UI_HUD_3D_TAGGING = false;



//-- #TODO: MESSY STUFF TO OVERHAUL 
if (A3C_IsAICommand) then {
	["AICommand",player] remoteExec ["A3C_checkserverAddon",2];
};

//-- check for supported serverSide Addons
{
	[_x,player] remoteExec ["A3C_checkserverAddon",2];
} foreach ["AR_AdvancedRappelling","A3C_UI"];
















A3C_GREN_MUZZLE = "";
A3C_GREN_ALLOW_UNITSWITCH = false;




A3C_Selection_MultiWaypoint = [];




//----------------  V A L U E S   A N D   A R R A Y S   F O R   P L A N N I N G   M O D E  -------------
//------------------------------------------------------------------------------------------------------







A3C_UI_SHARED_TREE_HC_AT_TICK = [];


A3C_OBJECTPLACER = objNull;
A3C_OBJECTPLACER_DIR = 180;


A3C_TICKTIME_MoveMark = time;
A3C_BOOL_MOVINGMARKER = false;
//A3C_DIAG_ACTIVE = false;
//A3C_PLOT_ACTIVE = false;
//A3C_CTRL_ACTIVE = false;
A3C_SYNC_ABORT = false;

A3C_CurSel = false;

A3C_TAB_BUILDING_BOOL = false;
A3C_BOOL_MOVINGHC = false;
A3C_BOOL_CT_SPACING = false;
A3C_BOOL_DISABLEMAPCTRL = false;
A3C_BOOL_LOOPING = false;
A3C_BOOL_MAP_MD = false;
A3C_BOOL_MAP_MU = false;
A3C_BOOL_MAPFORCE = true;
A3C_STATE_CHECKING_PICKUP = false;

A3C_isMergeGroupActive = false;

A3C_LAST_SUBSET_ACTION = "NONE";

A3C_ENGAGEDTARGETS = [];

A3C_PICKUP_OBJECTS = [];
A3C_PICKUP_MARKERS = [];

A3C_TAB_MARKERS = [];
A3C_LINE_ID = 1;
A3C_MARKER_COUNT = 0;
A3C_SYNC_INDEX = 1;
A3C_VARNAME_INDEX  = 0;
A3C_USERACTION_ID = 0;
A3C_BUTTONPAGE_TABLET = 0;
A3C_DIFFICULTY = difficulty;
A3C_OPACITY = if (profilenamespace getvariable ["A3C_MAP_OVERLAY_SHOWN",true]) then {1} else {0};
A3C_TAB_TOGGLE_VAR = 0;
A3C_TRACKER_VISIBLE = 1;
A3C_TEMP_ACTION = ["NONE","NONE"];
A3C_TEMP_CONDITION = ["NONE","NONE"];





A3C_assign_action_playerToVehicle = -1000;


A3C_TIMEOUT_VAL = 15;
A3C_SPACING_INF = 2;
A3C_SPACING_AIR = 100;
A3C_FORMMODE_TEMP = 0;

A3C_LoiterDir = "CIRCLE";
A3C_LoiterRadius = 500;


A3C_ui_mapOverlay_fnc_UFSB_onUndoButton_MODE = 0; // 0 means undo WP, 1 means undo SYNC
//-- A3C_USERACTION: Array to contain data input information used in Undo function. passed as [_inputIndex,_InputType,_syncWPindex]
//-- _inputType: 0 == Waypoint Entry , 1 == Sync Entry

A3C_MMCode = {};

A3C_USERACTION = [];
A3C_TRACKER_MARKERS = [];
A3C_MV_MARKERDATA= [];


A3C_TRACKED_ENEMYGROUP = objnull;
A3C_TAB_BUILDING = objNull;

A3C_LB_DEST = objnull;
A3C_LB_TICKTIME = time;
A3C_LB_MODE = -1;



A3C_BOOL_DRAGLINE = false;

A3C_MAP_CommandMode = "INF";
//A3C_VAL_SPACING = 4;


A3C_HC_DETONATION_BOOL = false; //~~ change to clearer varnames, make obvious that it's about map drawing

A3C_Boarding_ACTIVE = false;
A3C_BOARDING_GROUPS = [];
A3C_UI_MAPICONS_HC_VICS = [];

A3C_WP_SPEED_TEMP = -1;
A3C_STANCE1_TEMP = "UP";
A3C_STANCE2_TEMP = "MIDDLE";

A3C_CHECKVAR = "TEMP";
A3C_CONNECTING_MODE = "LOOKDIR";

A3C_MovedItem_ID = ""; //-- used to identify a moved marker or Icon

A3C_WeaponCurr = "";

A3C_Selected_PolyID = "";

A3C_GCUNITS = [];
A3C_MARKERS = [];
A3C_HC_MARKERS = [];
A3C_WAYPOINTS = [];
A3C_WAYPOINTS_TEMP = [];
A3C_MARKERS_TEMP = [];
A3C_HC_DISBANDED = [];


A3C_SELECTED_UNITS = [];
A3C_FLEXMARKERS =[];
A3C_BPICONS = [];
A3C_BPMARKERS = [];
A3C_HC_TOSWITCH = [grpNull,-1];
A3C_DIR_POS = [0,0,0];


//----------------  V A L U E S   A N D   A R R A Y S   F O R   H U D   M O D E  -------------
//------------------------------------------------------------------------------------------------------



A3C_HUD_Snap = false;

A3C_HUD_FORM = 0; // 0 = Line, 1 = L-Form
A3C_HUD_SPACING = 2;
A3C_SUPPRESSIONHEIGHT = 0;
A3C_HUD_UnitIndicator_TEXT_INDEX = 0;
A3C_HUD_RADIUS = 0;
A3C_HUD_RADIUS_MIN = 0;
A3C_HUD_UnitIndicator_TEXTCOUNT = 1;
A3C_HUD_UnitIndicatorINDEX = 1;

A3C_SCROLLTIME = time;
A3C_FORMATION_DIR = [player,(screenToWorld [0.5,0.5])] call BIS_fnc_dirto;

A3C_UI_squadPlacement_units = [];
A3C_UI_squadPlacement_unitGhosts= [];
A3C_UI_DOWNKEYS = [];
A3C_SPLIT_UNITS = [];
A3C_TAKEN_WEAPONS = [];
A3C_TAKEN_MAGS = [];
// A3C_PATIENTS = [];
// A3C_MEDICS = []; //-- #REMINDER: variable moved to group namespace to create access for any group
A3C_AutoCombatDisabledUnits = [];


A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = []; //-- Remfire Units: Indicator based (old)
A3C_UI_RADIAL_Current_Remfire_Units = []; //-- Remfire Units: Radial
A3C_UI_RADIAL_Current_Remfire_Vehicles = []; //-- Remfire Vehicles: Radial

A3C_REMFIRE_nearEmptyStatics = [];

a3c_is_HC_remote = false;
a3c_tank_speed = 0;
a3c_remote_tank_obj = false;


A3C_BOOL_REMFIRE = false;
A3C_BOOL_REMFIRE_SUP = false;
A3C_REMFIRE_MAGTYPES = [];

A3C_GTI_UNIT = objnull;
A3C_REMFIRE_UNIT = objnull;




A3C_fireOnMyLeadUnits = [];
A3C_RadialMenu_KEY_ID = [-500,false,false,false];
A3C_UI_squadPlacement_interaction_KEY_ID = [-500,false,false,false];




A3C_MODIFIER_LOCK = false;
A3C_MOUSEWHEEL_ACTIVE = false;
A3C_UI_squadPlacement_unitGhostsInBuilding = false;
A3C_360_out = true;



A3C_UI_MAP_OPENING_CONTEXTMENU = false;


A3C_BOOL_STANCE_ICON_TRAVEL = false;
profilenamespace setvariable ["A3C_HUD_STANCE_MODE_TRAVEL",profileNameSpace getVariable ["A3C_HUD_STANCE_MODE_TRAVEL", 4]];
A3C_HUD_STANCE_MODE_TRAVEL = profileNameSpace getVariable "A3C_HUD_STANCE_MODE_TRAVEL";
A3C_HUD_STANCE_ICON_COLOR_TRAVEL = [1,1,1,1]; //~~no longer needed
A3C_HUD_STANCE_ICON_TRAVEL = "A3C_CORE\ui\pictures\icon_menu_stance_NoChange.paa";



A3C_BOOL_STANCE_ICON_DESTINATION = false;
profilenamespace setvariable ["A3C_HUD_STANCE_MODE_DESTINATION",profileNameSpace getVariable ["A3C_HUD_STANCE_MODE_DESTINATION", 4]];
A3C_HUD_STANCE_MODE_DESTINATION = profileNameSpace getVariable "A3C_HUD_STANCE_MODE_DESTINATION";
A3C_HUD_STANCE_ICON_COLOR_DESTINATION= [1,1,1,1]; //~~no longer needed
A3C_HUD_STANCE_ICON_DESTINATION= "A3C_CORE\ui\pictures\icon_menu_stance_NoChange.paa";

profileNamespace setvariable ["A3C_EHM_DIR",0];


A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";




A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
A3C_HUD_FORM_ICON_COLOR = [0,0,0,0.2];
A3C_HUD_FORM_ICON_SIZE = 0.8;

A3C_HUD_SPEED_ICON_COLOR = [1,1,1,0.5];
A3C_HUD_SPEED_ICON_SIZE = 0.8;
//A3C_HUD_FORM_ICON_SIZE = 0.8;


profileNameSpace setVariable ["A3C_HUD_OBJECTS",profileNameSpace getVariable ["A3C_HUD_OBJECTS",true]];

profilenamespace setvariable ["A3C_NUM_VAR",profileNameSpace getVariable ["A3C_NUM_VAR", true]];
profilenamespace setvariable ["A3C_SKILL_VAR",profileNameSpace getVariable ["A3C_SKILL_VAR", true]];
profilenamespace setvariable ["A3C_MAP_OVERLAY_SHOWN",profileNameSpace getVariable ["A3C_MAP_OVERLAY_SHOWN", true]];

profilenamespace setvariable ["A3C_MAP_KEY_ID",profileNameSpace getVariable ["A3C_MAP_KEY_ID", [46,[false,false,false]]]];

profilenamespace setvariable ["A3C_ORDER_REG_KEY_ID",profileNameSpace getVariable ["A3C_ORDER_REG_KEY_ID", [57,[false,false,false]]]];
profilenamespace setvariable ["A3C_ORDER_FW_KEY_ID",profileNameSpace getVariable ["A3C_ORDER_FW_KEY_ID", [57,[false,true,false]]]];
profilenamespace setvariable ["A3C_ORDER_BW_KEY_ID",profileNameSpace getVariable ["A3C_ORDER_BW_KEY_ID", [57,[false,false,true]]]];
profilenamespace setvariable ["A3C_FORCERAIL_VAR",profileNameSpace getVariable ["A3C_FORCERAIL_VAR", false]];

profilenamespace setvariable ["A3C_HUD_RES_VAR",profileNameSpace getVariable ["A3C_HUD_RES_VAR", true]];

profilenamespace setvariable ["A3C_SUP_RESTRICTIVE",profileNameSpace getVariable ["A3C_SUP_RESTRICTIVE", ["UNLIMITED",0]]];
profilenamespace setvariable ["A3C_SUP_VAL_MAGAZINE",profileNameSpace getVariable ["A3C_SUP_VAL_MAGAZINE", 1]];
profilenamespace setvariable ["A3C_SUP_VAL_PERCENTAGE",profileNameSpace getVariable ["A3C_SUP_VAL_PERCENTAGE", 25]];
profilenamespace setvariable ["A3C_SUP_VAL_TIME",profileNameSpace getVariable ["A3C_SUP_VAL_TIME", 30]];

profilenamespace setvariable ["A3C_UI_squadPlacement_interactionSHOW_VAR",profileNameSpace getVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", true]];
profilenamespace setvariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR",profileNameSpace getVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true]];

A3C_HUD_GOCODE_ICON_COLOR = if (profilenamespace getvariable "A3C_UI_squadPlacement_interactionOVERRIDE_VAR") then {[1,1,1,0.2]} else {[1,1,1,0.7]};

profilenamespace setvariable ["A3C_HUD_SPEED_VAR",profileNameSpace getVariable ["A3C_HUD_SPEED_VAR", -1]];
profilenamespace setvariable ["A3C_TABLET_IMG",profileNameSpace getVariable ["A3C_TABLET_IMG", "A3C_CORE\ui\pictures\BG_Tablet_Tough.paa"]];

profileNamespace setVariable ['A3C_UI_squadPlacement_overlayIsOpen',false];
profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","NONE"];

profilenamespace setvariable ["A3C_HUD_LAYOUT_CORNER",profileNameSpace getVariable ["A3C_HUD_LAYOUT_CORNER", false]];
profilenamespace setvariable ["HC_GROUP_RESPONSE",profileNameSpace getVariable ["HC_GROUP_RESPONSE", false]];

profilenamespace setvariable ["A3C_AUTOMEDIC",profileNameSpace getVariable ["A3C_AUTOMEDIC", false]];

if (isServer) then { //-- ONLY RELEVANT FOR HOSTING MACHINE - DEDICATED EXITED EARLIER IN SCRIPT. Variable is only tested by server monitor
	A3C_isHCSkillMaxed = if (!isNil 'A3C_isHCSkillMaxed') then {A3C_isHCSkillMaxed} else {profileNameSpace getVariable ["A3C_SKILL_VAR",true]}; //-- SKILL MP
};



A3C_HUD_SPEED_ICON = if ( (profilenamespace getvariable "A3C_HUD_SPEED_VAR") == -1) then {"A3C_CORE\ui\pictures\icon_menu_speed_full.paa"} else {"A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa"};


A3C_DATA_REMOTE_AMMO = [];
{
	//A3C_DATA_REMOTE_AMMO pushBack (configname _x);
	_ammo = getText (configfile >> "CfgVehicles" >> configName _x >> "ammo");
	_trigger = getText (configfile >> "CfgAmmo" >> _ammo >> "mineTrigger");
	if (_trigger == "RemoteTrigger") then {
		A3C_DATA_REMOTE_AMMO pushBack
		[
			configName _x,
			getText (configfile >> "CfgVehicles" >> configName _x >> "displayName"),
			_ammo
		];
	};
} foreach ("true" configClasses (configFile >> "CfgVehicles"));


//---------------------------  R A D I A L   V A L U E S   A N D   A R R A Y S  ------------------------
//------------------------------------------------------------------------------------------------------

BV_GREN = 0;
BV_ROE = 0;
BV_BRAIN = 0;
BV_FORM = 0;
BV_STANCES = 0;
BV_ITEMS = 0;
BV_VEHS = 0;
BV_MEDICAL = 0;
BV_CBMODE = 0;




BV_LB1 = 6;
BV_LB2 = 7;
BV_STANCES = 0;
BV_ACT = 0;

BV_RINGFORM = 0;



A3C_RD_UNITS = [];

A3C_AI_GREN_ARRAY = [];

A3C_RADIAL_VEH_KIND = "CAR";

A3C_RD_BOOL_UNITS = true;


A3C_Prevent_attach_IR = false;
A3C_Prevent_attach_IR_Laser = false;
A3C_Prevent_attach_Flashlight = false;
A3C_Prevent_attach_Silencer = false;
A3C_Prevent_attach_NVG = false;
A3C_Prevent_SwitchWeapon = false;

A3C_SNAP_MAP_BOOL = false;




A3C_VEHSAV= [];
A3C_VEHROLES = [];
A3C_BOARD_UNITS = [];
A3C_BOARD_UNITS_ACTIVE = if (isNil "A3C_BOARD_UNITS_ACTIVE") then {[]} else {A3C_BOARD_UNITS_ACTIVE};
A3C_TURRETS = [];

A3C_WeaponHolderClasses = ["WeaponHolderSimulated", "GroundWeaponHolder"];
A3C_LBR_1 = "MEDICAL";
A3C_ReArm_Options = [];



A3C_UI_MAP_Overlay_VAR_isUnFolded = false;
A3C_SQ_CLICKED_UNIT = objNull;
A3C_BOOL_MOUSEMOVING = false;
A3C_MAP_DRAGPLANNING_POSITIONS = [];
A3C_MAP_DRAGPLANNING_ACTIVE = false;
A3C_DRAGPOS = [];
A3C_Prevent_SCALING = false;
  


A3C_UI_CustomFormation_BOOL_DRAW = false;
A3C_UI_CustomFormation_BOOL_ALLOW = false;
A3C_UI_CustomFormation_BOOL_formationActive = false;

A3C_UI_CustomFormation_formationDirection = getDir player;

A3C_UI_CustomFormation_Dots = [];
A3C_UI_CustomFormation_tickDir = 0;
A3C_UI_CustomFormation_Poses = [];
A3C_UI_CustomFormation_lineLength = 0;


A3C_UI_INV_CONTAINERS = [];


BR_A3C_GRENADEMODE = false;

A3C_Prevent_attach_IR = false;
A3C_Prevent_attach_IR_Laser = false;
A3C_Prevent_attach_Flashlight = false;

A3C_Prevent_UGLSHOT = false;
A3C_Prevent_ATSHOT = false;
A3C_Prevent_TANKSHOT = false;
A3C_Prevent_STATICSHOT = false;

A3C_REFRESHING = false;

A3C_CONVOY_GROUPORDER = [];

A3C_HC_CASMODES = [];



//-- HARDCODED UI CTRL VARIABLES >>> ALL NEED TO BE CHANGED TO QGVAR?

A3C_UI_MAP_UNITBUTTONCEIL = 16;


A3C_FlyinHeightArrayHeli = ["25","75","200","500"];
A3C_FlyinHeightArrayJet = ["30","100","500","1000","2000"];


A3C_HC_MENU_REFERENCE_UNITS = [];
A3C_RADIALMODE = "";
A3C_UI_GRID_SIZE = 1;
A3C_CURRENT_COMMAND_LEVEL = "SQUAD";
A3C_UI_RADIAL_CTRLS_SHOWN = [];
A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED = false;
A3C_ui_shared_fnc_createDashBoard_ExtraControls = [];
A3C_ACTIVE_BUTTONUNIT = objnull;

//----------------------------- MEDICAL VARIABLES
A3C_MEDICAL_MeetingPos = [];
//----------------------------- 


//----------------------------- MAP OVERLAY (#TODO: move other map overlay data here too)
//-- Hardcoded GROUPMENU ACTIONBUTTONS array (HCGP Context)
A3C_ui_mapOverlay_GROUPMENU_ACTIONBUTTONS =
[
	[IDC_MAP_HCGP_ActionMacro_0_BG,IDC_MAP_HCGP_ActionMacro_0_IMG,IDC_MAP_HCGP_ActionMacro_0_BTN], //-- row 1
	[IDC_MAP_HCGP_ActionMacro_1_BG,IDC_MAP_HCGP_ActionMacro_1_IMG,IDC_MAP_HCGP_ActionMacro_1_BTN],
	[IDC_MAP_HCGP_ActionMacro_2_BG,IDC_MAP_HCGP_ActionMacro_2_IMG,IDC_MAP_HCGP_ActionMacro_2_BTN],
	[IDC_MAP_HCGP_ActionMacro_3_BG,IDC_MAP_HCGP_ActionMacro_3_IMG,IDC_MAP_HCGP_ActionMacro_3_BTN],
	[IDC_MAP_HCGP_ActionMacro_4_BG,IDC_MAP_HCGP_ActionMacro_4_IMG,IDC_MAP_HCGP_ActionMacro_4_BTN],

	[IDC_MAP_HCGP_ActionMacro_5_BG,IDC_MAP_HCGP_ActionMacro_5_IMG,IDC_MAP_HCGP_ActionMacro_5_BTN], //- row 2
	[IDC_MAP_HCGP_ActionMacro_6_BG,IDC_MAP_HCGP_ActionMacro_6_IMG,IDC_MAP_HCGP_ActionMacro_6_BTN],
	[IDC_MAP_HCGP_ActionMacro_7_BG,IDC_MAP_HCGP_ActionMacro_7_IMG,IDC_MAP_HCGP_ActionMacro_7_BTN],
	[IDC_MAP_HCGP_ActionMacro_8_BG,IDC_MAP_HCGP_ActionMacro_8_IMG,IDC_MAP_HCGP_ActionMacro_8_BTN],
	[IDC_MAP_HCGP_ActionMacro_9_BG,IDC_MAP_HCGP_ActionMacro_9_IMG,IDC_MAP_HCGP_ActionMacro_9_BTN]
];

A3C_UI_MAP_UFSQB_SettingsButtonPairs =  
[
	[IDC_MAP_UFSB_STANCE_TRAVEL_IMG, IDC_MAP_UFSB_STANCE_TRAVEL_BTN], //-- Stance Travel
	[IDC_MAP_UFSB_WP_SPEED_IMG, IDC_MAP_UFSB_WP_SPEED_BTN], //-- Travel Speed
	[IDC_MAP_UFSB_STANCE_ARRIVAL_IMG, IDC_MAP_UFSB_STANCE_ARRIVAL_BTN], //-- Stance Arrival
	[IDC_MAP_UFSB_COMBATMODE_IMG, IDC_MAP_UFSB_COMBATMODE_BTN], //-- Waypoint-Combatmode
	[IDC_MAP_UFSB_WPACTION_IMG, IDC_MAP_UFSB_WPACTION_BTN], //-- Squad Waypoint Actions
	[IDC_MAP_UFSB_WPFORMATION_IMG, IDC_MAP_UFSB_WPFORMATION_BTN], //-- Waypoint Formation
	[IDC_MAP_UFSB_SPACING], //-- Spacing Input
	[IDC_MAP_UFSB_WPCONDITION_IMG, IDC_MAP_UFSB_WPCONDITION_BTN],  //-- Waypoint Completion Condition
	[IDC_MAP_UFSB_UNDO_IMG, IDC_MAP_UFSB_UNDO_BTN], //-- Undo
	[IDC_MAP_UFSB_CANCEL_IMG, IDC_MAP_UFSB_CANCEL_BTN], //-- Cancel Data
	[IDC_MAP_UFSB_HOLD_IMG, IDC_MAP_UFSB_HOLD_BTN], //-- Hold Button
	[IDC_MAP_UFSB_CONTINUE_IMG, IDC_MAP_UFSB_CONTINUE_BTN] //-- Continue Button	
];
reverse A3C_UI_MAP_UFSQB_SettingsButtonPairs; //-- reverse to start animation from last button


A3C_CUR_EDIT_POLY = [];
A3C_TRACKER_GROUPS = [];
A3C_GROUND_ACTIONS = ["NONE","GRENADE","SUPPRESSION"];
A3C_GROUND_ACTIONS_INDEX = 0;

A3C_Map_HC_groupContext_Behaviour = "";
A3C_Map_HC_groupContext_CMode = "";
A3C_Map_HC_groupContext_Form = "";
A3C_Map_HC_groupContext_Color = "";

A3C_SELECTED_HC_GROUPS_SETTINGS = [];
A3C_CONVOYGROUPS = [];

A3C_HC_NearStatics = [];



A3C_HC_GroupMenu_SuppressionRequested = false;

A3C_ALLOW_HCrEFRESH = true;

A3C_HC_engineOffUnits = [];

A3C_MapSel_Field_Root = [0,0,0];
A3C_MapSel_Field_DEST = [0,0,0];
A3C_MapSel_Field_Active = false;



A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_WIPE = {
	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_0 = [[],{}];
	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_1 = [[],{}];
	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_2 = [[],{}];
	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_3 = [[],{}];
	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_4 = [[],{}];

	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_5 = [[],{}];
	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_6 = [[],{}];
	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_7 = [[],{}];
	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_8 = [[],{}];
	A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_9 = [[],{}];
};

[] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_WIPE;

A3C_HC_ACTIVEGROUP = grpNull;
A3C_HC_ACTIVE_IND = 0;
A3C_HC_ACTIVE_IND_A = 0;

A3C_HC_ACTIVE_PRE_COND_MODE = "ARRIVAL";
A3C_HC_ACTIVE_PRE_COND_VAL = 0;
A3C_HC_ACTIVE_POST_COND_MODE = "NONE";
A3C_HC_ACTIVE_POST_COND_VAL = "NONE";

A3C_ACTIVE_HC_WP_ICON = -1;

A3C_HC_ACTIVE_FORM_PRE = "LINE";
A3C_HC_ACTIVE_FORM_POST = "LINE";

A3C_HC_PREVENT_POLY = false;
A3C_HC_ACTIVE_IND = 0;

A3C_HC_EDIT_ACTION = "MOVE";
A3C_HC_EDIT_TYPE = "MOVE";
A3C_HC_RC_LB_MODE = 0;
A3C_HC_EDIT_COMBOSUBVAL_1 = "CIRCLE_L";
A3C_HC_EDIT_COMBOSUBVAL_2 = 1000;

A3C_isIssuingCargoWPs = false;




//----------------------------- drawMapUI variables
A3C_UI_MAPICONS_POLYGON_MAIN = [];
A3C_UI_MAPICONS_POLYGON_EDGE = [];
A3C_UI_MAPICONS_SQUAD = [];
A3C_UI_MAPICONS_SQ_WPS_WPDOTS = [];
A3C_UI_MAPICONS_SQ_WPS_LOOKDIR = [];
A3C_UI_MAPICONS_HC_GROUP = [];
A3C_UI_MAPICONS_HC_WPS = [];
A3C_UI_MAPICONS_HC_TRACKER = [];
A3C_UI_MAPICONS_PICKUP = [];
A3C_UI_MAPICONS_DEMO_VICS = [];
A3C_UI_MAPICONS_BOARDING_DRAW = [];
A3C_UI_MAPICONS_HC_CONES = [];



//----------------------------- 

//----------------------------- SHARED UI VARIABLES

//----------------------------- UnitSelection Tree Variables
A3C_UI_MAP_TREES_OPEN = [];
A3C_RADIAL_TREES_OPEN_SQ = [[0]];
A3C_RADIAL_TREES_OPEN_HC = [[0]];


//----------------------------- DATA: NAVIGABLE BUILDING POSITIONS
profilenamespace setvariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT",profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]];
profilenamespace setvariable ["A3C_PROFILEVAR_BUILDINGS_CLEAR",profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_CLEAR", []]];


private _data = profilenamespace getvariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT",[]];
{
	_x params ["_buildingType","_pgs"];

	private _execute = true;
	{
		if (_x select 0 == _buildingType) exitWith {
			_execute = false;
		};
	} foreach _data;
	if (_execute) then {
		_data pushBack _x;
	};
} foreach A3C_DATA_bPosNoAccess;
profilenamespace setvariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", _data];
//----------------------------- 

//-----------------------------  SUPPRESSION AND OTHER POLYGON VARIABLES
A3C_SUP_BOOL_MD = false;

A3C_SUP_DRAW_TOGGLE = false;
A3C_DRAW_ORDER_RELEASE = true;

A3C_SUP_CLICKPOS = [];
A3C_SUP_MOUSEPOS = [];
A3C_SUP_PosArray = [];


A3C_SUP_MAIN_POLY = []; //~~ is this still needed?

A3C_ALL_POLYS = [];

A3C_SUPPRESSION_UNITS_SQ = []; //-- array for suppressing player controlled units. LOCAL TO CLIENT, CHANGES NOT BROADCASTED

A3C_SUPPRESSION_UNITS_SQ_TEMP = [];



A3C_SUP_POLYMARKS = [];
A3C_POLYEDGE_MARKERS = [];
A3C_SUP_POLY_IND = 1;
A3C_SUP_POLY_IND_MARK = 1;


A3C_SUPPRESSION = false; //-- might be unused >> confirm

A3C_HUD_DRAW_BOOL = false;
A3C_HUD_DRAW_POSARRAY = [];

//-- Custom formation
A3C_UI_CustomFormation_SaveOverlayIsOpen = false;

A3C_UI_CustomFormation_BOOL_DRAW = false;
A3C_UI_CustomFormation_BOOL_isMouseUp = false;
A3C_UI_CustomFormation_BOOL_ALLOW = false;
A3C_UI_CustomFormation_BOOL_formationActive = false;

A3C_UI_CustomFormation_GridUnit =
    ((abs safeZoneY) + (safeZoneY + safeZoneH)) / 12;

profileNamespace setVariable [
    "A3C_C_FORMATIONS_SAVED",
    profileNamespace getVariable [
        "A3C_C_FORMATIONS_SAVED",
        []
    ]
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_saveLB",
    0
];

//-----------------------------  ZEUS (WIP)
A3C_ZEUSMISSION = if (!isNil 'A3C_ZEUSMISSION') then {A3C_ZEUSMISSION} else {false};


//-- fetch reference game-controls once they exist
[] spawn {
	sleep 1;
	A3C_SHOWNHUD = shownHud; //-- shownHud select 6 is false if this fires earlier

	//-- GAMEUI- VARIABLES
	waitUntil {!isNull findDisplay 12}; //-- necessary because otherwise weird offset


	A3C_GAMEUI_COMMANDBAR_X = (profilenamespace getvariable ["IGUI_GRID_BAR_X", (safezoneX + 1 * ( ((safezoneW / safezoneH) min 1.2) / 40))]);
	A3C_GAMEUI_COMMANDBAR_Y = (profilenamespace getvariable ["IGUI_GRID_BAR_Y", (safezoneY + safezoneH - 4.5 * ( (((safezoneW / safezoneH) min 1.2) / 1.2) / 25))]);
	A3C_GAMEUI_COMMANDBAR_W = (36 * (((safezoneW / safezoneH) min 1.2) / 40));
	A3C_GAMEUI_COMMANDBAR_H =  (4 * ( ( ((safezoneW / safezoneH) min 1.2) / 1.2) / 25));
	A3C_GAMEUI_COMMANDBAR_PADDING_Y =  (safeZoneY + safeZoneH) - A3C_GAMEUI_COMMANDBAR_H;
	
	A3C_MAP_GAMEUI_MENU = (ctrlPosition (findDisplay 12 displayctrl 1021));
	A3C_MAP_GAMEUI_MENU_X = A3C_MAP_GAMEUI_MENU select 0;
	A3C_MAP_GAMEUI_MENU_Y = A3C_MAP_GAMEUI_MENU select 1;
	A3C_MAP_GAMEUI_BAR = (ctrlPosition (findDisplay 12 displayctrl 1020));
	A3C_MAP_GAMEUI_PADDING_Y = A3C_MAP_GAMEUI_MENU_Y - ((A3C_MAP_GAMEUI_BAR select 1) + (A3C_MAP_GAMEUI_BAR select 3));
	A3C_MAP_GAMEUI_PADDING_X = (A3C_MAP_GAMEUI_MENU select 0) - safeZoneX;
	A3C_MAP_GAMEUI_PADDEDBOTTOM_Y = (safezoneH + safezoneY) - A3C_MAP_GAMEUI_PADDING_Y;

	A3C_MAP_OVERLAY_GAMEUI_TREEROWHEIGHT_MAIN = 0.039 / (getResolution select 5);
	A3C_MAP_OVERLAY_GAMEUI_TREEROWHEIGHT_SUB = 0.03 / (getResolution select 5);
	A3C_MAP_OVERLAY_GAMEUI_TREEW = 8 * A3C_MAP_OVERLAY_GAMEUI_TREEROWHEIGHT_SUB;// 0.14 * safezoneW; //0.19477 * safezoneW; ( 10 * ( pixelGrid * pixelW * 2.5 )); //
	A3C_MAP_OVERLAY_GAMEUI_TREEX = (safeZoneX + safeZoneW) - A3C_MAP_GAMEUI_PADDING_X - A3C_MAP_OVERLAY_GAMEUI_TREEW;
	



	A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_H = 0.05 / (getResolution select 5);
	A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W = A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_H * 0.75;
	A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_X = (safeZoneX + safeZoneW) - A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W - A3C_MAP_GAMEUI_PADDING_X;

	
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_FULL = 0.555611 * safezoneW;
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_COLLAPSED = A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_FULL * 0.011;
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X = A3C_MAP_OVERLAY_GAMEUI_TREEX - A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_COLLAPSED; //A3C_MAP_GAMEUI_MENU_X + A3C_MAP_OVERLAY_GAMEUI_TREEW;
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_H = ( 0.11899 * safezoneH) * 1.5;
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y = A3C_MAP_GAMEUI_PADDEDBOTTOM_Y - A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_H;

	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H = (A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_H * 0.6) - (A3C_MAP_GAMEUI_PADDING_Y * 2);
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_W = A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H * 0.75;
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_EXPANDED = (12 * (A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_W + (A3C_MAP_GAMEUI_PADDING_Y / 2))) + (3 * (A3C_MAP_GAMEUI_PADDING_Y / 2) ); //-- 12 is (count _settingsButtonsPairs)
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X_EXPANDED = A3C_MAP_OVERLAY_GAMEUI_TREEX - A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_EXPANDED;


	//A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_COMMITBUTTON_W = 0.0973751 * safezoneW;
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_COMMITBUTTON_H = 0.044007 * safezoneH;

	A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H = 0.08 * safezoneH; //0.0330046;  = 0.07; //0.0330046;
	A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H * 0.75; 

	A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y = (safezoneH + safezoneY); //-- default, out of bounds on first spawn

	A3C_MAP_OVERLAY_GAMEUI_teamcolorboxH = (0.04 * safezoneH) - A3C_MAP_GAMEUI_PADDING_Y;

	A3C_MAP_GAMEUI_Upper_buttonH = 0.04 * safezoneH; 

};

//-- Debug 
A3C_DebugHint = false;


if ("antistasi" in (toLower missionName)) then {
	[] spawn {
		waituntil {!isNil 'A3C_IsA3CServer'};
		//-- ANTISTASI - give tablet to commander
		if (
			A3C_IsA3CServer
			&& {player isEqualTo (missionNamespace getVariable ["theBoss", objNull])}
			&& {{"A3C_Terminal" in _x} count ((assignedItems player) + (items player)) == 0}
		) then {
			waitUntil {
				uiSleep 0.25;
        		missionNamespace getVariable ["initClientDone", false]
			};
			[player] call A3C_main_fnc_issueCommandingTablet;
		};

	};
};


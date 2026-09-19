//-- Server A3C presence.
//-- Value always exists; Resolved tells us whether that value is authoritative yet.
if (isNil "A3C_IsA3CServer") then {
	A3C_IsA3CServer = false;
};

if (isNil "A3C_IsA3CServerResolved") then {
	A3C_IsA3CServerResolved = false;
};

diag_log "[A3C]: Starting A3C initvalues common";

//---------------------------  S H A R E D  V A L U E S   A N D   A R R A Y S  ------------------------
//------------------------------------------------------------------------------------------------------

A3C_HC_allGroupsClient_Current = []; //-- despite the name this needs to exist everywhere at the moment


//---------------------------------------------------------------------------------------------------------
//--------------------  ADDON CHECKS  ---------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
A3C_EHM = if (isClass(configFile/"CfgPatches"/"BaBe_core")) then {true} else {false}; //-- detect if Enhanced Movement is running
A3C_IsAce3 = if (isClass(configFile/"CfgPatches"/"ace_medical")) then {true} else {false}; //-- detect if ACE3-Medical is running
A3C_IsIFA = if (isClass(configFile/"CfgPatches"/"WW2_Assets_c_Weapons_InfantryWeapons_c")) then {true} else {false}; //-- detect if IFA is running

///////////////////////////////////////////////////////////////////////////////////
//-- CHECK FOR SERVER SIDE ADDON PRESENCE

A3C_checkserverAddon = { //-- this works but is sloppy. we need a way to return value from server.
	if !(isServer) exitWith {};
	params ["_inputString","_caller"];
	private ["_isClass"];
	_isClass = if (isClass(configFile/"CfgPatches"/_inputString)) then {true} else {false};
	switch _inputString do {
		case ("AR_AdvancedRappelling") : {A3C_IsRappel = _isClass; publicVariable 'A3C_IsRappel'};
		case ("AICommand") : {A3C_IsAICommand = _isClass; publicVariable 'A3C_IsAICommand'};
		case ("A3C_UI") : {
			A3C_IsA3CServer = _isClass;
			A3C_IsA3CServerResolved = true;

			publicVariable "A3C_IsA3CServer";
			publicVariable "A3C_IsA3CServerResolved";
		};
	};
};
publicVariable 'A3C_checkserverAddon';


//-- check for supportet client/serverSide addons
A3C_IsAICommand = if (isClass(configFile/"CfgPatches"/"AICommand")) then {true} else {false};






A3C_CarrierArray =
[
	[[-31.6045,-22.9785,24],92.178],
	[[-31.915,-3.06934,24],92.178],
	[[-32.1641,16.7773,24],93.26],
	[[-32.4199,36.4346,24],92.178],
	[[-31.3652,55.6875,24],92.178],
	[[-32.2373,74.7832,24],92.1777],
	[[34.0117,121.157,24],230],
	[[33.1025,148.224,24],230],

	[[-9.61328,-23.7344,24],92.178],
	[[-9.92969,-3.89941,24],92.178],
	[[-10.1982,15.542,24],92.178],
	[[-12.4434,35.6865,24],92.178],

	[[33.9961,101.191,24],230]
];

A3C_HUMAN_HITPOINTS = ["HitAbdomen","HitArms","HitChest","HitDiaphragm","HitFace","HitHands","HitHead","HitLegs","HitNeck","HitPelvis"];


A3C_WAYPOINT_UID_COUNTER_LOCAL = 0;


A3C_UI_COLOR_RED = [0.5,0,0,1];
A3C_UI_COLOR_BLUE = [0,0.3,0.6,1];
A3C_UI_COLOR_YELLOW = [0.8,0.6,0,1];
A3C_UI_COLOR_GREY = [0.29,0.29,0.29,1];
A3C_UI_COLOR_BLACK = [0,0,0,1];
A3C_UI_COLOR_YELLOW2 = [0.85,0.85,0,1];

A3C_CONVOY_SLOWDOWN_VICS = [];
A3C_UI_HUDICONS_HC_GROUP = [];

A3C_VARNAME_INDEX_HC = 0;



A3C_OCCUPIED_BPOSES = [];


A3C_THROW_MUZZLES = getArray (configFile >> "CfgWeapons" >> "THROW" >> "muzzles");
A3C_SUPPRESSION_FORBIDDEN = ["missiles_DAGR","missiles_ASRAAM","cannon_120mm"];

A3C_HangarTypes = [];
_array = "true" configClasses (configFile >> "CfgVehicles");{
	if (["hangar",(configname _x)] call BIS_fnc_instring) then {
		A3C_HangarTypes pushback (configName _x);
	};
} foreach _array;





{
	private _sideKey = _x;

	{
		missionNamespace setVariable [
			format [
				"A3C_GoCode_Activate_%1_%2",
				_x,
				_sideKey
			],
			false
		];
	} forEach [
		"A",
		"B",
		"C",
		"D"
	];
} forEach [
	"WEST",
	"EAST",
	"GUER",
	"CIV"
];

A3C_MISSIONENDED = false;

A3C_UI_HUD_ASSIGNVEHICLE = false;
A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS = [];

A3C_UI_HUD_3D_TAG_reposition = false;
A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
A3C_UI_HUD_3D_TAG_ICON_SIZE = 3;
A3C_UI_HUD_3D_TAG_ICON_POS = [0,0,0];
A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
A3C_isHud3dTag = false;

A3C_UI_HUD_3D_TAG_ICON_MOD = "NONE"; //-- for modifier

A3C_AI_HighCommand_Action_ID = "";


A3C_UI_MAP_BOOL_isHCWaypointPosEdit = false; //-- different from A3C_BOOL_MOVINGHC (for default Arma HC module)




A3C_HC_ACTIVEGROUP = grpNull;
A3C_HC_ACTIVE_WPSPEED = "UNCHANGED";

//A3C_Mon_Server_EH_units = [];





//if (isnil "A3C_ADJUSTSKILL") then {
//	A3C_ADJUSTSKILL = true;
//};



A3C_HC_WP_SYNC_ROOT = [grpNull,-1];

A3C_UI_MAP_SYNC_BOARDGROUP = grpNull;
A3C_UI_MAP_SYNC_HOSTGROUP = grpNull;
A3C_UI_MAP_SYNC_BoardWPI = -1;
A3C_UI_MAP_SYNC_HostWPI = -1;

A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE = false;

//A3C_HC_WP_SYNC_ARRAYS = [];
A3C_UI_MAP_isCircleMenu = false;
A3C_UI_MAP_CircleMenu_CTRLS = [];

A3C_TARGETVEH = objnull;
A3C_SNAP_OBJECT = objnull;

A3C_GRENPHR = "A3C_FireInTheHole";

A3C_SelectionPromptPanel_MODE = "DISASSEMBLE";
A3C_HC_FOCUS_ARTY_AMMO = "";
A3C_HC_FOCUS_ARTY_POS = [0,0,0];

A3C_MAP_CONNECTING_ID = "";

A3C_isArtyAwaitingSuborder = false;

A3C_HC_CASMODE_VAL = 0;

A3C_HC_ACTIVE_WPOS = [0,0,0];
A3C_RADIAL_ACTION_HC_LANDINGDATA = [];


A3C_GROUP_STANCE_Selected = "AUTO";

A3C_DEBUG = if (!isNil 'A3C_DEBUG') then {A3C_DEBUG} else {false};


A3C_HUD_NORMAL = [0,0,0];

A3C_HUD_COLLIDER = objnull;
A3C_HUD_Snap_DIR = 0;
A3C_HUD_Snap = false;
A3C_HUD_FormDir_Old = 0;




A3C_DISABLE_TRACKER = if (!isNil 'A3C_DISABLE_TRACKER') then {A3C_DISABLE_TRACKER} else {false};



A3C_MON_SERVER_checkGroups = [];

A3C_COVER_BLACKLIST = [];


///////////////////////////////////////////////////////////////////////////////////



//-- IFA is running: Create arrays with [_weaponType,[_part1, _part2]] for each vehicle with "LIB_dissasembleTo" data
//-- this is because there is no "LIB_asembleTo" config entries
A3C_IFA_StaticPartPairs = [];
if (A3C_IsIFA) then {
	_cfgArray = "true" configClasses (configfile >> "CfgVehicles");
	{
		_assembleInfo = getArray (configfile >> "CfgVehicles" >> configName _x >> "assembleInfo" >> "LIB_dissasembleTo");
		if (count _assembleInfo > 0) then {
			A3C_IFA_StaticPartPairs pushBack [configName _x,_assembleInfo];
		};
	} foreach _cfgArray;
};





A3C_SOG_BASEPACKS = ["vn_o_pack_static_base_01","vn_b_pack_static_base_01"];


A3C_STATIC_PACKS = [];


//-- gtiGrenade variables

BR_A3C_TACV_GV0MaxS = 19;		//standing
BR_A3C_TACV_fatEff	= 0.4;	//max - fatEff*max when fat = 1
BR_A3C_TACV_GV0MaxP = 0.75;		//prone
BR_A3C_TACV_GV0MaxC = 0.9;		//crouch
A3C_DISABLE_RADIAL = false;
BR_A3C_TACV_throwTheta = 45;
BR_A3C_TACV_throwTheta_Add = 0;







///////// TEMP DEBUG STUFF GETIN 

// A3C_ai_highCommand_fnc_actionLandingGetIn = {
// 	params ["_group", "_vehiclesLanding"];
// 	private _groupVehicles = [];

// 	{
// 		private _vehicle = vehicle _x;

// 		if (_x == effectiveCommander _vehicle) then {
// 			if !(isTouchingGround _vehicle) then {
// 				[
// 					_group,
// 					_pos,
// 					30,     //-- final combat landing speed in km/h
// 					20,     //-- low final altitude ATL before GET IN landing behavior takes over
// 					500,    //-- short approach envelope; main approach already happened
// 					150     //-- soft anti-overshoot damping near landing point
// 				] call A3C_ai_shared_fnc_approachWaypointHelicopter;

// 				if !(_vehicle in _vehiclesLanding) then {
// 					(format ["%1 (%2) added to _vehiclesLanding [%3]", typeOf _vehicle, groupID _group, round time]) remoteExec ["systemchat", 0];
// 					_vehicle land "GET IN";
// 					_vehiclesLanding pushBack _vehicle;
// 				};
// 			} else {
// 				(format ["%1 (%2) is glued to ground [%3]", typeOf _vehicle, groupID _group, round time]) remoteExec ["systemchat", 0];
// 				_vehicle flyInHeight 0;
// 			};

// 			_groupVehicles pushBack _vehicle;
// 		};
// 	} forEach units _group;
// 	[_groupVehicles, _vehiclesLanding]
// };



/////////////////

A3C_MEDICAL_itemStrings =
[
	//Regular
	
	"firstaid",
	"fak",
	"fielddressing",
	"morphine",
	//--ACE stuff
	//"ACE_fieldDressing", //-- not necessary, fielddressing is already checked
	"ace_morphine",
	"ace_surgicalkit",
	"ace_personalaidkit",
	"ace_elasticbandage",
	"ace_quikclot",
	"ace_packingbandage",
	"medi",
	"medkit",
	"medikit",
	"biofoam"
];



//-- Server only

if (!isServer) exitWith {};



if (isDedicated) then {
	A3C_DEDI_allowLocalitySwitch = true;
};

A3C_WAYPOINT_BUNDLES = [];
publicVariable "A3C_WAYPOINT_BUNDLES";

A3C_DETO_VIC_INDEX = 0;
publicVariable 'A3C_DETO_VIC_INDEX';

A3C_BLACKLIST_WAYPOINT_EDIT = [];
publicVariable 'A3C_BLACKLIST_WAYPOINT_EDIT';

A3C_CLIENT_IDS = [];
publicVariable 'A3C_CLIENT_IDS';

A3C_REMFIRE_UNITS_ACTIVE = [];
publicVariable 'A3C_REMFIRE_UNITS_ACTIVE';

A3C_GROUP_CONVOYS = [];
publicVariable 'A3C_GROUP_CONVOYS';

A3C_REMOTE_BLACKFISH_HandlerIndex = 0;
publicVariable "A3C_REMOTE_BLACKFISH_HandlerIndex";

A3C_TurnOutEH_Vehicles = []; //-- Server only, NOT public

KNOWSABOUT_ARRAY = [];

A3C_SUPPRESSION_UNITS_AI = []; //-- array for suppressing AI controlled units. CHANGES ARE BROADCASTED
publicVariable 'A3C_SUPPRESSION_UNITS_AI';

RHS_ENGINE_STARTUP_OFF = true;
publicVariable 'RHS_ENGINE_STARTUP_OFF';


diag_log "[A3C]: FINISHED A3C initvalues common";




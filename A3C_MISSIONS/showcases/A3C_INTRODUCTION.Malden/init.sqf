
//////////////////////// FUNCTIONS

#include "\A3C_CORE\ui\SHARED\shared_ui_defines.hpp"
#include "\A3C_CORE\ui\mapOverlay\dialog_defines.hpp"
#include "\A3C_CORE\ui\radial\radialMenu\dialog_defines.hpp"
#include "\A3C_CORE\ui\hud\squadPlacement\dialog_defines.hpp"
#include "\A3C_CORE\ui\SHARED\selectionPromptPanel\dialog_defines.hpp"

A3C_TUTORIAL_UI_VARIABLES = [
	//-- RADIAL MENU
	IDD_RADIAL_MENU,
	IDC_RADIAL_CORE_REFRESHDATA_IMG,
	IDC_RADIAL_INNERRING_ACTIONS_IMG,
	IDC_RADIAL_INNERRING_ROE_IMG,
	IDC_RADIAL_INNERRING_AUTO_IMG,
	IDC_RADIAL_INNERRING_STANCES_IMG,
	IDC_RADIAL_INNERRING_GRENADES_IMG,
	IDC_RADIAL_OUTERTOP_1_IMG,
	IDC_RADIAL_OUTERTOP_2_IMG,
	IDC_RADIAL_OUTERTOP_3_IMG,
	IDC_RADIAL_OUTERRIGHT_2_IMG,
	IDC_RADIAL_OUTERRIGHT_3_IMG,
	IDC_RADIAL_OUTERRIGHT_4_IMG,
	IDC_RADIAL_EXTENSIONRIGHT_GO_BTN,
	IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP,
	IDC_RADIAL_EXTENSIONLEFT_BG,

	//-- SHARED: SELECTION TREE
	IDC_SHARED_UI_TREE_SELECTOR,

	//-- MAP OVERLAY
	IDD_MAP_OVERLAY,

	//-- MAP: TOP CONTROLS
	IDC_MAP_TOP_DISBAND_IMG,

	//-- MAP: UFSB SUBSELECTION
	IDC_MAP_UFSB_Subselection_01_Parent,
	IDC_MAP_UFSB_Subselection_01_IMG_01,
	IDC_MAP_UFSB_Subselection_01_IMG_02,
	IDC_MAP_UFSB_Subselection_02_BTN_01,
	IDC_MAP_UFSB_FRAME,
	IDC_MAP_UFSB_STANCE_TRAVEL_IMG,
	IDC_MAP_UFSB_WP_SPEED_IMG,
	IDC_MAP_UFSB_STANCE_ARRIVAL_IMG,
	IDC_MAP_UFSB_COMBATMODE_IMG,
	IDC_MAP_UFSB_WPACTION_IMG,
	IDC_MAP_UFSB_Subselection_01_IMG_03,
	IDC_MAP_UFSB_WPCONDITION_IMG,
	IDC_MAP_UFSB_WPFORMATION_IMG,
	IDC_MAP_UFSB_UNDO_IMG,
	IDC_MAP_UFSB_CANCEL_IMG,
	IDC_MAP_UFSB_Subselection_01_IMG_05,
	IDC_MAP_UFSB_Subselection_01_IMG_04,
	IDC_MAP_UFSB_HOLD_IMG,
	IDC_MAP_UFSB_CONTINUE_IMG,

	//-- MAP: HIGH COMMAND GROUP CONTEXT MENU
	IDC_MAP_HCGP_Parent,
	IDC_MAP_HCGP_STANCES_AUTO_IMG,
	IDC_MAP_HCGP_LISTBOX_BEHAVIOUR,
	IDC_MAP_HCGP_LISTBOX_COMBATMODE,
	IDC_MAP_HCGP_LISTBOX_FORMATION,
	IDC_MAP_HCGP_LISTBOX_TEAMCOLOR,
	IDC_MAP_HCGP_CONFIRM_BG,

	IDC_MAP_HCGP_ActionMacro_0_BG,
	IDC_MAP_HCGP_ActionMacro_0_IMG,
	IDC_MAP_HCGP_ActionMacro_0_BTN,

	IDC_MAP_HCGP_ActionMacro_1_BG,
	IDC_MAP_HCGP_ActionMacro_1_IMG,
	IDC_MAP_HCGP_ActionMacro_1_BTN,

	IDC_MAP_HCGP_ActionMacro_2_BG,
	IDC_MAP_HCGP_ActionMacro_2_IMG,
	IDC_MAP_HCGP_ActionMacro_2_BTN,

	//-- MAP: HIGH COMMAND WAYPOINT CONTEXT MENU
	IDC_MAP_HCWP_Parent,
	IDC_MAP_HCWP_Completion_Parent,
	IDC_MAP_HCWP_Condition_Pre_Type,
	IDC_MAP_HCWP_Action_Parent_MAIN,
	IDC_MAP_HCWP_Condition_Post_Type,
	IDC_MAP_HCWP_Type_Parent,
	IDC_MAP_HCWP_Type_Action,

	//-- MAP: GO-CODES
	IDC_MAP_Order_GoCode_A_BTN,
	IDC_MAP_Order_GoCode_D_IMG,

	//-- MAP: DYNAMIC COMBO
	IDC_MAP_DynamicCombo,

	//-- SHARED: DASHBOARD
	IDC_SHARED_UI_DASHBOARD_PARENT,
	IDC_SHARED_UI_DASHBOARD_BG,

	//-- SHARED: SELECTION PROMPT
	IDD_SELECTION_PROMPT_PANEL,
	IDC_SHARED_UI_SelectionPromptPanel_Parent,
	IDC_SHARED_UI_SelectionPromptPanel_ListBox
];


A3C_HC_isGroupIdle = {
	params ["_group"];
	{_x select 1 == currentWaypoint _group} count (waypoints _group) == 0
};

{_x allowDamage false} foreach allunits;

lesson_selector = {
	
	o1 setPosASL [8108.99,10126.9,30.1371]; o1 setDir 91;
	player setposASL [8114.55,10128.5,30.1371]; player setDir 273;
	[] spawn {
		player selectWeapon (primaryWeapon player);
		sleep 2;
		player action ["WeaponOnBack", player];
	};
	UNLOCKED_LESSONS = ["RADIAL_1","STRATEGIC_1","STRATEGIC_2","RADIAL_2","RADIAL_3"]; //profileNameSpace getVariable ["A3C_TUTORIAL_LESSONS",[]];
	A3C_CURRENT_COMMAND_LEVEL = "SQUAD";
	player switchCamera "INTERNAL";
	private _unlocked = [];
	{
		switch (_x) do {
			case ("RADIAL_1") : {
				_unlocked pushBack
				[
					[7779,10500,0],
					{
						[A3C_TUTORIAL_UI_VARIABLES] execFSM "FSM\LESSON_02_SQUAD_RAD_01.fsm";
					},
					"LESSON 2",
					"Learn how to use the radial menu to quickly accomplish tasks on SQUAD and HIGH COMMAND levels.",
					"SQUAD RADIAL - 1",
					"img\LESSON_02_SQUAD_RAD_01.paa",
					1.5,
					[ player ]
				];
			};
			case ("RADIAL_2") : {
				_unlocked pushBack
				[
					[7779,10200,0],
					{[A3C_TUTORIAL_UI_VARIABLES] execFSM "FSM\LESSON_03_SQUAD_RAD_02.fsm";},
					"LESSON 3",
					"Learn how to use the radial more in the field",
					"SQUAD RADIAL - 2",
					"img\LESSON_03_SQUAD_RAD_02.paa",
					1.5,
					[ player ]
				];
				
			};
			case ("STRATEGIC_1") : {
				_unlocked pushBack
				[
					
					[7779,9900,0],
					{[A3C_TUTORIAL_UI_VARIABLES] execFSM "FSM\LESSON_04_SQUAD_STRATEGIC.fsm";},
					"LESSON 4",
					"Learn how to use the map control elements to construct detailed plans for SQUAD operations.",
					"STRATEGIC [SQUAD]",
					"img\LESSON_04_SQUAD_STRATEGIC.paa",
					1.5,
					[ player]
				];
			};
			
			case ("STRATEGIC_2") : {
				_unlocked pushBack
				[
					[7779,9600,0],
					{[A3C_TUTORIAL_UI_VARIABLES] execFSM "FSM\LESSON_05_HC_STRATEGIC.fsm";},
					"LESSON 5",
					"Learn how to use the map control elements to construct detailed plans for HIGH COMMAND operations.",
					"STRATEGIC [HIGH COMMAND]",
					"img\LESSON_05_HC_STRATEGIC.paa",
					1.5,
					[ player ]
				];
			};
			case ("RADIAL_3") : {
				_unlocked pushBack
				[
					[7779,9300,0],
					{[A3C_TUTORIAL_UI_VARIABLES] execFSM "FSM\LESSON_06_HC_RADIAL.fsm";},
					"LESSON 6",
					"Learn how to use the radial to control High Command Assets in 3D space",
					"RADIAL [HIGH COMMAND]",
					"img\LESSON_06_HC_RADIAL.paa",
					1.5,
					[ player ]
				];
			};	
		};
	} foreach UNLOCKED_LESSONS;
	
	
	
	
	
	[
		findDisplay 46,
		[8000,9800,0],
		LESSON_ARRAY + _unlocked,
		[],
		[], 
		[
			[
				"\A3\Ui_f\data\Logos\arma3_white_ca.paa",
				[0,1,0,1],
				[4000,4000,0],
				8,
				8,
				0,
				"Arma 3 Logo",
				true
			]
		],
		0.5,
		false,
		1,
		true,
		"Select Lesson",
		false
	] call BIS_fnc_StrategicMapOpen;
};


LESSON_ARRAY =
[
	[
		[7779,10800,0],
		{[A3C_TUTORIAL_UI_VARIABLES] execFSM "FSM\LESSON_01_SQUAD_MOVE.fsm";},
		"LESSON 1",
		"Learn how to precisely position your squad in 3D-space with the help of visual indicators.",
		"TACTICAL MODE",
		"img\LESSON_01_SQUAD_MOVE.paa",
		1.5,
		[ player ]
	]
];


fnc_interrupt = {
	params ["_sentence"];
	setAccTime 1;
	o1 = [o1] call A3C_Replace_Officer;
	o1 kbAddTopic ["Lesson1", "kb\Lesson1.bikb", ""];
	o1 kbTell [p1, "Lesson1", _sentence];
	o1 setIdentity "CROSSROADS";
};


ENEMIES = [];

"arty_mark" setMarkerAlpha 0;

ENEMY_DATA = {
	{deleteVehicle _x} foreach ENEMIES;
	ENEMIES = [];
	{
		_x params ["_pos","_dir","_stance"];
		_gp = creategroup EAST;
		_unit = _gp createUnit ["O_SOLDIER_VR_F", [0,0,0], [], 0, "FORM"];
		_unit setPosASL _pos;
		switch (_stance) do {
			case ("STAND") : {_unit setUnitPos "UP"};
			case ("CROUCH") : {_unit setUnitPos "MIDDLE"};
			case ("PRONE") : {_unit setUnitPos "DOWN"};
		};
		ENEMIES pushBackUnique _unit;
		_unit disableAI "PATH"; 
		_unit addeventhandler
		[
			"FIRED",
			{
				deletevehicle (_this select 6);
				HAS_FIRED = true;
			}
		];
		_unit allowdamage false;
		_unit setcaptive true;
		_unit setDir _dir;
		_unit addVest "V_Chestrig_oli";
		_unit addMagazine "30Rnd_556x45_Stanag";
		_unit addMagazine "30Rnd_556x45_Stanag";
		_unit addWeapon "arifle_TRG21_F";

	} foreach _this; 	
};

vehicle_fnc = {
	params ["_vehData","_addCrew"];
	{
		_x params ["_type","_pos","_dir"];
		_veh = createVehicle [_type, [0,0,0], [], 0, "NONE"];
		_veh setDir _dir;
		_veh setPosASL _pos;
		_veh addEventHandler
		[
			"HandleDamage",
			{
				params ["_vehi", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
				0
			}
		];
		TUT_VICS pushBackUnique _veh;
		if (_addCrew) then {
			_cg = createVehicleCrew _veh;
			{_x allowDamage false} foreach units _cg;
		};
	} foreach _vehData;
};

indicate_icon = {
	params ["_ctrl","_color"];
	FLASHTEXT = ctrlText _ctrl;
	_color = if (isNil '_color') then {A3C_UI_COLOR_YELLOW} else {_color};
	for "_i" from 1 to 3 do {
		if (FLASHTEXT != ctrlText _ctrl) exitWith {};
		_ctrl ctrlSetTextColor _color;
		sleep 0.2;
		_ctrl ctrlSetTextColor [1,1,1,1];
		sleep 0.2;
	};
};




MCSS_C2TUT_getCBABind = {
	private ["_bind","_return"];
	params ["_fnc"];
	if (true) exitWith {
		_return = ["A3C",_fnc] call A3C_ui_shared_fnc_getKeybindTranslation;
		_return
	};
	
	
	_return = "";
	_bind = (["A3C", _fnc] call CBA_fnc_getKeybind) select 5;
	if ((_bind select 1) select 0) then {_return = _return + "SHIFT+"};
	if ((_bind select 1) select 1) then {_return = _return + "CTRL+"};
	if ((_bind select 1) select 1) then {_return = _return + "ALT+"};
	_return = _return + ([(_bind select 0)] call BIS_fnc_keyCode);
	_return

};




NEW_LOCATION = {
	params ["_pos","_dir","_units","_orientation","_doFadeOut","_playerPosData","_date"];
	private _spacing = if (count _this > 7) then {_this select 7} else {2};
	if (_doFadeOut) then {
		sleep 2;
	};
	player selectWeapon (primaryWeapon player);
	
	if (!isNil '_playerPosData') then {
		player setpos (_playerPosData select 0);
		player setDir (_playerPosData select 1);
	} else {
		player setpos _pos;
		player setDir (_dir + 130);
	};
	
	//[_units,true,false] call A3C_ai_shared_fnc_cancelUnitPlot;
	{dostop _x; _x setUnitPos "UP";} foreach (units player - [player]);
	_relDir = if (_orientation == "FWD") then {_dir} else {_dir + 180};
	
	_respos = _pos getPos [10, _relDir];
	_respos = _respos getPos [3, _dir + 90];
	_d = 0;

	for "_i" from 1 to (count _units) do {
		_u = _units select (_i - 1);
		_u setPos (_respos getPos [_spacing * _d, _dir -90]);
		_u lookat (_u getPos [200,_dir]);
		_u doMove (position _u);
		_d = _d + 1;
		if (_i != 0 && {_i %4 == 0}) then {
			_respos = _respos getpos [2, _dir - 180];
			_d = 0;
		};
	};
	
	[] spawn {
		private _timer = time;
		while {time < _timer + 7} do {
			if (!weaponLowered player) then {
				player action ["WeaponOnBack", player];
			};
			sleep 0.5;		
		};
	};

	sleep 2;

	{
		if (side _x == resistance) then {
			_x setVariable ["A3C_HC_BLACKLIST",true,true];
		};
	} foreach allgroups;

	setDate _date;
	titlecut ["","black in",2];
	sleep 2;
	cutRsc ["TutorialHint", "PLAIN"];
};



choose_progress = {
	titlecut ["","black out",2];
	sleep 2;
	player setpos [7472.68,10550.7,0.00143814];
	player setdir 3.25528;
	
	titlecut ["","black in",2];
	sleep 2;
	cutRsc ["TutorialHint", "PLAIN"];
	((uiNamespace getVariable "TutorialHint") displayCtrl 50001) ctrlSetText "If you are ready to go on, shoot the green billboard. If you want to repeat the last lesson, shoot the red one.";
};


A3C_Replace_Officer = {
	//-- purpose: completely replace a soldier that is in STOP mode
	params ["_unit"];
	if !(_unit == driver vehicle _unit) exitWith {};
	

	
	
	_hasParent = !isNull objectParent _unit;
	_vehicle = vehicle _unit;
	
	//-- retrieve unit data
	_type = typeOf _unit;
	_name = name _unit;
	_dir = getDir _unit;
	_anim = animationState _unit;
	_face = face _unit;
	_pos = getPosASL _unit;
	_stance = stance _unit;
	_face = face _unit;
	_VVN = vehicleVarname _unit;
	private _gp = group _unit;
	_vehicle = vehicle _unit;

	_fatigueAndStamina = [getFatigue _unit, getStamina _unit];
	_isStaminaEnabled = isStaminaEnabled _unit;
	_destination = expectedDestination _unit;
	
	

	

	_damage = [];
	{
		_damage pushBack [_x,_unit getHitPointDamage _x];
	} foreach A3C_HUMAN_HITPOINTS;
	
	_loadOut = getUnitLoadOut _unit;
	_allVariables = [];
	{
		_allVariables pushBack [_x,_unit getVariable _x];
	} foreach allVariables _unit;
	

	//-- delete unit, spawn logics until unit's formationIndex is reached, then spawn new unit and delete logics
	deleteVehicle _unit;
	_newUnit = _gp  createUnit [_type, [0,0,0], [], 0, "FORM"]; 

	
	//-- reEstablish Damage
	for "_i" from 0 to 9 do {
		_hitPointArray = _damage select _i;
		_newUnit setHitPointDamage [_hitPointArray select 0, _hitPointArray select 1];
	};

	if (_hasParent) then {
		_newUnit moveInDriver _vehicle;
	} else {
		_newUnit setDir _dir;
		_newUnit setPosASL _pos;
		_newUnit switchMove _anim;
	};
	
	//-- reset fatigue
	_newUnit setFatigue (_fatigueAndStamina select 0);
	_newUnit setStamina (_fatigueAndStamina select 1);
	_newUnit enableStamina _isStaminaEnabled;
	_newUnit setPitch 1; 

	
	switch (_stance) do {
		case ("STAND") : {_newUnit setUnitPos "UP"};
		case ("CROUCH") : {_newUnit setUnitPos "MIDDLE"};
		case ("PRONE") : {_newUnit setUnitPos "DOWN"};
	};





	

	_nameStringArray = _name splitString " ";
	_firstName = _nameStringArray deleteAt 0;
	_lastName = _nameStringArray joinstring " ";
	_name = [_firstName + " " + _lastName,_firstName,_lastName];
	

	
	[_newUnit,_vvn,_name,_loadout,_face,_destination] spawn {
		params ["_unit","_vvn","_name","_loadout","_face","_destination"];
		_unit setVehicleVarname _VVN;
		_unit setName _name;		
		_unit setUnitLoadout _loadOUt;
		_unit setFace _face;
		_unit setDestination _destination;
	};
	_newUnit
};


//-- Team Color pre-assignment

full_teamcolors = {
	{
		_color = "RED";
		if (_foreachIndex > 3) then {
			_color = "GREEN";
		};
		if (_foreachIndex > 7) then {
			_color = "BLUE";
		};
		_x assignTeam _color;
	} foreach units player - [player];

};


restore_loadout = {
	params ["_unit"];
	removeAllWeapons _unit;
	
	{
		_unit removeItem _x;
	} foreach (items _unit);
	_loadout = _unit getVariable ["A3C_LOADOUT",[]];
	if (_loadout isequalto []) exitWith {};
	_loadout params ["_weapons","_uniform","_vest","_backPack","_uniformItems","_vestItems","_backpackItems","_assignedItems"];
	_unit forceAddUniform _uniform;
	_unit addVest _vest;
	removeBackPack _unit;
	_unit addBackpack _backpack;
	{
		_unit removeMagazine _x;
	} foreach (magazines _unit);	
	{_unit addWeapon _x} foreach _weapons;
	{_unit addItemToUniform _x} foreach _uniformItems;
	
	{_unit addItemToBackpack _x} foreach _backpackItems;
	{_unit addItem _x; _unit assignItem _x} foreach _assignedItems;
	{_unit addItemToVest _x} foreach _vestItems;
	_unit spawn {
		for "_i" from 1 to 3 do {
			reload _this;
			sleep 5;
		};
	};
};


tutorial_drawHudUI = {
	disableserialization;
	if (tutorial_icon_type != "") then {
		drawIcon3D  
		[ 
			tutorial_icon_type,				
			tutorial_icon_color, 
			tutorial_icon_pos,  
			1,  
			1,  
			0,
			tutorial_icon_text,
			0,
			0.05,
			"PuristaMedium",
			"right",
			true
		];
	};
};



reset_hudImage = {
	tutorial_icon_type = "";
	tutorial_icon_color = [1,1,1,1];
	tutorial_icon_pos = [0,0,0];
	tutorial_icon_text = "";
};
[] call reset_hudImage;
if (!isNil 'TUT_DRAW_HUD') then {removeMissionEventHandler ["Draw3d",TUT_DRAW_HUD];};
TUT_DRAW_HUD = addMissionEventHandler
[
	"Draw3D",
	{
		[] call tutorial_drawHudUI;
	} 
]; 

//--------------------- MISSION SETUP

 (group player) setGroupID ["SPLND TEAM"]; 
 
 {_x enablefatigue false; _x allowDamage false } foreach units player; 
 
 {dostop _x} foreach (units player - [player]);
o1 setunitpos "UP";

{
	{
		_weapons = weapons _x;
		_uniform = uniform _x;
		_vest = vest _x;
		_backPack = backpack _x;
		_uniformItems = uniformItems _x;
		_vestItems = vestItems _x;
		_backpackItems = (backpackItems _x) + (secondaryWeaponMagazine _x);
		_assignedItems = assignedItems _x;
		_x setVariable ["A3C_LOADOUT",[_weapons,_uniform,_vest,_backPack,_uniformItems,_vestItems,_backpackItems,_assignedItems]];
	} foreach units _x;
} foreach [gp1,gp2,gp3];


init_position = {
	private _data =
	[
		[r1,[8316.93,10045.5,28.6388]],
		[r2,[8318.4,10042.5,28.5671]],
		[r3,[8315.03,10040.8,28.7247]],
		[r4,[8318.31,10038.5,28.5679]],
		[g1,[8316.62,10035.6,28.5549]],
		[g2,[8318.15,10032.7,28.3422]],
		[g3,[8315.16,10031.2,28.586]],
		[g4,[8317.05,10027.9,28.4052]],
		[b1,[8315.75,10022.3,28.7904]],
		[b2,[8317.31,10019.3,28.8414]],
		[b3,[8314.12,10018.9,28.8414]],
		[b4,[8316.65,10016.1,28.8414]]
	];
	{
		(_x select 0) setPosASL (_x select 1);
	} foreach _data;
};

_data = [];
	{
		_data pushBack [_x,getPosASL _x]
	} foreach [r1,r2,r3,r4,g1,g2,g3,g4,b1,b2,b3,b4];




//-- Tutorial preparation
TUTORIAL_REPEAT = false;
TUTORIAL_CONTINUE = false;

TUTORIAL_DEBUG = true;



//setdate [2020,8,13,3,16]; 0 setOvercast 0.7; 0 setRain 0; 0 setfog 0;  setwind [0,0,true]; forceWeatherChange;  999999 setRain 0;



WIP_SKIP = false;


//AskPlayerToContinue = false;
//[] call full_teamcolors;



p1 kbAddTopic ["Lesson1", "kb\Lesson1.bikb", ""];
o1 kbAddTopic ["Lesson1", "kb\Lesson1.bikb", ""];


waituntil {!isNil "bis_fnc_init"};

o1 forceSpeed 2;
[] spawn {
	sleep 5;
	while {alive o1} do {
		o1 reveal [player,4];
		o1 lookat (o1 getPos [100,o1 getDir player]);
		sleep 2;

	};
};





private _scr = [v1, "AFB COLUMBUS - MALDEN", 5, 35, 90, 0, [], 0, true,10] spawn BIS_fnc_establishingShot;
waituntil {scriptDone _scr};
titlecut ["","black faded",0];
sleep 1;
[] call lesson_selector;

{deleteVehicle _x} foreach [v1,v2,v3,v4,v5,v6,v7];

//sleep 3;
//[] execVM "a3c_fncs.sqf";



(group o1) setVariable ["A3C_HC_BLACKLIST",true,true];


////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////



A3C_Tutorial_fnc_loadLauncher = {
	params ["_unit"];

	private _launcher = secondaryWeapon _unit;

	if (
		_launcher isEqualTo ""
		|| {secondaryWeaponMagazine _unit isNotEqualTo []}
	) exitWith {};

	private _compatibleMagazines = compatibleMagazines _launcher;

	if (_compatibleMagazines isNotEqualTo []) then {
		_unit addWeaponItem [
			_launcher,
			_compatibleMagazines select 0,
			true
		];
	};

};



#include "..\script_component.hpp" 
#include "..\dialog_defines.hpp" 

#include "..\..\SHARED\shared_ui_defines.hpp" //-- SHARED DEFINES FOR DASHBOARD
#include "..\..\SHARED\selectionPromptPanel\dialog_defines.hpp"


if (isDedicated) exitWith {};


A3C_Map_HC_groupContext_Behaviour = "";
A3C_Map_HC_groupContext_CMode = "";
A3C_Map_HC_groupContext_Form = "";
A3C_Map_HC_groupContext_Color = "";

A3C_SELECTED_HC_GROUPS_SETTINGS = [];
A3C_CONVOYGROUPS = [];

A3C_HC_NearStatics = [];



A3C_HC_GroupMenu_SuppressionRequested = false;

A3C_ALLOW_HCrEFRESH = true;





A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_WIPE = {
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_0 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_1 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_2 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_3 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_4 = [[],{}];

	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_5 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_6 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_7 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_8 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_9 = [[],{}];
};

[] call A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_WIPE;



A3C_MAP_fnc_GroupMenu_Action_BTN = {
	params["_data","_mode","_buttonArray"];
	_buttonArray params ["_buttonImage","_buttonClicker"];
	_fncArray = call compile format ["A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_%1",_mode];
	[_data,_buttonArray,(_fncArray select 0)] spawn (_fncArray select 1);
	[] spawn { sleep 0.1; [false] call A3C_MAP_fnc_GroupMenu_LabelActionButtons};

	/*
	switch (_mode) do {
		case (0) : {
			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_0 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_0 select 1);
		};
		case (1) : {
			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_1 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_1 select 1);
		};
		case (2) : {
			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_2 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_2 select 1);
		};
		case (3) : {

			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_3 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_3 select 1);
		};
		case (4) : {
			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_4 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_4 select 1);
		};

	};
	*/
};


A3C_HC_engineOffUnits = [];















A3C_AI_HIGHCOMMAND_fnc_Unstuck = {
	if (count A3C_SELECTED_HC_GROUPS_SETTINGS != 1) exitWith {
		systemChat "A3C: Unstuck is only available for single selections";
	};
	private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	(units _gp) spawn A3C_ai_shared_fnc_actionUnstuck;

};



A3C_UI_MAP_FNC_HCGPContext_OpenMenu = {
	params ["_group","_modeNum"];
	private ["_a3c_dsp"];
	A3C_HC_NearStatics = [];

	private _a3c_dsp = IDD_MAP_OVERLAY;

	
	

	_startBar = findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_STARTUP_BAR;
	_startText = findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_STARTUP_TEXT;
	_startText ctrlSetText "CONNECTING";
	_startBar progressSetPosition 0.1;
	{
		_x ctrlShow true;
	} foreach [_startBar,_startText];



	_groupMenuCtrlsGroup = (findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_Parent);
	_groupMenuCtrlsGroup ctrlShow false; //-- hide until dashboard is shown
	_groupMenuCtrlsGroup ctrlSetPosition 
	[
		0.5,
		0.3
	]; //_menuPos;
	_groupMenuCtrlsGroup ctrlCommit 0;


	{
		if (isplayer leader _x && {!(leader _x == player)}) then { //&& {(leader _x) != player}  CHANGE THIS TO WORK ON PLAYER GROUP FOR SINGLE SELECTION!!
			A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_HC_GROUPS_SETTINGS - [_x];
			systemchat format ["A3C: %1 is controlled by another player",_x];
		};
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) exitWith {};

	private _gp = grpNull;

	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
		_gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;



		private _groupStance = _group getVariable ["A3C_GROUP_STANCE","AUTO"];
		[_groupStance] call A3C_GP_Btns_Stances; //-- WHY>?
	} else {

		{
			_x ctrlSetTextColor [1,1,1,0.1];
		} forEach (["map_hcgp_imgs_Stance"] call FUNC(ctrlGroup));
	};

	
	
	
	





	disableSerialization;

	if (_modeNum == 0) then {
		A3C_Map_HC_groupContext_Color = _group getVariable ["A3C_HC_GroupColor","blue"];
	};
	{
		_ctrl = (findDisplay _a3c_dsp displayCtrl (_x select 0));
		lbClear _ctrl;
		private _forInd = _forEachIndex;
		[_ctrl, -1] call A3C_ui_shared_fnc_lbSetCurSel;
		{
			[_ctrl, _x] call A3C_ui_shared_fnc_addLbEntry;
			if (_modeNum == 0) then {
				switch (_forInd) do {
					case (0) : {
						if (behaviour (leader _group) == _x) then {
							
							A3C_Map_HC_groupContext_Behaviour = _x;
							[_ctrl, _forEachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
						};
					};
					case (1) : {
						{
							if (combatMode _group == _x) then {
								
								A3C_Map_HC_groupContext_CMode = _x;
								[_ctrl, _forEachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
							};
						} foreach ["BLUE","GREEN","WHITE","YELLOW","RED"];
					};
					case (2) : {
						if (formation _group == _x) then {
							
							A3C_Map_HC_groupContext_Form = _x;
							[_ctrl, _forEachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
						};
					};
					case (3) : {
						if ( (_group getVariable ["A3C_HC_GroupColor","Blue"]) == _x) then {
							A3C_Map_HC_groupContext_Color = _x;
							[_ctrl, _forEachIndex] call A3C_ui_shared_fnc_lbSetCurSel;

						};
					};
				};
			};
		} foreach (_x select 1);
	} foreach
		[
			[IDC_MAP_HCGP_LISTBOX_BEHAVIOUR,["Careless","Safe","Aware","Combat","Stealth"]], // "Careless (Driver)",
			[IDC_MAP_HCGP_LISTBOX_COMBATMODE,["Never Fire","Defend Only","Engage At Will","Fire At Will","F&E At Will"]],
			[IDC_MAP_HCGP_LISTBOX_FORMATION,["Column","Stag Column","Wedge","Ech Left","Ech Right","Vee","Line","File","Diamond"]],
			[IDC_MAP_HCGP_LISTBOX_TEAMCOLOR,["Red","Blue","Green","Black","White"]]
		];


	_startBar progressSetPosition 0.75;
	
	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
		[] call A3C_UI_SHARED_createDashBoard;

		waitUntil {
			isNull findDisplay _a3c_dsp ||
			{ ctrlShown (findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) }
		};

		private _display = findDisplay _a3c_dsp;
		if (isNull _display) exitWith {};

		private _dashboardCtrl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_BG;
		if (isNull _dashboardCtrl) exitWith {
			systemChat "layout failed: 11015 not found";
		};

		// Controls that define the top row above the listboxes.
		// Add every relevant control here if needed.
		private _topRowCtrls = [
			IDC_MAP_HCGP_STANCES_AUTO_IMG //-- reference point
		];

		// Extra conditional button macro
		
		private _showResponseButton = !(profileNamespace getVariable ["HC_GROUP_RESPONSE", false]);

		private _dashboardPos = ctrlPosition _dashboardCtrl;
		private _dashboardBottom = (_dashboardPos select 1) + (_dashboardPos select 3);

		// Find bottom edge of the top row
		private _topBoundary = -1;
		
		private _topRowRefCtrl = _display displayCtrl IDC_MAP_HCGP_STANCES_AUTO_IMG;
		if !(isNull _topRowRefCtrl) then {
			private _pos = ctrlPosition _topRowRefCtrl;
			private _bottom = (_pos select 1) + (_pos select 3);
			if (_bottom > _topBoundary) then {
				_topBoundary = _bottom;
			};
		};
		

		if (_topBoundary < 0) exitWith {
			systemChat "layout failed: no top row controls found";
		};

		// Height of the conditional bottom button area
		private _responseButtonH = 0;
		if (_showResponseButton) then {
			private _responseCtrl = _display displayCtrl IDC_MAP_HCGP_CONFIRM_BG;
			if !(isNull _responseCtrl) then {
				_responseButtonH = (ctrlPosition _responseCtrl) select 3;
			};
		};

		// Space available for the two listbox rows
		private _availableH = _dashboardBottom - _topBoundary - _responseButtonH;
		private _rowH = _availableH / 2;

		// Top row listboxes
		{
			private _ctrl = _display displayCtrl _x;
			if !(isNull _ctrl) then {
				private _pos = ctrlPosition _ctrl;
				_pos set [1, _topBoundary];
				_pos set [3, _rowH];
				_ctrl ctrlSetPosition _pos;
				_ctrl ctrlCommit 0;
			};
		} forEach [IDC_MAP_HCGP_LISTBOX_BEHAVIOUR, IDC_MAP_HCGP_LISTBOX_COMBATMODE];

		// Bottom row listboxes
		{
			private _ctrl = _display displayCtrl _x;
			if !(isNull _ctrl) then {
				private _pos = ctrlPosition _ctrl;
				_pos set [1, _topBoundary + _rowH];
				_pos set [3, _rowH];
				_ctrl ctrlSetPosition _pos;
				_ctrl ctrlCommit 0;
			};
		} forEach [IDC_MAP_HCGP_LISTBOX_FORMATION, IDC_MAP_HCGP_LISTBOX_TEAMCOLOR];

		// Conditional response button pair

		{
			private _ctrl = _display displayCtrl _x;
			if !(isNull _ctrl) then {
				private _pos = ctrlPosition _ctrl;

				if (_showResponseButton) then {
					_pos set [1, _dashboardBottom - _responseButtonH];
					_ctrl ctrlSetPosition _pos;
					_ctrl ctrlCommit 0;
					_ctrl ctrlShow true;
				} else {
					_ctrl ctrlShow false;
				};
			};
		} forEach [IDC_MAP_HCGP_CONFIRM_BG, IDC_MAP_HCGP_CONFIRM_BTN];
	};

	

	
	{
		_x ctrlShow false;
	} foreach [_startBar,_startText];
	
	_groupMenuCtrlsGroup ctrlShow true;

	if (profileNameSpace getVariable ["HC_GROUP_RESPONSE", false]) then {
		{
			(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
		} foreach [IDC_MAP_HCGP_CONFIRM_BG, IDC_MAP_HCGP_CONFIRM_BTN];	
	};

	
	[false] call A3C_MAP_fnc_GroupMenu_LabelActionButtons; //-- unfortunately has to happen after ctrl is shown

	playsound "ReadOutHideClick1"; 
	// ctrlSetFocus _groupMenuCtrlsGroup;
	
};





A3C_AI_HIGHCOMMAND_fnc_paraLoadAndDrop = {//mumu
	params ["_call"];
	private ["_vehicle","_cargoObjects"];
	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_SELECTION_PROMPT_PANEL};



	_vehicle = if (isNull _call) then {

			vehicle (leader (A3C_SELECTED_HC_GROUPS_SETTINGS select 0))

	} else {_call};


	if (((getPosATL _vehicle) select 2) > 1) then {
		//-- vehicle is airborne

		_vehicle setVariable ["A3C_ParadropActive",true,true];
		[false] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;

		[
			[getPlayerUID player, _vehicle],
			A3C_ai_shared_fnc_paradropManage
		] remoteExec ["bis_fnc_call", _vehicle];

	} else {
		//-- vehicle is on ground
		_cargoObjects = [_vehicle] call A3C_main_fnc_getNearCargoLoadObjects;
		if (count _cargoObjects > 0) then {

			A3C_SelectionPromptPanel_MODE = "PARALOAD";
			if (!isNull findDisplay IDD_RADIAL_MENU) then {
				A3C_DISABLE_RADIAL = true;
				[] call A3C_ui_radialMenu_fnc_closeDisplay;

				with uiNameSpace do {
					A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
				};

			} else {
				{(findDisplay IDD_MAP_OVERLAY displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
				(findDisplay 12 displayCtrl 51) ctrlEnable true;
			};

			_parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
			_text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
			_listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

			_parent ctrlShow true;
			_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
			_parent ctrlCommit 0;
			_text ctrlSetText "Select Object to load";
			ctrlSetFocus _listBox;
			
			lbClear _listBox;
			
			{
				private _lbText = format ["%1: %2 (%3m)",(getText (configfile >> "CfgVehicles" >> typeof _x >> "displayName")),if (count crew _x == 0) then {"Empty"} else {groupID group (crew _x select 0)},round(_vehicle distance _x)];
				[_listBox, _lbText] call A3C_ui_shared_fnc_addLbEntry;
			} foreach _cargoObjects;
		} else {
			systemchat "A3C: No loadable objects closeby";
		};

	};



};









A3C_AI_HIGHCOMMAND_fnc_mergeGroups = {
	params ["_groupArray"];
	if (count _groupArray == 0) exitWith {};
	A3C_SELECTED_HC_GROUPS_SETTINGS = +(_groupArray);
	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_SELECTION_PROMPT_PANEL};
	

	{(findDisplay IDD_MAP_OVERLAY displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
	if (count _groupArray <= 1) then {
		[_groupArray] spawn A3C_REJOIN_GROUPS;
	} else {
		if (_a3c_dsp == IDD_SELECTION_PROMPT_PANEL) then {
			with uiNamespace do {
				//disableSerialization;
				A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
			};
		};
		_parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
		_text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
		_listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;
		_parent ctrlShow true;
		_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
		_parent ctrlCommit 0;
		_text ctrlSetText format ["Really join %1 groups to your squad?",count A3C_SELECTED_HC_GROUPS_SETTINGS];
		A3C_SelectionPromptPanel_MODE = "SECU_REJOIN";
		lbClear _listBox;
		
		{
			[_listBox, _x] call A3C_ui_shared_fnc_addLbEntry;
		} foreach ["Cancel","Proceed"];
		

	};
};


A3C_REJOIN_GROUPS = {
	params ["_groups"];
	{
		private _units = units _x;
		A3C_HC_DISBANDED = A3C_HC_DISBANDED - [_x];
		(_x getvariable 'A3C_TAB_MARKER') setmarkeralphaLocal 1; //~~ still needed?
		{
			(vehicle _x) spawn {
				[_this,"LOCKED"] remoteExec ["setvehicleLock", _this];
				sleep 5;
				[_this,"UNLOCKED"] remoteExec ["setvehicleLock", _this];
			};
			[[_x],A3C_ai_highCommand_fnc_restoreUnitRole] remoteExec ["bis_fnc_spawn",_x];

		} foreach _units;
		_units join group player;
	} foreach _groups;
};




A3C_FlyinHeightArrayHeli = ["25","75","200","500"];
A3C_FlyinHeightArrayJet = ["30","100","500","1000","2000"];







A3C_Map_HC_groupContext_LB_Switch = {
	params ["_box","_lb","_display"];
	if (A3C_CurSel) exitWith {};
	private _immediateAction = [];
	switch (_box) do {
		case (IDC_MAP_HCGP_LISTBOX_BEHAVIOUR) : {
			A3C_Map_HC_groupContext_Behaviour = ["Careless","Safe","Aware","Combat","Stealth"] select _lb; //"Careless (Driver)",
			_immediateAction = ["setBehaviourStrong", A3C_Map_HC_groupContext_Behaviour];
		};
		case (IDC_MAP_HCGP_LISTBOX_COMBATMODE) : {
			A3C_Map_HC_groupContext_CMode = ["BLUE","GREEN","WHITE","YELLOW","RED"] select _lb;
			_immediateAction = ["setCombatMode", A3C_Map_HC_groupContext_CMode];
		};
		case (IDC_MAP_HCGP_LISTBOX_FORMATION) : {
			A3C_Map_HC_groupContext_Form = ["Column","Stag Column","Wedge","Ech Left","Ech Right","Vee","Line","File","Diamond"] select _lb;
			_immediateAction = ["setFormation", A3C_Map_HC_groupContext_Form];
		};
		case (IDC_MAP_HCGP_LISTBOX_TEAMCOLOR) : {
			A3C_Map_HC_groupContext_Color = ["Red","Blue","Green","Black","White"] select _lb;
			
		};
	};

	//-- potential immediate response
	if (profileNameSpace getVariable ["HC_GROUP_RESPONSE", false]) then {
		{
			private _group = _x;
			if (_box == IDC_MAP_HCGP_LISTBOX_TEAMCOLOR) then {
				_group setVariable ["A3C_HC_GroupColor",A3C_Map_HC_groupContext_Color,true];
			} else {
				// private _executingEntity = if (_box ) then {leader _group} else {_group};
				[_group, _immediateAction select 1] remoteExec [_immediateAction select 0, leader _group];
			};
		} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
	};
};


A3C_GP_Btns_Stances = {
	params ["_stance","_mode"]; //-- #TODO: _mode is always 1
	private _a3c_dsp = IDD_MAP_OVERLAY;
	A3C_GROUP_STANCE_Selected = _stance;
	if (profileNameSpace getVariable ["HC_GROUP_RESPONSE", false]) then {
		{
			{[_x,_stance] remoteExec ['setUnitPos',_x]} foreach units _x;
			_x setVariable ["A3C_GROUP_STANCE",_stance,true];
		} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
	};
	{
		_x ctrlSetTextColor [1,1,1,0.1];
	} forEach (["map_hcgp_imgs_Stance"] call FUNC(ctrlGroup));
	private _ModeButton = switch (_stance) do {
		case ("AUTO") : {IDC_MAP_HCGP_STANCES_AUTO_IMG};
		case ("UP") : {IDC_MAP_HCGP_STANCES_STAND_IMG};
		case ("MIDDLE") : {IDC_MAP_HCGP_STANCES_CROUCH_IMG};
		case ("DOWN") : {IDC_MAP_HCGP_STANCES_PRONE_IMG};
	};
	(findDisplay _a3c_dsp displayCtrl _ModeButton) ctrlSetTextColor [1,1,1,0.7];
};




A3C_Map_HC_groupContext_ButtonFnc_Confirm = {


	private _a3c_dsp = IDD_MAP_OVERLAY;
	(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;

	private _showPlayerHint = false;

	{
		private _ld = leader _x;
		if (isPlayer _ld && {_ld != player}) then {
			_showPlayerHint = true;

			// () remoteExec []; //#TODO: implement structured text hint solution
			
		} else {
			if (A3C_Map_HC_groupContext_Behaviour == "Careless (Driver)") then {
				{
					_s = _x;
					if (_s == driver vehicle _x) then {
						[_s,["BEHAVIOUR","CARELESS"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
					};
				} foreach (units _x);
			} else {
				if (A3C_Map_HC_groupContext_Behaviour != "") then {
					[leader _x,A3C_Map_HC_groupContext_Behaviour] remoteExec ["setBehaviourStrong", leader _x];
				};	
				if (A3C_Map_HC_groupContext_CMode != "") then {
					[leader _x,A3C_Map_HC_groupContext_CMode] remoteExec ["setCombatMode", leader _x];
				};
				
				if (A3C_Map_HC_groupContext_CMode == "RED") then {
					[_x,true] remoteExec ["enableAttack", leader _x];
				} else {
					[_x,false] remoteExec ["enableAttack", leader _x];
				};
				//_x setFormation A3C_Map_HC_groupContext_Form;
				if (A3C_Map_HC_groupContext_Form != "") then {
					[_x,A3C_Map_HC_groupContext_Form] remoteExec ["setFormation", leader _x];
					[_x,A3C_Map_HC_groupContext_Form] remoteExec ["setFormation", leader _x];
				};
				_x setVariable ["A3C_HC_GroupColor",A3C_Map_HC_groupContext_Color,true];
				//systemchat str (_x getVariable ["A3C_HC_GroupColor","oi"]);
				
				if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
					_ctrlText = ctrlText (findDisplay _a3c_dsp displayCtrl IDC_MAP_DASHBOARD_GROUPNAME_EDIT);
					if (groupID _x != _ctrlText) then {
						[_x,[_ctrlText]] remoteExec ["setGroupIDGlobal", leader _x];
						_button = _x getVariable ["A3C_TREESEL_INDEX",[]];
						
						if (count _button > 0) then {
							private _CT_TREE = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
							_button = _button select 0;
							_CT_TREE tvSetText [_button, _ctrlText];
						};
					};
					if (A3C_MAP_CommandMode == "HC") then {
						["HC"] call A3C_UI_MAP_UFSB_ApplyMode;
					};
				};
			};
			{[_x,A3C_GROUP_STANCE_Selected] remoteExec ['setUnitPos',_x]} foreach units _x;
			_x setVariable ["A3C_GROUP_STANCE",A3C_GROUP_STANCE_Selected,true];
		};
		
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	if (_showPlayerHint) then { //#TODO: implement this functionality of letting players know via structured text hint with desired formation, behavior etc
		[] spawn {
			hint "A3C: Player groups within selection have been notified of your orders. (Not implemented yet)";
			sleep 2;
			hintSilent "";
		};	
	};


	{(findDisplay IDD_MAP_OVERLAY displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
};















#include "..\..\ui\SHARED\shared_ui_defines.hpp"
#include "..\..\ui\radial\radialMenu\dialog_defines.hpp"
#include "..\..\ui\radial\radialMenu\script_component.hpp"






//---------------------------------------------------------------------------------------------
//---------- 1. Non positional actions --------------------------------------------------------
//---------------------------------------------------------------------------------------------


//---------------------------- MAP ONLY

A3C_AI_HighCommand_Action_joinPlayerGroup = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	//-- UI-Reaction
	if !(_isRadial) then {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	} else {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	};
	[A3C_SELECTED_HC_GROUPS_SETTINGS] call A3C_AI_HIGHCOMMAND_fnc_mergeGroups;
};

A3C_AI_HighCommand_Action_mergeGroups = {
	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
	// (findDisplay 12 displayCtrl 51) ctrlEnable true;
	A3C_isMergeGroupActive = true;
	hint "Click on the group to join";
	waituntil {!visibleMap OR {!(A3C_isMergeGroupActive)}};
	hint "";
	A3C_isMergeGroupActive = false;
};

A3C_AI_HighCommand_Action_heliHoverInPlace = {
	private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100060};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	
	private _var = (vehicle leader _group) getVariable ["A3C_Freeze_helicopter",[false,0]];


	if (_var select 0) then {
		//-- cancel action
		if !(_isRadial) then {
			{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
			(findDisplay 12 displayCtrl 51) ctrlEnable true;
		};
		{
			_vehicle = vehicle _x;
			if (_x == driver _vehicle && {[_vehicle] call A3C_fnc_isAttackHelicopter}) then {
				_vehicle setVariable ["A3C_Freeze_helicopter",[false,0],true];
				{_vehicle enableAI _x; } foreach ["TARGET","PATH"];
			};
		} foreach (units _group);
	};
};

//---------------------------- RADIAL ONLY




//---------------------------- SHARED (MAP+RADIAL)

A3C_AI_HighCommand_Action_RefreshGroup = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;

	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		//-- note: we still disable radial so that player needs to let go of key
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};

	//-- AI Action
	{
		_oldGroup = _x;
		_waypointData = [];
		_groupID = groupID _oldGroup;
		_wpIndex = 0;
		private _allVariables = (allVariables _oldGroup) apply {[_x, _oldGroup getVariable [_x,nil]]};
		{
			_wp = _x;
			if (_wp select 1 >= currentWaypoint _oldGroup ) then { //-- exclude first waypoint? && {_foreachIndex > 0}
				_waypointData set
				[
					_wpIndex,
					[
						waypointBehaviour _wp,
						waypointCombatMode _wp,
						waypointCompletionRadius _wp,
						waypointDescription _wp,
						waypointFormation _wp,
						waypointName _wp,
						waypointPosition _wp,
						waypointScript _wp,
						waypointSpeed _wp,
						waypointStatements _wp,
						waypointTimeout _wp,
						waypointType _wp,
						waypointVisible _wp
					]
				];
				_wpIndex = _wpIndex + 1;
			};
			
		} foreach (waypoints _oldGroup);


		_newGroup = createGroup (side _oldGroup);
		(units _oldGroup) joinSilent _newGroup;

		[_newGroup] call A3C_HC_ReInitGroupMovement;
		{
			_x params ["_name","_val"];
			if (!isNil '_newGroup') then {
				if (!isNil '_name') then {
					if (!isNil '_val') then {
						_newGroup setVariable [_name,_val,true]; //-- unfortunately there's no way to know if var was public or not :S > so we broadcast lol
					};
				};
			};				
		} foreach _allVariables;
		deleteGroup _oldGroup;
		_newGroup setGroupIdGlobal [_groupID];
		
	
		{
			_wpData = _x;
			_wp = _newGroup addWaypoint [[0,0,0],0];
			{
				_wpValue = _x;
				diag_log _wpValue;
				switch _foreachIndex do {
					case (0)  : {_wp setWaypointBehaviour _wpValue};
					case (1)  : {_wp setWaypointCombatMode _wpValue};
					case (2)  : {_wp setWaypointCompletionRadius _wpValue};
					case (3)  : {_wp setWaypointDescription _wpValue};
					case (4)  : {_wp setWaypointFormation _wpValue};
					case (5)  : {_wp setWaypointName _wpValue};
					case (6)  : {_wp setWaypointPosition  [_wpValue,0]};
					case (7)  : {_wp setWaypointScript _wpValue};
					case (8)  : {_wp setWaypointSpeed _wpValue};
					case (9)  : {_wp setWaypointStatements _wpValue};
					case (10) : {_wp setWaypointTimeout _wpValue};
					case (11) : {_wp setWaypointType _wpValue};
					case (12) : {_wp setWaypointVisible _wpValue};
				};
			} foreach _wpData;
		} foreach _waypointData;

		private _wpPos = waypointPosition [_newGroup, currentWaypoint _newGroup];
		if (_wpPos distance2D (vehicle leader _newGroup) > 20) then {
			[_newGroup,_wpPos] call A3C_HC_MoveToWaypoint; 
		};

		{
			{
				_x enableAI "ALL";
			} foreach [_x, objectParent _x];
		} foreach (units _newGroup);

		[_newGroup] call A3C_HC_ReInitGroupMovement; //-- backup brute force double right hook lol - probably not really needed.
		
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
};

A3C_AI_HighCommand_Action_VehicleRemote = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	if (_isRadial) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};
	
	[] call A3C_GP_RC_UIVehicleRemoteFnc;
};


A3C_AI_HighCommand_Action_ConvoyHalt = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	//-- UI-Reaction
	if (_isRadial) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
	};

	hint format ["%1 convoy(s) have been ordered to halt!", count A3C_GROUP_CONVOYS];

	{
		_convoyElement = _x;
		{
			private _gp = _x;
			[_gp, "ALL"] call A3C_HighCommand_deleteAllWaypoints;
			private _lv = vehicle leader _gp;
			private _effCom = effectiveCommander _lv;
			if (_effCom in (units _gp)) then {
				private _closePos = _lv getPos [10, getDir _lv];
				[_effCom, _closePos]  call A3C_DOMOVE;
			};
			(leader _gp) setBehaviour "COMBAT";
			{
				private _weaponsFound = false;
				private _oP = objectParent _x;

				if (!isNull _oP) then {
					if (currentWeapon _x != "") then {_weaponsFound = true};
				} else {
					private _turrentWeapons = _oP weaponsTurret ((_oP) unitTurret gunner _oP);
					if !(_turrentWeapons isEqualTo []) then {_weaponsFound = true};
				};
				if (_weaponsFound) exitWith {
					(leader _gp) setBehaviourStrong "COMBAT";
					(leader _gp) setCombatMode "RED";
				};
			} foreach (units _gp);
		} foreach _convoyElement;
		
		
	} foreach A3C_GROUP_CONVOYS;

	[] spawn {
		sleep 2;
		hintSilent "";
	};
	
	A3C_GROUP_CONVOYS = [];
	A3C_SELECTED_HC_GROUPS_SETTINGS = [];
};


A3C_AI_HighCommand_Action_DeleteGroups = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	//-- UI-Reaction
	if (_isRadial) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
	};

	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
		{
			private _gp = _x;
			if ({isPlayer _x} count(units _gp) == 0) then {
				[_gp] call A3C_DeleteGroup;
			} else {
				systemchat format ["A3C: Group %1 was not deleted. Players detected", groupID _gp];
			};
		} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
	} else {
		// if (visibleMap) then {
			(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_Parent) ctrlShow false;
			(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
		// } else {
		// 	with uiNamespace do {
		// 		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		// 	};
		// };
		["DELETE"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;
	};
	// A3C_SELECTED_HC_GROUPS_SETTINGS = [];
};

A3C_AI_HighCommand_Action_convoyCreate = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};
	//-- create convoy group
	[] spawn A3C_Map_HC_groupContext_ButtonFnc_Convoy;
};

A3C_AI_HighCommand_Action_convoyRejoin = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};
	//-- rejoin convoy
	[] spawn A3C_Map_HC_groupContext_ButtonFnc_Convoy;
};

A3C_AI_HighCommand_Action_limitSpeed = {
	A3C_OBJECTSELECTOR_MODE = "SPEEDLIMIT";
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;

	if (_isRadial) then {
		_a3c_dsp = 100060;
	};

	if (_isRadial) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
		with uiNamespace do {
			//disableSerialization;
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
			(findDisplay 100060 displayCtrl IDC_SHARED_UI_ObjectSelector_Description_TXT) ctrlSetText "Select Max Speed";
		};	
			
		private _parent = findDisplay 100060 displayCtrl IDC_SHARED_UI_ObjectSelector_Parent;
		private _listBox = findDisplay 100060 displayCtrl IDC_SHARED_UI_ObjectSelector_ListBox;
		private _text = findDisplay 100060 displayCtrl IDC_SHARED_UI_ObjectSelector_Description_TXT;

		_parent ctrlShow true;
		_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
		_parent ctrlCommit 0;
		_parent ctrlShow true;
		_text ctrlSetText "Select Max Speed";
		{
			private _ctrlPos = ctrlPosition _x;
			_ctrlPos set [3,(_ctrlPos select 3) + (  (4)   * (0.0440051 * safezoneH) )];
			_x ctrlSetPosition _ctrlPos;
			_x ctrlCommit 0;
		} foreach [_parent,_listBox];

		lbClear _listBox;
		{
			[_listBox, _x] call A3C_addLbEntry;
		} foreach ["FULL PACE","JOGGING PACE","COMBAT PACE","WALKING PACE"];			
			
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
		private _parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Parent;
		private _listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_ListBox;
		private _text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Description_TXT;
		_parent ctrlShow true;
		_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
		_parent ctrlCommit 0;
		_parent ctrlShow true;
		_text ctrlSetText "Select Max Speed";
		{
			private _ctrlPos = ctrlPosition _x;
			_ctrlPos set [3,(_ctrlPos select 3) + (  (4)   * (0.0440051 * safezoneH) )];
			_x ctrlSetPosition _ctrlPos;
			_x ctrlCommit 0;
		} foreach [_parent,_listBox];
		lbClear _listBox;
		{
			[_listBox, _x] call A3C_addLbEntry;
		} foreach ["FULL PACE","JOGGING PACE","COMBAT PACE","WALKING PACE"];
	};	
};

A3C_AI_HighCommand_Action_orderDetonation = {
	[] call A3C_UI_RADIAL_OBJECTSELECTOR_START_CHARGEDIALOG;
	A3C_HC_DetoTrigger_Units = nil; //~~ this whole var stoll needed?
};

A3C_AI_HighCommand_Action_reBoardGroupToVehicle = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};
	[A3C_SELECTED_HC_GROUPS_SETTINGS] spawn A3C_AI_HIGHCOMMAND_fnc_reboardGroupToVehicle;
};

A3C_AI_HighCommand_Action_chargeMavic = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};
	if (isClass (configFile >> "CfgVehicles" >> "mavic_3_BLU")) then {
		private _nearMavics = (player nearobjects 2) select {"mavic" in (toLower (typeOf _x))};
		if !(_nearMavics isEqualTo []) then {
			private _selectedDrone = _nearMavics select 0;
			[_selectedDrone, player] call mavic_fnc_changeBattery;
		};
	} else {
		private _nearMavics = (player nearobjects 2) select {"mavik" in (toLower (typeOf _x))};
		if !(_nearMavics isEqualTo []) then {
			private _selectedDrone = _nearMavics select 0;
			[_selectedDrone, player] call mavic_fnc_changeBattery;
		};
	};
};

A3C_AI_HighCommand_Action_vehicleSmoke = {
	// {
	// 	private _gp = _x;
	// 	private _gpDrivers = (units _gp) select {
	// 		private _oP = objectParent _x;
	// 		!isNull _oP && {
	// 			_x == driver _oP
	// 		};
	// 	};
	// 	private _gpVehicles = _gpDrivers apply {objectParent _x};
	// 	{
	// 		[[_x, 1], A3C_FireCounterMeasures] remoteExec ['bis_fnc_call', _x];
	// 	} foreach _gpVehicles;
	// } foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
	private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	private _leaderVic = vehicle leader _gp;
	[_leaderVic, 1] call A3C_FireCounterMeasures;
};

A3C_AI_HighCommand_Action_flyInHeight = {

	private _group = if (!isNull findDisplay IDD_RADIAL_MENU) then {A3C_RD_UNITS select 0} else {A3C_SELECTED_HC_GROUPS_SETTINGS select 0}; //~~ same same??
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100060};

	if (_a3c_dsp == 100060) then {
		with uiNameSpace do {
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		};
	};

	private _parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Parent;
	private _text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Description_TXT;
	private _listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_ListBox;

	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
	A3C_OBJECTSELECTOR_MODE = "flyInHeight"; //-- !! CHECK IF STILL NEEDED!
	lbClear _listBox;
	_parent ctrlShow true;
	_textSize = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);

					
	_text ctrlSetText "Select Flying-Height";

	private _heightArray = A3C_FlyinHeightArrayHeli;
	if ((vehicle leader _group) isKindOf "PLANE") then {
		_heightArray = A3C_FlyinHeightArrayJet;
	};
	[_parent,_listBox,count _heightArray] call A3C_OBJECTSEL_RESIZE;
	{
		[_listBox, _x] call A3C_addLbEntry;
	} foreach _heightArray;
};

A3C_AI_HighCommand_Action_suppressionStop = {
	{
		private _gp = _x;
		{
			private _u = _x;
			if (_u in A3C_SUPPRESSION_UNITS_AI) then {
				[[_u],"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
			};
		} foreach units _gp;

	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
};

A3C_AI_HighCommand_Action_reArm = {
	private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
						
	{[_x] spawn A3C_ReArm_Auto_Evaluate} foreach (units _gp);
	player groupradio 'SentCmdRearm';
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100060};

	if (!isNull findDisplay IDD_RADIAL_MENU) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_Parent) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
	};
};

A3C_AI_HighCommand_Action_groupHeal = {
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100060};

	if (!isNull findDisplay IDD_RADIAL_MENU) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_Parent) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
	};
	[A3C_SELECTED_HC_GROUPS_SETTINGS select 0] call A3C_AI_HIGHCOMMAND_fnc_groupHeal;
};

A3C_AI_HighCommand_Action_transferOwnership = {
	private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	private _transferFnc = {
		params ["_clientID","_group"];

		if (groupOwner _group != _clientID) then {
			//-- transfer ownership to client
			_group setGroupOwner _clientID;
			(format ["%1 has been transfered to your client", groupID _group]) remoteExec ['systemchat',_clientID];
		} else {
			//-- transfer ownership to server
			_group setGroupOwner 2;
			(format ["%1 has been transfered to the server", groupID _group]) remoteExec ['systemchat',_clientID];
		};
	};

	[[clientOwner, _group], _transferFnc] remoteExec ['bis_fnc_call', 2];
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100060};

	if (!isNull findDisplay IDD_RADIAL_MENU) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_Parent) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
	};
};

A3C_AI_HighCommand_Action_unAssembleWeapon = { // #TODO This fnc requires investigation >> Also used in HUD_UI.sqf

	params ["_mode"];
	if !(count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) exitWith {};
	
	private ["_group","_groupUnits","_wpn","_exit","_imgtext"];
	_group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	_groupUnits = units _group;
	_wpn = if (_mode == 0) then {objNull} else {_this select 1};


	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100060};



	//-- main display EH to disable radial until key is let go
	if (!isNull findDisplay IDD_RADIAL_MENU && _a3c_dsp == 100060 ) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_UI_RADIAL_CloseDisplay;
	};

	if (_a3c_dsp == 100060 && { {(vehicle _x) isKindOf "staticweapon"} count units _group == 0 }) then {
		with uiNamespace do {
			//disableSerialization;
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		};
	};


	_parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Parent;
	_text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Description_TXT;
	_listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_ListBox;
	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
	(findDisplay 12 displayCtrl 51) ctrlEnable true;


	if ( (_mode == 0) && (count A3C_HC_NearStatics > 0) && { {(vehicle _x) isKindOf "staticweapon"} count units _group == 0 }) exitWith {



		A3C_OBJECTSELECTOR_MODE = "STATIC_DISASSEMBLE_HC";
		lbClear _listBox;
		_parent ctrlShow true;
		[_parent,_listBox, count A3C_HC_NearStatics] call A3C_OBJECTSEL_RESIZE;
		
		//_parent ctrlCommit 0;
		_text ctrlSetText "Select Static Weapon";
		
		{
			private _lbText = (getText (configFile >> "CfgVehicles" >> (typeOf (vehicle _x)) >> "displayName"));
			[_listBox, _lbText] call A3C_addLbEntry;
		} foreach A3C_HC_NearStatics;
		
	};

	if (_a3c_dsp == 100060 && { {(vehicle _x) isKindOf "staticweapon"} count units _group == 0 }) then { //-- radial menu HC-disassemble: close menu
		(findDisplay 100060) closeDisplay 0;
		A3C_DISABLE_RADIAL = false;
	};

	private _exit = false;
	{
		_u = _x;
		if ((vehicle _x) isKindOf "staticweapon") exitWith { //-- only one weapon possible

			//_groupUnits = _groupUnits - [_x];
			_wpn = vehicle _x;
			//if ({ (backPack _x == "") && (_x distance (vehicle _u) < 30) && (isNull objectParent _x) } count _groupUnits > 0) then {
			if ([units _group,_wpn,true] call A3C_HC_canSelectionPickUpStatic) then {
				player commandRadio "SentDisAssemble";
				A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >>  (typeOf _wpn) >> "picture");
				A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
				[position _wpn,""] spawn A3C_UI_HUD_3D_TAG;

				systemchat format
				[
					"A3C: %1 is packing up their %2",
					groupId _group,
					(getText (configfile >> "CfgVehicles" >> (typeOf _wpn) >> "displayName"))
				];
			} else {
				_exit = true;
				systemchat format
				[
					"A3C: %1 can not be picked up. No units nearby with the capacity to pick up parts",
					(getText (configfile >> "CfgVehicles" >> (typeOf (vehicle _x)) >> "displayName"))
				];
			};
		};
	} foreach (units _group);
	if (_exit) exitWith {};
	if (isNull _wpn) exitWith {};

	{

		[[_x], A3C_AIGetOut] remoteExec ['bis_fnc_call', _x];
	} foreach crew _wpn;
	sleep 3;
	[
		(units _group),
		["DISASSEMBLE",_wpn],
		position _wpn,
		getDir _wpn
	] spawn A3C_WP_ACTION_STATICWEAPON;
};

A3C_AI_HighCommand_Action_animatePlow = {
	params ["_mode"];
	private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	private _leaderVic = vehicle (leader _gp);
	if (_mode == 0) then {
		_leaderVic animatesource ['moveplow', 1];
	} else {
		_leaderVic animatesource ['moveplow', 0];
	};	
};

A3C_AI_HighCommand_Action_lineCharge = {
	private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	private _leaderVic = vehicle (leader _gp);
	private _fnc_MCLC = {
		params ["_leaderVic"];
		[_leaderVic] execVM '\Bobcat_Fixed\scripts\LineCharge.sqf';
	};
	[[_leaderVic], _fnc_MCLC] remoteExec ['bis_fnc_spawn', _leaderVic];
};

A3C_AI_HighCommand_Action_vehicleEngineOff = {
	{
		[units _x] call A3C_AI_action_engineOff;
	} foreach A3C_HC_engineOffUnits;
};

A3C_AI_HighCommand_Action_vehicleLights = { //-- seems to not work currently?

	params ["_mode"]; //-- 0: On | 1: Off
	{
		private _gp = _x;
		{
			private _vehicle = objectParent _x;
			if (!isNull _vehicle && {_x == driver _vehicle}) then {
				[_vehicle, _mode] call A3C_Switch_Vehicle_Lights;
			};
		} foreach units _gp;
		_gp setVariable ["A3C_VehicleLightsOn",false,true];
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
};

A3C_AI_HighCommand_Action_irStrobe = {
	params ["_mode"]; //-- "ON" | "OFF"
	if !(A3C_Prevent_attach_IR) then {
		[_mode] spawn A3C_AI_action_toggleIrStrobeHC;
	} else {
		hint "Please wait for your last order instance to reach all units";
	};
};


A3C_AI_HighCommand_Action_irPointer = {
	params ["_mode"]; //-- "ON" | "OFF"
	if !(A3C_Prevent_attach_IR_Laser) then {
		["LASER",_mode] call A3C_fnc_toggle_WeaponAttachMent;
	} else {
		hint "Please wait for your last order instance to reach all units";
	};
};

A3C_AI_HighCommand_Action_weaponFlashLight = {
	params ["_mode"]; //-- "ON" | "OFF"
};


//---------------------------------------------------------------------------------------------
//---------- 2. Positional actions ------------------------------------------------------------
//---------------------------------------------------------------------------------------------

//---------------------------- RADIAL ONLY

/*//-------------------------------------------------------------------------------------------
	Positional Actions are spread up over multiple steps / UI-Elements
	1. Radial menu is used to issue the order
	2. HUD Keydown event (A3C_UI_HUD_onKeyDown)
		2.1 Pressing SPACE-key confirms the order
		2.2 Releasing TAB-Key cancels the order-planning
*///-------------------------------------------------------------------------------------------




//---------------------------- RADIAL ONLY

//----- Remote-Fire Actions 



A3C_AI_HighCommand_Action_remoteFire_VTOL_Weapon = {
	params ["_weapon"];
	private _aimpos = ATLtoASL(A3C_UI_HUD_3D_TAG_ICON_POS);
	private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	private _leaderVic = vehicle (leader _gp);
	private _array = [side player, _leaderVic, _aimpos, _weapon, objNull];
	[_array, A3C_REMOTE_BLACKFISH] remoteExec ['bis_fnc_spawn', _leaderVic];
	sleep 2;
	waituntil {true};
	if (!isNull findDisplay IDD_RADIAL_MENU && {(ctrlShown (findDisplay IDD_RADIAL_MENU displayctrl IDC_RADIAL_BG_TOP)) && {A3C_RADIALMODE in ['ACT','HC ACTIONS']}}) then {
		[false] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
	};
};


//----- Regular Radial Actions


A3C_AI_HighCommand_Action_uavFPV = {

	private _group = A3C_RD_UNITS select 0;
	private _wpPos = +(A3C_UI_HUD_3D_TAG_ICON_POS);
	

	//-- delete current waypoints
	[_group, "ALL"] call A3C_HighCommand_deleteAllWaypoints;
	private _ct = cursortarget;
	if (!isNull _ct) then {
		private _wp = _group addWaypoint [_wpPos,0];
		_wp setWaypointType "SCRIPTED";
		_wp waypointAttachVehicle _ct;
		_wp setWaypointSpeed "FULL";
		_wp setWaypointScript "A3C_CORE\fnc_AI\wpFncs\wpScript_UAV_FPV.sqf [getPlayerUID player]"; 
	} else {
		[] spawn {
			hint "NO TARGET SELECTED!";
			sleep 3;
			hintSilent "";
		};
	};
};

A3C_AI_HighCommand_Action_repair = {
	private _group = A3C_RD_UNITS select 0;
	private _wpPos = +(A3C_UI_HUD_3D_TAG_ICON_POS);

	[_group, "ALL"] call A3C_HighCommand_deleteAllWaypoints;
	private _wp = _group addWaypoint [_wpPos,0];
	_wp setWaypointType "SCRIPTED";
	_wp setWaypointScript "A3C_CORE\fnc_AI\wpFncs\wpScript_repair.sqf [getPlayerUID player, ['ARRIVAL', 0]]";
};

A3C_AI_HighCommand_Action_landAircraft = {
	A3C_RADIAL_ACTION_HC_LANDINGDATA = [];

	//("A3C_KEY_VIEWER_UI" call BIS_fnc_rscLayer) cutRsc ["","PLAIN"];
	with uiNamespace do {
		//disableSerialization;
		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
	};


	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100060};
	_parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Parent;
	_text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Description_TXT;
	_listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_ListBox;

	_text ctrlSetText "CHECKING LZ";
	lbClear _listBox;
	[_listBox, "KEEP TAB PRESSED DOWN"] call A3C_addLbEntry;




	_parent ctrlShow true;


	_requiresPlacementCorrection = true;
	_placerPos = getPosASL A3C_OBJECTPLACER;
	private _landingPosRoot = +(_placerPos);
	private _landingVector = [getDir A3C_OBJECTPLACER] call MCSS_fnc_DegreeToVector;

	_dimensions = [typeof A3C_OBJECTPLACER] call A3C_getVehicleBodyDimensions;
	_dimensions params ["_reference_Width","_reference_Length","_reference_Height","_reference_Rotorsize"];

	_forceDefaultLanding = true;

	_exit = false;
	if (!isNull A3C_SNAP_OBJECT) then {
		//-- position snapped against object

		//systemchat str (typeof A3C_SNAP_OBJECT);

		_placerPosZ = _placerPos select 2;
		_snapObjectPos = (getPosASL A3C_SNAP_OBJECT);

		_snapObjectZ = _snapObjectPos select 2;
		_snapObjectHeight = A3C_SNAP_OBJECT call BIS_fnc_objectHeight;

		_refPosTop = (_placerPos select [0,2]) + [_snapObjectZ + _snapObjectHeight]; //-- placer-pos at boundingBox top

		_ins = lineIntersectsSurfaces
		[
			_refPosTop,
			[_placerPos select 0,_placerPos select 1, 0],
			A3C_OBJECTPLACER,
			objNull,
			true,
			1,
			"GEOM",
			"NONE"
		];

		if (count _ins > 0) then {
			//helper setposASL ((_ins select 0) select 0);
			_intersectPosZ = ((_ins select 0) select 0) select 2;
			//systemchat str [_intersectPosZ,_placerPosZ];
			if (abs(_intersectPosZ - _placerPosZ) < 0.1) then {
				_requiresPlacementCorrection = false;
				_forceDefaultLanding = false;

			};
			if (_requiresPlacementCorrection) then {
				hint "ADJUSTING LZ";
				_LZData = [A3C_SNAP_OBJECT,_reference_Width,_reference_Length] call A3C_getHeliRoofLZ;
				[] spawn {
					hint "LZ ADJUSTED";
					sleep 5;
					hintSilent "";
				};
				if (count _LZData > 0) then {
					_landingPosRoot = _LZData select 0;
					_landingVector = [(_LZData select 1)] call MCSS_fnc_DegreeToVector;
					_forceDefaultLanding = false;




				};


				//systemchat str _LZData;
			};
		//} else {
		//	systemchat "NO INS";
		};
	} else {
		//-- position in the open
		_forceDefaultLanding = false;
		_requiresPlacementCorrection = false;
		_dummyBox = ([A3C_OBJECTPLACER,1] call MCSS_fnc_BBOX);
		_maxRotorHeight = 1000;
		{

			_z = (A3C_OBJECTPLACER modelToWorld (A3C_OBJECTPLACER selectionposition _x)) select 2;
			//systemchat str [_z];
			if (_z < _maxRotorHeight) then {
				_maxRotorHeight = _z;
			};
		} foreach ([A3C_OBJECTPLACER] call MCSS_fnc_getMainRotorSelections);

		_centerAtRotorHeight = getPosASL A3C_OBJECTPLACER;
		_centerAtRotorHeight set [2,_maxRotorHeight];
		_centerAtRotorHeight = ATLtoASL _centerAtRotorHeight;
		{
			_dist = A3C_OBJECTPLACER distance2d _x;
			_dir = A3C_OBJECTPLACER getDir _x;
			_ins = lineIntersectsSurfaces
			[
				_centerAtRotorHeight,
				[_centerAtRotorHeight,_dist,_dir] call BIS_fnc_relPos,
				A3C_OBJECTPLACER,
				objNull,
				true,
				1,
				"GEOM",
				"NONE"
			];
			if (count _ins > 0) exitWith {
				_exit = true;
			};
		} foreach _dummyBox;
	};

	if (_exit) exitWith {
		hint "THE SELECTED GROUND-LZ IS NOT SAFE - PLEASE REPEAT";
		sleep 5;
		hintSilent "";
		//deletevehicle A3C_OBJECTPLACER;
	};



	if !(_requiresPlacementCorrection) then {
		//systemchat "GOOD PLACEMENT";
		//-- could be on roof (!isNull snap_object) but might still need security checks
		//-- could be on ground and use same checks
	} else {
		//if !(_forceDefaultLanding) then {

		//};
		//systemchat "LZ WILL BE ADJUSTED";
		//-- snap_object detected and definitely requires correction
		//-- if (!isNull snap_object), use rooftop position generator
		//-- otherwise use simple, ASL-level security
	};



	if (_forceDefaultLanding) then {
		[] spawn {
			hint "ALERT: NO SUITABLE LZ FOUND ON OBJECT. REVERTING TO DEFAULT LANDING";
			sleep 5;
			hintSilent "";
		};
		A3C_RADIAL_ACTION_HC_LANDINGDATA = [];

	};

	A3C_RADIAL_ACTION_HC_LANDINGDATA = [_landingPosRoot,_landingVector,_forceDefaultLanding];

	A3C_OBJECTSELECTOR_MODE = "HELI_LANDING_HC_TYPE";



	_text ctrlSetText "SELECT LANDING TYPE";

	{
		_ctrlPos = ctrlPosition _x;
		_ctrlPos set [3,(_ctrlPos select 3) + (  (3)   * (0.0440051 * safezoneH) )];
		_x ctrlSetPosition _ctrlPos;
		_x ctrlCommit 0;
	} foreach [_parent,_listBox];

	ctrlSetFocus _listBox;

	lbClear _listBox;
	{
		[_listBox, _x] call A3C_addLbEntry;
	} foreach ["COMBAT LANDING","TRANSPORT UNLOAD","FULL LANDING"];
};

A3C_AI_HighCommand_Action_casStrike = {
	with uiNamespace do {
		//disableSerialization;
		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
	};


	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100060};
	
	private _parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Parent;
	private _text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Description_TXT;
	private _listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_ListBox;
	_text ctrlSetText "SELECT CAS-TYPE";

	A3C_OBJECTSELECTOR_MODE = "CAS";
	
	lbClear _listBox;
	{
		_leaderVic = vehicle leader _x;
		private _casModes = [typeof _leaderVic] call MCSS_fnc_getCASmodes;
		if (count _casModes > 0) exitWith {
			{
				_casMode = switch (true) do {
					case (_x isEqualTo ["machinegun"]) : {'GUN RUN'};
					case (_x isEqualTo ["missilelauncher"]) : {'MISSILES'};
					case (_x isEqualTo ["machinegun","missilelauncher"]) : {'GUNS + MISSILES'};
					case (_x isEqualTo ["bomblauncher"]) : {'BOMBING RUN'};
				};
				[_listBox, _casMode] call A3C_addLbEntry;
			} foreach _casModes;
		};
	} foreach A3C_RD_UNITS;
	{
		_ctrlPos = ctrlPosition _x;
		_ctrlPos set [3,(_ctrlPos select 3) + (  (3)   * (0.0440051 * safezoneH) )];
		_x ctrlSetPosition _ctrlPos;
		_x ctrlCommit 0;
	} foreach [_parent,_listBox];

};

A3C_AI_HighCommand_Action_rappel = {
	{
		private _gp = _x;

		_gp setvariable ["A3C_UNIT_POLYS",[],true];

		//-- clear all waypoints
		{
			{
				_x setVariable ["A3C_CLEARING",false,true];
			} foreach (units _x);
		} foreach A3C_SELECTED_UNITS;


		// _gp = A3C_RD_UNITS select 0; // ?????
		while {(count (waypoints _gp)) > 1} do {
			{
				if (_forEachIndex > 0) then {
					deletewaypoint _x;
				};
			} foreach waypoints _gp;
		};
		
		//-- add new waypoints
		private _leaderVic = (vehicle leader _gp);
		private _rappelWPos = +(A3C_UI_HUD_3D_TAG_ICON_POS);
		private _startPos = getpos _leaderVic;
		private _landOnReturn = !isEngineOn _leaderVic;
		private _wp =
		[
			_gp,
			_rappelWPos
		] call A3C_HC_ADD_WP;
		if (A3C_UI_HUD_3D_TAG_ICON_POS distance2D _leaderVic > 50) then {
			_wp2 =
			[
				_gp,
				_startPos
			] call A3C_HC_ADD_WP;
			if (_landOnReturn) then {
				_statements = format
				[
					"
						[this,%1,'%2',[],true] spawn A3C_HC_WPACTION_LANDING_FULL;
					",
					_startPos,
					getPlayerUID player

				];
				_wpStm = waypointStatements _wp2;
				_wp2 setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
			};
		};
		if (_leaderVic distance2D _rappelWPos < 800) then {
			waitUntil {speed _leaderVic > 80  OR {_leaderVic distance2D _rappelWPos < 300} };
		};

		_statements = format
		[
			"
				[['%1',this,[['NONE','NONE'],'RAPPELL'],'LINE',(currentWaypoint group this),0],A3C_HC_INSERT_ACTION_WP] remoteExec ['bis_fnc_call',0];
			",
			getPlayerUID player
		];
		_wpStm = waypointStatements _wp;
		_wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
};

A3C_AI_HighCommand_Action_suppression = {
	if (count A3C_RD_UNITS > 0 && {A3C_UI_HUD_3D_TAG_ICON_TYPE != ""}) then {
		{
			[_x,A3C_UI_HUD_3D_TAG_ICON_POS] call A3C_HC_Suppression_Immediate;
		} foreach A3C_UI_RADIAL_Current_Remfire_Units;
	};
	A3C_HC_GroupMenu_SuppressionRequested = false;
};

A3C_AI_HighCommand_Action_artillery = {
	A3C_HC_FOCUS_ARTY = objNull;
	A3C_HC_FOCUS_ARTY_AMMO = ""; //-- what is goin on here
	with uiNamespace do {
		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
	};

	A3C_HC_FOCUS_ARTY_POS = +(A3C_UI_HUD_3D_TAG_ICON_POS);
	["ARTY"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;
};


A3C_AI_HighCommand_Action_placeCharge = {
	if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
		with uiNamespace do {
			//disableSerialization;
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		};

		private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100060};
		private _parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Parent;
		private _text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_Description_TXT;
		private _listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_ObjectSelector_ListBox;

		A3C_OBJECTSELECTOR_MODE = "PLACE_CHARGE_HC";
		_parent ctrlShow true;
		_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
		_parent ctrlCommit 0;
		_text ctrlSetText "Place Charge";

		if (count A3C_REMFIRE_MAGTYPES > 4) then {
			_parentPos = ctrlPosition _parent;
			_parentPos set[3,(_parentPos select 3) + (  ((count A3C_REMFIRE_MAGTYPES) - 4)   * (0.0440051 * safezoneH) )];
			_parent ctrlSetPosition _parentPos;
			_parent ctrlCommit 0;
		};
		
		ctrlSetFocus _listBox;
		
		lbClear _listBox;
		{
			private _lbText = (getText (configfile >> "CfgMagazines" >> _x >> "displayName"));
			[_listBox, _lbText] call A3C_addLbEntry;
		} foreach A3C_REMFIRE_MAGTYPES;
		[_parent,_listBox, count A3C_REMFIRE_MAGTYPES] call A3C_OBJECTSEL_RESIZE;
	};
};

A3C_AI_HighCommand_Action_assembleWeapon = {
	private _gp = A3C_RD_UNITS select 0;
	{
		private _units = _x select 0;
		private _weapon = _x select 1;
		private _var = [];
		if (_weapon == typeOf A3C_OBJECTPLACER) exitWith {
			//-- clear all waypoints
			{
				{
					_x setVariable ["A3C_CLEARING",false,true];
				} foreach (units _x);
			} foreach A3C_SELECTED_UNITS;

			
			
			while {(count (waypoints _gp)) > 1} do {
				{
					if (_forEachIndex > 0) then {
						deletewaypoint _x;
					};
				} foreach waypoints _gp;
			};
			private _wp =
			[
				_gp,
				position A3C_OBJECTPLACER
			] call A3C_HC_ADD_WP;

			private _var = _gp getvariable ["A3C_UNIT_POLYS",[]];

			private _prefix = 'ASS'; //-- ASS stands for 'assemble' you cheeky little kitten.
			private _tPos = position A3C_OBJECTPLACER;
			_tpos set [2,0]; //==-- security mechanic: sometimes z-value is missing! ~~// does that apply here?

			_tPos = _tPos getPos [50, getDir A3C_OBJECTPLACER];

			if !(A3C_HC_PREVENT_POLY) then {

				//-- create VISIBLE polygon
				private _polygon = ([[_tPos,format ["A3C_%1_MAIN_Mark_%2_%3",parsetext _prefix,getPlayerUID player,A3C_SUP_POLY_IND_MARK],currentWaypoint _gp]] + ([_tPos,getDir A3C_OBJECTPLACER,"ASSEMBLE WEAPON",true] call A3C_SUP_CREATE_POLY));

				A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
				_var pushback _polygon;
			};



			// _statements = format
			// [
			// 	"

			// 		['%1',this,%2,'%3',(currentWaypoint group this)] call A3C_HC_INSERT_ACTION_WP;
			// 	",
			// 	getPlayerUID player,
			// 	[["NONE","NONE"],"ASSEMBLE WEAPON"],
			// 	formation _gp,
			// 	typeOf A3C_OBJECTPLACER
			// ];
			// _wpStm = waypointStatements _wp;
			// _wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
			// systemchat str _wpStm;



			private _wpScript = format 
			[
				"A3C_CORE\fnc_AI\wpFncs\wpScript_AssembleWeapon.sqf ['%1',%2,%3,'%4']",
				getPlayerUID player,
				["ARRIVAL",0],
				["NONE","NONE"],
				typeOf A3C_OBJECTPLACER
			];
			_wp setWaypointType "SCRIPTED";
			_wp setWaypointScript _wpScript;

			
			_gp setvariable ["A3C_UNIT_POLYS",_var,true];
			

			//-- create waypoint

			A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >>  _weapon >> "picture");
			A3C_UI_HUD_3D_TAG_ICON_MOD = "ON";
			// [screentoWorld [0.5,0.5],""] spawn A3C_UI_HUD_3D_TAG;
			player commandRadio "SentAssemble";

		};
	} foreach A3C_STATIC_PACKS;
};

A3C_AI_HighCommand_Action_boardGroupToVehicle = {
    private _vehicle = cursortarget;
    [ A3C_RD_UNITS select {!isPlayer leader _x}, _vehicle] call A3C_HC_AssignVehicle;           
    A3C_UI_HUD_3D_TAG_ICON_TYPE = (gettext (configfile >> "CfgVehicles" >> typeof _vehicle >> "picture"));
    _uiPos = getPosASL _vehicle;
    _uiPos set [2,(((boundingBoxReal _vehicle) select 1) select 2) / 2];
    // [_uiPos,"BOARD"] spawn A3C_UI_HUD_3D_TAG;
    A3C_UI_MAPICONS_HC_VICS = [];
    A3C_UI_HUD_ASSIGNVEHICLE = false;   
};


A3C_AI_HighCommand_Action_addWaypoint = {
	if (count A3C_RD_UNITS > 1) then {
								
		private _units = +(A3C_RD_UNITS);
		[_units,A3C_UI_HUD_3D_TAG_ICON_POS] spawn A3C_FNCS_CONVOY_MULTIGROUP;
	} else {
		{
			private _gp = _x;
			private _wpParams = [_gp,A3C_UI_HUD_3D_TAG_ICON_POS];
			private _eligibleForBuildingSearch = A3C_UI_HUD_3D_TAG_ICON_TYPE == "a3c_ui\markers\building.paa";
			if (_eligibleForBuildingSearch) then {
				_wpParams set [1, cursorTarget buildingPos 0];
				_wpParams set [2,[]];
				_wpParams = _wpParams +
				[
					"MOVE",
					[0,0,"AUTO","AUTO","NORMAL","CLEARBUILDING"]
				];
			};
			_wpParams call A3C_HC_ADD_WP;
		} foreach A3C_RD_UNITS;
	};
};







//---------------------------- MAP ONLY

//---------------------------- SHARED (MAP+RADIAL)
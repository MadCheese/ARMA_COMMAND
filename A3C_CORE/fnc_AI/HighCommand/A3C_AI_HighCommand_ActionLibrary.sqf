//---------------------------------------------------------------------------------------------
//---------- 1. Non positional actions --------------------------------------------------------
//---------------------------------------------------------------------------------------------


//---------------------------- MAP ONLY

A3C_AI_HighCommand_Action_joinPlayerGroup = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;
	//-- UI-Reaction
	if !(_isRadial) then {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	} else {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	};
	[A3C_SELECTED_HC_GROUPS_SETTINGS] call A3C_AI_HIGHCOMMAND_fnc_mergeGroups;
};

A3C_AI_HighCommand_Action_mergeGroups = {
	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
	// (findDisplay 12 displayCtrl 51) ctrlEnable true;
	A3C_isMergeGroupActive = true;
	hint "Click on the group to join";
	waituntil {!visibleMap OR {!(A3C_isMergeGroupActive)}};
	hint "";
	A3C_isMergeGroupActive = false;
};

//---------------------------- SHARED (MAP+RADIAL)

A3C_AI_HighCommand_Action_RefreshGroup = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;

	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		//-- note: we still disable radial so that player needs to let go of key
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
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
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;
	if (_isRadial) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};
	
	[] call A3C_GP_RC_UIVehicleRemoteFnc;
};


A3C_AI_HighCommand_Action_ConvoyHalt = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;
	//-- UI-Reaction
	if (_isRadial) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
	};

	hint format ["%1 convoy(s) have been ordered to halt!", count A3C_GROUP_CONVOYS];

	{
		_convoyElement = _x;
		{
			_gp = _x;
			private _waypoints = waypoints _x;
			private _cwp = currentWaypoint _gp;
			{
				if (_x select 1 >= _cwp) then {
					deleteWaypoint _x;
				};
			} foreach _waypoints;
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
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;
	//-- UI-Reaction
	if (_isRadial) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
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
			(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
			(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
		// } else {
		// 	with uiNamespace do {
		// 		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		// 	};
		// };
		["DELETE"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;
	};
	A3C_SELECTED_HC_GROUPS_SETTINGS = [];
};

A3C_AI_HighCommand_Action_convoyCreate = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;
	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};
	//-- create convoy group
	[] spawn A3C_Map_HC_groupContext_ButtonFnc_Convoy;
};

A3C_AI_HighCommand_Action_convoyRejoin = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;
	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};
	//-- rejoin convoy
	[] spawn A3C_Map_HC_groupContext_ButtonFnc_Convoy;
};

A3C_AI_HighCommand_Action_limitSpeed = {
	A3C_OBJECTSELECTOR_MODE = "SPEEDLIMIT";
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;

	if (_isRadial) then {
		_a3c_dsp = 100060;
	};

	if (_isRadial) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
		with uiNamespace do {
			//disableSerialization;
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
			(findDisplay 100060 displayCtrl 800802) ctrlSetText "Select Max Speed";
		};	
			
		private _parent = findDisplay 100060 displayCtrl 8008;
		private _listBox = findDisplay 100060 displayCtrl 800803;
		private _text = findDisplay 100060 displayCtrl 800802;

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
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
		private _parent = findDisplay _a3c_dsp displayCtrl 8008;
		private _listBox = findDisplay _a3c_dsp displayCtrl 800803;
		private _text = findDisplay _a3c_dsp displayCtrl 800802;
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

A3C_AI_HighCommand_Action_boardGroupToVehicle = {
	_this spawn A3C_AI_HighCommand_boardGroupToVehicle;
};

A3C_AI_HighCommand_Action_reBoardGroupToVehicle = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;
	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
	};
	[A3C_SELECTED_HC_GROUPS_SETTINGS] spawn A3C_AI_HIGHCOMMAND_fnc_reboardGroupToVehicle;
};

A3C_AI_HighCommand_Action_chargeMavic = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100040};
	private _isRadial = _a3c_dsp == 100040;
	//-- UI-Reaction
	if (_isRadial) then {
		//-- no actual action - just close menu
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
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

	private _group = if (!isNull findDisplay 100040) then {A3C_RD_UNITS select 0} else {A3C_SELECTED_HC_GROUPS_SETTINGS select 0}; //~~ same same??
	private _a3c_dsp = if (visibleMap) then {100020} else {100060};

	if (_a3c_dsp == 100060) then {
		with uiNameSpace do {
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		};
	};

	private _parent = findDisplay _a3c_dsp displayCtrl 8008;
	private _text = findDisplay _a3c_dsp displayCtrl 800802;
	private _listBox = findDisplay _a3c_dsp displayCtrl 800803;

	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
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
	private _a3c_dsp = if (visibleMap) then {100020} else {100060};

	if (!isNull findDisplay 100040) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
	};
};

A3C_AI_HighCommand_Action_groupHeal = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100060};

	if (!isNull findDisplay 100040) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
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
	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};

	if (!isNull findDisplay 100040) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	} else {
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
	};
};

A3C_AI_HighCommand_Action_unAssembleWeapon = { // #TODO This fnc requires investigation >> Also used in HUD_UI.sqf

	params ["_mode"];
	if !(count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) exitWith {};
	
	private ["_group","_groupUnits","_wpn","_exit","_imgtext"];
	_group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	_groupUnits = units _group;
	_wpn = if (_mode == 0) then {objNull} else {_this select 1};


	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};



	//-- main display EH to disable radial until key is let go
	if (!isNull findDisplay 100040 && _a3c_dsp == 100060 ) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	};

	if (_a3c_dsp == 100060 && { {(vehicle _x) isKindOf "staticweapon"} count units _group == 0 }) then {
		with uiNamespace do {
			//disableSerialization;
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		};
	};


	_parent = findDisplay _a3c_dsp displayCtrl 8008;
	_text = findDisplay _a3c_dsp displayCtrl 800802;
	_listBox = findDisplay _a3c_dsp displayCtrl 800803;
	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
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
	//{
	//	(finddisplay _a3c_dsp displayCtrl _x) ctrlShow false;     !!!!!!!!!!!!!!!!!!!!!!
	//} foreach [800716,800717];
	//systemchat "leave static";
	{
		// //unassignvehicle _x;
		// //dogetOut _x;
		// [_x,vehicle _x] remoteExec ["leaveVehicle",_x];
		// [_x] remoteExec ["unassignvehicle",_x];
		// [_x] remoteExec ["doGetOut",_x];
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
		[units _x] call A3C_AI_Shared_fnc_engineOff;
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
		[_mode] spawn A3C_fnc_toggle_IR_STROBES;
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


//---------------------------- SHARED POSITIONAL STARTUP FUNCTION
A3C_AI_HighCommand_Action_StartPositionalProcess = { //-- THIS MIGHT BE REQUIRED TO BE USED MY SQUAD -LEVEL TOO: IF SO, RENAME AND MOVE
	params ["_isBusy", "_actionID", "_iconType","_iconColor","_objectPlacerClass", "_objectPlacerColorString"];
	
	if (_isBusy) exitWith {
		systemchat 'A3C: Plase wait for your last order to complete';
	};
	//-- UI-Reaction
	A3C_DISABLE_RADIAL = true;
	[] call A3C_RADIAL_CloseDisplay;

	{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu '';

	//-- Positional UI 
	A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
	A3C_UI_HUD_3D_TAG_ICON_COL = [_iconColor,0.7] call A3C_UI_Color_setOpacity;
	A3C_UI_HUD_3D_TAG_reposition = true;

	A3C_AI_HighCommand_Action_ID = _actionID;

	//-- Spawn object placer
	if (_objectPlacerClass != "") then {
		
		private _placer = _objectPlacerClass createvehicleLocal [0,0,100]; //
		_placer allowdamage false;
		_placer enableSimulation false;
		_placer disableCollisionWith player;
		_placer hideObject true;
		private _safePos = ([screenToWorld [0.5,0.5],[0,100]] call MCSS_fnc_getSafePos);
		if (!isNil '_safePos' && {count _safePos > 0}) then {
			_placer setpos _safePos;
		};
		_placer disableCollisionWith cursortarget;
		//-- Color Object
		if (_objectPlacerClass != "") then {
			private _colorStringFinal = "#(rgb,8,8,3)color" + _objectPlacerColorString;
			for "_i" from 0 to 10 do {
				A3C_OBJECTPLACER setObjectTexture [0, _colorStringFinal];
			};
		};

		_placer spawn { //-- spawn because we need the slight delay
			sleep 0.2;
			_this hideObject false;
			A3C_OBJECTPLACER = _this; //-- naming delay is necessary so object does not get moved by HUDdraw script immediately to be destroyed
			
		};
	};
};

// ["TANKSHOT", '\a3c_ui\crosshairs\icon_crosshair_remoteTankShell.paa',[1,0,0,1], "A3C_HeliPad","(0.5,0.1,1,1)"] call A3C_AI_HighCommand_Action_StartPositionalProcess;


A3C_AI_HighCommand_Action_CancelPositionalProcess = {
	// systemchat "A3C_AI_HighCommand_Action_CancelPositionalProcess";
	A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
	A3C_UI_HUD_3D_TAG_reposition = false;
	A3C_UI_HUD_3D_TAG_ICON_COL = [0.5,0.5,0.5,1]; //-- probably not needed, using grey to spot it happens :)
	if (!isNull A3C_OBJECTPLACER) then {
		deleteVehicle A3C_OBJECTPLACER;
	};
	// A3C_DISABLE_RADIAL = false; // -- not needed (Handled by keyup)
	A3C_AI_HighCommand_Action_ID = "";
	A3C_UI_HUD_3D_TAG_ICON_POS = [0,0,0];
};


//----- Remote-Fire Actions (use )


A3C_AI_HighCommand_Action_remoteFire_TankShot = {
	[A3C_REMFIRE_TankShot_Units, "TANKSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};

A3C_AI_HighCommand_Action_remoteFire_VTOL_Weapon = {
	params ["_weapon"];
	private _aimpos = ATLtoASL(A3C_UI_HUD_3D_TAG_ICON_POS);
	private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	private _leaderVic = vehicle (leader _gp);
	private _array = [side player, _leaderVic, _aimpos, _weapon, objNull];
	[_array, A3C_REMOTE_BLACKFISH] remoteExec ['bis_fnc_spawn', _leaderVic];
	sleep 2;
	waituntil {true};
	if (!isNull findDisplay 100040 && {(ctrlShown (findDisplay 100040 displayctrl 8001)) && {A3C_RADIALMODE in ['ACT','HC ACTIONS']}}) then {
		[A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
	};
};

A3C_AI_HighCommand_Action_remoteFire_UGLshot = {
	[A3C_REMFIRE_UGLShot_Units, "UGLSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};


A3C_AI_HighCommand_Action_remoteFire_ATshot = {
	[A3C_REMFIRE_ATShot_Units, "ATSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};

A3C_AI_HighCommand_Action_remoteFire_StaticRocketShot = {
	[A3C_REMFIRE_StaticShot_Units, "STATICSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};



//---------------------------- MAP ONLY



//---------------------------- SHARED (MAP+RADIAL)
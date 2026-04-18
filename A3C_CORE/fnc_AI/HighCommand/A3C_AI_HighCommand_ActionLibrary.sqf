

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

	if (_isRadial) then {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
		[
			46,
			'RADIAL',
			{

				true
			},
			{
			},
			{
				(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
				A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
				A3C_UI_HUD_3D_TAG_reposition = false;
			},
			true
		] call A3C_UI_RADIAL_ADD_EH_MACROS;
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
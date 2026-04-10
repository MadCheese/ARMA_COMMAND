A3C_HC_findExecutingMachine_old = {
	params ["_callerUID","_group"];
	private ["_return"];
	_return = false;
	//
	if (isNil 'A3C_IsA3CServer') exitWith {};
	if (A3C_IsA3CServer) then {
		//str [getPlayerUID player == _callerUID] remoteExec ["systemChat",0];
		//if (A3C_isAICommand) then {
			if (isServer) then {
				_return = true;
			};
		//} else {
			//if (local _group) then {
			//	_return = true;
			//};
		//};
	} else {
		if (getPlayerUID player == _callerUID) then {
			_return = true;
		};
	};
	//if !(A3C_IsA3CServer) then {
		//if !(_return) then {
		//	if (local _group) then {
				//_return = true;
		//	};
		//};
	//};
	//(str _return) remoteExec ["systemchat",0];
	_return
};



//////////////////////////////////////////////////////////////////////
/////////////////      A I C  -  F U N C S       /////////////////////
//////////////////////////////////////////////////////////////////////

A3C_AIC_ALLGROUPS = {
	private ["_return"];
	_side =  (getNumber (configfile >> "CfgFactionClasses" >> (faction player) >> "side"));
	_side = [_side] call BIS_fnc_sideType;
	_return = switch (_side) do {
		case (WEST) :{["ALL_WEST"]};
		case (EAST) :{["ALL_EAST"]};
		case (RESISTANCE) :{["ALL_GUER"]};
		case (CIVILIAN) :{["ALL_CIV"]};
	};
	_return
};

A3C_AIC_getControlMode = {
	//private["_commandersModules","_groupsModules","_configurationMode"];

	A3C_AIC_commandersModules = allMissionObjects "AdvancedAICommand_Commanders";
	A3C_AIC_groupsModules = allMissionObjects "AdvancedAICommand_Groups";

	A3C_AIC_configurationMode = "ALL_COMMANDERS_ALL_GROUPS";
	if(count A3C_AIC_commandersModules > 0) then {
		if(count A3C_AIC_groupsModules > 0) then {
			// Specific commanders assigned to specific groups
			A3C_AIC_configurationMode = "SPECIFIED_COMMANDERS_SPECIFIED_GROUPS"
		} else {
			// Specific commanders assigned to all local-side groups
			A3C_AIC_configurationMode = "SPECIFIED_COMMANDERS_ALL_GROUPS"
		};
	};
	//_configurationMode
};
[] call A3C_AIC_getControlMode;


// [_group,_index, "ACTIVE","Position"[ call A3C_AIC_returnWaypointData;
A3C_AIC_returnWaypointData = {
	params ["_group","_wpIndex","_wpMode","_searchItem"];
	private ["_return"];
	_return = -1;
	_AICwaypoints = if (_wpMode == "ALL") then {
		(_group getVariable ["AIC_Waypoints",[0,[]]]) select 1
	} else {
		([_group] call AIC_fnc_getAllActiveWaypoints) select 1
	};
	if (_AICwaypoints in [ []  ] ) exitWith {};
	{
		private _waypoint = _x;
		if (_x select 0 == _wpIndex) exitWith {
			_return = switch (_searchItem) do {
				case ("Position") : {_waypoint select 1};
				case ("Action") : {
					if (count _waypoint > 4) then {
						_waypoint select 4
					} else {
						""
					};
				};
				case ("Condition") : {
					if (count _waypoint > 5) then {
						_waypoint select 5
					} else {
						""
					};
				};
			};
		};
	} foreach _AICwaypoints;
	_return
};

A3C_AIC_currentWaypoint = {
	params ["_group"];
	private ["_return"];
	_return = ([_group] call AIC_fnc_getAllActiveWaypoints) select 1;
	if (count _return > 0) then {
		_return = (_return select 0) select 0;
	} else {
		_return = -1;
	};
	_return
};

A3C_AIC_currentWaypoint_Idle = {
	//-- fires if insert waypoint requires 
	params ["_group"];
	private ["_wps","_wpI"];
	_wps = (_group getVariable ["AIC_Waypoints",[0,[]]]) select 1; 
	_wpI = 0;
	if (count _wps > 0) then {
		_wp = _wps select (count _wps - 1);
		_wpI = (_wp select 0) + 1;
		//(str  (_wp SELECT 0)) remoteExec ["systemchat",0];
	};
	_wpI
};


A3C_AIC_RenewGroup = { //-- this function puts the units in a new copy group because they are somehow unresponsive after being dropped by aircraft
	params ["_gp"];
	private _id = groupID _gp;
	_gp1 = creategroup (side (leader _gp));
	_units = (units _gp);
	_units join grpNull;
	_units joinSilent _gp1;
	deletegroup _gp;
	//-- AIC is active - make sure unit will be shown right away
	private _arr = [] call A3C_AIC_ALLGROUPS;
	_gp1 setVariable ["AIC_Waypoints",[0,[]],true]; //-- big problem, might not wanna do this. somehow come up with a way to have waypoints and transport at same time
	_gp1 setGroupIDGlobal [_id];
	[_gp1] call A3C_AIC_REFRESH;
	{
		_x doFollow (leader (group _x));
	} foreach _units;
};


A3C_AIC_REFRESH = {
	params ["_group"];
	private ["_groupArray","_commandControls"];
	_groupArray = [] call A3C_AIC_ALLGROUPS;
	_groupArray pushBackUnique _group;
	_groupArray call AIC_fnc_commandControlAddGroup;
	{
		[_x,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
		[_x,"REFRESH_GROUP_ICON",[]] call AIC_fnc_groupControlEventHandler;
		[_x,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
		[_x,"REFRESH_ACTIONS",[]] call AIC_fnc_groupControlEventHandler;
	} foreach (missionNamespace getVariable ["AIC_Group_Controls",[]]); 

	_commandControls =  missionNamespace getVariable ["AIC_Command_Controls",[]];		
	{
		[_x,"REFRESH_GROUP_CONTROLS",[]] call AIC_fnc_commandControlEventHandler;
	} foreach _commandControls;
};


A3C_AIC_ChangeWaypointData = {
	params ["_group","_waypointIndex","_settingType","_settingReplace"];
	private ["_AIC_waypointArray","_AIC_waypoints"];
	_AIC_waypointArray = (_group getVariable ["AIC_Waypoints",[0,[]]]);
	_AIC_waypoints =  _AIC_waypointArray select 1;
	//systemchat str _this;
	
	{
		private _wp = _x;
		if (_wp select 0 == _waypointIndex) exitWith {
			//-- NO IDEA WHY< BUT A SWITCH COMMAND DID NOT WORK HERE!
			if (_settingType == "POSITION") then {
				if (typeName _settingReplace == "ARRAY") then {
					_wp set [1,_settingReplace];	
					
					//player setpos _settingReplace;
				};
			};
			if (_settingType == "CONDITION") then {
				if (typeName _settingReplace == "STRING") then {
					_wp set [5,_settingReplace];
				};
			};
			if (_settingType == "ACTIONSCRIPT")then {
				if (typeName _settingReplace == "STRING") then {
					_wp set [4,_settingReplace];
				};
			};
			if (_settingType == "WPBOOL")then {
				if (typeName _settingReplace == "BOOL") then {
					_wp set [2,_settingReplace];
				};
			};
			_AIC_waypoints set [_forEachIndex,_wp];
		};
	} foreach _AIC_waypoints;
	//systemchat str _AIC_waypoints;
	_AIC_waypointArray set [1,_AIC_waypoints];
	_group setVariable ["AIC_Waypoints",_AIC_waypointArray,true];
	//[_group] call A3C_AIC_REFRESH;
	for "_i" from 1 to 8 do {
		sleep 0.5;
		{[_x,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler} foreach (missionNamespace getVariable ["AIC_Group_Controls",[]]);  
	};
};

A3C_AIC_fnc_unloadOtherGroupsActionHandler = {
	params ["_group"];
	private ["_vehicle","_unloadedGroups","_assignedVehicles"];
	_unloadedGroups = [];
	{
		_vehicle = _x;
		//_vehicle = vehicle player;
		{
			if(group _x != _group) then {
				if!(group _x in _unloadedGroups) then {
					[group _x, _vehicle] remoteExec ["leaveVehicle", leader group _x];
					_unloadedGroups pushBack (group _x);
					_assignedVehicles = [group _x] call AIC_fnc_getGroupAssignedVehicles;
					_assignedVehicles = _assignedVehicles - [_vehicle];
					[group _x,_assignedVehicles] call AIC_fnc_setGroupAssignedVehicles;
				};
			};
		} forEach (crew _vehicle);
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	//hint ((str count _unloadedGroups) + " other group(s) unloaded");
};

A3C_AIC_fnc_assignVehicleActionHandler = {
	params ["_group","_selectedVehicle"];
	//_menuParams params ["_groupControlId"];
	//private ["_group"];
	//_group = AIC_fnc_getGroupControlGroup(_groupControlId);
	//private ["_selectedVehicle"];
	//_selectedVehicle = [_groupControlId] call AIC_fnc_selectGroupControlVehicle;
	if(!isNull _selectedVehicle) then {
		private ["_vehicleName","_assignedVehicles","_vehicleSlotsToAssign","_maxSlots","_vehicleRoles"];
		private ["_unitIndex","_countOfSlots","_vehicleToAssign"];
		[_group,_selectedVehicle] remoteExec ["addVehicle", leader _group];
		_assignedVehicles = [_group] call AIC_fnc_getGroupAssignedVehicles;
		_assignedVehicles pushBack _selectedVehicle;
		[_group,_assignedVehicles] call AIC_fnc_setGroupAssignedVehicles;
		//systemchat str _assignedVehicles;
		_vehicleSlotsToAssign = [];
		_maxSlots = 0;
		{
			_vehicleRoles = [_x] call BIS_fnc_vehicleRoles;
			if(count _vehicleRoles > _maxSlots) then {
				_maxSlots = count _vehicleRoles;
			};
		} forEach _assignedVehicles;
		if(_maxSlots > 0) then {
			for "_i" from 0 to (_maxSlots-1) do {
				{
					_vehicleRoles = [_x] call BIS_fnc_vehicleRoles;
					if(count _vehicleRoles > _i) then {
						_vehicleSlotsToAssign pushBack [_x,_vehicleRoles select _i];
					};
				} forEach _assignedVehicles;
			};
		};
		_unitIndex = 0;
		_countOfSlots = count _vehicleSlotsToAssign;
		{
			if(_countOfSlots > _unitIndex) then {
				_vehicleToAssign = (_vehicleSlotsToAssign select _unitIndex) select 0;
				_role = (_vehicleSlotsToAssign select _unitIndex) select 1;
				[_x,_vehicleToAssign,_role] remoteExec ["AIC_fnc_getInVehicle", _x];
			};
			_unitIndex = _unitIndex + 1;
		} forEach (units _group);
		if(_selectedVehicle isKindOf "Air") then {
			[_selectedVehicle,100] remoteExec ["flyInHeight", _selectedVehicle]; 
		};
		_vehicleName = getText (configFile >> "CfgVehicles" >> typeOf _selectedVehicle >> "displayName");
		hint ("Vehicle assigned: " + _vehicleName);
	} else {
		hint ("No vehicle assigned");
	};
};

A3C_AIC_getGroupCtrlID = {
	params ["_group"];
	private ["_return"];
	_return = -1;
	_groupControls = (missionNamespace getVariable ["AIC_Group_Controls",[]]);
	{
		private ["_groupControlID"];
		_groupControlId = _x;
		if ((missionNamespace getVariable [format ["AIC_Group_Control_%1_Group",(_groupControlId)],nil]) == _group) exitWith {
			_return = _groupControlID
		};
	} foreach _groupControls;
	_return
};

A3C_AIC_OVER_GROUP_ID = nil;


A3C_AIC_fnc_unassignVehicleActionHandler = {
	params ["_group"];

	{
		[_group,_x] remoteExec ["leaveVehicle", leader _group];
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	[_group,nil] call AIC_fnc_setGroupAssignedVehicles;
	//hint ("All vehicles unassigned");
};
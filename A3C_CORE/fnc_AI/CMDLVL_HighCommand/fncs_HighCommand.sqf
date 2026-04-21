////////////////////////  GETTERS
/////////////////////////////////////////////////////////
A3C_HC_getConditionFromStatements = {
	params ["_cond","_timeOut"];
	_cond = toLower _cond;
	
	private _condMode = "";
	private _condVal = "";
	switch (true) do {
		case ("gocode" in _cond) : {
			_condMode = "GOCODE";
			_condVal = switch (true) do {
				case ("activate_a" in _cond) : {"A"};
				case ("activate_b" in _cond) : {"B"};
				case ("activate_c" in _cond) : {"C"};
				case ("activate_d" in _cond) : {"D"};
			};
		};
		case ("time" in _cond) : {
			if ("timeout" in _cond) then {
				_condMode = "TIMEOUT";
				_condVal = _timeOut select 1;
			} else {
				_condMode = "DAYTIME";
				_cond = _cond splitString """[],";
				_condVal = _cond select {
					_st = _x;
					({typeName (call compile _x) == "SCALAR"} count (_st splitString "")) == count _st
				};
				_condVal = _condVal joinString ":";
		
			};
		};
	};
	[_condMode,_condVal]
};

A3C_HC_getFullCrew = {
	params ["_vehicle"];
	private _vicVar = _vehicle getVariable ["A3C_AssignedVehicleCrew",[]];
	private _emptyPositions = 
	(
		(fullcrew [_vehicle,"driver",true]) 
		+ (fullcrew [_vehicle,"gunner",true])
		+ (fullcrew [_vehicle,"commander",true])
		+ (fullcrew [_vehicle,"turret",true])
		+ (fullcrew [_vehicle,"cargo",true])  
	);
	_emptyPositions = _emptyPositions select {
		_x params ["_occupyingUnit","_role","_CargoIndex","_turretPath"];
		private _seatIndexPath = if (tolower _role == "turret" ) then {_turretPath} else {_CargoIndex};
		(isNull _occupyingUnit OR {!alive _occupyingUnit} ) && 
		{
			{
				_x params ["_refUnit","_refRole","_refSeatIndex"];
				!(_refUnit in _boardUnits) && {[_role,_seatIndexPath] isEqualto [_refRole,_refSeatIndex]} 
			} count _vicVar == 0
		}
	};
	_emptyPositions
};

A3C_AI_FNC_remoteSteer = {
	params ["_vehicle","_angleDiff"];

	if !(isEngineOn _vehicle) exitWith {
		_vehicle engineOn true;
	};

	if (!(_vehicle isKindOf "TANK") && {abs ((velocityModelSpace _vehicle) select 1) < 4}) exitWith {}; //-- only tracked vehicles can rotate while stationary

	private _currentVelocity = velocity _vehicle;
	//private _vectorUp = vectorUp _vehicle;

	private _newDir = [getDir _vehicle + _angleDiff] call MCSS_fnc_CorrectDir;

	private _terrainVectors = [getPos _vehicle, _newDir] call MCSS_fnc_TerrainTilt;

	// Calculate new velocity components after rotation
	private _newVx = (_currentVelocity select 0) * cos(_angleDiff) - (_currentVelocity select 1) * sin(_angleDiff);
	private _newVy = (_currentVelocity select 0) * sin(_angleDiff) + (_currentVelocity select 1) * cos(_angleDiff);
	private _newVelocity = [_newVx, _newVy, _currentVelocity select 2];


	_vehicle setVectorDirAndUp _terrainVectors;
	_vehicle setVectorUp (surfaceNormal (getPos _vehicle));
	_vehicle setVelocity _newVelocity;      
};

A3C_HC_getAllGroups_Player_ORGANIZED = {
	private _hcAll = +A3C_HC_getAllGroups_Player_Current;
	_hcAll = [_hcAll,[],{vehicle leader _x distance2D player},"ASCEND"] call BIS_fnc_sortBy;
	_closestUnits = _hcAll select [0,4];
	_hcAll = _hcAll - _closestUnits;
	_tankGroups = [];
	_infantryGroups = [];
	_wheeledGroups = [];
	_heliGroups = [];
	_jetGroups = [];
	_boatGroups = [];
	_staticGroups = [];
	{
		_leaderVic = vehicle leader _x;
		switch (true) do {
			case (_leaderVic isKindOf "MAN") : {_infantryGroups pushBack _x};
			case (_leaderVic isKindOf "CAR") : {_wheeledGroups pushBack _x};
			case (_leaderVic isKindOf "SHIP") : {_boatGroups pushBack _x};
			case (_leaderVic isKindOf "TANK") : {_tankGroups pushBack _x};
			case (_leaderVic isKindOf "HELICOPTER") : {_heliGroups pushBack _x};
			case (_leaderVic isKindOf "PLANE") : {_jetGroups pushBack _x};
			case (_leaderVic isKindOf "STATICWEAPON") : {_staticGroups pushBack _x};
		};
	} foreach _hcAll;

	_hcAll = _closestUnits + _infantryGroups + _staticGroups + _wheeledGroups + _boatGroups + _tankGroups + _heliGroups + _jetGroups;
	_hcAll 
};


////////////////////////  STATE GETTERS
/////////////////////////////////////////////////////////

A3C_HC_getState_isGroupIdle = {
	params ["_group"];
	{_x select 1 == currentWaypoint _group} count (waypoints _group) == 0
};

////////////////////////  ACTIONS
/////////////////////////////////////////////////////////

A3C_HC_ACTION_ASSEMBLE_UAV = {
	params ["_leader","_activeWpos","_callerUID"];
	//~~ _activeWpos is useless?
	private _group = group _leader;
	//private _wPos = waypointPosition [_group, currentWaypoint _group]; //-- not needed really?
	if !([_callerUID,_group] call A3C_HC_findExecutingMachine) exitWith {};
	
	{
		_u = _x;
		_backPack = backpack _u;
		_uavType = (getText (configfile >> "CfgVehicles" >> _backPack >> "assembleInfo" >> "assembleTo"));
		private _exit = false;
		if (_uavType != "") then {
			_isUAV = (getText(configfile >> "CfgVehicles" >> _uavType >> "uavCameraDriverDir")) != "";
			if (_isUAV) then {
				_exit = true;
				[_u,"ainvpknlmstpslaywrfldnon_medic"] remoteExec ["playMove",_u];
				sleep 2;
				removeBackPackGlobal _u;
				sleep 5;
				if (animationState _u == "ainvpknlmstpslaywrfldnon_medic") then {
					[_u,"amovpknlmstpslowwrfldnon"] remoteExec ["playMove",_u];
				};
				if (alive _u) then {
					_uavObject = _uavType createVehicle (_u getPos [1.5,getDir _u]);
					createvehicleCrew _uavObject;
					_uavObject flyinHeight 500;
					[driver _uavObject ,_uavObject getPos [15, getDir _uavObject]] call A3C_DOMOVE;					
				} else {
					//-- somehow a spawned backpack does not want to be deleted. since the unit's bp was removed before, it is spawned on ground if killed
					_dummyy = _backPack createVehicleLocal (_u getPos [1,getDir _u]);
				};
			};
		};
		if (_exit) exitWith {};
	} foreach units _group;
};

A3C_isLoiterCompleted = {
	params ["_wp"];
	
	private _group = _wp select 0;
	private _precond = [((waypointStatements _wp) select 0), waypointTimeout _wp] call A3C_HC_getConditionFromStatements;
	_precond params ["_condMode","_condVal"];
	
	_leaderVic = vehicle leader _group;

	private _tolerance = 20;
	private _exitCondition = canMove _leaderVic && 
	{
		_leaderVic distance2d (waypointPosition _wp) < ((waypointLoiterRadius _wp) + _tolerance)
	};
	if (_exitCondition) then {
		_exitCondition = switch (_condMode) do {
			case ("TIMEOUT") : {
				private _val = _group getVariable ["A3C_LOITER_TIMEOUT",-1];
				private _return = false;
				if (_val != -1) then {
					if (time > (_val + _condVal)) then {
						_return = true;
					};
				} else {
					_group setVariable ["A3C_LOITER_TIMEOUT",time,true];
				};
				_return
			};
			case ("GOCODE") : {
				call compile format ["A3C_GoCode_Activate_%1",_condVal];
			};
			case ("DAYTIME") : {
				
				private _str = _condVal splitString ":";
				private _checkParams = [];
				{
					_checkParams pushBack (parseNumber _x)
				} foreach _str;
				//systemchat str _condVal;
				call compile format ["%1 call A3C_fnc_DAYTIME_COMPLETED",_checkParams];
			};
			default {true};
		};
	};
	
	if (_exitCondition) then {
		_group setVariable ["A3C_LOITER_TIMEOUT",nil,true];
		_group setCurrentWaypoint [_group, (currentWaypoint _group) + 1];
		if ((currentWaypoint _group) == (_wp select 1)) then {
			_wp call A3C_HC_REMOVE_WP_RC;
		};
	};
};




A3C_HC_AssignVehicle = { //--#TODO: change from call to spawn and add delay if group is does not share clientOwner with vehicle driver. then make a short server fnc to transfer ownership back and forth after ordergetIn
	params ["_boardGroups","_selectedVehicle"];
	_boardGroups = if (typeName _boardGroups == "ARRAY") then {_boardGroups} else {[_boardGroups]};
	private _boardCount = count _boardGroups;
	private _groupString = "";
	{
		_Bgroup = _x;
		private _vicVar = _selectedVehicle getVariable ["A3C_AssignedVehicleCrew",[]];
		_boardUnits = (units _Bgroup) select {isNull objectParent _x};

		_emptyPositions = [_selectedVehicle] call A3C_HC_getFullCrew;

		if (count _boardUnits > 0 && {count _boardUnits <= count _emptyPositions}) then {
			{
				_unit = _x;
				_seatData = _emptyPositions select _foreachIndex;
				_seatData params ["_occupyingUnit","_role","_cargoIndex","_turretPath"];
				_seatValue = if (_role == "cargo") then {_cargoIndex} else {_turretPath};
				_cmnd = "";
				_params = "";
				switch (tolower _role) do {
					case ("driver") : {
						_cmnd = "assignAsDriver";
						_params = _selectedVehicle;
					}; //--assignAsX commands are global
					case ("gunner") : {
						_cmnd = "assignAsGunner";
						_params = _selectedVehicle;
					};
					case ("commander") : {
						_cmnd = "assignAsCommander";
						_params = _selectedVehicle;
					};
					case ("turret") : {
						_cmnd = "assignAsTurret";
						_params = [_selectedVehicle,_seatValue];
					};
					case ("cargo") : {
						_cmnd = "assignAsCargoIndex";
						_params = [_selectedVehicle,_seatValue];
					};
				};
				[_unit,_params] remoteExec [_cmnd,_unit];
				_vicVar pushBack [_unit,_role,_seatValue];
				[_unit,_selectedVehicle] spawn {
					params ["_unit","_selectedVehicle"];
					while {alive _unit} do {
						if (assignedVehicle _unit != _selectedVehicle OR {_unit in _selectedVehicle}) exitWith {};
						sleep 1;
					};
					private _vicVar = _selectedVehicle getVariable ["A3C_AssignedVehicleCrew",[]];
					{
						if (_x select 0 == _unit) exitWith {
							_vicVar deleteAt _foreachIndex;
						};
					} foreach _vicVar;
					_selectedVehicle setVariable ["A3C_AssignedVehicleCrew",_vicVar,true];
				};
			} foreach _boardUnits;
			_selectedVehicle setVariable ["A3C_AssignedVehicleCrew",_vicVar,true];
			_Bgroup setVariable ["A3C_AssignedGroupVehicle",_selectedVehicle,true];
			[_boardUnits,true] remoteExec ["allowGetIn",leader _Bgroup];
			[_boardUnits,true] remoteExec ["orderGetIn",leader _Bgroup];
			//_boardUnits orderGetIn true;

			

			_prestring = "";
			_postString = "";
			if (_foreachIndex == (_boardCount -1)) then {
				if (_boardCount > 1) then {
					_preString = " and ";
				};
			} else {
				if (_foreachIndex < (_boardCount -2)) then {
					_postString = ", ";
				};
			};
			_groupString = _groupString + _preString + groupID _x + _postString;

			
			///systemchat format ["A3C: %1 was assigned a %2", groupID _Bgroup, (gettext(configFile >> "CfgVehicles" >> typeof _selectedVehicle >> "displayName"))];
			
		} else {
			systemchat format ["A3C: %1 does not have space for %2", groupID (group driver _selectedVehicle),groupID _Bgroup];
			_Bgroup setVariable ["A3C_AssignedGroupVehicle",nil,true];
			_boardGroups = _boardGroups - [_Bgroup];
		};	
	} foreach _boardGroups;
	if (count _boardGroups > 0) then {
		if (!isNull driver _selectedVehicle) then {
			systemchat format ["A3C: %1 is boarding %2",_groupString, groupID (group driver _selectedVehicle)];
		} else {
			systemchat format ["A3C: %1 %2 boarding a %3", _groupString, if (count _boardGroups == 1) then {"is"} else {"are"}, gettext (configfile >> "CfgVehicles" >> typeof _selectedVehicle >> "displayName")];
		};
		
	};
	
	A3C_Boarding_ACTIVE = false;
};


A3C_HC_INSERT_ACTION_WP = {
	private ["_callerUID","_group","_data","_var","_formation","_wpI","_actionType","_wp","_wpA","_wps","_wpC","_wpCurr","_wpsActive","_next","_condition","_insCondition","_statements","_leadVic","_exit"];

	//"111" remoteexec ["systemchat",0];
	if (isNil 'A3C_IsA3CServer') exitWith {};
	
	
	_callerUID = _this select 0;
	private _group = group (_this select 1);
	private _leadVic = vehicle (leader _group);
	//(str (count (([_leadVic, driver _leadVic] call A3C_getDismountData) select 0))) remoteExec ["systemchat",0];
	
	//keep in mind: all_polys is an array local to the client. the 'base' of polygons is in the unit's namespace variable ('unit_polys'), which is PUBLIC so that adjustments are still broadcasted while each client forms their own all_polys array
	//-- this means that the wpi index is passed into this script, but when the SERVER triggers the poly_action_on func the


	if !([_callerUID,_group] call A3C_HC_findExecutingMachine) exitWith {};
	


	//"ayo1" remoteExec ["systemchat",0];
	

	
	_data = _this select 2; // array: [[condType,condVal],actionType]
	_formation = _this select 3;
	_wpI = if (count _this > 4) then {_this select 4} else {-1};
	
	_subType = if (count _this > 5) then {_this select 5} else {nil};
	
	_leaderOnly = if (count _this > 6) then {_this select 6} else {false}; //-- will only perform action on leader's vehicle (ie combat landing)
	
	_condition = _data select 0;
	_ActionType = _data select 1;


	{
		[_x] call MCSS_fnc_setVehicleVarname;
		_veh = objectParent _x;
		if (!isNull _veh && {_x == driver (_veh)}) then {
			[_veh] call MCSS_fnc_setVehicleVarname;
		};
	} foreach (units _group);
	
	


	_wp = [];

	_WPpos = [];
	
	
	
	_syncWps = [];

	_WPpos = waypointPosition [_group,_wpI];
	_syncWps = synchronizedWaypoints [_group,currentWaypoint _group];

	
	//player sidechat str [_group == gp2, _wpI,_syncWps];
	
	if (_wpPos isEqualTo [0,0,0]) then {
		_wpPos = position _leadVic;
	};
	
	if (_actionType == "FULL LANDING" && {_leadVic getvariable ["alive_combatsupport",false]}) exitWith {
		systemChat "A3C: You are trying to land ALIVE helicopters with A3C. Please use ALIVE-RTB to land this vehicle";
	};
	
	_hPad = if (_actionType in ["FULL LANDING","COMBATLANDING","TRANSPORT UNLOAD"]) then {"Land_HelipadEmpty_F" createvehicle _WPpos} else {objNull};
	
	if (_actionType == "TRANSPORT UNLOAD") exitWith {
		waituntil { {  private _vic = vehicle _x; (_x == driver _vic) && { _vic isKindOf "HELICOPTER" && istouchingGround _vic} } count units _group > 0 };
		deletevehicle _hPad;
		//"unload exit" remoteExec ["systemchat",0];	
	};
	
	
	
	if (_actionType == "SYNCBOARD_VIV") then {
		//_leadVic land "GET IN";
		[_leadVic,"GET IN"] remoteExec ["land",_leadVic];
	};
	
	
	private _specialCondition = {};
	_insCondition = "";
	if (_condition select 0 == "GoCode") then {
		A3C_GOCODES_HC pushbackUnique (_condition select 1);
		publicVariable 'A3C_GOCODES_HC'; 
		[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];
		_insCondition = format ["A3C_GoCode_Activate_%1",(_condition select 1)];
	} else {
		if (_condition select 0 == "NONE") then {
			_insCondition = "";
			_specialCondition = {true};
		} else {
			_insCondition = "time > time"; // can never return true on purpose, just needs to be a valid condition for the icon to be drawn // why not just use "false"?
		};
	};
	
	
	
	
	if (_actionType == "CAS-STRIKE") then {
		_specialCondition = {params ["_gp"]; ((_gp getVariable ['CAS_COMPLETED',true]) OR ({alive _x} count units _gp == 0) )};
		_condition = ["NONE","NONE"];
		_insCondition = "false && false";
		_group setvariable ['CAS_COMPLETED',false,true];
		//[_leadVic,_WPpos,_subType] remoteExec ["A3C_HC_execute_CAS", _leadVic];		
	};
	
	if (_actionType == "RAPPELL") then {
		//systemchat "oi";
		_specialCondition = {params ["_gp"]; ((_gp getVariable ['A3C_RAPPELL_COMPLETED',true]) OR ({alive _x} count units _gp == 0) )};
		_condition = ["NONE","NONE"];
		_insCondition = "false && false";
		_group setvariable ['A3C_RAPPELL_COMPLETED',false,true];
		_WPpos set [2,25];
		[driver _leadVic,(leader _group),_WPpos] spawn A3C_BEHAVIOUR_HELI_RAPPEL;
		//systemchat 'uouo';
	};
	if (_actionType in ["SUPPRESSION","AMBUSH"]) then {
	
		_specialCondition = switch (_condition select 0) do {
			case ("GOCODE") : {
				compile format ["%1",_insCondition];
			};
			case ("TIMEOUT") : {
				_timeAtCompletion = time +  (_condition select 1);
				compile format ["time > %1",_timeAtCompletion];
			};
			case ("DAYTIME") : {
				_str = (_condition select 1) splitString ":";
				_checkParams = [];
				{
					_checkParams pushBack (parseNumber _X)
				} foreach _str;
				compile format ["%1 call A3C_fnc_DAYTIME_COMPLETED",_checkParams];
			};
		};
		//systemchat str _specialCondition;
	};

	
	
	
	//if (_actionType == "FULL LANDING") then {
	//	_specialCondition = {params ["_gp"]; {!(isTouchingGround (vehicle _x))} count units _gp == 0};
	//	_condition = ["NONE","NONE"];
	//	_insCondition = "false && false";
	//	{
	//		private _vehi = vehicle _x;
	//		private _runwayLanding = ((getNumber (configfile >> "CfgVehicles" >> typeOf _vehi >> "landingSpeed")) > 10);
	//		if (_vehi isKindOf "PLANE" && {_runwayLanding}) then {
	//			if (_x == (driver _vehi)) then {
	//				[_x] spawn A3C_LANDPLANE;
	//			};
	//		} else {
	//			if (_vehi isKindOf 'HELICOPTER') then {
	//				[_vehi,'LAND'] remoteExec ["land",_vehi];
	//			};
	//		};
	//	} foreach (units _group);
	//};
	
	if (_actionType == "COMBATLANDING") then {
		{
			private _vicc = (vehicle _x);
			if (_vicc isKindOf 'HELICOPTER') then {
				if (_x == driver _vicc) then {
					[_vicc,'GET IN'] remoteExec ["land",_vicc];
					[_vicc,_x] spawn {
						params ["_vicc","_pilot"];
						waitUntil { (((getPosATL _vicc) select 2) < 0.5) OR (!alive _pilot) OR (!canMove _vicc)  };
						[_vicc,0] remoteExec ["flyInHeight",_vicc];
						//"combatLand exit" remoteExec ["systemchat",0];
					};
				};
			};
		} foreach (units _group);
	};
//	if (_actionType == "CLEARBUILDING") then {
//		_specialCondition = {params ["_gp"]; {_x getVariable ["A3C_CLEARING",false]} count units _gp == 0};
//		_building = nearestBuilding _WPpos;
//		[units _group,_building] spawn A3C_AI_Shared_action_CLEARBUILDING;
//		_insCondition = "false";
//	};
	
	if (_actionType == "ASSEMBLE WEAPON") then {
		[leader _group,_caller] call A3C_WPstatementsASSEMBLE;
		//systemchat 'yo';
	};
	


	//systemchat str _actionType;
	_statements = switch (_actionType) do {
		case ("SUPPRESSION") : {
			{ [_this,"SUPPRESSION"] call A3C_POLY_ACTION_OFF}
		};
		case ("AMBUSH") : {
			{ [_this,"AMBUSH"] call A3C_POLY_ACTION_OFF}		
		};
		case ("COMBATLANDING") : {
			
				if ( _leadVic isKindOf "HELICOPTER") then {
					{
						{[(vehicle _x),"NONE"] remoteExec ["land",(vehicle _x)];} foreach (units _this);
						{[(vehicle _x),_x getVariable ["A3C_FLYINHEIGHT",100]] remoteExec ["flyInHeight",(vehicle _x)];} foreach (units _this);
					}
				} else {
					{}
				}
				
		};
		
	//	case ("FULL LANDING") : {
	//			//{[vehicle _x] spawn A3C_Landplane} foreach (units _group);
	//		
	//			if ( _leadVic isKindOf "HELICOPTER") then {
	//				{ 
	//					{[(vehicle _x),_x getVariable ["A3C_FLYINHEIGHT",100]] remoteExec ["flyInHeight",(vehicle _x)];} foreach (units _this); 
	//				} //if (_condition select 0 == "Arrival") then {} else {vehicle _this land "NONE"	
	//			} else {
	//				{}
	//				//{[driver (vehicle _this)] call A3C_LANDPLANE }
	//			}
	//		
	//		
	//	};
		
		case ("CAS-STRIKE") : {
			{}
		};
		case ("RAPPELL") : {
			{}
		};
		case ("CLEARBUILDING") : {
			{}
		};
		default { {} };
		//case ("STATICWEAPON") : {
			//_weaponData = [units Tgroup,"PLANNING"] call A3C_getSelectionBackpackStatics;
			//if (count _data > 0) then {
			//	[
			//		(units Tgroup),
			//		["ASSEMBLE",(_weaponData select 0) select 1],
			//		position (leader _group),
			//		getDir (leader _group)	
			//	] spawn A3C_WP_ACTION_STATICWEAPON;
			//}; 
		//};
	};
	_fakeStatements = switch (_actionType) do { //-- 'fake' statements are just used to have be able to identify the action for UI purposes (fnc_drawMapUI)
		case ("SUPPRESSION") : {
			"nul = 'SUPPRESSION_ACTIVE'; "
		};
		case ("AMBUSH") : {
			"nul = 'AMBUSH_ACTIVE'; "
		};
		case ("COMBATLANDING") : {
			"nul = 'COMBATLANDING_ACTIVE'; "	
		};
		
		//case ("FULL LANDING") : {
		//	"nul = 'FULL LANDING ACTIVE'; "
		//};
		
		case ("CAS-STRIKE") : {
			"nul = 'CAS-STRIKE_ACTIVE'; "
		};
		case ("RAPPELL") : {
			"nul = 'RAPPELL_ACTIVE_ACTIVE'; "
		};
		//case ("CLEARBUILDING") : {
		//	"nul = 'CLEARBUILDING_ACTIVE'; "
		//};
		default {""};
	};
	
	
	_WPpos = if (!isNil '_WPpos' && {!(_WPpos isEqualTo [])}) then {_WPpos} else {position (leader _group) }; //~~ this is a sloppy temp fix. Instead, make sure that _wPos is always passed. 
	
	
	
	
	//str (count waypoints _group) remoteExec ["systemChat",0];

	
	private _wpCurr = -1;
	
	private _var = (_group getvariable ["A3C_UNIT_POLYS",[]]);


	//-- INSERT ACTUAL WP
	

	if (!(_actionType == "FULL LANDING") OR (count waypoints _group > 0)) then { //~~ is this supposed to mean active waypoints? why would there be 0 waypoints to begin with?? Like ever?
		
		_wp = 
		[
			_group,
			_WPpos,
			[],
			'HOLD',
			[0,1000,'AUTO','AUTO',-1,'NONE'],
			false,
			_wpI + 1
		] call A3C_HC_ADD_WP;

		
		
		
	
		
		//-- adjust polygon data 
		{
			private ["_data","_wpIndex"];
			_data = _x select 0;
			_wpIndex = _data select 2;
			_data set [2,_wpIndex + 1];  //~~ Add 1 to polygon ID to match added waypoint index
		} foreach _var;
		
		//-- adjust waypoint actionScripts
		{
			private ["_wpIndex"];
			_wpIndex = _x select 1;
			//adjust postAction poly-Waypoints
			if (_wpIndex >  ((currentWaypoint _group) + 1)) then { //-- add 1 because suppression poly is already assigned
				_wpAdjust = ((waypoints _group) select _wpIndex);
				private _actionScript = (waypointStatements _wpAdjust) select 1;
				if ({[_x,_actionscript] call bis_fnc_instring} count ["suppression","ambush"] > 0) then {
					_actionScript = _actionscript splitstring ";"; //-- actionscript is broken down from string to array
					{
						_str = _x;
						if ( {[_x,_str] call BIS_fnc_inString} count ["SUPPRESSION","AMBUSH"] > 0) then {

							_str = _str splitString "]"; //-- convert string to array
							_subString = _str select 2;
							_subStringArray = _subString splitString ",";
							_id = (parsenumber (_substringarray select 1)) + 1; //-- add 1 for wpi/poly sync
							_subStringArray set [1, (str _id)];
							_subString = "," + ((_SubStringArray joinstring ","));
							_str set [2,_substring];
							_str = (_str joinString "]") + "]"; //-- re-convert poly-scriptline array to string     + 
							//systemchat str _str;
							_actionScript set [_forEachIndex,_str];
						};
					} foreach _actionScript;
					_actionScript = _actionScript joinString ";"; //-- re-convert scriptlineS array to string
					//_wpAdjust setWayPointStatements [(waypointStatements _wpAdjust) select 0, _actionScript];	
				};
			};
		} foreach (waypoints _group);
		//systemchat str [_insCondition, _fakeStatements];
		_wp setWaypointStatements [_insCondition, _fakeStatements];
		_group setCurrentWaypoint _wp;
		//[_group,_wp] remoteExec ["setCurrentWaypoint",leader _group];
		_group call A3C_HC_Refresh_WP_Markers;
		
	};		
		
	
	
	//if (true) exitWith {
	//	systemchat 'exit insert hcwp';
	//};
	
	//if (true) exitWith {systemchat 'tadaa';};
	
	[(leader _group),_WPpos] spawn {
		params ["_leader","_WPpos"];
		for "_i" from 0 to 1 do {
			[_leader ,_WPpos] call A3C_DOMOVE;
			sleep 1;
		};
	};

	//str _var remoteExec ["systemChat",0];	
	//-- assign new polygon data
	_group setvariable ["A3C_UNIT_POLYS",_var,true];
	
	//-- poly Actions
	if (_actionType in ["SUPPRESSION","AMBUSH"]) then {
		[_group,_actionType,_wpI,_var] spawn {
			params ["_group","_actionType","_wpI","_var"];
			waitUntil {_var isEqualTo (_group getvariable ["A3C_UNIT_POLYS",[]]) };
			sleep 0.2;
			[(units _group),['A3C_HC_POLY',0],_actionType,false,_wpI + 1] spawn A3C_POLY_ACTION_ON;
		};	 
	};
	
	
	//--adjust editing wp-index for clients who may be editing a waypoint of this group
	[
		[_group,_wpI],
		{
			params ["_group","_wpI"];
			if (isDedicated) exitWith {};
			if (isNil 'A3C_HC_ACTIVEGROUP') exitWith {};
			if ({ctrlShown (findDisplay _x displayCtrl A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT)} count [100020,100030] > 0 ) then {
				if (A3C_HC_ACTIVEGROUP == _group) then {
					if (_wpI < A3C_HC_ACTIVE_IND) then {
						A3C_HC_ACTIVE_IND = A3C_HC_ACTIVE_IND + 1;
						//systemchat str _wpi;
					};
					if (_wpI == A3C_HC_ACTIVE_IND) then {
						{
							(findDisplay _x displayCtrl A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT) ctrlShow false;
						} foreach [100020,100030];
					};
				};
			};
		}
	] remoteExec ["bis_fnc_call", 0]; 
	
	
	
	
	
	//systemchat str _specialCondition;
	//if (_actionType in ["CAS-STRIKE"]) exitWith {};
	
	//-- spawn 'real' condition. Shared by all HighCommand Modes.
	
	[_group,_wpCurr,_wpPos,_condition,_statements,_actionType,_wp,_specialCondition,_var,_hPad] spawn {
		params ["_group","_wpCurr","_wpPos","_condition","_statements","_actionType","_wp","_specialCondition","_var","_hPad"];
		private ["_timeInit","_check"];
		waitUntil {_var isEqualTo (_group getvariable ["A3C_UNIT_POLYS",[]]) };
		_formation = formation _group;
//		if (_actionType == "CLEARBUILDING") then {
//			_group setFormation "FILE";
//			sleep 1;
//			waituntil {{alive _x && !(_x getVariable ["A3C_CLEARING",false])} count units _group == 0};
//			sleep 2;
//			//aituntil {{alive _x && (_x distance (formationPosition _x) > 2)} count units _group == 0};
			
//		};
//systemchat str _condition;
		//if (_actionType in ["SUPPRESSION","AMBUSH"]) then {
			//waitUntil {};
			
		//};
		_timeInit = time;
		//systemchat str _statements;
		//systemchat str [_condition,_specialCondition];
		
		_check = switch (toUpper (_condition select 0)) do {
			case ("TIMEOUT") : { 
				{
					params ["_gp","_timeInit","_condition"];
					time > (_timeInit + (_condition select 1))
				} 
			};
			case ("DAYTIME") : { 
				//{time > (_condition select 1)} 
				
				{
					params ["_gp","_timeInit","_condition"];
					private ["_str","_checkParams","_return"];
					_str = (_condition select 1) splitString ":";
					_checkParams = [];
					{
						_checkParams pushBack (parseNumber _X)
					} foreach _str;
					_return = _checkParams call A3C_fnc_DAYTIME_COMPLETED;
					//systemchat str [_return,_checkParams];
					_return

				}
			};
			case ("GOCODE") : { 
				switch (_condition select 1) do {
					case ("A") : { {A3C_GoCode_Activate_A} };
					case ("B") : { {A3C_GoCode_Activate_B} };
					case ("C") : { {A3C_GoCode_Activate_C} };
					case ("D") : { {A3C_GoCode_Activate_D} };
				};

			};
			default {_specialCondition};
		};
		//systemchat str _check;
		if (_actionType in ["SUPPRESSION","AMBUSH"]) then {
			//-- wait for polyUnits to get ready
			//waituntil {(leader _group) getVariable ["A3C_POLY_ACTION_ACTIVE",false]};
			sleep 1;
		};
		
		private _leaderDest = (expectedDestination (leader _group)) select 0;
		
		while {true} do {
			//"loop" remoteExec ["systemChat",0];
			
			private _exit = false;
			//hintsilent str _check;
			if ([_group,_timeInit,_condition] call _check) then {
				_exit = true;
				//systemchat '_check';
				
			};
			
			if (_actionType in ["SUPPRESSION","AMBUSH"]) then {
				//if !((leader _group) getVariable "A3C_POLY_ACTION_ACTIVE") then {
				if ({_x getVariable "A3C_POLY_ACTION_ACTIVE"} count (units _group) == 0) then {
					_exit = true;
					//systemchat '_poly';
					//"insert waypoint complete" remoteExec ["systemchat",0];
				};
			};
			if (_actionType in  ["COMBATLANDING"]) then {
				{
					_gp = group _x;
					if (_x == driver vehicle _x) then {
						if (vehicle _x isKindOf "HELICOPTER") then {
							_height = (getPosATL vehicle _x) select 2;
							if ( _height < 2 && {(((expectedDestination (leader _gp)) select 0) distance _leaderDest < 10)} ) then {
								[(vehicle _x),1] remoteExec ["flyInHeight",(vehicle _x)];
							};
						};
					};
				} foreach units _group;
				private _expD = (expectedDestination (leader _group)) select 0;
				
				if ( (_expD distance2D [0,0,0] > 0) && {_expD distance _leaderDest > 10}) then {
					_exit = true;
				};
			};
			//systemchat 'loop';
			if (_exit) exitwith {
				if (!isNull _hPad) then { //-- this will be executed too early!
					deleteVehicle _hPad;
					{
						if (_x == driver vehicle _x) then {
							if (vehicle _x isKindOf "HELICOPTER") then {
								[(vehicle _x),_x getVariable ["A3C_FLYINHEIGHT",100]] remoteExec ["flyInHeight",(vehicle _x)];
							};
						};
					} foreach units _group;
				};
				//systemchat 'exit';
				if (_condition select 0 == "GoCode") then {
					//A3C_GOCODES_HC = A3C_GOCODES_HC - [_condition select 1];
					//publicVariable 'A3C_GOCODES_HC'; 
				};
				//"exit" remoteExec ["systemChat",0];
				private ["_prms"]; //(_statements select 0)
				_prms = switch _actionType do {
					case ("SUPPRESSION") : {
						(units _group)
					};
					case ("AMBUSH") : {
						(units _group)
					};
					case ("COMBATLANDING") : {
						(leader _group)
					};
					case ("FULL LANDING") : {
						(leader _group)
					};
					case ("CAS-STRIKE") : {
						(leader _group)
					};
				};
				_prms call _statements; 

				if ( ((count (waypoints _group) - 1) > (currentwaypoint _group)) ) then { //&& !(_actionType in ["SUPPRESSION","AMBUSH","CAS-STRIKE"]) 
					private _wpc = (currentWaypoint _group);
					[_group, currentwaypoint _group] call A3C_HC_REMOVE_WP_RC;
				} else {
					deletewaypoint [_group,currentwaypoint _group];
				};

				_leader = leader _group;
				sleep 2;
				{
					if (!isPlayer _x) then {
						_pos = if (_x == leader group _x) then {waypointPosition [_group,currentWaypoint _group]} else {formationPosition _x};
						[_x ,_pos] call A3C_DOMOVE;
					};
				} foreach ((units _group)); // - [_leader]
				(units _group) commandFollow _leader;
				// (format ["%1 calling back all units to formation 2", _group]) remoteExec ["systemchat", 0];
				
				//systemchat "exit condition hc";
			};
			sleep 0.1;
		};
		_group setFormation _formation;
		//"loop exit" remoteExec ["systemChat",0];
	};
	
	
};

A3C_HC_ChangeWaypointData = {
	params ["_group","_waypointIndex","_dataType","_dataReplace"];
	private _statements = ["",""];

	switch (_dataType) do {
		case ("POSITION") : {
			//systemchat str _dataReplace;
			[_group,_waypointIndex] setWaypointPosition [_dataReplace,0];
		};
		case ("CONDITION") : {
			_statements = waypointStatements [_group,_waypointIndex];
			_statements set [0,_dataReplace];
			[_group,_waypointIndex] setWaypointStatements _statements;
		};
		case ("ACTIONSCRIPT") : {
			_statements = waypointStatements [_group,_waypointIndex];
			_statements set [1,_dataReplace];
			[_group,_waypointIndex] setWaypointStatements _statements;
		};
	};		
	
};

A3C_HC_findExecutingMachine = {
	params ["_callerUID","_group"];
	!isNil 'A3C_IsA3CServer' && {local _group}
};






A3C_fnc_DAYTIME_COMPLETED = {
	params ["_year","_month","_day","_hour","_min"];
	date params ["_currentYear","_currentMonth","_currentDay","_currentHour","_currentMin"];
	private _return = false;
	////---- STEP 1: compare year,month and day to when order was set
	//-- 1. year number has to be larger or the same compared to when order was given
	_cond1 = _currentYear >= _year; 
	//-- 2. if order was given in december, current month needs to be lower or same. Otherwise it must be higher
	_cond2 = if (_month == 12) then {_currentMonth <= _month} else {_currentMonth >= _month}; 
	//-- 3. day check: if month or year are higher compared to when order was set, day number must be lower. otherwise it mus be higher or same
	_cond3 = if (_currentMonth > _month OR (date select 0) > _year) then {_currentDay < _day} else {_currentDay >= _day};
	
	////---- STEP 2: compare hour and minutes. these are the actual vals to be reached, independent of when order was given 
	_cond4 = if (_hour > 12) then {_currentHour > 12} else {_currentHour <= 12};
	_cond5 = (_currentHour >= _hour);
	_cond6 = _currentMin >= _min; //if (_cond5) then {true} else {(_currentMin >= _min)};
	//systemchat str [[_currentMin, _min],_cond1,_cond2,_cond3,_cond4,_cond5,_cond6];
	if ({_x} count [_cond1,_cond2,_cond3,_cond4,_cond5,_cond6] == 6) then {_return = true};
	//if (_return) then {systemchat 'DID WORK!'};	
	_return
};




//-- Add Waypoint to HC-Group
A3C_HC_ForceGround = {
	private ["_vehicle"];
	_vehicle = _this;
	while {canMove _vehicle} do {
		if (((getPosATL _vehicle) select 2) < 1) exitwith {
			[_vehicle,0] remoteExec ["flyInHeight",_vehicle];
		};
		sleep 0.5;
	};
};

A3C_HC_ADD_WP = {
	private ["_isHighCommand","_wp","_wpType","_wpI","_statements","_group","_posi","_return","_vehicle","_isFirstWP"];
	private _group = _this select 0;
	_posi = _this select 1;
	params ["_group","_posi"];

	

	// _syncWps = if (isNil '_syncWps') then {[]} else {_syncWps};
	_syncWps = if (count _this > 2) then {_this select 2} else {[]};
	_wpType = if (count _this > 3) then {_this select 3} else {"MOVE"};
	_statements = if ((count _this) > 4) then {_this select 4} else {[0,0,A3C_STANCE1_TEMP,A3C_STANCE2_TEMP,A3C_WP_SPEED_TEMP,if ((A3C_TEMP_ACTION select 0) == "FULL LANDING") then {A3C_TEMP_ACTION select 1} else {"NONE"}]};
	_isLoop = if ((count _this) > 5) then {_this select 5} else {false};
	_wpI = if (count _this > 6) then {_this select 6} else {-1};

	private _isHighCommand = ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) && {hcShownBar};
	_wp = [];
	// _nudge = count (waypoints _group) == 0; //~~ is this ever the case?

	_vehicle = vehicle (leader _group);
	private _waypoints = waypoints _group;
	
	
	private _lastWP = (_waypoints select ((count _waypoints) - 1) ) select 1; //~~ attention - this might clash with CYCLE waypoints
	private _currentWaypointIndex = ((currentWaypoint _group) - 1);
	private _isFirstWP = _currentWaypointIndex  == _lastWP;

	
	
	private _exit = false;
	if (_isFirstWP && {{canMove (vehicle _x) && _x getVariable ["A3C_VAR_LANDING",false]} count units _group > 0}) exitWith {
		systemchat format ["A3C: Waypoint can not be given until %1 has landed all of it's aircraft",groupID _group];
	};

	

	if (_isFirstWP && {driver _vehicle in units _group}) then {
		_wpI = 1;
		[_group] call A3C_HC_ReInitGroupMovement;
		_group setvariable ["A3C_UNIT_POLYS",[],true];
		
		private _jetTakeOff = false;
		{
			private _v = vehicle _x;
			if (_x == driver _v) then {
				// if (_v isKindOf "AIR") then {
						// private _flyInHeight =_v getVariable ["A3C_FLYINHEIGHT",25];
						// private _flyInHeightASL = (ATLtoASL _posi) vectorAdd [0,0,_flyInHeight];
						if (_v isKindOf "PLANE") then {
							if (isTouchingGround _v) then {
								_jetTakeOff = true;
							};
						};
				// };
				
				if (_v isKindOf "SHIP") then {
					private _vicPos = getpos _v;
					private _refPos = ATLtoASL ((_vicPos select [0,2]) + [0]);
					
					private _shoreAction = false;
					if (surfaceIsWater _refPos) then {
						private _depth = _refPos select 2;
						//systemchat str _depth;
						//private _refDepth = if (_cycle == 0) then {4} else {2};
						if (_depth >= -3) then { 
							_shoreAction = true;
						}; 
					} else {
						_shoreAction = true;
					};
					if (_shoreAction) then {
						if (abs (speed _v) < 2 ) then {
							[_v] call A3C_SHIP_startBoat;
						};
					};
					
				};
			};
		} foreach (units _group);
		
		if (_jetTakeOff) then {
			[leader _group] spawn A3C_JET_organizeGroupTakeOff;
		};	
	};
	
	_wp = [];

	if (_wpI == -1 OR _isFirstWP) then {
		_wp = [_group, _group addWayPoint [_posi,0] ];

	} else {
		_wp = [_group, _group addWayPoint [_posi,0,_wpI] ];
	};
		
	(_wp select 1) SetWayPointType _wpType;
	(_wp select 1) setwaypointSpeed "UNCHANGED";
	(_wp select 1) showWaypoint "NEVER";
	
	


	if ((typeName _statements) == "ARRAY") then { //~~ what's happening here, cycles?
		_statements pushback _isLoop;
		_statements set [0, [_group,(_wp select 1)] ];
		_statements call A3C_WP_STATEMENTS;	
	};

	if (_isFirstWP && {!isPlayer leader _group}) then {
		_group move _posi;
		private _effCom = effectiveCommander (vehicle leader _group);
		if (_effCom in (units _group)) then {
			[_effCom, _posi] call A3C_DOMOVE;
		};
		
	};


	// if (_nudge && {!isPlayer leader _group}) then {
	// 	if (_isFirstWP) then {
	// 		_posi = position leader _group; 
	// 	};
	// 	_group move _posi;
	// 	//'IF YOU SEE THIS MESSAGE, PLEASE REPORT ERROR CODE #NUDGE01 ON A3C DISCORD' remoteExec ["systemChat",0]; //~~ #REQUEST
	// 	//'IF YOU SEE THIS MESSAGE, PLEASE REPORT ERROR CODE #NUDGE01 ON A3C DISCORD' remoteExec ["hint",0];
	// 	//  #HCMOVE
	// //	{
	// //		if !(isnull objectparent _x) then {
	// //			[_x,_posi] remoteExec ["moveTo",_x];
	// //		};	
	// //	} foreach units _group;
	// };
	
	//-- SHIPS: dynamically set swimInDepth for each waypoint. Has no effect on non-submersible vehicles
	{
		if (_x == driver (vehicle _x)) then {
			if ((vehicle _x) isKindOf "SHIP") then {
				//-- next line, pay attention: the true/false may seem counter intuitive. We are looking for ZERO units WITHOUT rebreathers (meaning all have one)
				(vehicle _x) spawn {
					private _v = _this;
					sleep 5;
					if ( { _c = count (getArray (configfile >> "CfgWeapons" >> vest _x >> "hiddenUnderwaterSelections")); if (_c > 0) then {false} else {true};  } count (crew _v) == 0      ) then {
						[_v,-30] remoteExec ["swimInDepth",_v];
					} else {
						[_v,0] remoteExec ["swimInDepth",_v];
					};
				};	
			};
		};
	} foreach (units _group);
	// systemchat str _syncWps;
	// systemchat str _wp;

	if !(_syncWps isEqualTo []) then {
		(_wp select 1) synchronizeWaypoint _syncWps;
	};
		
	_wp select 1 //-- return wp
};

A3C_HC_FNC_MoveToWayPointPosition = {
	params ["_group","_wpi"];

	// systemchat str ["MVTWPS",time];
	private _leader = leader _group;
	if (!isPlayer leader _group) then {
		//_group setCurrentWaypoint [_group,(currentWaypoint _group)];
		sleep 1.5;
		[_leader,waypointposition [_group,_wpi]] call A3C_DOMOVE;
		sleep 1;
		_leader setDestination [waypointposition [_group,_wpi],"FORMATION PLANNED",true];
		//private _grunts = ((units _group) - [_leader]) select {!isPlayer _x && {isNull objectParent _x}};
		//_grunts doFollow (leader _group);
	};
};

A3C_HC_FNC_SYNC_WP = {
	params ["_wp","_syncData"];
	_wp synchronizeWaypoint _syncData;
};


A3C_HC_FNC_CompleteWaypoint = {
	private ["_group","_waypoints"];
	
	//if (true) exitwith {};
	_group = _this select 0;
	_waypoints = waypoints _group;
	//systemchat format ["%1 has completed a waypoint",groupId _group];
	//systemchat str ({_x == driver vehicle _x && {vehicle _x iskindof "AIR"}} count units _group);
	private _currentWaypoint = currentWaypoint _group;
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	if (ctrlShown (findDisplay _a3c_dsp displayctrl A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT)) then {
		if ([_group,_currentWaypoint] isEqualTo [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND]) then {
			(findDisplay _a3c_dsp displayctrl A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT) ctrlShow false;
		};
	};
	//systemchat format ["current waypoint is %1",currentWaypoint _group];
	
	if ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) exitwith {};
	
	if ({waypointtype _x == "CYCLE"} count _waypoints == 0) then {
		[_group, currentwaypoint _group] setwaypointstatements ['false',''];
	};	
};




A3C_WP_STATEMENTS = {
	private ["_wp","_statements","_preStatements"];
	_wp = _this select 0;
	_timeOut = _this select 1;	
	_stance1 = _this select 2;
	_stance2 = _this select 3;
	_speed = _this select 4;
	_landingType = _this select 5;
	_isLoop = _this select 6;
	_group = _wp select 0;
	_index = (_wp select 1) select 1;
	_wp = [_group,_index];
	_wp setwaypointType "MOVE";
	
	_wp setWaypointTimeout [_timeOut,_timeOut,_timeOut];
	//systemchat str _speed;
	_wpSpeed = if (typeName _speed == "SCALAR") then {if (_speed == -1) then {"NORMAL"} else {"LIMITED"};} else {"UNCHANGED"};
	//_wpSpeed = if ((_speed isEqualTo -1) OR (_speed isEqualTo "NORMAL")) then {if (_speed isEqualTo -1) then {"NORMAL"} else {"UNCHANGED"}} else {"LIMITED"};
	_statements = "";
	_preStatements = "";
	_preMod = "";
	_stance1Pre = "";
	_preWP = [];
	private _wpScript = "";
	
	/* TEMPORARILY BLOCKED
	//-- step 1: override stance2 of previous WP, unless index is 0 (no previous WP exists)
	if (_index > 0) then {
		_preWP = [_group,(_index - 1)];
		_preStatements = ((waypointstatements _preWP) select 1) splitstring ";";
		_preStatements set [1,format [" {_x setunitpos '%1'} foreach units (group this)",_stance1] ];
		_preStatements = _preStatements joinstring ";";
		_preWP setWaypointStatements [((waypointstatements _preWP) select 0),_preStatements];
	};
	
	_statements = _statements + 
		(
			format 
			[
				"
					{_x setunitpos '%1'} foreach units (group this); 
					{_x setunitpos '%2'} foreach units (group this); 	 
				",
				_stance1,
				_stance2	
			]
		);
	
	*/	
	_statements = _statements + 
		(
			format 
			[
				"
					if !(%2) then {[(group this)] call A3C_HC_FNC_CompleteWaypoint};
					 
				",
				_stance2,
				_isLoop	
			]
		);//
		//systemchat str _statements;
	
	switch (_landingType) do {
		case ("DROPOFF") : {
			_wp setwaypointType 'MOVE';
			_statements = _statements + format
			[
				"
					['%1',this,[['TIMEOUT',50],'COMBATLANDING'],'LINE',(currentwaypoint (group this))] call A3C_HC_INSERT_ACTION_WP;
				",
				getPlayerUID player
			];
		};
		case ("RAPPEL") : {
			_wp setwaypointType 'MOVE';
			//_statements = _statements + " [this,[['TIMEOUT',50],'COMBATLANDING'],'LINE',(currentwaypoint (group this))] call A3C_HC_INSERT_ACTION_WP; {(vehicle _x) land 'GET IN'; (vehicle _x) flyInHeight 0;} foreach (units this);";
		};
		case ("PICKUP") : {
			_wp setwaypointType 'MOVE';
			_statements = _statements + format
			[
				"
					['%1', this,[['TIMEOUT',50],'COMBATLANDING'],'LINE',(currentwaypoint (group this))] call A3C_HC_INSERT_ACTION_WP;
				",
				getPlayerUID player
			];
		};
		case ("LANDFINAL") : {
			_wp setwaypointType 'MOVE';
			_statements = _statements + format 
			[
				"
					['%1',this,[['TIMEOUT',50],'FULL LANDING'],'LINE',(currentwaypoint (group this))] call A3C_HC_INSERT_ACTION_WP;
				",
				getPlayerUID player
			];
			//_statements = _statements + "  thislist spawn {sleep 10; {player action ['engineOff', vehicle _x];} foreach _this;};  ";
		};
		case ("CLEARBUILDING") : {
			//systemchat 'clearb1';

			_wp setWaypointType "SCRIPTED";
			_wpScript = format ["A3C_CORE\fnc_AI\wpFncs\wpScript_CLEARBUILDING.sqf ['%1',['ARRIVAL','']]",getPlayerUID player];
			
			//_statements = _statements + format 
			//[
			//	"
			//		['%1',this,[['NONE','NONE'],'CLEARBUILDING'],'NO CHANGE',(currentwaypoint (group this))] call A3C_HC_INSERT_ACTION_WP;
			//	",
			//	getPlayerUID player
			//];

		};
	};
	_wp setWaypointScript _wpScript;
	_wp setwaypointStatements [((waypointStatements _wp) select 0), (((waypointStatements _wp) select 1) + _statements)];	
	_wp setwaypointSpeed _wpSpeed;
	[_wp,"UNCHANGED"] remoteExec ["setWaypointBehaviour", 2]; //-- behaviour for wp has to be executed on server
};


A3C_AI_HighCommand_ActionDistribute_boardGroupsToVehicle = {
	params ["_button","_ctrl"];
	private ["_group","_a3c_dsp"];
	//if !(count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) exitWith {systemchat 'A3C: Boarding/Dismount function is only compatible with single selections'};
	_a3c_dsp = if (visibleMap) then {100020} else {100040};
	
	

	//-- Boarding HC-units via map-ui pt 1
	(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
	(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
	if (_button == 0) then {
		A3C_UI_MAPICONS_HC_VICS = [] call A3C_fnc_getBoardableVehicles;
		if (_a3c_dsp == 100040) then {

			A3C_UI_HUD_ASSIGNVEHICLE = true;
			[
				false, //-- isBusy
				"BoardVehicle_HC", //-- actionID
				'', //-- Hud-Icon-class
				[1,0,0,1], //-- Hud-Icon-color
				"", //-- placer class
				"" //-- placer color-params
			] call A3C_AI_SHARED_Action_StartPositionalProcess;
		} else {
			if !(A3C_Boarding_ACTIVE) then {
				A3C_BOARDING_GROUPS = +(A3C_SELECTED_HC_GROUPS_SETTINGS);
				
				A3C_BOOL_MOUSEMOVING = true;
				A3C_MMCode = {
					_this spawn A3C_UI_MAP_onMouseDrag;
				};
				A3C_BOOL_DRAGLINE = true;
				A3C_CONNECTING_MODE = "HCBOARD";
				A3C_Boarding_ACTIVE = true;
			};
		};
	} else {
		private _dismountFnc = {
			params ["_group"];
			private _vehicles = [];
			// _group setVariable ["a3c_assignedgroupvehicle",nil];
			{
				_v = [_x] call A3C_AIGetOut; //-- in this case, we do not use remoteExec as we already know we are on the unit's machine. Instead, we return the vehicle
				if (!isNull _v) then {
					_vehicles pushBackUnique _v;
				};
			} foreach (units _group);
			{
				private _var = _x getVariable ["a3c_assignedvehiclecrew",[]];
				_var = _var select {!(_x select 0 in (units _group))};
				_x setVariable ["a3c_assignedvehiclecrew",_var];
			} foreach _vehicles;
		};
		_aiGroups = A3C_SELECTED_HC_GROUPS_SETTINGS select {!isPlayer leader _x};
		// right MB: dismount vehicle
		{
			private _group = _x;
			private _groupsToDismount = if (_ctrl) then {[]} else {[_group]};
			if (_ctrl) then {
				{
					_u = _x;
					if (!isNull objectParent _u) then {
						{
							if (group _x != group _u) then {
								_groupsToDismount pushBackUnique (group _x);
							};
						} foreach (crew (vehicle _u));
					};
					
				} foreach (units _group);
			};
			_groupsToDismount = _groupsToDismount - [group player]; //-- precation: We do not want the player accidentally dismounting his own troops (would dismount every single unit from his vehicle)
			//systemchat str _groupsToDismount;
			{
				_testedgroup = _x;
				[[_testedgroup],_dismountFnc] remoteExec ["bis_fnc_call",leader _testedgroup];	
			} foreach _groupsToDismount;

			if (count _groupsToDismount > 0) then {
				
				if (_ctrl) then {
					_groupString = "";
					_dismountCount = count _groupsToDismount;
					{
						_prestring = "";
						_postString = "";
						if (_foreachIndex == (_dismountCount -1)) then {
							if (_dismountCount > 1) then {
								_preString = " and ";
							};
						} else {
							if (_foreachIndex < (_dismountCount -2)) then {
								_postString = ", ";
							};
						};
						_groupString = _groupString + _preString + groupID _x + _postString;
					} foreach _groupsToDismount;
					systemchat format ["A3C: %1 is dismounting %2", groupID _group,_groupString];
				} else {
					systemchat format ["A3C: %1 was unassigned from all vehicles", groupID _group];
					
				};
				
			};
		} foreach _aiGroups;
		
	};
	
	
	
};


A3C_HC_REMOVE_WP_RC = {

	
	
	//~~ polys will need to have their ID's adjusted. 
	// NORMAL
	// AIC: 
	private _group = if (count _this > 0) then {_this select 0} else {A3C_HC_ACTIVEGROUP};
	private _wpIndex = if (count _this > 1) then {_this select 1} else {A3C_HC_ACTIVE_IND};
	private ["_isHighCommand","_waypoints","_var","_polys"];
	private _isHighCommand = ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) && {hcShownBar};
	
	//-- step 1: adjust poly-Indexes. Needs to happen BEFORE waypoint deletion
	private _polys = _group getvariable ["A3C_UNIT_POLYS",[]];
	
	//systemchat "hey";
	
	private _activeWPindex = currentWaypoint _group;
	if (_wpIndex == _activeWPindex) then {
		//-- exit possible clearing operations
		{
			_x setVariable ["A3C_CLEARING",false,true];
		} foreach (units _group);
	};
	
	{
		//systemchat str [((_x select 0) select 1),_wpIndex];
		if ( ((_x select 0) select 2) == _wpIndex ) then {
			_polys = _polys - [_x];
			_group setVariable ["A3C_UNIT_POLYS",_polys,true];
		};
		if ( ((_x select 0) select 2) > _wpIndex ) then {
			(_x select 0) set [2, ((_x select 0) select 2)-1];	
		};
	} foreach _polys;
	_group setvariable ["A3C_UNIT_POLYS",_polys,true];
	//-- adjust waypoint actionScripts
	{
		private ["_wpI"];
		_wpI = _x select 1;
		//adjust postAction poly-Waypoints
		if (_wpI >  (_wpIndex + 0)) then { //--
			_wpAdjust = ((waypoints _group) select _wpI);
			private _actionScript = (waypointStatements _wpAdjust) select 1;
			if ({[_x,_actionscript] call bis_fnc_instring} count ["suppression","ambush","LANDING","CAS-STRIKE","RAPPEL"] > 0) then {
				_actionScript = _actionscript splitstring ";"; //-- actionscript is broken down from string to array
				{
					_str = _x;
					if ( {[_x,_str] call BIS_fnc_inString} count ["SUPPRESSION","AMBUSH","LANDING","CAS-STRIKE","RAPPEL"] > 0) exitWith {
						//systemchat str _str;
						_str = _str splitString "]"; //-- convert string to array
						_subString = _str select 2;
						_subStringArray = _subString splitString ",";
						_id = (parsenumber (_substringarray select 1)) - 1; //-- remove 1 for wpi/poly sync
						if (!isNil '_id') then { //~~ ALERT! this is just coz u don't know what is happening after synced wp
							_subStringArray set [1, (str _id)];
							_subString = "," + ((_SubStringArray joinstring ","));
							_str set [2,_substring];
							_str = (_str joinString "]") + "]"; //-- re-convert poly-scriptline array to string     + 
							//systemchat str _str;
							_actionScript set [_forEachIndex,_str];
						};
					};
				} foreach _actionScript;
				_actionScript = _actionScript joinString ";"; //-- re-convert scriptlineS array to string
				//_wpAdjust setWayPointStatements [(waypointStatements _wpAdjust) select 0, _actionScript];	
			};
		};
	} foreach (waypoints _group);	
	
	//-- step 2: remove waypoint

	private _isLastWP = ({ _x select 1 > _wpIndex} count waypoints _group == 0);
	private _isCurrentWP = _wpIndex == _activeWPindex;
		
	A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_group,_wpIndex];
	publicVariable "A3C_BLACKLIST_WAYPOINT_EDIT";
	deleteWaypoint [_group,_wpIndex];

	private _leaderVic = vehicle leader _group;
	private _effCom = effectiveCommander _leaderVic;

	if (_effCom in (units _group)) then {
		if (_isLastWP) then {
			if (_isCurrentWP) then {
				private _leaderVic = vehicle leader _group;
				
				private _stopPos = (position _leaderVic) getPos [10, getDir _leaderVic];
				[_effCom, _stopPos] call A3C_DOMOVE;
				// player sidechat format ['last waypoint deleted - if current waypoint, then unit should stop. _isCurrentWP: %1', _isCurrentWP];
			};
			// [units _group] remoteExec ["commandStop",_group];
			// [_group, _activeWPindex] spawn A3C_HC_FNC_MoveToWayPointPosition; //-- not correct, should STOP!
		} else {
			if (_isCurrentWP) then {
				private _leaderVic = vehicle leader _group;
				private _movePos = waypointPosition [_group, currentWaypoint _group]; //-- while the index will be the same, the waypoint position has changed to the new current waypoint (next in line)
				[_effCom, _movePos] call A3C_DOMOVE;
				// player sidechat format ['not last waypoint, add move to new current waypoint TRICKY if current waypoint. _isCurrentWP: %1', _isCurrentWP];
				// systemchat str [_activeWPindex, currentWaypoint _group];
				// player setpos (waypointPosition [_group, currentWaypoint _group]);
			};
			
		};
	};

	//-- refresh gocodes, since deleted waypoint may have been the only one with gocode attached 
	[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];	
};


A3C_HC_LINE = {
	_group = A3C_HC_getAllGroups_Player_Current select (_this select 0);
	_mode = _this select 1;	
	_wp = (waypoints _group) select ((_this select 2) -1);
	_return = position (leader _group);
	if (_mode == 0) then {
		if ((_wp select 1) == (currentWaypoint _group)) then {
			_return = (getposworld (leader _group));
		} else {
			_return = waypointposition ( (waypoints _group) select ((_this select 2) - 2) );
		};
	} else {
		_return = waypointposition ( (waypoints _group) select ((_this select 2) - 1) );
	};
	_return
};

//~~ is this still needed?
A3C_HC_Refresh_WP_Markers = {
	private ["_group","_waypoints"];
	_group = _this;
	_waypoints = +(waypoints _group);
	//-- delete current markers
	for "_i" from 1 to (count _waypoints + 1) do {
		call compile format 
		[
			"
				A3C_HC_MARKERS = A3C_HC_MARKERS - ['A3C_HC_MARKER_%1_%2'];
				deletemarkerlocal 'A3C_HC_MARKER_%1_%2';
			
			",
			[_group,A3C_HC_DISBANDED] call MCSS_fnc_GetArrayIndex,
			_i
		]; //~~ it may be better to assign a ID-variable to each HC group? make sure that this works with changing HC arrays
	};
	
	//-- create new markers with accurate ID
	//~~ HCWP ALERT
	/*
	for "_i" from 1 to (count _waypoints) do {
		private ["_marker"];
		if ((_i - 1) >= (currentWaypoint _group)) then {
			_marker = 
			[
				format 
				[
					"A3C_HC_MARKER_%1_%2",
					[_group,A3C_HC_DISBANDED] call MCSS_fnc_GetArrayIndex,
					_i
				],
				(waypointPosition [_group,(_i - 1)]),
				"ICON",
				"A3C_Marker_HCWP",
				[0.5,0.5],
				"",
				"ColorBlufor"
			] call MCSS_fnc_createMarker;
			A3C_HC_MARKERS pushback _marker;
		};
	};
	*/
	
};


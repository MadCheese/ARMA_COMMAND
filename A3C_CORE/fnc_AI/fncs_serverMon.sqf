

//-- Vehicle turnout handler stuff 
A3C_Server_HandleDisableTurnOut = {
    if (!isServer) exitWith {};

    if (isNil "A3C_TurnOutEH_Vehicles") then {
        A3C_TurnOutEH_Vehicles = [];
    };

    {
        private _group = _x;

        if !(isNull _group) then {
            [_group] call A3C_Server_HandleDisableTurnOut_Group;
        };
    } forEach (A3C_MON_SERVER_checkGroups select {!(isPlayer leader _x)});

    [] call A3C_Server_CleanupTurnOutVehicles;
};


A3C_Server_HandleDisableTurnOut_Group = {
    params ["_group"];

    if (isNull _group) exitWith {};

    private _activeBehaviours = ["AWARE", "COMBAT", "STEALTH"];

    private _leader = leader _group;
    if (isNull _leader) exitWith {};

    private _behaviour = behaviour _leader;

    // Vehicles currently driven by members of this group
    private _currentVehicles =
        (units _group)
        select {
            private _veh = objectParent _x;
            !isNull _veh && {_x isEqualTo driver _veh}
        }
        apply { objectParent _x };

    _currentVehicles = _currentVehicles arrayIntersect _currentVehicles;

    // Keep only vehicles relevant for turnout suppression
    _currentVehicles = _currentVehicles select {
        private _className = typeOf _x;
        ["Tank", "Wheeled_APC_F"] findIf {_className isKindOf _x} > -1
    };

    // Vehicles this group is currently managing
    private _managedVehicles = _group getVariable ["A3C_ManagedTurnoutVehicles", []];
    _managedVehicles = _managedVehicles select {!isNull _x};

    if (_behaviour in _activeBehaviours) then {
        // Newly used vehicles: add EH
        private _toAdd = _currentVehicles - _managedVehicles;

        // No longer used vehicles: remove EH
        private _toRemove = _managedVehicles - _currentVehicles;

        {
            [_x] remoteExecCall ["A3C_fnc_InstallTurnOutEH", _x];
        } forEach _toAdd;

        {
            [_x] remoteExecCall ["A3C_fnc_RemoveTurnOutEH", _x];
        } forEach _toRemove;

        _group setVariable ["A3C_ManagedTurnoutVehicles", _currentVehicles];
    } else {
        {
            [_x] remoteExecCall ["A3C_fnc_RemoveTurnOutEH", _x];
        } forEach _managedVehicles;

        _group setVariable ["A3C_ManagedTurnoutVehicles", []];
    };
};


A3C_fnc_RegisterTurnOutVehicle_Server = {
    params ["_vehicle"];

    if (!isServer) exitWith {};
    if (isNull _vehicle) exitWith {};

    if (isNil "A3C_TurnOutEH_Vehicles") then {
        A3C_TurnOutEH_Vehicles = [];
    };

    if !(_vehicle in A3C_TurnOutEH_Vehicles) then {
        A3C_TurnOutEH_Vehicles pushBack _vehicle;
    };
};


A3C_fnc_UnregisterTurnOutVehicle_Server = {
    params ["_vehicle"];

    if (!isServer) exitWith {};
    if (isNil "A3C_TurnOutEH_Vehicles") exitWith {};
    if (isNull _vehicle) exitWith {};

    A3C_TurnOutEH_Vehicles = A3C_TurnOutEH_Vehicles select {
        !isNull _x && {_x != _vehicle}
    };
};


A3C_fnc_PruneTurnOutVehicleRegistry_Server = {
    if (!isServer) exitWith {};
    if (isNil "A3C_TurnOutEH_Vehicles") exitWith {};

    A3C_TurnOutEH_Vehicles = A3C_TurnOutEH_Vehicles select {!isNull _x};
};


A3C_fnc_InstallTurnOutEH = {
    params ["_vehicle"];

    if (isNull _vehicle) exitWith {};

    // This function should execute only where the vehicle is local
    if !(local _vehicle) exitWith {};

    // Guard on the machine where the vehicle is local / EH will exist
    private _existingEH = _vehicle getVariable ["A3C_TurnOutEH", -1];
    if (_existingEH >= 0) exitWith {
        [_vehicle] remoteExecCall ["A3C_fnc_RegisterTurnOutVehicle_Server", 2];
    };

    // systemChat format ["%1 (%2) had eventhandler added", _vehicle, groupID (group driver _vehicle)];

    private _ehId = _vehicle addEventHandler ["TurnOut", {
        params ["_vehicle", "_unit", "_turret"];
        {
            _x action ["TurnIn", _vehicle];
        } forEach (crew _vehicle);
    }];

    _vehicle setVariable ["A3C_TurnOutEH", _ehId];
    _vehicle setVariable ["A3C_TurnOutEH_Owner", owner _vehicle];

    [_vehicle] remoteExecCall ["A3C_fnc_RegisterTurnOutVehicle_Server", 2];
};


A3C_fnc_RemoveTurnOutEH = {
    params ["_vehicle"];

    if (isNull _vehicle) exitWith {};

    // This function should execute only where the vehicle is local
    if !(local _vehicle) exitWith {};

    private _ehId = _vehicle getVariable ["A3C_TurnOutEH", -1];
    private _ehOwner = _vehicle getVariable ["A3C_TurnOutEH_Owner", -1];
    private _currentOwner = owner _vehicle;

    if (_ehId >= 0) then {
        // systemChat format ["%1 (%2) had eventhandler removed", _vehicle, groupID (group driver _vehicle)];

        if (_ehOwner == _currentOwner) then {
            _vehicle removeEventHandler ["TurnOut", _ehId];
        } else {
            _vehicle removeAllEventHandlers "TurnOut";
        };

        _vehicle setVariable ["A3C_TurnOutEH", nil];
        _vehicle setVariable ["A3C_TurnOutEH_Owner", nil];
    };

    [_vehicle] remoteExecCall ["A3C_fnc_UnregisterTurnOutVehicle_Server", 2];
};


A3C_Server_CleanupTurnOutVehicles = {
    if (!isServer) exitWith {};
    if (isNil "A3C_TurnOutEH_Vehicles") exitWith {};

    [] call A3C_fnc_PruneTurnOutVehicleRegistry_Server;

    private _handledVehicles_Turnout = +A3C_TurnOutEH_Vehicles;

    {
        private _vehicle = _x;

        if (isNull _vehicle) then {
            // already pruned above
        } else {
            private _ehId = _vehicle getVariable ["A3C_TurnOutEH", -1];

            if (_ehId < 0) then {
                [_vehicle] call A3C_fnc_UnregisterTurnOutVehicle_Server;
            } else {
                private _driver = driver _vehicle;

                if (isNull _driver) then {
                    [_vehicle] remoteExecCall ["A3C_fnc_RemoveTurnOutEH", _vehicle];
                } else {
                    private _group = group _driver;

                    if (isNull _group) then {
                        [_vehicle] remoteExecCall ["A3C_fnc_RemoveTurnOutEH", _vehicle];
                    } else {
                        private _managedVehicles = _group getVariable ["A3C_ManagedTurnoutVehicles", []];
                        _managedVehicles = _managedVehicles select {!isNull _x};

                        if !(_vehicle in _managedVehicles) then {
                            [_vehicle] remoteExecCall ["A3C_fnc_RemoveTurnOutEH", _vehicle];
                        };
                    };
                };
            };
        };
    } forEach _handledVehicles_Turnout;
};

//-- ServerMon FSM Functions (to make editing easier. FSM editor scripting is not guhd): 

A3C_SERVERMON_fncActions = {
	// //-- remove player controlled groups from checkGroups (only relevant for this particular check)
	// _A3C_MON_SERVER_checkGroups = A3C_MON_SERVER_checkGroups select {!isPLayer leader _x};
	// //publicVariable'A3C_MON_SERVER_checkGroups';

	//-- Server handles EH-complexities for disabling Turnout
	[] call A3C_Server_HandleDisableTurnOut;

	private _gunnerSwitchFnc = {
		params ["_newGunner","_v"];
		{
			if (!alive _x) then {
				_x action ["EJECT", _v]
			};
		} foreach (crew _v);
		_newGunner assignAsGunner _v;
		_newGunner moveInGunner _v;
	};

	private _targetDistance = 2500;

	KNOWSABOUT_ARRAY = [];
	_allClients = allPlayers apply {owner _x};

	if (isDedicated) then {
		[A3C_MON_SERVER_checkGroups, _targetDistance, MCSS_fnc_NearEntities] call A3C_fnc_clientFetchKnowsAbout;
	};

	{

		[[A3C_MON_SERVER_checkGroups, _targetDistance, MCSS_fnc_NearEntities], A3C_fnc_clientFetchKnowsAbout] remoteExec ['bis_fnc_call', _x];
		sleep 0.5;
	} foreach _allClients;

	sleep (0.5 * (count _allClients)); //-- give timeout to receive update from clients. If a client fails to respond, KNOWSABOUT_ARRAY should simply not consider that client's groups
	//-- revealing of knowledge between units - 
	{
		private _gp = _x;
		private _leader = leader _gp;
		{
			private _knArray = _x;
			_knArray params ["_target","_knowsAbout"];
			
			if (_leader distance2D _target < _targetDistance) then {
				// _leader reveal _knArray;
				[_leader, _knArray] remoteExec ["reveal", _leader];
				if (A3C_DEBUG) then {
					systemchat format ["%1 knows about of %2 set to  %3", groupID _gp, typeof _target, _knowsAbout];
				};
			};
		} foreach KNOWSABOUT_ARRAY;
	} foreach A3C_MON_SERVER_checkGroups;

	// (format ["FINAL KNOWSABOUT ARRAY: %1", KNOWSABOUT_ARRAY]) remoteExec ["systemchat", 0];

	// private _allTargets = [];
	
	{

		private _gp = _x;
		private _leader = leader _x;
		private _lV = vehicle _leader;
		private _driver = driver _lv; //-- leader vehicle driver

		// //-- Target Communication - fetch targets - Including player groups

		// // _tgts =  (_leader targetsQuery [objNull, sideUnknown, "", [], 60]);
		// private _tgts = [(side _leader),_targetDistance,"ENEMY",position _lV, ["MAN","CAR","TANK","AIR","SHIP","STATICWEAPON"]] call MCSS_fnc_NearEntities;
		
		// {
		// 	private _target = _x;
		// 	private _kn = _leader knowsAbout _target;
			
		// 	if (_kn > 0) then { //-- exclude unknown targets
		// 		private _targetFound = false;
		// 		{
		// 			private _fi = _foreachIndex;
		// 			if (_target == _x select 0) exitWith {
		// 				_targetFound = true;
						
		// 				private _knRef = _x select 1;
		// 				if (_kn > _knRef) then {
		// 					_allTargets set [_fi, [_target, _kn]];
		// 				};

		// 			};
		// 		} foreach _allTargets;
		// 		if !(_targetFound) then {
		// 			_allTargets set [count _allTargets, [_target, _kn]];
		// 		};
		// 	};
		// } foreach _tgts;

		//-- Non Player groups: Other settings
		if (!isPLayer _leader) then {
			private _drivers = (units _gp) select {private _oP = objectParent _x; !isNull _oP && {_x == driver vehicle _x}};
			_comm = effectiveCommander _lv;
			_gp enableAttack false;
			//-- exclude team AI from AI-Enhancing addons (group level)
			_gp setVariable ["NOAI",1,false];
			_gp setVariable ["asr_ai_exclude", true,true];	
			_gp setVariable ["Vcm_Disable",true,true];
			_gp setVariable ["lambs_danger_dangerAIEnabled",false,true];
			_gp setVariable ["lambs_danger_disableGroupAI", true, true];
			
			
			if !(_gp in A3C_TCL_GROUPS) then {
				_gp setVariable ["TCL_Disabled", true, true];
				A3C_TCL_GROUPS pushback _x;
				//systemchat str _x;
			};
			
			//-- 'MOVE' nudge
			private _wpCurr = [_gp,currentWaypoint _gp];
			private _wpPos = waypointPosition _wpCurr;
			private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _lv) >> "precision")) + 10;
			private _condi = !isPlayer _driver &&
			{
				_driver in (units _gp) &&
				{
					waypointType _wpCurr == "MOVE" &&
					{
						speed _lv < 1 &&
						{
							!(_lv isKindOf "AIR") && 
							{
								_wpPos distance2D _lv > _precision OR
								{
									private _expD = (expectedDestination _leader) select 0;
									_expD distance2D [0,0,0] > 1 && {_expD distance2D _wpPos > 5}
								}
							}
						}	
					}
				}
			};
			if (_condi) then {
				_wpPos = (waypointPosition _wpCurr) select [0,2];
				_wpPos = _wpPos getPos [1, random 360];
				_wpPos set [2,0];
				_eff = effectiveCommander _lV;
				[_eff,_wpPos] call A3C_DOMOVE;
				//_gp move _wpPos;
				//#HCMOVE
			} else {
				if (_wpPos distance2D _lv <= _precision && {speed _lv < 1}) then {
					if ( waypointScript _wpCurr == "" && {waypointType _wpCurr == "MOVE"}) then {
						_wpCurr setWaypointPosition [getPos _lv, 0]; //-- unit got stuck just before waypoint: move waypoint to vehicle pos
						// systemchat "MOVING WP";
					};
				};
			};
			//-- automatically replace dead gunners
			{
				private _d = _x;
				private _v = objectParent _x;
				private _g = gunner _v;
				
				
				if (!isNull _g && {!alive _g}) then {
					private _crewFromGroup = ((crew _v) select {_x in (units _d) && {alive _x && {!isPlayer _x}}}) - [_d];
					_crewFromGroup = [_crewFromGroup,[],{if (_x == commander (vehicle _x)) then {1} else {0}},"ASCEND"] call BIS_fnc_sortBy;
					//private _gunnerTurret = _v unitTurret _g;
					if !(_crewFromGroup isEqualTo []) then {
						private _newGunner = _crewFromGroup select 0;
						
						[[_newGunner,_v],_gunnerSwitchFnc] remoteExec ["bis_fnc_call",_newGunner];
						//systemchat "SWITCHED TO GUNNER";			
					};
				};
			} foreach _drivers;

			private _isGroupClearing = "clearbuilding" in (toLower (waypointScript [_gp, currentWaypoint _gp]));
			_gp setVariable ["lambs_danger_disableGroupAI", false, true];
			{
				//-- exclude team AI from AI-Enhancing addons (unit level)
				_x setVariable ["NOAI",1,false];
				_x setVariable ["asr_ai_exclude", true,true];
				//_x setVariable ["TCL_Disabled", true, true];
				_x setVariable ["Vcm_Disable",true,true];
				_x setVariable ["dangerAIEnabled",false,true];
				_x setVariable ["lambs_danger_dangerAIEnabled",false,true];

				_x setVariable ["lambs_danger_disableAI", false, true];
				

				//-- enable Autocombat for SAFE Mode
				if (behaviour _x in ["SAFE"]) then {
					[_x,"AUTOCOMBAT"] remoteExec ["enableAI",_x];
				} else {
					[_x,"AUTOCOMBAT"] remoteExec ["disableAI",_x];
				};
				//-- Skill Reset
				if (A3C_isHCSkillMaxed) then {
					[_x,1] remoteExec ["setSkill",_x];
				};
				//-- prevent loaded AI groups from dismounting in combat mode (more suited for non commanded units)
				if (!isnull objectParent _x) then {
					if (_x == driver vehicle _x) then {
						[(vehicle _x),[false,false]] remoteExec ["setUnloadInCombat",(vehicle _x)];	
					};
				};
				//-- Force AI to follow leader  #note: doesn't this break scripts?
				if (currentCommand _x == "STOP" && {!(_isGroupClearing)}) then {
					[_x, _leader] remoteExec ["doFollow",_x];

					// (format ["%1 calling back %2 to formation 1. current PATH count: %3", groupID (group _x), name _x, count (_x getVariable ["A3C_PLOT",[]]) ]) remoteExec ["systemchat", 0];
				};
			} foreach (units _gp);

			//-- Resupply Actions

			if (getNumber (configFile >> "CfgVehicles" >> typeof _lV >> "transportAmmo" ) > 1000) then {
				_nearVehicles = (_lV nearEntities [["AIR","TANK","CAR","SHIP","STATICWEAPON"], 150]) select {side _x == side _gp && {isTouchingGround _x}};
				{
					_x setVehicleAmmo 1;
					//-- Bobcat Fixed Line Charge Resupply (Mod Support)
					if (typeOf _x in ["B_APC_Tracked_01_CRV_F_Fixed", "B_T_APC_Tracked_01_CRV_F_Fixed"]) then {
						_x setVariable ["MCSS_MCLC_MAGCOUNT", 4, true];
						// systemchat format ["BOBCAT RESSUPLIED BY %1", groupID (group driver_lV)];
					};
				} foreach _nearVehicles;
			};
			if (getNumber (configFile >> "CfgVehicles" >> typeof _lV >> "transportFuel" ) > 1000) then {
				_nearVehicles = (_lV nearEntities [["AIR","TANK","CAR","SHIP","STATICWEAPON"], 150]) select {side _x == side _gp && {isTouchingGround _x}};
				{_x setFuel 1} foreach _nearVehicles;
			};
		};
	} foreach A3C_MON_SERVER_checkGroups;

	//-- Blacklist WPs
	{
		if ((_x select 1) < currentWaypoint (_x select 0)) then {
			A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_x];
		};
	} forEach A3C_BLACKLIST_WAYPOINT_EDIT;
	publicVariable "A3C_BLACKLIST_WAYPOINT_EDIT";
};


/*

	Q: WHY SO COMPLICATED?
	A: Because knowsAbout is a local variable and can't be accessed remotely. Therefore, in order to sync KN values over the friendly forces,
	we need this hacky workaround that effectively broadcasts local KN-values from all clients to the server.
*/


MCSS_fnc_serverReceiveKnowsAbout = {
    params ["_client", "_knowsAboutData"];

	// (format ["Client %1 sent %2 knowsAbout entries", _client, count _knowsAboutData]) remoteExec ["systemchat", 0];
    // Merge the data into the global array
    {
		_x params ["_target", "_knowsAbout"];

        private _found = false;
        {
            if (_x select 0 == _target) exitWith {
                _found = true;
                if (_knowsAbout > _x select 1) then {
                    KNOWSABOUT_ARRAY set [_foreachIndex, [_target, _knowsAbout]];
                };
            };
        } forEach KNOWSABOUT_ARRAY;

        if (!_found) then {
            KNOWSABOUT_ARRAY set [count KNOWSABOUT_ARRAY, _x];
        };
    } forEach _knowsAboutData;    
};

if (!isServer) exitWith {};

KNOWSABOUT_ARRAY = [];

A3C_fnc_clientFetchKnowsAbout = {
    params ["_groups", "_targetDistance", "_fncEntities"];

	private _groupsLocal = _groups select {local _x};


	

    private _allTargets = [];

	{
		private _gp = _x;
		private _leader = leader _x;
		private _lV = vehicle _leader;

	

		private _tgts = [(side _leader),_targetDistance,"ENEMY",position _lV, ["MAN","CAR","TANK","AIR","SHIP","STATICWEAPON"]] call _fncEntities;
		
		{
			private _target = _x;
			private _kn = _leader knowsAbout _target;
			
			if (_kn > 0) then { //-- exclude unknown targets
				
				private _found = false;
				{
					if (_x select 0 == _target) exitWith {
						_found = true;
						if (_kn > _x select 1) then {
							_allTargets set [_foreachIndex, [_target, _kn]];
						};
					};
				} forEach _allTargets;

				if (!_found) then {
					_allTargets set [count _allTargets, [_x, _kn]];
				};
			};
		} foreach _tgts;
	} foreach _groupsLocal;

	if (isServer) then {
		KNOWSABOUT_ARRAY = _allTargets;
		// (str KNOWSABOUT_ARRAY) remoteExec ["systemchat", 0];
	} else {
		// Send the results back to the server
		// player commandchat format ["Your client is sending back _allTargets with %1 entries", count _allTargets];
		[clientOwner, _allTargets] remoteExecCall ["MCSS_fnc_serverReceiveKnowsAbout", 2]; // Send to server only
	};
    
};














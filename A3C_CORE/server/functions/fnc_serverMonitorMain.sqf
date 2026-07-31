// A3C_server_fnc_serverMonitorMain

//-- ServerMon FSM Functions (to make editing easier. FSM editor scripting is not guhd): 

//-- Server handles EH-complexities for disabling Turnout

// (format ["Running ServerLoop %1", round time]) remoteExec ["systemchat", 0];

[] call A3C_server_fnc_handleDisableTurnout;

private _gunnerSwitchFnc = {
	params ["_newGunner", "_vehicle"];

	{
		if (!alive _x) then {
			_x action ["EJECT", _vehicle];
		};
	} forEach crew _vehicle;

	_newGunner assignAsGunner _vehicle;
	_newGunner moveInGunner _vehicle;
};

private _targetDistance = 2500;

KNOWSABOUT_ARRAY = [];

private _allClients = allPlayers apply {
	owner _x
};

if (isDedicated) then {
	[A3C_MON_SERVER_checkGroups, _targetDistance, MCSS_fnc_NearEntities] call A3C_main_fnc_knowsAboutClientFetch;
};

{
	[[A3C_MON_SERVER_checkGroups, _targetDistance, MCSS_fnc_NearEntities], A3C_main_fnc_knowsAboutClientFetch] remoteExec ["bis_fnc_call", _x];
	sleep 0.5;
} forEach _allClients;

sleep (0.5 * count _allClients); //-- give timeout to receive update from clients. If a client fails to respond, KNOWSABOUT_ARRAY should simply not consider that client's groups

//-- revealing of knowledge between units
{
	private _group = _x;
	private _leader = leader _group;

	{
		private _knowledgeEntry = _x;
		_knowledgeEntry params ["_target", "_knowsAbout"];

		if (_leader distance2D _target < _targetDistance) then {
			[_leader, _knowledgeEntry] remoteExec ["reveal", _leader];

			if (A3C_DEBUG) then {
				systemChat format ["%1 knows about of %2 set to  %3", groupID _group, typeOf _target, _knowsAbout];
			};
		};
	} forEach KNOWSABOUT_ARRAY;
} forEach A3C_MON_SERVER_checkGroups;

{
	private _group = _x;
	private _leader = leader _group;
	private _leaderVehicle = vehicle _leader;
	private _driver = driver _leaderVehicle; //-- leader vehicle driver
	private _groupUnits = units _group;

	//-- AI-Only groups should always be managed by server if running on dedicated.
	//-- Excluded: UAV's - ALL Uav's until we figure out why CROCUS-FPV drones have their group deleted
	//-- NOTE: We could detect CROCUS objects but that's vulnerable if other addon-UAV's have the same issue
	
	if (
		isDedicated
		&& {A3C_DEDI_allowLocalitySwitch}
		&& {!local _group}
		&& {
			{
				isPlayer _x
				|| {unitIsUAV (vehicle _x)}
			} count _groupUnits == 0
		}
	) then {
		_group setGroupOwner 2;
	};

	//-- Non Player groups: Other settings
	if (!isNull _leader && {!isPlayer _leader}) then {
		private _vehicleConfig = configFile >> "CfgVehicles" >> typeOf _leaderVehicle;

		private _drivers = _groupUnits select {
			private _objectParent = objectParent _x;

			!isNull _objectParent && {_x == driver vehicle _x}
		};

		//-- enableAttack-false will prevent subordinates from moving when player commander does not want it 
		//-- #ToDo: test if this makes sense to add as an action
		[_group, false] remoteExecCall ["enableAttack", leader _group];
		//-- allowFleeing disabled means that groups won't erratically move when player commander does not want it
		[_group, 0] remoteExecCall ["allowFleeing", leader _group];

		//-- exclude team AI from AI-Enhancing addons (group level)
		_group setVariable ["NOAI", 1, false];
		_group setVariable ["asr_ai_exclude", true, true];
		_group setVariable ["Vcm_Disable", true, true];
		_group setVariable ["lambs_danger_dangerAIEnabled", false, true];
		_group setVariable ["lambs_danger_disableGroupAI", true, true];

		if !(_group in A3C_TCL_GROUPS) then {
			_group setVariable ["TCL_Disabled", true, true];
			A3C_TCL_GROUPS pushBack _group;
		};

		//-- 'MOVE' nudge
		private _currentWaypoint = [_group, currentWaypoint _group];
		private _waypointPosition = waypointPosition _currentWaypoint;
		private _precision = getNumber (_vehicleConfig >> "precision") + 10;

		private _isMoveWaypoint = waypointType _currentWaypoint == "MOVE";
		private _isUnscriptedWaypoint = waypointScript _currentWaypoint == "";
		private _isStopped = speed _leaderVehicle < 1;
		private _isGroundVehicle = !(_leaderVehicle isKindOf "AIR");
		private _driverOk = !isPlayer _driver && {_driver in _groupUnits};

		private _expectedDestination = expectedDestination _leader select 0;
		private _hasExpectedDestination = _expectedDestination distance2D [0, 0, 0] > 1;
		private _offExpectedDestination = _hasExpectedDestination && {_expectedDestination distance2D _waypointPosition > 5};

		private _farFromWaypoint = _waypointPosition distance2D _leaderVehicle > _precision;
		private _shouldNudge = _driverOk
			&& {_isMoveWaypoint}
			&& {_isUnscriptedWaypoint}
			&& {_isStopped}
			&& {_isGroundVehicle}
			&& {_farFromWaypoint || {_offExpectedDestination}};

		if (_shouldNudge) then {
			private _nudgePosition = +_waypointPosition;
			_nudgePosition resize 2;
			_nudgePosition = _nudgePosition getPos [1, random 360];
			_nudgePosition set [2, 0];

			private _effectiveCommander = effectiveCommander _leaderVehicle;
			[_effectiveCommander, _nudgePosition] call A3C_ai_shared_fnc_doMove;
		} else {
			if (
				_driverOk
				&& {_isMoveWaypoint}
				&& {_isUnscriptedWaypoint}
				&& {_isStopped}
				&& {_waypointPosition distance2D _leaderVehicle <= _precision}
				&& {waypointTimeoutCurrent _group == -1}
				&& {waypointScript _currentWaypoint == ""}
				&& {count synchronizedWaypoints _currentWaypoint == 0}
			) then {
				_currentWaypoint setWaypointPosition [getPosASL _leaderVehicle, -1];
			};
		};

		//-- automatically replace dead gunners and disable driver "COVER" feature
		{
			private _driverUnit = _x;
			private _vehicle = objectParent _driverUnit;
			private _gunner = gunner _vehicle;

			// if (_driverUnit checkAIFeature "COVER") then {
			// 	_driverUnit enableAIFeature ["COVER", false];
			// };

			if (!isNull _gunner && {!alive _gunner}) then {
				private _crewFromGroup = crew _vehicle select {
					_x in units _driverUnit && {alive _x && {!isPlayer _x}}
				};

				_crewFromGroup = _crewFromGroup - [_driverUnit];

				_crewFromGroup = [
					_crewFromGroup,
					[],
					{
						if (_x == commander vehicle _x) then {
							1
						} else {
							0
						}
					},
					"ASCEND"
				] call BIS_fnc_sortBy;

				if (_crewFromGroup isNotEqualTo []) then {
					private _newGunner = _crewFromGroup select 0;

					[[_newGunner, _vehicle], _gunnerSwitchFnc] remoteExec ["bis_fnc_call", _newGunner];
				};
			};
		} forEach _drivers;

		private _isGroupClearing = "clearbuilding" in toLower waypointScript [_group, currentWaypoint _group];

		_group setVariable ["lambs_danger_disableGroupAI", false, true];

		{
			//-- exclude team AI from AI-Enhancing addons (unit level)
			_x setVariable ["NOAI", 1, false];
			_x setVariable ["asr_ai_exclude", true, true];
			_x setVariable ["Vcm_Disable", true, true];
			_x setVariable ["dangerAIEnabled", false, true];
			_x setVariable ["lambs_danger_dangerAIEnabled", false, true];

			_x setVariable ["lambs_danger_disableAI", false, true];

			//-- enable Autocombat for SAFE Mode
			if (behaviour _x == "SAFE") then {
				[_x, "AUTOCOMBAT"] remoteExec ["enableAI", _x];
			} else {
				[_x, "AUTOCOMBAT"] remoteExec ["disableAI", _x];
			};

			//-- Skill Reset
			if (A3C_isHCSkillMaxed) then {
				[_x, 1] remoteExec ["setSkill", _x];
			};

			//-- prevent loaded AI groups from dismounting in combat mode (more suited for non commanded units)
			if (!isNull objectParent _x) then {
				if (_x == driver vehicle _x) then {
					[vehicle _x, [false, false]] remoteExec ["setUnloadInCombat", vehicle _x];
				};
			};

			//-- Force AI to follow leader  #note: doesn't this break scripts?
			if (currentCommand _x == "STOP" && {!_isGroupClearing}) then {
				[_x, _leader] remoteExec ["doFollow", _x];
			};
		} forEach _groupUnits;

		//-- Resupply Actions
		private _canResupplyAmmo = getNumber (_vehicleConfig >> "transportAmmo") > 1000;
		private _canResupplyFuel = getNumber (_vehicleConfig >> "transportFuel") > 1000;

		if (_canResupplyAmmo || {_canResupplyFuel}) then {
			private _nearVehicles = _leaderVehicle nearEntities [["AIR", "TANK", "CAR", "SHIP", "STATICWEAPON"], 150] select {
				side _x == side _group && {isTouchingGround _x}
			};

			if (_canResupplyAmmo) then {
				{
					[_x, 1] remoteExec ["setVehicleAmmo", _x];

					//-- Bobcat Fixed Line Charge Resupply (Mod Support)
					if (typeOf _x in ["B_APC_Tracked_01_CRV_F_Fixed", "B_T_APC_Tracked_01_CRV_F_Fixed"]) then {
						_x setVariable ["MCSS_MCLC_MAGCOUNT", 4, true];
					};
				} forEach _nearVehicles;
			};

			if (_canResupplyFuel) then {
				{
					[_x, 1] remoteExec ["setFuel", _x];
				} forEach _nearVehicles;
			};
		};
	};
} forEach A3C_MON_SERVER_checkGroups;

//-- Blacklist WPs
{
	if ((_x select 1) < currentWaypoint (_x select 0)) then {
		A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_x];
	};
} forEach A3C_BLACKLIST_WAYPOINT_EDIT;

publicVariable "A3C_BLACKLIST_WAYPOINT_EDIT";


params ["_group", "_pos", "_target","_callerUID","_preCondition","_postCondition","_direction","_overwatch_height","_formation"];

if (isNull _group || {!local _group}) exitWith {true};
if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

// A. Invocation ownership. No external lifecycle function or global registry.
// Capture BEFORE reInitGroupMovement / approachWaypointRegular enable PATH/MOVE.
private _wpIndex = currentWaypoint _group;
private _wp = [_group,_wpIndex];
private _leader = leader _group;
private _leaderVic = vehicle _leader;
private _groupPilots = (units _group) select {
	private _v = vehicle _x;
	_x == driver _v && {[_v] call A3C_main_fnc_isAttackHelicopter}
};
private _owRun = createHashMap;
private _owSignature = {
	params ["_wp"];
	[waypointPosition _wp, waypointScript _wp, waypointType _wp,
		waypointStatements _wp, waypointFormation _wp, waypointBehaviour _wp,
		waypointCombatMode _wp, waypointSpeed _wp, waypointTimeout _wp,
		waypointCompletionRadius _wp]
};
private _owCurrent = {
	params ["_run", ["_session",createHashMap]];
	private _g = _run get "group";
	private _wp = _run get "wp";
	if (_run get "closed" || {isNull _g} || {!local _g}
		|| {!((_g getVariable ["A3C_OW_Invocation",createHashMap]) getOrDefault ["id",[]]
			isEqualTo (_run get "id"))}
		|| {!(_wp in waypoints _g)} || {currentWaypoint _g != (_wp select 1)}
		|| {!(([_wp] call (_run get "signatureCode")) isEqualTo (_run get "signature"))}
		|| {leader _g != (_run get "leader")} || {!alive (_run get "leader")}
		|| {!local (_run get "leader")} || {isPlayer (_run get "leader")}
		|| {vehicle (_run get "leader") != (_run get "leaderVehicle")}
		|| {!local (_run get "leaderVehicle")} || {!canMove (_run get "leaderVehicle")}
		|| {!alive (_run get "leaderPilot")} || {!local (_run get "leaderPilot")}
		|| {isPlayer (_run get "leaderPilot")} || {group (_run get "leaderPilot") != _g}
		|| {driver (_run get "leaderVehicle") != (_run get "leaderPilot")}) exitWith {false};
	if (count _session == 0) exitWith {true};
	private _v = _session get "vehicle";
	private _p = _session get "pilot";
	!(_session get "closed") && {alive _v} && {canMove _v}
		&& {alive _p} && {!isPlayer _p} && {local _v} && {local _p}
		&& {driver _v == _p} && {vehicle _p == _v} && {group _p == _g}
		&& {((_v getVariable ["A3C_OW_Session",createHashMap]) getOrDefault ["id",[]])
			isEqualTo (_session get "id")}
};
private _owPhase = {
	params ["_session","_phase"];
	if ((_session get "phase") == _phase) exitWith {};
	_session set ["phase",_phase];
	private _v = _session get "vehicle";
	if (_v getVariable ["A3C_OW_LifecycleDebug",false]) then {
		diag_log format ["A3C OW %1 %2 phase %3",_session get "id",_v,_phase];
	};
};
private _owReleaseSession = {
	params ["_session","_reason",["_self",scriptNull]];
	if (_session get "closed") exitWith {};
	_session set ["closed",true]; // Invalidate first; handover/release is unscheduled.
	_session set ["fireRequest",createHashMap];
	_session set ["missileFlight",createHashMap]; // Launched projectiles keep their captured guidance target.
	_session set ["missileFlights",[]];
	private _v = _session get "vehicle";
	private _p = _session get "pilot";
	private _owned = ((_v getVariable ["A3C_OW_Session",createHashMap]) getOrDefault ["id",[]])
		isEqualTo (_session get "id");
	private _rotation = _session get "rotation";
	private _rotationRunning = !scriptDone _rotation;
	if (_rotationRunning) then {terminate _rotation;};
	private _worker = _session get "worker";
	if (!(_worker isEqualTo _self) && {!scriptDone _worker}) then {
		terminate _worker;
	};
	if (_owned) then {
		{
			_x params ["_actor","_target"];
			private _lease = _actor getVariable ["A3C_OW_FeatureSession",createHashMap];
			if (local _actor && {alive _actor} && {!isPlayer _actor}
				&& {!(_actor == _v && {isPlayer gunner _v})}
				&& {_actor == _v || {
					(_lease getOrDefault ["id",[]]) isEqualTo (_session get "id")
					&& {(_lease getOrDefault ["vehicle",objNull]) == _v}
				}}
				&& {(assignedTarget _actor) isEqualTo _target}) then {
				_actor doTarget objNull;
				_actor doWatch objNull;
			};
		} forEach (_session get "targetOrders");
	};
	// Remove our exact local EH even if locality was lost. Never another EH ID.
	private _eh = _session get "firedEH";
	if (_owned && {_eh >= 0}) then {_v removeEventHandler ["Fired",_eh];};
	{if (!isNull _x) then {deleteVehicle _x;};} forEach (_session get "lasers");
	_session set ["lasers",[]];
	if (_owned) then {
		// AI feature values are local. Do not route stale restoration to a new owner.
		{
			_x params ["_actor","_feature","_saved"];
			private _lease = _actor getVariable ["A3C_OW_FeatureSession",createHashMap];
			if (!isNull _actor && {local _actor}
				&& {_actor == _v || {
					(_lease getOrDefault ["id",[]]) isEqualTo (_session get "id")
					&& {(_lease getOrDefault ["vehicle",objNull]) == _v}
				}}) then {
				_actor enableAIFeature [_feature,_saved];
			};
		} forEach (_session get "savedFeatures");
		{
			private _actor = _x select 0;
			private _lease = _actor getVariable ["A3C_OW_FeatureSession",createHashMap];
			if ((_lease getOrDefault ["id",[]]) isEqualTo (_session get "id")
				&& {(_lease getOrDefault ["vehicle",objNull]) == _v}) then {
				_actor setVariable ["A3C_OW_FeatureSession",nil];
			};
		} forEach (_session get "savedFeatures");
		if (local _v) then {
			if (_session get "rotationSpeedOwned" && {_rotationRunning}) then {
				_v limitSpeed false;
			};
			if (_session get "freezeOwned") then {
				_v setVariable ["A3C_Freeze_helicopter",[false,0],true];
			};
			if (_eh >= 0) then {
				_v setVariable ["A3C_fireComplete",nil,true];
				_v setVariable ["A3C_Guided_Projectile",nil,true];
				_v setVariable ["A3C_OW_Ranking",nil];
			};
			if (driver _v == _p && {!isPlayer _p}) then {
				_v flyInHeight (_p getVariable ["A3C_FLYINHEIGHT",100]);
			};
		};
		private _actual = [_v checkAIFeature "PATH",_v checkAIFeature "FIREWEAPON"];
		_v setVariable ["A3C_OW_LastCleanup",[
			_session get "id",_reason,_session get "phase",
			[_session get "pathBefore",_session get "fireBefore"],_actual,local _v
		]];
		_v setVariable ["A3C_OW_Session",nil];
		if (_v getVariable ["A3C_OW_LifecycleDebug",false]) then {
			diag_log format ["A3C OW %1 cleanup %2; restore PATH/FIREWEAPON %3; actual %4; local=%5",
				_session get "id",_reason,[_session get "pathBefore",_session get "fireBefore"],_actual,local _v];
		};
	};
};
private _owReleaseRun = {
	params ["_run","_reason"];
	if (_run get "closed") exitWith {};
	_run set ["closed",true];
	{[_x,_reason] call (_run get "releaseSession");} forEach (_run get "sessions");
	private _monitor = _run get "monitor";
	if (_monitor >= 0) then {removeMissionEventHandler ["EachFrame",_monitor];};
	_run set ["monitor",-1];
	private _g = _run get "group";
	if (((_g getVariable ["A3C_OW_Invocation",createHashMap]) getOrDefault ["id",[]])
		isEqualTo (_run get "id")) then {_g setVariable ["A3C_OW_Invocation",nil];};
	{
		private _v = _x get "vehicle";
		if (_v getVariable ["A3C_OW_LifecycleDebug",false]) then {
			diag_log format ["A3C OW %1 cleanup handler %2 removed (%3)",_run get "id",_monitor,_reason];
		};
	} forEach (_run get "sessions");
	_run set ["sessions",[]]; // Break run/session references after final release.
};
private _owMainCurrent = {
	private _valid = [_owRun] call _owCurrent;
	if (_valid) then {_owRun set ["heartbeat",time];};
	_valid
};
// Capture whether Arma provided a usable main-script handle.
// This must remain a separate Boolean: completed script handles
// may subsequently become null handles.
private _owMainHandle = if (isNil "_thisScript") then {
    scriptNull
} else {
    _thisScript
};

private _owHasMainHandle = !isNull _owMainHandle;
// Release old ownership and capture the restored baseline in ONE handover.
isNil {
	private _old = _group getVariable ["A3C_OW_Invocation",createHashMap];
	if (count _old > 0) then {[_old,"replacement invocation"] call (_old get "release");};
	{
		private _oldSession = (vehicle _x) getVariable ["A3C_OW_Session",createHashMap];
		if (count _oldSession > 0) then {
			private _oldRun = _oldSession get "run";
			[_oldRun,"helicopter reassigned"] call (_oldRun get "release");
		};
	} forEach _groupPilots;
	// A pilot/AI commander can move between helicopters while an old run exists.
	// Release that actor's previous feature owner before sampling its baseline.
	{
		private _lease = _x getVariable ["A3C_OW_FeatureSession",createHashMap];
		if (count _lease > 0) then {
			private _oldRun = _lease get "run";
			[_oldRun,"crew reassigned"] call (_oldRun get "release");
		};
	} forEach (units _group);
	if (_groupPilots isEqualTo [] || {isPlayer _leader}
		|| {_groupPilots findIf {vehicle _x == _leaderVic} < 0}
		|| {_groupPilots findIf {!local _x || {!local vehicle _x} || {isPlayer _x}} >= 0}) exitWith {};
	private _serial = (_group getVariable ["A3C_OW_RunSerial",0]) + 1;
	_group setVariable ["A3C_OW_RunSerial",_serial];
	_owRun = createHashMapFromArray [
		["id",[clientOwner,_group,_serial]],["group",_group],["wp",_wp],
		["leader",_leader],["leaderVehicle",_leaderVic],["leaderPilot",driver _leaderVic],
		["signatureCode",_owSignature],["signature",[_wp] call _owSignature],
		["closed",false],["heartbeat",time],["nextCheck",0],["monitor",-1],
		["main", _owMainHandle],
		["hasMainHandle", _owHasMainHandle],
		["sessions",[]],["release",_owReleaseRun],["releaseSession",_owReleaseSession],
		["valid",_owCurrent],["phaseCode",_owPhase]
	];
	_group setVariable ["A3C_OW_Invocation",_owRun];
	{
		private _v = vehicle _x;
		private _path = _v checkAIFeature "PATH";
		private _fire = _v checkAIFeature "FIREWEAPON";
		private _saved = [[_v,"PATH",_path],[_v,"FIREWEAPON",_fire]];
		{_saved pushBack [_v,_x,_v checkAIFeature _x];} forEach ["MOVE"];
		private _pilot = _x;
		{
			private _actor = _x;
			{_saved pushBack [_actor,_x,_actor checkAIFeature _x];} forEach ["PATH","MOVE","ANIM"];
		} forEach (units _group select {vehicle _x == _v && {local _x} && {!isPlayer _x}});
		private _session = createHashMapFromArray [
			["id",_owRun get "id"],["run",_owRun],["vehicle",_v],["pilot",_pilot],
			["phase","TRAVEL"],["closed",false],["pathBefore",_path],["fireBefore",_fire],
			["savedFeatures",_saved],["fireOwned",false],["freezeOwned",false],
			["worker",scriptNull],["workerStarted",false],["rotation",scriptNull],
			["rotationSpeedOwned",false],["firedEH",-1],["lasers",[]],["targetOrders",[]],
			["fireRequest",createHashMap],["missileFlight",createHashMap],["missileFlights",[]],["lastFire",[]]
		];
		(_owRun get "sessions") pushBack _session;
		_v setVariable ["A3C_OW_Session",_session];
		{(_x select 0) setVariable ["A3C_OW_FeatureSession",_session];} forEach _saved;
		if (_v getVariable ["A3C_OW_LifecycleDebug",false]) then {
			diag_log format ["A3C OW %1 new invocation %2 phase TRAVEL; PATH acquisition original=%3; FIREWEAPON original=%4",
				_session get "id",_v,_path,_fire];
		};
	} forEach _groupPilots;
	// C. Explicit EH arguments; this handler inherits NO waypoint-private scope.
	_owRun set ["monitor",addMissionEventHandler ["EachFrame",{
		_thisArgs params ["_run"];
		if (diag_tickTime < (_run get "nextCheck")) exitWith {};
		_run set ["nextCheck",diag_tickTime + 0.1];
		private _reason = "";

		if !([_run] call (_run get "valid")) then {
			_reason = "waypoint/run invalidated";
		};

		if (
			(_run get "hasMainHandle")
			&& {scriptDone (_run get "main")}
		) then {
			_reason = "waypoint script stopped";
		};
		// Native SCRIPTED WPs may not expose _thisScript: a 15 s heartbeat lease.
		if (time - (_run get "heartbeat") > 15) then {_reason = "waypoint heartbeat expired";};
		if (_reason != "") exitWith {[_run,_reason] call (_run get "release");};
		{
			private _session = _x;
			if !(_session get "closed") then {
				private _reason = "";
				if !([_run,_session] call (_run get "valid")) then {_reason = "helicopter/pilot/locality invalidated";};
				if (_session get "workerStarted" && {scriptDone (_session get "worker")}) then {_reason = "worker stopped";};
				if (_session get "freezeOwned"
					&& {!(((_session get "vehicle") getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)}) then {
					_reason = "hover cancelled";
				};
				if (_reason != "") then {[_session,_reason] call (_run get "releaseSession");};
			};
		} forEach (_run get "sessions");
	},[_owRun]]];
};
if (count _owRun == 0) exitWith {true};

// B. Existing flight and targeting; mutations/waits observe this invocation.
isNil {
	if !(call _owMainCurrent) exitWith {};
	[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;
	_group setFormation _formation;
};
private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.3;
private _leaderSession = _leaderVic getVariable ["A3C_OW_Session",createHashMap];
isNil {
	if (call _owMainCurrent) then {
		_leader setBehaviourStrong "CARELESS"; //-- pilot avoids frontal attacks; gunner still engages
	};
};

private _t = time;


waitUntil {
	sleep 0.05;
	!(call _owMainCurrent) || {
		{((vehicle _x) getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0} count _groupPilots == 0
	}
};
if !(call _owMainCurrent) exitWith {isNil {[_owRun,"travel cancelled"] call _owReleaseRun;}; true};


isNil {if (call _owMainCurrent) then {_leader setCombatMode "BLUE";};};

_leaderDist = _leaderVic distance2d _pos; 
_closeTo = _precision;
_doSlowDown = false;

if (_leaderDist > 600) then {
	_closeTo = 500;
	_doSlowDown = true;
};



//-- wait for arrival

while {call _owMainCurrent && {_leaderVic distance2d _pos >= _closeTo}} do { //--_precision
	_wPos = waypointPosition [_group, _wpIndex];
	{_x set [2,0]} foreach [_pos, _wPos];
	if !(_pos isEqualTo _wPos) then {
		_pos = _wPos;
	};

	isNil {
		if !(call _owMainCurrent) exitWith {};
		_leader setBehaviourStrong "CARELESS";
		{
			private _session = _x;
			if ([_owRun,_session] call _owCurrent) then {
				private _v = _session get "vehicle";
				private _pilot = _session get "pilot";
				_v limitSpeed false;
				{_x enableAI "PATH"; _x enableAI "MOVE";} forEach [_pilot,_v];
			};
		} forEach (_owRun get "sessions");
		[_group,_pos] call A3C_ai_shared_fnc_approachWaypointRegular;
	};
	sleep 5;
};



if !(call _owMainCurrent) exitWith {isNil {[_owRun,"approach cancelled"] call _owReleaseRun;}; true};

//-- slow down aircraft

if (_doSlowDown && {speed _leaderVic > 80}) then {
	_posFrom = getPosASL _leaderVic;
	_posTo = _pos;
	_originalDistance =  _posFrom distance2D _posTo;
	_smallestDistance = +(_originalDistance);
	_speed = 0;  
	_originalspeed = (speed _leaderVic) max 10; 
	// ALL also disables FIREWEAPON/aiming and loses pre-disabled feature values.
	// Freeze only movement while retaining the existing velocity taper.
	private _brakeFeatures = [];
	isNil {
		if !(call _owMainCurrent) exitWith {};
		[_leaderSession,"BRAKING"] call _owPhase;
		{
			private _actor = _x;
			{
				_brakeFeatures pushBack [_actor,_x,_actor checkAIFeature _x];
				_actor enableAIFeature [_x,false];
			} forEach ["PATH","MOVE"];
		} forEach [_leaderVic,_leader];
		doStop _leaderVic;
	};
	
	//systemchat 'slowdown';
	_linCon = 1;
	while {call _owMainCurrent && {_lincon > 0.2}} do {
		_vel = velocity _leaderVic; 
		_dir = direction _leaderVic;
		_currentDistance = getPosASL _leaderVic distance2D _posTo; 
		if (_currentDistance > _smallestDistance) exitWith {};
		_smallestDistance = +(_currentDistance);
		_linCon = linearConversion [ 0, _originalDistance, _currentDistance, 0, 1, true ];
		_speed = _originalspeed * _linCon;
		//hintsilent str [_linCon,_speed];
		_speedReal = _speed / 3.6;
		isNil {
			if !(call _owMainCurrent) exitWith {};
			doStop _leaderVic;
			_leaderVic setVelocity [(sin _dir * _speedReal),(cos _dir * _speedReal),(_vel select 2)];
		};
		sleep 0.01; 
	};
	isNil {
		if !(call _owMainCurrent) exitWith {};
		{_x params ["_actor","_feature","_saved"]; _actor enableAIFeature [_feature,_saved];} forEach _brakeFeatures;
	};

};

if !(call _owMainCurrent) exitWith {isNil {[_owRun,"braking cancelled"] call _owReleaseRun;}; true};
isNil {
	if !(call _owMainCurrent) exitWith {};
	_leader domove (position _leaderVic);
	_leader setCombatMode "YELLOW";
};

while {call _owMainCurrent && {speed _leaderVic > 10}} do {
	isNil {if (call _owMainCurrent) then {_leader setBehaviourStrong "CARELESS";};};
	sleep 2;
};

if !(call _owMainCurrent) exitWith {isNil {[_owRun,"arrival cancelled"] call _owReleaseRun;}; true};

//-- compose pre- and post conditions, wait for pre-condition
private _timer = time;

//-- CONDITIONS: Step 1
private _exitCondition = {};
private _retriggered = false;
{
	_x params ["_condType","_condVal"];
	_exitCondition = switch (toUpper _condType) do {
		case ("TIMEOUT") : {
			_timeAtCompletion = time + _condVal;

			compile format [
				"time > %1",
				_timeAtCompletion
			];
		};

		case ("GOCODE") : {
			private _goCodeActivationVariableName = [
				_condVal,
				side _group
			] call A3C_main_fnc_getGoCodeActivationVariableName;

			compile format [
				"missionNamespace getVariable ['%1', false]",
				_goCodeActivationVariableName
			];
		};

		case ("DAYTIME") : {
			_str = _condVal splitString ":";
			_checkParams = [];

			{
				_checkParams pushBack (parseNumber _x);
			} foreach _str;

			compile format [
				"%1 call A3C_main_fnc_isDaytimeCompleted",
				_checkParams
			];
		};

		default {
			{true}
		};
	};

	//-- pre-condition other than 'arrival' will wait and re-trigger waypoint script
	//-- when script is re-triggered, condition is satisfied and script continues
	//-- second cycle is only relevant if post-condition exists. In that case the _exitCondition is stored for later reference


	if (_foreachIndex == 0) then {
		waitUntil {sleep 0.05; !(call _owMainCurrent) || {[] call _exitCondition}};
		if !(call _owMainCurrent) exitWith {}; //-- _foreachIndex == 0 is for pre-condition
		if !((_preCondition select 0) in ["ARRIVAL",""]) then {
			private _wpScript = waypointScript _wp;
			if ("[" in _wpScript) then {
				//-- assign new params for script re-trigger
				_wpScript = _wpScript splitString " ";
				_wpScript params ["_scrPath","_scrParams"];
				_scrParams =  call compile _scrParams;
				_scrParams set [1, ['ARRIVAL',''] ];
				_scrParams set [2, _postCondition ];
				_scrParams = str _scrParams;
				_wpScript = format ["%1 %2", _scrPath,_scrParams];
			};
			isNil {
				if !(call _owMainCurrent) exitWith {};
				// The next native invocation captures the restored baseline.
				[_owRun,"precondition retrigger"] call _owReleaseRun;
				_retriggered = true;
				_wp setWaypointScript _wpScript;
				_wp setWaypointPosition [_pos,0];
				private _statements = waypointStatements _wp;
				_statements set [0,"true"];
				_wp setWaypointStatements _statements;
			};
		};
	};
} foreach [_preCondition,_postCondition];

if (_retriggered || {!(call _owMainCurrent)}) exitWith {
	isNil {[_owRun,"precondition boundary"] call _owReleaseRun;}; true
};

///////////////  _fncs for CAS

// Discover executable modes separately from their AI range/burst preferences.
// A physical burst cannot be cancelled reliably by clearing doTarget/FIREWEAPON.
// The controller therefore uses a one-round mode (often the player/manual mode)
// from this list, rather than forcing an AI burst and assuming one command = one shot.
// "this" is the actual muzzle classname when passed to forceWeaponFire.
private _fireModes = {
	params ["_weapon","_muzzleName","_cache"];
	private _key = format ["fireModes:%1:%2",toLower _weapon,toLower _muzzleName];
	if (_key in _cache) exitWith {_cache get _key};
	private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
	private _cfg = if (_muzzleName == "this") then {_weaponCfg} else {_weaponCfg >> _muzzleName};
	private _muzzle = if (_muzzleName == "this") then {_weapon} else {_muzzleName};
	private _modes = getArray (_cfg >> "modes");
	if (_modes isEqualTo []) then {_modes = ["this"];};
	private _single = [];
	private _automatic = [];
	{
		private _modeCfg = if (_x == "this") then {_cfg} else {_cfg >> _x};
		private _burst = if (isNumber (_modeCfg >> "burst")) then {getNumber (_modeCfg >> "burst")} else {1};
		private _multiplier = if (isNumber (_modeCfg >> "multiplier")) then {getNumber (_modeCfg >> "multiplier")} else {1};
		private _range = getNumber (_modeCfg >> "maxRange");
		if (isClass _modeCfg && {_burst >= 1} && {_multiplier >= 1}) then {
			private _mode = if (_x == "this") then {_muzzle} else {_x};
			private _entry = [_mode,(getNumber (_modeCfg >> "reloadTime")) max 0.05,
				getNumber (_modeCfg >> "minRange"),_range,
				_burst max getNumber (_modeCfg >> "burstRangeMax"),_multiplier];
			if (getNumber (_modeCfg >> "autoFire") == 0) then {_single pushBack _entry;}
			else {_automatic pushBack _entry;};
		};
	} forEach _modes;
	private _result = _single + _automatic;
	_cache set [_key,_result];
	_result
};

// Classifier-approved primary-gunner missiles only. AA threat labels are never
// used to infer friendly compatibility. Live stock includes actual turret/pylon
// magazines; guidance configuration replaces the old lock-bit-only inference.
_fnc_vehicleWeaponAmmo = {
	params ["_vehicle","_cache","_capabilities","_fireModes"];
	private _turret = _capabilities getOrDefault ["primaryGunnerTurret",[]];
	if (_turret isEqualTo []) exitWith {[]};
	private _operator = _vehicle turretUnit _turret;
	private _lease = _operator getVariable ["A3C_OW_FeatureSession",createHashMap];
	private _session = _vehicle getVariable ["A3C_OW_Session",createHashMap];
	if (isNull _operator || {!alive _operator} || {isPlayer _operator}
		|| {lifeState _operator == "INCAPACITATED"} || {!local _operator} || {!local _vehicle}
		|| {!(_vehicle turretLocal _turret)}
		|| {!((_vehicle unitTurret _operator) isEqualTo _turret)}
		|| {(_lease getOrDefault ["vehicle",objNull]) != _vehicle}
		|| {!((_lease getOrDefault ["id",[]]) isEqualTo (_session getOrDefault ["id",[]]))}) exitWith {[]};
	private _return = [];
	private _stock = magazinesAllTurrets [_vehicle,true];
	private _installed = (_vehicle weaponsTurret _turret) apply {toLower _x};
	{
		private _evidence = _x;
		private _weapon = _evidence get "weapon";
		private _mag = _evidence get "magazine";
		private _muzzleName = _evidence get "muzzle";
		private _muzzle = if (_muzzleName == "this") then {_weapon} else {_muzzleName};
		if (_evidence get "qualifies" && {toLower _weapon in _installed}) then {
			private _rounds = 0;
			{
				if ((_x select 1) isEqualTo _turret && {toLower (_x select 0) == toLower _mag}) then {
					_rounds = _rounds + ((_x select 2) max 0);
				};
			} forEach _stock;
			private _info = [_weapon,_muzzleName,_mag,_cache] call A3C_main_fnc_getHeliOverwatchAmmoInfo;
			if (_rounds > 0 && {_info get "damaging"} && {(_info get "simulation") == "shotmissile"}) then {
				private _types = if (_info get "airAmmo") then {["AIR"]} else {["CAR","TANK","SHIP"]};
				{
					_x params ["_mode","_reload","_minRange","_range"];
					private _spec = [_weapon,_muzzle,_mag,+_turret,_operator,_mode,_reload,_minRange,_range];
					_return pushBackUnique [_weapon,_types,_rounds,_range,_minRange,_spec];
				} forEach (([_weapon,_muzzleName,_cache] call _fireModes) select {
					(_x select 4) == 1 && {(_x select 5) == 1} && {(_x select 3) > 0}
				});
			};
		};
	} forEach (_capabilities getOrDefault ["guidedMagazines",[]]);
	_return
};


private _aimTarget = {
	params ["_gunner","_vehicle","_activeTarget","_session","_turret"];
	isNil {
		private _run = _session get "run";
		if !([_run,_session] call (_run get "valid")) exitWith {};
		if (!alive _gunner || {isPlayer _gunner} || {!local _gunner}
			|| {_vehicle turretUnit _turret != _gunner} || {!(_vehicle turretLocal _turret)}) exitWith {};
		_session set ["targetOrders",[[_gunner,_activeTarget],[_vehicle,_activeTarget]]];
		_gunner forgetTarget (assignedtarget _gunner);
		_gunner doTarget objNull;
		_gunner reveal [_activeTarget,4];
		_gunner lookAt _activeTarget;
		{_x doWatch _activeTarget; _x lookat _activeTarget; _x doTarget _activeTarget} foreach [_gunner,_vehicle];
	};
};

//------------DO NOT DELETE THIS
/*
_fnc_tilt = {

	//-- if you use this after all, give credit to Rydigier

	params ["_mode","_vehicle","_aslPos","_initVectorDir","_newVectorDir","_initVectorUp","_newVectorUp"];
	//-- _newVectorUp > 0: tilt into position
	//-- _newVectorUp == []: keep vehicle tilted 

	compile format
	[
		"
			
			private _veh = %1;
			private _aslPos = %2;
			private _initVectorDir = %3;
			private _newVectorDir = %4;
			private _vectorUpStart = %5;
			private _newVectorUp = %6;

			private _startTime = %7;
			private _timeWhenFinished = _startTime  + 1;

			private _mode = %8;

			private _conv = if (_mode == 1) then {0} else {(linearConversion [_startTime, _timeWhenFinished, time, 0, 1])};
			_veh setVelocityTransformation 
			[
				_aslPos, 
				_aslPos, 
				[0,0,0], 
				[0,0,0], 
				_initVectorDir, 
				_newVectorDir, 
				_vectorUpStart, 
				_newVectorUp,
				_conv
			]
		",
		_vehicle,
		_aslPos,
		_initVectorDir,
		_newVectorDir,
		_initVectorUp,
		_newVectorUp,
		time,
		_mode
	]
};
*/


isNil {
	if !(call _owMainCurrent) exitWith {};
	{
	private _session = _x;
	private _pilot = _session get "pilot";
	private _worker = [_pilot,_group,_leaderVic,+_pos,_direction,_overwatch_height,_fnc_vehicleWeaponAmmo,_aimTarget,_exitCondition,_t,_session,_fireModes] spawn {
		params ["_pilot","_group","_leaderVic","_waypointPos","_direction","_overwatch_height","_fnc_vehicleWeaponAmmo","_aimTarget","_exitCondition","_t","_session","_fireModes"];
		private _run = _session get "run";
		private _current = {[_run,_session] call (_run get "valid")};
		private _release = {
			params ["_reason"];
			isNil {[_session,_reason,_thisScript] call (_run get "releaseSession");};
		};
		private _rotate = {
			params ["_position"];
			private _handle = scriptNull;
			isNil {
				if !(call _current) exitWith {};
				_session set ["rotationSpeedOwned",!(_vehicle getVariable ["A3C_LIMIT_SPEED",false])];
				_handle = [_vehicle,_position] spawn A3C_ai_shared_fnc_rotateVehicleTowardsPos;
				_session set ["rotation",_handle];
			};
			_handle
		};
		
		
				
		_waypointPos set [2,0];
		private _vehicle = vehicle _pilot;
		private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "precision")) * 1.3;
		private _doExit = false;
		private _exitFnc = {
			params ["_vehicle","_pilot","_waypointPos"];
			
			private _exit = 
			(
				{!alive _x} count [_vehicle,_pilot] > 0 OR 
				{
					//_isWaypointCancelled
					(_waypointPos distance2D (waypointPosition [group _pilot, currentWaypoint group _pilot])) > 1
				}
			);
			_exit
		};

		while {call _current} do {
			_doExit = [_vehicle,_pilot,_waypointPos] call _exitFnc;
			_pilot setBehaviourStrong "CARELESS";
			if (_vehicle distance2D (formationposition _vehicle) < (_precision * 1.3) ) exitWith {}; //
			if (_doExit) exitWith {};
			sleep 0.05;
		};
		if (_doExit || {!canMove _vehicle} || {!(call _current)}) exitWith {
			"formation/approach cancelled" call _release;
		};

		// Register the rotation before it can run; cleanup owns its speed limit.
		private _targetPos = _vehicle getPos [1000,_direction];
		private _rotation = scriptNull;
		isNil {
			if !(call _current) exitWith {};
			[_session,"ROTATING"] call (_run get "phaseCode");
			_rotation = [_targetPos] call _rotate;
			_session set ["freezeOwned",true];
			_vehicle setVariable ["A3C_Freeze_helicopter",[true,_direction],true];
		};
		waitUntil {
			sleep 0.05;
			_doExit = _doExit || {[_vehicle,_pilot,_waypointPos] call _exitFnc}
				|| {!canMove _vehicle} || {[] call _exitCondition}
				|| {!((_vehicle getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)};
			!(call _current) || {_doExit} || {scriptDone _rotation}
		};
		if (_doExit || {!(call _current)}) exitWith {"rotation cancelled" call _release;};
		private _heliHeight = (getPosVisual _vehicle) select 2;
		private _adjustZvelocity = if (_heliHeight < _overwatch_height) then {7} else {-7};
		isNil {
			if !(call _current) exitWith {};
			[_session,"ALTITUDE"] call (_run get "phaseCode");
			_vehicle enableAIFeature ["PATH",false];
		};
		private _altitudeDeadline = time + 90;
		while {call _current && {time < _altitudeDeadline}
			&& {abs ((getPosATL _vehicle select 2) - _overwatch_height) > 20}
			&& {(_vehicle getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0}} do {
			isNil {if (call _current) then {_vehicle setVelocity [0,0,_adjustZvelocity];};};
			sleep 0.05;
		};
		if (!(call _current) || {abs ((getPosATL _vehicle select 2) - _overwatch_height) > 20}
			|| {!((_vehicle getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)}) exitWith {
			"altitude interrupted / deadline" call _release;
		};
		private _weapons = weapons _vehicle;
		private _gunner = gunner _vehicle;
		if (isPlayer _gunner) exitWith {"player gunner" call _release;};
		isNil {
			if !(call _current) exitWith {};
			_vehicle flyInHeight _overwatch_height;
			[_session,"ACTIVE"] call (_run get "phaseCode");
			_session set ["fireOwned", true];
			_vehicle enableAIFeature ["FIREWEAPON", false];

			if (_vehicle getVariable ["A3C_OW_LifecycleDebug", false]) then {
				diag_log format [
					"A3C OW %1 FIREWEAPON acquisition (ACTIVE), original=%2",
					_session get "id",
					_session get "fireBefore"
				];
			};
		};
		/////////////////////////////////////////////   BEGIN CAS-behaviour

		private _weapon = "";
		private _weaponAmmo = [];
		private _capabilities = createHashMap;
		private _capabilitySignature = [];
		private _rankingCache = createHashMap;
		private _retention = createHashMap;
		private _usableGuns = [];
		private _selectedTarget = createHashMap;
		private _nextEvaluation = 0;
		private _blockedUntil = createHashMap; // Failed weapon combinations get a five-second retry delay.
		private _engagementRejections = []; // [target, until, cause]; target failures only, never missile reservations.
		private _lastEngagementRejection = createHashMap; // Bounded diagnostic state; suppress unchanged retries.
		// Read live stock for classifier-approved gun/muzzle/magazine combinations.
		// Entries: [weapon, muzzle, magazine, range, fireSpec]; loaded stock comes first.
		private _getAvailableGuns = {
			params ["_vehicle","_capabilities"];
			if !(_capabilities getOrDefault ["hasTraversableGun",false]) exitWith {[]};
			private _turret = _capabilities get "primaryGunnerTurret";
			private _operator = _vehicle turretUnit _turret;
			private _lease = _operator getVariable ["A3C_OW_FeatureSession",createHashMap];
			if (isNull _operator || {!alive _operator} || {isPlayer _operator}
				|| {lifeState _operator == "INCAPACITATED"} || {!local _operator} || {!local _vehicle}
				|| {!(_vehicle turretLocal _turret)}
				|| {!((_vehicle unitTurret _operator) isEqualTo _turret)}
				|| {(_lease getOrDefault ["vehicle",objNull]) != _vehicle}
				|| {!((_lease getOrDefault ["id",[]]) isEqualTo (_session get "id"))}) exitWith {[]};
			private _installed = (_vehicle weaponsTurret _turret) apply {toLower _x};
			private _qualified = (_capabilities get "gunWeapons") apply {toLower _x};
			private _stock = magazinesAllTurrets [_vehicle,true];
			private _loaded = [];
			private _reserve = [];
			{
				private _gun = _x get "weapon";
				if (toLower _gun in _qualified && {toLower _gun in _installed}) then {
					{
						private _ammo = _x;
						private _magazine = _ammo get "magazine";
						if (_ammo getOrDefault ["gunAmmoQualifies",false] && {
							_stock findIf {(_x select 1) isEqualTo _turret && {(_x select 2) > 0}
								&& {toLower (_x select 0) == toLower _magazine}} >= 0
						}) then {
							private _muzzleName = _ammo get "muzzle";
							private _muzzle = if (_muzzleName == "this") then {_gun} else {_muzzleName};
							// Direct gun projectiles only; guided launcher ammunition never
							// enters the cannon request path, even on a mixed modded weapon.
							if ((_ammo get "simulation") in ["shotbullet","shotshell"]) then {
								private _modes = [_gun,_muzzleName,_rankingCache] call _fireModes;
								private _controlled = _modes select {(_x select 4) == 1 && {(_x select 5) == 1}};
								private _info = [_gun,_muzzleName,_magazine,_rankingCache] call A3C_main_fnc_getHeliOverwatchAmmoInfo;
								// Use the muzzle's full range evidence, not the chosen mode's
								// short AI selection range. Lifetime/speed is an upper bound,
								// not a promise of ballistic accuracy or armor penetration.
								private _magCfg = configFile >> "CfgMagazines" >> _magazine;
								private _ammoCfg = configFile >> "CfgAmmo" >> (_ammo get "ammo");
								private _gunCfg = configFile >> "CfgWeapons" >> _gun;
								private _muzzleCfg = if (_muzzleName == "this") then {_gunCfg} else {_gunCfg >> _muzzleName};
								private _velocity = getNumber (_magCfg >> "initSpeed");
								private _override = getNumber (_muzzleCfg >> "initSpeed");
								if (_override > 0) then {_velocity = _override;};
								if (_override < 0) then {_velocity = _velocity * abs _override;};
								private _lifeRange = _velocity * getNumber (_ammoCfg >> "timeToLive");
								private _gunRange = _info get "range";
								if (_gunRange <= 0) then {_gunRange = _lifeRange;};
								_gunRange = _gunRange min 3000;
								if (_lifeRange > 0) then {_gunRange = _gunRange min _lifeRange;};
								private _modeReason = if (_controlled isEqualTo []) then {
									"No bounded one-round mode; physical/random bursts or ammo multipliers require engine-specific validation."
								} else {if (_gunRange <= 0) then {"No positive weapon/ammunition range evidence."} else {"Bounded firing mode and muzzle/ammunition range resolved."}};
								_rankingCache set [format ["gunModes:%1:%2",_gun,_muzzle],[_modes,_controlled,_gunRange,_modeReason]];
								{
									_x params ["_mode","_reload"];
									private _minRange = _info get "minRange";
									private _range = _gunRange;
									private _spec = [_gun,_muzzle,_magazine,+_turret,_operator,_mode,_reload,_minRange,_range];
									private _entry = [_gun,_muzzle,_magazine,_range,_spec];
									private _state = weaponState [_vehicle,_turret,_gun,_muzzle];
									if (toLower (_state param [3,""]) == toLower _magazine && {(_state param [4,0]) > 0}) then {
										_loaded pushBackUnique _entry;
									} else {
										_reserve pushBackUnique _entry;
									};
								} forEach (_controlled select {_gunRange > 0});
							};
						};
					} forEach (_x get "ammunition");
				};
			} forEach (_capabilities get "candidates");
			_loaded + _reserve
		};
		
		// Session-private safety bookkeeping shared with the unscheduled Fired receiver.
		_session set ["quarantineMissile",{
			params ["_session","_projectile","_request","_unobservable","_reason"];
			private _quarantine = _session get "missileFlight";
			if (count _quarantine == 0) then {
				_quarantine = createHashMapFromArray [["projectiles",[]],["unresolved",[]],
					["unobservable",false],["assessmentUntil",-1],["flightDeadline",time + 120]];
				_session set ["missileFlight",_quarantine];
			};
			if (!isNull _projectile) then {(_quarantine get "projectiles") pushBackUnique _projectile;};
			if (_unobservable) then {_quarantine set ["unobservable",true];};
			if (count _request > 0) then {
				_request set ["unknown",true];
				_request set ["unaccountedShots",_request getOrDefault ["unaccountedShots",1]];
				if ((_request get "shots") == 0) then {
					_request set ["state","UNRESOLVED"];
					_session set ["missileFlights",(_session get "missileFlights") select {(_x get "id") != (_request get "id")}];
				} else {_request set ["safetyHold",true];};
				if ((_quarantine get "unresolved") findIf {(_x get "id") == (_request get "id")} < 0) then {
					(_quarantine get "unresolved") pushBack _request;
				};
			};
			_quarantine set ["assessmentUntil",-1];
			_quarantine set ["reason",_reason];
			private _vehicle = _session get "vehicle";
			if (_vehicle getVariable ["A3C_OW_Debug",false]) then {
				diag_log format ["A3C OW UNKNOWN LAUNCH QUARANTINED: projectile=%1 engagement=%2 reason=%3",
					_projectile,_request getOrDefault ["id",-1],_reason];
			};
		}];
		private _assessMissileTarget = {
			params ["_target"];
			if (isNull _target || {!alive _target} || {{alive _x} count crew _target == 0}) exitWith {
				["NEUTRALIZED","Target destroyed/deleted or no surviving crew."]
			};
			if (_target isKindOf "Air") exitWith {
				if (canMove _target) then {["OPERATIONAL","Aircraft alive, mobile and crewed."]}
				else {["NEUTRALIZED","Aircraft canMove=false."]}
			};
			if (_target isKindOf "StaticWeapon") exitWith {
				if (canFire _target) then {["OPERATIONAL","Static weapon crewed and canFire=true."]}
				else {["INDETERMINATE","Crewed static weapon: canFire=false alone is not reliable neutralization evidence."]}
			};
			if (canMove _target || {canFire _target}) exitWith {["OPERATIONAL","Ground target can move or fire."]};
			private _armed = (magazinesAllTurrets [_target,true]) findIf {
				private _ammoCfg = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> (_x select 0) >> "ammo");
				getNumber (_ammoCfg >> "hit") > 0
					|| {getNumber (_ammoCfg >> "indirectHit") > 0 && {getNumber (_ammoCfg >> "indirectHitRange") > 0}}
			} >= 0;
			if (_armed) then {["NEUTRALIZED","Armed ground target can neither move nor fire."]}
			else {["INDETERMINATE","No reliable armed-vehicle evidence; preserve existing target eligibility."]}
		};
		private _maintainMissileFlights = {
			// Invoked by the existing worker only; Fired mutations cannot interleave with pruning/assessment.
			isNil {
				if !(call _current) exitWith {};
				private _debug = _vehicle getVariable ["A3C_OW_Debug",false];
				{
					private _flight = _x;
					private _projectiles = _flight get "projectiles";
					if ((_flight get "state") == "FLIGHT" && {!(_flight getOrDefault ["unknown",false])}
						&& {_projectiles findIf {!isNull _x && {alive _x}} < 0}) then {
						_flight set ["state","ASSESSING"];
						_flight set ["terminated",true];
						_flight set ["assessmentUntil",time + 0.5];
						_flight set ["reason",if (count (_session get "missileFlight") > 0) then {
							"Observed projectiles terminated; reservation/laser retained while global launch uncertainty remains."
						} else {"All associated projectiles terminated; awaiting 0.5 s damage assessment."}];
						private _id = _flight get "id";
						if (((_vehicle getVariable ["A3C_Guided_Projectile",[-1]]) param [0,-1]) == _id) then {
							_vehicle setVariable ["A3C_Guided_Projectile",nil,true];
						};
						if (((_vehicle getVariable ["A3C_fireComplete",["",false,-1]]) param [2,-1]) == _id) then {
							_vehicle setVariable ["A3C_fireComplete",nil,true];
						};
						if (_debug) then {diag_log format ["A3C OW MISSILE TERMINATED; ASSESSMENT STARTED: id=%1 target=%2 until=%3",_id,_flight get "target",_flight get "assessmentUntil"];};
					};
					if ((_flight get "state") == "FLIGHT") then {
						if (time >= (_flight get "handoffDeadline") && {!(_flight getOrDefault ["handoffReported",false])}
							&& {!(_flight get "handoff") || {_projectiles findIf {
								!local _x || {!(_x getVariable ["A3C_Guidance_Started",false]) && {(_x getVariable ["A3C_OW_MissileGuidanceOwner",""]) != "NATIVE"}}
							} >= 0}}) then {
							_flight set ["handoffReported",true];
							_flight set ["safetyHold",true];
							_flight set ["reason","Guidance handoff/start unconfirmed; all missile launches withheld until this flight completes."];
							if (_debug) then {diag_log format ["A3C OW UNKNOWN LAUNCH QUARANTINED: id=%1 reason=%2",_flight get "id",_flight get "reason"];};
						};
						if (time >= (_flight get "flightDeadline") && {!(_flight getOrDefault ["timeoutReported",false])}) then {
							_flight set ["timeoutReported",true];
							_flight set ["safetyHold",true];
							_flight set ["reason","Flight diagnostic deadline exceeded; no timeout release while a projectile remains alive."];
							if (_debug) then {diag_log format ["A3C OW UNKNOWN LAUNCH QUARANTINED: id=%1 reason=%2",_flight get "id",_flight get "reason"];};
						};
					};
					if ((_flight get "state") == "ASSESSING" && {time >= (_flight get "assessmentUntil")}
						&& {!(_flight getOrDefault ["acceptShots",false])} && {count (_session get "missileFlight") == 0}) then {
						private _result = [_flight get "target"] call _assessMissileTarget;
						private _laser = _flight getOrDefault ["laser",objNull];
						if (!isNull _laser) then {deleteVehicle _laser;};
						_flight set ["state","COMPLETE"];
						_session set ["lastMissileAssessment",[time,_flight get "id",_flight get "target",_result]];
						_nextEvaluation = 0;
						if (_debug) then {diag_log format ["A3C OW ASSESSMENT COMPLETE; %1: id=%2 target=%3 result=%4 reason=%5",
							if ((_result select 0) == "NEUTRALIZED") then {"TARGET NEUTRALIZED"} else {"TARGET RELEASED"},
							_flight get "id",_flight get "target",_result select 0,_result select 1];};
					};
				} forEach (_session get "missileFlights");
				_session set ["missileFlights",(_session get "missileFlights") select {(_x get "state") != "COMPLETE"}];
				private _quarantine = _session get "missileFlight";
				if (count _quarantine > 0) then {
					if (!(_quarantine get "unobservable") && {(_quarantine get "unresolved") isEqualTo []}
						&& {(_quarantine get "projectiles") findIf {!isNull _x && {alive _x}} < 0}) then {
						if ((_quarantine get "assessmentUntil") < 0) then {_quarantine set ["assessmentUntil",time + 0.5];};
						if (time >= (_quarantine get "assessmentUntil")) then {
							_session set ["missileFlight",createHashMap];
							_nextEvaluation = 0;
							if (_debug) then {diag_log "A3C OW UNKNOWN LAUNCH QUARANTINE RELEASED: observed projectiles terminated and assessment elapsed.";};
						};
					} else {
						if (time >= (_quarantine get "flightDeadline") && {!(_quarantine getOrDefault ["timeoutReported",false])}) then {
							_quarantine set ["timeoutReported",true];
							if (_debug) then {diag_log "A3C OW UNKNOWN LAUNCH QUARANTINED: diagnostic timeout; unresolved launches remain fail-closed.";};
						};
					};
				};
			};
		};

		// Run on engagement boundaries and at most once per two seconds in a gun
		// window. Selection keeps the original waypoint direction.
		private _evaluateTargets = {
			if !(call _current) exitWith {};
			call _maintainMissileFlights;
			private _primary = _capabilities getOrDefault ["primaryGunnerTurret",[]];
			private _paths = allTurrets [_vehicle,true];
			private _signature = [
				_paths apply {[_x,_vehicle weaponsTurret _x]},
				magazinesAllTurrets [_vehicle,true] apply {[_x select 0,_x select 1]},
				getAllPylonsInfo _vehicle apply {[_x select 2,_x select 3]},
				if (_primary isEqualTo []) then {[]} else {_vehicle getTurretLimits _primary}
			];
			if !(_signature isEqualTo _capabilitySignature) then {
				_capabilities = [_vehicle] call A3C_main_fnc_getHeliOverwatchCapabilities;
				_capabilitySignature = _signature;
			};
			_gunner = gunner _vehicle;
			_weaponAmmo = [_vehicle,_rankingCache,_capabilities,_fireModes] call _fnc_vehicleWeaponAmmo;
			_usableGuns = [_vehicle,_capabilities] call _getAvailableGuns;
			private _available = {
				private _spec = _x select (count _x - 1);
				time >= (_blockedUntil getOrDefault [str (_spec select [0,6]),0])
			};
			private _flights = _session get "missileFlights";
			private _quarantined = count (_session get "missileFlight") > 0 || {_flights findIf {_x getOrDefault ["safetyHold",false]} >= 0};
			private _missilesReady = if (_quarantined) then {[]} else {_weaponAmmo select _available};
			private _reservedTargets = _flights apply {_x get "target"};
			_engagementRejections = _engagementRejections select {!isNull (_x select 0) && {time < (_x select 1)}};
			private _result = [_vehicle,_direction,_missilesReady,_usableGuns select _available,_retention,_rankingCache,_reservedTargets,_engagementRejections]
				call A3C_main_fnc_selectHeliOverwatchTarget;
			(_result select 1) set ["armament",[_weaponAmmo,_usableGuns,_missilesReady,
				((keys _rankingCache) select {(_x find "gunModes:") == 0}) apply {[_x,_rankingCache get _x]}]];
			(_result select 1) set ["missileStatus",(_session get "missileFlight") getOrDefault ["reason",""]];
			(_result select 1) set ["stock",magazinesAllTurrets [_vehicle,true]];
			(_result select 1) set ["capabilityReasons",_capabilities getOrDefault ["reasons",[]]];
			_selectedTarget = _result select 0;
			_nextEvaluation = time + 2;
			isNil {
				if !(call _current) exitWith {};
				if (_vehicle getVariable ["A3C_OW_Debug",false]) then {
					(_result select 1) set ["engagementRejections",_engagementRejections apply {+_x}];
					(_result select 1) set ["lastEngagementRejection",_lastEngagementRejection];
					(_result select 1) set ["missileFireControl",createHashMapFromArray [
						["quarantined",_quarantined],["reservedTargets",_reservedTargets],
						["flights",_flights apply {createHashMapFromArray [
							["id",_x get "id"],["target",_x get "target"],["state",_x get "state"],
							["started",_x get "started"],["flightStart",_x get "flightStart"],
							["projectiles",+(_x get "projectiles")],["alive",(_x get "projectiles") apply {!isNull _x && {alive _x}}],
							["terminated",_x get "terminated"],["assessmentUntil",_x get "assessmentUntil"],
							["safetyHold",_x get "safetyHold"],["handoff",_x get "handoff"],["reason",_x get "reason"]
						]}],
						["unknownProjectiles",+((_session get "missileFlight") getOrDefault ["projectiles",[]])],
						["unknownAlive",((_session get "missileFlight") getOrDefault ["projectiles",[]]) apply {!isNull _x && {alive _x}}],
						["quarantineAssessmentUntil",(_session get "missileFlight") getOrDefault ["assessmentUntil",-1]],
						["quarantineReason",(_session get "missileFlight") getOrDefault ["reason",""]],
						["unresolved",((_session get "missileFlight") getOrDefault ["unresolved",[]]) apply {[_x get "id",_x get "target",_x get "unaccountedShots"]}],
						["unobservable",(_session get "missileFlight") getOrDefault ["unobservable",false]],
						["lastAssessment",_session getOrDefault ["lastMissileAssessment",[]]]
					]];
					_vehicle setVariable ["A3C_OW_Ranking",_result select 1];
				} else {
					_vehicle setVariable ["A3C_OW_Ranking",nil];
				};
			};
		};

		isNil {
			if !(call _current) exitWith {};
			_vehicle setVariable ["A3C_Guided_Projectile",nil,true];
			private _handle = _vehicle addEventHandler ["Fired",{
				params ["_vehicle","_weapon","_muzzle","_mode","_ammo","_magazine","_projectile","_gunner"];
				private _debug = _vehicle getVariable ["A3C_OW_Debug",false];
				if (_debug) then {
					diag_log format ["A3C OW projectile fired: weapon/muzzle/mode/ammo/operator/projectile = %1",
						[_weapon,_muzzle,_mode,_ammo,_gunner,_projectile]];
				};
				private _session = _vehicle getVariable ["A3C_OW_Session",createHashMap];
				if (count _session == 0 || {(_session get "firedEH") != _thisEventHandler}) exitWith {};
				private _run = _session get "run";
				if !([_run,_session] call (_run get "valid")) exitWith {};
				private _request = _session get "fireRequest";
				private _simulation = toLower getText (configFile >> "CfgAmmo" >> _ammo >> "simulation");
				private _quarantine = _session get "missileFlight";
				private _claim = if (isNull _projectile) then {[]} else {_projectile getVariable ["A3C_OW_MissileLaunch",[]]};
				if (_simulation == "shotmissile" && {_claim isNotEqualTo []}
					&& {!((_claim select 0) isEqualTo (_session get "id"))}) exitWith {
					[_session,_projectile,createHashMap,false,"Projectile belongs to a previous Overwatch session; no new ownership assigned."]
						call (_session get "quarantineMissile");
				};
				// A repeated event for an already captured object cannot be a new request's shot.
				if (_simulation == "shotmissile" && {!isNull _projectile} && {
					(_session get "missileFlights") findIf {_projectile in (_x get "projectiles")} >= 0
					|| {_projectile in (_quarantine getOrDefault ["projectiles",[]])}
				}) exitWith {};
				if (_simulation == "shotmissile" && {_claim isNotEqualTo []}) exitWith {
					[_session,_projectile,createHashMap,false,"Previously claimed projectile has no active record; never reassigned to the current request."]
						call (_session get "quarantineMissile");
				};
				private _event = ([_weapon,_muzzle,_magazine,_mode] apply {toLower _x}) + [_gunner];
				private _unresolved = _quarantine getOrDefault ["unresolved",[]];
				private _lateCandidates = if (_simulation == "shotmissile") then {
					_unresolved select {(_x get "expectedEvent") isEqualTo _event}
				} else {[]};
				private _lateMatch = count _lateCandidates == 1;
				private _ambiguous = count _lateCandidates > 1 || {_lateMatch && {(_request getOrDefault ["kind",""]) == "MISSILE"}
					&& {_request getOrDefault ["acceptShots",false]}
					&& {(_request get "id") != ((_lateCandidates select 0) get "id")}};
				// Recover the exact captured request, even if a gun now owns fireRequest.
				if (_lateMatch && {!_ambiguous}) then {_request = _lateCandidates select 0;};
				private _matches = false;
				private _kind = _request getOrDefault ["kind",""];
				if (!_ambiguous && {(_lateMatch || {_request getOrDefault ["acceptShots",false]})}
					&& {(_request getOrDefault ["sessionId",[]]) isEqualTo (_session get "id")}) then {
					(_request get "spec") params ["_wantWeapon","_wantMuzzle","_wantMag","_turret","_operator","_wantMode"];
					_matches = toLower _weapon == toLower _wantWeapon && {toLower _muzzle == toLower _wantMuzzle}
						&& {toLower _magazine == toLower _wantMag} && {toLower _mode == toLower _wantMode}
						&& {_gunner == _operator} && {local _operator} && {!isPlayer _operator}
						&& {_vehicle turretUnit _turret == _operator} && {_vehicle turretLocal _turret}
						&& {(_vehicle unitTurret _operator) isEqualTo _turret}
						&& {(_kind == "MISSILE" && {_simulation == "shotmissile"})
							|| {_kind == "GUN" && {_simulation in ["shotbullet","shotshell"]}}};
				};
				// Unmatched missiles never borrow the selected target or mutate a confirmed record.
				if (_simulation == "shotmissile" && {!_matches}) then {
					[_session,_projectile,createHashMap,isNull _projectile,
						"Unexpected/ambiguous missile Fired event; globally withheld until observed completion."] call (_session get "quarantineMissile");
				};
				if (!_matches) exitWith {
					if (_request getOrDefault ["acceptShots",false]) then {
						_request set ["reason",format ["Fired mismatch: actual=%1 expected=%2",
							[_weapon,_muzzle,_magazine,_mode,_gunner],_request get "spec"]];
						if (_vehicle getVariable ["A3C_OW_Debug",false]) then {diag_log (_request get "reason");};
					};
				};
				if (_kind == "MISSILE" && {isNull _projectile}) exitWith {
					[_session,objNull,_request,false,"Matching Fired event supplied no observable projectile; trustworthy late recovery required."]
						call (_session get "quarantineMissile");
				};
				// Count EVERY matching Fired event during the request, including
				// any extra events after the first acknowledged discharge.
				_request set ["pending",false];
				_request set ["shots",(_request get "shots") + 1];
				_request set ["lastShot",time];
				private _engagement = _request get "id";
				private _shotTarget = _request get "target"; // Snapshot before any scheduled work or preemption.
				private _round = _request get "shots";
				if (_lateMatch) then {
					private _missing = ((_request getOrDefault ["unaccountedShots",1]) - 1) max 0;
					_request set ["unaccountedShots",_missing];
					_request set ["unknown",_missing > 0];
					if (_missing == 0) then {
						_quarantine set ["unresolved",_unresolved select {(_x get "id") != _engagement}];
						if ((_quarantine get "unresolved") isEqualTo [] && {(_quarantine get "projectiles") isEqualTo []}
							&& {!(_quarantine get "unobservable")}) then {_session set ["missileFlight",createHashMap];};
					};
				};
				if (_debug) then {
					diag_log format ["A3C OW projectile matched: engagement=%1 kind=%2 round=%3 target=%4 projectile=%5",
						_engagement,_kind,_round,_shotTarget,_projectile];
				};
				if (_kind == "GUN") exitWith {
					// The suppression helper accepts [_eh,_target,_operator,_weapon,_token],
					// but aims at getPosASL, deletes the real shot, sleeps, and creates a
					// replacement without shot parents. Use its velocity-to-target idea
					// on the ORIGINAL projectile: no launch delay, ammo/attribution changes,
					// replacement Fired events, or dependency on mechanical turret alignment.
					private _step = {
						params ["_projectile","_target","_first","_deadline"];
						private _result = [false,false,"projectile gone/dead or locality lost"];
						isNil {
							if (isNull _projectile || {!alive _projectile} || {!local _projectile}) exitWith {};
							_result set [2,"target gone/dead or guidance deadline reached"];
							if (isNull _target || {!alive _target} || {time >= _deadline}) exitWith {};
							private _aimASL = aimPos _target;
							_result set [2,"invalid aimPos"];
							if (!(_aimASL isEqualTypeArray [0,0,0]) || {{finite _x} count _aimASL != 3}
								|| {_aimASL isEqualTo [0,0,0]}) exitWith {};
							private _offset = _aimASL vectorDiff getPosASL _projectile;
							private _distance = vectorMagnitude _offset;
							private _velocity = velocity _projectile;
							private _speed = vectorMagnitude _velocity;
							_result set [2,"zero/invalid projectile speed or aim distance"];
							if (!finite _speed || {!finite _distance} || {_speed <= 0.001} || {_distance <= 0.001}) exitWith {};
							// Release before impact/passage so penetration or a ricochet cannot
							// cause a shot to be steered back into its target. Always correct
							// the first shot, even inside this short terminal handoff window.
							private _handoff = ((diag_deltaTime * 2) max 0.01) min 0.035;
							_result set [2,"terminal handoff or target passed"];
							if (!_first && {(_offset vectorDotProduct _velocity) <= 0 || {_distance / _speed <= _handoff}}) exitWith {};
							private _direction = _offset vectorMultiply (1 / _distance);
							private _up = vectorUp _projectile;
							_up = _up vectorDiff (_direction vectorMultiply (_up vectorDotProduct _direction));
							if (vectorMagnitude _up < 0.001) then {
								private _reference = if (abs (_direction select 2) < 0.9) then {[0,0,1]} else {[1,0,0]};
								_up = _reference vectorDiff (_direction vectorMultiply (_reference vectorDotProduct _direction));
							};
							_projectile setVectorDirAndUp [_direction,vectorNormalized _up];
							// Preserve the engine's current speed, including drag/impact losses;
							// never invent muzzle velocity or reset kinetic energy each step.
							_projectile setVelocity (_direction vectorMultiply _speed);
							_result = [_distance / _speed > _handoff,true,"terminal handoff"];
						};
						_result
					};
					private _deadline = time + ((getNumber (configFile >> "CfgAmmo" >> _ammo >> "timeToLive") max 0.1) min 30);
					private _result = [false,false,"Fired event supplied no live projectile"];
					if (!isNull _projectile && {_projectile getVariable ["A3C_OW_GunGuidanceClaimed",false]}) then {
						_result set [2,"duplicate cannon guidance ownership"];
					};
					if (!isNull _projectile && {!(_projectile getVariable ["A3C_OW_GunGuidanceClaimed",false])}) then {
						if (local _projectile) then {_projectile setVariable ["A3C_OW_GunGuidanceClaimed",true];};
						// Unscheduled Fired call: first trajectory writes precede spawn.
						_result = [_projectile,_shotTarget,true,_deadline] call _step;
					};
					if (_debug) then {
						diag_log format ["A3C OW cannon guidance %1: engagement=%2 round=%3 target=%4 projectile=%5 reason=%6",
							if (_result select 1) then {"started (trajectory corrected)"} else {"could not start"},
							_engagement,_round,_shotTarget,_projectile,if (_result select 1) then {""} else {_result select 2}];
					};
					if !(_result select 0) exitWith {};
					// Only shot/target/scalars/code survive. No run/session/request references
					// and no permanent handler; preemption/cancellation cannot retarget it.
					[_projectile,_shotTarget,_deadline,_step,_debug,_engagement,_round] spawn {
						params ["_projectile","_target","_deadline","_step","_debug","_engagement","_round"];
						private _result = [true,false,""];
						while {_result select 0} do {
							sleep 0.01;
							_result = [_projectile,_target,false,_deadline] call _step;
						};
						if (_debug) then {
							diag_log format ["A3C OW cannon guidance ended: engagement=%1 round=%2 target=%3 reason=%4",
								_engagement,_round,_target,_result select 2];
						};
					};
				}; // Guns never touch missile state/guidance; every matched round takes this branch.
				if ((_request get "shots") > 1) exitWith {
					_projectile setVariable ["A3C_OW_MissileLaunch",[_session get "id",_engagement]];
					(_request get "projectiles") pushBackUnique _projectile;
					_request set ["state","FLIGHT"];
					_request set ["terminated",false];
					_request set ["assessmentUntil",-1];
					_request set ["safetyHold",true];
					_request set ["reason","Additional matching missile projectile: target reserved and global safety hold until every projectile terminates."];
					if (_debug) then {diag_log format ["A3C OW UNKNOWN LAUNCH QUARANTINED: extra projectile=%1 id=%2 capturedTarget=%3",_projectile,_engagement,_shotTarget];};
				};
				_request set ["projectile",_projectile];
				_projectile setVariable ["A3C_OW_MissileLaunch",[_session get "id",_engagement]];
				(_request get "projectiles") pushBackUnique _projectile;
				if (!_lateMatch) then {_request set ["unknown",false];};
				_request set ["state","FLIGHT"];
				_request set ["flightStart",time];
				_request set ["flightDeadline",time + 120];
				_request set ["handoffDeadline",time + 3];
				_request set ["reason","Confirmed missile in flight."];
				if ((_session get "missileFlights") findIf {(_x get "id") == _engagement} < 0) then {
					(_session get "missileFlights") pushBack _request;
				};
				if (((_vehicle getVariable ["A3C_Guided_Projectile",[-1]]) param [0,-1]) == _engagement) then {
					_vehicle setVariable ["A3C_Guided_Projectile",[_engagement,_projectile,1,[_projectile]],true];
				};
				if (_debug) then {diag_log format ["A3C OW MISSILE CONFIRMED: id=%1 target=%2 projectile=%3 late=%4",_engagement,_shotTarget,_projectile,_lateMatch];};
				private _startGuidance = {
					params ["_projectile","_target","_engagement","_debug","_laser"];
					private _reason = "";
					if (isNull _projectile || {!alive _projectile}) then {_reason = "launched projectile no longer exists/alive";} else {
						if (isNull _target) then {_reason = "captured target no longer exists";} else {
							if (!local _projectile) then {_reason = "projectile not local at guidance receiver";};
						};
					};
					if (_reason != "") exitWith {
						if (_debug) then {diag_log format ["A3C OW missile guidance could not start: engagement=%1 target=%2 projectile=%3 ammo=%4 targetClass=%5 nativeAttempted=false owner=NONE reason=%6",
							_engagement,_target,_projectile,typeOf _projectile,typeOf _target,_reason];};
					};
					private _guidanceOwner = "";
					// One native-first decision for both air and ground; ACE reservation precedes either.
					call {
						private _ammo = typeOf _projectile; // Actual Fired projectile, not the selected magazine's prediction.
						private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
						private _sensorManager = _ammoCfg >> "Components" >> "SensorsManagerComponent";
						private _sensors = _sensorManager >> "Components";
						// As in remote launch: actual ammo must advertise a compatible seeker.
						// A modern sensor manager supersedes legacy irLock, even if empty.
						private _objectGuidance = if (isClass _sensorManager) then {
							(configProperties [_sensors,"isClass _x",true]) findIf {
								getText (_x >> "componentType") in ["IRSensorComponent","VisualSensorComponent",
									"ActiveRadarSensorComponent","PassiveRadarSensorComponent"]
							} >= 0
						} else {getNumber (_ammoCfg >> "irLock") == 1};
						private _laserGuidance = if (isClass _sensorManager) then {
							(configProperties [_sensors,"isClass _x",true]) findIf {
								getText (_x >> "componentType") == "LaserSensorComponent"
							} >= 0
						} else {getNumber (_ammoCfg >> "laserLock") == 1};
						// Never acquire a proxy as an object target. The retained designation
						// must still belong to this captured ground target, including at a remote receiver.
						private _realTarget = (_target isKindOf "AllVehicles")
							&& {!(_target isKindOf "LaserTarget")}
							&& {!(_target isKindOf "A3C_Invisible_Man_F")}
							&& {!(_target isKindOf "A3C_Supression_Target_F")};
						private _validLaser = !(_target isKindOf "Air") && {!isNull _laser} && {alive _laser}
							&& {_laser isKindOf "LaserTarget"} && {(attachedTo _laser) isEqualTo _target};
						private _aceLoaded = isClass (configFile >> "CfgPatches" >> "ace_main")
							|| {isClass (configFile >> "CfgPatches" >> "ace_missileguidance")}
							|| {!isNil "ace_missileguidance_fnc_onFired"};
						private _aceConfigured = _aceLoaded && {getNumber (_ammoCfg >> "ace_missileguidance" >> "enabled") == 1};
						_guidanceOwner = _projectile getVariable ["A3C_OW_MissileGuidanceOwner",""];
						if (_projectile getVariable ["A3C_Guidance_Started",false]) then {_guidanceOwner = "SCRIPTED";};
						private _nativeReason = switch (true) do {
							case (_guidanceOwner != ""): {"projectile already claimed; no reassignment"};
							case (_aceConfigured): {"ACE-configured ammunition; mod guidance reserved, activation unverified"};
							case (!alive _target): {"captured target no longer alive"};
							case (!isClass _ammoCfg || {toLower getText (_ammoCfg >> "simulation") != "shotmissile"}): {"actual ammunition is not a configured shotMissile"};
							case (getNumber (_ammoCfg >> "maneuvrability") <= 0): {"ammunition has no native manoeuvrability"};
							case (!(_objectGuidance && {_realTarget}) && {!(_laserGuidance && {_validLaser})}): {"no compatible native object seeker or valid laser designation"};
							default {""};
						};
						private _nativeApplicable = _nativeReason == "";
						private _assigned = false;
						private _nativeAccepted = false;
						private _verifiedTarget = missileTarget _projectile;
						if (_nativeApplicable) then {
							private _candidates = [];
							if (_objectGuidance && {_realTarget}) then {_candidates pushBack _target;};
							if (_laserGuidance && {_validLaser}) then {_candidates pushBack _laser;};
							{
								// A laser seeker is eligibility, not proof this ammo supports the command.
								// Ordinary acquisition only; never force a lock or retry later in flight.
								_assigned = _projectile setMissileTarget _x;
								_verifiedTarget = missileTarget _projectile;
								_nativeAccepted = _assigned && {_verifiedTarget isEqualTo _x};
								_nativeReason = if (_nativeAccepted) then {"native target accepted and verified"} else {
									if (!_assigned) then {"setMissileTarget rejected ordinary acquisition"} else {"missileTarget did not match candidate"}
								};
								if (_debug) then {diag_log format ["A3C OW native acquisition: engagement=%1 ammo=%2 targetClass=%3 candidate=%4 candidateClass=%5 assigned=%6 verified=%7 accepted=%8 projectile=%9",
									_engagement,_ammo,typeOf _target,_x,typeOf _x,_assigned,_verifiedTarget,_nativeAccepted,_projectile];};
								if (_nativeAccepted) exitWith {};
							} forEach _candidates;
						};
						if (_guidanceOwner == "") then {
							if (_aceConfigured) then {_guidanceOwner = "ACE_RESERVED";};
							if (_nativeAccepted) then {_guidanceOwner = "NATIVE";};
							if (_guidanceOwner != "") then {_projectile setVariable ["A3C_OW_MissileGuidanceOwner",_guidanceOwner];};
						};
						if (_debug) then {
							diag_log format ["A3C OW missile guidance decision: engagement=%1 target=%2 projectile=%3 ammo=%4 nativeApplicable=%5 attempted=%6 setMissileTarget=%7 missileTarget=%8 owner=%9 reason=%10 targetClass=%11 objectSeeker=%12 laserSeeker=%13 validLaser=%14",
								_engagement,_target,_projectile,_ammo,_nativeApplicable,_nativeApplicable,_assigned,_verifiedTarget,
								if (_guidanceOwner == "") then {"SCRIPTED_FALLBACK_REQUESTED"} else {_guidanceOwner},_nativeReason,typeOf _target,_objectGuidance,_laserGuidance,_validLaser];
						};
					};
					// Native flights never enter the trajectory helper, even after lock loss/CM.
					// ACE-enabled ammo is conservatively left to the mod, regardless of EH order/AI settings.
					if (_guidanceOwner != "") exitWith {};
					if (isNil "A3C_ai_shared_fnc_guideProjectileMissile") exitWith {
						if (_debug) then {diag_log format ["A3C OW missile guidance could not start: engagement=%1 target=%2 projectile=%3 ammo=%4 owner=NONE reason=missile guidance helper unavailable",
							_engagement,_target,_projectile,typeOf _projectile];};
					};
					private _alreadyStarted = _projectile getVariable ["A3C_Guidance_Started",false];
					// Helper claims atomically, attempts a bounded correction, retries zero launch
					// velocity in its own worker, and guards duplicate/locality ownership.
					[_projectile,_target,"MISSILE",_debug] call A3C_ai_shared_fnc_guideProjectileMissile;
					if (_debug) then {
						private _status = if (_alreadyStarted) then {"already owned; no duplicate worker"} else {
							if !(_projectile getVariable ["A3C_Guidance_Started",false]) then {"helper did not claim projectile"} else {
								if (_projectile getVariable ["A3C_Guidance_Released",true]) then {"helper claimed then released; no continuing guidance"} else {
									"helper claimed; actual writes/cadence reported by scripted guidance stop diagnostics"
								}
							}
						};
						diag_log format ["A3C OW missile guidance: engagement=%1 target=%2 projectile=%3 status=%4",_engagement,_target,_projectile,_status];
					};
				};
				if (isNull _projectile || {!alive _projectile} || {local _projectile}) then {
					[_projectile,_shotTarget,_engagement,_debug,_request getOrDefault ["laser",objNull]] call _startGuidance;
				} else {
					// Exceptional locality handoff uses the projectile owner, never a
					// future helicopter owner. Receiver validates locality and logs start.
					[[_projectile,_shotTarget,_engagement,_debug,_request getOrDefault ["laser",objNull]],_startGuidance] remoteExecCall ["bis_fnc_call",_projectile];
					if (_debug) then {diag_log format ["A3C OW missile guidance dispatched: engagement=%1; receiver execution not confirmed",_engagement];};
				};
				_request set ["handoff",true]; // Dispatch/attempt only; not proof of guidance execution.
				// ACE_RESERVED is a reservation, not proof that ACE actually started guidance.
				if (!local _projectile || {!(_projectile getVariable ["A3C_Guidance_Started",false])
					&& {(_projectile getVariable ["A3C_OW_MissileGuidanceOwner",""]) != "NATIVE"}}) then {
					_request set ["safetyHold",true];
					_request set ["reason","Guidance receiver ownership unconfirmed; global safety hold until actual projectile completion."];
				};
				private _data = _vehicle getVariable ["A3C_fireComplete",["",false,-1]];
				if ((_data param [2,-1]) == _engagement) then {
					_vehicle setVariable ["A3C_fireComplete",[_weapon,true,_engagement],true];
				};
			}];
			_session set ["firedEH",_handle];
		};

		// These are worker-local engagement helpers, not another lifecycle monitor.
		private _combatCurrent = {
			if (!(call _current) || {[] call _exitCondition}
				|| {!((_leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)}
				|| {!((_vehicle getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)}) exitWith {
				_doExit = true; false
			};
			call _maintainMissileFlights;
			!_doExit
		};
		private _rejectEngagement = {
			params ["_target","_cause","_targetSpecific"];
			_authorizationReason = _cause; // Latch even before a fireRequest/engagement ID exists.
			// A confirmed command's own missile reservation is normal completion, not an early rejection.
			if (!_targetSpecific && {(_request getOrDefault ["commands",0]) > 0}) exitWith {false};
			private _until = 0;
			if (_targetSpecific) then {
				private _index = _engagementRejections findIf {(_x select 0) isEqualTo _target};
				_until = time + 5;
				private _entry = [_target,_until,_cause];
				if (_index < 0) then {_engagementRejections pushBack _entry;} else {_engagementRejections set [_index,_entry];};
				_retrySelection = true;
				_nextEvaluation = 0;
			};
			private _scope = if (_targetSpecific) then {"TARGET"} else {
				switch (_cause) do {
					case "SESSION_CANCELLED": {"SESSION"};
					case "TARGET_PREEMPTED": {"PREEMPTION"};
					case "TARGET_TEMPORARILY_UNAVAILABLE": {"MISSILE_CONTROL"};
					default {"WEAPON"};
				}
			};
			private _changed = !((_lastEngagementRejection getOrDefault ["target",objNull]) isEqualTo _target)
				|| {(_lastEngagementRejection getOrDefault ["cause",""]) != _cause}
				|| {(_lastEngagementRejection getOrDefault ["scope",""]) != _scope};
			_lastEngagementRejection = createHashMapFromArray [["time",time],["target",_target],
				["cause",_cause],["scope",_scope],["excluded",_targetSpecific],["until",_until]];
			if (_changed && {_vehicle getVariable ["A3C_OW_Debug",false]}) then {
				diag_log format ["A3C OW authorization rejected: target=%1 cause=%2 scope=%3 excluded=%4 until=%5",
					_target,_cause,_scope,_targetSpecific,_until];
			};
			false
		};
		private _engagementCurrent = {
			params ["_target","_method","_spec"];
			if (_authorizationReason != "") exitWith {false};
			if !(call _combatCurrent) exitWith {[_target,"SESSION_CANCELLED",false] call _rejectEngagement};
			if (_method == "MISSILE" && {count (_session get "missileFlight") > 0
				|| {(_session get "missileFlights") findIf {(_x get "target") isEqualTo _target || {_x getOrDefault ["safetyHold",false]}} >= 0}}) exitWith {
				[_target,"TARGET_TEMPORARILY_UNAVAILABLE",false] call _rejectEngagement
			};
			if (time >= _nextEvaluation) then {call _evaluateTargets;};
			if (!((_selectedTarget getOrDefault ["target",objNull]) isEqualTo _target)
				|| {(_selectedTarget getOrDefault ["method",""]) != _method}) exitWith {
				_preempted = true; [_target,"TARGET_PREEMPTED",false] call _rejectEngagement
			};
			_spec params ["_weapon","_muzzle","_magazine","_turret","_operator","_mode","_reload","_minRange","_maxRange"];
			private _distance = _vehicle distance _target;
			private _lease = _operator getVariable ["A3C_OW_FeatureSession",createHashMap];
			if !(alive _target && {side _target != civilian} && {(side _target) getFriend (side _vehicle) < 0.6}
				&& {_method != "MISSILE" || {!(_target isKindOf "Air")} || {canMove _target}}
				&& {!(_target isKindOf "Man") || {vehicle _target == _target}}
				&& {_target isKindOf "Man" || {{alive _x} count crew _target > 0}}) exitWith {
				[_target,"TARGET_INVALID",true] call _rejectEngagement
			};
			if (_distance < _minRange || {_distance > _maxRange}) exitWith {
				[_target,"TARGET_OUT_OF_RANGE",true] call _rejectEngagement
			};
			if (!(_target isKindOf "Man") && {!([_vehicle,_target] call A3C_main_fnc_hasHeliOverwatchLOS)}) exitWith {
				[_target,"LOS_BLOCKED",true] call _rejectEngagement
			};
			private _operatorReady = alive _operator && {!isPlayer _operator} && {local _operator}
				&& {lifeState _operator != "INCAPACITATED"}
				&& {(_lease getOrDefault ["vehicle",objNull]) == _vehicle}
				&& {(_lease getOrDefault ["id",[]]) isEqualTo (_session get "id")}
				&& {_vehicle turretLocal _turret} && {_vehicle turretUnit _turret == _operator}
				&& {(_vehicle unitTurret _operator) isEqualTo _turret}
				&& {toLower _weapon in ((_vehicle weaponsTurret _turret) apply {toLower _x})}
				&& {(magazinesAllTurrets [_vehicle,true]) findIf {
					(_x select 1) isEqualTo _turret && {(_x select 2) > 0}
						&& {toLower (_x select 0) == toLower _magazine}
				} >= 0};
			if (!_operatorReady) exitWith {[_target,"WEAPON_UNAVAILABLE",false] call _rejectEngagement};
			true
		};
		private _clearAim = {
			isNil {
				if !(call _current) exitWith {};
				{
					_x params ["_actor","_target"];
					private _lease = _actor getVariable ["A3C_OW_FeatureSession",createHashMap];
					if (alive _actor && {local _actor} && {!isPlayer _actor}
						&& {!(_actor == _vehicle && {isPlayer gunner _vehicle})}
						&& {_actor == _vehicle || {
							(_lease getOrDefault ["vehicle",objNull]) == _vehicle
							&& {(_lease getOrDefault ["id",[]]) isEqualTo (_session get "id")}
						}}
						&& {(assignedTarget _actor) isEqualTo _target}) then {
						_actor doTarget objNull;
						_actor doWatch objNull;
					};
				} forEach (_session get "targetOrders");
				_session set ["targetOrders",[]];
			};
		};
		private _stopRotation = {
			isNil {
				if !(call _current) exitWith {};
				private _rotation = _session get "rotation";
				if (!scriptDone _rotation) then {
					terminate _rotation;
					if (_session get "rotationSpeedOwned") then {_vehicle limitSpeed false;};
				};
				_session set ["rotation",scriptNull];
				_session set ["rotationSpeedOwned",false];
			};
		};

		while {call _combatCurrent} do {
			isNil {if (call _current) then {_pilot setBehaviourStrong "CARELESS";};};
			call _evaluateTargets;
			private _method = _selectedTarget getOrDefault ["method",""];
			private _preempted = false;
			private _retrySelection = false;
			private _authorizationReason = "";
			if (_method != "") then {
				private _target = _selectedTarget get "target";
				private _option = _selectedTarget get "option";
				private _spec = _option select (count _option - 1);
				_spec params ["_weapon","_muzzle","_magazine","_turret","_operator","_mode","_reload","_minRange","_maxRange"];
				private _mayEngage = {[_target,_method,_spec] call _engagementCurrent};
				private _aim = _target;
				private _laser = objNull;
				private _request = createHashMap;
				private _failed = false;
				// Ground missiles keep the existing owned, surface-attached laser.
				// AA uses the actual aircraft; it is never wrapped in a ground laser.
				if (_method == "MISSILE" && {!(_target isKindOf "Air")}) then {
					isNil {
						if !(call _mayEngage) exitWith {};
						private _laserType = if (((side _vehicle) getFriend west) > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
						_laser = _laserType createVehicle position _target;
						_aim = _laser;
						_session set ["lasers",(_session get "lasers") select {!isNull _x}];
						(_session get "lasers") pushBack _laser;
						private _attachArray = [0,0,-1];
						private _dir = _laser getDir _vehicle;
						private _dist = sizeOf typeOf _target;
						private _startPos = _laser getPos [_dist,_dir];
						_startPos set [2,1];
						_startPos = ATLtoASL _startPos;
						private _refPos = [_startPos,_dist,_dir + 180] call BIS_fnc_relPos;
						private _intersections = lineIntersectsSurfaces [_startPos,_refPos,_laser,objNull,true,1,"GEOM","NONE"];
						if (_intersections isNotEqualTo []) then {
							(_intersections select 0) params ["_surface","_normal","_object"];
							if (_object == _target) then {
								_laser setPosASL _surface;
								_attachArray = _target worldToModel (ASLtoATL _surface);
							};
						};
						_laser attachTo [_target,_attachArray];
					};
				};

				// A fresh rotation for EVERY missile or eight-round gun engagement.
				if (call _mayEngage) then {
					call _clearAim;
					private _rotation = [position _target] call _rotate;
					private _rotationDeadline = time + 12; // Helper's normal timeout remains ten seconds.
					waitUntil {
						sleep 0.05;
						!(call _mayEngage) || {scriptDone _rotation} || {time >= _rotationDeadline}
					};
					call _stopRotation;
					if (call _mayEngage) then {
						[_operator,_vehicle,_aim,_session,_turret] call _aimTarget;
						isNil {
							if (call _mayEngage) then {
								_vehicle selectWeaponTurret [_weapon,_turret,_muzzle,_mode];
							};
						};
						private _settleUntil = time + 0.5;
						waitUntil {sleep 0.05; !(call _mayEngage) || {time >= _settleUntil};};

						// Confirmed flights reserve only their own targets; no global flight-completion wait.
						if (call _mayEngage) then {
							isNil {
								if !(call _mayEngage) exitWith {};
								private _id = (_vehicle getVariable ["A3C_Fire_Engagement",0]) + 1;
								_vehicle setVariable ["A3C_Fire_Engagement",_id];
								_request = createHashMapFromArray [
									["id",_id],["sessionId",_session get "id"],["kind",_method],
									["target",_target],["spec",_spec],["pending",false],["shots",0],
									["acceptShots",false],["commands",0],["reason",""],
									["lastShot",time - _reload],["projectile",objNull],["projectiles",[]],["handoff",false],["flightDeadline",0],
									["state","PREPARING"],["started",-1],["flightStart",-1],["terminated",false],
									["assessmentUntil",-1],["safetyHold",false],["laser",_laser],
									["expectedEvent",([_weapon,_muzzle,_magazine,_mode] apply {toLower _x}) + [_operator]]
								];
								_session set ["fireRequest",_request];
							};
							private _limit = if (_method == "MISSILE") then {1} else {8};
							private _loadRequested = false;
							private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
							private _muzzleCfg = if (_muzzle == _weapon) then {_weaponCfg} else {_weaponCfg >> _muzzle};
							private _magReload = getNumber (_muzzleCfg >> "magazineReloadTime");
							private _readyWindow = ((_reload + _magReload + 3) max 3) min 120;
							private _readyDeadline = time + _readyWindow;
							private _stopFiring = false;
							while {call _mayEngage && {!_stopFiring} && {count _request > 0} && {(_request get "shots") < _limit}} do {
								if (time >= _readyDeadline) exitWith {
									_failed = true;
									_request set ["reason","Weapon/magazine did not become ready before deadline."];
								};
								private _ready = false;
								isNil {
									if !(call _mayEngage) exitWith {};
									_vehicle selectWeaponTurret [_weapon,_turret,_muzzle,_mode];
									private _state = weaponState [_vehicle,_turret];
									private _loaded = toLower (_state param [3,""]) == toLower _magazine && {(_state param [4,0]) > 0};
									if (_loaded) then {_loadRequested = false;};
									if (!_loaded && {!_loadRequested} && {(_state param [6,-1]) == 0}) then {
										_vehicle loadMagazine [_turret,_weapon,_magazine];
										_loadRequested = true; // One ordinary request per empty/wrong magazine.
									};
									_ready = _loaded
										&& {toLower (_state param [0,""]) == toLower _weapon}
										&& {toLower (_state param [1,""]) == toLower _muzzle}
										&& {toLower (_state param [2,""]) == toLower _mode}
										&& {(_state param [5,-1]) == 0} && {(_state param [6,-1]) == 0}
										&& {time >= (_request get "lastShot") + _reload};
								};
								if (_ready) then {
									private _before = _request get "shots";
									private _issued = false;
									isNil {
										if !(call _mayEngage) exitWith {};
										if ((_request get "shots") >= _limit || {(_request get "commands") >= _limit}
											|| {_request get "pending"}) exitWith {};
										if (_method == "MISSILE" && {count (_session get "missileFlight") > 0
											|| {(_session get "missileFlights") findIf {(_x get "target") isEqualTo _target || {_x getOrDefault ["safetyHold",false]}} >= 0}}) exitWith {
											_stopFiring = true;
											_request set ["reason","Missile target reserved or global quarantine active at final authorization."];
										};
										// Recheck engine readiness in the same unscheduled scope
										// as firing; a scheduled caller may have yielded since selection.
										private _live = weaponState [_vehicle,_turret];
										if (toLower (_live param [0,""]) != toLower _weapon
											|| {toLower (_live param [1,""]) != toLower _muzzle}
											|| {toLower (_live param [2,""]) != toLower _mode}
											|| {toLower (_live param [3,""]) != toLower _magazine}
											|| {(_live param [4,0]) <= 0} || {(_live param [5,-1]) != 0}
											|| {(_live param [6,-1]) != 0}) exitWith {};
										// Final AIR authorization, before any launch/request bookkeeping, in this same unscheduled block.
										if (_method == "MISSILE" && {_target isKindOf "Air"}
											&& {!(alive _target && {canMove _target} && {{alive _x} count crew _target > 0})}) exitWith {
											_stopFiring = true;
											_request set ["reason","Aircraft no longer operational; AA missile firing authorization cancelled."];
											[_target,"TARGET_INVALID",true] call _rejectEngagement;
										};
										if (_method == "MISSILE" && {(([_target] call _assessMissileTarget) select 0) == "NEUTRALIZED"}) exitWith {
											_stopFiring = true;
											_request set ["reason","Target no longer combat-effective at final missile authorization."];
											[_target,"TARGET_INVALID",true] call _rejectEngagement;
										};
										if (_method == "MISSILE") then {
											// Atomic reservation precedes the sole command; only Fired confirms a real flight.
											_request set ["state","RESERVED"];
											_request set ["started",time];
											(_session get "missileFlights") pushBack _request;
											if (_vehicle getVariable ["A3C_OW_Debug",false]) then {
												diag_log format ["A3C OW MISSILE RESERVED: id=%1 target=%2",_request get "id",_target];
											};
											// Initialize missile state once, immediately before its single command.
											_vehicle setVariable ["A3C_Guided_Projectile",[_request get "id",objNull,0,[]],true];
											_vehicle setVariable ["A3C_fireComplete",[_weapon,false,_request get "id"],true];
										};
										_request set ["pending",true];
										_request set ["acceptShots",true];
										_request set ["commands",(_request get "commands") + 1];
										private _stockBefore = 0;
										{
											if ((_x select 1) isEqualTo _turret && {toLower (_x select 0) == toLower _magazine}) then {
												_stockBefore = _stockBefore + ((_x select 2) max 0);
											};
										} forEach magazinesAllTurrets [_vehicle,true];
										_request set ["stockBefore",_stockBefore];
										_issued = true;
										// Correct local weapon operator, actual muzzle and config-resolved mode.
										// The command return value is never used as evidence of a shot.
										_operator forceWeaponFire [_muzzle,_mode];
									};
									if (_issued) then {
										private _ackDeadline = time + 3;
										waitUntil {
											sleep 0.05;
											(_request get "shots") > _before
												|| {if (_method == "MISSILE") then {!(call _combatCurrent)} else {!(call _mayEngage)}}
												|| {time >= _ackDeadline}
										};
										if ((_request get "shots") == _before) then {
											_stopFiring = true; // Latch in the while condition, not a nested exitWith.
											_failed = !_preempted && {!_doExit} && {time >= _ackDeadline};
											if (_failed && {(_request get "reason") == ""}) then {
												_request set ["reason","No matching Fired event within 3 seconds."];
											};
										};
										if (_method == "MISSILE") then {
											isNil {
												if !(call _current) exitWith {};
												private _stockAfter = 0;
												{
													if ((_x select 1) isEqualTo _turret && {toLower (_x select 0) == toLower _magazine}) then {
														_stockAfter = _stockAfter + ((_x select 2) max 0);
													};
												} forEach magazinesAllTurrets [_vehicle,true];
												// Check for unobserved extra rounds even when one projectile was confirmed.
												private _missing = (_request get "stockBefore") - _stockAfter - (_request get "shots");
												if (_missing > 0) then {
													_failed = true; _stopFiring = true;
													_request set ["unaccountedShots",_missing max (_request getOrDefault ["unaccountedShots",0])];
													_request set ["reason","Missile ammunition consumption exceeds captured projectiles; globally quarantined until trustworthy late recovery or session replacement."];
													if !(_request getOrDefault ["unknown",false]) then {
														[_session,objNull,_request,false,_request get "reason"] call (_session get "quarantineMissile");
													};
												};
											};
										};
										// Drain the normal round-reload interval before issuing
										// another command, counting any additional Fired events.
										if (_method == "GUN" && {(_request get "shots") > _before}) then {
											waitUntil {
												sleep 0.01;
												!(call _mayEngage) || {(_request get "shots") > (_request get "commands")}
													|| {time >= (_request get "lastShot") + _reload}
											};
											if ((_request get "shots") > (_request get "commands")) then {
												_stopFiring = true; _failed = true;
												_request set ["reason","Configured single-round mode emitted extra Fired events; mode disabled for this session."];
												_blockedUntil set [str (_spec select [0,6]),1e12];
											};
										};
										_readyDeadline = time + _readyWindow;
									} else {
										sleep 0.05;
									};
								} else {
									sleep 0.05;
								};
							};
							// Launch acknowledgement is complete; the worker may select B while A remains tracked.
						};
					};
				};

				call _clearAim;
				isNil {
					if !(call _current) exitWith {};
					// Confirmed/unresolved flights retain their own ground laser until termination/session cleanup.
					if (!isNull _laser && {(_request getOrDefault ["shots",0]) == 0}
						&& {!(_request getOrDefault ["unknown",false])}) then {deleteVehicle _laser;};
					if (_method == "MISSILE" && {(_request getOrDefault ["shots",0]) == 0}) then {
						private _id = _request getOrDefault ["id",-1];
						_session set ["missileFlights",(_session get "missileFlights") select {(_x get "id") != _id}];
					};
					_request set ["pending",false];
					_request set ["acceptShots",false];
					if ((_request getOrDefault ["shots",0]) == 0) then {
						if (_authorizationReason == "" && {(_request getOrDefault ["commands",0]) == 0}) then {
							private _cause = _request getOrDefault ["reason",""];
							if (_cause == "") then {_cause = "AUTHORIZATION_CANCELLED";};
							[_target,_cause,false] call _rejectEngagement;
						};
						if ((_request getOrDefault ["reason",""]) == "") then {_request set ["reason",_authorizationReason];};
					} else {_lastEngagementRejection = createHashMap;};
					_session set ["lastFire",[_method,_target,_spec,_request getOrDefault ["shots",0],_preempted,_failed,_request getOrDefault ["reason",""]]];
					if ((_request getOrDefault ["commands",0]) > 0 && {_vehicle getVariable ["A3C_OW_Debug",false]}) then {
						diag_log format ["A3C OW fire %1: kind/target/spec/actual shots/preempted/failed/reason = %2",
							_request getOrDefault ["id",-1],_session get "lastFire"];
					};
					_session set ["fireRequest",createHashMap];
					if (_failed) then {
						private _key = str (_spec select [0,6]);
						_blockedUntil set [_key,(time + 5) max (_blockedUntil getOrDefault [_key,0])];
					};
					if (_method == "MISSILE" && {(_request getOrDefault ["shots",0]) == 0}) then {
						private _id = _request getOrDefault ["id",-1];
						if (((_vehicle getVariable ["A3C_fireComplete",["",false,-1]]) param [2,-1]) == _id) then {_vehicle setVariable ["A3C_fireComplete",nil,true];};
						if (((_vehicle getVariable ["A3C_Guided_Projectile",[-1]]) param [0,-1]) == _id) then {_vehicle setVariable ["A3C_Guided_Projectile",nil,true];};
					};
				};
			};
			if (_doExit) exitWith {};
			// No live ammo, no executable mode and no target are normal ACTIVE
			// idle states. Reevaluate stock/capabilities on the next iteration.
			if (!_preempted && {!_retrySelection}) then {sleep 1;}; // Target rejection immediately reselects; normal cadence is unchanged.
		};

/*
							//-- save / generate vectors
							_initVectorDir = vectorDir _vehicle;
							_initVectorUp = vectorUp _vehicle;

							_tilt = [_vehicle,position _activeTarget] call MCSS_fnc_tiltObjectTowardsPosition;
							_tilt params ["_newVectorDir","_newVectorUp"];
							_vehicle selectWeapon _weapon;

							//-- tilt chopper into position:
							[
								format ["A3C_EH_TILT_%1",str _vehicle],
								"onEachFrame",
								[0,_vehicle,_aslPos,_initVectorDir,_newVectorDir,_initVectorUp,_newVectorUp] call _fnc_tilt
							] call BIS_fnc_addStackedEventHandler;
							sleep 1;
							[format ["A3C_EH_TILT_%1",str _vehicle], "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

							//-- keep chopper tilted
							[
								format ["A3C_EH_TILT_%1",str _vehicle],
								"onEachFrame",
								[1,_vehicle,_aslPos,_newVectorDir,_newVectorDir,_newVectorUp,_newVectorUp] call _fnc_tilt
							] call BIS_fnc_addStackedEventHandler;
							*/

/*
								///////////////////////////////////-- DO NOT DELETE THIS !!!!!!!!!!!!!!!!!!
								if (count _entitiesGroundAndWater < 2) then {
									//-- tilt back to upright position
									[
										format ["A3C_EH_TILT_%1",str _vehicle],
										"onEachFrame",
										[0,_vehicle,_aslPos,_newVectorDir,_initVectorDir,_newVectorUp,_initVectorUp] call _fnc_tilt
									] call BIS_fnc_addStackedEventHandler;
									sleep 1;
									[format ["A3C_EH_TILT_%1",str _vehicle], "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
								};

								*/

		"worker finished / cancelled" call _release;
		/////////////////////////////////////////////   CAS BEHAVIOUR COMPLETE
	};
	_session set ["worker",_worker];
	_session set ["workerStarted",true];
	} forEach (_owRun get "sessions");
};

sleep 1;
waitUntil {
	sleep 0.05;
	if !(call _owMainCurrent) exitWith {true};
	_isCompleted = [] call _exitCondition; 
	
	_var = _leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]];
	//systemchat str [_isCompleted,!(_var select 0),(_pos distance (waypointPosition [_group, currentWaypoint _group])) > 1];
	_isCompleted OR {!(_var select 0) OR {(_pos distance (waypointPosition [_group, currentWaypoint _group])) > 1}}
};

private _normalDeparture = call _owMainCurrent;
isNil {[_owRun,"waypoint complete / cancelled"] call _owReleaseRun;};
if (!_normalDeparture) exitWith {true};

// Restoration is complete BEFORE any doMove or the existing three-second delay.
private _canDepart = {
	local _group && {alive _leader} && {local _leader} && {vehicle _leader == _leaderVic}
		&& {(_group getVariable ["A3C_OW_RunSerial",-1]) == ((_owRun get "id") select 2)}
		&& {_wp in waypoints _group} && {currentWaypoint _group == _wpIndex}
		&& {([_wp] call _owSignature) isEqualTo (_owRun get "signature")}
};
private _remainingWaypoints = waypoints _group select {_x select 1 > currentwaypoint _group};
if (count _remainingWaypoints > 0) then {
	isNil {if (call _canDepart) then {_leader domove (waypointPosition (_remainingWaypoints select 0));};};
	sleep 3;
	isNil {if (call _canDepart) then {(units _group - [_leader]) doFollow _leader;};};
};

[_leader,_group,_owRun get "id"] spawn {
	params ["_leader","_group","_id"];
	sleep 30; //-- existing delayed return to AWARE, guarded against replacement
	isNil {
		if ((_group getVariable ["A3C_OW_RunSerial",-1]) == (_id select 2)
			&& {alive _leader} && {local _leader} && {!isPlayer _leader} && {group _leader == _group}) then {
			_leader setBehaviourStrong "AWARE";
		};
	};
};

[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls",0]; //-- check gocodes and assign color

true;





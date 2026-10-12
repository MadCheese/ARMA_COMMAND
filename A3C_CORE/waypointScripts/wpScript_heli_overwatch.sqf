

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
			["fireRequest",createHashMap],["missileFlight",createHashMap],["lastFire",[]]
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
		
		// Run on engagement boundaries and at most once per two seconds in a gun
		// window. Selection keeps the original waypoint direction.
		private _evaluateTargets = {
			if !(call _current) exitWith {};
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
			// An unobserved launch cannot be retried safely. Ground targets can
			// use the gun during quarantine. Normal tracked flights retain the
			// selector's hysteresis and wait for completion; AA infantry can preempt.
			private _missilesReady = if ((_session get "missileFlight") getOrDefault ["unknown",false]) then {[]} else {_weaponAmmo select _available};
			private _result = [_vehicle,_direction,_missilesReady,_usableGuns select _available,_retention,_rankingCache]
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
				private _session = _vehicle getVariable ["A3C_OW_Session",createHashMap];
				if (count _session == 0 || {(_session get "firedEH") != _thisEventHandler}) exitWith {};
				private _run = _session get "run";
				if !([_run,_session] call (_run get "valid")) exitWith {};
				private _request = _session get "fireRequest";
				private _simulation = toLower getText (configFile >> "CfgAmmo" >> _ammo >> "simulation");
				private _flight = _session get "missileFlight";
				private _lateMatch = (_flight getOrDefault ["unknown",false]) && {_simulation == "shotmissile"}
					&& {(([_weapon,_muzzle,_magazine,_mode] apply {toLower _x}) + [_gunner])
						isEqualTo (_flight get "expectedEvent")};
				// Recover the exact captured request, even if a gun now owns fireRequest.
				if (_lateMatch) then {_request = _flight;};
				private _matches = false;
				private _kind = _request getOrDefault ["kind",""];
				if ((_lateMatch || {_request getOrDefault ["acceptShots",false]})
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
				// Even an unexpected/late missile event owns the launch slot until
				// its actual projectile is gone. It is never guided or retargeted here.
				if (_simulation == "shotmissile" && {!_matches || {(_request get "shots") > 0}}) then {
					if (count _flight == 0) then {
						_flight = createHashMapFromArray [["id",-1],["projectiles",[]],
							["handoff",false],["flightDeadline",time + 120]];
						_session set ["missileFlight",_flight];
					};
					(_flight get "projectiles") pushBackUnique _projectile;
					if !(_flight getOrDefault ["unknown",false]) then {
						_flight set ["reason","Unexpected missile Fired event; waiting for observed projectile completion."];
					};
				};
				if (!_matches) exitWith {
					if (_request getOrDefault ["acceptShots",false]) then {
						_request set ["reason",format ["Fired mismatch: actual=%1 expected=%2",
							[_weapon,_muzzle,_magazine,_mode,_gunner],_request get "spec"]];
						if (_vehicle getVariable ["A3C_OW_Debug",false]) then {diag_log (_request get "reason");};
					};
				};
				// Count EVERY matching Fired event during the request, including
				// any extra events after the first acknowledged discharge.
				_request set ["pending",false];
				_request set ["shots",(_request get "shots") + 1];
				_request set ["lastShot",time];
				if (_kind != "MISSILE") exitWith {}; // Guns never touch missile state/guidance.
				if ((_request get "shots") > 1) exitWith {};
				private _engagement = _request get "id";
				private _missiletarget = _request get "target"; // Captured real object, never a future assignedTarget.
				_request set ["projectile",_projectile];
				(_request get "projectiles") pushBackUnique _projectile;
				_request set ["unknown",false];
				_request set ["flightDeadline",time + 120];
				_request set ["handoffDeadline",time + 3];
				_request set ["reason","Confirmed missile in flight."];
				_session set ["missileFlight",_request];
				_vehicle setVariable ["A3C_Guided_Projectile",[_engagement,_projectile,1,[_projectile]],true];
				[_vehicle,_weapon,_projectile,_missiletarget,_engagement,_session,_request] spawn {
					params ["_vehicle","_weapon","_projectile","_missiletarget","_engagement","_session","_request"];
					sleep 1;
					isNil {
						// A launched shot may finish after release/preemption; no firing here.
						[[_projectile,_missiletarget,"MISSILE"],A3C_ai_shared_fnc_guideProjectileMissile] remoteExec ["bis_fnc_spawn",_vehicle];
						if (_session get "closed") exitWith {};
						private _run = _session get "run";
						if !([_run,_session] call (_run get "valid")) exitWith {};
						if (((_session get "missileFlight") getOrDefault ["id",-1]) != _engagement) exitWith {};
						_request set ["handoff",true];
						private _data = _vehicle getVariable ["A3C_fireComplete",["",false,-1]];
						if ((_data param [2,-1]) == _engagement) then {
							_vehicle setVariable ["A3C_fireComplete",[_weapon,true,_engagement],true];
						};
					};
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
			private _flight = _session get "missileFlight";
			if (count _flight > 0) then {
				private _projectiles = _flight get "projectiles";
				if (!(_flight getOrDefault ["unknown",false])
					&& {_projectiles findIf {!isNull _x && {alive _x}} < 0}) then {
					isNil {
						if !(call _current) exitWith {};
						// Recheck inside the atomic mutation; a Fired event may have
						// added another observed projectile since the scheduled check.
						_flight = _session get "missileFlight";
						if (count _flight == 0 || {_flight getOrDefault ["unknown",false]}
							|| {(_flight get "projectiles") findIf {!isNull _x && {alive _x}} >= 0}) exitWith {};
						_session set ["missileFlight",createHashMap];
						if (((_vehicle getVariable ["A3C_Guided_Projectile",[-1]]) select 0) == (_flight get "id")) then {
							_vehicle setVariable ["A3C_Guided_Projectile",nil,true];
							_vehicle setVariable ["A3C_fireComplete",nil,true];
						};
					};
				} else {
					if (time >= (_flight getOrDefault ["handoffDeadline",1e12])
						&& {!(_flight getOrDefault ["handoffReported",false])}
						&& {!(_flight get "handoff") || {
							_projectiles findIf {local _x && {!(_x getVariable ["A3C_Guidance_Started",false])}} >= 0
						}}) then {
						_flight set ["handoffReported",true];
						_flight set ["reason","Guidance handoff/start not acknowledged after 3 seconds; waiting for actual missile completion."];
						if (_vehicle getVariable ["A3C_OW_Debug",false]) then {diag_log (_flight get "reason");};
					};
					// A timeout explains a blocked slot; it does not end Overwatch or
					// permit another launch while the existing projectile is alive.
					if (time >= (_flight get "flightDeadline") && {!(_flight getOrDefault ["timeoutReported",false])}) then {
						_flight set ["timeoutReported",true];
						_flight set ["reason",format ["Missile slot held: unknown launch=%1, live projectiles=%2, handoff requested=%3",
							_flight getOrDefault ["unknown",false],_projectiles select {!isNull _x && {alive _x}},_flight get "handoff"]];
						if (_vehicle getVariable ["A3C_OW_Debug",false]) then {diag_log (_flight get "reason");};
					};
				};
			};
			!_doExit
		};
		private _engagementCurrent = {
			params ["_target","_method","_spec"];
			if !(call _combatCurrent) exitWith {false};
			if (time >= _nextEvaluation) then {call _evaluateTargets;};
			if (!((_selectedTarget getOrDefault ["target",objNull]) isEqualTo _target)
				|| {(_selectedTarget getOrDefault ["method",""]) != _method}) exitWith {
				_preempted = true; false
			};
			_spec params ["_weapon","_muzzle","_magazine","_turret","_operator","_mode","_reload","_minRange","_maxRange"];
			private _distance = _vehicle distance _target;
			private _lease = _operator getVariable ["A3C_OW_FeatureSession",createHashMap];
			alive _target && {side _target != civilian} && {(side _target) getFriend (side _vehicle) < 0.6}
				&& {!(_target isKindOf "Man") || {vehicle _target == _target}}
				&& {_target isKindOf "Man" || {{alive _x} count crew _target > 0}}
				&& {_target isKindOf "Man" || {!(lineIntersects [getPosASL _vehicle,getPosASL _target,_vehicle,_target])}}
				&& {_distance >= _minRange} && {_distance <= _maxRange}
				&& {alive _operator} && {!isPlayer _operator} && {local _operator}
				&& {lifeState _operator != "INCAPACITATED"}
				&& {(_lease getOrDefault ["vehicle",objNull]) == _vehicle}
				&& {(_lease getOrDefault ["id",[]]) isEqualTo (_session get "id")}
				&& {_vehicle turretLocal _turret} && {_vehicle turretUnit _turret == _operator}
				&& {(_vehicle unitTurret _operator) isEqualTo _turret}
				&& {toLower _weapon in ((_vehicle weaponsTurret _turret) apply {toLower _x})}
				&& {(magazinesAllTurrets [_vehicle,true]) findIf {
					(_x select 1) isEqualTo _turret && {(_x select 2) > 0}
						&& {toLower (_x select 0) == toLower _magazine}
				} >= 0}
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

						// Preemption may rotate/aim at B while A remains in flight.
						// Guns may engage B; another missile cannot launch before A finishes.
						if (_method == "MISSILE") then {
							waitUntil {
								sleep 0.05;
								!(call _mayEngage) || {count (_session get "missileFlight") == 0}
							};
						};
						if (call _mayEngage) then {
							isNil {
								if !(call _mayEngage) exitWith {};
								private _id = (_vehicle getVariable ["A3C_Fire_Engagement",0]) + 1;
								_vehicle setVariable ["A3C_Fire_Engagement",_id];
								_request = createHashMapFromArray [
									["id",_id],["sessionId",_session get "id"],["kind",_method],
									["target",_target],["spec",_spec],["pending",false],["shots",0],
									["acceptShots",false],["commands",0],["reason",""],
									["lastShot",time - _reload],["projectile",objNull],["projectiles",[]],["handoff",false],["flightDeadline",0]
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
										if (_method == "MISSILE" && {count (_session get "missileFlight") > 0}) exitWith {};
										// Recheck engine readiness in the same unscheduled scope
										// as firing; a scheduled caller may have yielded since selection.
										private _live = weaponState [_vehicle,_turret];
										if (toLower (_live param [0,""]) != toLower _weapon
											|| {toLower (_live param [1,""]) != toLower _muzzle}
											|| {toLower (_live param [2,""]) != toLower _mode}
											|| {toLower (_live param [3,""]) != toLower _magazine}
											|| {(_live param [4,0]) <= 0} || {(_live param [5,-1]) != 0}
											|| {(_live param [6,-1]) != 0}) exitWith {};
										if (_method == "MISSILE") then {
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
											(_request get "shots") > _before || {!(call _mayEngage)} || {time >= _ackDeadline}
										};
										if ((_request get "shots") == _before) then {
											_stopFiring = true; // Latch in the while condition, not a nested exitWith.
											_failed = !_preempted && {!_doExit} && {time >= _ackDeadline};
											if (_failed && {(_request get "reason") == ""}) then {
												_request set ["reason","No matching Fired event within 3 seconds."];
											};
											if (_method == "MISSILE" && {call _current}) then {
												private _stockAfter = 0;
												{
													if ((_x select 1) isEqualTo _turret && {toLower (_x select 0) == toLower _magazine}) then {
														_stockAfter = _stockAfter + ((_x select 2) max 0);
													};
												} forEach magazinesAllTurrets [_vehicle,true];
												// Unacknowledged ammo consumption may be an untracked launch.
												// Keep ACTIVE, but quarantine the missile slot if no event
												// supplied a projectile we can observe. Guns remain usable.
												if (_stockAfter < (_request get "stockBefore") && {count (_session get "missileFlight") == 0}) then {
													_failed = true;
													_request set ["reason","Missile ammo consumed without a Fired projectile; launch slot quarantined until a late event or session replacement."];
													_request set ["unknown",true];
													_request set ["expectedEvent",([_weapon,_muzzle,_magazine,_mode] apply {toLower _x}) + [_operator]];
													_request set ["flightDeadline",time + 120];
													_session set ["missileFlight",_request];
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
							if (_method == "MISSILE" && {(_request getOrDefault ["shots",0]) > 0}) then {
								// Priority/validity reevaluations continue throughout the flight.
								// Preemption exits this wait without deleting or retargeting its projectile.
								waitUntil {
									sleep 0.05;
									!(call _mayEngage) || {count (_session get "missileFlight") == 0}
								};
							};
						};
					};
				};

				call _clearAim;
				// Guidance captures the real target at Fired, so deleting this owned
				// laser cannot change a launched missile's target on preemption.
				if (!isNull _laser) then {deleteVehicle _laser;};
				isNil {
					if !(call _current) exitWith {};
					_request set ["pending",false];
					_request set ["acceptShots",false];
					_session set ["lastFire",[_method,_target,_spec,_request getOrDefault ["shots",0],_preempted,_failed,_request getOrDefault ["reason",""]]];
					if (_vehicle getVariable ["A3C_OW_Debug",false]) then {
						diag_log format ["A3C OW fire %1: kind/target/spec/actual shots/preempted/failed/reason = %2",
							_request getOrDefault ["id",-1],_session get "lastFire"];
					};
					_session set ["fireRequest",createHashMap];
					if (_failed) then {
						private _key = str (_spec select [0,6]);
						_blockedUntil set [_key,(time + 5) max (_blockedUntil getOrDefault [_key,0])];
					};
					if (_method == "MISSILE" && {(_request getOrDefault ["shots",0]) == 0}
						&& {count (_session get "missileFlight") == 0}) then {
						_vehicle setVariable ["A3C_fireComplete",nil,true];
						_vehicle setVariable ["A3C_Guided_Projectile",nil,true];
					};
				};
			};
			if (_doExit) exitWith {};
			// No live ammo, no executable mode and no target are normal ACTIVE
			// idle states. Reevaluate stock/capabilities on the next iteration.
			if (!_preempted) then {sleep 1;}; // Bounded burst/failure/idle pacing, then a new decision.
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





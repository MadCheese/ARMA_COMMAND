

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
			["rotationSpeedOwned",false],["firedEH",-1],["lasers",[]],["targetOrders",[]]
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

// Keep the legacy lock-system/magazine gate; only live stock/ranges are tightened.
_fnc_vehicleWeaponAmmo = {
	params ["_vehicle", "_cache"];
	private _operator = gunner _vehicle;
	if (isNull _operator || {!alive _operator} || {isPlayer _operator}
		|| {!local _operator} || {!local _vehicle}) exitWith {[]};
	private _turret = _vehicle unitTurret _operator;
	if !(_vehicle turretLocal _turret) exitWith {[]};
	private _return = [];
	private _stock = magazinesAllTurrets [_vehicle,true];
	{
		private _weapon = _x;
		private _cfg = configFile >> "CfgWeapons" >> _weapon;
		// Deliberately not expanded to new RHS / other missile systems in 2A.
		if (getNumber (_cfg >> "weaponLockSystem") in [2,4]) then {
			{
				private _mag = _x;
				private _rounds = 0;
				{
					if ((_x select 1) isEqualTo _turret && {toLower (_x select 0) == toLower _mag}) then {
						_rounds = _rounds + ((_x select 2) max 0);
					};
				} forEach _stock;
				if (_rounds > 0) then {
					private _info = [_weapon,"this",_mag,_cache] call A3C_main_fnc_getHeliOverwatchAmmoInfo;
					private _types = if (_info get "airAmmo") then {["AIR"]} else {["CAR","TANK","SHIP"]};
					if ((_info get "range") > 0 && {_info get "damaging"}
						&& {(_info get "simulation") == "shotmissile"}) then {
						_return pushBack [_weapon,_types,_rounds,_info get "range",_info get "minRange"];
					};
				};
			} forEach getArray (_cfg >> "magazines");
		};
	} forEach (_vehicle weaponsTurret _turret);
	_return
};


_doFire = {
	params ["_gunner","_vehicle","_activeTarget","_weapon","_enemyVehicle","_session"];
	isNil {
		private _run = _session get "run";
		if !([_run,_session] call (_run get "valid")) exitWith {};
		_session set ["targetOrders",[[_gunner,_activeTarget],[_vehicle,_activeTarget]]];
		_gunner forgetTarget (assignedtarget _gunner);
		_gunner doTarget objNull;
		_gunner reveal [_activeTarget,4];
		_gunner lookAt _activeTarget;
		private _engagement = (_vehicle getVariable ["A3C_Fire_Engagement", 0]) + 1;
		_vehicle setVariable ["A3C_Fire_Engagement", _engagement];
		_vehicle setVariable ["A3C_Guided_Projectile", [_engagement, objNull, 0, []], true];
		_vehicle setVariable ["A3C_fireComplete",[_weapon,false,_engagement],true];
		{_x doWatch _activeTarget; _x lookat _activeTarget; _x doTarget _activeTarget} foreach [_gunner,_vehicle];
		if (_enemyVehicle isKindOf "AIR") then {
			{_x doFire _activeTarget} foreach [_gunner,_vehicle];
		};
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
	private _worker = [_pilot,_group,_leaderVic,+_pos,_direction,_overwatch_height,_fnc_vehicleWeaponAmmo,_doFire,_exitCondition,_t,_session] spawn {
		params ["_pilot","_group","_leaderVic","_waypointPos","_direction","_overwatch_height","_fnc_vehicleWeaponAmmo","_doFire","_exitCondition","_t","_session"];
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
		// Read live stock for classifier-approved gun/muzzle/magazine combinations.
		// Entries: [weapon, muzzle, magazine, range]; loaded ammunition comes first.
		private _getAvailableGuns = {
			params ["_vehicle","_capabilities"];
			if !(_capabilities getOrDefault ["hasTraversableGun",false]) exitWith {[]};
			private _turret = _capabilities get "primaryGunnerTurret";
			private _operator = _vehicle turretUnit _turret;
			if (isNull _operator || {!alive _operator} || {isPlayer _operator}
				|| {!local _operator} || {!(_vehicle turretLocal _turret)}
				|| {!((_vehicle unitTurret _operator) isEqualTo _turret)}) exitWith {[]};
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
							private _info = [_gun,_muzzleName,_magazine,_rankingCache]
								call A3C_main_fnc_getHeliOverwatchAmmoInfo;
							// Same configured gun ceiling as 1B-A, cached per combination.
							private _range = (_info get "range") min 3000;
							if (_range > 0) then {
								private _entry = [_gun,_muzzle,_magazine,_range];
								private _state = weaponState [_vehicle,_turret,_gun,_muzzle];
								if (toLower (_state param [3,""]) == toLower _magazine && {(_state param [4,0]) > 0}) then {
									_loaded pushBackUnique _entry;
								} else {
									_reserve pushBackUnique _entry;
								};
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
			_weaponAmmo = [_vehicle,_rankingCache] call _fnc_vehicleWeaponAmmo;
			_usableGuns = [_vehicle,_capabilities] call _getAvailableGuns;
			private _result = [_vehicle,_direction,_weaponAmmo,_usableGuns,_retention,_rankingCache]
				call A3C_main_fnc_selectHeliOverwatchTarget;
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
			_vehicle setVariable ["A3C_Guided_Projectile",nil,true]; //-- original Fired projectile
			private _handle = _vehicle addEventHandler
			[
				"FIRED",
				{
					params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
					private _session = _vehicle getVariable ["A3C_OW_Session",createHashMap];
					if (count _session == 0 || {(_session get "firedEH") != _thisEventHandler}) exitWith {};
					private _run = _session get "run";
					if !([_run,_session] call (_run get "valid")) exitWith {};
					private _data = _vehicle getVariable ["A3C_fireComplete",["",false,-1]];
					_data params ["_assignedWeapon","_isComplete",["_engagement",-1]];
					private _missiletarget = assignedTarget _gunner;
					// Guidance already resolves attachedTo laser -> real aim object.
					// Capture that object at Fired, so cancellation may delete our laser.
					private _aimObject = attachedTo _missiletarget;
					if (!isNull _aimObject) then {_missiletarget = _aimObject;};
					private _shot = _vehicle getVariable ["A3C_Guided_Projectile",[-1,objNull,0,[]]];

					if (_weapon == _assignedWeapon && {_engagement >= 0} && {(_shot select 0) == _engagement}) then {
						// Track each original shot; delayed workers never overwrite the reference.
						private _shotIndex = (_shot select 2) + 1;
						private _projectiles = +(_shot select 3);
						_projectiles pushBack _projectile;
						_vehicle setVariable ["A3C_Guided_Projectile",[_engagement,_projectile,_shotIndex,_projectiles],true];
						[_vehicle,_weapon,_projectile,_missiletarget,_engagement,_shotIndex,_session] spawn {
							params ["_vehicle","_weapon","_projectile","_missiletarget","_engagement","_shotIndex","_session"];
							sleep 1;
							// Preserve owner routing/pacing without completing a newer engagement.
							isNil {
								// Already-launched shots may finish; this handoff never fires a weapon.
								[[_projectile,_missiletarget,"MISSILE"],A3C_ai_shared_fnc_guideProjectileMissile] remoteExec ["bis_fnc_spawn",_vehicle];
								if (_session get "closed") exitWith {};
								private _run = _session get "run";
								if !([_run,_session] call (_run get "valid")) exitWith {};
								private _current = _vehicle getVariable ["A3C_fireComplete",["",false,-1]];
								if ((_current param [2,-1]) != _engagement) exitWith {};
								private _latestShot = _vehicle getVariable ["A3C_Guided_Projectile",[-1,objNull,0,[]]];
								if ((_latestShot select 0) == _engagement && {(_latestShot select 2) == _shotIndex}) then {
									_vehicle setVariable ["A3C_fireComplete",[_weapon,true,_engagement],true];
								};
							};
						};
					};
				}
			];
			_session set ["firedEH",_handle];
		};

		while {call _current && {canmove _vehicle}} do {
			_pilot setBehaviourStrong "CARELESS";
			private _isCompleted = [] call _exitCondition;
			_leaderVar = _leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]];
			if (_isCompleted OR {!(_leaderVar select 0) OR {(_waypointPos distance (waypointPosition [_group, currentWaypoint _group])) > 1}}) exitWith {
				_doExit = true;
			};
			

			call _evaluateTargets;
			private _method = _selectedTarget getOrDefault ["method",""];
			private _activeTarget = objNull;
			private _weapon = "";
			private _enemyVehicle = objNull;
			private _preempted = false;
			if (_method == "MISSILE") then {
				_enemyVehicle = _selectedTarget get "target";
				_weapon = (_selectedTarget get "option") select 0;
				isNil {
					if !(call _current) exitWith {_doExit = true;};
					_activeTargetType = if (((side _vehicle) getFriend west) > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
					_activeTarget = _activeTargetType createVehicle position _enemyVehicle;
					_session set ["lasers",(_session get "lasers") select {!isNull _x}];
					(_session get "lasers") pushBack _activeTarget;

					_attachArray = [0,0,-1];
					_dir = _activeTarget getDir _vehicle;
					_dist = sizeOf typeOf _enemyVehicle;
					_startPos = (_activeTarget getPos [_dist,_dir]);
					_startPos set [2,1];
					_startPos = ATLtoASL _startPos;
					_refPos = [_startPos,_dist, _dir + 180] call BIS_fnc_relPos;
					private _ins = lineIntersectsSurfaces
					[
						_startPos,
						_refPos,
						_activeTarget,
						objNull,
						true,
						1,
						"GEOM",
						"NONE"
					];
					if (count _ins > 0) then {
						(_ins select 0) params ["_intsPos","_irrellevant","_intsObj"];
						if (_intsObj == _enemyVehicle) then {
							_activeTarget setposASL _intsPos;
							_attachArray = _enemyVehicle worldToModel (ASLtoATL _intsPos);
						} ;
					};
					_activeTarget attachTo [_enemyVehicle,_attachArray];
				};
				if (_weapon != "" && {!isNull _activeTarget} && {alive _activeTarget}) then {
					private _orientPos = position _activeTarget;
					private _rotation = [_orientPos] call _rotate;
					waitUntil {
						sleep 0.05;
						if (time >= _nextEvaluation) then {call _evaluateTargets;};
						_preempted = _preempted || {!((_selectedTarget getOrDefault ["target",objNull]) isEqualTo _enemyVehicle)};
						_doExit = _doExit || {[_vehicle,_pilot,_waypointPos] call _exitFnc}
							|| {!canMove _vehicle}
							|| {[] call _exitCondition}
							|| {!((_leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)}
							|| {!((_vehicle getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)};
						!(call _current) || {_doExit} || {scriptDone _rotation}
					};
					if !(call _current) then {_doExit = true;};
					if (!_doExit) then {call _evaluateTargets;};
					_preempted = _preempted || {!((_selectedTarget getOrDefault ["target",objNull]) isEqualTo _enemyVehicle)};
					if (!_doExit && {!_preempted} && {!isNull _activeTarget} && {alive _activeTarget}) then {
						_weapon = (_selectedTarget get "option") select 0;
						[_gunner,_vehicle,_activeTarget,_weapon,_enemyVehicle,_session] call _doFire;

						if (_activeTarget isKindOf "AIR") then {
							
							sleep 5;
						} else {
						
							///////////////////////////////////-- DO NOT DELETE THIS !!!!!!!!!!!!!!!!!!	
							//_aslPos = getPosASL _vehicle;
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

							sleep 1;
							if (call _current && {[_vehicle,_enemyVehicle,40] call MCSS_fnc_relDirRange}) then {
								isNil {
									if !(call _current) exitWith {};
									_gunner setCombatMode "RED"; //"YELLOW";
									_gunner fireattarget [_vehicle,_weapon];
								};
								//systemchat str [_enemyVehicle,_weapon];
								//systemchat str ["FIRE", _weapon,typeOf _enemyVehicle, typeOf _activeTarget, assignedTarget _gunner];
								private _fireDeadline = time + 30;
								waitUntil {
									sleep 0.05;
									!(call _current) || {time >= _fireDeadline}
										|| {(_vehicle getVariable ["A3C_fireComplete",["",true]]) select 1}
								};
								if (!(call _current) || {time >= _fireDeadline}) exitWith {_doExit = true;};
								sleep 0.5;
								private _shot = _vehicle getVariable ["A3C_Guided_Projectile",[-1,objNull,0,[]]];
								private _engagement = _shot select 0;
								// Keep the owned laser target until every captured original shot completes.
								private _projectileDeadline = time + 120;
								waituntil {
									sleep 0.05;
									if (!(call _current) || {time >= _projectileDeadline}) exitWith {_doExit = true; true};
									private _currentShot = _vehicle getVariable ["A3C_Guided_Projectile",_shot];
									if ((_currentShot select 0) == _engagement) then {_shot = _currentShot;};
									({!isNull _x && {alive _x}} count (_shot select 3)) == 0
								};
								isNil {
									if (call _current && {((_vehicle getVariable ["A3C_Guided_Projectile",[-1,objNull,0,[]]]) select 0) == _engagement}) then {
										_vehicle setVariable ["A3C_Guided_Projectile",nil,true];
									};
								};

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

							};

							
							deleteVehicle _activeTarget;
						};
					} else {
						// Only the ground-target branch creates a temporary laser target.
						if !(_activeTarget isKindOf "AIR") then {deleteVehicle _activeTarget;};
					};
				};
			};
			if (_doExit) exitWith {};

			// The shared selector decides between missiles and on-foot gun targets.
			if (_method == "GUN") then {
				if (_usableGuns isNotEqualTo []) then {
					private _gunTurret = _capabilities get "primaryGunnerTurret";
					private _primaryGunner = _vehicle turretUnit _gunTurret;
					private _target = _selectedTarget get "target";
					if (!isNull _target) then {
						private _gunIndex = _usableGuns findIf {
							_vehicle distance _target <= (_x select 3)
						};

						if (_gunIndex < 0) exitWith {};

						(_usableGuns select _gunIndex) params [
							"_gunWeapon",
							"_gunMuzzle",
							"_gunMagazine",
							"_effectiveRange"
						];
						
						_doExit = [_vehicle,_pilot,_waypointPos] call _exitFnc;
						_doExit = _doExit || {!canMove _vehicle} || {[] call _exitCondition}
							|| {!((_leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)}
							|| {!((_vehicle getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)};
						if (!_doExit && {_vehicle turretUnit _gunTurret == _primaryGunner} && {!isPlayer _primaryGunner} && {alive _primaryGunner}
							&& {local _primaryGunner} && {_vehicle turretLocal _gunTurret}) then {
							private _state = [];
							isNil {
								if !(call _current) exitWith {_doExit = true;};
								_session set ["targetOrders",[[_primaryGunner,_target]]];
								_vehicle selectWeaponTurret [_gunWeapon,_gunTurret,_gunMuzzle];
								_state = weaponState [_vehicle,_gunTurret,_gunWeapon,_gunMuzzle];
								if (((_state param [4,0]) <= 0 || {toLower (_state param [3,""]) != toLower _gunMagazine})
									&& {(_state param [6,0]) == 0}) then {
									// One ordinary load request; readiness is checked during the window.
									_vehicle loadMagazine [_gunTurret,_gunWeapon,_gunMagazine];
								};
								_primaryGunner reveal [_target,4];
								_primaryGunner doTarget _target;
								_primaryGunner doWatch _target;
							};
							private _gunTimer = time;
							private _fireOrdered = false;
							while {call _current && {time - _gunTimer < 7}} do {
								_doExit = _doExit || {[_vehicle,_pilot,_waypointPos] call _exitFnc}
									|| {!canMove _vehicle} || {[] call _exitCondition}
									|| {!((_leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)}
									|| {!((_vehicle getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)};
								if (_doExit || {!alive _target} || {vehicle _target != _target}
									|| {_vehicle distance _target > _effectiveRange}
									|| {_vehicle turretUnit _gunTurret != _primaryGunner}) exitWith {};
								if (time >= _nextEvaluation) then {call _evaluateTargets;};
								if !((_selectedTarget getOrDefault ["target",objNull]) isEqualTo _target) exitWith {
									_preempted = true;
									// Preemption/invalidity ends this window, not a firing failure.
									if (call _current && {alive _primaryGunner} && {!isPlayer _primaryGunner} && {local _primaryGunner}
										&& {_vehicle turretLocal _gunTurret} && {_vehicle turretUnit _gunTurret == _primaryGunner}) then {
										_primaryGunner doTarget objNull;
									};
								};
								_usableGuns = [_vehicle,_capabilities] call _getAvailableGuns;
								if (_usableGuns isEqualTo []) exitWith {};
								private _selected = weaponState [_vehicle,_gunTurret];
								private _selectionChanged = toLower (_vehicle currentWeaponTurret _gunTurret) != toLower _gunWeapon
									|| {toLower (_selected param [1,""]) != toLower _gunMuzzle};
								if (_selectionChanged && {_fireOrdered}) exitWith {};
								isNil {
									if !(call _current) exitWith {_doExit = true;};
									if (_selectionChanged) then {
										_vehicle selectWeaponTurret [_gunWeapon,_gunTurret,_gunMuzzle];
									};
									_state = weaponState [_vehicle,_gunTurret];
									private _loadedGun = _usableGuns findIf {
										toLower (_x select 0) == toLower _gunWeapon && {toLower (_x select 1) == toLower _gunMuzzle}
										&& {toLower (_x select 2) == toLower (_state param [3,""])}
									};
									if (!_fireOrdered && {_loadedGun >= 0} && {(_state param [4,0]) > 0}
										&& {toLower (_state param [0,""]) == toLower _gunWeapon}
										&& {toLower (_state param [1,""]) == toLower _gunMuzzle}
										&& {(_state param [5,-1]) == 0} && {(_state param [6,-1]) == 0}) then {
										_primaryGunner doFire _target;
										_fireOrdered = true;
									};
								};
								sleep 0.5;
							};
							if (call _current && {_vehicle turretUnit _gunTurret == _primaryGunner} && {alive _primaryGunner} && {!isPlayer _primaryGunner}
								&& {local _primaryGunner} && {_vehicle turretLocal _gunTurret}) then {
								_primaryGunner doWatch objNull;
							};
						};
					};
					if (!_preempted) then {sleep 1;};
				};
			};
			if (_doExit) exitWith {};
			if ((_weaponAmmo findIf {!("AIR" in (_x select 1))}) < 0
				&& {([_vehicle,_capabilities] call _getAvailableGuns) isEqualTo []}) exitWith {
				//-- message goes here
			};
			if (!_preempted) then {sleep 2;}; //-- bounded cadence; preemption proceeds next iteration
		};

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





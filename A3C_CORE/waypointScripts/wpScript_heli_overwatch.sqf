

params ["_group", "_pos", "_target","_callerUID","_preCondition","_postCondition","_direction","_overwatch_height","_formation"];

if (local _group) then {
	["releaseGroup", _group, "waypoint invocation"] call A3C_main_fnc_heliOverwatchLifecycle;
};
if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

private _wpIndex = currentWaypoint _group;
private _wp = [_group, _wpIndex];

// private _waypointPositions =  [_pos,units _group,count units _group, (_pos getDir (leader _group)) + 180,100 ] call A3C_main_fnc_generateWpWedgePositions;

private _assignedIndex = 0;


private _leader = leader _group;
private _leaderVic = vehicle _leader;
private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.3;
private _groupPilots = (units _group) select {private _v = vehicle _x; _x == driver _v && {[_v] call A3C_main_fnc_isAttackHelicopter}};

if (count _groupPilots == 0) exitWith {true};

if (isplayer _leader) exitWith {}; //-- here we don't return true because the waypoint may still be issued for players

if (!local _group || {!local _leaderVic}) exitWith {true};

// Release older sessions and capture the original vehicle features BEFORE any
// movement helper can enable PATH. Engine waypoint scripts may lack _thisScript.
private _hasMainHandle = !isNil "_thisScript" && {!isNull _thisScript};
private _mainHandle = if (_hasMainHandle) then {_thisScript} else {scriptNull};
private _lifecycle = ["begin", [_group, _wp, _groupPilots, _mainHandle, _hasMainHandle]]
	call A3C_main_fnc_heliOverwatchLifecycle;
_lifecycle params ["_run", "_sessions"];
if (_sessions isEqualTo []) exitWith {
	["end", _run, "no local helicopters"] call A3C_main_fnc_heliOverwatchLifecycle;
	true
};
private _mainCurrent = {
	["pulse", _run] call A3C_main_fnc_heliOverwatchLifecycle
};
private _leaderSessionIndex = _sessions findIf {(_x get "vehicle") == _leaderVic};
if (_leaderSessionIndex < 0) exitWith {
	["end", _run, "leader is not a local overwatch helicopter"] call A3C_main_fnc_heliOverwatchLifecycle;
	true
};
private _leaderSession = _sessions select _leaderSessionIndex;

isNil {
	if !(call _mainCurrent) exitWith {};
	[_group, true] call A3C_ai_highCommand_fnc_reInitGroupMovement;
	_group setFormation _formation;
	_leader setBehaviourStrong "CARELESS"; //-- gunner keeps engaging
	_leader setCombatMode "BLUE";
};

private _t = time;


_leaderDist = _leaderVic distance2d _pos; 
_closeTo = _precision;
_doSlowDown = false;

if (_leaderDist > 600) then {
	_closeTo = 500;
	_doSlowDown = true;
};



//-- wait for arrival

while {call _mainCurrent && {_leaderVic distance2d _pos >= _closeTo}} do {
	isNil {
		if !(call _mainCurrent) exitWith {};
		_leader setBehaviourStrong "CARELESS";
		{
			if (["current", _x] call A3C_main_fnc_heliOverwatchLifecycle) then {
				(_x get "vehicle") limitSpeed false;
				["phase", _x, "TRAVEL"] call A3C_main_fnc_heliOverwatchLifecycle;
			};
		} forEach _sessions;
		// The regular approach helper enables unit PATH; helicopter travel needs
		// only its ordinary movement orders and the owned vehicle PATH above.
		[_group,_pos,_run get "id"] call A3C_ai_highCommand_fnc_moveGroupToPosition;
	};
	sleep 5;
};
if !(call _mainCurrent) exitWith {
	["end", _run, "travel invalidated"] call A3C_main_fnc_heliOverwatchLifecycle; true
};



//-- slow down aircraft

if (_doSlowDown && {speed _leaderVic > 80}) then {
	_posFrom = getPosASL _leaderVic;
	_posTo = _pos;
	_originalDistance =  _posFrom distance2D _posTo;
	_smallestDistance = +(_originalDistance);
	_speed = 0;  
	_originalspeed = (speed _leaderVic) max 10; 
	isNil {
		if !(call _mainCurrent) exitWith {};
		doStop _leaderVic;
		["phase", _leaderSession, "BRAKING"] call A3C_main_fnc_heliOverwatchLifecycle;
	};
	
	//systemchat 'slowdown';
	_linCon = 1;
	while {call _mainCurrent && {_lincon > 0.2}} do {
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
			if !(call _mainCurrent) exitWith {};
			doStop _leaderVic;
			_leaderVic setVelocity [(sin _dir * _speedReal), (cos _dir * _speedReal), (_vel select 2)];
		};
		sleep 0.01; 
	};
	["phase", _leaderSession, "TRAVEL"] call A3C_main_fnc_heliOverwatchLifecycle;
};

isNil {
	if !(call _mainCurrent) exitWith {};
	_leader domove (position _leaderVic);
	_leader setCombatMode "YELLOW";
};

while {call _mainCurrent && {speed _leaderVic > 10}} do {
	isNil {if (call _mainCurrent) then {_leader setBehaviourStrong "CARELESS";};};
	sleep 2;
};
if !(call _mainCurrent) exitWith {
	["end", _run, "positioning invalidated"] call A3C_main_fnc_heliOverwatchLifecycle; true
};

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
		waitUntil {sleep 0.05; !(call _mainCurrent) || {[] call _exitCondition}};
		if (call _mainCurrent && {!((_preCondition select 0) in ["ARRIVAL",""])}) then {
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
				if !(call _mainCurrent) exitWith {};
				["end", _run, "precondition retrigger"] call A3C_main_fnc_heliOverwatchLifecycle;
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
if (_retriggered || {!(call _mainCurrent)}) exitWith {
	["end", _run, "precondition boundary"] call A3C_main_fnc_heliOverwatchLifecycle; true
};
_run set ["condition", _exitCondition];
_run set ["conditionsReady", true];

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
		if !(["current", _session] call A3C_main_fnc_heliOverwatchLifecycle) exitWith {};
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


{
	private _session = _x;
	_session set ["height", _overwatch_height];
	isNil {
	if !(["current", _session] call A3C_main_fnc_heliOverwatchLifecycle) exitWith {};
	private _worker = [_session,_session get "pilot",_group,_leaderVic,+_pos,_direction,_overwatch_height,_fnc_vehicleWeaponAmmo,_doFire,_exitCondition,_t] spawn {
		params ["_session","_pilot","_group","_leaderVic","_waypointPos","_direction","_overwatch_height","_fnc_vehicleWeaponAmmo","_doFire","_exitCondition","_t"];
		private _workerHandle = _thisScript;
		private _current = {["current", _session] call A3C_main_fnc_heliOverwatchLifecycle};
		private _release = {
			["release", _session, _this, _workerHandle] call A3C_main_fnc_heliOverwatchLifecycle
		};
		
		
				
		_waypointPos set [2,0];
		private _vehicle = vehicle _pilot;
		private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "precision")) * 1.3;
		private _doExit = false;
		private _exitFnc = {
			params ["_vehicle","_pilot","_waypointPos"];
			if !(call _current) exitWith {true};
			
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

		while {true} do {
			_doExit = [_vehicle,_pilot,_waypointPos] call _exitFnc;
			if (_doExit) exitWith {};
			isNil {if (call _current) then {_pilot setBehaviourStrong "CARELESS";};};
			if (_vehicle distance2D (formationposition _vehicle) < (_precision * 1.3) ) exitWith {}; //
			sleep 0.05;
		};
		if (_doExit || {!canMove _vehicle}) exitWith {"formation positioning cancelled" call _release;};


		//-- rotate chopper
		private _targetPos = _vehicle getPos [1000,_direction];
		private _rotation = scriptNull;
		isNil {
			if !(call _current) exitWith {};
			["phase", _session, "ROTATION"] call A3C_main_fnc_heliOverwatchLifecycle;
			_rotation = ["rotate", _session, _targetPos] call A3C_main_fnc_heliOverwatchLifecycle;
			_session set ["freezeOwned", true];
			_vehicle setVariable ["A3C_Freeze_helicopter",[true,_direction],true];
		};
		// Keep the hover flag active while the outer waypoint watcher waits.
		waitUntil {
			sleep 0.05;
			_doExit = _doExit || {[_vehicle,_pilot,_waypointPos] call _exitFnc}
				|| {!canMove _vehicle}
				|| {[] call _exitCondition}
				|| {!((_vehicle getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)};
			_doExit || {scriptDone _rotation}
		};
		if (_doExit) exitWith {
			"initial rotation cancelled" call _release;
		};
		_heliHeight = (getPosVisual _vehicle) select 2;

		_adjustZvelocity = if (_heliHeight < _overwatch_height) then {7} else {-7};
		["phase", _session, "ALTITUDE"] call A3C_main_fnc_heliOverwatchLifecycle;
		//-- adjust altitude
		while {abs ((getposATL _vehicle select 2) - _overwatch_height) > 20} do {
			if !(call _current) exitWith {_doExit = true;};
			isNil {
				if !(call _current) exitWith {_doExit = true;};
				_vehicle setVelocity [0,0,_adjustZvelocity];
			};
			sleep 0.01;
		};
		if (_doExit || {!(call _current)}) exitWith {"altitude cancelled" call _release;};
		private _activated = false;
		isNil {
			if !(call _current) exitWith {};
			_vehicle flyInHeight _overwatch_height;
			_activated = ["phase", _session, "ACTIVE"] call A3C_main_fnc_heliOverwatchLifecycle;
		};
		if (!_activated) exitWith {"altitude admission failed" call _release;};
		/////////////////////////////////////////////   BEGIN CAS-behaviour

		
		private _weapons = weapons _vehicle;
		private _gunner = gunner _vehicle;

		if (isPlayer _gunner) exitWith {
			"player gunner" call _release;
		};
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
		// window. Ranking cadence and selection are independent of lifecycle cleanup.
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
				private _session = _vehicle getVariable ["A3C_OW_Session", createHashMap];
				if (count _session == 0 || {(_session get "firedEH") != _thisEventHandler}
					|| {!( ["current", _session] call A3C_main_fnc_heliOverwatchLifecycle)}) exitWith {};
				private _data = _vehicle getVariable ["A3C_fireComplete",["",false,-1]];
				_data params ["_assignedWeapon","_isComplete",["_engagement",-1]];
				private _missiletarget = assignedTarget _gunner;
				private _shot = _vehicle getVariable ["A3C_Guided_Projectile",[-1,objNull,0,[]]];

				if (_weapon == _assignedWeapon && {_engagement >= 0} && {(_shot select 0) == _engagement}) then {
					// Track each original shot; delayed workers never overwrite the reference.
					private _shotIndex = (_shot select 2) + 1;
					private _projectiles = +(_shot select 3);
					_projectiles pushBack _projectile;
					_vehicle setVariable ["A3C_Guided_Projectile",[_engagement,_projectile,_shotIndex,_projectiles],true];
					private _delayed = [_session,_vehicle,_weapon,_projectile,_missiletarget,_engagement,_shotIndex] spawn {
						params ["_session","_vehicle","_weapon","_projectile","_missiletarget","_engagement","_shotIndex"];
						sleep 1;
						// Preserve owner routing/pacing without completing a newer engagement.
						isNil {
							if !(["current", _session] call A3C_main_fnc_heliOverwatchLifecycle) exitWith {};
							private _current = _vehicle getVariable ["A3C_fireComplete",["",false,-1]];
							if ((_current param [2,-1]) != _engagement) exitWith {};
							[[_projectile,_missiletarget,"MISSILE"],A3C_ai_shared_fnc_guideProjectileMissile] remoteExec ["bis_fnc_spawn",_vehicle];
							private _latestShot = _vehicle getVariable ["A3C_Guided_Projectile",[-1,objNull,0,[]]];
							if ((_latestShot select 0) == _engagement && {(_latestShot select 2) == _shotIndex}) then {
								_vehicle setVariable ["A3C_fireComplete",[_weapon,true,_engagement],true];
							};
						};
					};
					private _pending = (_session get "delayedWorkers") select {!scriptDone _x};
					_pending pushBack _delayed;
					_session set ["delayedWorkers", _pending];
				};
			}
		];
		_session set ["firedEH", _handle];
		};

		while {call _current && {canmove _vehicle}} do {
			isNil {if (call _current) then {_pilot setBehaviourStrong "CARELESS";};};
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
					private _rotation = ["rotate", _session, _orientPos] call A3C_main_fnc_heliOverwatchLifecycle;
					waitUntil {
						sleep 0.05;
						if (time >= _nextEvaluation) then {call _evaluateTargets;};
						_preempted = _preempted || {!((_selectedTarget getOrDefault ["target",objNull]) isEqualTo _enemyVehicle)};
						_doExit = _doExit || {[_vehicle,_pilot,_waypointPos] call _exitFnc}
							|| {!canMove _vehicle}
							|| {[] call _exitCondition}
							|| {!((_leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)}
							|| {!((_vehicle getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0)};
						_doExit || {scriptDone _rotation}
					};
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
								if !(call _current) exitWith {_doExit = true;};
								_gunner setCombatMode "RED"; //"YELLOW";
								_gunner fireattarget [_vehicle,_weapon]; 
								};
								//systemchat str [_enemyVehicle,_weapon];
								//systemchat str ["FIRE", _weapon,typeOf _enemyVehicle, typeOf _activeTarget, assignedTarget _gunner];
								waitUntil {
									sleep 0.05;
									!(call _current) || {(_vehicle getVariable ["A3C_fireComplete",["",true]]) select 1}
								};
								sleep 0.5;
								private _shot = _vehicle getVariable ["A3C_Guided_Projectile",[-1,objNull,0,[]]];
								private _engagement = _shot select 0;
								// Keep the owned laser target until every captured original shot completes.
								waituntil {
									sleep 0.05;
									if !(call _current) exitWith {true};
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

							
							private _index = (_session get "lasers") find _activeTarget;
							if (_index >= 0) then {(_session get "lasers") deleteAt _index;};
							deleteVehicle _activeTarget;
						};
					} else {
						// Only the ground-target branch creates a temporary laser target.
						if !(_activeTarget isKindOf "AIR") then {
							private _index = (_session get "lasers") find _activeTarget;
							if (_index >= 0) then {(_session get "lasers") deleteAt _index;};
							deleteVehicle _activeTarget;
						};
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
							while {time - _gunTimer < 7} do {
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
									isNil {
									if (call _current && {alive _primaryGunner} && {!isPlayer _primaryGunner} && {local _primaryGunner}
										&& {_vehicle turretLocal _gunTurret} && {_vehicle turretUnit _gunTurret == _primaryGunner}) then {
										_primaryGunner doTarget objNull;
									};
									};
								};
								_usableGuns = [_vehicle,_capabilities] call _getAvailableGuns;
								if (_usableGuns isEqualTo []) exitWith {};
								private _selected = weaponState [_vehicle,_gunTurret];
								private _selectionChanged = toLower (_vehicle currentWeaponTurret _gunTurret) != toLower _gunWeapon
									|| {toLower (_selected param [1,""]) != toLower _gunMuzzle};
								if (_selectionChanged && {_fireOrdered}) exitWith {};
								if (_selectionChanged) then {
									isNil {if (call _current) then {_vehicle selectWeaponTurret [_gunWeapon,_gunTurret,_gunMuzzle];};};
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
									isNil {
										if (call _current) then {_primaryGunner doFire _target; _fireOrdered = true;};
									};
								};
								sleep 0.5;
							};
							isNil {
							if (call _current && {_vehicle turretUnit _gunTurret == _primaryGunner} && {alive _primaryGunner} && {!isPlayer _primaryGunner}
								&& {local _primaryGunner} && {_vehicle turretLocal _gunTurret}) then {
								_primaryGunner doWatch objNull;
							};
							};
						};
					};
					// Preserve pacing after the bounded gun window.
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

		// Release before any movement. The outer script orders group departure
		// after releasing ALL helicopters, so a follower cannot outrun cleanup.
		"worker exit" call _release;
		/////////////////////////////////////////////   CAS BEHAVIOUR COMPLETE	
	};
	_session set ["worker", _worker];
	_session set ["hasWorker", true];
	};
} foreach _sessions;


sleep 1;
waitUntil {
	sleep 0.05;
	if !(call _mainCurrent) exitWith {true};
	_isCompleted = [] call _exitCondition; 
	
	_var = _leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]];
	//systemchat str [_isCompleted,!(_var select 0),(_pos distance (waypointPosition [_group, currentWaypoint _group])) > 1];
	_isCompleted OR {!(_var select 0) OR {(_pos distance (waypointPosition [_group, currentWaypoint _group])) > 1}}
};

private _normalDeparture = call _mainCurrent;
["end", _run, if (_normalDeparture) then {"waypoint complete / hover ended"} else {"main invalidated"}]
	call A3C_main_fnc_heliOverwatchLifecycle;
if (!_normalDeparture) exitWith {true};
// Once released, a replacement run can still start during a departure delay.
private _canDepart = {
	!isNull _group && {local _group}
		&& {alive _leader} && {local _leader} && {group _leader == _group} && {leader _group == _leader}
		&& {vehicle _leader == _leaderVic} && {local _leaderVic}
		&& {(_group getVariable ["A3C_OW_LastRunID", []]) isEqualTo (_run get "id")}
		&& {count (_group getVariable ["A3C_OW_Run", createHashMap]) == 0}
		&& {_wp in waypoints _group} && {currentWaypoint _group == _wpIndex}
		&& {waypointType _wp == "SCRIPTED"} && {(waypointPosition _wp) distance2D (_run get "pos") <= 1}
		&& {(["signature", _wp] call A3C_main_fnc_heliOverwatchLifecycle) isEqualTo (_run get "signature")}
};

private _remainingWaypoints = waypoints _group select {_x select 1 > currentwaypoint _group};
if (count _remainingWaypoints > 0) then {
	isNil {if (call _canDepart) then {_leader domove (waypointPosition (_remainingWaypoints select 0));};};
	sleep 3;
	isNil {if (call _canDepart) then {(units _group - [_leader]) doFollow _leader;};};
};

[_leader,_group,_run get "id"] spawn {
	params ["_leader","_group","_id"];
	sleep 30; //-- give some time for leader to move away - gunners will engage anyways
	isNil {
		if (!isNull _group && {local _leader} && {group _leader == _group}
			&& {(_group getVariable ["A3C_OW_LastRunID", []]) isEqualTo _id}
			&& {count (_group getVariable ["A3C_OW_Run", createHashMap]) == 0}) then {
			_leader setBehaviourStrong "AWARE";
		};
	};
};

[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls",0]; //-- check gocodes and assign color

true;





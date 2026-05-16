

params ["_group", "_pos", "_target","_callerUID","_preCondition","_postCondition","_direction","_overwatch_height","_formation"];

if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;


_group setFormation _formation;

private _wpIndex = currentWaypoint _group;

// private _waypointPositions =  [_pos,units _group,count units _group, (_pos getDir (leader _group)) + 180,100 ] call A3C_fnc_generateWpWedgePositions;

private _assignedIndex = 0;


private _leader = leader _group;
private _leaderVic = vehicle _leader;
private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.3;
private _groupPilots = (units _group) select {private _v = vehicle _x; _x == driver _v && {[_v] call A3C_fnc_isAttackHelicopter}};

if (count _groupPilots == 0) exitWith {true};

if (isplayer _leader) exitWith {}; //-- here we don't return true because the waypoint may still be issued for players

_leader setBehaviourStrong "CARELESS"; //-- exploiting a bug: careless will prevent the chopper from his frontal attacks, but the gunner keeps engaging

private _t = time;


waitUntil {
	{((vehicle _x) getVariable ["A3C_Freeze_helicopter",[false,0]]) select 0} count _groupPilots == 0
};


_leader setCombatMode "BLUE"; //"GREEN";

_leaderDist = _leaderVic distance2d _pos; 
_closeTo = _precision;
_doSlowDown = false;

if (_leaderDist > 600) then {
	_closeTo = 500;
	_doSlowDown = true;
};



//-- wait for arrival

while {_leaderVic distance2d _pos >= _closeTo} do { //--_precision
	_wPos = waypointPosition [_group, _wpIndex];
	{_x set [2,0]} foreach [_pos, _wPos];
	if !(_pos isEqualTo _wPos) then {
		_pos = _wPos;
	};

	//systemchat format ["moving: %1",_t];
	_leader setBehaviourStrong "CARELESS";
	{
		_v = vehicle _x;
		_v limitSpeed 1000;
		{
			_x enableAI "PATH";
			_x enableAI "MOVE";
		} foreach [_x,_v]
	} foreach _groupPilots;
	[_group,_pos] call A3C_ai_shared_fnc_approachWaypointRegular;
	sleep 5;
};



//-- slow down aircraft

if (_doSlowDown && {speed _leaderVic > 80}) then {
	_posFrom = getPosASL _leaderVic;
	_posTo = _pos;
	_originalDistance =  _posFrom distance2D _posTo;
	_smallestDistance = +(_originalDistance);
	_speed = 0;  
	_originalspeed = (speed _leaderVic) max 10; 
	doStop _leaderVic;
	_leaderVic disableAI "ALL";
	_leader disableAI "ALL";
	
	//systemchat 'slowdown';
	_linCon = 1;
	while {_lincon > 0.2} do { 
		_vel = velocity _leaderVic; 
		_dir = direction _leaderVic;
		_currentDistance = getPosASL _leaderVic distance2D _posTo; 
		if (_currentDistance > _smallestDistance) exitWith {};
		_smallestDistance = +(_currentDistance);
		_linCon = linearConversion [ 0, _originalDistance, _currentDistance, 0, 1, true ];
		_speed = _originalspeed * _linCon;
		//hintsilent str [_linCon,_speed];
		doStop _leaderVic;
		_speedReal = _speed / 3.6; 
		_leaderVic setVelocity  
		[
			(sin _dir * _speedReal),
			(cos _dir * _speedReal),
			(_vel select 2)
		]; 
		sleep 0.01; 
	};
	_leaderVic enableAI "ALL";
	_leader enableAI "ALL";
};

_leader domove (position _leaderVic);
_leader setCombatMode "YELLOW"; 

while {speed _leaderVic > 10} do {
	_leader setBehaviourStrong "CARELESS";
	sleep 2;
};

//-- compose pre- and post conditions, wait for pre-condition
private _timer = time;

//-- CONDITIONS: Step 1
private _exitCondition = {};
{
	_x params ["_condType","_condVal"];
	_exitCondition = switch (toUpper _condType) do {
		case ("TIMEOUT") : {
			_timeAtCompletion = time + _condVal;
			compile format ["time > %1",_timeAtCompletion];
		};
		case ("GOCODE") : {
			compile format ["A3C_GoCode_Activate_%1",_condVal];
		};
		case ("DAYTIME") : {
			_str = _condVal splitString ":";
			_checkParams = [];
			{
				_checkParams pushBack (parseNumber _X)
			} foreach _str;
			compile format ["%1 call A3C_main_fnc_isDaytimeCompleted",_checkParams];
		};
		default {{true}};
	};

	//-- pre-condition other than 'arrival' will wait and re-trigger waypoint script
	//-- when script is re-triggered, condition is satisfied and script continues
	//-- second cycle is only relevant if post-condition exists. In that case the _exitCondition is stored for later reference


	if (_foreachIndex == 0) then {
		waitUntil {[] call _exitCondition}; //-- _foreachIndex == 0 is for pre-condition
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
			_wp setWaypointScript _wpScript;
			_wp setWaypointPosition [_pos,0];
			private _statements = waypointStatements _wp;
			_statements set [0,"true"];
			_wp setWaypointStatements _statements;
		};
	};
} foreach [_preCondition,_postCondition];

///////////////  _fncs for CAS

_fnc_vehicleWeaponAmmo =  {
	params ["_vehicle"];
	private _return = [];
	private _weapons = weapons _vehicle;
	private _vehicleMags = (magazinesAmmoFull _vehicle) select {_x select 1 > 0}; //magazines _vehicle;
	{
		private _weapon = _x;
		private _weaponLockSystem = getNumber (configfile >> "CfgWeapons" >> _weapon >> "weaponLockSystem");
		_weaponArray = [_weapon];
		if (_weaponLockSystem in [2,4]) then {
			private _suitableWeaponMags = getArray (configfile >> "CfgWeapons" >> _weapon >> "magazines");
			{
				private _weaponMag = _x;
				//if (_x in _vehicleMags) then {
				if ({_weaponMag == _x select 0} count _vehicleMags > 0) then {
					private _ammo = getText (configfile >> "CfgMagazines" >> _weaponMag >> "ammo");
					private _aiAmmoUsageFlags = getText (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");
					private _targetTypes = if (["256",_aiAmmoUsageFlags] call BIS_fnc_instring OR {getNumber (configfile >> "CfgAmmo" >> _ammo >> "airLock") == 2}) then {["AIR"]} else {["CAR","TANK","SHIP"]};
					private _magAmount = {_x == _weaponMag} count magazines _vehicle; 
					{_weaponArray pushBack _x} foreach  [_targetTypes,_magAmount];
				};
				
			} foreach _suitableWeaponMags;
		};
		if (count _weaponArray > 1) then {
			_return pushBack _weaponArray;
		};
	} foreach _weapons;
	_return
};

_fnc_canVehicleEngageAir = {
	params ["_vehicle"];
	_return = false;
	if (canFire _vehicle) then {
		{
			private _ammo = getText (configfile >> "CfgMagazines" >> _x >> "ammo");
			private _aiAmmoUsageFlags = getText (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");
			private _canTargetAir = ["256",_aiAmmoUsageFlags] call BIS_fnc_instring OR {getNumber (configfile >> "CfgAmmo" >> _ammo >> "airLock") == 2};
			if (_canTargetAir) exitWith {
				_return = true;

			};
		} foreach (magazines _vehicle);
	};
	_return	
};


_doFire = {
	params ["_gunner","_vehicle","_activeTarget","_weapon","_enemyVehicle"];
	
	_gunner forgetTarget (assignedtarget _gunner);
	_gunner doTarget objNull;
	_gunner reveal [_activeTarget,4];
	_gunner lookAt _activeTarget;
	_vehicle setVariable ["A3C_fireComplete",[_weapon,false],true];
	{_x doWatch _activeTarget; _x lookat _activeTarget; _x doTarget _activeTarget} foreach [_gunner,_vehicle];
	if (_enemyVehicle isKindOf "AIR") then {
		{_x doFire _activeTarget} foreach [_gunner,_vehicle];
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
	[_x,_group,_leaderVic,_pos,_direction,_overwatch_height,_fnc_vehicleWeaponAmmo,_fnc_canVehicleEngageAir,_doFire,_exitCondition,_t] spawn {
		params ["_pilot","_group","_leaderVic","_waypointPos","_direction","_overwatch_height","_fnc_vehicleWeaponAmmo","_fnc_canVehicleEngageAir","_doFire","_exitCondition","_t"];
		
		
				
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

		while {true} do {
			_doExit = [_vehicle,_pilot,_waypointPos] call _exitFnc;
			_pilot setBehaviourStrong "CARELESS";
			if (_vehicle distance2D (formationposition _vehicle) < (_precision * 1.3) ) exitWith {}; //
			if (_doExit) exitWith {};
		};
		if (_doExit) exitWith {};


		//-- rotate chopper
		private _targetPos = _vehicle getPos [1000,_direction];
		_vehicle domove _targetPos;
		_vehicle setVariable ["A3C_Freeze_helicopter",[true,_direction],true];
		_heliHeight = (getPosVisual _vehicle) select 2;

		_adjustZvelocity = if (_heliHeight < _overwatch_height) then {7} else {-7};
		_vehicle disableAI "PATH";
		//-- adjust altitude
		while {abs ((getposATL _vehicle select 2) - _overwatch_height) > 20} do {
			_vehicle setVelocity [0,0,_adjustZvelocity];
			private _var = _vehicle getVariable ["A3C_Freeze_helicopter",[false,0]];
			if !(_var select 0) exitWith {};
		};
		_vehicle flyInHeight _overwatch_height;
		/////////////////////////////////////////////   BEGIN CAS-behaviour

		
		private _weapons = weapons _vehicle;
		private _gunner = gunner _vehicle;
		if (isplayer _gunner) exitWith {};
		private _weapon = "";
		private _weaponAmmo = [];
		private _updateWeaponAmmo = true;
		
		_vehicle setVariable ["A3C_Replacement_Projectile",nil,true]; //-- for missile guide
		private _handle = _vehicle addEventHandler
		[
			"FIRED",
			{
				params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
				_data = _vehicle getVariable ["A3C_fireComplete",["",false]];
				_data params ["_assignedWeapon","_isComplete"];
				private _missiletarget =  assignedTarget _gunner;

				if (_weapon == _assignedWeapon) then {
					[_vehicle,_weapon,_projectile,_missiletarget] spawn {
						params ["_vehicle","_weapon","_projectile","_missiletarget"];
						//-- currently guiding all rockets due to targetting issues
						//if (speed _missiletarget > 0 OR {"rhs_" in toLower _weapon}) then {
							sleep 1;
							//systemchat 'exacto';
							_vehicle setVariable ["A3C_fireComplete",[_weapon,true],true];
							[[_vehicle,_projectile,2,_missiletarget,_missiletarget],A3C_ai_shared_fnc_guideProjectileMissile] remoteExec ["bis_fnc_spawn",_vehicle]; //--0 did not work.
						//} else {
						//	waitUntil {isNull _projectile Or {!alive _projectile}};
						//};
						
						_vehicle setVariable ["A3C_fireComplete",[_weapon,true], true];
						
					};

				};
			}
		];

		while {canmove _vehicle} do {
			_pilot setBehaviourStrong "CARELESS";
			private _isCompleted = [] call _exitCondition;
			_leaderVar = _leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]];
			if (_isCompleted OR {!(_leaderVar select 0) OR {(_waypointPos distance (waypointPosition [_group, currentWaypoint _group])) > 1}}) exitWith {
				_vehicle setVariable ["A3C_Replacement_Projectile",nil,true];
				_vehicle setVariable ["A3C_fireComplete",nil,true];
				_vehicle setVariable ["A3C_Freeze_helicopter",nil,true];
			};
			

			private _activeTarget = objNull;
			private _weapon = "";
			private _canEngageLand = false;
			private _canEngageAir = false;
			private _availableWeapons = [ [],[] ]; //-- [GROUND,AIR]
			private _enemyVehicle = objNull;
			private _maxRangeGround = [0,0];
			private _maxRangeAir = [0,0];

			//-- fetch available missile ammo
			if (_updateWeaponAmmo) then {
				_weaponAmmo = [_vehicle] call _fnc_vehicleWeaponAmmo;
				_updateWeaponAmmo = false;
			};
			{
				_x params ["_weapon","_activeTargetTypes","_magAmount"]; 
				
				if ("AIR" in _activeTargetTypes) then {
					_maxRange = getNumber (configfile >> "CfgWeapons" >> _weapon >> "maxRange"); 
					if (_maxRange > _maxRangeAir select 0) then {
						_step = switch (true) do {
							case (_maxRange % 500) : {500};
							default {100};
						};
						_maxRangeAir = [_maxRange,_step];
					};
					(_availableWeapons select 1) pushBack _weapon;
					_canEngageAir = true;
				} else {
					_maxRange = getNumber (configfile >> "CfgWeapons" >> _weapon >> "maxRange");
					if (_maxRange > _maxRangeGround select 0) then {
						_step = switch (true) do {
							case (_maxRange % 500) : {500};
							default {100};
						};
						_maxRangeGround = [_maxRange,_step];
					};
					(_availableWeapons select 0) pushBack _weapon;
					_canEngageLand = true;
				};
			} foreach _weaponAmmo;

			_entitiesAIR = [];
			_entitiesGroundAndWater = [];
			if (count _weaponAmmo > 0) then {		
				//-- only check for air entities if unit can target those 
				if (_canEngageAir) then {
					//-- attempt to minimize use of resources
					_maxRangeAir params ["_d","_s"];
					for "_i" from _s to _d step _s do {
						_entitiesAIR = ([side _vehicle,_i,"ENEMY",position _vehicle,["AIR"]] call MCSS_fnc_NearEntities) select {
							{alive _x} count crew _x > 0 && {
								!(lineInterSects [getPosasl _vehicle, getPosASL _x,_vehicle,_x])
							}	
						};
						if (count _entitiesAIR > 0) then {};
					};
				};

				if (count _entitiesAIR > 0) then {
					_entitiesAIR = [_entitiesAIR,[],{count weapons _x},"DESCEND"] call BIS_fnc_sortBy; //-- we want to engage gunships/jets > transport helos
					_activeTarget = _entitiesAIR select 0;
					//_enemyVehicle = _entitiesAIR select 0;
					//_weapon = (_availableWeapons select 1) select 0;
					//_activeTargetType = if (((side _vehicle) getFriend west) > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
					//_activeTarget = _activeTargetType createvehicle position _enemyVehicle;
					//_activeTarget attachTo [_enemyVehicle,[0,0,0]];
					//_updateWeaponAmmo = true;
					
				} else {
					
					//-- only check for ground/marine targets if unit can target those
					if (_canEngageLand) then {
						//-- attempt to minimize use of resources
						_maxRangeGround params ["_d","_s"];
						for "_i" from _s to _d step _s do {
							_entitiesGroundAndWater = ([side _vehicle,_i,"ENEMY",position _vehicle,["TANK","CAR","SHIP"]] call MCSS_fnc_NearEntities) select {
								canFire _x && {
									speed _x < 100 && {
										count (weapons _x select {_wpn = _x; {_x in _wpn} count ["horn","smoke"] == 0}) > 0 && {
											{alive _x} count crew _x > 0 && {
												!(lineInterSects [getPosasl _vehicle, getPosASL _x,_vehicle,_x])
											}
										}
									}
								}
							};
							if (count _entitiesGroundAndWater > 0) then {};
						};
					};
					
					if (count _entitiesGroundAndWater > 0) then {
						
						_entitiesGroundAndWater = 
						[
							_entitiesGroundAndWater,
							[],
							{
								_armor = getNumber (configfile >> "CfgVehicles" >> typeOf _x >> "armor");
								_canTargetAir = if ([_x] call _fnc_canVehicleEngageAir && {assignedTarget _vehicle isKindOf "AIR"}) then {1000} else {1};
								_isTank = if (_x isKindOf "TANK") then {2000} else {1};
								_armor * _canTargetAir * _isTank
							},
							"DESCEND"
						] call BIS_fnc_sortBy; //-- heaviest vehicle first
						_enemyVehicle = _entitiesGroundAndWater select 0;
						_weapon = (_availableWeapons select 0) select 0;
						_activeTargetType = if (((side _vehicle) getFriend west) > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
						_activeTarget = _activeTargetType createvehicle position _enemyVehicle;
						
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
						_updateWeaponAmmo = true;
					} else {
						//-- no targets - search for Infantry
						_weapon =( weapons _vehicle select 0);
						_vehicle selectWeapon _weapon;
						_maxRange = getNumber (configfile >> "CfgWeapons" >> _weapon >> "maxRange");
						_entitiesMan = ([side _vehicle,3000,"ENEMY",position _vehicle,["MAN"]] call MCSS_fnc_NearEntities); //_maxRange
						_entitiesMan = [_entitiesMan,[],{getNumber (configfile >> "CfgWeapons" >> secondaryWeapon _x >> "canLock")},"DESCEND"] call BIS_fnc_sortBy; //-- go for AA- and AT-units first
						if (count _entitiesMan > 0) then {
							
							_target = _entitiesMan select 0;
							//player globalchat str _target;
							_gunner reveal [_target,4];
							_gunner doTarget _target;
							_gunner doFIre _target;
							_timer = time;
							while {(time - _timer) < 7} do {
								if (!alive _target) exitWith {};
								sleep 1;
							};
						};
						_weapon = ""; //-- to prevent missile fnc from firing
					};
				};

				if (_weapon != "") then {
					_orientPos = _vehicle getPos [1000, _vehicle getDIr _activeTarget]; 
					_orientPos set [2,0];
					_vehicle domove _orientPos; 
					//systemchat str _orientPos; playsound "A3C_MenuSound1";
					_timer = time;
					waitUntil {
						!canMove _vehicle OR {
							_relDir = _vehicle getRelDir _activeTarget;
							_relDir < 90 OR {
								_relDir < 270 OR {
									time - _timer > 10
								}
							}
						}
					};
					if (canMove _vehicle) then {
						[_gunner,_vehicle,_activeTarget,_weapon,_enemyVehicle] call _doFire;

						if (_activeTarget isKindOf "AIR") then {
							
							sleep 5;
						} else {
						
							///////////////////////////////////-- DO NOT DELETE THIS !!!!!!!!!!!!!!!!!!	
							//_aslPos = getPosASL _vehicle;
							/*
							//-- save / generate vectors
							_initVectorDir = vectorDir _vehicle;
							_initVectorUp = vectorUp _vehicle;

							_tilt = [_vehicle,position _activeTarget] call MCSS_fnc_TiltTowardsPos;
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
							if ([_vehicle,_enemyVehicle,40] call MCSS_fnc_relDirRange) then {
								_gunner setCombatMode "RED"; //"YELLOW";
								_gunner fireattarget [_vehicle,_weapon]; 
								//systemchat str [_enemyVehicle,_weapon];
								//systemchat str ["FIRE", _weapon,typeOf _enemyVehicle, typeOf _activeTarget, assignedTarget _gunner];
								waituntil {(_vehicle getVariable ["A3C_fireComplete",["",true]]) select 1};
								sleep 0.5;
								_m = _vehicle getVariable ["A3C_Replacement_Projectile",objNull];
								//systemchat str [_m];
								waituntil {isNull _m OR {!alive _m}};
								//systemchat "cont";
								_vehicle setVariable ["A3C_Replacement_Projectile",nil,true];
								[format ["A3C_EH_TILT_%1",str _vehicle], "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

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
					};
					_vehicle selectWeapon (weapons _vehicle select 0);
				};
			};
			if (count _weaponAmmo == 0) exitWith {
				//-- message goes here
			};
			sleep 0.1;
		};

		private _remainingWaypoints = waypoints _group select {_x select 1 > currentwaypoint _group};
		if (count _remainingWaypoints > 0) then {
			_pilot domove (waypointPosition (_remainingWaypoints select 0));
			sleep 3;
		};
						
		_vehicle setVariable ["A3C_fireComplete",nil,true];
		_vehicle setVariable ["A3C_Freeze_helicopter",[false,0],true];
		_vehicle removeEventHandler ["FIRED",_handle];
		_vehicle enableAI "PATH";
		_vehicle flyInHeight (_pilot getVariable ["A3C_FLYINHEIGHT",100]);
		//=====systemchat format ["exited: %1",_t];
		/////////////////////////////////////////////   CAS BEHAVIOUR COMPLETE	
	};
} foreach _groupPilots;


sleep 1;
waitUntil {
	_isCompleted = [] call _exitCondition; 
	
	_var = _leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]];
	//systemchat str [_isCompleted,!(_var select 0),(_pos distance (waypointPosition [_group, currentWaypoint _group])) > 1];
	_isCompleted OR {!(_var select 0) OR {(_pos distance (waypointPosition [_group, currentWaypoint _group])) > 1}}
};

private _remainingWaypoints = waypoints _group select {_x select 1 > currentwaypoint _group};
if (count _remainingWaypoints > 0) then {
	_leader domove (waypointPosition (_remainingWaypoints select 0));
	sleep 3;
	(units _group - [_leader]) doFollow _leader;
};

_leader spawn {
	sleep 30; //-- give some time for leader to move away - gunners will engage anyways
	_this setBehaviourStrong "AWARE";
};

{
	private _vehicle = vehicle _x;
	{_vehicle enableAI _x; } foreach ["TARGET","PATH"];
	_vehicle  setVariable ["A3C_Freeze_helicopter",[false,0],true];
	_vehicle flyInHeight (_x getVariable ["A3C_FLYINHEIGHT",100]);

} foreach _groupPilots;

[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0]; //-- check gocodes and assign color

true;





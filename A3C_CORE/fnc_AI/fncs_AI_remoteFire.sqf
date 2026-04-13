//-----------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------  F I R E  -  O R D E R S   -------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------






//-----
//----- used in SUPPRESSION by vehicles
//-----
A3C_addFiredHandler = { 
	params ["_vehicle","_target"];
	if !(local _vehicle) exitWith {};
	if (!isNull ((_vehicle getvariable ["A3C_REMOTE_HANDLE",[-1,objNull]]) select 1)) exitWith {};
	_handle = _vehicle addEventHandler
	[
		"Fired",
		{
			_this spawn A3C_guided_BulletHandler_1
		}

	];
	_vehicle setvariable ["A3C_REMOTE_HANDLE",[_handle,_target]];
};

A3C_removeFiredHandler = {
	params ["_vehicle"];
	if !(local _vehicle) exitWith {};
	_var = _vehicle getvariable ["A3C_REMOTE_HANDLE",[-1,objNull]];
	if (count _var == 0 OR {_var select 0 == -1}) exitWith {};
	_vehicle removeEventhandler ["FIRED",_var select 0];
	_vehicle setvariable ["A3C_REMOTE_HANDLE",[-1,objNull]];
};
//-----
//-----
//-----


A3C_FireCounterMeasures = {
	params [
		"_vehicle",
		"_mode" //-- ): 0 = only check, 1 = fire if possible
	];


	_counterWeapon = "";
	_found = false;

	{
		_turret = _x;
		_turretWeapons = _vehicle weaponsturret _x;
		{
			_weapon = _x;
			_magazines = getArray (configfile >> "CfgWeapons" >> _x >> "magazines");
			{
				_mag = _x;
				
				_ammo = getText (configfile >> "CfgMagazines" >> _x >> "ammo");
				_aiAmmoUsageFlags = getText (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");
				_splitFlags = _aiAmmoUsageFlags splitString "+";
				// systemchat str _splitFlags;
				{
					_spaceSplit = _x splitString " ";
					if ({_x == "4" || _x == "8"} count _spaceSplit > 0) exitWith {
						_counterWeapon = _weapon;
						_found = true;
						// systemchat str _mag;
					};
				} foreach _splitFlags;
				if (_found) exitWith {};
			} foreach (_magazines select {_x in (_vehicle magazinesTurret _turret)});
			if (_found) exitWith {};
		} foreach _turretWeapons;
		if (_found) exitWith {};
	} foreach (allTurrets _vehicle);

	if (_mode == 0) exitWith {
		_found
	};

	if (_found && {_counterWeapon!= ""}) then {
		[_vehicle, _counterWeapon] call BIS_fnc_fire;
	};
};






//-- order remote fire. currently only grenade launchers, add  AT (attach to vehicle)
A3C_Tank_HE = {
	_tank = _this;
	_mags = getArray (configfile >> "CfgVehicles" >> typeOf _tank >> "Turrets" >> "MainTurret" >> "magazines");
	_chooseMag = "";
	_explosiveMacro = 0;
	{
		_ammo = getText (configfile >> "CfgMagazines" >> _x >> "ammo");
		_effect = getText (configfile >> "CfgAmmo" >> _ammo >> "ExplosionEffects");
		_explosiveMicro = getNumber (configfile >> "CfgAmmo" >> _ammo >> "explosive");
		if (_explosiveMicro > _explosiveMacro) then {
			_chooseMag = _ammo;
		};
	} foreach _mags;
	_chooseMag
};




//-----
//--=== guided projectiles
//-----
A3C_ExactoMISSILE = {
	params ["_unit","_missile","_lock","_target","_target1"];
	//"1" remoteExec ['systemChat',0];
	if !(local _missile) exitWith {};

	// _debug = 
	// [
	// 	(format ["MISSILE OWNER: %1", owner _missile]),
	// 	(format ["TARGET OWNER: %1", owner _target]),
	// 	_unit,
	// 	_missile,
	// 	_lock,
	// 	_target,
	// 	_target1

	// ];

	// (str _debug) remoteExec ["systemChat", 0];
	
	_missile setDir (_missile getDir _target);

	private _ammo = typeOf _missile;
	private _vectorDir = vectorDir _missile;
	private _vectorUp = vectorUp _missile;
	private _posi = getPosASL _missile;

	//-- fetch projectile features
	_vectorDir = vectorDir _missile;
	_vectorUp = vectorUp _missile;
	_posi = getPosASL _missile;

	
	//-- default: use missile max speed
	private _isInf = _unit == driver vehicle _unit;
	_missilespeed = if (_isInf) then {(getNumber (configfile >> "CfgAmmo" >> _ammo >> "maxSpeed")) * 3.6} else {speed _missile}; //(speed _missile) / 1.5; //3.6;
	// _missilespeed = speed _missile;
	//systemchat str (_missilespeed);
	//-- replace projectile
	deletevehicle _missile;
	sleep 0.001; //-- delay so that the new bullet does not damage the turret
	_newProjectile = _ammo createVehicle ((_posi select [0,2]) + [100]);
	_newProjectile setPosASL _posi;
	_newProjectile setVectorDirAndUp [_vectorDir,_vectorUp];

	private _targetPosASL = (getPosASL _target);
	//player setposasl _targetPosASL;
	private _tickTime = time;
	_unit setVariable ["A3C_Replacement_Projectile",_newProjectile,true];

	

	while {alive _newProjectile} do {
		//if (speed _newProjectile <= 0) exitWIth {
		//	_newProjectile setDamage 1;
		//	systemchat 'wup';
		//};
		if (_lock > 0) then {
			//-- update target position for locked ammo
			_targetPosASL = (getPosASL _target);
			//hintSilent str (getPosASL _target);
		};
	//	(format ["PROJECTILE LOOP (%1, %2)", _target, time]) remoteExec ["systemChat", 0];
		//if (_newProjectile distance2D _targetPosASL < 5) exitWith {};
		_vd = _targetPosASL vectorDiff (getPosASL _newProjectile);
		_vd params ["_dX","_dY","_dZ"];
		_d = sqrt(_dx * _dx + _dy * _dy + _dz * _dz);
		_vx = 0;
		_vy = 0;
		_vz = 0;
		if ((_d * _missilespeed) > 0) then {
			_vx = _dx / _d * _missilespeed;
			_vy = _dy / _d * _missilespeed;
			_vz = _dz / _d * _missilespeed;
		};
		_velNew = [_vX,_vY,_vZ];
		
		if !(_isInf) then {
			_tilt_to = [_newProjectile,position _target] call MCSS_fnc_TiltTowardsPos;
			_tilt_to params ["_vDi","_vUp"];
			_newProjectile setVectorDirAndUp [_vDi,_vUp];
		};
		_timePassed = (time - _tickTime);
		_newProjectile setVelocity _velNew;
		if (!(_isInf) && {speed _newProjectile < 1}) exitWith {
			// "EXIT NOINF 1" remoteExec ["systemChat", 0];
			_newProjectile setDamage 1;
			//systemchat str _timePassed;
		};
		if (_timePassed > 10 OR {_newProjectile distance2d _targetPosASL < 5}) exitWith {
			//-- Final nudge towards target - prevents the infamous 'missile dance'
			_tickTime = time;
			// "EXIT TIMEPASSED" remoteExec ["systemChat", 0];
			while {(time - _tickTime) < 2} do {
				// "LOOP TIMEPASSED" remoteExec ["systemChat", 0];
				_newProjectile setVelocity _velNew;
				// (str _velNew) remoteExec ["systemChat", 0];
				
			};
			// "LOOP DONE TIMEPASSED" remoteExec ["systemChat", 0];
		};
	};

	{
		if (!isNull _x) then {
			deleteVehicle _x;
		};
	} foreach [_newProjectile,_target,_target1];
};



A3C_guided_BulletHandler_1 = {
	private ["_var","_target"];
	_veh = _this select 0;
	_weapon = _this select 1;
	_ammo = _this select 4;
	_projectile = _this select 6;

	_var = _veh getvariable "A3C_REMOTE_HANDLE";
	_target = _var select 1;
	if (isNil {_target}) exitWith {};


	//-- fetch projectile features
	_vectorDir = vectorDir _projectile;
	_vectorUp = vectorUp _projectile;
	_posi = getPosASL _projectile;
	//_vel = velocity _projectile;

	// Calculate the velocity vector:
	_missilespeed = (speed _projectile) / 3.6;
	_vd = (getPosASL _target) vectorDiff (getPosASL _veh);
	_vd params ["_dX","_dY","_dZ"];
	_d = sqrt(_dx * _dx + _dy * _dy + _dz * _dz);
	_vx = _dx / _d * _missilespeed;
	_vy = _dy / _d * _missilespeed;
	_vz = _dz / _d * _missilespeed;
	_velNew = [_vX,_vY,_vZ];

	//-- replace projectile
	deletevehicle _projectile;
	sleep 0.001; //-- sleep 0.1 sec so the new bullet does not damage the turret
	_newProjectile = _ammo createVehicle ((_posi select [0,2]) + [100]);
	_newProjectile setPosASL _posi;
	_newProjectile setVectorDirAndUp [_vectorDir,_vectorUp];
	while {alive _newProjectile} do {
		_newProjectile setVelocity _velNew;
	};


	/*
	_length = sqrt((_vel select 0)*(_vel select 0) + (_vel select 1)*(_vel select 1) + (_vel select 2)*(_vel select 2));
	while {alive _newProjectile && alive _target} do
	{
		_dir = getPosATL _newProjectile vectorFromTo (getPosATL _target);
		_vel =  [(_dir select 0) * _length, (_dir select 1) * _length, (_dir select 2) * _length];
		_newProjectile setVelocity _vel;
		sleep 0.1;
	};
	*/
};


A3C_ORDER_REMOTE_LAUNCH = {

	params ["_unit","_targetPos","_weaponGroup"];



	private ["_velo","_unit","_refPos"];
	if (!isDedicated && {!alive player}) exitWith {};


	//if (isPlayer _unit) exitWith {};
	if (_unit in A3C_REMFIRE_UNITS_ACTIVE) exitWith {};
	if (_unit in (A3C_SUPPRESSION_UNITS_SQ + A3C_SUPPRESSION_UNITS_AI)) exitWith {
		systemchat format ["%1 is busy suppressing. Cancel suppression to order remote shots", name _unit];
	};



	_PrimWeap = primaryWeapon _unit;
	_secWeap = secondaryWeapon _unit;
	_primMuzzles = (getarray (configfile >> "CfgWeapons" >> _PrimWeap >> "muzzles"));

	_muzzle = "";
	if (_weaponGroup == "FIND") then {
		_weaponGroup = switch (true) do {
			case ([_unit] call A3C_HasGL) : {"UGLSHOT"};
			case ([_unit] call A3C_HasAT) : {"ATSHOT"};
			case (((vehicle _unit isKindOf "TANK") && {_unit == (gunner vehicle _unit)})) : {"TANKSHOT"};
			case ((count (getArtilleryAmmo [vehicle _unit])) > 0) : {"ARTY"};
			case ([vehicle _unit] call A3C_isStaticMissileLauncher) : {"STATICSHOT"};
			default {"EXIT"};
		};
	};

	A3C_REMFIRE_UNITS_ACTIVE pushBackUnique _unit;
	publicVariable 'A3C_REMFIRE_UNITS_ACTIVE';


	_velo = [0,0,0];
	A3C_HC_FOCUS_ARTY_POS = ASLtoATL _targetPos;
	//-- exit if no mode has ben detected (?)
	if (_weaponGroup == "EXIT") exitwith {};

	_unit setVariable ["A3C_unit_is_Remote_Firing",true,true];

	_dir = _unit getDir _targetPos;
	_refPos = (_unit getRelPos [((_unit distance _targetpos) - 10),_dir]);
	//_counter = 0;
	_delete = true; //-- bool to later delete the target. Can be overridden to false when snapobject turns to target (no additional target will be spawned)

	//-- function to make sure EH is added on correct machine. You are DEFINITELY overcomplicating things here, but this was painful to get to work
	private _addEHFunc = {
		params ["_object","_func","_target","_target1","_snapObject"];
		if !(local _object) exitWith {};
		if (isNil '_func') exitWith {};
		//'fired' remoteExec ["systemChat",0];
		private _handle = _object addEventHandler
		[
			"Fired",
			compile format
			[
				"
					_this spawn %1;
				",
				_func
			]
		];
		
		_object setvariable ["A3C_REMOTE_HANDLE",[_handle,_target,_target1,_snapObject, behaviour _object],true];
		
		//[[2,_object getvariable "A3C_REMOTE_HANDLE"]] spawn {
		//	sleep 2;
		//	(str _this) remoteExec ["systemChat",0];
		//};
		
	};
	private _snapObjectStored = A3C_SNAP_OBJECT;
	//-- default: set remote handle variable to empty array. Scripts will later use this to determine when to shoot safely
	{_x setvariable ["A3C_REMOTE_HANDLE",[],true]} foreach [_unit,vehicle _unit];
	//sleep 1;
//	if (_weaponGroup in ["UGLSHOT","ATSHOT"]) then { //~~ why is this again?
//		[_unit,objnull] remoteExec ["lookAt",_unit];
//		A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
//		publicVariable 'A3C_REMFIRE_UNITS_ACTIVE';
//	};

	_unit disableAI "AUTOTARGET"; //-- prevent unit from firing somewhere else

	switch (_weaponGroup) do {
		case ("STATICSHOT") : {
			if (count magazines (vehicle _unit) > 0) then {
				//-- FIRE STATIC-LAUNCHER
				_lT = switch (true) do {
					case ((side _unit) getfriend WEST < 0.6) : {"LaserTargetW"};
					case ((side _unit) getfriend EAST < 0.6) : {"LaserTargetE"};
					default {"LaserTargetC"};

				};
				_targetPos set [2, (_targetPos select 2) + 0.5];
				private _target = "A3C_Supression_Target_F" createVehicle _targetPos; //
				private _target1 = _lT createVehicleLocal _targetPos;
				[_unit,_target] remoteExec ["doTarget",_unit];
				[_unit,_target] remoteExec ["doWatch",_unit];
				if (_snapObjectStored isKindOf "HOUSE") then {
					_snapObjectStored = objnull;
				};
				private _list = if (!isNull _snapObjectStored) then {
					[_snapObjectStored]
				} else {
					(ASLtoATL _targetPos) nearEntities [["Car","Motorcycle", "Tank","Man","AIR"], 10]
				};

				if (count _list > 0) then {
					private _h = 0; //if ((_list select 0) isKindOf "MAN") then {0.3} else {0};
					{_x attachto [(_list select 0),[0,0,_h]]} foreach [_target,_target1];

				} else {
					{
						_x setposASL _targetPos;
						_x enablesimulation false;
					} foreach [_target,_target1];
				};

				private _handlerFunc = {
					params ["_unit"];
					private ["_var","_missileSpeed","_act"];
					private _ammoType = _this select 4;
					private _missile = (_this select 6);
					private _var = _unit getvariable "A3C_REMOTE_HANDLE";
					_var params ["_handle","_target","_target1","_snapObject","_behaviour"];

					if (isNull _missile) then {
						_missile = (nearestObject [position _unit,_ammoType]);
					};
					_unit removeEventHandler ["Fired",_handle];
					_unit setVariable ["A3C_unit_is_Remote_Firing",false,true];
					private _lock = getNumber (configfile >> "CfgAmmo" >> (_this select 4) >> "weaponLockSystem");
					//-- wait until unit has reloaded or other

					private _weaponType = if (_unit isKindOf "STATICWEAPON") then {
						(getArray (configfile >> "CfgVehicles" >> typeof _unit >> "Turrets" >> "MainTurret" >> "weapons")) select 0
					} else {
						(weapons _unit) select 0
					};
					
					private _reloadTime = getNumber (configfile >> "CfgWeapons" >> _weaponType >> "magazinereloadTime");

					//-- spawn loop to wait for reload time. Does not matter if unit is out of ammo. Has to run in parallel so missile flight path can be calculated as well.
					[gunner _unit,_reloadTime] spawn {
						params ["_gunner","_reloadTime"];
						private _timer = time;
						while {alive _gunner} do {
							if (time > _timer + _reloadTime) exitWith {};
							sleep 1;
						};
						A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_gunner];
						publicVariable 'A3C_REMFIRE_UNITS_ACTIVE';
					};

					sleep 0.001;
					//(str ['isServer',isServer])  remoteExec ["systemchat",0];
					[_unit,_missile,_lock,_target,_target1] spawn A3C_ExactoMISSILE;
				};


				while {alive _unit} do {
					_unit doWatch _target;
					if ([position _target, vehicle _unit,10] call MCSS_fnc_LOS_Vehicle) exitWith {};
					sleep 1;
				};
				[(vehicle _unit),_handlerFunc,_target,_target1,_snapObjectStored] call _addEHFunc;
				sleep 2;
				if (!isNull _unit && {alive _unit}) then {
					waitUntil {count ((vehicle _unit) getvariable ["A3C_REMOTE_HANDLE",[]]) > 0};
					(vehicle _unit) fireAtTarget [objNull];
				} else {
					//-- gunner is no more - remove EH
					//(vehicle _unit) removeEventHandler ["FIRED",_handle];
					_var = (vehicle _unit) getvariable "A3C_REMOTE_HANDLE";
					(vehicle _unit) removeEventHandler ["Fired",_var select 0];
				};
			} else {
				systemchat "A3C: Static weapon is out of ammo!";
			};
		};
		case ("ARTY") : {
			A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
			publicVariable 'A3C_REMFIRE_UNITS_ACTIVE';
			with uiNamespace do {
				//disableSerialization;
				A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
			};
			["ARTY"] call A3C_OPEN_OBJECTSELECTOR_MAP;
		};
		case ("TANKSHOT") : {

			_tankTarget = objNull;
			//if (isnull _snapObjectStored) then {
				_tankTarget =  "A3C_Supression_Target_F" createVehicle (ASLtoATL _targetPos); //  "Land_Radar_Small_F"
				_targetPos set [2,(_targetPos select 2) - 0.5];
				_tankTarget setPosASL _targetPos;
			//} else {
				if ({_snapObjectStored iskindof _x} count ["TANK","CAR"] > 0) then {
					[_tankTarget,_snapObjectStored] remoteExec ["disableCollisionWith",_tankTarget];
					[_snapObjectStored, _tankTarget] remoteExec ["disableCollisionWith",_snapObjectStored];
					_tankTarget attachTo [_snapObjectStored,[0,0,0]];
					//_tankTarget = _snapObjectStored;
					//_targetPos = getPosASL _snapObjectStored;
					//_delete = false;
					//_tankTarget AttachTo [_snapObjectStored,[0,0,0.5]];
				};
			//	} else {
			//		_tankTarget = "A3C_Supression_Target_F" createVehicle (ASLtoATL _targetPos);
			//		_targetPos set [2,(_targetPos select 2) + 0.5];
			//	};
			//};
			_tankTarget enableSimulation false;
			//if (_delete) then {
			//	_tankTarget setPosASL _targetPos;
				//_tankTarget enableSimulation false;
			//};
			//_targetPos = ASLtoATL _targetPos;
			private _tank = vehicle _unit;
			//[_unit,_targetPos] remoteExec ["lookAt",_unit];
			[_unit,_tankTarget] remoteExec ["lookAt",_unit];
			[_unit,_tankTarget] remoteExec ["doTarget",_unit];
			private _counter = 0;
			while {alive _tank} do {
				if (_tank aimedattarget [_tankTarget] == 1) exitwith {sleep 3};
				if ([getPosATL _tankTarget, _unit] call MCSS_fnc_LOS_Vehicle) exitWith {sleep 3};
				if (_counter >= 100) exitwith {};
				sleep 0.1;
				_counter = _counter + 1;
			};
			if (_counter < 100) then {
				private _handlerFunc = {
					private _tank = _this select 0;
					private _ammo = _this select 4;
					private _projectile = _this select 6;
					private _effect = getText (configfile >> "CfgAmmo" >> _ammo >> "ExplosionEffects");
					private _var = _tank getvariable "A3C_REMOTE_HANDLE";

					_var params ["_handle","_target","_newMag","_snapObject","_behaviour"];
					_tank removeEventHandler ["Fired", _handle];
					(gunner _tank) setVariable ["A3C_unit_is_Remote_Firing",false,true];

					private _magType = _ammo;
					if (_newMag != "") then {
						if (!(_effect == "ExplosionEffects") && ({_snapObject iskindof _x} count ["TANK","CAR"] == 0)) then {
							_magType = _newMag;
						};
					};
					_guideFnc = {
						params ["_projectile","_magType","_target"];
						if (!local _projectile) exitWith {};
						//sleep 0.001;
						private _vectorDir = vectorDir _projectile;
						private _vectorUp = vectorUp _projectile;
						private _posi = getPosASL _projectile;
						private _vel = velocity _projectile;
						deletevehicle _projectile;
						private _newProjectile = _magType createVehicle _posi;
						_newProjectile setVectorDirAndUp [_vectorDir,_vectorUp];
						_newProjectile setPosASL _posi;
						_newProjectile setVelocity _vel;

						//str [_magType] remoteExec ["systemchat",0];


						private _length = sqrt((_vel select 0)*(_vel select 0) + (_vel select 1)*(_vel select 1) + (_vel select 2)*(_vel select 2));
						//_timer = time;
						//while {time < _timer + 10} do
						//[commandant,false] remoteExec ["allowdamage",commandant];
						while {alive _newProjectile && alive _target} do
						{
							private _tPos = (getPosATL _target);
							//commandant setpos position _target;
							private _dir = (getPosATL _newProjectile) vectorFromTo _tPos;
							private _vel =  [(_dir select 0) * _length, (_dir select 1) * _length, (_dir select 2) * _length];
							_newProjectile setVelocity _vel;
							sleep 0.1;
						};
						//str [alive _newProjectile] remoteExec ["systemchat",0];
						deletevehicle _target;
					};
					//sleep 1; //aaa
					[_tank,_projectile,0,_target,_target] spawn A3C_ExactoMISSILE;
					
					
					//[[_projectile,_magType,_target],_guideFnc] remoteExec ["bis_fnc_spawn",0];
				};
				 [_tank,_handlerFunc,_tankTarget,_tank call A3C_Tank_HE, _snapObjectStored] call _addEHFunc;
				waitUntil {count (_tank getvariable ["A3C_REMOTE_HANDLE",[]]) > 0};
				[_tank,["UseWeapon", _tank, _unit, 0]] remoteExec ["action",_tank];
				sleep (2 + (random 2));
			};
			sleep 1;
			if (_delete) then {
				deleteVehicle _tankTarget;
			};
			[_unit,objnull] remoteExec ["lookAt",_unit];
			A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
			publicVariable 'A3C_REMFIRE_UNITS_ACTIVE';

		};
		case ("ATSHOT") : {
			//-- FIRE AT-LAUNCHER

			_lT = switch (true) do {
				case ((side _unit) getfriend WEST < 0.6) : {"LaserTargetW"};
				case ((side _unit) getfriend EAST < 0.6) : {"LaserTargetE"};
				default {"LaserTargetC"};

			};
			//_targetPos set [2, (_targetPos select 2) + 0.5];
			private _target = "A3C_Invisible_Man_F" createVehicleLocal [0,0,0]; // "C_MAN_1"    "A3C_Supression_Target_F"  "O_TargetSoldier"
			//createVehicleCrew _target;  
			//_target hideObject true;
			private _target1 = _lT createVehicle _targetPos;
			_target enablesimulation false;

			_target setPosASL _targetPos;
			

			if (_snapObjectStored isKindOf "HOUSE") then {
				_snapObjectStored = objnull;
			};
			private _list = if (!isNull _snapObjectStored) then {
				[_snapObjectStored]
			} else {
				(ASLtoATL _targetPos) nearEntities [["Car","Motorcycle", "Tank","Man","AIR"], 10]
			};

			_unit doTarget _target;
			_unit lookAt _target;
			_unit reveal [_target,4];
			sleep 1;
			if (count _list > 0) then {
				private _h = 0;
				{_x attachto [(_list select 0),[0,0,_h]]} foreach [_target,_target1];
			} else {
				{
					_x setposASL _targetPos;
					_x enablesimulation false;
				} foreach [_target,_target1];
			};

			[_unit] call A3C_UNIT_STORE_DESTINATION;
			_unitPos = (position vehicle _unit);
			_unit doMove _unitPos;
			_unit moveTo _unitPos;
			{_unit disableAI _x} foreach ["MOVE","PATH"];
			sleep 2;

			private _setDir = (_unit modeltoworld (_unit selectionposition "lefthand")) getDir _targetPos;
			_unit setDir _setDir;
			private _wm = (getArray (configFile >> "CfgWeapons" >> secondaryWeapon _unit >> "modes")) select 0;
			if (_wm == "this") then {_wm = secondaryWeapon _unit};
			_unit forceWeaponFire [(secondaryweapon _unit), _wm]; //-- make unit select launcher
			sleep 2;
			_unit disableAI "ANIM";
			_unit doTarget _target;
			_unit setVariable ["A3C_PAUSE_PLAN",true,true];

			private _handlerFunc = {
				params ["_unit"];
				private _missile = (_this select 6);
				
				private _var = _unit getvariable ["A3C_REMOTE_HANDLE",[]];
				//(str [3,_var]) remoteExec ["systemChat",0];
				if (count _var == 0) exitWith {};
				_var params ["_handle","_target","_target1","_snapObject","_behaviour"];
				
				_unit removeEventHandler ["Fired",_handle];
				_unit setVariable ["A3C_unit_is_Remote_Firing",false,true];
				private _lock = getNumber (configfile >> "CfgAmmo" >> (_this select 4) >> "weaponLockSystem");
				A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
				publicvariable 'A3C_REMFIRE_UNITS_ACTIVE';
				[_unit] call A3C_UNIT_RESUME_DESTINATION;
				
				[_unit,_missile,_lock] spawn {
					//-- parallel: make sure unit behaviour is correct
					params ["_unit","_missile","_lock"];
					
					private _carriedMissiles = [];
					if (_lock > 0) then {
						//"test" remoteExec ["systemchat",0];
						//-- weapon can lock, meaning we want the unit to hold his weapon up until he's really done
						//-- first, we freeze him, or he will get excited and reload immediately - but we want him to preted he's guiding the mission.
						//[_unit,false] remoteExec ["enableSimulation",_unit];
						//-- we also add a HandleDamage-EH because if he gets killed the aesthtic messup is kinda tolerable
						_hitHandle = _unit addEventHandler
						[
							"HandleDamage",
							{
								_unit = _this select 0;
								_damage = _this select 2;

								if ((damage _unit) + _damage >= 0.9) then {
									[_unit] spawn {
										params ["_unit"];
										sleep 1;
										_unit setDamage 1;
									};
									_damage = 0;
								};
								_damage

							}
						];
						_unit setVariable ["A3C_Hit_Handler",_hithandle,true];
						_unit setvariable ["A3C_Hit_Value",damage _unit,true];
						_launcherAmmo = getArray (configfile >> "CfgWeapons" >> secondaryWeapon _unit >> "magazines");
						waitUntil {!isNull (_unit getVariable ["A3C_Replacement_Projectile",objNull])};
						_newMissile = (_unit getVariable ["A3C_Replacement_Projectile",objNull]);
						//-- now we wait until the missile has detonated
						waitUntil {!alive _newMissile};
						//-- he was a good boy and may move again

						//-- remove EH again
						_unit removeEventHandler ["HandleDamage",_hitHandle];
					};
					{_unit enableAI _x} foreach ["MOVE","PATH","ANIM"];
					_unit setVariable ["A3C_Replacement_Projectile",objNull,true];
				};
				//-- guide the missile to it's target
				[_unit,_missile,_lock,_target,_target1] spawn A3C_ExactoMISSILE;
			};
			[_unit,_handlerFunc,_target,_target1,_snapObjectStored] call _addEHFunc;
			sleep 2;
			waitUntil {count (_unit getvariable ["A3C_REMOTE_HANDLE",[]]) > 0};
			_vari = _unit getvariable ["A3C_REMOTE_HANDLE",[]];
			_vari params ["_handle","_targett","_target1","_snapObject","_behaviour"];
			_unit forceWeaponFire [(secondaryweapon _unit), _wm];
		};
		case ("UGLSHOT") : {
			//-- FIRE GL-LAUNCHER
			_muzzle = _primMuzzles select 1;
			_target = "A3C_Supression_Target_F"   createVehicle [0,0,0]; // "A3C_Supression_Target_F"    "B_SOLDIER_F"  
			//[_target,true] remoteExec ["hideObjectGlobal",2];

			sleep 1;
			
			//_unit playMoveNow "amovpercmstpsraswrfldnon";

			
			//_unit disableAI "ANIM";
			_target setposASL _targetPos;
			_unit reveal [_target,4];
			_unit doTarget _target;
			_unit doWatch _target;
			_unit lookAt _target;

			

			
			//(units player select 1) forceWeaponFire ["GL_3GL_F","Single"]
			
			sleep 2;
			for "_i" from 0 to 80 do {
				_unit doTarget _target;
				if !(alive _unit) exitwith {};
				
				if ([_unit,_target] call MCSS_fnc_LOF) exitwith {
					//systemchat "yeppi";
					_unit setVariable ["A3C_PAUSE_PLAN",true,true];

					_unit setDir (_unit getDir (getPosASL _target));

					//sleep 1;
					_refPos = (ASLtoATL _targetPos);
					if ((_refPos select 2) > 2) then {
						_refPos = [_refPos,15,_dir] call BIS_fnc_RelPos;
					};
					_velo = [_unit,_refPos,300,1] call A3C_THROW_VEL;
					_unit setvariable ["A3C_GRENADE_VEL",_velo,true];
					private _handlerFunc = {
						private _shooter = _this select 0;
						private _projectile = (_this select 6);
						private _var = _shooter getvariable "A3C_REMOTE_HANDLE";
						_var params ["_handle","_target","_target1","_snapObject","_behaviour"];
						A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_shooter];
						publicVariable 'A3C_REMFIRE_UNITS_ACTIVE';
						_shooter setVariable ["A3C_PAUSE_PLAN",false,true];
						private _vel = _shooter getvariable ["A3C_GRENADE_VEL",velocity _projectile];
						if (_this select 2 == ((getarray (configfile >> "CfgWeapons" >> primaryWeapon _shooter >> "muzzles")) select 1)  ) then {
							_projectile setVelocity _vel;
						};
						_shooter removeEventHandler ["Fired",_handle];
						_shooter setVariable ["A3C_unit_is_Remote_Firing",false,true];
						_shooter enableAI "ANIM";
						sleep 1;
						//systemchat str _behaviour;
						[_shooter,["BEHAVIOUR",_behaviour]] call MCSS_fnc_orderIndividual;
					};
					[_unit,_handlerFunc,objNull,objNull,_snapObjectStored] call _addEHFunc;
					
					

					

					waitUntil {count (_unit getvariable ["A3C_REMOTE_HANDLE",[]]) > 0};
					[_unit,["BEHAVIOUR","COMBAT"]] call MCSS_fnc_orderIndividual;
					sleep 1;

					//_var = _unit getvariable ["A3C_REMOTE_HANDLE",[],true];
					//if !(_var isEqualTo []) then {
					//	systemchat 'goes';
					//	_var set [count _var, behaviour _unit];
					//	_unit setvariable ["A3C_REMOTE_HANDLE",_var,true];
					//};
					_unit forceWeaponFire [_muzzle,"Single"]
				};
				sleep 0.1;
			};
			hintsilent "";
			deletevehicle _target;
			_unit doTarget objNull;
			_unit doWatch objNull;
			_unit lookAt objNull;

		};

	};


	if (_weaponGroup in ["UGLSHOT","ATSHOT"]) then {
		//-- security: if unit does not fire within 10sec
		for "_i" from 1 to 10 do {
			sleep 1;
			if !(_unit in A3C_REMFIRE_UNITS_ACTIVE) exitWith {};
			if (_i == 10) exitWith {
				_var = _unit getvariable "A3C_REMOTE_HANDLE";
				_unit removeEventHandler ["Fired",_var select 0];
				_unit setVariable ["A3C_unit_is_Remote_Firing",false,true];
				{_unit enableAI _x} foreach ["MOVE","PATH","ANIM"];
				_unit setVariable ["A3C_PAUSE_PLAN",false,true];
				_unit setVariable ["A3C_unit_is_Remote_Firing",false,true];
				A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
				publicVariable 'A3C_REMFIRE_UNITS_ACTIVE';
			};
		};
	};
	_unit enableAI "AUTOTARGET";
};



A3C_ArtilleryOrder_Map_Setup = {
	
};



/*

A3C_guided_BulletHandler = {
	private ["_var","_target"];
	_veh = _this select 0;
	_weapon = _this select 1;
	_ammo = _this select 4;
	_projectile = _this select 6;

	_var = _veh getvariable "A3C_REMOTE_HANDLE";
	_target = _var select 1;
	if (isNil {_target}) exitWith {};

	_vel = velocity _projectile;
	_length = sqrt((_vel select 0)*(_vel select 0) + (_vel select 1)*(_vel select 1) + (_vel select 2)*(_vel select 2));
	while {alive _projectile && alive _target} do
	{
		_dir = getPosATL _projectile vectorFromTo (getPosATL _target);
		_vel =  [(_dir select 0) * _length, (_dir select 1) * _length, (_dir select 2) * _length];
		_projectile setVelocity _vel;
		sleep 0.1;
	};
};
A3C_ExactoMISSILE1 = {
	params ["_unit","_missile","_lock","_target","_target1"];

	//(str _this) remoteExec ["systemchat",0];
	if !(local _missile) exitWith {};

	_missile setDir (_missile getDir _target);
	private _missileSpeed = (speed _missile);
	private _act = true;
	private _c = 0;
	private _sleep = if (_lock == 0) then {0.1} else {0.2};
	private _maxCycles = if (_lock == 0) then {40} else {20};

	private _ammo = typeOf _missile;
	private _vel = velocity _missile;
	private _vectorDir = vectorDir _missile;
	private _vectorUp = vectorUp _missile;
	private _posi = getPosASL _missile;


	//systemchat str (_ammo == (typeOf _projectile));


	sleep 0.001; //-- sleep 0.1 sec so the new bullet does not damage the turret
	deletevehicle _missile;
	private _newProjectile = _ammo createVehicle ((_posi select [0,2]) + [100]);
	_newProjectile setPosASL _posi;
	_newProjectile setVectorDirAndUp [_vectorDir,_vectorUp];
	_newProjectile setVelocity _vel;
	_unit setVariable ["A3C_Replacement_Projectile",_newProjectile,true];

	//str _ammo remoteExec ["systemchat",0];
	while {alive _newProjectile} do {
		_travelTime = (_target distance _newProjectile) / ((_missileSpeed max 150) min 150);
		_velocityX = (((getPosASL _target) select 0) - ((getPosASL _newProjectile) select 0)) / _travelTime;
		_velocityY = (((getPosASL _target) select 1) - ((getPosASL _newProjectile) select 1)) / _travelTime;
		_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _newProjectile) select 2)) / _travelTime;
		_newProjectile setvelocity [_velocityX,_velocityY,_velocityZ];
		//str [getPosATL _newProjectile] remoteExec ["systemchat",0];
		if (_lock == 0 && {_act}) then {
			_act = false;
			{detach _x} foreach [_target,_target1];
		};

		if (_lock == 0 && {_c > _maxCycles}) exitWith {};
		_c = _c + 1;
		sleep _sleep;
	};
	sleep 1;
	{deletevehicle _x} foreach [_target,_target1];
};





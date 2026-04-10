


private _whPos = (position player) getPos [5, getDir player];



// create weapon holder
private _wh = createVehicle ["GroundWeaponHolder", _whPos, [], 0, "CAN_COLLIDE"];

// add weapons
_wh addWeaponCargoGlobal ["arifle_MX_F", 1];
_wh addWeaponCargoGlobal ["hgun_P07_F", 1];

// add magazines
_wh addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 6];
_wh addMagazineCargoGlobal ["16Rnd_9x21_Mag", 3];

// optional: add some items
_wh addItemCargoGlobal ["FirstAidKit", 2];
_wh addItemCargoGlobal ["optic_Hamr", 1];


_whPos = _whPos getPos [10, (getDir player) + 90];
private _gp = createGroup WEST;
private _unit = _gp createUnit [typeOf player, _whPos, [], 0, "NONE"];
_unit setDamage 1;

if (true) exitWith {};




_playerGroup = group player;
_unit = (units _playerGroup) select 3;
_vehicle = truck1;

_gpTemp = createGroup (side player);
[player] joinSilent _gpTemp;

_unit assignAsCargo _vehicle;
[_unit] orderGetIn true;
sleep 0.7;
[player] joinSilent _playerGroup;
_playerGroup selectLeader player;
deleteGroup _gpTemp;



if (true) exitWith {};
_repairPatient = cursortarget;

private _visualRepairStrings = ["hull", "glass", "track", "wheel", "engine", "turret", "gun", "light", "body"];
private _hitPointDamage = getAllHitPointsDamage _repairPatient;
_hitPointDamage params ['_hpNames', '_hpValues'];
{
	private _hitPointNameLower = toLower _x;
	private _fi = _forEachIndex;
	if ({_x in _hitPointNameLower} count _visualRepairStrings == 0) then {
		_repairPatient setHitPointDamage [_x, 0];
	};
} forEach _hpNames;





if (true) exitWith {};

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
						systemchat str _mag;
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



[cursorTarget, 1] call A3C_FireCounterMeasures;




if (true) exitWith {};

 player setpos [14789.2,16534.4,0.00143814]; 
 
 wp1 = gp1 addWaypoint [leader gp1 getpos [50,90],0];
 
 sleep 5;
 
 [group cursortarget,currentWaypoint group cursortarget]; 
 wp1 setWaypointPosition [position player,0]; 
 sleep 1;
 [group cursortarget,currentWaypoint group cursortarget] call A3C_BEHAVIOUR_HC_MoveToWayPointPosition;


if (true) exitWith {};

if (!isNil 'EH') then {
	player removeEventHandler ["Fired",EH];
};
EH = player addEventHandler 
[
	"Fired",
	{
		

		private _reloadTime = getNumber (configFile >> "CfgWeapons" >> "Throw" >> _muzzle >> "magazineReloadTime");  
		systemchat str [_muzzle,_ammo,_reloadTime];
	}
];

if (true) exitWith {};
if (isNil 'arrow') then {
	 arrow = "B_SOLDIER_F" createVehicle [0,0,0]; 
	 arrow enableSimulation false;
};

onEachFrame {
	_ins = lineIntersectsSurfaces
	[ 
		AGLToASL positionCameraToWorld [0,0,0],  
		AGLToASL positionCameraToWorld [0,0,1000],  
		player, arrow 
	]; 
	if (count _ins == 0) exitWith {arrow setPosASL [0,0,0]};
	_insPos = (_ins select 0 select 0); 
	arrow setPosASL _insPos;
	_object = (_ins select 0 select 2);
	_normal =  (_ins select 0 select 1);
	//arrow setVectorDir (vectorDir _object);
	arrow setVectorUp _normal;
	//arrow setVectorDirAndUp [(vectorDir _object),_normal];
	_vd = vectorDir arrow;
	_vda = 0;
	if ((_vd select 1) != 0) then {
		_vda = atan( (_vd select 0) / (_vd select 1)); 
	};
	//copytoclipboard str _normal;
	for "_i" from 0 to 2 do {
		_normal set [_i,if (_normal select _i == 0) then {0} else {[_normal select _i,2] call BIS_fnc_cutDecimals}];
	};
	_dir = [0,0] getDir (_normal select [0,2]);
	hintSilent format
	[
		"DIR-AZM BUILDING:         %1      
		                                             NORMAL:     %2
		                                             AZM from NORMAL:      %3
	
		",
		getDir _object,
		_normal,
		_dir	
	];
	ball setposASL ([_insPos,2,_dir] call BIS_fnc_RelPos);  
};
//_ins select 0 select 1,
if (true) exitWith {};

[cursorTarget] call MCSS_fnc_getRealBoundingBox;

if (true) exitWith {};

//str (lineIntersectsObjs [eyepos player, eyepos edude, pDlayer, edude])




fnc1 = {_center = position player; _terrainObjects = nearestTerrainObjects [_center, ["ROCK"], 30];};
["[] call fnc1"] call BIS_fnc_codePerformance;
if (true) exitwith {};


{deletevehicle _x} foreach (units bdg);
deletegroup bdg;
sleep 2;
bdg = creategroup WEST;

for "_i" from 1 to 4 do {
	_unit = bdg createUnit ["B_SOLDIER_F", [3739.58,13423.4,0.00144768], [], 0, "FORM"];
};

_p = [3725.81,13433.7,0.628233]; 
wp1 = bdg addwaypoint [_p,0]; 
wp1 setwaypointType "SCRIPTED"; 
wp1 setWaypointScript "A3C_CORE\fnc_AI\wpFncs\wpScript_CLEARBUILDING.sqf";


if (true) exitWith {};


_fnc1 = {systemchat "1"; false};
_fnc2 = {systemchat "2"; true};
_fnc3 = {systemchat "3"; true};
_fnc4 = {systemchat "4"; false};
_fnc5 = {systemchat "5"; true};

switch (true) do {
	case ([] call _fnc1) : {};
	case ([] call _fnc2) : {};
	case ([] call _fnc3) : {};
	case ([] call _fnc4) : {};
	case ([] call _fnc5) : {};
	default {systemchat "hmm"};	
};



if (true) exitwith {};

sleep 3;

_refControl = findDisplay 6998 displayctrl 10;

{
	_pos = ctrlPosition (findDisplay 12 displayctrl 1020); // _x; //
	_refControl ctrlSetPosition _pos;
	_refControl ctrlCommit 0;
	systemchat str _x;
	sleep 2;
	
} foreach (allcontrols (findDisplay 12));


if (true) exitWith {};

//1200, 

for "_i" from 1 to 18 do {
	(gunner bf1) fireAtTarget [bf1, weapons bf1 select 3];
	systemchat "fire";
	sleep 0.1;
};



if (true) exitwith {};




_vehicle = bf1;


			_vehicleDefaultMags = (getArray (configfile >> "CfgVehicles" >> typeof _vehicle >> "magazines"));
			_turretMags = [];
			_turrets = "true" configClasses (configfile >> "CfgVehicles" >> typeof _vehicle >> "Turrets");
			{
				_turretMags = _turretMags + (getArray (configfile >> "CfgVehicles" >> typeof _vehicle >> "Turrets" >> (configName _x) >> "magazines"));
			} foreach _turrets;
			_vehicleDefaultMags = _vehicleDefaultMags  + _turretMags;
				
				
			_vehicleDefaultMags = _vehicleDefaultMags + (getPylonMagazines _vehicle);	
			_currentVehicleMags = (magazinesAmmoFull _vehicle);
			_percentages = [];
			systemchat str [count _vehicleDefaultMags, count _currentVehicleMags];
			{
				_x params ["_magName","_ammoCount"];
				private _ammoCountFullMag = getNumber (configfile >> "CfgMagazines" >> _magName >> "count");
				_percentage = if (_ammoCount > 0) then {_ammoCount / _ammoCountFullMag} else {0};
				systemchat str [_magName, _percentage ];
				_vehicleDefaultMags = _vehicleDefaultMags - [_magName];
				_currentVehicleMags =  _currentVehicleMags - [_x];
				_percentages pushBack _percentage;
			} foreach _currentVehicleMags;

			_finalPercentage = 0;
			{_finalPercentage = _finalPercentage + _x} foreach _percentages;
			_finalPercentage = if (count _percentages > 0) then {_finalPercentage / count _percentages;} else {0};
			
			systemchat str [[count _percentages],_finalPercentage,count _currentVehicleMags, count _vehicleDefaultMags];
			


if (true) exitWith {};

//setdate [2035,12,31,6,21];


// (linearConversion [RYD_HAS_EF_t1, RYD_HAS_EF_t2, time, 0, 1])


/*
if (true) exitWith {};



	
	if (true) exitWith {};



//	_gunner fireattarget [_target,"rhs_weap_AGM114L_Launcher"];

[] spawn {
	_enemyVehicle = t1;
	_heli = bf1;
	_gunner = gunner bf1;
	_targetType = if (((side _heli) getFriend west) > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
	_target = createvehicle [_targetType,_enemyVehicle,[],0,"CAN_COLLIDE"];
	_target attachTo [_enemyVehicle,[0,0,0]];
	{_x doTarget _target} foreach [_heli,_gunner];
	sleep 1;
	_gunner fireattarget [_target,"missiles_DAGR"];
};


[] spawn {
	_enemyVehicle = t1;
	_heli = bf2;
	_gunner = gunner bf2;
	_targetType = if (((side _heli) getFriend west) > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
	_target = createvehicle [_targetType,_enemyVehicle,[],0,"CAN_COLLIDE"];
	_target attachTo [_enemyVehicle,[0,0,0]];
	{_x doTarget _target} foreach [_heli,_gunner];
	sleep 1;
	_gunner fireattarget [_target,"rhs_weap_AGM114L_Launcher"];
};


_fnc_CfgVehicleWeapons = {
	params ["_class"];
	private _weapons = (getArray (configfile >> "CfgVehicles" >> "B_QuadBike_01_F" >> "weapons")) select {!("horn" in toLower _x)};
	_turrets = "true" configClasses (configfile >> "CfgVehicles" >> _class >> "Turrets");
			
	{
		_turretWeapons = getArray (configfile >> "CfgVehicles" >> _class >> "Turrets" >> (configName _x) >> "weapons");
		_weapons = _weapons + _turretWeapons;
	} foreach _turrets;
	_weapons
};

//
//-- magamount not really necessary?

BULLET_CAM = {
	params ["_projectile"];
	setacctime 0.5;
	_cam = "camera" camcreate [0,0,0];

	while {!isNull _projectile && {!alive _projectile}} do {
		_cam cameraeffect ["internal", "back"];

		_cam camsettarget _projectile;

		_cam camsetrelpos [ 3, -6, 10];


		_cam camcommit 0;


		_cam camsettarget Car;
		_cam camcommit 0;

		sleep 0.01;
	};

	



	_cam cameraEffect ["terminate","back"];
	camDestroy _cam;

	setAcctime 1;
};

*/

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





private _vehicle = bf1;
private _weapons = weapons _vehicle;
private _gunner = gunner _vehicle;
private _weapon = "missiles_DAGR";


private _weaponAmmo = [];
private _updateWeaponAmmo = true;

_vehicle disableAI "PATH";

_vehicle setVariable ["A3C_Replacement_Projectile",nil,true];

private _handle = _vehicle addEventHandler
[
	"FIRED",
	{
		params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
		_data = _vehicle getVariable ["A3C_fireComplete",["",false]];
		_data params ["_assignedWeapon","_isComplete"];
		private _missiletarget =  assignedTarget _gunner;
		//[_projectile] spawn BULLET_CAM;
		

		if (_weapon == _assignedWeapon) then {
			[_vehicle,_weapon,_projectile,_missiletarget] spawn {
				params ["_vehicle","_weapon","_projectile","_missiletarget"];
				//if (speed _missiletarget > 0 OR {"rhs_" in toLower _weapon}) then {
				if (true) then {
					sleep 1;
					//systemchat 'exacto';
					_vehicle setVariable ["A3C_fireComplete",[_weapon,true,true]]; //!!!!!!!!!!!!!!!!!!!!!
					[[_vehicle,_projectile,2,_missiletarget,_missiletarget],A3C_ExactoMISSILE] remoteExec ["bis_fnc_spawn",0];
				} else {
					waitUntil {isNull _projectile Or {!alive _projectile}};
				};
				
				_vehicle setVariable ["A3C_fireComplete",[_weapon,true,true]];
				
			};

		};
	}
];





//_gunner setCombatMode "BLUE"; //-- DEBUG ONLY

while {canmove _vehicle} do {
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
	//systemchat str _weaponAmmo;
//systemchat str ((_availableWeapons select 0) select 0);
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
				//hintsilent str _maxRangeGround;
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
						_armor * _canTargetAir
					},
					"DESCEND"
				] call BIS_fnc_sortBy; //-- heaviest vehicle first
			//	systemchat str _availableWeapons;
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
				//player setPosASL _startPos;
				if (count _ins > 0) then {
					//systemchat '1';
					(_ins select 0) params ["_intsPos","_irrellevant","_intsObj"];
					//systemchat str _intsObj;
					if (_intsObj == _enemyVehicle) then {
						_activeTarget setposASL _intsPos;
						_attachArray = _enemyVehicle worldToModel (ASLtoATL _intsPos);
					} ;
				};

				
				_activeTarget attachTo [_enemyVehicle,_attachArray];

				
				_updateWeaponAmmo = true;
			//} else {
				//systemchat "no entities left"; //~~ REMOVE THIS, ONLY DEBUG
			};
		};
		if (_weapon != "") then {
			//_gunner setCombatMode "BLUE";

			_doFire = {
				params ["_gunner","_vehicle","_activeTarget","_weapon","_enemyVehicle"];
				
				_gunner forgetTarget (assignedtarget _gunner);
				_gunner doTarget objNull;
				_gunner reveal [_activeTarget,4];
				_gunner lookAt _activeTarget;
				_vehicle setVariable ["A3C_fireComplete",[_weapon,false,true]];
				{_x doWatch _activeTarget; _x lookat _activeTarget; _x doTarget _activeTarget} foreach [_gunner,_vehicle];
				if (_enemyVehicle isKindOf "AIR") then {
					{_x doFire _activeTarget} foreach [_gunner,_vehicle];
				};
			};
			

			
			_orientPos = _vehicle getPos [1000, _vehicle getDIr _activeTarget]; _vehicle domove _orientPos; 

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
				
				if (_activeTarget isKindOf "AIR") then {
					[_gunner,_vehicle,_activeTarget,_weapon,_enemyVehicle] call _doFire;
					sleep 5;
				} else {


					//_camdata = ["Altis",[18527.5,13747,356.745],102.983,0.75,[-14.5739,0],0,0,775.196,0,0,1,0,1];
					//["Paste",_camdata] call BIS_fnc_camera; 
					//["Paste",["Altis",getPosATL bf1 vectorAdd [-20,-20,0],102.983,0.75,[-14.5739,0],0,0,775.196,0,0,1,0,1]] call BIS_fnc_camera;
					
					//-- save / generate vectors
					if (false) then { //-- doing this because I do not want to lose the fnc
						_aslPos = getPosASL _vehicle;
					
						_initVectorDir = vectorDir _vehicle;
						_initVectorUp = vectorUp _vehicle;

						_tilt = [_vehicle,position _activeTarget] call MCSS_fnc_TiltTowardsPos;
						_tilt params ["_newVectorDir","_newVectorUp"];
						_vehicle selectWeapon _weapon;


						//{_x disableAI "AUTOTARGET"} foreach [_vehicle,_gunner];

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
					};
					
					
					
					[_gunner,_vehicle,_activeTarget,_weapon,_enemyVehicle] call _doFire;

					
					sleep 1;


					_gunner setCombatMode "YELLOW";
					_gunner fireattarget [_vehicle,_weapon];
					//systemchat str ["FIRE", _weapon,typeOf _enemyVehicle, typeOf _activeTarget, assignedTarget _gunner];
					waituntil {(_vehicle getVariable ["A3C_fireComplete",["",true]]) select 1};
					sleep 0.5;
					_m = _vehicle getVariable ["A3C_Replacement_Projectile",objNull];
					//systemchat str [_m];
					waituntil {isNull _m OR {!alive _m}};
					//systemchat "cont";
					_vehicle setVariable ["A3C_Replacement_Projectile",nil,true];
					[format ["A3C_EH_TILT_%1",str _vehicle], "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
					//{_x enableAI "AUTOTARGET"} foreach [_vehicle,_gunner];
					if (false) then {
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
	//sleep 1;

};
_vehicle setVariable ["A3C_fireComplete",nil,true];
_vehicle removeEventHandler ["FIRED",_handle];

if (true) exitWith {};
/*00
	



//ammo = "M_PG_AT";
//ammo = "RHS_ammo_AGM_114K";




//




	if (_entities isEqualTo []) exitWith {};
	_target = _entities select 0;
	systemchat str _target;
	_gunner doTarget _target;
	player commandchat str ((bf1 aimedAtTarget [_target,_weapon]));
	
	_timer = time;
	waitUntil {
		({_vehicle aimedAtTarget [assignedTarget _gunner,_x] > 0} count (weapons _vehicle) > 0) OR {time - _timer > 10}
	};
	systemchat str [_vehicle, _gunner, _target,{_vehicle aimedAtTarget [assignedTarget _gunner,_x] > 0} count (weapons _vehicle) > 0];
	if ({_vehicle aimedAtTarget [assignedTarget _gunner,_x] > 0} count (weapons _vehicle) > 0) then {
		_gunner fireattarget [_vehicle,_weapon];
	};
	
	sleep 7;

};

systemchat "done";





//(driver bf1) disableAI _x


_vehicle = bf1;
_targetPos = position if1;
[_vehicle,0] remoteExec ["limitSpeed",_vehicle];
//[_vehicle,"ALL"] remoteExec ["disableAI",_vehicle];
//[driver _vehicle,"ALL"] remoteExec ["disableAI",driver _vehicle];
{bf1 disableAI _x; } foreach ["TARGET","PATH"]; //,  ["ALL"] ,,"AUTOTARGET","FSM","SUPPRESSION","COVER","AUTOCOMBAT","MOVE"
//[_vehicle,_targetPos] spawn A3C_FORCEORIENT; // not needed
_vehicle setVariable ["A3C_Freeze_helicopter",true,true];

bf1 domove position if1;

//-- keep heli moving in direction!  bf1 doMove [19364.8,14694.8,0]

//-- adjust altitude    [] spawn {while {getposATL bf1 select 2 < 999} do {bf1 setVelocity [0,0,7]}}; //-- after action is done, heli automatically adjusts altitude

_data = ["Altis",[18544.9,13702,392.562],65.9006,0.75,[-25.4473,0],0,0,775.338,0,0,1,0,1];
["Paste",_data] call BIS_fnc_camera;

if (true) exitWith {};









A3C_calculatePathLength = {
	params ["_unit","_destination"];
	private _vehicle = vehicle _unit;
	private _return = -1;
	
	private _vehicleKind = "";
	{
		if (_vehicle isKindOf _x) exitWith {
			_vehicleKind = _x;
		};
	} foreach 
	[
		"MAN",
		"WHEELED_APC",
		"CAR",
		"TANK",
		"BOAT",
		"HELICOPTER",
		"PLANE"
	];
	if (_vehicleKind == "") exitWith {_vehicle distance2D _destination};
	
	_cp = calculatePath [_vehicleKind,behaviour _unit,position _vehicle,_destination];
	_handle = _cp addEventHandler 
	[
		"PathCalculated",
		{
			params ["_agent", "_path"];
			player commandchat str (_agent distance (_path select (count _path - 1)));
			_distance = 0;
			{
				if (_foreachIndex > 0) then {
					_distance = _distance + (_x distance (_path select (_forEachIndex - 1)));
				};
			} forEach _path;
			_agent setVariable ["A3C_pathDistance",_distance];
			systemchat str _distance;
		}
	];
	systemchat str _cp;
	_dist =  (_cp getVariable ["A3C_pathDistance","NUH"]);
	_cp removeEventHandler ["PathCalculated",_handle];
	deleteVehicle _cp;
	_dist

};


onmapsingleclick {_p = [player,_pos] call A3C_calculatePathLength; systemchat str _p};

if (true) exitWith {};



0 = [] spawn {
	{
		systemchat "go";
		private _refVehicle = _x;
		_refType = typeof _refVehicle;
		_building = if (_foreachindex > 1) then {hb2} else {hb1};
		if (_foreachindex > 3) then {_building = hb3};
		if (_foreachindex > 1) then {sleep 2; crane1 setdamage 1};
		
		_refVehicle1 = _refType createVehicleLocal [100,100,1000];
		_refVehicle1 enablesimulation false;
		_refVehicle1 setPosASL (ATLtoASL [100,100,1000]);
		
		
		_vehicleDimensions = [_refVehicle1] call A3C_getVehicleBodyDimensions;
		systemchat str _vehicleDimensions;
		deletevehicle _refVehicle1;
		
		_vehicleDimensions params ["_reference_Width","_reference_Length"];
		private _LZposition = [_building,_reference_Width,_reference_Length] call A3C_getHeliRoofLZ;

		if (_LZposition isEqualto []) exitWith {
			systemchat format ["No possible stashing Pos for %1",	gettext (configfile >> "CfgVehicles" >> _refType >> "displayName")];

		};

		_LZposition params ["_LZ_center","_LZ_direction"];
		private _gp = group driver _refVehicle;
		private _wp = 
		[
			_gp,
			_LZ_center
		] call A3C_HC_ADD_WP;
		
		private _statements = format 
		[
			"
				[this,%1,'%2',%3] spawn A3C_HC_WPACTION_LANDING_FULL;
			",
			_LZ_center,
			getPlayerUID player,
			[_LZ_direction] call MCSS_fnc_DegreeToVector
			
		];
		_wpStm = waypointStatements _wp;
		_wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements]; 
		
		waituntil {isTouchingGround _refVehicle};
		
	} foreach [landchop1,landchop2,landchop3,landchop4,landchop5];
};
//

if (true) exitWith {};

/*





_matrix = 
[
	[[[1,1,1],0],[[1,1,2],0],[[1,1,3],0]],
	[[[2,2,1],0],[[2,2,2],0],[[2,2,3],0]],
	[[[3,3,1],0],[[3,3,2],0],[[3,3,3],0]],
	[[[4,4,1],0],[[4,4,2],0],[[4,4,3],0]]
];

_newMatrixLayout =
[
	[_matrix select 0 select 2, _matrix select 1 select 2,_matrix select 2 select 2,_matrix select 3 select 2],
	[_matrix select 0 select 1, _matrix select 1 select 1,_matrix select 2 select 1,_matrix select 3 select 1],
	[_matrix select 0 select 0, _matrix select 1 select 0,_matrix select 2 select 0,_matrix select 3 select 0]
];


_newMatrix1 =
[
	[[[1,1,3],0],[[2,2,3],0],[[3,3,3],0],[[4,4,3],0]],
	[[[1,1,2],0],[[2,2,2],0],[[3,3,2],0],[[4,4,2],0]],
	[[[1,1,1],0],[[2,2,1],0],[[3,3,1],0],[[4,4,1],0]]
];





_subMatrixEntryCount = count (_matrix select 0);
    
_newMatrix = [];
for "_i" from (_subMatrixEntryCount - 1) to 0 step -1 do {
	_subMatrix = [];
	{
		_subMatrix pushBack (_x select _i);
	} foreach _matrix;
	_newMatrix pushBack _subMatrix;
};
copytoclipboard str _newMatrix;   
    
// if (true) exitWith {};

_newMatrix = [];
_subMatrixEntryCount = (count (_matrix select 0));





for "_i" from (_subMatrixEntryCount - 1) to 0 step - 1 do {
	_subMatrix = [];
	{
		_subMatrix pushBack (_x select _i);
	} foreach _matrix;
	_newMatrix pushBack _subMatrix;
};




copytoclipboard str _newMatrix;



//if (true) exitWith {};



_subMatrixEntryCount = count (_matrix select 0);	
_newMatrix = [];
for "_i" from (_subMatrixEntryCount) to 1 step -1 do {
	_subMatrix = [];
	{
		_subMatrix pushBack (_x select _i);
	} foreach _matrix;
	_newMatrix pushBack _subMatrix;

};

copytoclipboard str _newMatrix;



//if (true) exitWith {};

*/


_building = ofb;



_refType =
[
	"B_Heli_Light_01_F",
	"B_Heli_Attack_01_F",
	"B_Heli_Transport_01_camo_F",
	"B_Heli_Transport_03_F"
] call BIS_fnc_SelectRandom;

//-- to do: calculate the measures when helper object is spawned and set them as object namespace variable
_refType = "B_Heli_Light_01_F"; //"B_Heli_Transport_01_camo_F"; //"B_G_Quadbike_01_F";

_refVehicle = _refType createVehicleLocal [100,100,1000];
_refVehicle enablesimulation false;
_refVehicle setPosASL (ATLtoASL [100,100,1000]);


A3C_getVehicleBodyDimensions = {
	params ["_refVehicle"];
	_vehicleHeight = ((boundingBoxReal _refVehicle) select 1) select 2;
	_refBbox = [_refVehicle,0] call MCSS_fnc_BBOX;
	{
		_x set [2,1000];
	} foreach _refBbox;

	_testPosRoot = ATLtoASL (_refBbox select 0);
	_testPosZ = _testPosRoot select 2;

	_reference_L1 = ((_refBbox select 1) distance2D (_refBbox select 2)); //   WIDTH    7;
	_reference_L2 = ((_refBbox select 0) distance2D (_refBbox select 1)); //   LENGHT   3;
	//width and length might be swapped?


	_maxWidth = 0;
	_length = 0;

	_bodyStartY = [0,0,0];
	_isBodyY = false;

	//-- the following assumes a vehicle with a orientation of 0 deg
	for "_i" from 0 to ([_reference_L1,1] call BIS_fnc_cutDecimals) step 0.1 do {
		_subRoot = _testPosRoot getPos [_i, 0];
		_subRoot set [2,_testPosZ];
		_isBodyX = false;
		_exit = false;
		_bodyStartX = [0,0,0];
		_intsCount = 0;
		//-- width checks
		for "_t" from 0 to ([_reference_L2,1] call BIS_fnc_cutDecimals) step 0.1 do {
			_refpos2 = _subRoot getPos [_t, 90];
			_refpos2 set [2,_testPosZ];
			_refpos3 = [_refpos2 select 0,_refpos2 select 1,(_refpos2 select 2) + _vehicleHeight];
			_ints = lineIntersects [_refpos3,_refpos2];
			if (_ints) then {
				_intsCount = _intsCount + 1;
				if !(_isBodyX) then {
					_bodyStartX = +(_refpos3);
				};
				_isBodyX = true;
			} else {
				if (_isBodyX) then {
					_exit = true;
					_width = _refpos3 distance2D _bodyStartX;
					if (_width > _maxWidth) then {
						_maxWidth = _width;
					};
				};
			};
			if (_exit) exitWith {};
		};
		//-- legth checks
		if (_intsCount > 0) then {
			if !(_isBodyY) then {
				_bodyStartY = +(_subRoot);
			};
			_isBodyY = true;
		} else {
			if (_isBodyY) then {
				_length = _subRoot distance2D _bodyStartY;
				_isBodyY = false;
			};
		};
	}; 
	systemchat str [_maxWidth,_length];
	//systemchat format ["Vehicle type %1, WIDTH %2, LENGHT %3", _refType,_reference_L1,_reference_L2];
	//if (true) exitWith {deletevehicle _refVehicle};

	[_maxWidth - 1,_length - 1]; 
	//width and length might be swapped?
};

_vehicleDimensions = [_refVehicle] call A3C_getVehicleBodyDimensions;
_vehicleDimensions params ["_reference_Width","_reference_Length"];


//_reference_Width = 2;   // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//_reference_Length = 14; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!




A3C_isEmptySquareOnSurfaceLevel = {
	params ["_testPos","_building","_bDir","_highestZ_ASL"];
	private _isUsable = true;
	
	_ints_Z = lineIntersectsSurfaces
	[
		_testPos,
		[_testPos select 0, _testPos select 1, 0],
		objnull,
		objNull,
		true,
		1,
		"GEOM",
		"NONE"
	];
	if (count _ints_Z == 0) exitWith {false};
	
	_intsPos = (_ints_Z select 0) select 0;

	if (abs ((_intsPos select 2) - _highestZ_ASL) > 0.5) exitWith {false};
	for "_i" from 0 to 7 do {
		
		_checkLength = if (_i % 2 == 0) then {0.353553} else {0.5}; //-- 0.353553 is half the diameter of a 1m square, 0.5 is half a side-length
		
		_refPos = _testPos getPos [_checkLength,(_bdir + 45) * _i];
		_refPos set [2, _highestZ_ASL];
		_isIntersects = lineIntersects [_testPos, _refPos,objNull,objNull];
		if (_isIntersects) exitWith {
			_isUsable = false;
		};
	};
	_isUsable
};



A3C_getHeliRoofLZ = {
	params ["_building","_reference_Width","_reference_Length"];
	_bDir = getDir _building;
	
	//-- create boundingbox within roof-height
	_highestZ_ATL = 0;
	_highestZ_ASL = 0;
	{
		if (_x select 2 > _highestZ_ATL) then {
			_highestZ_ATL = _x select 2;
			_highestZ_ASL = (ATLtoASL _x) select 2;
		};
	} foreach ([_building] call BIS_fnc_buildingPositions);

	_bboxATL = [_building,0] call MCSS_fnc_BBOX;
	_bboxASL = [];
	{
		_x set [2, _highestZ_ATL];
	} foreach _bboxATL;
	{
		_bboxASL pushBack [_x select 0, _x select 1, _highestZ_ASL];
	} foreach _bboxATL;
	

	//-- optional helpers deletion
	helpers = if (isNil 'helpers') then {[]} else {helpers};
	{deletevehicle _x} foreach helpers;
	
	//-- function to find largest area in matrix-histograms
	_fnc_findLargestRectangleInHistogram = {
		params ["_matrix"];
		//-- create histograms and reference values against 
		_subMatrixEntryCount = count (_matrix select 0); //-- identical to ceil(_buildingWith)
		systemchat str _subMatrixEntryCount;
		_histogram = [];
		_histoClean = [];
		for "_i" from 1 to _subMatrixEntryCount do {
			_histogram pushBack [[0,0,0],0];
			_histoClean pushBack 0;
		};
		private _largestRectangle = [[0,0,0],0,0]; //-- [bottom lect corner,width,length];

		{
			_subMatrix = _x;

			//-- create submatrix histogram
			{
				_x params ["_aslPos","_isEmpty"];
				
				_histoValue = (_histogram select _foreachIndex) select 1;
				if (_isEmpty == 1) then {
					_histogram set [_foreachIndex, [_aslPos,_histoValue + 1]];
					_histoClean set [_foreachIndex,_histoValue];
				} else {
					_histogram set [_foreachIndex,[_aslPos,0]];
					_histoClean set [_foreachIndex,0];
				};
				
			} foreach _subMatrix;
			diag_log _histoClean;

			_largestRectangle params ["_corner","_w","_l"];
			_requiredHistogramCheck = -1; //-- skip those who are already within a rectangle
			
			//-- check histogram for properties: x-number of consecutive histoValues of >= _reference_Length
			//-- fetch surfaceArea, override _largestRectangle
			{
				_x params ["_aslPos1","_histoValue"];
				_currentW = 0;
				if (_foreachIndex > _requiredHistogramCheck) then {
					if (_histoValue >= _reference_Length) then {
						for "_i" from _foreachIndex to ((count _histogram) - 1) do {
							_refEntry = _histogram select _i;
							_refEntry params ["_aslPosREF","_histoValueREF"];
							if (_histoValueREF < _histoValue) exitWith {};
							_currentW = _currentW + 1;
							_requiredHistogramCheck = _i;
						};
					};
					if (_currentW >= _reference_Width) then {
						if ((_currentW * _histoValue) > ( (_largestRectangle select 1) * (_largestRectangle select 2)) ) then {
							_largestRectangle = [_aslPos1,_currentW,_histoValue];
						};
					};	
				};
			} foreach _histogram;
		} foreach _matrix;
		_largestRectangle
	};


	//-- CREATE MATRIX
	private _matrix = [];
	_building_width = (_bboxASL select 0) distance2D (_bboxASL select 1);
	_building_length = (_bboxASL select 1) distance2D (_bboxASL select 2);
	_testPosRoot = (_bboxASL select 3);
	
	_visualizeHelpers = false; 
	
	for "_building_length_step" from 0 to (floor _building_length) do {
		_testPos1 = _testPosRoot getPos [_building_length_step, _bDir - 180];

		_subMatrix = [];

		for "_building_width_step" from 0 to (floor _building_width)  do {
			_testPos = _testPos1 getPos [_building_width_step,_bDir + 90];
			_testPos set [2,_highestZ_ASL];

			_matrixValue = 0;

			if ([_testPos,_building,_bDir,_highestZ_ASL] call A3C_isEmptySquareOnSurfaceLevel) then {
				_matrixValue = 1;
				if (_visualizeHelpers) then {
					_helper = "Land_VR_Shape_01_cube_1m_F" createVehicleLocal [0,0,0];
					helpers pushBack _helper;
					_helper setDir _bDir;
					_helper setPosASL _testPos;
				};
			};
			_subMatrix pushBack [_testPos,_matrixValue]; 
		
		};

		_matrix pushBack _subMatrix;
	};


	
	//-- check Matrix for suitable LZ-Area
	private _largestRectangle = [_matrix] call _fnc_findLargestRectangleInHistogram;
	
	//-- suitable LZ-Area was found - calculate rectangle center and add _bDir
	if (_largestRectangle select 1 > 0) exitWith {
	//if (false) exitWith { //-- to be used for matrix flip troubleshooting
		_LZ = (_largestRectangle select 0) getPos [(_largestRectangle select 1) / 2,_bDir + 90];
		_LZ = _LZ getPos [(_largestRectangle select 2) / 2,_bDir];
		_LZ set [2,_highestZ_ASL];
		//-- since ASLheight is taken from buildingPos, we need to snap to roof-surface
		_surfaceIntersect = lineIntersectsSurfaces
		[
			_LZ,
			[_LZ select 0,_LZ select 1,0],
			objNull,
			objNull,
			true,
			1,
			"GEOM",
			"NONE"
		];
		_LZ set [2,((_surfaceIntersect select 0) select 0) select 2];
		[_LZ,_bDir]	
	};


	//-- No suitable LZ-Area was found yet - Flip the matrix 90 degrees and check a second time:
	
	//-- NOT WORKING! >>> ASL POSITIONS ARE NOT ACCURATE WHEN FLIPPING THE MATRIX!
	
	
	_subMatrixEntryCount = count (_matrix select 0);
	
	_newMatrix = [];
	for "_i" from (_subMatrixEntryCount - 1) to 0 step - 1 do {
		_subMatrix = [];
		{
			_subMatrix pushBack (_x select _i);
		} foreach _matrix;
		_newMatrix pushBack _subMatrix;

	};
	//player commandchat str [count _Matrix,count (_Matrix select 0)];
	//player commandchat str [count _newMatrix, count (_newMatrix select 0)];
	//copytoclipboard str _newMatrix;
	
	_largestRectangle = [_newMatrix] call _fnc_findLargestRectangleInHistogram;
	
	if (_largestRectangle select 1 > 0) exitWith {
		
		_LZ = (_largestRectangle select 0) getPos [(_largestRectangle select 1) / 2, _bDir + 90];
		_LZ = _LZ getPos [(_largestRectangle select 2) / 2,_bDir];
		_LZ set [2,_highestZ_ASL];
		//-- since ASLheight is taken from buildingPos, we need to snap to roof-surface
		_surfaceIntersect = lineIntersectsSurfaces
		[
			_LZ,
			[_LZ select 0,_LZ select 1,0],
			objNull,
			objNull,
			true,
			1,
			"GEOM",
			"NONE"
		];
		_LZ set [2,((_surfaceIntersect select 0) select 0) select 2];
		systemchat str _largestRectangle;
		[_LZ,_bDir + 90];	
	};	
	//-- still no suitable LZ area found: return empty array
	[] 
	
};


private _LZposition = [_building,_reference_Width,_reference_Length] call A3C_getHeliRoofLZ;

if (_LZposition isEqualto []) exitWith {
	systemchat format ["No possible stashing Pos for %1",	gettext (configfile >> "CfgVehicles" >> _refType >> "displayName")];
	deletevehicle _refVehicle;
};

_LZposition params ["_LZ_center","_LZ_direction"];

_refVehicle setPosASL _LZ_center;
_refVehicle setDir _LZ_direction;
sleep 3;
//deletevehicle _refVehicle;



if (true) exitwith {};


///////////////////////////////////


{
	player enablesimulation false;
	player setposASL _x;
	player setdir (player getdir _building);
	sleep 1;
} foreach _bboxASL;






_vehicle = v4;
_vehicle disableAI "MOVE";
_railpos = (position player) getpos [20,getDir player];

_railPos set [2,((getposASL player) select 2) + 1];


_speed = 80;
_dist = (getPosASL _vehicle) distance _railPos;
_factor = (((_dist / 50) * 0.001) * 60) * 60;

_endTimeEstimated = time + _factor;
_subBehaviour = 
[
	_vehicle,
	getPosASL _vehicle,
	_railPos, 
	vectorDirVisual _vehicle,
	[_vehicle getDir _railPos] call MCSS_fnc_DegreeToVector, //
	vectorUpVisual _vehicle,
	[0,0,1], //vectorUpVisual _vehicle,
	_speed,
	_endTimeEstimated
] spawn A3C_AI_RAIL_HELI;
waituntil {scriptdone _subBehaviour};

_railPos set [2,0];

_pad = "Land_HelipadEmpty_F" createvehicle _railPos;
_vehicle land 'LAND';
_vehicle enableAI "MOVE";


if (true) exitWith {};



[] spawn {
	_units = [];
	{
		if (side _x == EAST) then {
			_units pushback _x
		};
	} foreach allunits;
	_units = [_units,[],{_val = (_x distance2d [10007.8,11234.4,0]) + (_x distance2d position player); _val = _val / 2; _val},"ASCEND"] call BIS_fnc_sortBy;
	{
		if (_foreachINdex > 40) then {
			vehicle _x setdamage 1;
		};
	} foreach _units;
};

//_input = _this;

//systemchat str (count _input);
//private _runwayPositions = [];

//_count = 1;
//while {count _input > 0} do {
//	_newPosition = [_input select 0,_input select 1];
//	_input = _input - _newPosition;
//	_runwayPositions pushBack _newPosition;
//};

//systemchat str _runwayPositions;

_runwayPositions = _this;
_sizeX = 40;

markerCount = if (isNil 'markerCount') then {0} else {markerCount};


{
	if (_foreachIndex < (count _runWayPositions - 1)) then {
		//player setPos _x; sleep 2;
		_startPos = _x;
		_endPos = (_runWayPositions select (_forEachIndex + 1));
		_length = _startPos distance2D _endPos;
		_areaDir = _startPos getDir _endPos;
		_sizeY = (_length / 2); // max 60;
		_areaCenter = _startPos getPos [_sizeY,_areaDir];
		_area = [_areaCenter,_sizeX,_sizeY,_areaDir,true];
		
		_topLeft = _startPos getPos [_sizeY,_areaDIr];
		_topRight = _topLeft getPos [_sizeX, _areaDir + 90]; //-- we skipped a step by making _topRight from first step FIRST
		_topLeft = _topLeft getPos [_sizeX, _areaDir - 90];
		
		_bottomRight = _startPos getPos [_sizeY,_areaDIr - 180];
		_bottomLeft = _bottomRight getPos [_sizeX,_areaDIr + 90]; //-- skipped a step as above
		_bottomRight = _bottomRight getPos [_sizeX,_areaDIr + 90];
		


		_sizeY = _sizeY max 50;
		
		//systemchat str _area;
		_marker = [(format ['A3C_Mark_P%1',markerCount]),_areaCenter,"RECTANGLE","RECTANGLE",[_sizeX,_sizeY],"","ColorOrange",1] call MCSS_fnc_createMarker;
		_marker setMarkerDir _areaDir;
		markerCount = markerCount + 1;
	};
} foreach _runWayPositions;


//systemchat str _runwayPositions;
//systemchat str _input;




if (true) exitWith {};



private _airportData = [position player] call MCSS_fnc_getNearestAirportData;
_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];

_airportIlsDir = [_airportIlsDir] call MCSS_fnc_CorrectDir;

private _approxLength =  _airportTaxiIn distance2D _airportTaxiOff;
private _diameter = 20;


//-- Landing
private _landingDir = [_airportIlsDir + 180] call MCSS_fnc_CorrectDir;
"airMark1" setmarkerDir _landingDir; 
_landingAreaPos = (_airportTaxiIn getPos [_approxLength /2,_landingDir]);
"airMark1" setMarkerPos _landingAreaPos;



//-- TakeOff
"airMark2" setmarkerDir (_airportIlsDir);
_takeOffAreaPos = (_airportTaxiOff getPos [_approxLength /2,_airportIlsDir]); 
"airMark2" setMarkerPos _takeOffAreaPos;
{
	_x setMarkerSize [_diameter,_approxLength /2];
} foreach ["airMark1","airMark2"];




_connectPos1_1 =  (_airportTaxiOff getPos [_approxLength + (_diameter / 2),_airportIlsDir]); //-- connects to _airportTaxiIn
_connectPos1_2 =  (_airportTaxiIn getPos [(_diameter / 2),_airportIlsDir]); 
_connectLength1 = _connectPos1_1 distance2D _connectPos1_2;
_connectDir1 = [_airportIlsDir + 90] call MCSS_fnc_CorrectDir;
_connectAreaPos1 = _connectPos1_1 getPos [_connectLength1 / 2,_connectDir1 ];
"airMark3" setMarkerDir _connectDir1;
"airMark3" setMarkerPos _connectAreaPos1;





_connectPos2_1 =  (_airportTaxiIn getPos [_approxLength + (_diameter / 2),_landingDir]); //-- connects to _airportTaxiOff
_connectPos2_2 =  (_airportTaxiOff getPos [(_diameter / 2),_landingDir]);
_connectLength2 = _connectPos2_1 distance2D _connectPos2_2;
_connectDir2 = [_landingDir + 90] call MCSS_fnc_CorrectDir;
_connectAreaPos2 = _connectPos2_1 getPos [_connectLength2 / 2,_connectDir2 ];
"airMark4" setMarkerDir _connectDir2; 
"airMark4" setMarkerPos _connectAreaPos2;



{
	_x setMarkerSize [_diameter,_connectLength1];
} foreach ["airMark3","airMark4"];

_area1 = [_landingAreaPos,_diameter,(_approxLength /2),_airportIlsDir,true]; //-- LandingRunway
_area2 = [_takeOffAreaPos,_diameter,(_approxLength /2),_airportIlsDir,true]; //-- TakeOff runway
_area3 = [_connectAreaPos1,_diameter,_connectLength1,_connectDir1,true]; //-- connect 1, LandingEnd to TakeoffStart
_area4 = [_connectAreaPos2,_diameter,_connectLength2,_connectDir2,true];







if (true) exitWith {};



_wp = gp2 addwaypoint [[14904.1,17163.9,3.97594],0];
//_wp waypointAttachObject bb;
//_wp setWaypointHousePosition 33; ///


if (true) exitWith {};

//-- find 'room door' for building position
params ["_building","_room"];
private _doors = [_building] call A3C_DOORPOSITIONS;
private _roomDoorsArray = [];

{
	private _doorDir = [_building, _x] call A3C_DOOR_DIR;
	private _LOS_count = 0;
	private _roomIndex = -1;
	private _doorPos = _x;
	_doorIndex = _foreachIndex;
	private _fEI = _forEachIndex;
	//-- check 'in front' and 'behind door'
	_refPos1 = [_doorPos,0.5,_doorDir + 0] call BIS_fnc_RelPos;
	_count1 = {!(_building in lineIntersectsWith [ATLtoASL (_building buildingPos _x), ATLtoASL _refPos1])} count _room;
	_refPos2 = [_doorPos,0.5,_doorDir + 180] call BIS_fnc_RelPos;
	_count2 = {!(_building in lineIntersectsWith [ATLtoASL (_building buildingPos _x), ATLtoASL _refPos2])} count _room;
	if ((_count1 + _count2) > _LOS_count) then {
		_LOS_count = (_count1 + _count2);
		_roomIndex  = _fEI;	
	};

	if (_roomIndex != -1) then {
		if (_LOS_count != -1) then {
			_roomDoorsArray pushBack _doorPos;
		};
	};
} foreach _doors;
if (count _roomDoorsArray > 1) then {
	_roomDoorsArray = [_roomDoorsArray,[],{_x distance2d (position _building)},"ASCEND"] call BIS_fnc_sortBy;
};

systemchat str _roomDoorsArray;


if (true) exitWith {};

{


	
	
	
	_doorIndex = _foreachIndex;
	{
		_room = _x;
		private _fEI = _forEachIndex;
		//-- check 'in front' and 'behind door'
		_refPos1 = [_doorPos,0.5,_doorDir + 0] call BIS_fnc_RelPos;
		_count1 = {!(_building in lineIntersectsWith [ATLtoASL (_building buildingPos _x), ATLtoASL _refPos1])} count _room;
		_refPos2 = [_doorPos,0.5,_doorDir + 180] call BIS_fnc_RelPos;
		_count2 = {!(_building in lineIntersectsWith [ATLtoASL (_building buildingPos _x), ATLtoASL _refPos2])} count _room;
		if ((_count1 + _count2) > _LOS_count) then {
			_LOS_count = (_count1 + _count2);
			_roomIndex  = _fEI;	
		};
	} foreach _rooms;
	if (_roomIndex != -1) then {
		systemchat format ["door %1 belongs to %2",_doorIndex, _rooms select _roomIndex];
		player setpos (_building buildingpos ((_rooms select _roomIndex) select 0));
		sleep 5;
	};
} foreach _doors;


 

{
	
	private _room = _x;
	private _fEI = _forEachIndex;
	//-- check 'in front' and 'behind door'
	{
		private _roomIndex = -1;
		private _LOS_count = -1;
		private _doorDir = [_building, _x] call A3C_DOOR_DIR;
		_refPos1 = [_doorPos,0.5,_doorDir + 0] call BIS_fnc_RelPos;
		_count1 = {!(_building in lineIntersectsWith [ATLtoASL (_building buildingPos _x), ATLtoASL _refPos1])} count _room;
		_refPos2 = [_doorPos,0.5,_doorDir + 180] call BIS_fnc_RelPos;
		_count2 = {!(_building in lineIntersectsWith [ATLtoASL (_building buildingPos _x), ATLtoASL _refPos2])} count _room;
	} foreach _doors;

	if ((_count1 + _count2) > _LOS_count) then {
		_LOS_count = (_count1 + _count2);
		_roomIndex  = _fEI;	
	};
} foreach _rooms;









if (true) exitWith {};
tt =
[
	[
		[0],[2,5,6],[7,8],[10,11],[12,13],[15,16],[1,49,48]
	],
	[
		[14,18,32,33]
	],
	[
		[3,25],[17],[26,27],[28,29],[4,24,37,20,21,34,19,22,23,35,36]
	],
	[
		[30,31]
	],
	[
		[38,39,40,41,42,43,44,45,46,47]
	]
];





private _newFloorsArray = []; //-- NEW FULL ARRAY
//player sidechat str tt;
for "_i" from 0 to ((count tt) - 1) do {
	
	_roomArrayCurrent = tt select _i;
	_referencePosition = if (_i == 0) then {bb buildingPos 0} else {bb buildingPos (((_newFloorsArray select (_i - 1)) select ((count (_newFloorsArray select (_i - 1))) -1))  select 0)}; //-- either bpos0 or first bpos of last entry WITHIN previous roomsarray/floor
	
	
	if (isNil '_referencePosition') exitWith {
	//	player sideChat str _newFloorsArray;
	//	systemchat str (((_newFloorsArray select (_i - 1)) select ((count (_newFloorsArray select (_i - 1))) -1))  select 0);
	};
	
	_firstShuffle = [_roomArrayCurrent,[],{(bb buildingPos (_x select 0)) distance2D _referencePosition},"ASCEND"] call BIS_fnc_sortBy;
	private _newRoomArray = [_firstShuffle select 0];
	_firstShuffle = _firstShuffle - [_firstShuffle select 0];
	//if (_i == 0) then {
		while {count _firstShuffle > 0} do {
			{
				if (count _firstShuffle == 0) exitWith {};
				_secondShuffle = [_firstShuffle,[],{(bb buildingPos (_x select 0)) distance2D _referencePosition},"ASCEND"] call BIS_fnc_sortBy;
				_firstShuffle = _firstShuffle - [_secondShuffle select 0];
				_newRoomArray pushBackUnique (_secondShuffle select 0);
			} foreach _firstShuffle;
		};
		_newFloorsArray pushBack _newRoomArray;
		//systemchat str _newFloorsArray;
	//} else {
		//player sidechat str (((_newRoomArray select (_i - 1)) select ((count (_newRoomArray select (_i - 1))) -1))  select 0)
	//};	
};
player commandChat str _newFloorsArray;






if (true) exitWith {};



//-- find closest building Position
params ["_refPos","_building"];
private ["_closestBposATL","_distance"];
_closestBpos = [];
_distance = 500000; //-- random overly igh number to begin distance reference far away
private _bpc = ([_building] call MCSS_fnc_countBPos);
for "_i" from 0 to _bpC do {
	_checkPos = (_building buildingPos _i);
	if ((_checkPos distance _refPos) < _distance) then {
		_closestBposATL = (_building buildingPos _i);
	};
};
systemchat str _closestBposATL;



if (true) exitWith {};
//-- assign roomPoses to unitArray
 params ["_units","_roomPoses"];
while {(count _roomPoses) > 0} do {
	{
		if ((count _roomPoses) == 0) exitWith {};
		systemchat str [_x,_roomPoses select 0]; //-------- add WP data to variable!
		_roomPoses deleteAt 0;
	} foreach _units;
};



if (true) exitWith {};


//--Creating Rooms


params ["_building"];

_bpc = ([_building] call MCSS_fnc_countBPos);
_bPosArray = [];
_rooms = [];


for "_i" from 0 to _bpc do {
	_bPos = ATLtoASL (_building buildingPos _i);
	_bPos  set [2,(_bPos select 2) + 0.5];
	_bPosArray pushBackUnique [_i,_bPos];
};


{
	_bPosIndex = _x select 0;
	_bPosASL = _x select 1;
	if ({_bPosIndex in _x} count _rooms == 0) then { //-- problem: this way, a rsecond room could be created because of a corner. Not too bad but could be adressed. 
		_roomPoses = [_bPosIndex];
		{
			_intersectsOBJS = lineIntersectsObjs [_bPosASL, (_x select 1), objnull,objnull,false];
			if !(_building in _intersectsOBJS) then {
				//-- there's a direct LOS between positions
				_roomPoses pushBackUnique (_x select 0);
			};
		} foreach _bPosArray;
		_rooms pushBackUnique _roomPoses;
	};
} foreach _bPosArray;

//~~ to do: sort rooms by ATLheight (threshold 1m)
//~~ to do: first room on next floor should be closest to last roomPos on previous floor 

systemchat str _rooms;

//copytoClipboard str _bPosArray;


if (true) exitWith {};


//-- bundle units into groups of 2

params ["_assignedUnits"];
//_assignedUnits = [1,2,3,4,5,6,7,8,9];
private _weaponArray = [];

while {(count _assignedUnits) > 0} do {
	private _subArray = [];
	_subArray pushBack (_assignedUnits select 0);
	if (count _assignedUnits > 1) then {
		_subArray pushBack (_assignedUnits select 1);
	};
	_assignedUnits = _assignedUnits - _subArray;
	_weaponArray pushBack _subArray;
};
systemchat str _weaponArray;


if (true) exitWith {};






/*	
[] spawn {
	A3C_TEST1 = false;
	

	{
		if (getPlayerUID player == "76561198085716174") then {
			A3C_TEST1 = true;
			publicVariable 'A3C_TEST1';
		};
	} remoteExec ["bis_fnc_call", 0]; 
	(str A3C_TEST1) remoteExec ["systemchat",0];

};
*/

tt = false;
sleep 0.2;

tt = true;

while {tt} do {
	_array1 = [];
	_array2 = [];
	_wps = waypoints tgroup; //((tgroup getVariable ["AIC_Waypoints",[0,[]]]) select 1); //
	{
		if (_x select 1 >= currentWaypoint tgroup) then {
			_array1 pushBack (_x select 1);
		};
	} foreach _wps;
	{
		_array2 pushBack ((_x select 0) select 2);
	} foreach A3C_ALL_POLYS;
	hintSilent format ["%1                                                                            %2",_array1,_array2];
	sleep 0.1;
};




if (true) exitWith {};



tt = false;
sleep 0.2;

tt = true;

while {tt} do {
	_array1 = [];
	_array2 = [];
	_wps = ([tgroup] call AIC_fnc_getAllActiveWaypoints) select 1; //((tgroup getVariable ["AIC_Waypoints",[0,[]]]) select 1); //
	{
		_array1 pushBack (_x select 0);
	} foreach _wps;
	{
		_array2 pushBack ((_x select 0) select 2);
	} foreach A3C_ALL_POLYS;
	hintSilent format ["%1                                                                            %2",_array1,_array2];
	sleep 0.1;
};




if (true) exitWith {};


_gp = tgroup;
tt = true;
while {tt} do {
	_wps = [];
	_polys = [];
	{
		_wps pushBack (_x select 0);
	} foreach (([_gp] call AIC_fnc_getAllActiveWaypoints) select 1);
	{
		_polys pushBack ((_x select 0) select 2);
	} foreach (_gp getvariable ["A3C_UNIT_POLYS",[]]);
	hintSilent str [_wps,_polys];
	sleep 0.1;
};


player setVariable ["projectilesHit",[],false];
ttime = time;
player addeventhandler
[
	"handleDamage",
	{
		params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];	
		private _preDamage = getDammage _unit;
		private _pH = _unit getVariable ["projectilesHit",[]];
		systemchat str [_preDamage,_damage];
		if (time - ttime < 1) exitWith {_preDamage};
		ttime = time;
		if (!(_projectile == '') && {_projectile in _pH}) exitWith {_preDamage};
		removeallweapons _unit;
		_ph pushBackUnique _projectile;
		_unit setVariable ["projectilesHit",_pH,false];
		
		_preDamage
	}
];


player addeventhandler
[
	"handleDamage",
	{
		params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];	
		private _preDamage = getDammage _unit;
		systemchat str [_preDamage,_damage];
		if (_damage > 0.1) then {_predamage = _predamage + 0.1};
		_preDamage
	}
];

 

tt = [];
player addeventhandler 
[ 
 "handleDamage", 
 {tt pushbackunique (getdammage player); 0
 } 
]; 
 
 
 
 
 














sleep 1;


A3C_HUD_CAM_MoveCam_Pos = ASLtoATL eyepos player;
A3C_HUD_CAM_MoveCam_Dir = getDir vehicle player;
_eyeHeight = A3C_HUD_CAM_MoveCam_Pos select 2;
//A3C_HUD_CAM_MoveCam_Pos = A3C_HUD_CAM_MoveCam_Pos getPos [0.1, A3C_HUD_CAM_MoveCam_Dir];
A3C_HUD_CAM_MoveCam_Pos set [2,_eyeHeight];


player hideobject true;
A3C_HUD_CAM = "camera" camCreate [0,0,0];
A3C_HUD_CAM cameraEffect ["INTERNAL", "BACK"];
A3C_HUD_CAM camPreparePos A3C_HUD_CAM_MoveCam_Pos;
A3C_HUD_CAM camPrepareFov 0.700;
A3C_HUD_CAM camPrepareTarget (A3C_HUD_CAM_MoveCam_Pos getPos [50, A3C_HUD_CAM_MoveCam_Dir]);
A3C_HUD_CAM camCommitPrepared 0;
showCinemaBorder false;
with uiNameSpace do {
	HUD_CAM_DISPLAY = (finddisplay 46) createDisplay "HUD_CAM_DISPLAY";
};

sleep 20;

A3C_HUD_CAM cameraEffect ["terminate","back"];
camDestroy A3C_HUD_CAM;
A3C_HUD_CAM = nil;
player hideobject false;
(findDisplay 79995) closeDisplay 0;
if (true) exitWith {};






_newGroup = creategroup WEST;
_leader = _newGroup createUnit [(typeOf player), position player, [], 0, "FORM"];

[_newGroup] call A3C_AIC_REFRESH;


if (true) exitWith {};


_groupControls = missionNamespace getVariable ["AIC_Group_Controls",[]];
{
			_groupControlId = _x;
			_group = missionNamespace getVariable [format ["AIC_Group_Control_%1_Group",(_groupControlId)],nil];
			_currentControlColor = ([_group] call AIC_fnc_getGroupColor);  
			_currentGroupColor = [_group] call AIC_fnc_getGroupColor;
			if((_currentControlColor select 0) != (_currentGroupColor select 0)) then {
				//AIC_fnc_setGroupControlColor(_groupControlId,_currentGroupColor);
				missionNamespace setVariable [format ["AIC_Group_Control_%1_Color",(_groupControlId)],_currentGroupColor];
				
			};
			//_currentGroupType = AIC_fnc_getGroupControlType(_groupControlId); 
			//_groupType = _group call AIC_fnc_getGroupIconType;
			//if(_groupType != _currentGroupType) then {
				[_groupControlId,"REFRESH_GROUP_ICON",[]] call AIC_fnc_groupControlEventHandler;
			//};
			
		} forEach _groupControls;
		
	
		

systemchat str time;
if (true) exitWith {};




_vehicle = vehicle player;
_array = [driver _vehicle, _vehicle];

_vehicle flyInHeight 500;
_vehicle limitspeed 0;

{
	_u = _x;

	//{_u disableAI "ALL"} foreach ["TARGET","AUTOTARGET","AUTOCOMBAT","PATH","FSM","MOVE"];
	_u setbehaviour "CARELESS";
} foreach _array;


if (true) exitWith {};





_pos = position player;
_dir = 0;


_dummy = "LaserTargetCBase" createVehicle _pos;
_dummy enableSimulation false; _dummy hideObject true;
_dummy setVariable ["vehicle",typeOf plane0];
_dummy setVariable ["type",1];
_dummy setDir _dir;

[_dummy,nil,true,plane0] call MCSS_fnc_moduleCAS;




if (true) exitWith {};

/*

{
	_ctrl = (finddisplay _x displayCtrl 11111);
	_ctrtpos = ctrlPosition _ctrl;
	_ctrlPos set [1, (1 - (GRIDY( MAIN_HEIGHT ) / 1))];
	_ctrl ctrlSetPosition _ctrlPos;
	_ctrl ctrlCommit 0;
} foreach [79992,79993];



if (true) exitwith {};




_vehicle = plane0;

_height = (getPosWorld _vehicle) select 2;

//systemchat "1";
_carrierObjects = _vehicle nearObjects ["Land_Carrier_01_base_F", 200];
//{
//	////if !(typeOf _x == "Land_Carrier_01_hull_04_F" || typeOf _x == "Land_Carrier_01_hull_07_F" ) then {
//	if !(["Land_Carrier",typeOf _x] call BIS_fnc_instring) then {
//		_carrierObjects = _carrierObjects - [_x];
//	};
//} foreach _carrierObjects;
if (count _carrierObjects == 0) exitWith {};
_carrier = _carrierObjects select 0;
_tarray = [];
//{
//	systemchat str (typeOf _x);
//	_tarray pushback (typeOf _x);
	//sleep 2;
//} foreach _carrierObjects;
//copytoclipboard str _tarray;
//_cfgArray = "true" configClasses (configfile >> "CfgVehicles" >> (typeOf _carrier) >> "Catapults");
//player commandchat str (count _cfgArray);
//_catapults = [];
//{
//	_catapults pushBackUnique (configName _x);
//} foreach _cfgArray;
//systemchat str _catapults;

_busyCatapults = _carrier getVariable ["A3C_BUSYCATAPULTS",[]];
_catapults = ["Catapult1","Catapult2","Catapult3","Catapult4"] - _busyCatapults;


private _execute = true;
if (count _cataPults > 0) then {
} else {
	systemchat "All catapults are occupied at the moment";
	_execute = false;
};
	



if (_execute) then {

	_catapult = _catapults select 0;
	private _partClass = "";
	
	if ((_catapult == "Catapult1") || (_catapult == "Catapult2")) then {
	   _partClass = "Land_Carrier_01_hull_04_1_F";
	} else {
		_partClass = "Land_Carrier_01_hull_07_1_F";
	};
	systemchat _partclass;
	private _carrierObjects = (_vehicle) nearObjects [_partClass , 400];
	private _part = _carrierObjects param [0, objNull];
	systemchat str _part;
	
	_var = _carrier getVariable ["A3C_BUSYCATAPULTS",[]];
	_var pushBackUnique _catapult;
	_carrier setVariable ["A3C_BUSYCATAPULTS",_var,true];
	
	//private _mempoint = getText (configfile >> "CfgVehicles" >> _partClass >> "Catapults" >> _catapult >> "memoryPoint");
	//private _dirOffset = getNumber (configfile >> "CfgVehicles" >> _partClass >> "Catapults" >> _catapult >> "dirOffset");
	//private _catapultPos = _carrier modelToWorld (_partClass selectionPosition _memPoint); //_catapultPos set [2, _height];
	//private _catapultDir = (getDir _carrier) - _dirOffset - 180;
	private _configPath = configfile >> "CfgVehicles" >> _partClass >> "Catapults" >> _catapult;
	private _animations = getArray (_configPath >> "animations");
	private _memPoint = getText (_configPath >> "memoryPoint");
	private _dirOffset = getNumber (_configPath >> "dirOffset");
	private _posCatapult = _part modelToWorld (_part selectionPosition _memPoint); _posCatapult set [2, _height];
	private _dirCatapult = (getDir _part - _dirOffset - 180) % 360;
	private _configPlane = configFile >> "CfgVehicles" >> typeOf _vehicle;
	private _velocityLaunch = getNumber (_configPlane >> "CarrierOpsCompatability" >> "LaunchVelocity") max 210;
	private _velocityIncrease = getNumber (_configPlane >> "CarrierOpsCompatability" >> "LaunchVelocityIncrease") max 75;
	private _accelerationStep = getNumber (_configPlane >> "CarrierOpsCompatability" >> "LaunchAccelerationStep") max 0.025;
	private _launchBar = getText (_configPlane >> "CarrierOpsCompatability" >> "LaunchBarMemoryPoint");
	
	//player allowdamage false;
	//player setposWorld _posCatapult;
	_vehicle setposWorld _posCatapult;
	_vehicle setDir _dirCatapult;
	(driver _vehicle) disableAI "PATH";
	_vehicle setvelocity [0,0,0];
	sleep 2;
	
	_vehicle engineOn true;
	
	
	_vehicle setfuel 1;
	//systemchat str [_mempoint,_dirOffset,_catapultPos];
	//sleep 5;
	[_vehicle] spawn BIS_fnc_AircraftCatapultLaunch;
	sleep 5;
	(driver _vehicle) enableAI "path";
	_var = _carrier getVariable ["A3C_BUSYCATAPULTS",[]];
	_var = _var - [_catapult];
	_carrier setVariable ["A3C_BUSYCATAPULTS",_var,true];
			
};




if (true) exitWith {};

{
	_data = [_x,carrier1] call A3C_FindCarrierPlaneStorage;
	//systemchat str _data;
	if (count _data > 0) then {
		_x setPosASL (_data select 0);
		_x setDir (_data select 1);
		
		//player allowdamage false;
		//systemchat str (_data select 0);
		//player setposASL (_data select 0);
		
	} else {
		//systemchat "no pos";
	};
	sleep 1;
	
} foreach [plane1,plane2,plane3,plane4,plane5,plane6,plane7,plane8];

//

if (true) exitWith {};


_planearray = [plane1,plane2,plane3,plane4,plane5,plane6,plane7,plane8];
_array = [];

{
	_ta = [(carrier worldToModel (position _x)),getDir _x];
	(_ta select 0) set [2,0.1];
	_array PushBack _ta;
} foreach _planearray;


systemChat str _array;
copyToClipboard str _array;

if (true) exitWith {};



params ["_vehicle","_cargoVehicle"];

 
_vehicle enableVehicleCargo true;

if !((_vehicle  canVehicleCargo _cargoVehicle) select 0) exitWith {
	systemchat format ["%1 [%2] has no space to load this %2",(gettext(configFile >> "CfgVehicles" >> typeof _vehicle >> "displayName")),_vehicle, (gettext(configFile >> "CfgVehicles" >> typeof _cargoVehicle >> "displayName")) ];
};

_vehicle setVehicleCargo _cargoVehicle;
systemchat format ["%1 [%2] was loaded with a  %2",(gettext(configFile >> "CfgVehicles" >> typeof _vehicle >> "displayName")),_vehicle, (gettext(configFile >> "CfgVehicles" >> typeof _cargoVehicle >> "displayName")) ];


if (true) exitWith {};


_vehicle = vehicle player;

{_vehicle animateDoor [_x,1]} foreach ["Door_1_rear","Door_1_source",'door_rear','door_rear_source'];
sleep 1;
_list = crew _vehicle;
{
	if ( ((assignedVehicleRole _x) select 0) == "cargo") then {
		//_backPackData = [backPack _x,
		_chuteType = if (isPLayer _x) then {"Steerable_Parachute_F"} else {"NonSteerable_Parachute_F"};
		unAssignVehicle _x;
		_x allowDamage false;
		moveOut _x;
		_x action["Eject",_vehicle]; 
		sleep 0.35;
		_chute = createVehicle [_chuteType, (getPos _x), [], 0, "NONE"];
		_chute setPos (getPos _x);
		_x moveinDriver _chute;
		_x allowDamage true;
	};
	sleep 0.5;
} forEach _list;
{_vehicle animateDoor [_x,0]} foreach ["Door_1_rear","Door_1_source",'door_rear','door_rear_source'];

	//{_vehicle animateDoor [_x, 1]} foreach ['door_R','door_L','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open'];

if (true) exitWITH {};






_veh = cursortarget;

{
	unassignvehicle _x;
	dogetOut _x;
} foreach crew _veh;
sleep 3;

[
	(units Tgroup),
	["DISASSEMBLE",_veh],
	position player,
	getDir player	
] spawn A3C_WP_ACTION_STATICWEAPON;




if (true) exitWith {};


_data = [units Tgroup,"PLANNING"] call A3C_getSelectionBackpackStatics;
systemchat str _data;
if (count _data > 0) then {
	[
		(units Tgroup),
		["ASSEMBLE",(_data select 0) select 1],
		position player,
		getDir player	
	] spawn A3C_WP_ACTION_STATICWEAPON;
}; 
if (true) exitWith {};


testing = true;
tPos = [0,0,0];
while {testing} do {
	tpos = morty getPos [5,random 360];
	morty setpos tpos;
	sleep 2;
};



if (true) exitwith {};

_ordenance = satchel;
_target = cursortarget;
_attachPos = ([_target,1] call MCSS_fnc_BBOX) select 1;
_attachPos set [2,1];
_attachPos = (lineintersectsSurfaces [AGLtoASL _attachPos,(AGLtoASL (((position _target) select [0,2]) + [1]))]); //,objnull, objnull, true, 1, "GEOM", "FIRE"
_attachPos = ASLtoATL ((_attachPos select 0) select 0);
systemchat str _attachPos;
_attachPos = _target worldToModel _attachPos;
_ordenance attachTo [_target,_attachPos];




if (true) exitwith {};



_unit = units player select 1;
_destination = (screentoworld [0.5,0.5]);
_vehicle = vehicle _unit;

if (currentCommand _unit == "STOP") then {	
	[_unit] call MCSS_fnc_EndStopState;
	//[_unit,_destination] call A3C_DOMOVE;
	sleep 2;
	//_unit doMove _destination;
	//_unit moveTo _destination;
};

//sleep 2;
if (effectiveCommander _vehicle == player) then {
	_unit commandMove _destination;
} else {
	systemchat "dude"; 	
	_unit doFSM ["A3C_CORE\fsm\doMove.fsm", _destination,[player,_unit]]; 
	//_unit execFSM "A3C_CORE\fsm\doMove1.fsm";
};

if (true) exitwith {};
bb = units player select 1;
[bb] join grpNull; 

bb doFollow player;
sleep 0.1; 

[bb] joinSilent group player; 
bb doFollow player;
sleep 1;
bb commandmove (screentoWorld [0.5,0.5]); 
bb moveTo (screentoWorld [0.5,0.5]);  
bb setDestination [screenToWorld [0.5,0.5], "LEADER PLANNED", true];

if (true) exitWith {};

disableserialization;
{
	_display = _x;
	_allCtrls = [];
	{
		_ctrl = ((str _x) splitString "Control#");
		{
			
			if (_x == "Control#") then {
				_ctrl = _ctrl - [_x];
			};
			
		} foreach _ctrl;
		_ctrl = _ctrl joinString "";
		_ctrl = parseNumber _ctrl;
		
		if (_ctrl > 0) then {
			{
				(_display displayCtrl _ctrl) ctrlSetEventHandler [_x,(format ["systemchat 'control %1'; true",_ctrl])];
				//~~ rumour: if EH returns number, default will be overriden. Could not confirm
			} foreach ["MouseButtonClick","MouseButtonDown","OnMouseButtonDown"];
		};
		_allCtrls pushback _ctrl;		
	} foreach (allControls _display);
} foreach (allDisplays);


{
	_display = _x;
	{
		_display displaySetEventHandler [_x,(format ["player commandchat 'control %1'; true",_display])];
	} foreach ["MouseButtonClick","MouseButtonDown"];
} foreach (allDisplays);

//_ctrl = _ctrl - "Control #";
//(findDisplay 12 displayCtrl _ctrl) ctrlRemoveAllEventHandlers _x
//systemchat  _ctrl;
if (true) exitWith {};

{
		
		
	} foreach ["MouseButtonClick","MouseButtonDown"];

{
	(findDisplay 12 displayCtrl 51) ctrlRemoveAllEventHandlers _x
} foreach ["MouseButtonClick","MouseButtonDown"];

{
	(findDisplay 12) displayRemoveAllEventHandlers _x
} foreach ["MouseButtonClick","MouseButtonDown"];

(findDisplay 12 displayCtrl 51) ctrlSetEventHandler
[
	"MouseButtonClick",
	"

		true					
	"
];

(findDisplay 12 displayCtrl 51) ctrlSetEventHandler
[
	"MouseButtonDown",
	"
		true					
	"
];

(findDisplay 46) displaySetEventHandler
[
	"MouseButtonClick",
	"
		true					
	"
];

(findDisplay 12) displaySetEventHandler
[
	"MouseButtonClick",
	"
		true					
	"
];

(findDisplay 12) displaySetEventHandler
[
	"MouseButtonDown",
	"
		true					
	"
];



if (true) exitWith {};

_obj = player;
_targetPos = getposATL dude;
_objPos = getposATL _obj;

_vDif = _objPos vectorDiff _targetPos;
_tVal = (_vDif select 2) / (_vDif select 1);

_angle = abs (atan _tVal); 
//systemchat str _angle;
_dir = _objPos getdir _targetPos; 

_pitch = 0; 
_vecdx = sin(_dir) * cos(_angle); 
_vecdy = cos(_dir) * cos(_angle); 
_vecdz = sin(_angle); 
_vecux = cos(_dir) * cos(_angle) * sin(_pitch); 
_vecuy = sin(_dir) * cos(_angle) * sin(_pitch); 
_vecuz = cos(_angle) * cos(_pitch); 

_obj setVectorDirAndUp [ [_vecdx,_vecdy,_vecdz], [_vecux,_vecuy,_vecuz] ];


if (true) exitWith {};

params ["_unit","_targetPos"];


_unit lookat _targetPos;

_target = "A3C_Supression_Target_F" createVehicleLocal _targetPos;
_target1 = "LaserTargetE" createVehicleLocal _targetPos;
_unit dotarget _target;

_list = _targetPos nearEntities [["Car","Motorcycle", "Tank","Man","AIR"], 10];
if (count _list > 0) then {
	_h = if ((_list select 0) isKindOf "MAN") then {0.3} else {1};
	{_x attachto [(_list select 0),[0,0,_h]]} foreach [_target,_target1];
};
	
sleep 2;
_unit setDir (([_unit,_targetPos] call BIS_fnc_dirTo) + 0);
_unit forceWeaponFire [(secondaryweapon _unit), "Single"];
sleep 2;
_unit disableAI "anim"; 
_unit dotarget _target;

_handle = _unit addEventHandler
[
	"Fired",
	{
		params ["_unit"];
		private ["_var"];
		_var = _unit getvariable "A3C_REMOTE_HANDLE";
		_unit enableAI "anim";
		_unit removeEventHandler ["Fired",_var select 0];
		{deletevehicle _x} foreach [(_var select 1),(_var select 2)];				 
	}
]; 
_unit setvariable ["A3C_REMOTE_HANDLE",[_handle,_target,_target1]];
//if (_exit) exitWith {};
//systemchat "oi";
sleep 2;

_unit setDir (([_unit,_target] call BIS_fnc_dirTo) + 0);
_unit forceWeaponFire [(secondaryweapon _unit),"Single"]; 
//sleep 7; 




 





if (true) exitwith {};

unit1 = cursortarget;
[
		"111",
		"onEachFrame",
		{unit1 switchmove "amovpercmwlksraswrfldf"; }
	] call BIS_fnc_addStackedEventHandler;

if (true) exitwith {};



[cursortarget,position player,objnull] spawn A3C_forceDestination;



_mrks = [
	[8860.11,14842.1,1],
	[8863.11,14842.1,1],
	[8863.11,14839.1,1],
	[8860.11,14839.1,1]
] call A3C_SUP_CREATE_POLY;



if (true) exitwith {};
_group = gp1;


{
	_groupControlId = _x;
	_waypointIcons = missionNamespace getVariable [format ["AIC_Group_Control_%1_Wp_Icons",_groupControlId],[]];
	systemchat str _waypointIcons;

} foreach  (missionNamespace getVariable ["AIC_Group_Controls",[]]);

// //(_controlId)
//
if (true) exitwith {};
_waypoints = [_group] call AIC_fnc_getAllActiveWaypoints;
//_color = AIC_fnc_getGroupControlColor(_groupControlId);

_currentWpRevision = _waypoints select 0;
_waypointsArray = _waypoints select 1;

{
	_wpIndex = _x select 0;
} foreach _waypointsArray;

if (true) exitwith {};
/*
while {true} do {
	_rPos = +(position dummy);
	_rpos set [2,15];
	_pos = ([_rPos,viewDistance,10,0,position dude1] call BIS_fnc_findOverwatch);
	if (_pos distance2D dude1 < 100) exitwith {dude1 domove _pos;};
	hintSilent "test";
};
hintSilent "done";
if (true) exitwith {};
*/


_group = gp1;
/*
gp1 setvariable
[
	"A3C_UNIT_POLYS",
	[
		[
			[
				[8861.61,14840.6,1],
				"TMARK"
			],
			[
				[8860.11,14842.1,1],
				[8863.11,14842.1,1],
				[8863.11,14839.1,1],
				[8860.11,14839.1,1]
			],
			["A3C_SUP_Mark_13","A3C_SUP_Mark_14","A3C_SUP_Mark_15","A3C_SUP_Mark_16"]
		]
	],
	true
];

[
	[
		[
			[8269.57,14796.5,0.123199],
			"A3C_SUP_MAIN_Mark_1"
		],
		[
			[8259.57,14806.5,0.123199],
			[8279.57,14806.5,0.123199],
			[8279.57,14786.5,0.123199],
			[8259.57,14786.5,0.123199]
		],
		[
			"A3C_SUP_Mark_2",
			"A3C_SUP_Mark_3",
			"A3C_SUP_Mark_4",
			"A3C_SUP_Mark_5"
		]
	]
]


[
				[8860.11,14842.1,1],
				[8863.11,14842.1,1],
				[8863.11,14839.1,1],
				[8860.11,14839.1,1]
] call A3C_SUP_CREATE_POLY
*/
_wpA = _group getVariable ["AIC_Waypoints",[0,[]]];
//_wpA = ([_group] call AIC_fnc_getAllActiveWaypoints);
_wpC = _wpA select 0;

//if (true) exitwith {systemchat str _wpA; copyToClipboard str _wpA;};


_wps = +(_wpA select 1);
_wpi = ((_wps select 1) select 0) - 1;
//player sidechat str _wpi;
_indSel = 1; //-- this is the index of selected waypoint
_indAdd = (_indSel + 1);
//_wps = (_wps select [0,_indAdd]) + [[_indAdd + _wpi,(waypointPosition [_group,_indSel] ),false,"MOVE","systemchat 'done';  ","true",5,"LINE",1000]] + (_wps select [_indAdd,(count _wps)]);
// 
//(_wps select _indSel) set [4,"[this] call A3C_AIC_InsertWP; {_x dowatch (position dummy)} foreach units group this; [(units group this),(position dummy),true] spawn A3C_SUPPRESSION_ON;  "]; // 

(_wps select _indSel) set [4,"[this] call A3C_AIC_InsertWP; {_x dowatch (position dummy)} foreach units group this; [(units group this),['A3C_HC_POLY'],true] spawn A3C_SUPPRESSION_ON;  "];

(_wps select _indSel) set [5, "true"];
(_wps select _indSel) set [6, 0];
(_wps select _indSel) set [7, "LINE"];
//S

//([position dummy,viewDistance,10,0,position dude1] call BIS_fnc_findOverwatch);

// 

//{
	//_x set [0,(_forEachIndex + _wpi)];
	//if (_foreachIndex == _indSel) then {
		//_x set [4," [(units this),([leader this,100,(getdir leader this)] call BIS_fnc_RelPos),true] spawn A3C_SUPPRESSION_ON; "];
		////_x set [4,""]; //-- action
		//_x set [5,"true"];
		////_x set [6,15];
	//};
	//if (_foreachIndex == _indAdd) then {
	//	_x set [4,""];
	//	_x set [5,"true"];
	//	_x set [6,15];
	//};
//} foreach _wps;


_group setVariable ["AIC_Waypoints",[_wpc,_wpS],true];
{[_x,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler} foreach (missionNamespace getVariable ["AIC_Group_Controls",[]]); 


if (true) exitwith {};

_t = [
	3,
	[
		[
			0,
			[8121.57,15196.2,0],
			false,
			"MOVE"
		],
		[
			1,
			[8429.14,15212.7,0],
			false,
			"MOVE"
		],
		[
			2,
			[9080.65,15463.8,0],
			false,
			"MOVE"
		]
	]
];

_arr = [];
TT = true;
while {TT} do {
	_cc = currentCommand dude1;
	_arr pushBackUnique _cc;
};
systemchat str _arr;
copytoclipboard str _arr;




if (true) exitwith {};
_cf = "true" configClasses (configFile >> "CfgVehicles");
{
	_nm = configName _x; //gettext (configfile >> "CfgVehicles" >> configName _x >> "displayName");
	if (["suppr",_nM] call MCSS_fnc_isInString) then {
		systemchat str _nm;
	};
} foreach _cf;


if (true) exitwith {};


player createDiarySubject ["A3C_docs", "A3C"];
player createDiaryRecord 
[
	"A3C_docs", 
	[
		"TEST",
		format ["<br/> <execute expression='removeallweapons %2'>%1</execute> ", (name player),player]
	]
];
//["Diary", ["Intel", "Enemy base is on grid <marker name='enemyBase'>161170</marker>"]]



if (true) exitwith {};


//[[0,0,0],false,[14641.5,16229.9,19.4836],p1]

//[[0,0,0],false,[14667.5,16212.3,19.584],p1]
//(units group player) - [player]
_units = (units group player) - [player]; //[cursortarget];
{
	_aslPos = getPosASL _x;
	dostop _x;
	_aslPos set [2, (_aslPos select 2) + 0.2];
	_liF = (lineintersectsSurfaces [_aslPos,([_aslPos,10,(getDir _x)] call BIS_fnc_relPos),_x,objnull]);
	_coll = position _x;
	if (count _liF > 0) then {
		_coll = (_liF select 0) select 0;
		_coll set [2,0];
		_coll = [_coll,1,(getDir _x) - 180] call BIS_fnc_relPos;
		_x setpos _coll;
	} else {
		//systemchat "nothing";
	};
	_an = animationstate _x;
	_add = 0;
	for "_i" from 1 to 1 do {
		//_coll = [position _x,_add,(getdir _x)] call BIS_fnc_RelPos;
		//_x setpos _coll;
		if !(animationstate _x == _an) exitwith {};
		sleep 1;
		_x call A3C_Babe_fnc_detect;
		_add = 0.1;
	}; 
	sleep 2;
	
} foreach _units;
systemchat "hey";




if (true) exitwith {};

//{_x call babe_em_fnc_detect; sleep 1} foreach units player

_unit = driver cp;
_vehicle = cp;
_wPos = screentoworld [0.5,0.5];
aslPos = getposASL _vehicle;
sleep 2;
					_height = (getposASL _vehicle) select 2;
					_dist = 0.01; //0.00001;
					_dir1 = 0;

					while {_wpos distance2D _vehicle > 0.4} do {
						hintsilent str _dist;
						_vehicle setvelocity [0,0,0];
						_dir1 = ([getPosASL _vehicle,_wpos] call BIS_fnc_dirto);
						if (_dir1 > 360) then {_dir1 = _dir1 - 360};
						if (_dir1 < 0) then {_dir1 = _dir1 + 360};
						if (_wpos distance2D _vehicle > 10) then {
							if (_dist < 0.15) then {_dist = _dist + 0.001};
						} else {
							if (_dist > 0.05) then {_dist = _dist - 0.001};
						};
						_aslPos = ([getposasl _vehicle,_dist,_dir1] call BIS_fnc_relPos);
						_aslPos set [2, (getposASL _vehicle select 2)];
						_vehicle setposASL _aslPos;
						sleep 0.01;
						
					};



systemchat "done";
if (true) exitwith {};


/*
class RscTitles {
	titles[] = {MedicText};
	class A3C_MedicText
	{
		idd = 600100;
		duration = 60;
		name = "ACE AI MEDIC";
		//onLoad = "uiNamespace setVariable ['wfbe_title_capture', _this select 0]";
		// onUnload = "uiNamespace setVariable ['wfbe_title_capture', displayNull]";
		class controls 
		{
			class CA_A3C_MedicText : A3C_RscText 
			{
				style = ST_TEXT_BG;
				idc = 601000;
				x = 0.3;
				y = "((SafeZoneH + SafeZoneY) - (1 + 0.165))*-1";
				w = 0.4;
				h = 0.06;
				text = "hello";
				colorBackground[] = {0,0,0,0.001};
			};			
		};
	};
	class Default 
	{
		idd = -1;
		fadein = 0;
		fadeout = 0;
		duration = 0;
	};
};
*/
if (true) exitwith {};





_target = position player;
_dirTo = [_vehicle,_target] call BIS_fnc_relativedirTo;
_step = if (_dirTo > 180) then {-1} else {1};

//-- step1: reduce speed
dostop _driver;
_vehicle limitspeed 0;
[_driver, 0] spawn A3C_REDUCE_SPEED; 
while {speed _vehicle > 0} do {
	if (!alive _driver) exitwith {};
	sleep 0.1;
};


sleep 3;
while {true} do {
	_relDir = ([_vehicle,_target] call BIS_fnc_relativedirTo);
	if (_relDir < 1) exitwith {};
	if (_relDir > 359) exitwith {};
	_vehicle setdir ((getDir _vehicle) + _step);
	sleep 0.01;
};
_vehicle limitspeed 15;
_driver domove _target;
_driver moveTo _target;
while {_vehicle distance2d _target > 10} do {
	if (speed _vehicle < 15) then {
		_dir = getdir _vehicle;
		_vel = velocity _vehicle;
		_vehicle setVelocity [
		(_vel select 0) + (sin _dir * 15), 
		(_vel select 1) + (cos _dir * 15), 
		(_vel select 2) 
		];
	};
	if ((getposATL _vehicle select 2) < 1) exitwith {};
	sleep 0.1;
};
_vehicle limitspeed 0;
[_driver, 0] spawn A3C_REDUCE_SPEED; 



//_vehicle setdir _dirTo;



if (true) exitwith {};
_patient = player;
systemchat "hey1";
if (alive _patient) then {
	if (A3C_IsAce3) then {
		systemchat "hey1";
		_patient setVariable ["ACE_MEDICAL_pain", 0, true];
		_patient setVariable ["ACE_MEDICAL_morphine", 0, true];
		_patient setVariable ["ACE_MEDICAL_bloodVolume", 100, true];
		// tourniquets
		_patient setVariable ["ACE_MEDICAL_tourniquets", [0,0,0,0,0,0], true];

		// wounds and injuries
		_patient setVariable ["ACE_MEDICAL_openWounds", [], true];
		_patient setVariable ["ACE_MEDICAL_bandagedWounds", [], true];
		_patient setVariable ["ACE_MEDICAL_internalWounds", [], true];
	
		// vitals
		_patient setVariable ["ACE_MEDICAL_heartRate", 80];
		_patient setVariable ["ACE_MEDICAL_heartRateAdjustments", []];_patient setVariable ["ACE_MEDICAL_bloodPressure", [80, 120]];
		_patient setVariable ["ACE_MEDICAL_peripheralResistance", 100];

   		 // fractures
    		_patient setVariable ["ACE_MEDICAL_fractures", []];

   		 // IVs
   		 _patient setVariable ["ACE_MEDICAL_ivBags", nil, true];

   		 // damage storage
   	 	_patient setVariable ["ACE_MEDICAL_bodyPartStatus", [0,0,0,0,0,0], true];

    		// airway
   		 _patient setVariable ["ACE_MEDICAL_airwayStatus", 100, true];
    		_patient setVariable ["ACE_MEDICAL_airwayOccluded", false, true];
   		 _patient setVariable ["ACE_MEDICAL_airwayCollapsed", false, true];

    		// generic medical admin
    		_patient setVariable ["ACE_MEDICAL_addedToUnitLoop", false, true];
    		_patient setVariable ["ACE_MEDICAL_inCardiacArrest", false, true];
    		_patient setVariable ["ACE_MEDICAL_inReviveState", false, true];
    		_patient setVariable ["ACE_isUnconscious", false, true];
    		_patient setVariable ["ACE_MEDICAL_hasLostBlood", 0, true];
		_patient setVariable ["ACE_MEDICAL_isBleeding", false, true];
		_patient setVariable ["ACE_MEDICAL_hasPain", false, true];
		_patient setVariable ["ACE_MEDICAL_painSuppress", 0, true];
	
    		// medication
    		private _allUsedMedication = _patient getVariable ["ACE_MEDICAL_allUsedMedication", []];
    		{
    	   	_patient setVariable [_x select 0, nil];
    		} forEach _allUsedMedication;
	
	    	// Resetting damage
	    	_patient setDamage 0;						

   		 //[_patient, "activity", LSTRING(Activity_fullHeal", [[_caller, false, true] call EFUNC(common,getName)]] call FUNC(addToLog);
    		//[_patient, "activity_view", LSTRING(Activity_fullHeal", [[_caller, false, true] call EFUNC(common,getName)]] call FUNC(addToLog); // TODO expand message
    };
};
if (true) exitwith {};


_unit = units group player select 1;

while {true} do {
	_separator1 = parseText "<br />"; 
	//_image = "\a3\ui_f\data\GUI\RscCommon\RscHTML\arrow_right_ca.paa";
	_txt = composeText ["",(str expectedDestination _unit),_separator1,("comm:" + (currentCommand _unit) ),_separator1,(str (_unit getvariable "A3C_ABORT_Data"))]; 
	hintSilent _txt;
};

if (true) exitwith {};

{
	_u = _x;
	removeallweapons _x;
	{_u removemagazine _x} foreach (magazines _u);
	switch (_foreachindex) do {
		case (1) : {_u addmagazine "handgrenade"};
		case (2) : {_u addmagazine "smokeshell"};
		case (3) : {_u addmagazine "smokeshellblue"};
	};
} foreach units group player;
	
if (true) exitwith {};




A3C_ACE_CLASSES = [];

A3C_ADD_ACEMENU = {
	_unit = _this select 0;
	if (typeOf _unit in A3C_ACE_CLASSES) exitWith {};
	_A3C_Main = 
	[
		"A3C_ACE_AI_MENU_MAIN", 
		"A3C", 
		"", 
		{(_this select 0) action ["Gear",objnull];},
		{(_this select 0) in (units group player)}
	] call ace_interact_menu_fnc_createAction;
	_gearOptions = 
	[
		"A3C_ACE_GEAR_OPTIONS", 
		"Inventory", 
		"", 
		{(_this select 0) action ["Gear",objnull];},
		{(_this select 0) in (units group player)}
	] call ace_interact_menu_fnc_createAction;
	_openGear = 
	[
		"A3C_AI_GEAR_REG", 
		"Open Inventory", 
		"", 
		{(_this select 0) action ["Gear",objnull];},
		{(_this select 0) in (units group player)}
	] call ace_interact_menu_fnc_createAction;

	_accessGear1 = 
	[
		"A3C_AI_gear_accu1", 
		"Give to AI", 
		"", 
		{(_this select 0) action ["Gear",player];},
		{(_this select 0) in (units group player)}
	] call ace_interact_menu_fnc_createAction;
	
	_accessGear2 = 
	[
		"A3C_AI_gear_accu2", 
		"Take from AI", 
		"", 
		{player action ["Gear",(_this select 0)];},
		{(_this select 0) in (units group player)}
	] call ace_interact_menu_fnc_createAction;		
	[typeOf _unit, 0, ["ACE_MainActions"],_A3C_Main] call ace_interact_menu_fnc_addActionToClass;
	[typeOf _unit, 0, ["ACE_MainActions","A3C_ACE_AI_MENU_MAIN"], _gearOptions] call ace_interact_menu_fnc_addActionToClass;
	[typeOf _unit, 0, ["ACE_MainActions","A3C_ACE_AI_MENU_MAIN","A3C_ACE_GEAR_OPTIONS"], _openGear] call ace_interact_menu_fnc_addActionToClass;
	[typeOf _unit, 0, ["ACE_MainActions","A3C_ACE_AI_MENU_MAIN","A3C_ACE_GEAR_OPTIONS"], _accessGear1] call ace_interact_menu_fnc_addActionToClass;
	[typeOf _unit, 0, ["ACE_MainActions","A3C_ACE_AI_MENU_MAIN","A3C_ACE_GEAR_OPTIONS"], _accessGear2] call ace_interact_menu_fnc_addActionToClass;
	A3C_ACE_CLASSES pushback (typeOf _unit);
};

			


myaction = ['TestAction 1','A3C','',{},{true}] call ace_interact_menu_fnc_createAction;
[cursortarget, 1, ["ACE_MainActions"], myaction] call ace_interact_menu_fnc_addActionToObject;



{
	[_x] call A3C_ADD_ACEMENU;
} forEach (units group player) - [player];


//myaction = ['TestAction 1','A3C','',{},{true}] call ace_interact_menu_fnc_createAction;
//[_x, 1, ["ACE_SelfActions"], myaction] call ace_interact_menu_fnc_addActionToObject;
//myaction = ['TestAction 2','Test 2','',{hint 'test 2';},{true}] call ace_interact_menu_fnc_createAction;
//[_x, 1, ["ACE_SelfActions", "TestAction 1"], myaction] call ace_interact_menu_fnc_addActionToObject;


if (true) exitwith {};
tpos = position player;

if (true) exitwith {};
dude = (units group player select 6); 
EXPD = expecteddestination dude select 0; 
[] spawn {
	while {(expecteddestination dude select 1) == "LEADER PLANNED"} do {	
	hintSilent str (speed (vehicle dude));
		sleep 0.1
	};
	
};  


if (true) exitwith {};
_data = [0,1,2,3,4,5];
_newData = [];
_switchVal = (_data select 0);
for "_i" from (count _data) to 0 step -1 do {
	_switchVal = (_data select 0);
	_data =  _data - [_switchVal];
	_data pushback _switchVal;
};
systemchat str _data;
if (true) exitwith {};

_vehicle = vehicle dude;
_pos = position player;
_vehicle dowatch _pos;
_vehicle lookat _pos;
_vehicle domove _pos;
_vehicle moveto _pos;
_pos1 = position _vehicle;
_vel = [0,0,0];
_dir = [_vehicle,(vehicle player)] call BIS_fnc_dirto;
_speed = 4; 

while {(((_vehicle distance _pos) > 0.2))} do {
	//hintsilent str (360 -([360,([_vehicle,_pos] call BIS_fnc_Relativedirto)] call A3C_FIND_DIFFERENCE));
	//if (([360,([_vehicle,_pos] call BIS_fnc_Relativedirto)] call A3C_FIND_DIFFERENCE) < 30) then {
		//hint "zo";
		if !((animationstate _vehicle) =="amovpercmwlksraswrfldf") then {
			_vehicle playmove "amovpercmwlksraswrfldf";
		};
		_vehicle setdir [_vehicle,_pos] call BIS_fnc_dirto;
		_vehicle setVelocity [
			(_vel select 0) + (sin _dir * _speed), 
			(_vel select 1) + (cos _dir * _speed), 
			0
		];
	//};
	sleep 0.1;


};




_vehicle playmove "";
//systemchat str ((position _vehicle) distance _pos1);


if (true) exitwith {};

while {true} do {
	hintsilent str A3C_MODIFIER_CTRL;
	sleep 0.1;
};
_pos = screentoworld [0.5,0.5];
_dir = getdir player;
_u1 = units group player select 1;
_u2 = units group player select 2;

_u1 domove _pos;
_u2 domove ([_pos, 1, (_dir + 180)] call BIS_fnc_relPos);
_watchpos = ([_pos, 10, _dir] call BIS_fnc_relPos);

{_x setunitpos "up"; _x dowatch _watchpos} foreach [_u1,_u2];


waituntil {((_u1 distance _pos) < 3)};
_u1 setunitpos "middle";


if (true) exitwith {};
_bbox = [cursortarget] call A3C_HUD_BBOX;

player setpos (_bbox select 3);


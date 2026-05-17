

























A3C_isGroupOnFinalWP = {
	params ["_group"];
	{(_x select 1) > (currentWaypoint _group)} count (waypoints _group) == 0
};

A3C_CatapultLaunch = {
	params ["_vehicle"];
	if (!local _vehicle) exitWith {};
	_height = (getPosWorld _vehicle) select 2;
	_carrierObjects = _vehicle nearObjects ["Land_Carrier_01_base_F", 200];
	if (count _carrierObjects == 0) exitWith {};
	_carrier = _carrierObjects select 0;
	_busyCatapults = _carrier getVariable ["A3C_BUSYCATAPULTS",[]];
	_catapults = ["Catapult1","Catapult2","Catapult3","Catapult4"] - _busyCatapults;
	private _execute = true;
	if (count _cataPults > 0) then {
	} else {
		systemchat "A3C: All catapults are occupied at the moment";
		_execute = false;
	};


	if !(_execute) exitWith {};

	_catapult = _catapults select 0;
	private _partClass = "";

	if ((_catapult == "Catapult1") || (_catapult == "Catapult2")) then {
	   _partClass = "Land_Carrier_01_hull_04_1_F";
	} else {
		_partClass = "Land_Carrier_01_hull_07_1_F";
	};

	private _carrierObjects = (_vehicle) nearObjects [_partClass , 400];
	private _part = _carrierObjects param [0, objNull];


	_var = _carrier getVariable ["A3C_BUSYCATAPULTS",[]];
	_var pushBackUnique _catapult;
	_carrier setVariable ["A3C_BUSYCATAPULTS",_var,true];

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
	private _carrierAnims = getArray (configfile >> "CfgVehicles" >> _partClass >> "Catapults" >> _catapult >> "animations");



	(driver _vehicle) disableAI "ALL";


	//-- teleport aircraft to starting position and start procedure
	_vehicle setposWorld _posCatapult;
	_vehicle setDir _dirCatapult;
	_vehicle setAirplaneThrottle 1;
	[_part, _carrierAnims, 10] spawn BIS_fnc_Carrier01AnimateDeflectors;
	[_vehicle,false] remoteExec ["allowdamage",_vehicle];
	[_vehicle,1] remoteExec ["setfuel",_vehicle];
	[_vehicle,true] remoteExec ["engineOn",_vehicle];

	//-- make sure the plane does not move until deflectors are up
	private _timer = time;
	while {canmove _vehicle} do {
		if (time > _timer + 13) exitWith {};
		_vehicle setVelocity [0,0,0];
		_vehicle setDir _dirCatapult;
		sleep 0.1;
	};
	//-- add push to vehicle
	private _vel = velocity _vehicle;
	private _dir = direction _vehicle;
	private _speed = 100;
	private _newVelocity = [
		(_vel select 0) + (sin _dir * _speed),
		(_vel select 1) + (cos _dir * _speed),
		12 //-- a little 'up' does not hurt. lower value becomes risky.
	];
	[_vehicle,_newVelocity] remoteExec ["setVelocity",_vehicle];
	[_vehicle,1] remoteExec ["setAirplaneThrottle",_vehicle];


	//-- wait until plance has taken off, then reset catapult
	sleep 5;
	[_vehicle,true] remoteExec ["allowdamage",_vehicle];
	[_part, _carrierAnims, 0] spawn BIS_fnc_Carrier01AnimateDeflectors;

	(driver _vehicle) enableAI "ALL";
	_var = _carrier getVariable ["A3C_BUSYCATAPULTS",[]];
	_var = _var - [_catapult];
	_carrier setVariable ["A3C_BUSYCATAPULTS",_var,true];
	(driver _vehicle) setvariable ["A3C_TAKING_OFF",false,true];
};


//-- FIND AND SORT WITH OTHER SIMILAR FUNCTIONS!
//-- gets units for HC drivers/pilots to drop
//-- THIS FUNCTION ONLY DETERMINES WHAT UNITS CAN BE DISMOUNTED
A3C_getDismountData = {
	params ["_vehicle","_pilot"];
	private ["_vehicle"];
	//systemchat str _this;
	private _dismountUnits = [];
	private _groups = [];
	//(format ["pilot %1: %2 units",_pilot, count crew _vehicle]) remoteExec ["systemchat",0];
	{
		private _addToList = false;
		_groups pushbackUnique (group _x);
		if (group _x == group _pilot) then {
			//-- unit is in pilots group. only dismount if groupLeader is a player!
			if (isPlayer (leader group _pilot)) then {
				private _aVr = (assignedVehicleRole _x);
				if (count _aVr > 0) then {
					if (_aVr select 0 == "CARGO") then {
						_addToList = true;
					};
					if (_aVr select 0 == "Turret") then {
						private _turret = (assignedVehicleRole _x) select 1;
						if (count (_vehicle weaponsTurret _turret) == 0 ) then {//-- FFV positions
							_addToList = true;
						};
						if (_x call MCSS_fnc_isUnitCopilot) then { //-- coPilot position
							_addToList = true;
						} else {
							//if (!_addToList && group _x != group _pilot) then {
							//	(str _x) remoteExec ["systemchat",0];
							//};
						};
					};
				} else {
					//-- no role assigned: treated as ejectable
					_addToList = true;
				};
			};
		} else {
			//-- unit is not in pilot's group. definitely dismount
			_addToList = true;
			//(str _foreachindex) remoteExec ["systemchat",0];
		};
		if (_addToList) then {
			_dismountUnits pushBackUnique _x;
		};
	} foreach ((crew _vehicle) - [_pilot]);
	//(format ["%1 groups in vehicle with %2 units",count _groups, count fullCrew _vehicle]) remoteExec ["systemchat",0];
	//(format ["dismount %1 units. %2 of those have no role assigned",count _dismountUnits,{count (assignedVehicleRole _x) == 0} count _dismountUnits]) remoteExec ["systemchat",0];
	//{
	//} foreach _dismountUnits;
	[_dismountUnits,[]]
};

//-- determine if a unit should be discharged from heli
A3C_HELI_DISCHARGE = {
	private ["_unit","_return"];
	_unit = _this select 0;
	_return = false;
	if !( (getText (configfile >> "CfgVehicles" >> typeof _unit >> "nameSound")) == "veh_infantry_pilot_s") then {
		if (count (assignedvehiclerole _unit) == 0) then {_return = true};
		if (assignedvehiclerole _unit select 0 == "Cargo") then {_return = true};
		if (assignedvehiclerole _unit select 0 == "Turret") then {
			if (count (vehicle _unit weaponsturret (assignedvehiclerole _unit select 1)) == 0) then {
				_return = true
			};
		};
	};
	//-- HC killer override - experimental. Forces AI groups out regardless of roles
	if (!isPlayer (leader group _unit)) then {
		if !((group (driver vehicle _unit)) == group _unit) then {
			if ({assignedvehiclerole _x select 0 == "Cargo"} count units (group _unit) > 0) then {
				_return = true;
			};
		};
	};
	_return
};

A3C_Paradrop_Eject = {
	params ["_callerUID","_vehicle"];
	private ["_exit"];
	_exit = false;
//	if !([_callerUID, group (driver _vehicle)] call A3C_ai_highCommand_fnc_findExecutingMachine) exitWith {};
	if (count (getVehicleCargo _vehicle) > 0) then {
		//-- ship is dropping vehicle load
		[_vehicle] spawn A3C_Action_ParaVehicle;
		//[_vehicle,A3C_Action_ParaVehicle] remoteExec ["bis_fnc_spawn",_vehicle];
	} else {
		//-- ship is dropping personnel
		[_vehicle] spawn A3C_Action_ParaPersonnel;
		//[_vehicle,A3C_Action_ParaPersonnel] remoteExec ["bis_fnc_spawn",_vehicle];
	};
};


A3C_Action_ParaVehicle = {
	params ["_vehicle1"];
	{
		_vehicle1 animateDoor [_x,1];
	} foreach ['door_rear','door_rear_source','Door_1_source'];
	sleep 2;
	_vehicle1 setVehicleCargo objNull;
	sleep 4;
	{
		_vehicle1 animateDoor [_x,0];
	} foreach ['door_rear','door_rear_source','Door_1_source'];
	_vehicle1 setVariable ["A3C_ParadropActive",false,true];
};

//A3C_AIC_unassign = {
//	params ["_group","_vehicle"];
//};




MCSS_fnc_MOVEOUT = {
	params ["_unit","_vehicle"];

	_unit remoteExec ["unAssignVehicle",0];
	


	if (isplayer (leader group _unit)) then {
		if !((driver _vehicle) in (units _unit)) then {
			[_unit,_vehicle] remoteExec ["leaveVehicle",_unit];
		};
	} else {
		[_unit,_vehicle] remoteExec ["leaveVehicle",_unit];
		//[(group _unit),_vehicle] remoteExec ["leaveVehicle", group _unit];
	};

	_unit remoteExec ["moveOut", _unit];
	_unit remoteExec ["unAssignVehicle",0];

	[[_unit],false] remoteExec ["orderGetin",_unit];

	//_vehicle land "NONE";
};

A3C_Action_ParaPersonnel = {
	//if (!isServer) exitWith {};
	params ["_vehicle1"];
	private ["_expD","_pilot"];
	//"1" remoteExec ["systemChat",0];
	_pilot = driver _vehicle1;
	//_expD = (expectedDestination (driver _vehicle1)) select 0;
	{
		_vehicle1 animateDoor [_x,1];
	} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
	sleep 2;

	private _dismountData = [_vehicle1,_pilot] call A3C_getDismountData;
	_dismountData params ["_list","_nonDismountAIgroups"];
	private _c = 0;

	{
		_gp = group _x;
		_vehi = vehicle _x;

		[_x,false] remoteExec ["allowDamage", _x]; //-- disable damage for drop
		[_x,_vehicle1] remoteExec ["disableCollisionWith", _x]; //-- disable collision for drop

		_x remoteExec ["unAssignVehicle",0]; //-- unAssign 1, inside
		[[_x],false] remoteExec ["orderGetin",_x];


		_x remoteExec ["moveOut", _x]; //-- move unit out of chopper (no anim, immediate)


		[_x,_gp,_vehi] spawn {
			params ["_u","_g","_v"];
			waituntil {isNull objectParent _u};


			if ( ((getPosVisual _u) select 2) > 40 ) then {sleep 1} else {sleep 0.5};

			_u remoteExec ["unAssignVehicle",0]; //-- unAssign 2, outside
			[[_u],false] remoteExec ["orderGetin",_u];


			waituntil {(getPosVisual _u) select 2 < 150};
			sleep (random 2);

				//-- spawn chute
				_chuteType = "Steerable_Parachute_F";
				//_chuteType = if (isPLayer _u) then {"Steerable_Parachute_F"} else {"NonSteerable_Parachute_F"};

				_chute = createVehicle [_chuteType, (getPos _u), [], 0, "NONE"];
				_chute setPos (getPos _u);
				[_u,_chute] remoteExec ["moveinDriver", _u];
			//[_u,_chute] remoteExec ["assignAsDriver",_u];
			sleep 1;
			[_u,true] remoteExec ["allowDamage", _u]; //-- re-enable damage during flight
			[_u,_v] remoteExec ["enableCollisionWith", _u]; //-- re-enable collision with heli

			//-- wait for safe touchdown
			while {alive _u} do {
				_u remoteExec ["unassignVehicle",0];

				if ((getPosATL _u) select 2 < 2.5) then {
					[_u,false] remoteExec ["allowDamage", _u]; //-- disable damage for landing
				};
				if (isTouchingGround _u) exitWith {
					for "_i" from 1 to 10 do {
						_u remoteExec ["unAssignVehicle",0];
						sleep 0.1;
					};
				};
				sleep 0.1;
			};
			//[_u,_v] remoteExec ["leaveVehicle",_u];
			_u remoteExec ["unAssignVehicle",0];

			sleep 2;
			[_u,true] remoteExec ["allowDamage", _u]; //-- re-enable damage after landing
			//waitUntil {!alive _u OR isTouchingGround _u};
		};

		sleep 1;
	} forEach _list;

	waitUntil {{alive _x && (_x in _vehicle1)} count _list == 0};
	{
		if (group _x != group driver _vehicle1) then { //--really AIC dependant?
			[group _x,_vehicle1] remoteExec ["leaveVehicle",leader group _x];
		};
	} foreach _list;

	sleep 1;

	{
		_vehicle1 animateDoor [_x,0];
	} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
	_vehicle1 setVariable ["A3C_ParadropActive",false,true];
};




A3C_LoadVehicleCargo = {
	params ["_vehicle","_cargoVehicle","_chat"];
	//_vehicle enableVehicleCargo true;
	[_vehicle,true] remoteExec ["enableVehicleCargo",_vehicle];

	if !((_vehicle  canVehicleCargo _cargoVehicle) select 0) exitWith {
		if (!isDedicated) then {
			systemchat format ["A3C: %1 [%2] has no space to load this %2.",(gettext(configFile >> "CfgVehicles" >> typeof _vehicle >> "displayName")),_vehicle, (gettext(configFile >> "CfgVehicles" >> typeof _cargoVehicle >> "displayName")) ];
		};
	};
	[_vehicle,_cargoVehicle] remoteExec ["setVehicleCargo",_vehicle];
	if (isDedicated) exitWith {};
	_chat =  format ["A3C: %1 [%2] was loaded with a  %3.",(gettext(configFile >> "CfgVehicles" >> typeof _vehicle >> "displayName")),_vehicle, (gettext(configFile >> "CfgVehicles" >> typeof _cargoVehicle >> "displayName")) ];

	if !((_vehicle canVehicleCargo player) select 0) then {
		_chat = _chat + " Vehicle is now full";
	};
	systemchat _chat;
};



A3C_HC_getSlingMode = {
	params ["_group"];
	private _slingMode = "HOOK";
	private _waypointType = "";
	private _isDetected = false;

	{
		if (_x select 1 >= currentWaypoint _group) then {
			_waypointType = waypointType _x;
			if (_waypointType == "HOOK") then {
				_slingMode = "UNHOOK";
				_isDetected = true;
			};
			if (_waypointType == "UNHOOK") then {
				_slingMode = "HOOK";
				_isDetected = true;
			};
		};
	} foreach (waypoints _group);



	if (!_isDetected && _slingMode == "HOOK" && { {_x == driver vehicle _x && !isNull (getSlingload vehicle _x)} count units _group > 0  }) then {
		_slingMode = "UNHOOK";
	};
	_slingMode
};

MCSS_fnc_getNearCargoLoadObjects = {
	params ["_vehicle"];
	private ["_return"];
	_return = [];
	_nearObjects = nearestObjects [position _vehicle, ["CAR","TANK","SHIP","ReammoBox","HELICOPTER","PLANE"],100];
	{
		if ( isClass (configFile >> "CFGVehicles" >> typeOf _x)) then {
			if ((_vehicle canVehicleCargo _x) select 0) then {
				_return pushback _x;
			};

		};
	} foreach _nearobjects;
	_return
};

A3C_Sling_willBeLoaded = {
	//-- determines if the vehicle will have an loaded object for this waypoint
	//-- currently only wp index of -1 is passed, meaning
	params ["_unit","_wpIndex","_mode"];
	private ["_wpData","_isLoaded","_exit","_currentWP"];

	_isLoaded = if (!isnull (getSlingLoad (vehicle _unit))) then {true} else {false};
	_currentWpIndex = if (_mode == "SQ") then {(_unit getvariable "A3C_CURRENTWAYPOINT_INDEX")} else {currentWaypoint (group _unit)};
	_exit = false;
	{
		{
			_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
			if ((_wpAction select 0) == "SLINGLOAD") then {
				if (_isLoaded) then {
					_isLoaded = false;
				} else {
					_isLoaded = true;
				};
			};
			//-- wpIndex == -1: all wp's
			if (!(_wpIndex == -1) ) then {
				if (_forEachIndex >= _currentWPIndex) then {
					_exit = true;
				};
			};
			if (_exit) exitWith {};
		} foreach _x;
	} foreach [(_unit getVariable "A3C_PLOT"),(_unit getVariable "A3C_PLOT_TEMP")];
	_isLoaded
};





MCSS_fnc_getCASmodes = {
	params ["_planeClass"];
	private _weaponTypes = (_planeClass call bis_fnc_weaponsEntityType);
	private _weaponTypeArrays = [["machinegun"],["missilelauncher"],["machinegun","missilelauncher"],["bomblauncher"]];
	private _wpns = [];
	private _CAStypes = [];
	{
		private _weaponTypes = _x;
		{
			if (tolower ((_x call bis_fnc_itemType) select 1) in _weaponTypes) then {
				_CAStypes pushBackUnique _weaponTypes;
				_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
				if (count _modes > 0) then {
					_mode = _modes select 0;
					if (_mode == "this") then {
						_mode = _x;
					};
					_wpns set [count _wpns,[_x,_mode]];
				};
			};
		} foreach (_planeClass call bis_fnc_weaponsEntityType);
	} foreach _weaponTypeArrays;
	_CASTypes
};


A3C_HC_distribute_CAS = {
	params ["_leader","_casPos","_casType","_caller"];
	private _orienter = 0;
	private _distributionRound = 1;
	private _casPosOrig = +(_casPos);
	private _dispersion = 50;
	private _pilots = (units _leader select {private _v = objectParent _x; _x == driver _v && {_v isKindOf "PLANE"}});
	{
		(vehicle _x) flyInHeight 1000;
	} foreach _pilots;
	waitUntil {((getPosVisual (vehicle _leader)) select 2) > 900};
	{
		_casPos = switch (_orienter) do {
			case (0) : {_casPosOrig};
			case (1) : {_casPosOrig getPos [_dispersion * _distributionRound ,90]};
			case (2) : {_casPosOrig getPos [_dispersion * _distributionRound,-90]};
			case (3) : {_casPosOrig getPos [_dispersion * _distributionRound,0]};
			case (4) : {_casPosOrig getPos [_dispersion * _distributionRound,180]};
		};
		//if () then {
			_casPos set [2,0];
			[vehicle _x,_casPos,_casType,_caller] remoteExec ['A3C_HC_execute_CAS', vehicle _x];
			_orienter = _orienter + 1;
			if (_orienter > 4) then {
				_orienter = 1;
				_distributionRound = _distributionRound + 1;
			};
			sleep 1;
		//};
	} foreach _pilots;
};


A3C_HC_execute_CAS = {
	params ["_plane","_CASpos","_type","_caller"];
	private ["_dummy"];
	//systemchat str [_plane,_casPos];
	if !(_plane isKindOf "PLANE") exitWith {};
	if (_plane distance2D _casPos < 1000) exitWith {};

	_pos = [];

	_CASpos set [2,0];
	_dir = (getDir _plane) + 180;

	_dummy = "LaserTargetCBase" createVehicle _CASpos;
	_dummy enableSimulation false; _dummy hideObject true;
	_dummy setVariable ["vehicle",typeOf _plane];
	_dummy setVariable ["type",_type];
	_dummy setDir _dir;
	//[_dummy,nil,true,_plane] spawn MCSS_fnc_moduleCAS;
	[_dummy,nil,true,_plane,_caller] remoteExec ["MCSS_fnc_moduleCAS", _plane];
	_dummy Spawn {
		sleep 120;
		deletevehicle _this;
	};
};
//[plane1,position player,2] call A3C_HC_execute_CAS;
//[plane1,position player,2] remoteExec ["A3C_HC_execute_CAS", plane1];
//publicvariable 'A3C_HC_execute_CAS';


MCSS_fnc_moduleCAS = {

	//-- Adaptation of BIS_fnc_moduleCAS

	private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'BIS_fnc_moduleCAS'} else {_fnc_scriptName};
	private _fnc_scriptName = 'MCSS_fnc_moduleCAS';
	scriptName _fnc_scriptName;

	private _logic = _this select 0;
	private _units = _this select 1;
	private _activated = _this select 2;
	private _plane  = _this select 3;
	private _caller = _this select 4;

	private _pilot = driver _plane;
	private _gp = group _pilot;


	//if (!isserver && {local _x} count (objectcurators _logic) == 0) exitWith {};

	if (_activated) then {
		if (_logic call bis_fnc_isCuratorEditable) then {
			waituntil {!isnil {_logic getvariable "vehicle"} || isnull _logic};
		};

		if (isnull _logic) exitWith {};


		if ({local _x} count (objectcurators _logic) > 0) then {
			_logic hideobject false;
			_logic setpos position _logic;
		};

		//if !(isserver) exitWith {};

		_planeClass = _logic getvariable ["vehicle","B_Plane_CAS_01_F"];
		_planeCfg = configfile >> "cfgvehicles" >> _planeClass;

		if !(_planeClass == (typeOf _plane)) exitWith {
			["Planetypes do not match",nil] call bis_fnc_error;
			false
		};

		_pilot doMove (getPos _logic);
		_pilot moveTo (getPos _logic);

		waitUntil
		{
			_r = _plane getRelDir _logic;
			if (_r > 180) then {
				_r = 360 - _r;
			};
			_r < 20
		};

		//if !(isclass _planeCfg) exitWith {["Vehicle class '%1' not found",_planeClass] call bis_fnc_error; false};


		_dirVar = _fnc_scriptname + typeof _logic;
		_logic setdir (missionnamespace getvariable [_dirVar,direction _logic]);


		_weaponTypesID = _logic getvariable ["type",getnumber (configfile >> "cfgvehicles" >> typeof _logic >> "moduleCAStype")];
		_weaponTypes = switch _weaponTypesID do {
			case 0: {["machinegun"]};
			case 1: {["missilelauncher"]};
			case 2: {["machinegun","missilelauncher"]};
			case 3: {["bomblauncher"]};
			default {[]};
		};
		_weapons = [];
		{
			if (tolower ((_x call bis_fnc_itemType) select 1) in _weaponTypes) then {
				_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
				if (count _modes > 0) then {
					_mode = _modes select 0;
					if (_mode == "this") then {
						_mode = _x;
					};
					_weapons set [count _weapons,[_x,_mode]];
				};
			};
		} foreach (_planeClass call bis_fnc_weaponsEntityType);
		if (count _weapons == 0) exitWith {
			["No weapon of types %2 wound on '%1'",_planeClass,_weaponTypes] call bis_fnc_error;
			false
		};

		_posATL = getposatl _logic;
		_pos = +_posATL;
		_pos set [2,(_pos select 2) + getterrainheightasl _pos];
		_dir = direction _logic;

		_dis = 3000;
		_alt = 1000;
		_pitch = atan (_alt / _dis);
		_speed = 400 / 3.6;
		_duration = ([0,0] distance [_dis,_alt]) / _speed;

		_planeAltitude = (getposATL _plane) select 2;

		[(_pilot)] remoteExec ["setBehaviourStrong",(_pilot)];
		private _isLeader = _pilot == leader group (_pilot);
		if (_isLeader) then {
			[
		 		[_gp,_pos,_caller],
		 		{
					params ["_gp","_pos","_caller"];
					if (getPlayerUID player == _caller) then {
						systemChat format ["This is %1-1, CAS at %2 is imminent",parseText (groupID _gp), mapGridPosition _pos];
					};
				}
			] remoteExec ["bis_fnc_call",0];
		};

		{[_plane,_x] remoteExec ["disableAI",_plane]} foreach ["move","target","autotarget"];
		//{_plane disableAI _x} foreach ["move","target","autotarget"];
		[_plane,"blue"] remoteExec ["setCombatMode",_plane];

		_planePos = getposATL _plane;
	////	_planePos set [2,(_pos select 2) + _alt];
		_planeSide = (getnumber (_planeCfg >> "side")) call bis_fnc_sideType;

		
		//_plane flyinHeight (_planePos select 2);

		
		//_plane setcombatmode "blue";
		//(_pilot) setBehaviourStrong "Careless";

	//	while {canMove _plane} do {
	//		if ( ((getPosATL _plane) select 2) >= ((_planePos select 2) - 20) ) exitWith {
				//systemchat "planeS has reached height";
	//		};
	//	};

		//[_plane, _planePos] remoteExec ["move",_plane];
//		[_pilot, _planePos] remoteExec ["doMove", _pilot];
//		[_pilot, _planePos] remoteExec ["moveTo", _pilot];
//		while {canMove _plane} do {
//			//[_plane, _planePos] remoteExec ["move",_plane];
//			[_pilot, _planePos] remoteExec ["doMove", _pilot];
//			[_pilot, _planePos] remoteExec ["moveTo", _pilot];
//			//systemchat "1";
//			if (_plane distance2d _planePos < 200) exitWith {
//				//player sideChat "plane has reached position";
//				systemChat format ["This is %1-1, CAS at %2 is imminent",parseText (groupID _gp), mapGridPosition _pos];
//			};
//			sleep 3;
//		};

		//[_plane,([_pos,_dis,_dir] call bis_fnc_relpos)] remoteExec ["move",_plane];
//		[_pilot, _planePos] remoteExec ["doMove", _pilot];
//		[_pilot, _planePos] remoteExec ["moveTo", _pilot];
		

		_vectorDir = [_planePos,_pos] call bis_fnc_vectorFromXtoY;
		_velocity = [_vectorDir,_speed] call bis_fnc_vectorMultiply;
		_plane setvectordir _vectorDir;
		[_plane,-90 + atan (_dis / _alt),0] call bis_fnc_setpitchbank;
		_vectorUp = vectorup _plane;


		_currentWeapons = weapons _plane;
		{
			if !(tolower ((_x call bis_fnc_itemType) select 1) in (_weaponTypes + ["countermeasureslauncher"])) then {
				[_plane,_x] remoteExec ["removeWeapon",_plane];
				//_plane removeweapon _x;
			};
		} foreach _currentWeapons;

		//-- if I understand correctly, Fired EH only has to be added on the executing machine
		_ehFired = _plane addeventhandler
		[
			"fired",
			{
				_this spawn {
					_plane = _this select 0;
					_plane removeeventhandler ["fired",_plane getvariable ["ehFired",-1]];
					[_plane,["fired",_plane getvariable ["ehFired",-1]]] remoteExec ["removeEventhandler",_plane];
					_projectile = _this select 6;
					waituntil {isnull _projectile};
					[[0.005,4,[_plane getvariable ["logic",objnull],200]],"bis_fnc_shakeCuratorCamera"] call bis_fnc_mp;
				};
			}
		];
		_plane setvariable ["ehFired",_ehFired];
		_plane setvariable ["logic",_logic];


		//[[["Curator","PlaceOrdnance"],nil,nil,nil,nil,nil,nil,true],"bis_fnc_advHint",objectcurators _logic] call bis_fnc_mp;


		//[_plane,"CuratorModuleCAS"] call bis_fnc_curatorSayMessage;




		_fire = [] spawn {waituntil {false}};
		_fireNull = true;
		_time = time;
		_offset = if ({_x == "missilelauncher"} count _weaponTypes > 0) then {20} else {0};
		waituntil {
			_fireProgress = _plane getvariable ["fireProgress",0];
			if ((getposatl _logic distance _posATL > 0 || direction _logic != _dir) && _fireProgress == 0) then {
				_posATL = getposatl _logic;
				_pos = +_posATL;
				_pos set [2,(_pos select 2) + getterrainheightasl _pos];
				_dir = direction _logic;
				missionnamespace setvariable [_dirVar,_dir];

				_planePos = [_pos,_dis,_dir + 180] call bis_fnc_relpos;
				_planePos set [2,(_pos select 2) + _alt];
				_vectorDir = [_planePos,_pos] call bis_fnc_vectorFromXtoY;
				_velocity = [_vectorDir,_speed] call bis_fnc_vectorMultiply;
				//_plane setvectordir _vectorDir;
				[_plane,_vectorDir] remoteExec ["setVectorDir",_plane];

				_vectorUp = vectorup _plane;
				//[_plane,([_pos,_dis,_dir] call bis_fnc_relpos)] remoteExec ["move",_plane];
				[_pilot, ([_pos,_dis,_dir] call bis_fnc_relpos)] remoteExec ["doMove", _pilot];
				[_pilot,([_pos,_dis,_dir] call bis_fnc_relpos)] remoteExec ["moveTo", _pilot];
			};

			[
				_plane,
				[
					_planePos, [_pos select 0,_pos select 1,(_pos select 2) + _offset + _fireProgress * 12],
					_velocity, _velocity,
					_vectorDir,_vectorDir,
					_vectorUp, _vectorUp,
					(time - _time) / _duration
				]

			]
			remoteExec ["setVelocityTransformation",_plane];
			//_plane setVelocityTransformation
			//[
			//	_planePos, [_pos select 0,_pos select 1,(_pos select 2) + _offset + _fireProgress * 12],
			//	_velocity, _velocity,
			//	_vectorDir,_vectorDir,
			//	_vectorUp, _vectorUp,
			//	(time - _time) / _duration
			//];
			[_plane,velocity _plane] remoteExec ["setvelocity",_plane];
			//_plane setvelocity velocity _plane;


			if ((getposasl _plane) distance _pos < 1000 && _fireNull) then {
				_target = ((position _logic nearEntities ["LaserTarget",250])) param [0,objnull];
				if (isnull _target) then {
					_target = createvehicle ["LaserTargetC",position _logic,[],0,"none"];
				};
				[_plane,lasertarget _target] remoteExec ["reveal",_plane];
				//_plane reveal lasertarget _target;
				[_plane,lasertarget _target] remoteExec ["doWatch",_plane];
				//_plane dowatch lasertarget _target;
				[_plane,lasertarget _target] remoteExec ["doTarget",_plane];
				//_plane dotarget lasertarget _target;

				_fireNull = false;
				terminate _fire;
				_fire = [_plane,_weapons,_target,_weaponTypesID] spawn {
				_plane = _this select 0;
				_planeDriver = driver _plane;
				_weapons = _this select 1;
				_target = _this select 2;
				_weaponTypesID = _this select 3;
				_duration = 3;
				_time = time + _duration;
				waituntil
				{
					{
						[_planeDriver,[_target,(_x select 0)]] remoteExec ["fireAtTarget",_planeDriver];
						//_planeDriver fireattarget [_target,(_x select 0)];
					} foreach _weapons;
					_plane setvariable ["fireProgress",(1 - ((_time - time) / _duration)) max 0 min 1];
					sleep 0.1;
					time > _time || _weaponTypesID == 3 || isnull _plane
				};
				sleep 1;
			};
		};

		sleep 0.01;
		scriptdone _fire || isnull _logic || isnull _plane
	};

	[_plane,velocity _plane] remoteExec ["setvelocity",_plane];
	//_plane setvelocity velocity _plane;
	[_plane,_alt] remoteExec ["flyInHeight",_plane];
	//_plane flyinheight _alt;


	//systemchat "airstrike complete";
	_gp setvariable ['CAS_COMPLETED',true,true];
	{[_plane,_x] remoteExec ["enableAI",_plane]} foreach ["move","target","autotarget"];
	//{_plane enableAI _x} foreach ["move","target","autotarget"];
	[_plane,"YELLOW"] remoteExec ["setCombatMode",_plane]; //~~ gfetch combatmode before and reset here
	//_plane setcombatmode "yellow";




	if ({_x == "bomblauncher"} count _weaponTypes == 0) then {
		for "_i" from 0 to 1 do {
			[driver _plane,["CMFlareLauncher","Burst"]] remoteExec ["forceWeaponFire",driver _plane];
			driver _plane forceweaponfire ["CMFlareLauncher","Burst"];
			_time = time + 1.1;
			waituntil {time > _time || isnull _logic || isnull _plane};
		};
	};
	sleep 2;
	if (_isLeader) then {
	 	[
	 		[_gp,_pos,_caller],
	 		{
				params ["_gp","_pos","_caller"];
				if (getPlayerUID player == _caller) then {
					systemChat format ["This is %1-1, CAS at %2 is complete",parseText (groupID _gp), mapGridPosition _pos];
				};
			}
		] remoteExec ["bis_fnc_call",0];
	};
	sleep 2;

		
	if ( ((count (waypoints _gp) - 1) > (currentwaypoint _gp)) ) then { //&& !(_actionType in ["SUPPRESSION","AMBUSH","CAS-STRIKE"])
		private _wpc = (currentWaypoint _gp);
		[_gp, currentwaypoint _gp] call A3C_ai_highCommand_fnc_removeWaypoint;
	} else {
		deletewaypoint [_gp,currentwaypoint _gp];
	};


	sleep 18;
	if !(isnull _logic) then {
		sleep 1;
		deletevehicle _logic;
	//	waituntil {_plane distance _pos > _dis || !alive _plane};

	};
	//systemchat "end cas";
	[_plane,_planeAltitude] remoteExec ["flyInHeight",_plane];
	//if (alive _plane) then {
		//_group = group _plane;
		//_crew = crew _plane;
		//deletevehicle _plane;
		//{deletevehicle _x} foreach _crew;
		//deletegroup _group;
	//};
};
};

//
A3C_CAS_PreventAction = {
	params ["_group","_wpIndex","_wpPosition"];
	private _lastWpPosition = [];
	private _leaderVehicle = vehicle (leader _group);
	private _activeWaypoints = [];
	private _lastWpPosition = [0,0,0];
	private _lastWpIndex = -1;
	//systemchat 'ayoyo';
	_activeWaypoints = waypoints _group;
	{
		if (_x select 1 < _wpIndex) then {
			_activeWaypoints = _activeWaypoints - [_x];
		};
	} foreach _activeWaypoints;
	// systemchat str [_wpIndex, (_activeWaypoints select 0) select 1];
	if ( (count _activeWaypoints == 0) OR {(_wpIndex == ((_activeWaypoints select 0) select 1) ) && {position (vehicle leader _group) distance2D (waypointPosition [_group, currentWaypoint _group]) < 200}}  )then {
		_lastWpPosition = position (_leaderVehicle);
	} else {
		{

			if (_x select 1 == _wpIndex) exitWith {
				_lastWpIndex = _wpIndex -1; //-- here we can use the actual waypointIndex as the sequence is assured
				_lastWpPosition = waypointPosition [_group,_lastWpIndex];
			};
		} foreach _activeWaypoints;
	};
	//player commandchat str [(_lastWpPosition distance2D _wpPosition)];
	private _return = if (_lastWpPosition distance2D _wpPosition < 3000) then {true} else {false};
	_return
};

//publicVariable 'MCSS_fnc_moduleCAS';

if (isDedicated) exitWith {};

//-- SQUAD LEVEL / CLIENT ONLY
A3C_BEHAVIOUR_SQ_HELI_PICKANDDROP = {
	params ["_unit","_playerUnit","_movePos","_wtf","_landingdata"];
	private ["_landingpos","_maxdist","_pad","_shell"];
	_vehicle = vehicle _unit;
	if (_vehicle isKindOf "PLANE") then {
		[_unit,position _vehicle] spawn A3C_ai_shared_fnc_planeLanding;
	} else {
		_unit Setvariable ["A3C_WAITCARGO",true,true];
		_maxdist = 20;
		_landingpos = [];
		while {count _landingpos == 0} do {
			if (isNull _unit) exitWith {_abort = true};
			_landingpos = ([_movePos,[0,_maxdist]] call MCSS_fnc_getSafePos);
			_maxdist = _maxdist + 20;
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true};
		};
		_pad = "Land_HelipadEmpty_F" createvehicle _landingpos;
		[_unit,_landingpos] call A3C_ai_shared_fnc_doMove;
		if (_landingdata == "PICKUP") then {
			_shell = "Smokeshellgreen" createVehicle _landingpos;
		};
		sleep 2;
		//_vehicle land "_pad";
		if (_landingdata == "PICKUP") then {
			[_vehicle, _playerUnit] execFSM "A3C_CORE\FSM\A3C_AssignPlayerToVehicleCargo.fsm";
			_vehicle land "GET IN";
		} else {
			_vehicle land "GET OUT";
		};
		[_unit,_vehicle,_landingdata,_wtf,_landingpos,_playerUnit] spawn { //~~ should this not be the same? landingdata == 14
			params ["_unit","_vehicle","_type","_position","_landingpos","_playerUnit"];
			_unit groupchat format ["This is %1-%2, my %3 is approaching the %4 LZ at %5, over",(groupID group _playerUnit),(_unit getvariable "A3C_FORMATION_INDEX"),(parsetext  (getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"))),(parsetext _type),(mapgridposition _landingpos)];
			if (({(( ((_x select 2) getfriend (side _unit)) < 0.6)) && (_unit knowsabout (_x select 4) > 1.5) && (((_x select 4) distance _landingpos) < 300)} count (_unit neartargets viewdistance)) > 0) then {
				_unit groupchat "Caution, LZ is hot!";
			};
		};
		sleep 2;
		if (_landingdata == "DROPOFF") then {
			{
				//if !( (typeof _x) in ["B_Helipilot_F","B_Pilot_F","B_Helicrew_F","I_Helipilot_F","I_Helicrew_F","I_Pilot_F","O_Helipilot_F","O_Helicrew_F","O_Pilot_F"] ) then {
				if ([_x] call A3C_HELI_DISCHARGE) then {
					//unassignvehicle _x;
					[_x] spawn MCSS_fnc_GetOut;
					//-- loop
				};
				if ( (group _x != group _playerUnit) && (_x == leader group _x)) then {
					private _cargoGP = group _x;
					[_cargoGP,_vehicle] remoteExec ["leaveVehicle", leader _cargoGP];
				};
			} foreach (crew _vehicle) - [_unit]; //
		};

		while {(alive _unit)} do {
			if (isNull _unit) exitWith {_abort = true};
			if (_vehicle iskindof "AIR") then {
				{_unit disableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"THREAT_PATH","PATHPLAN",
				_unit dotarget _vehicle; _unit dowatch objnull;
				{_unit setskill [_x,0]} foreach ["commanding","spotTime","spotDistance"];
			};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {
				_vehicle land "NONE";

				{
					//- unassign all units outside of chopper. necessary?
					if ((assignedvehicle _x) == _vehicle) then {
						if !(_x in _vehicle) then {
							_x remoteExec ["unAssignVehicle",0];
						};
					};
				} foreach allunits - [_unit];
				[_unit,([(position _vehicle),1000,(random 360)] call BIS_fnc_Relpos)] call A3C_ai_shared_fnc_doMove;
				_vehicle flyinheight 25;
				_abort = true;
			};
			if ( ((position _vehicle) select 2) < 2) exitWith {
				deletevehicle _pad;
				[_unit,(position _vehicle)] call A3C_ai_shared_fnc_doMove;
				_vehicle flyinheight 2;
				{_vehicle animateDoor [_x, 1]} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
				sleep 2;
				if (_landingdata == "DROPOFF") then {
					if (_playerUnit in _vehicle) then {
						//_playerUnit action ["eject",_vehicle];
						[_playerUnit,["eject",_vehicle]] remoteExec ["action",_playerUnit];
					};
				};
			};
			if !(canmove _vehicle) exitWith {};
			sleep 1;
		};
	};
};



A3C_BEHAVIOUR_SQ_HELI_LANDFINAL = {
	params ["_unit","_playerUnit","_movePos"];
	private ["_vehicle","_maxdist","_landingpos","_pad","_abort"];
	_vehicle = vehicle _unit;
	_abort = false;
	if (_vehicle isKindOf "PLANE") then {
		[_unit,position _vehicle] spawn A3C_ai_shared_fnc_planeLanding;
	} else {
		_unit Setvariable ["A3C_WAITCARGO",true,true];
		_maxdist = 20;
		_landingpos = [];
		while {count _landingpos == 0} do {
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) then {_abort = true};
			_landingpos = ([_movePos,[0,_maxdist]] call MCSS_fnc_getSafePos);
			_maxdist = _maxdist + 20;
		};

		_pad = "Land_HelipadEmpty_F" createvehicle _landingpos;
//		[_unit,_landingpos] call A3C_ai_shared_fnc_doMove;
		if !(_abort) then {sleep 2};
		//_vehicle land "_pad";
		if !(_abort) then {sleep 1};
		_vehicle land "LAND";
		sleep 1;
		{
			//if !( (typeof _x) in ["B_Helipilot_F","B_Pilot_F","B_Helicrew_F","I_Helipilot_F","I_Helicrew_F","I_Pilot_F","O_Helipilot_F","O_Helicrew_F","O_Pilot_F"] ) then {
			if ([_x] call A3C_HELI_DISCHARGE) then {
				[_x] spawn MCSS_fnc_GetOut;
			};
			if ( (group _x != group _playerUnit) && (_x == leader group _x)) then {
				private _cargoGP = group _x;
				[_cargoGP,_vehicle] remoteExec ["leaveVehicle", leader _cargoGP];
			};
		} foreach (crew _vehicle) - [_unit];

		while {(alive _unit)} do {
			if (isNull _unit) exitWith {_abort = true};
			{_unit disableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"THREAT_PATH","PATHPLAN",
			_unit dotarget _vehicle; _unit dowatch objnull;
			{_unit setskill [_x,0]} foreach ["commanding","spotTime","spotDistance"];


			if ( ((position _vehicle) select 2) < 2) exitWith {
				_vehicle land "LAND";
				_vehicle flyinheight 0;
				{_vehicle animateDoor [_x, 1]} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
				sleep 3;
				if (_playerUnit in _vehicle) then {
					//_playerUnit action ["eject",_vehicle];
					[_playerUnit,["eject",_vehicle]] remoteExec ["action",_playerUnit];
				};
				[_vehicle,_pad,_unit] spawn {
					params ["_chopper","_pad","_unit"];
					_chopper = _this select 0;
					while {(((position _chopper) select 2) < 2)} do {
						if (isNull _unit) exitWith {_abort = true};
						if ( {isPlayer _x} count (crew _chopper) == 0 ) exitWith {
							sleep 2;
							//_chopper action ["engineOff", _chopper];
							[_chopper,["engineOff", _chopper]] remoteExec ["action",_chopper];
							deletevehicle _pad;
							_chopper setvelocity [0,0,0];
							_chopper flyInHeight 50;
						};
						if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {};
						sleep 0.1;
					};
				};
			};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {
				_abort = true;
				_vehicle land "NONE";
			};
			if !(_vehicle iskindof "AIR") then {_abort = true};
			if (currentcommand _unit == "STOP") then {
				if !( ((expectedDestination _unit ) select 1) == "LEADER PLANNED") then {
					if !( (effectivecommander _vehicle) == _unit) then {
						if !( ((expectedDestination (effectivecommander _vehicle)) select 1) == "LEADER PLANNED") then {
							_abort = true;
						};
					} else {
						_abort = true;
					};
				};
			};
			if !(canmove _vehicle) then {_abort = true};
			if !(alive _unit) then {_abort = true};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) then {_abort = true};
			if (((expectedDestination _unit) select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {_abort = true;};
			if (_abort) exitWith {};
			sleep 1;
		};
	};
	if !(_abort) then {
		while {alive driver _vehicle} do {
			if ( {[_x] call A3C_HELI_DISCHARGE} count (crew _vehicle) == 0 ) exitWith {
				doStop _unit;
				sleep 1;
				[_vehicle,["engineOff", _vehicle]] remoteExec ["action",_vehicle];
				_vehicle spawn {
					sleep 8;
					_this flyInHeight (_this getVariable ["A3C_FLYINHEIGHT",25]);
				};
			};
			sleep 1;
		};
	};
};


A3C_BEHAVIOUR_SQ_HELI_Sling = {
	params ["_mode","_veh","_cargo"];
	private ["_cargoLocation","_subBehaviour","_memPoints","_turnVeh","_cargoHeight"];

	//~~ might wanna ask underneath surface check

	_heliFreeze = {
		params ["_veh"];
		private _vectorDir = vectorDir _veh;
		_timer = time + 2;
		while {time < _timer} do {
			_veh setVelocity [0,0,0];
			_veh setVectorDir _vectorDir;
		};

	};

	if (_cargo isEqualType []) then {
		if (surfaceIsWater _cargo) then {
			_cargo set [2,10];
			//_cargo = ASLtoATL _cargo;
		};
	};


	_height = 15;

	if (_mode == 0) then {
		_cargoLocation = getPosATL _cargo;
		_cargoHeight = (_cargoLocation select 2) + ((((boundingBoxreal _cargo) select 1) select 2) + 10);
		_cargoLocation set [2,_cargoHeight];
		_veh flyInHeight _cargoHeight;

		//while {canMove _veh} do {
		//	if (speed _veh < 60) exitWith {};
		//	sleep 1;
		//};
		//_turnVeh = [_veh,_cargoLocation] spawn A3C_FORCEORIENT;
		//waitUntil {scriptDone _turnVeh};
		_subBehaviour =
		[
			_veh,
			getPosASL _veh,
			ATLtoASL ((_cargoLocation select [0,2]) + [_height]),
			50
		] spawn A3C_ai_rail_fnc_helicopter;
		waituntil {scriptDone _subBehaviour};
		_veh spawn _heliFreeze;
		_memPoints = getArray (configfile >> "CfgVehicles" >> typeOf _veh >> "slingCargoAttach");
		_cargo enableRopeAttach true;
		_veh enableRopeAttach true;
		_cans = [];
		{
			_veh1 = "Land_Can_V1_F" createVehicleLocal (_veh modelToWorldVisual [0,0,-1]);
			_veh1 setpos (_veh modelToWorldVisual [0,0,-4]);
			_veh1 hideObject true;
			_veh1 enableRopeAttach true;
			_rope = ropeCreate [_veh, _x, _veh1, [0, 0, -1], 100];
			_cans pushback _veh1;
			sleep 1;
		} foreach _memPoints;
		{ropedestroy _x} foreach ropes _veh;
		{deleteVehicle _x} foreach _cans;
		while {isNull getSlingLoad _veh} do {
			_veh setSlingLoad _cargo;
			sleep 1;
		};

	} else {
		//-- _cargo is _movePos here!! not the cargo itself
		//-- Note:  freezes the attached vehicle unnaturally
		//_subBehaviour = [_veh,_cargo,_height] spawn A3C_ai_rail_fnc_helicopterDuda; //-- leave in place as option
		_subBehaviour = [_veh,ATLtoASL ((_cargo select [0,2]) + [_height]),false] spawn A3C_ai_rail_fnc_hoverApproach;
		waituntil {scriptDone _subBehaviour};
		_veh spawn _heliFreeze;
		_veh setSlingLoad objNull;
	};
};



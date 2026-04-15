


//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------  G E N E R A L   A I  -  F U N C T I O N S    -------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------    Functions that are applied to AI      ------------------------------------------------
//-------------------------------------    - may require data from HUD/TABLE/RADIAL  -     ------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------  A U T O  R O U T I N E S    ------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------

//-- Teleport stuck units into a close and empty position
A3C_UNSTUCK = {

	private _units = _this;
	
	private _vehicles = [];
	{
		if !((vehicle _x) isKindOf "AIR") then {
			_vehicles pushBackUnique (vehicle _x);
		};
	} foreach _units;
	_vehicles = 
	[
		_vehicles,
		[],
		{
			_dest = (expectedDestination (driver _x)) select 0;
			if ({_dest distance2D _x < 1} count [[0,0,0], getPosASL _x] == 0) then {10000000} else {_x distance2D _dest}; 
		},
		"ASCEND"
	] call BIS_fnc_sortBy;
	
	{
		private _vehicle = _x;
		_bbox = ([_vehicle,0] call MCSS_fnc_BBOX);
		_longerLength = ((_bbox select 0) distance2D (_bbox select 1)) max ((_bbox select 1) distance2D (_bbox select 2));
		private _dir = -1;
		private _dest = (expectedDestination (driver _vehicle)) select 0;
		private _enRoute =  ({_dest distance2D _x < 1} count [[0,0,0], position _vehicle] == 0);
		private _refDir = _vehicle getDir _dest;
		if (!isPlayer driver _vehicle) then {
			private _pos = if !(_vehicle isKindOf "SHIP") then {getPosATL _vehicle} else {getPosASL _vehicle};
			private _res = [];
			private _dist = 10;
			if (_vehicle isKindOf "SHIP") then {
				if !(surfaceIsWater _pos) then {
					_dist = 50;
				};
			};
			private _hgt = _pos select 2;
			for "_i" from 1 to 5 do {
				_res = (_pos findEmptyPosition [5,_dist,(typeOf _vehicle)]);
				if ((count _res) > 0) exitwith {};
				_dist = _dist + 5;
			};
			if (_vehicle isKindOf "SHIP") then {
				_res set [2,_pos select 2];
			} else {
				if !(_vehicle isKindOf "MAN") then {

					//-- detect bridges:
					_nearBridges = (position _vehicle nearRoads 30) select {"bridge" in toLower (getModelInfo _x select 0)};
					if (count _nearBridges > 0) then {
						_nearBridges = 
						[
							_nearBridges,
							[],
							{position _x distance2D _dest},
							"ASCEND"
						] call BIS_fnc_sortBy;
						_bridge = _nearBridges select 0;
						_roads = roadsConnectedTo _bridge;
						
						while {true} do {
							_roads = 
							[
								_roads,
								[],
								{position _x distance2D _dest},
								"ASCEND"
							] call BIS_fnc_sortBy;
							_road = _roads select 0;
							_res1 = (position _road findEmptyPosition [0,5,(typeOf _vehicle)]);
							if ((count _res1) > 0) exitwith {
								_res = _res1;
								_roadDir = getDir _x;
								if (abs (_refDir - _roadDir) > abs (_refDir - (_roadDir + 180)) ) then {
									_dir = _roadDir + 180;
								} else {
									_dir = _roadDir;
								};
							};
							_roads = roadsConnectedTo _road;

						};
						

					} else {
						_vehicleSize = sizeOf typeOf _vehicle;
						_roads = position _vehicle nearRoads (_vehicleSize * 2);
						_roadsInTravelDirection = _roads select {
							_roadToDest = _x distance2D _dest;
							_roadToVehicle = _x distance2D _vehicle;
							_roadToDest < _roadToVehicle
						};

						_destination = (expectedDestination (driver _vehicle)) select 0;
						_destination set [2,0];

						if (count _roadsInTravelDirection > 0) then {
							_roads = _roadsInTravelDirection;
						};

						_roadsMinDistance = _roads select {_x distance _vehicle > _vehicleSize};

						if (count _roadsMinDistance > 0) then {
							_roads = _roadsMinDistance;
						};

						

						_roads = 
						[
							_roads,
							[],
							{
								_x distance2D _vehicle
								/*
								if (_enroute) then {
									//((_x distance2D _vehicle) + (_x distance2D _dest)) / 2
									_roadToDest = _x distance2D _dest;
									_roadToVehicle = _vehicle distance2D _x;
									_vehicleToDest = _vehicle distance2D _dest;
									if () then {

									};
								} else {
									_x distance2D _vehicle
								}; 
								*/
							},
							"ASCEND"
						] call BIS_fnc_sortBy;
						if (count _roads > 0) then {
							{
								_res1 = (position _x findEmptyPosition [0,5,(typeOf _vehicle)]);
								if ((count _res1) > 0) exitwith {
									_res = _res1;

									//-- align the vehicle with the road, in direction of the driver's destination
									//-- road direction does not work, need to use connected roads and dirto instead 
									_connectedRoads = roadsConnectedTo _x;
									_connectedRoads = [_connectedRoads,[],{(position _x) distance2D _destination},"ASCEND"] call BIS_fnc_sortBy;
									if !(_connectedRoads isEqualTo []) then {
										_selectedRoad = _connectedRoads select 0;
										_dir = _res getDir (position _selectedRoad);
									};



									//_roadDir = getDir _x;
									//if (abs (_refDir - _roadDir) > abs (_refDir - (_roadDir + 180)) ) then {
									//	_dir = _roadDir + 180;
									//} else {
									//	_dir = _roadDir;
									//};
								};
								_dist = _dist + 5;
							} foreach _roads;
						};
						
						if (_dir == -1) then {
							if ({_dest distance2D _x > 1} count [[0,0,0], position _vehicle] > 0) then {
								_dir = (_vehicle getDir _dest);
							};
						};
					};

				};
			};

			(driver _vehicle) lookAt objnull;
			(driver _vehicle) enableAI "FSM";
			(driver _vehicle) enableAI "MOVE";
			(driver _vehicle) enableSimulation true;
			(driver _vehicle) forcespeed -1;
			if ((driver _vehicle) == _vehicle) then {
				if ((animationState _vehicle) in ["afalpercmstpsraswrfldnon"]) then {
					//_vehicle switchmove "";
					[_vehicle,""] remoteExec ["switchMove",_vehicle];
					//_vehicle setposASL ([(getposASL (driver _vehicle)),0.5,(getDir (driver _vehicle))] call BIS_fnc_RelPos);
					[_vehicle,([(getposASL (driver _vehicle)),0.5,(getDir (driver _vehicle))] call BIS_fnc_RelPos)] remoteExec ["setposASL",_vehicle];
				};
			};
			if ((count _res) == 0) exitwith {};
			private _act = true;
			if (isMultiplayer) then {
				private _enemies = [(driver _vehicle),"ARRAY"] call MCSS_fnc_NearEnemies;
				if ( {isplayer _x} count _enemies > 0) then {
					_act = false;
				};
			};
			if (_act) then {
				if !(_vehicle isKindOf "SHIP") then {
					[_vehicle,_res] remoteExec ["setPos",_vehicle];
				} else {
					[_vehicle,_res] remoteExec ["setPosASL",_vehicle];
				};
				if !(_vehicle isKindOf "MAN") then {
					if (_dir != -1) then {
						_vehicle setDir _dir;
					};
				};
			};
		};
		sleep 0.2;
	} foreach _vehicles;
};

//-- Reduce Speed of driving vehicle (used to slow down choppers before landing to avoid the typical pullup)
//[(driver cp), 10] A3C_REDUCE_SPEED
A3C_REDUCE_SPEED = {
	_unit = (_this select 0);
	_maxspeed = _this select 1;
	_vehicle = vehicle _unit;
	_vel = velocity _vehicle;
	_dir = direction _vehicle;
	_speed = 0.1;
	while {(speed _vehicle) > _maxspeed} do {
		_vel = velocity _vehicle;
		_dir = direction _vehicle;
		private _newVel =
		[
			(_vel select 0) - (sin _dir * _speed),
			(_vel select 1) - (cos _dir * _speed),
			(_vel select 2)
		];
		[_vehicle,_newVel] remoteExec ["setVelocity",_vehicle];

		sleep 0.01;
	};
	{[_x,_maxspeed] remoteExec ["limitSpeed",_x]} foreach [_unit,_vehicle];
	//_unit limitspeed _maxspeed;
	//_vehicle limitspeed _maxspeed;
	_unit setvariable ["A3C_REDUCE_SPEED",true,true];
};



A3C_calculatePath = {
	params ["_unit", "_destination"];
	// systemchat 'yo';
	private _startPos = getPosASL (vehicle _unit);
	private _direction = getDir (vehicle _unit);

	_startPos set [2,0]; 
	_destination set [2,0];


	

	//-- #TODO: create road-positions for depart/destination

	private _skyPos = _startPos vectorAdd [0,0,10000];
	private _agent = createAgent [typeOf player, [0,0,0], [], 0, "NONE"]; 
	private _car =  "B_APC_Tracked_01_rcws_F" createVehicleLocal [0,0,10000 + random 1000]; //"B_Quadbike_01_F", (typeOf vehicle _unit)
	_car setPosASL _skyPos;
	_car hideObject true;

	// {} foreach [_agent, _car] //-- make agents invisible
	

	_agent setBehaviourStrong (behaviour _unit); //"CARELESS";  //-- #TODO: Careless may not always be the best, maybe actual behaviour is relevant
	_agent moveInDriver _car;
	
	_car setDir _direction;

	
	
	// _origDest = (expectedDestination _agent) select 0;
	_pathFinal = [];
	private _globalVarID =  format ["A3C_CONV_%1",round (random 1000000)];
	_agent setVariable [
		"A3C_VEHICLE_PATH",
		[
			[],
			false
		]
	];

	_agent addEventHandler
	[
		"PathCalculated", 
		{  
			params ["_agent", "_path"];

			private _globalVarID = _agent getVariable "A3C_VEHICLE_PATH";

			//-- unsuccessful path
			if (_path isEqualTo []) exitWith {
				_agent setVariable [
					"A3C_VEHICLE_PATH",
					[
						[],
						true
					]
				];
			};

			//-- successful path
			{
				_x set [2,0];
			} foreach _path;		
			
			for "_i" from 0 to 1 do {
				{ //-- remove non road position at beginning and end of path
				
					if (isOnRoad _x) exitWith {
						//systemchat 'road';
					};
					_path = _path - [_x];
				} foreach _path;
				reverse _path; //-- path will be reversed twice, setting it back to normal
			};

			_agent setVariable [
				"A3C_VEHICLE_PATH",
				[
					_path,
					true
				]
			];
		}
	];
	 
	//-- set agent on path
	_agent setDestination [_destination, "LEADER PLANNED", true];

	// sleep 0.5; 
	
	//-- wait for path calculation to complete
	private _timer = time;
	waitUntil {(_agent getVariable "A3C_VEHICLE_PATH") select 1  OR (time - _timer > 5)};

	

	private _path = (_agent getVariable ["A3C_VEHICLE_PATH", [[],true] ] ) select 0;


	if (_path isEqualTo []) exitWith {
		// systemchat "PATH CALC FAILED";
		_unit setVariable [
			"A3C_VEHICLE_PATH",
			[
				[],
				(_startPos distance2D _destination) //-- replacement distance to the destination in a straight line
			]
		];
	};

	{
		if (_x distance2D _agent > 30) exitWith {};
		_path = _path - [_x];
	} foreach _path; //-- loop just incase of a sneaky snake road, we only check in the beginning

	
	_totalPathLength = 0;
	{
		private _initPos = if (_foreachIndex == 0) then {getPosASL _agent} else {_path select (_foreachIndex - 1)};
		private _dist = _initPos distance2D _x;
		_totalPathLength = _totalPathLength + _dist;
		// [format ["M_%1",_foreachIndex],_x,"ICON","mil_dot",[1,1],"","ColorYellow"] call MCSS_fnc_createMarker;
	} foreach _path;

	{deleteVehicle _x} foreach [vehicle _agent,_agent];

	// systemchat format ['PATH CALCULATED, total length: %1', _totalPathLength];
	_unit setVariable [
		"A3C_VEHICLE_PATH",
		[
			_path,
			_totalPathLength
		]
	];	



};




//---------------------------------  M A I N  M O V E M E N T  S U B - F U N C T I O N S     --------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------
//-- Function to make unit move to position
//-- issues both doMove and moveTo orders
//-- issues commandMove order when player is effectiveCommander of vehicle
//-- this function is for a single movement and is called by A3C_MOVE and various other routines that require movement
A3C_DOMOVE = {
	private ["_unit","_wPos","_veh","_comm"];
	_unit = _this select 0;
	_wPos1 = _this select 1;

	

	if (_wPos1 distance2D [0,0,0] < 0.1) exitWith {}; //-- invalid position, would make unit go to [0,0,0]

	_veh = (vehicle _unit);

	//systemChat str ["A3C_DOMOVE",_this];
	//if (true) exitWith {};
	//player setpos _wPos1;

	private _commanderNotInGroup = !((effectivecommander _veh) in (units _unit));

	private _isCargoAI = _commanderNotInGroup && {!isPlayer _unit && {_unit == leader group _unit}};

	// systemchat format ["_domove: %1:, _commanderNotInGroup %2,  _isCargoAI %3", groupID group _unit, _commanderNotInGroup, _isCargoAI];
	if (_isCargoAI) exitWith {
		// systemchat "DOMOVE ABORTED CARGO-AI";
	};

	

	_commanderNotInGroup = !((effectivecommander _veh) in (units (driver _veh)));

	

	// systemchat format ["_commanderNotInGroup 1: %1", _commanderNotInGroup];
	//-- if effectiveCommander is not in driver's group, we should transfer command, otherwise driver will not listVehicleSensors
	if (_commanderNotInGroup) then {
		// systemchat 'transferring vehicle command';
		// _veh setEffectiveCommander _unit;
		_veh setEffectiveCommander (driver _veh);
	};

	// systemchat format ["_commanderNotInGroup 2: %1", !((effectivecommander _veh) in (units (driver _veh)))];

	

	if (!isPlayer (leader group _unit)) exitWith {
		private _effectiveCommander = effectiveCommander (vehicle _unit);
		[group _unit,_wPos1] remoteExec ["move",_effectiveCommander];
		[_effectiveCommander,_wPos1] remoteExec ["doMove",_effectiveCommander];
		[_effectiveCommander,_wPos1] remoteExec ["moveTo",_effectiveCommander];
		[_effectiveCommander,[_wPos1,"LEADER PLANNED",false]] remoteExec ["setDestination",_effectiveCommander];
	};

	if (!local player) exitWith {};
	if (isDedicated) exitWith {};
	if (isNil "_unit") exitWith {};

	

	if (!isNull objectParent _unit && !(_unit in [driver _veh, effectiveCommander _veh])) exitWith {}; //-- unit is not driver or commander - do not move!
//systemchat "MOVE";
	if (expectedDestination _unit isEqualTo []) then {
		_unit setDestination [position _unit,"DoNotPlan",true];
	};

	_pause = if (count _this > 2) then {_this select 2} else {false};
	
	_comm = (effectiveCommander _veh);


	_unit enableAI "MOVE";
	_unit forceSpeed -1;

	if ( _comm == player ) then {
		_unit commandmove _wPos1;
		_unit moveTo _WPos1;
	} else {
		[_unit,_comm,_wPos1] spawn {
			params ["_unit","_comm","_wPos1"];
			_unit doFSM ["A3C_CORE\fsm\doMove.fsm", _wPos1,[player,_unit]];

			_unit setdestination [_wPos1,((expectedDestination _unit) select 1),((expectedDestination _unit) select 2)];
			if !(_comm == _unit) then {
				if (!isDedicated && {group _unit == group player}) then {
					_comm doMove (position vehicle _comm); _comm moveTo (position vehicle _comm);
					sleep 0.2;
					_comm moveTo _wPos1;
					_comm setdestination [_wPos1,"LEADER PLANNED",true];
				} else {
					_comm domove _wPos1; _comm moveto _wPos1;
				};
			};
		};
	};
	_unit
};

MCSS_fnc_setVehicleVarname = {
	params ["_unit"];
	A3C_VARNAME_INDEX = if (!isNil 'A3C_VARNAME_INDEX') then {A3C_VARNAME_INDEX} else {1};
	if ((vehicleVarName _unit) == "") then {
		while {(vehicleVarName _unit) == ""} do {
			call compile format
			[
				"
					_unit setvehicleVarName 'A3C_MEMBER_%1_%2';
					A3C_MEMBER_%1_%2 = _unit;
					publicVariable 'A3C_MEMBER_%1_%2';
				",
				if (!isNull player) then {getPlayerUID player} else {"111011101111"},
				A3C_VARNAME_INDEX
			];
			//systemchat '1';
		};
	} else {
		call compile format
		[
			"
				%1 = _unit;
			",
			(vehiclevarname _unit)
		];
		//systemchat '2';
	};
	A3C_VARNAME_INDEX = A3C_VARNAME_INDEX + 1;
	(vehiclevarname _unit)
};



//-- Make Sure that disbanded units stay in vehicle
A3C_HC_ROLES = {
	//_unit = _this select 0;
	params ["_unit"];
	//systemchat (str (typeof vehicle _unit));
	if !(isTouchingGround (vehicle _unit)) exitWith {};
	//systemchat (str (typeof vehicle _unit));
	if (isPlayer _unit) exitWith {};
	if !(isnull objectparent _unit) then {
		if (_unit == (driver (vehicle _unit))) then {
			_unit assignAsDriver (vehicle _unit);
			_unit moveinDriver (vehicle _unit);
		};
	};
	switch (assignedVehicleRole _unit) do {
		case ("driver") : {
			_unit assignAsDriver (vehicle _unit);
			_unit moveinDriver (vehicle _unit);
			[_unit,(vehicle _unit)] spawn {
				private ["_unit"];
				_unit =_this select 0;
				_veh = _this select 1;
				_time = time;
				while {time <= (_time + 5)} do {
					_unit moveinDriver _veh;
					sleep 0.1;
				};
			};
		};
		case ("gunner") : {
			_unit assignAsGunner (vehicle _unit);
			_unit moveinGunner (vehicle _unit);
		};
		case ("cargo") : {
			_unit assignascargoIndex [(vehicle _unit),((vehicle _unit) getcargoindex _unit)];
			_unit moveinCargo [(vehicle _unit),((vehicle _unit) getcargoindex _unit)];
		};
	};
	if ( ((assignedVehicleRole _unit) select 0) == "Turret") then {
		_unit assignAsTurret [(vehicle _unit),((assignedVehicleRole _unit) select 1)];
		_unit moveinturret [(vehicle _unit),((assignedVehicleRole _unit) select 1)];
	};
	[_unit] allowGetIn true;
	[_unit] ordergetin true;
	sleep 5;
	(vehicle _unit) setvehicleLock "UNLOCKED";
};



A3C_isWPLOOP = {
	params ["_data","_wpIndex"];
	private ["_return"];
	_return = false;
	for "_i" from 0 to _wpIndex do {
		if ( ((_data select _i) select 10) == -2) exitWith {
			_return = true;
		};
	};
	_return
};

A3C_SpawnGoCode = {
	params ["_unit","_goCode","_movePos","_origDest","_data","_cycle"];
	private _abort = false;
	while {!(_goCode == "NONE")} do {
		if ([_unit] call A3C_ExitRoute_isWpAborted) exitwith {_abort = true};
		if !(A3C_BOOL_MOVINGMARKER) then {
			//-- exit stop
			if ([_unit,_movePos,1] call A3C_ExitRoute_isUnitStopped) then {
				_abort = true;
			};
		};
		//systemchat 'brokenfrom1';
		if ([_unit,_origdest,_data,_cycle,1] call A3C_ExitRoute_isBrokenFrom) then {
			_abort = true;
			//{dostop _x} foreach [_unit,effectivecommander (vehicle _unit)];
		};
		if (_abort) exitwith {};
		if (call compile format ["A3C_GoCode_Activate_%1",(parseText _goCode)]) exitwith {};
		sleep 0.1;
	};
};


//---------------------------------------  M A I N  M O V E M E N T  F U C T I O N     ----------------------------------------------
//-------------------------------- sends unit on a route, monitors and creates group/ui-data ----------------------------------------
//---------------------------- requires unit to have data in (_unit getvariable "A3C_PLOT") ---------------------------------
//------------------------------------ used by Planning Mode, ReArm, BuildingClear, Medical -----------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------
A3C_MOVE = {
	params ["_unit","_data"];
	private
	[
		"_exit","_cycle","_syncComplete","_syncIndex","_timer","_abort","_muzzle","_completionRadius",
		"_maxSpeed","_goCode","_moveOrder","_isLoop","_rail","_movePos","_wpData","_pickUpUnits","_precision"
	];


	// possibly not needed vars: _completionRadius

	//player globalChat str ["START",_unit];

	//(str [_unit,"A3C_Move"]) remoteExec ["systemchat",0];

	_count = count _data;


	_abort = false;
	_exit = false;
	_SyncComplete = false;
	_SyncCompleteMain = false;
	_hubComplete = false;
	//_condition = true;
	_inBuilding = false;
	_inside = false;
	_syncData = [];
	_switchData = [];
	_otherUnits = [];
	_crew = [];
	_vectorup = [];
	_abortData = [];
	_wpos = [];
	_pickUpUnits = [];
	_movePos = [];
	_timer = time;
	_counter = 0;
	_threshold = 50;
	_cycle = 0;
	_pause = 0;
	//_radius = 0;
	_syncIndex = 0;
	_completionRadius = 5;
	_maxdist = 20;
	_maxSpeed = -1;
	_comparedWP = 0;
	_dataCompared = 0;
	_syncDataCompared = 0;
	_testedSyncSubArray = 0;
	_landingpos = [];
	_landingdir = 0;
	_timeNow = 0;
	_velo = 0;
	_goCode = "";
	_varidist = 0;
	_muzzle = "";

	private _vehicle = vehicle _unit;

	_landingdata = "NONE";

	_unitNumber = _unit getvariable "A3C_VVNI"; //"A3C_FORMATION_INDEX";

	_precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "precision"));

	if (isPlayer _unit) exitWith {
		{
			_unit setVariable [_x,[],true];
		} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
	};

	if (count _data == 0) exitwith {};


	if (currentCommand _unit == "STOP") then {
		if (player == leader group _unit) then {
			_unit = [_unit] call A3C_Replace_Unit;
		};
	};


	//-- reset unit's planning stage array
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	if (!alive _unit) exitwith {_abort = true};

	_unit setVariable ["A3C_unitIsOnMainRoute",true,true];

	_unit setVariable ["A3C_FORM_MEMBER",false,false]; //-- take away from custom form!
	_unit setvariable ["A3C_PLOT_TEMP",[],true];
	_unit setvariable ["A3C_BOOL_WP_DELETED",false,true];
	_unit setvariable ["A3C_WAITCARGO",false,true];
	_unit setvariable ["A3C_ABORT_Data",[false,false],true];
	_unit setvariable ["A3C_SKILLDATA",[(_unit skill "commanding"),(_unit skill "spotDistance"),(_unit skill "spotTime")],true];

	_origDest = [0,0,0];
	if (_vehicle isKindOf "AIR") then {
		_unit setvariable ["A3C_CREWCOUNT",(count crew _vehicle),true];
	} else {
		if ((effectivecommander _vehicle) != player) then {
			_origDest = (expectedDestination (effectiveCommander _vehicle) select 0);
		} else {
			_origDest = ((expectedDestination _unit) select 0);
		};
	};
	if (isNil '_origDest') then {
		_origDest = position _unit;
	};



	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////   M A I N  L O O P   /////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	while {!isNull _unit} do {


		_vehicle = vehicle _unit; //-- refresh to monitor changes

		_data = (_unit getvariable ["A3C_PLOT",[]]);

		if (_cycle >= count _data) exitwith {};

		if (_cycle >= (count (_unit getvariable "A3C_PLOT")) ) exitwith {};


		_vehicle = vehicle _unit;
		_wpData = (_data select _cycle);

		_wpData params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];

		_wPos = _wpPositions select 0;
		_lookAtPos = _wpPositions select 1;
		_wpMarkerMain = _wpMarkers select 0;
		_wpMarkerXtra = _wpMarkers select 1;
		//_wpMarkerDir = _wpMarkers select 2;
		_unitPosTravel = _wpStances select 0;
		_unitPosDest = _wpStances select 1;
		_movePos = if ((_wpAction select 0) in ["GRENADE","SUPPRESSION"]) then {position _unit} else {_wPos};
		_landingdata = if ((_wpAction select 0) == "LANDING") then {_wpAction select 1} else {""};
		_wpTimeoutValue = if ((_wpAction select 0) == "TIMEOUT") then {_wpAction select 1} else {0};

		_precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "precision"));

		//(format ["%1 cycle start",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
		//_radius = if ( (count (_data select _cycle)) > 17) then {(_data select _cycle) select 17} else {0};
		if (_unit in A3C_SUPPRESSION_UNITS_SQ) then {
			[[_unit],"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
		};

		//-- Check if abort data was given via dialog
		_abortData = _unit getvariable "A3C_ABORT_Data";

		if (_abortdata select 1) then {
			//-- Player skipped current waypoint:
			_unit setvariable ["A3C_ABORT_Data",[false,false],true];
			if !([_data,_cycle] call A3C_isWPLOOP) then {
				{
					[_x,_unit,"A3C_PLOT_TEMP"] call A3C_DELETE_MARKER; //~~ sure it's supposed to be TEMP??
				} foreach (((_unit getvariable "A3C_PLOT") select (_cycle - 1)) select 1);

			};
			_abort = false;
			if (_unit getvariable "A3C_BOOL_WP_DELETED") then {

				_data deleteAt (_cycle - 1);
				_unit setvariable ["A3C_PLOT",_data,true];
				_unit setvariable ["A3C_BOOL_WP_DELETED",false,true];
				_cycle = _cycle - 1;
				_unit setvariable ["A3C_CURRENTWAYPOINT_INDEX",(_cycle + 1),true];
			};
		};


		//-- after checking and for skipped waypoint we wait for the unit to be 'driver'
		//while {alive _unit} do {
		//	_vehicle = vehicle _unit;
		//	if (_unit == driver _vehicle) exitWith {};
		//	_abortData = _unit getvariable "A3C_ABORT_Data"; //~~ NOTE: check what happens if you skip waypoint during this waiting circle
		//	if (count _abortData > 0) exitWith {};
		//	sleep 1;
		//};

		//-- default: switch default unit behavior on for each WP
		{_unit enableAI _x} foreach ["TARGET","AUTOTARGET","FSM"]; //,"WAYPOINT_STOP"

		_unit dowatch objnull;
		_unit lookat objnull;
		//if (_abortData select 0) exitWith {}; //-- not dnecessary as _abort is still true?
		//-- exit function if required (_abort returns true), delete lines/markers and reset values
		if (_abort) exitwith {
			{_unit enableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"THREAT_PATH","PATHPLAN",
			_unit forcespeed -1;
			_vehicle forcespeed -1;
			if !(_vehicle == _unit) then {
				_vehicle limitspeed 1000;
			};
			[_unit] call A3C_RESET;
		};

		if (isNull _unit) exitwith {};

		


		//-- refuel RTB planes
		if (_vehicle isKindOf "PLANE") then {
			if (_unit == (driver _vehicle)) then {
				if ( ((getposATL _vehicle) select 2) < 5) then {
					//_vehicle setfuel 1;
					{_vehicle animateDoor [_x, 0]} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
					if ((getNumber (configfile >> "CfgVehicles" >> typeOf _vehicle >> "landingSpeed")) > 10) then {
						[_unit] spawn A3C_JET_TAKEOFF;
					};
				};
			};
		};

		//-- help out the helpless guys in stranded boats
		//-- here we use the GENERAL depth of the ocean at the position. not the depth od the vehicle
		if (_vehicle isKindOf "SHIP") then {
			private _vicPos = getpos _vehicle;
			private _refPos = ATLtoASL ((_vicPos select [0,2]) + [0]);

			private _shoreAction = false;
			if (surfaceIsWater _refPos) then {
				private _depth = _refPos select 2;
				//systemchat str _depth;
				//private _refDepth = if (_cycle == 0) then {4} else {2};
				if (_depth >= -3) then {
					_shoreAction = true;
				};
			} else {
				_shoreAction = true;
			};
			if (_shoreAction) then {
				if (abs (speed _vehicle) < 2 ) then {
					[_vehicle] call A3C_SHIP_startBoat;
				};
			};
			//-- next line, pay attention: the true/false may seem counter intuitive. We are looking for ZERO units WITHOUT rebreathers (meaning all have one)
			if ( { _c = count (getArray (configfile >> "CfgWeapons" >> vest _x >> "hiddenUnderwaterSelections")); if (_c > 0) then {false} else {true};  } count (crew _vehicle) == 0      ) then {
				_vehicle swimInDepth -30;
			} else {
				_vehicle swimInDepth 0;
			};

		};


		//-- Throw Grenade
		if ((_wpAction select 0) == "GRENADE") then {
			_muzzle = (_wpAction select 1);
			if (_muzzle in (magazines _unit)) then {_muzzle = ([_muzzle] call MCSS_fnc_GetMuzzle) } else {_muzzle = ""};
			if !(_muzzle == "") then {
				[_unit,position _vehicle ] call A3C_DOMOVE;
				_unit lookat _wPos;
				if ((_wPos distance2D (getPosASL _unit)) > 70) then {
					_wPos = _unit getPos [70,_unit getDir _wPos];
				};
				_velo = [_unit,_wPos,300] call A3C_THROW_VEL;
				sleep 2;
				_unit setvariable ["A3C_GRENADE_VEL",_velo,true];
				A3C_firedEVH = _unit addEventHandler ["fired",
				{
					_shooter = _this select 0;
					_vel = _shooter getvariable "A3C_GRENADE_VEL";
					if (_this select 1 == "THROW") then
						{
							(_this select 6) setVelocity _vel;

						};
						_shooter removeEventHandler ["fired", A3C_firedEVH];
				}];
				_unit forceWeaponFire [_muzzle,_muzzle];

				if ((side _unit) == WEST) then {
					[_unit] call A3C_Gren_Phrase;
				};
				sleep 1;
			};
		};


		//-- Activate Suppression
		if ((_wpAction select 0) == "SUPPRESSION") then {
			if (!isnull gunner _vehicle) then {
				sleep 1;
				A3C_SUPPRESSION_UNITS_SQ pushback _unit;
				[[gunner _vehicle],(_unit getVariable "A3C_UNIT_POLYS") select 0,'SUPPRESSION',false] spawn A3C_POLY_ACTION_ON;
			};

		};

		//-- additional data for helicopters (not relevant for ground vehicles)
		if (_vehicle isKindOf "AIR") then {
			if (_vehicle isKindOf "PLANE") then {
				//-- adjust lower heights for planes
				if (_wpFlyInHeight == 25) then {_wpFlyInHeight = 150};
				if (_wpFlyInHeight == 5) then {_wpFlyInHeight = 25};
			} else {
				_unit setvariable ["A3C_REDUCE_SPEED",true,true];
			};
			if (_wpFlyInHeight == 1000) then {
				//-- weird fix for pilots bugging out in high altitudes
				_h = (getpos _vehicle) select 2;
				while {_h < 1000} do {
					_h = _h + 100;
					_vehicle flyinHeight _h;
					sleep 10;
				};
				_v flyinHeight 1000;
			} else {
				_vehicle flyinheight _wpFlyInHeight;
				//_vehicle flyInHeightASL [_wpFlyinHeight,_wpFlyinHeight,_wpFlyinHeight];
			};
			{_vehicle animateDoor [_x, 0]} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
			_unit enableAI "move";
			_vehicle enableAI "move";
		};
		//systemchat str _movepos;
		if ([_movePos, (nearestBuilding _movePos)] call A3C_fnc_INSIDE) then {_inBuilding = true} else {_inBuilding = false};

		//systemchat str [_movepos,_inBuilding];
		//if (true) exitWith {};

		if (_unit == driver _vehicle) then {
			if (!(_unit getvariable ["A3C_HOLD",false])) then {
				
				if !((_wpAction select 0) in ["SUPPRESSION","GRENADE"]) then {
					[_unit,_movePos] call A3C_DOMOVE;
					
					//systemChat 'variant 1';
				} else {
					[_unit,position _vehicle] call A3C_DOMOVE;
					//systemChat 'variant 2';
				};
			} else {
				//systemChat 'variant 3';
				[_unit,position _vehicle ] call A3C_DOMOVE;
			};
		};


		//(format ["%1 waittilcomm",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];


		if (_vehicle isKindOf "Man") then {
			_varidist = 5;
		} else {
			if (_vehicle isKindOf "Air") then {
				if (_landingdata == "NONE") then {
					_variDist = if (_wpAction select 0 == "PARADROP") then {50} else {150}; //500
				} else {
					_variDist = 150;
				};
			} else {
				_variDist = 15;
			};	
		};

		if !((_wpAction select 0) in ["SUPPRESSION","GRENADE"]) then {
			if !(_vehicle == _unit) then {
				if !(player == (effectivecommander _vehicle)) then {
					private _moving = false;
					while {_unit == driver _vehicle} do {
						if (isNil '_unit') exitWith {};
						if (isNull _unit) exitWith {};
						if (!alive _unit) exitWith {};
						private _commDest = (expectedDestination (effectivecommander _vehicle) select 0);

						if (_vehicle distance2D _movePos <= _variDist) then {
							_moving = true;
						} else {
							if ((_commDest distance2D _movePos ) < 2 ) then {
								if ((_commDest distance2D _origDest ) > 20 ) then {
									_moving = true;
								};
							};
						};

						if (_moving) exitWith {};
						sleep 2;
						_data = (_unit getvariable ["A3C_PLOT",[]]);
						_wpData = (_data select _cycle);
						_wpData params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
						_movePos  = _wpPositions select 0;
						//systemchat 'brokenfrom2';
						if ([_unit,_movePos,_data,_cycle,0] call A3C_ExitRoute_isBrokenFrom) exitWith {
							_abort = true;
						};
						[_unit,_movePos ] call A3C_DOMOVE;
					};

					//waituntil {};
					//waituntil {};
				};
			};
		};


		//-- set WP-details (speed/stance)
		_unit setunitpos _unitPosTravel;
		if !(_wpSpeed == -1) then {
			if (_vehicle == _unit) then {
				_maxSpeed = 2;
			} else {
				_maxSpeed = if (_vehicle iskindof "AIR") then {60} else {15};
			};
		} else {
			if (isnull objectParent _unit) then {
				_maxSpeed = -1;
			} else {
				_maxSpeed = 1000;
			};
		};
		if (isnull objectparent _unit) then {
			_unit forcespeed _maxSpeed;
		} else {
			_vehicle limitspeed _maxSpeed;
		};
		_unit setvariable ["A3C_MOVE_Active",true,true];


		if !(_vehicle == _unit) then {_vehicle = vehicle _unit}; //asasas


		//sleep 1; //~~ #UNCLEAR why is this needed?
		_unit stop false;

		//systemchat "2";
		private _complete = false;
		//THIS BIT CAN GET STUCK!
		//(format ["%1 pre mov",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
		if (_unit == driver _vehicle && {!((_wpAction select 0) in ["GRENADE","SUPPRESSION"])}) then {
			//-- wait until exit-conditions can be considered
			if (_vehicle isKindOf "AIR") then {
				if (_vehicle distance2d _movePos < 200) then {
					if (((getPosATL _vehicle) select 2) < 3) then {
						_vehicle engineOn true;
						[_unit,_movePos] call A3C_DOMOVE;
						//-- wait until aircraft has gained altitude
						while {(canMove _vehicle) && (alive driver _vehicle)} do {
							if (((getPosATL _vehicle) select 2) > 15) exitWith {};
							sleep 1;
						};
					};
					//(format ["%1 shoot 1",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
				};
				sleep 2;
			} else {
				private _threshHold = 0;
				if (isPlayer leader group _unit) then {
					while {alive _unit} do {
						if ([_unit] call A3C_ExitRoute_isWpAborted) exitWith {_abort = true};
						if ( (toLower((expectedDestination _unit ) select 1)) in ["leader planned","vehicle planned"]) exitWith {};
						_variDist = switch (true) do {
							case (_vehicle isKindOf "MAN") : {5};
							case (_vehicle isKindOf "AIR") : {150};
							default {15};
						};
						if (_vehicle distance _movePos <= (_precision + _variDist)) exitWith {_complete = true};
						_threshHold = _threshHold + 1;
						if (_threshHold >= 20) then {
							_threshHold = 0;
							if (!(_unit getvariable ["A3C_HOLD",false] ) && {_unit == driver _vehicle}) then {
								[_unit,_movePos] call A3C_DOMOVE;
							};
						};
						//(format ["%1 shoot 2",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
						sleep 0.1;
					};
					//waituntil {((expectedDestination _unit ) select 1) in ["LEADER PLANNED","VEHICLE PLANNED"]};
				};
			};
		};
		
		//for "_i" from 0 to 3 do { //-- DEBUG HC Building Clearing with VR units
		//	_unit setObjectTexture [_i, "#(rgb,8,8,3)color(0,1,0,1)"];
		//}



		//////////////////////////////////
		//-- WAIT FOR UNIT TO REACH WP
		//////////////////////////////////




		_timer = time;
		_ct = 0;
		_conPos = [0,0,0];
		_checkTime = 5;
		//_unit setVariable ["A3C_UNITMOVING",true];
		//_unit doFSM ["A3C_CORE\fsm\shutUp.fsm", _movePos,_unit];

		if ((effectivecommander _vehicle) == player) then {sleep 1};
		if (A3C_DEBUG)then {
			//player commandchat format ["%1 is on a active waypoint",name _unit];
		};
		//(format ["%1 moving",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
		private _stuckCycles = 0;
		while {true} do { //~~ is 'alive _unit' not a safer condition?
			//-- Update Waypoint Data
			waituntil {!A3C_REFRESHING};
			_data = (_unit getvariable ["A3C_PLOT",[]]);
			//if (_cycle > ((count _data) -1)) exitWith {};

			if (_cycle >= count _data) exitwith {};
			if (_cycle >= (count (_unit getvariable ["A3C_PLOT",[]])) ) exitwith {
				if (A3C_DEBUG) then {
					systemchat format ["%1 exit no more data",name _unit];
				};
			};
			_wpData = (_data select _cycle);
			_wpData params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
			_wPos = _wpPositions select 0;
			_lookAtPos = _wpPositions select 1;
			_wpMarkerMain = _wpMarkers select 0;
			_wpMarkerXtra = _wpMarkers select 1;
			//_wpMarkerDir = _wpMarkers select 2;
			_unitPosTravel = _wpStances select 0;
			_unitPosDest = _wpStances select 1;
			_vehicle = vehicle _unit; //-- refresh
			_movePos = _wPos;
			_doExit = false;
			_landingdata = if ((_wpAction select 0) == "LANDING") then {_wpAction select 1} else {""};
			_wpTimeoutValue = if ((_wpAction select 0) == "TIMEOUT") then {_wpAction select 1} else {0};
			if (_complete) exitwith {};
			if ((_wpAction select 0) in ["GRENADE","SUPPRESSION"]) exitwith {};
			
			if (_unit == driver _vehicle) then {
				
				//if (_vehicle isKindOf "HELICOPTER" && {!isnull getSlingLoad _vehicle}) then {
				//	//_vehicle setVectorUp [0,-0.2,1];
				//	if (speed _vehicle > 100) then {
				//		if (speed _vehicle <= 150) then {
				//			_vel = velocity _vehicle;
				//			_dir = direction _vehicle;
				//			_speed = 1;  //if (speed _vehicle < 10) then {10} else {10};
				//			_vehicle setVelocity [
				//				(_vel select 0) + (sin _dir * _speed),
				//				(_vel select 1) + (cos _dir * _speed),
				//				0
				//			];
				//		};
				//	};
				//};

				//-- re-adjust variDist
				if ((_wpAction select 0) in ["CTRL_DET"]) then {
					// hint format ["DEBUG DETO: %1", _wpAction]; 
					(_wpAction select 1) params ["_targetObject","_magType"];
					if (!isNull _targetObject) then {
						if (unitReady _unit) then {//-- only if unit is not moving anymore, we want him to get as close as possible
							_variDist = (sizeof typeOf _targetObject);
						};

					};
				};

				//player commandchat str ([_unit,_movePos,_variDist,_inBuilding,_wpRadius,_wpTimeoutValue] call A3C_ExitRoute_isWpCompleted);
				
				//-- NON NEGOTIOABLE EXIT CONDITIONS
				//-- check if wp is completed (first because STOPPED and BREAK are subordinate and share conditions).
				if ([_unit,_movePos,_variDist,_inBuilding,_wpRadius,_wpTimeoutValue] call A3C_ExitRoute_isWpCompleted) exitwith {
					_doExit = true;
					_unit setunitpos _unitPosDest;
					if (_inBuilding) then {
						_unit dowatch ([(getPosATL (nearestBuilding _wPos)),100, ([(nearestBuilding _wPos),_wPos] call BIS_fnc_DirTo)] call BIS_fnc_RelPos);
						_unit lookat ([(getPosATL (nearestBuilding _wPos)),100, ([(nearestBuilding _wPos),_wPos] call BIS_fnc_DirTo)] call BIS_fnc_RelPos);
					} else {
						if !(_lookAtPos isEqualTo []) then {
							_unit dowatch _lookAtPos;
							_unit lookat _lookAtPos;
						};
					};
				};


				if ([_unit] call A3C_ExitRoute_isWpAborted) exitWith {_abort = true};
				



				if !(A3C_BOOL_MOVINGMARKER) then {
					//-- exit stop
					if ([_unit,_movePos,0] call A3C_ExitRoute_isUnitStopped) then {
						_abort = true;
					};
				};

				private ["_hold"];
				_hold = _unit getvariable ["A3C_HOLD",false];


				//-- HOLD Dependent CONDITIONS
				if !(_hold) then {

					if !(A3C_BOOL_MOVINGMARKER) then {
						//-- unstucker
						if (time > (_timer + _checkTime)) then {
							_timer = time;
							if (_checkTime == 1) then {
								_checkTime = 5;
							};

							//if !(_vehicle isKindOf "AIR") then{
								if ( (speed _vehicle) < 1) then {
									//systemchat "move";
									/*
									_stuckCycles = _stuckCycles + 1;
									if (isNull objectParent _unit) then {
										//-- infantry only:
										//-- step 1: check if non-moving unit is in building
										_refpos = eyepos _unit; 
										private _ins = lineIntersectsSurfaces
										[
											_refPos vectorAdd [0,0,20],
											_refPos vectorAdd [0,0,-3],
											_unit,
											objNull,
											true,
											1,
											"GEOM",
											"NONE"
										];
										if ( (_stuckCycles > 2)  OR {count _ins == 0 OR {isNull ((_ins select 0) select 2)}} ) then {
											//-- unit is not in building:
											// OR {!(((_ins select 0) select 2) isKindOf "HOUSE")}
											_stuckCycles = 0;
											
											private _ins = [[[0,0,0],-1,_unit]];
											private _exit = false;
											for "_t" from 0.5 to 2 step 0.1 do {
												for "_i" from 0 to 500 do {
													_refPos = [_refPos,_t, random 360] call BIS_fnc_relPos;
													_ins = lineIntersectsSurfaces
													[
														_refPos vectorAdd [0,0,2],
														_refPos vectorAdd [0,0,-3],
														_unit,
														objNull,
														true,
														1,
														"GEOM",
														"NONE"
													];
													sleep 0.01;
													if (isNull ((_ins select 0) select 2)) exitWith {
														_exit = true;
														_refPos = (_ins select 0) select 0;
														_unit setposASL _refPos;
														//systemchat "UNSTUCKER FNC_AI";
													};
												};
												if (_exit) exitWith {};
											};
										
										};

									} else {
										_stuckCycles = 0;
									};
									*/									
									[_unit,_movePos] call A3C_DOMOVE;

									_unit setunitpos _unitPosTravel;
									if (isnull objectparent _unit) then {
										_unit forcespeed _maxSpeed;
									} else {
										_vehicle limitspeed _maxSpeed;
									};
								};
								if ((_conPos distance (position _unit)) < 1) then {
									if !(_inBuilding) then {
										if (behaviour _unit != "COMBAT") then {
	//~~ CURRENTLY DISABLES THE ENTIRE 'STUCK EXIT'									_ct = _ct + 1;
										};
									};
								};
							//};
						};
						_conPos = position _unit;
						//_condition = true;
						if (_ct > 0) then {
							if (isnull objectparent _unit) then {
								if (_unit in A3C_BOARD_UNITS_ACTIVE) then {
									if ( (_vehicle distance _movePos) < 20) then {
										_abort = true;
										if (A3C_DEBUG) then {
											systemchat format ["%1 exit ct (move)",name _unit];
										};
									};
								};
							};
						};
						if (_ct > 8) then {
							if (isnull objectparent _unit) then {
								if (_maxSpeed == -1) then {
									_abort = true;
									
									if (A3C_DEBUG) then {
										systemchat format ["%1 exit ct2 (move)",name _unit];
									};
								} else {
									_ct = 0;
								};
							};
						};
					};
					if ( _vehicle == _unit) then { //-- different radius for inf and cars
						_completionRadius = 5;
						_pause = 2;

					} else {
						_completionRadius = 20;
						_pause = 0;
					};

					if !(_abort) then {
						sleep 0.5; //~~ formerly #UNCLEAR :: why is this needed? - removing causes waypoint plans to abort
					};

					if (!(A3C_BOOL_MOVINGMARKER) && !(_wpAction select 0 == "REARM")) then { //~~ Temp Fix!!
						if ([_unit,_origdest,_data,_cycle,0] call A3C_ExitRoute_isBrokenFrom) then { //(false) then { // 
							_abort = true;					
						};
					};
				} else {
					if !(_unit getVariable "A3C_HOLD_COVER") then {
						//if !(position _unit isFlatEmpty  [5, -1, -1, -1, -1, false, _unit] isEqualTo []) then {
							_unit setVariable ["A3C_HOLD_COVER",true,false];
							if (speed _unit > 1) then { //~~ not ideal
								[[_unit],1] spawn A3C_FindCover;
							};
						//};
					};
					_checkTime = 1;
				};

				//\\-- WHAT IS THIS BELOW?? can it even be executed??
				private _expD = (expectedDestination _unit);
				if ( !(_expD isEqualTo []) && {  (_expD select 1) == "DoNotPlan" }  ) then {
					if !(currentcommand _unit == "STOP") then {
						if (((expectedDestination _unit) select 1) == "Leader Planned") then {
							//-- low level move command has failed
							_unit groupchat format ["I can not reach Waypoint No. %1. Proceeding with plans",(_cycle + 1)];
							[_unit,position _vehicle ] call A3C_DOMOVE;
							_unit setvariable ["A3C_ABORT_Data",[false,true],true];
						};
					};
				};

				//if (_abort && {!(_unit getVariable ["A3C_PAUSE_PLAN",false])}) then {systemchat "BUG"};
				if (_abort && {!(_unit getVariable ["A3C_PAUSE_PLAN",false])}) exitWith {};

				//-- switch of default behavior if ordered. done in the loop to prevent loss during saveGame/loadGame
				if (_wpCombatMode == 1) then {
					{_unit disableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"THREAT_PATH","PATHPLAN",
					if !(combatmode _unit == "BLUE") then {
						[_unit,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual;
					};
				} else {
	//				if (combatmode _unit == "BLUE") then {
	//					[_unit,["COMBATMODE","YELLOW"]] call MCSS_fnc_orderIndividual;
	//				};
				};

				_getDistance = if (_vehicle == _unit) then {
					(_unit distance _movePos)
				} else {
					(((getposASL _vehicle) select [0,2]) distance (_movePos select [0,2]))
				};



				_speedDist = 1200;
				if (_landingData == "RAPPEL") then {_speedDist = 300};
				if (_vehicle isKindOf "Helicopter") then {
					if ((_wpAction select 0) == "NONE") then {
						if (_cycle == (count _data - 1)) then {
							_speedDist = 300;
						};
					};
				};
				if ( (_vehicle iskindof "AIR") && !(_abort)) then {
					if ( (((getposASL _vehicle) select [0,2]) distance (((expecteddestination _unit) select 0) select [0,2])) < _speedDist ) then {
						if ( (speed _vehicle) > 150) then {
							if !(_landingdata == "NONE") then {
								if (_unit getvariable "A3C_REDUCE_SPEED") then {
									_unit setvariable ["A3C_REDUCE_SPEED",false,true];
									[_unit,150] spawn A3C_REDUCE_SPEED;
								};
							};
						};
					};
					if (_wpTimeoutValue > 0) then {
						_wpRadius = 50;
						_varidist = 10;
					};
					{_unit disableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"THREAT_PATH","PATHPLAN",
					_unit dotarget objnull; _unit dowatch objnull;
					{_unit setskill [_x,0]} foreach ["commanding","spotTime","spotDistance"];
					_vehicle land "NONE";
				};
				sleep 0.2;
			} else {
				sleep 0.2;
				//-- unit has just exited vehicle -> send to BIS_fnc_moduleTaskSetDestination
				if (_unit == driver vehicle _unit) then {
					if (isNull objectParent _unit) then {
						sleep 2; //-- allow some time for unit to complete engine dismount-routine
						waituntil {unitReady _unit};
					} else {
						sleep 3;
					};
					//-- we have to do a loop to make sure the dismount routine does not harm us!
					//-- sometimes (ie with editor placed cargo units) the dismount triggers the unit to run somewhere,
					//-- we have to overwrtie this
					//-- KEEP IN MIND: since varidist is currently calculated before while loop, first waypoint will probably have 15m radius
					while {_movepos distance2d ( (expectedDestination _unit) select 0) > 0} do {
						[_unit,_movePos] call A3C_DOMOVE; //-- boost
						sleep 1;
					};
				};
			};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true; }; 
			if (_unit getVariable ["A3C_PAUSE_PLAN",false]) then {_abort = false};
			if (_abort OR {_doExit}) exitWith {};
		};

		//systemchat format ["%1 has arrrived with abort value %2, inBuilding %3",_unit,_abort,_inBuilding];
		
		//////////////////////////////////
		//-- UNIT HAS ARRIVED
		//////////////////////////////////
		//"111" remoteExec ["systemchat",0];
		if !(isPlayer (leader group _unit)) then { //-- prevent High COmmand units from immediately returning to formation
			[_unit,_movePos] call A3C_DOMOVE; //#MONITOR
		};

		//if (A3C_DEBUG)then {
			//systemchat format ["%1 has completed a waypoint",name _unit];
		//};
		//-- refresh data (current waypoint settings may have been changed)
		_data = (_unit getvariable ["A3C_PLOT",[]]);
		if (_cycle >= count _data) exitWith {};
		_wpData = (_data select _cycle);
		if (isNil '_wpData') exitWith {};
		_wpData params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];

		//_unit setVariable ["A3C_UNITMOVING",false];
		///////////////////////////////////////////////////
		//-- wp complete
		///////////////////////////////////////////////////
		//systemchat str _abort;
//		if (combatmode _unit == "BLUE") then { //~~ IFFY: make an additional variable in objectNamespace for BLUE waypoints as opposed to global setting
//			[_unit,["COMBATMODE","YELLOW"]] call MCSS_fnc_orderIndividual; //-- reset combatmode so unit can cover other hub-units
//		};
		if (isnull _unit) exitwith {};
		if !(_abort) then {
			//-- Spawn AI Rail
			if !((_wpAction select 0) in ["GRENADE","SUPPRESSION","REARM"]) then {
				if (profileNameSpace getVariable ["A3C_FORCERAIL_VAR", false]) then {
					if (isnull objectparent _unit && {_cycle == ((count _data) - 1)}) then { //~~ ONLY DO THIS IF IT'S FINAL WAYPOINT OR UNIT HAS TO WAIT
						_aslP = +(getPosASL _unit);
						_aslRef = ATLtoASL _wPos;
						{
							_x set [2,(_x select 2) + 0.3];
						} foreach [_aslP,_aslRef];
						if (count (lineIntersectsObjs [_aslP, _aslRef, _unit, objnull, false]) == 0) then {
							waituntil {speed _unit < 1};
							if !(_lookAtPos isEqualTo []) then {
								_rail = [_unit,_wPos,_lookAtPos] spawn A3C_forceDestination;
								waituntil {scriptDone _rail};
								_unit dowatch _lookAtPos;
								_unit lookat _lookAtPos;
							};
						};
					};
				};
			};
			//systemchat str [_cycle,_wpCondition];
			if (_vehicle isKindOf "TANK") then {
				if ( ((_wpCondition select 0) != "NONE") OR ((_cycle + 1) == count (_unit getVariable ["A3C_PLOT",[]])) ) then {
					if !(_lookAtPos isEqualTo []) then {
						waituntil {unitReady _unit && speed _vehicle == 0};
						//sleep 2;
						_spawnBehaviour = [_vehicle,_lookAtPos] spawn A3C_FORCEORIENT;
						waitUntil {scriptDone _spawnBehaviour};
					};
				};
			};


			switch (_wpAction select 0) do {
				case ("EHM") : {
					//systemchat '1z';
					//_rail = [_unit, ATLtoASL _movePos] spawn A3C_forceDestination;
					//waituntil {scriptDone _rail};
					//sleep 0.1;
					_unit setPos _movePos;
					_unit setDir (_movePos getDir _lookAtPos);
					_unit call A3C_Babe_fnc_detect;

					//sleep 1;
					//private _takeOff = position _unit;
					//for "_i" from 1 to 2 do {
					//	if (_unit distance _takeOff < 0.2) then {
					//		_unit call A3C_Babe_fnc_detect;
					//		//	_unit call Babe_EM_fnc_detect;
					//		sleep 1;
					//	};
					//};
					waitUntil {!(_unit getVariable ["A3C_EM_ACTIVE",false])};
					[_unit,position _unit] call A3C_DOMOVE;
				};
				case ("REARM") : {
					//systemchat '2z';
					_spawnBehaviour = [_unit,(_wpAction select 1)] spawn A3C_ReArm_Plot_Behavior;
					waitUntil {scriptDone _spawnBehaviour};
					[_unit,_movePos] call A3C_DOMOVE;
					sleep 2;
				};
				case ("SLINGLOAD") : {
					_slingMode = if (isnull (getSlingLoad _vehicle)) then {0} else {1};
					waitUntil {(getPosATL _vehicle select 2) > 5};
					waitUntil {speed _vehicle < 50};
					//systemchat str _slingMode;
					_spawnBehaviour = {};
					if (_slingMode == 0) then {
						_spawnBehaviour = [_slingMode,_vehicle,_wpAction select 1] spawn A3C_BEHAVIOUR_SQ_HELI_Sling;
						waitUntil {scriptDone _spawnBehaviour};
					} else {
						_slingCargo = getSlingLoad _vehicle;
						if !(isnull _slingCargo) then {
							_cargoHeight = (((boundingBoxreal _slingCargo) select 1) select 2) + 10;
							//waitUntil {unitReady _unit}; //~~ add conditions //(speed _veh < 2) && (_movePos distance2d _vehicle < 50)
							waitUntil {speed _vehicle < 50};
							[_unit,position _vehicle] call A3C_DOMOVE;
							sleep 1;
							//_fHeight = ((((boundingBoxReal (getSlingLoad _vehicle)) select 1) select 2) + 8);
							//_vehicle flyInHeightASL [0,0,0];
							//_vehicle flyInHeight 0; //_fHeight;
							//waitUntil {(getPosATL _vehicle select 2) < (_fHeight + 8)};
							_slingPos = +(_movePos);
							_slingPos set [2,_cargoHeight];
							_spawnBehaviour = [_slingMode,_vehicle, ATLtoASL _slingPos] spawn A3C_BEHAVIOUR_SQ_HELI_Sling;
							//_vehicle flyInHeightASL [_wpFlyinHeight,_wpFlyinHeight,_wpFlyinHeight];
							waitUntil {scriptDone _spawnBehaviour};
							_unit doMove (position _vehicle); _unit moveTo (position _vehicle); //doStop _unit;
							_unit moveTo _movePos;
							sleep 2;
						};
					};
				};
				case ("CTRL_DET") : {
					_spawnBehaviour = [_unit,_movePos,(_wpAction select 1)] spawn A3C_WP_ACTION_PlantExplosive;
					waitUntil {scriptDone _spawnBehaviour};
					sleep 0.5;
				};
			};
			//-- Spawn Landing Behaviour for choppers
			if ( !(_vehicle == _unit) && !(_landingdata == "NONE") )then {
				_unit setvariable ["A3C_CREWCOUNT",(count crew _vehicle),true];
				switch (true) do {
					case (_landingdata in ["PICKUP","DROPOFF"]) : {
						_spawnBehaviour = [_unit,(leader group _unit),_movePos,_landingData,_landingdata] spawn A3C_BEHAVIOUR_SQ_HELI_PICKANDDROP; //~~ WTF
						waitUntil {scriptDone _spawnBehaviour};
					};
					case (_landingdata == "LANDFINAL") : {
						_spawnBehaviour = [_unit,(leader group _unit),_movePos] spawn A3C_BEHAVIOUR_SQ_HELI_LANDFINAL;
						waitUntil {scriptDone _spawnBehaviour};
					};
					case (_landingdata == "RAPPEL") : {
						_spawnBehaviour = [_unit,(leader group _unit),_movePos] spawn A3C_BEHAVIOUR_HELI_RAPPEL;
						waitUntil {scriptDone _spawnBehaviour};
					};
				};
			};
			//{_unit disableAI _x} foreach ["MOVE", "FSM"];

			if (_vehicle isKindOf "Helicopter") then {
				if ((_wpAction select 0) == "NONE") then {
					if (_cycle == (count _data - 1)) then {
						_subBehaviour =
						[
							_vehicle,
							getPosASL _vehicle,
							ATLtoASL ((_movePos select [0,2]) + [_wpFlyInHeight]),
							50
						] spawn A3C_AI_RAIL_HELI;
						waituntil {scriptDone _subBehaviour};
						doStop _unit;
					};
				};
			};
		};

		//"222" remoteExec ["systemchat",0];
		private _hubUnits = [];
		private _otherUnits = [];
		private _hubLeader = false;
		if (group _unit == group player) then {


			//-- gather HUD units
			/////////////////////


			_otherUnits = (units _unit) - [player,_unit];
			{
				private _soldier = _x;
				private _unitData = (_soldier getvariable ["A3C_PLOT",[]]);
				if (alive _soldier) then {
					{
						if (_wpMarkerMain == ((_x select 1) select 0)) then {
							_hubUnits pushBackUnique _soldier;
						};
					} foreach _unitData;
				};
			} foreach _otherUnits;
			//-- sort hubUnits by formIndex and find out if unit is the highest in chain
			_hubUnits = [([_unit] + _hubUnits),[],{_x getvariable "A3C_FORMATION_INDEX"},"ASCEND"] call BIS_fnc_sortBy;
			_hubLeader = (_unit == (_hubUnits select 0));


			///////////////////////////////////////////
			//-- MARK WP AS COMPLETED
			///////////////////////////////////////////
			_switchdata = if !(isnull _unit) then {(_unit getvariable ["A3C_PLOT",[]])} else {[]};
			if (count _switchData > 0) then {
				//-- remember: hubLeaders of waypoints with STATICWEAPON action will be completed after action is completed.
				if !(_hubLeader && {(_wpAction select 0) in ["STATIC"]}) then {
					//systemchat "completed";
					(_switchdata select _cycle) set [6,true];
					_unit setvariable ["A3C_PLOT",_switchdata,true];
				};
			};


			///////////////////////////////////////////
			//-- WAIT FOR OTHER UNITS TO REACH WP (HUB)
			///////////////////////////////////////////
			while {true} do {
//systemchat str ["HUB",time];
				if ((_wpAction select 0) in ["GRENADE","SUPPRESSION"]) exitwith {};


				if ([_unit] call A3C_ExitRoute_isWpAborted) exitwith {_abort = true};
				if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true};


				if !(A3C_BOOL_MOVINGMARKER) then {
					//-- exit stop
					if ([_unit,_movePos,1] call A3C_ExitRoute_isUnitStopped) then {
						_abort = true;
					};
				};
				//if (_abort && {!(_unit getVariable ["A3C_PAUSE_PLAN",false])}) then {systemchat "BUG"};
				if !((_wpAction select 0) == "STATIC") then { // << TEMP SOLUTION!
					//systemchat 'brokenfrom4';
					if ([_unit,_origdest,_data,_cycle,1] call A3C_ExitRoute_isBrokenFrom) then {
						_abort = true;
					};
				};

				if (_abort) exitwith {};
				_otherUnits = units group player - [player,_unit];
				_hubComplete = true;
				{
					private _soldier = _x;
					private _unitData = (_soldier getvariable ["A3C_PLOT",[]]);
					if (alive _soldier) then {
						{
							if (_wpMarkerMain == ((_x select 1) select 0) && {!(_wpMarkerMain == "")}) then {
								if !(_x select 6) then {
									_hubComplete = false;
								};
							};
						} foreach _unitData;
					};
				} foreach _otherUnits;
				if (_hubComplete) exitwith {};
				sleep 1; //~~ #UNCLEAR  is this needed? [might be irrelevant for single units - CONFIRMED]

			};
		};
		_vehicle = vehicle _unit; //-- refresh

		//-- WP ACTION: STATIC WEAPONS (had to wait unitil HUB is complete
		if (_wpAction select 0 == "STATIC" && {!(_abort)}) then {
			sleep 0.2;
			_staticData = _wpAction select 1;

			//-- bundle HUB units into one function
			if (_hubLeader) then {
				private _spawnBehaviour =
				[
					_hubUnits,
					_staticData,
					_movePos,
					if !(_lookAtPos isEqualTo []) then {[_movePos,_lookAtPos] call BIS_fnc_dirTo} else {0}
				] spawn A3C_WP_ACTION_STATICWEAPON;
				waitUntil {scriptDone _spawnBehaviour};
				//systemchat "cont";
				//-- remember: hubLeader's wp is completed.
				_switchdata = if !(isnull _unit) then {(_unit getvariable ["A3C_PLOT",[]])} else {[]};
				if (count _switchData > 0) then {
					(_switchdata select _cycle) set [6,true];
					_unit setvariable ["A3C_PLOT",_switchdata,true];
				};
			} else {


				private _formLeader = (_hubUnits select 0);
				_hubComplete = true;
				//while {alive _formLeader} do {
				//	private _unitData = if !(isnull _formLeader) then {(_formLeader getvariable ["A3C_PLOT",[]])} else {[]};
				//	{
				//		if (_wpMarkerMain == ((_x select 1) select 0)) then {
				//			if !(_x select 6) then {
				//				_hubComplete = false;
				//			};
				//		};
				//	} foreach _unitData;
				//	if (_hubComplete) exitWith {};
				//	sleep (1 + (random 0.5));
				//};

			};
			sleep 0.5;
			[_unit,_movePos] call A3C_DOMOVE;
			sleep 1;

		};


		//-- WAIT FOR WP-SYNC
		_pickUpUnits = [];
		_syncIndex = 0;
		private ["_otherUnits"];
		_otherUnits = units group player - [player,_unit];
		if !(((_wpSyncData select 0) select 0) == 0) then {
			//-- SYNCDATA DETECTED
			while {true} do {

				//~~ Authors note: WRITE ALL THESE _ABORT CHECKS INTO A FUNC!!!!!
				if ([_unit] call A3C_ExitRoute_isWpAborted) exitwith {_abort = true};
				if !(A3C_BOOL_MOVINGMARKER) then {
					//-- exit stop
					if ([_unit,_movePos,1] call A3C_ExitRoute_isUnitStopped) then {
						_abort = true;
					};
				};
				if !((_wpAction select 0) == "SUPPRESSION") then {
					//systemchat 'brokenfrom5';
					if ([_unit,_origdest,_data,_cycle,1] call A3C_ExitRoute_isBrokenFrom) then {
						_abort = true;
						//{dostop _x} foreach [_unit,effectivecommander _vehicle];
					};
				};
				if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) then {
					_abort = true;
				};
				if (_abort) exitwith {};
				private ["_syncComplete","_pickUp"];
				_syncComplete = true;
				_data = (_unit getvariable ["A3C_PLOT",[]]);
				_wpSyncData = ((_data select _cycle) select 5);
				_pickUp = if (_wpAction select 1 == "PICKUP") then {true} else {false};
				_pickUpUnits = [];
				//if (_wpAction select 1 == "PICKUP") then {
				//	_unit groupChat format ["unit %1: Pilot",_unit getVariable "A3C_FORMATION_INDEX"];
				//};
				{
					_soldier = _x;
					if (alive _soldier) then {
						_dataCompared = ((_soldier getvariable ["A3C_PLOT",[]])); //(_soldier getvariable "A3C_PLOT_TEMP") +
						{
							private ["_comparedWP","_isComp"];
							_comparedWP = _x;
							_isComp = (_comparedWP select 6);
							if !( ((_x select 1) select 0) == _wpMarkerMain ) then { //-- exclude HUB units
								_syncDataCompared = (_comparedWP select 5);
								{
									private ["_syncIndex"];
									_syncIndex = (_x select 0);
									{
										_fi = _foreachIndex;
										if !(_syncIndex == 0) then {
											if ((_x select 0) == _syncIndex) then {
												if !(_isComp) then {
													_syncComplete = false;
													_syncCompleteMain= false;
													//systemchat str _soldier;
												} else {
													//if (_pickUp) then {
													//	_pickUpUnits pushBackUnique _soldier;
													//};
													(_syncDataCompared select _fi) set [1,true];
													_comparedWP set [5,_syncDataCompared];
													if ({!(_x select 1)} count _syncDataCompared > 0) then {
														//-- if no compared wp is complete
														if !(_abort) then {
															_syncComplete = false;
															_SyncCompleteMain = false;
														};
													};

												};
											};
										};
									} foreach _syncDataCompared;
									if (_syncComplete && {_pickUp}) then {
										_pickUpUnits pushBackUnique _soldier;
									};
								} foreach _wpSyncData;
							};
						} foreach _dataCompared;
						_soldier setVariable ["A3C_PLOT",_dataCompared,true];
					};
				} foreach _otherUnits;
				if (_syncComplete) exitwith {
					//if (assignedVehicle player == _vehicle) then {
					//	A3C_BOARD_UNITS_ACTIVE pushBackUnique player;
					//};
					if (_pickup) then {

						if (_vehicle isKindOf "HELICOPTER") then {
							[_unit,position _vehicle] call A3C_DOMOVE;
							sleep 0.2;
							_vehicle flyInHeight 1;
							_vehicle limitSpeed 0;
					//		{
					//			[_x ,position (vehicle _x)] call A3C_DOMOVE;
					//			sleep 1;
					//			//systemchat str _x;
					//			_x assignAsCargo _vehicle;
					//			//_x setVariable ["A3C_PAUSE_PLAN",true,false];
					//			[_x,"cargo",_vehicle] spawn A3C_BOARD;
					//			//sleep 1;
					//		} foreach _pickUpUnits;
							_spawnBehaviour = [_vehicle,"all",0,_pickUpUnits] spawn A3C_AssignVehicleSeatMacro;
							waituntil {scriptDone _spawnBehaviour};

							while {({(_x in _pickUpUnits)} count A3C_BOARD_UNITS_ACTIVE > 0) OR ({(assignedvehicle _x == _vehicle) && !(_x in _vehicle) && (alive _x)} count units group player > 0) } do {
								//if (player in A3C_BOARD_UNITS_ACTIVE) then {
								//	if !(assignedVehicle player == _vehicle) then {
								//		A3C_BOARD_UNITS_ACTIVE = A3C_BOARD_UNITS_ACTIVE - [player];
								//	};
								//};
								//if (assignedVehicle player != _vehicle) then {
								//	_pickUpUnits = _pickUpUnits -  [player];
								//};
								if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true};
								[_unit,(position _vehicle)] call A3C_DOMOVE;
								sleep 0.01;
								_vehicle setvelocity [0,0,0];
								//hintSilent format ["%1, %2", A3C_BOARD_UNITS_ACTIVE,_pickUpUnits];
							};
							//systemchat "cargo wait";
							//waituntil { {!(_x in A3C_BOARD_UNITS_ACTIVE)} count _pickUpUnits == 0 };
							//waituntil { {(_x in A3C_BOARD_UNITS_ACTIVE)} count _pickUpUnits > 0 };
						};
						if !(_vehicle isKindOf "AIR") then {
						//	{
						//		[_x ,position (vehicle _x)] call A3C_DOMOVE;
						//		sleep 1;
						//		//systemchat str _x;
						//		_x assignAsCargo _vehicle;
						//		[_x,"cargo",_vehicle] spawn A3C_BOARD;
						//		//sleep 1;
						//	} foreach _pickUpUnits;
						//	_vehicle limitSpeed 0;
							_spawnBehaviour = [_vehicle,"all",0,_pickUpUnits] spawn A3C_AssignVehicleSeatMacro;
							waituntil {scriptDone _spawnBehaviour};
						};
					};
				};
				sleep 0.1;
			};
		};

		_vehicle = vehicle _unit; //-- refresh
		//(format ["%1 post sync",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
		/////////////////////
		//-- WAIT FOR Ground CARGO


		if (_unit == driver _vehicle && {!(_vehicle isKindOf "AIR") && {!(_abort) && {(_wpAction select 0) == "CARGO_IN"}}}) then {
			while {canmove _vehicle} do {
				if (isNull _unit) exitwith {_abort = true};
				if ({(assignedvehicle _x == _vehicle) && !(_x in _vehicle) && (alive _x)} count units group player == 0) exitwith {};
				if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true};
				_unit dowatch objnull;
				sleep 1;
			};
			_vehicle limitSpeed 1000;
			[_unit,_movePos] call A3C_DOMOVE;
			sleep 1;
			_vehicle = vehicle _unit; //-- refresh
		};
		
		
		
		
		
		if ( !(_abort) && {(_wpAction select 0) == "CARGO_OUT" && {{_vehicle isKindOf _x} count ["AIR","MAN"] == 0}} ) then { //~~{_unit == driver _vehicle && 
			_vehicle limitSpeed 0;
			{
				if ((assignedVehicleRole _x) select 0 == "CARGO") then {
					[_x] spawn MCSS_fnc_GetOut;
					[_x ,position (vehicle _x)] call A3C_DOMOVE;
					sleep 0.2;

					if (player in _vehicle) then {
						player action ["eject",_vehicle];
					};
				};
			} foreach crew _vehicle;
			//if !( ) then {
			while {canMove _vehicle} do {
				_ex = true;
				{
					if !(_x in [driver _vehicle,gunner _vehicle, commander _vehicle]) then {
						_ex = false;
						[_x] spawn MCSS_fnc_GetOut;
						sleep 0.1;
					};
				} foreach (crew _vehicle);
				if (_ex) exitWith {sleep 2};
				sleep 0.1;
			};
			//waituntil {{[_x] call A3C_HELI_DISCHARGE} count crew _vehicle == 0};
			_vehicle limitSpeed 1000;
			[_unit,_movePos] call A3C_DOMOVE;
			_vehicle = vehicle _unit; //-- refresh
		};
		
		//f/////////////
		//-- WAIT FOR Helicopter CARGO
		_landingpos = position _vehicle;
		_vectorup = vectorup _vehicle;
		private _isGoCode = ((_wpCondition select 0) == "GOCODE");

		if ( (_vehicle isKindOf "HELICOPTER") && (_landingdata in ["PICKUP","DROPOFF"]) && !(_abort) ) then {
			{_x disableAI "MOVE"} foreach [_unit,_vehicle];
			_vehicle limitSpeed 0;
			//doStop _unit;
			sleep 0.2;
			_exit = false;
			//systemchat format ["loop IN %1",(str _unit)];

			while {canmove _vehicle} do {
				if (isNull _unit) exitwith {_abort = true};
				_vehicle = vehicle _unit;
				_unit dowatch objnull;
				_vehicle limitspeed 0;
				
				//_unit moveTo _landingPos;
				_vehicle flyinheight 0;
				_velocity = [0,0,0];
				if ((velocity _vehicle) select 2 > 0) then {_velocity set [2,-2]};
				_vehicle setvelocity _velocity;
				if (_landingdata == "DROPOFF") then {
					//~~ WHAT IS THIS??	AUTHORNOTE
					if (({(( ((_x select 2) getfriend (side _unit)) < 0.6)) && (_unit knowsabout (_x select 4) > 1.5)} count (_unit neartargets viewdistance)) > 0) then {
						[_unit,(position _vehicle)] call A3C_DOMOVE;
					};
				};
				if (_isGoCode) then {
					_goCode = (_wpCondition select 1);
					if (call compile format ["A3C_GoCode_Activate_%1",(parseText _goCode)]) then {
						_exit = true
					};
				} else {
					if (_landingdata == "PICKUP") then {
						if ({(assignedvehicle _x == _vehicle) && !(_x in _vehicle) && (alive _x)} count units group player > 0) then {
							_exit = false;
							[_unit,(position _vehicle)] call A3C_DOMOVE;
							_vehicle setvelocity [0,0,0];
						} else {
							_exit = true;
						};
					};
					if (_landingdata == "DROPOFF") then {
						if !( {[_x] call A3C_HELI_DISCHARGE} count crew _vehicle == 0) then {
							_exit = false;
						} else {
							_exit = true;
						};
					};
					if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) then {
						_abort = true;
						_exit = true;
						_vehicle land "NONE";
					};

				};


				if !(_unit == (driver _vehicle)) then {_exit = true};
				if (_exit) exitwith {};
				if !(_exit) then {
					sleep 0.01;
				};
			};
			_vehicle limitspeed 1000;
			_vehicle flyinheight 3;
			_vehicle = vehicle _unit; //-- refresh
		};




		//{_unit enableAI _x} foreach ["MOVE", "FSM"];
		_SyncComplete= false;
		_data = _unit getVariable ["A3C_PLOT",[]];
		(_data select _cycle) set [5,[[0,true]]];
		_unit setVariable ["A3C_PLOT",_data,true];

		{_x enableAI "MOVE"} foreach [_unit,_vehicle];

		if ( (_landingdata == "LANDFINAL") && !(_abort) ) then {
			_timenow = (time + 10);
			while {time < _timenow} do {
				if (isNull _unit) exitwith {_abort = true};
				_vehicle flyinheight 0;
				sleep 0.05;
				if (({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) OR !(_unit == (driver _vehicle)) ) exitwith {  //~~ TO DO: CHECK EXACTLY WHAT THIS DOES (relates to new UI setup / non driver planning)
					_abort = true;
					_vehicle land "NONE";
				};
			};
			_vehicle = vehicle _unit; //-- refresh
		};
		_exit = false;
		_unit Setvariable ["A3C_WAITCARGO",false,true];
		_vehicle setvariable ["A3C_CHOPPER_ASSG_ACTIVE",false,true];
		if ( (_vehicle iskindof "AIR") && !(_landingdata == "LANDFINAL") && !(_abort) ) then {
			[_unit,_movePos] call A3C_DOMOVE;
			sleep 0.5;
			_vehicle land "NONE";
		};

		//(format ["%1 pre timeout",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
		//-- WAYPOINT TIMEOUT?
		if ((_wpCondition select 0) == "TIMEOUT") then {
			//-- wait for timeout
			_wpTimeoutValue = (_wpCondition select 1);
			_threshold = 0;
			_counter = 0;
			if (_wpTimeoutValue > 0) then {_threshold = (_wpTimeoutValue / 0.1)};
			while {_counter < _threshold} do {
				if ([_unit] call A3C_ExitRoute_isWpAborted) exitwith {_abort = true};
				_vehicle = vehicle _unit; //-- refresh
				if !(A3C_BOOL_MOVINGMARKER) then {
					//-- exit stop
					if ((_wpAction select 0) in ["SUPPRESSION"]) then {
					} else {
						if ([_unit,_movePos,1] call A3C_ExitRoute_isUnitStopped) then {
							_abort = true;
						};
					};
				};
				if ((_wpAction select 0) in ["SUPPRESSION"]) then {
					if (((expectedDestination _unit) select 1) in ["DoNotPlanFormation", "FORMATION PLANNED"]) then {_abort = true};
				} else {
					//systemchat 'brokenfrom6';
					if ([_unit,_origdest,_data,_cycle,1] call A3C_ExitRoute_isBrokenFrom) then {
						_abort = true;
						{
							[_x ,position (vehicle _x)] call A3C_DOMOVE;
						} foreach [_unit,effectivecommander _vehicle];
					};
				};
				_otherUnits = [];
				{
					_soldier = _x;
					_unitData = (_soldier getvariable ["A3C_PLOT",[]]);
					if (alive _soldier) then {
						{
							if (_wpMarkerMain == ((_x select 1) select 0)) then {
								_otherUnits pushback _soldier;
							};
						} foreach _unitData;
					};
				} foreach (units group player);
				if (_unit == (_otherUnits select ((count _otherUnits) - ( if ((count _otherUnits) > 0) then {1} else {0})    )) ) then {
					_wpMarkerMain setmarkerTextLocal str (ceil (_wpTimeoutValue - (_counter * 0.1)) );
				};

				if (_abort) exitwith {};
				if (_vehicle isKindOf "AIR") then {
					if (_landingdata in ["PICKUP","DROPOFF"]) then {
						_vehicle setvelocity [0,0,0];
						_vehicle flyinheight 0;
					};
				};
				sleep 0.1;
				_counter = _counter + 1;
			};
		};


		if (isnull _unit) exitwith {};

		///////////////////////////////////////////
		//-- CHECK FOR GO-CODES
		//if ((_wpCondition select 0) == "GOCODE") then {
		//(format ["%1 pre goCode",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
		if ((_wpCondition select 0) == "GOCODE") then {
			_goCode = (_wpCondition select 1);
			if !(_goCode == "NONE") then {
				while {!(_goCode == "NONE")} do {
					if ([_unit] call A3C_ExitRoute_isWpAborted) exitwith {_abort = true};
					if !(A3C_BOOL_MOVINGMARKER) then {
						//-- exit stop
						if ([_unit,_movePos,1] call A3C_ExitRoute_isUnitStopped) then {
							_abort = true;
						};
					};

					//systemchat 'brokenfrom7';
					if ([_unit,_origdest,_data,_cycle,1] call A3C_ExitRoute_isBrokenFrom) then {
						_abort = true;
						//{dostop _x} foreach [_unit,effectivecommander _vehicle];
					};
					if (_abort) exitwith {};
					if (call compile format ["A3C_GoCode_Activate_%1",(parseText _goCode)]) exitwith {};
					sleep 0.1;
				};
			};
			((_data select _cycle) select 2) set [1,"NONE"];
			_unit setvariable ["A3C_PLOT",_switchdata,true];
			[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];
		};

		_vehicle = vehicle _unit; //-- refresh

		//if (_isGoCode) then {
		//	_goCode = (_wpCondition select 1);
		//	if !(_goCode == "NONE") then {
		//		if !(_landingdata in ["PICKUP","DROPOFF"]) then {
		//			_spawnGocode = [_unit,_goCode,_movePos,_origDest,_data,_cycle] spawn A3C_SpawnGoCode;
		//			waituntil {scriptDone _spawnGoCode};
		//		};
		//	};
		//	((_data select _cycle) select 2) set [1,"NONE"];
		//	_unit setvariable ["A3C_PLOT",_switchdata,true];
		//	[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];
		//};



		if (_wpAction select 0 == "PARADROP") then {
			_spawnBehaviour = [getPlayerUID player,_vehicle] call A3C_Paradrop_Eject;
			waitUntil {scriptDone _spawnBehaviour};
			sleep 2;
			[_unit ,_movePos] call A3C_DOMOVE;
			sleep 1;
		};




		sleep 0.1;

		//if (({!((_x select 10) == -1)} count _data) == 0) then {_isLoop = false};

		_counter = 0;
		if (_wpLoopValue > -1) then {
			_cycle = _wpLoopValue;
			//_isLoop = false;
		} else {
			_cycle = _cycle + 1;
		};
		_unit setvariable ["A3C_CURRENTWAYPOINT_INDEX",(_cycle + 1),true];
		sleep 0.1; //~~YOU CHANGED THIS
		//(format ["%1 pre PlanWait",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
		if (_cycle == (count _data)) then {
			while {(alive _unit)} do {
				if (isnull _unit) then {_abort = true};
				if ((count(_unit getvariable ["A3C_PLOT_TEMP",[]])) == 0) exitwith {};
				sleep 0.5;
			};

		};
		//(format ["%1 pre Pause",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
		while {alive _unit} do {
			if !(_unit getVariable ["A3C_PAUSE_PLAN",false]) exitWith {};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true};
			sleep 1;
		};

		if (!isPLayer (leader group _unit)) then {
			doStop _unit
		};
		//(format ["%1 end cycle",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];



	};
	//(format ["%1 post loop",[_unit, units _unit] call MCSS_fnc_getArrayINdex]) remoteExec ["systemchat",0];
	//(str [_unit,_abort]) remoteExec ["systemchat",0];
	_unit setVariable ["A3C_unitIsOnMainRoute",false,true];
	//if (_abort) then {
		//if (alive _unit) then {
			//if !( ( (expectedDestination _unit) select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
				////[_unit ,position _vehicle] call A3C_DOMOVE;
			//};
		//};
	//};
	_unit setvariable ["A3C_ABORT_Data",[false,false],true];
	//-- Just to be safe that we don't end up with a nasty line that can't be calculated and vomits script-errors :)
	//[_unit,"A3C_PLOT"] call A3C_REMOVE_ALL_LOOPLINES;

	//-- reset defaults
	{_unit enableAI _x} foreach ["MOVE","TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"PATHPLAN","THREAT_PATH",
	{_unit setskill [_x,((_unit getvariable "A3C_SKILLDATA") select _foreachindex)]} foreach ["commanding","spotDistance","spotTime"];
	_unit forcespeed -1;
	_vehicle = vehicle _unit; //-- refresh
	if (!isnull objectparent _unit && {_unit ==  driver vehicle _unit}) then {
		_vehicle limitSpeed 1000;
	};
	if !(_unit in A3C_DANGER_UNITS) then {
		_unit enableAI "AUTOCOMBAT";
	};
//	if (combatmode _unit == "BLUE") then {
//		[_unit,["COMBATMODE","YELLOW"]] call MCSS_fnc_orderIndividual;
//	};
	_unit setvariable ["A3C_MOVE_Active",false,true];

	_unit setvariable ["A3C_CURRENTWAYPOINT_INDEX",1,true];
	if !(alive _unit) then {sleep 5}; // safety for reassigning vars when clearing buildings
	_unit setvariable ["A3C_PLOT",[],true];
//	_unit setVariable ["A3C_DEST",[],true];
	//doStop _unit;
	//if (_unit == (leader group _unit)) then {
	//	systemchat format ["A3C_MOVE exit, ABORT: %1",_abort];

	//	for "_i" from 0 to 3 do { //-- DEBUG HC Building Clearing with VR units
	//		_unit setObjectTexture [_i, "#(rgb,8,8,3)color(1,1,1,1)"];
	//	};
	//};
	//player globalChat str ["END",_unit];

};



//if (isDedicated) exitwith {};








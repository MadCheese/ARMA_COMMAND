// A3C_ai_shared_fnc_planeLanding

params ["_unit","_inputPosition"];

if (isPlayer _unit) exitWith {};

private _vehicle = vehicle _unit;
private _group = group _unit;
private _vehicleType = typeOf _vehicle;
private _cfgVehicles = configFile >> "CfgVehicles";

_vehicle setUnloadInCombat [false,false];

private _dynamicArports = allAirports select 1;
private _dynamicLanding = false;
private _moving = false;
private _currentWaypoint = currentWaypoint _group;

_unit setVariable ["A3C_VAR_LANDING",true,true];

private _airportData = [_inputPosition] call A3C_main_fnc_getNearestAirportData;
_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];

private _airportAreas = _airportData call A3C_main_fnc_getAirFieldRunwayAreas;
_airportAreas params ["_mainAirfieldArea","_prohibitedAreas"];

_mainAirfieldArea params ["_areaCenter","_areaSizeX","_areaSizeY","_areaDir","_areaIsRectangle"];
private _mainAirFieldAreaConverted = [_areaCenter,[_areaSizeX,_areaSizeY,_areaDir,_areaIsRectangle]];

if (typeName _airportName == "OBJECT") then {
	private _tailHook = (getNumber (_cfgVehicles >> _vehicleType >> "tailHook")) > 0;
	_airportID = _airportName;

	if (_tailHook) then {
		_dynamicLanding = true;
	} else {
		_moving = true;
		[_vehicle,"LAND"] remoteExec ["land",_vehicle];
	};
};

if !(_moving) then {
	[_vehicle,_airportID] remoteExec ["landAt",_vehicle];
};

private _exit = false;
private _carrierLanding = false;
private _delete = false;

private _vehicleHandle = -2;
private _unitHandle = -2;

if (_dynamicLanding) then {
	_vehicle allowDamage false;
	[_vehicle,false] remoteExec ["allowDamage",_vehicle];

	private _addEHFunc = {
		params ["_object","_func"];

		if !(local _object) exitWith {};
		if (isNil "_func") exitWith {};

		private _handle = _object addEventHandler [
			"HandleDamage",
			compile format [
				"_this spawn %1",
				_func
			]
		];

		_object setVariable ["A3C_DAMAGE_HANDLE",_handle,true];
	};

	{
		[_x,A3C_ai_shared_fnc_planeDynamicLandingOnHandleDamage] call _addEHFunc;
	} forEach [_unit,_vehicle];
};


//-- alive exit
if (_vehicle getVariable ["alive_combatsupport",false]) exitWith {
	systemChat "A3C: You are using A3C's controls on ALIVE support planes. Plane will take off again. Use ALIVE-RTB to land thins plane";
};


private _landingTime = -1;
private _touchDownCount = if (_dynamicLanding) then {3} else {0};
private _sleep = if (_dynamicLanding) then {0.5} else {1};

while {alive _unit} do {
	if (!canMove _vehicle) exitWith {};

	if (isTouchingGround _vehicle) then {
		_touchDownCount = _touchDownCount + 1;

		if (_landingTime == -1) then {
			_landingTime = time;
		};

		if (surfaceIsWater _inputPosition) then {
			private _carrierObjects = _vehicle nearObjects ["Land_Carrier_01_base_F", 200];

			if (count _carrierObjects > 0) then {
				_exit = true;

				private _carrier = _carrierObjects select 0;

				//-- only works if plane has configs!
				[_vehicle,true] spawn BIS_fnc_aircraftTailhookAI;
				[_vehicle,0] remoteExec ["setFuel",_vehicle];

				sleep 5;

				if (alive _vehicle && {_vehicle == vehicle _unit}) then {
					_carrierLanding = true;

					private _storageData = [_vehicle,_carrier] call A3C_ai_shared_fnc_planeFindCarrierStorage;

					if (count _storageData > 0) then {
						[_vehicle,(_storageData select 0)] remoteExec ["setPosASL",_vehicle];
						[_vehicle,(_storageData select 1)] remoteExec ["setDir",_vehicle];
						[_vehicle,0] remoteExec ["setFuel",_vehicle];
						[_vehicle,[0,0,0]] remoteExec ["setVelocity",_vehicle];
					};
				};
			};
		};

		if (speed _vehicle < 40) then {
			_exit = true;
		};

		if (_landingTime != -1) then {
			if (time > _landingTime + 10) then {
				_exit = true;
			};
		};
	};

	if (!(_dynamicLanding) && {_touchDownCount > 0}) then { //-- Regular Airport Landing: Reset _touchdownCount if landing failed
		if ((getPosATL _vehicle) select 2 > 10) then {
			_touchDownCount = 0;
			_landingTime = -1;
		};
	};

	if (_exit && {_touchDownCount >= 3}) exitWith {};

	if (_dynamicLanding) then {
		if (speed _vehicle < 10) then {
			if (surfaceIsWater _inputPosition) then {
				private _carrierObjects = _vehicle nearObjects ["Land_Carrier_01_base_F", 200];

				if (count _carrierObjects > 0) then {
					private _carrier = _carrierObjects select 0;
					private _storageData = [_vehicle,_carrier] call A3C_ai_shared_fnc_planeFindCarrierStorage;

					[_vehicle,0] remoteExec ["setFuel",_vehicle];
					[_vehicle,[0,0,0]] remoteExec ["setVelocity",_vehicle];

					if (count _storageData > 0) then {
						[_vehicle,(_storageData select 0)] remoteExec ["setPosASL",_vehicle];
						[_vehicle,(_storageData select 1)] remoteExec ["setDir",_vehicle];
					};

					_exit = true;
				};
			};
		};
	};

	if (_exit) exitWith {};

	sleep _sleep;
};

if (_dynamicLanding) then {
	[_vehicle,true] remoteExec ["allowDamage",_vehicle];

	{
		private _handle = _x getVariable ["A3C_DAMAGE_HANDLE",-2];

		if (_handle != -2) then {
			[_x,["HandleDamage",_handle]] remoteExec ["removeEventHandler",_x];
		};
	} forEach [_vehicle,_unit];

	sleep 1;

	waitUntil {speed _vehicle == 0};
};


if (isNull _vehicle) exitWith {};

//-- security against this weird glitch where unit gets out of vehicle
private _scr = [_unit,_vehicle] spawn {
	params ["_unit","_vehicle"];

	waitUntil {
		sleep 1;
		isTouchingGround _vehicle
	};

	sleep 1;

	_unit moveInDriver _vehicle;
};

if !(_dynamicLanding) then {
	private _mode = "TENT";
	private _hangars = [];

	_vehicle setFuel 0;
	[_vehicle,["Door_1_source",1]] remoteExec ["animateDoor",_vehicle];

	private _hangar = objNull;

	if (_carrierLanding) exitWith {};

	private _dir = 0;
	private _pos = [];
	private _runwayLanding = (getNumber (_cfgVehicles >> _vehicleType >> "landingSpeed")) > 10;
	private _waypointTimeout = waypointTimeout [_group, currentWaypoint _group];

	if ((alive _vehicle) && {_runwayLanding}) then {
		//-- park vehicle, disband pilot to the reserve
		[[_unit],true,false] spawn A3C_ai_shared_fnc_cancelUnitPlot;	//-- end units current plans just in case the player was being insane :)

		_hangars = nearestObjects [_vehicle, ["Land_TentHangar_V1_F"], 1500];

		if (count _hangars == 0) then {
			_hangars = nearestObjects [_vehicle, A3C_HangarTypes, 1500];
		};

		private _exit = false;

		{
			_dir = getDir _x;

			if !(typeOf _x == "Land_TentHangar_V1_F") then {
				_dir = _dir + 180;
			};

			_pos = position _x;

			private _nearestObjects = nearestObjects [
				_pos,
				["Stall_base_F","VASI","Motorcycle","WheeledAPC","WheeledAPC","Wreck","UnknownObject","Ammobox","Thing","air","Car","Tank"],
				12
			];

			if ((sizeOf _vehicleType) < (sizeOf (typeOf _x))) then {
				if (count _nearestObjects == 0) then {
					_hangar = _x;
					_exit = true;
				};

				if (isNull _hangar) then {
					_pos = [(position _x),((sizeOf typeOf _x) * 0.7),_dir] call BIS_fnc_RelPos;

					_nearestObjects = nearestObjects [
						_pos,
						["Stall_base_F","VASI","Motorcycle","WheeledAPC","WheeledAPC","Wreck","UnknownObject","Ammobox","Thing","air","Car","Tank"],
						12
					];

					if !(count (_pos isFlatEmpty [10,-1,-1,20,0,false,_x]) == 0) exitWith {
						if (count _nearestObjects == 0) then {
							if ({_pos inArea _x} count _prohibitedAreas == 0) then {
								_hangar = _x;
								_exit = true;
							};
						};
					};
				};
			};

			if (_exit) exitWith {};
		} forEach _hangars;

		if !(isNull _hangar) then {
			[_vehicle,_dir] remoteExec ["setDir",_vehicle];
			[_vehicle,_pos] remoteExec ["setPos",_vehicle];
		} else {
			//-- we have NOT found a suitable position yet. Bummer. We have to go hardcore.
			_exit = false;

			for "_i" from 1 to 20000 do {
				private _testPos = [0,0,0];

				for "_t" from 1 to 1000 do {
					private _testPos1 = _mainAirFieldAreaConverted call BIS_fnc_randomPosTrigger;

					if ({_testPos1 inArea _x} count _prohibitedAreas == 0) exitWith {
						_testPos = _testPos1;
					};
				};

				if !(_testPos isEqualTo [0,0,0]) then {
					if !(count (_testPos isFlatEmpty [(sizeOf _vehicleType) / 1.5,-1,-1,1,0,false,objNull]) == 0) then {
						_nearestObjects = nearestObjects [
							_testPos,
							["Stall_base_F","VASI","Motorcycle","WheeledAPC","WheeledAPC","Wreck","UnknownObject","Ammobox","Thing","air","Car","Tank"],
							(sizeOf _vehicleType) / 1.5
						];

						if (count _nearestObjects == 0) then {
							_pos = _testPos;
							_exit = true;
						};
					};
				};

				if (_exit) exitWith {
					[_vehicle,_airportIlsDir] remoteExec ["setDir",_vehicle];
					[_vehicle,_pos] remoteExec ["setPos",_vehicle];
				};
			};
		};
	};

	[_vehicle,0] remoteExec ["setFuel",_vehicle];
};


_unit setVariable ["A3C_VAR_LANDING",false,true];

//-- spawn Maintenance Loop in parallel
[_vehicle] spawn {
	params ["_vehicle"];

	private _counter = 1;
	private _reArm = true;

	while {_counter < 60} do {
		sleep 1;

		if ((fuel _vehicle > 0.1) && {isEngineOn _vehicle}) exitWith {
			_reArm = false;
		};

		_counter = _counter + 1;

		[_vehicle,(damage _vehicle - 0.017)] remoteExec ["setDamage",_vehicle];
	};

	if (_reArm) then {
		[_vehicle,1] remoteExec ["setVehicleAmmo",_vehicle];
	};
};

if (_unit == leader _group) then {
	private _currentWaypoint = currentWaypoint _group;
	private _waypointTimeout = waypointTimeout [_group, _currentWaypoint];

	private _conditions = (waypointStatements [_group,_currentWaypoint]) select 0;

	_conditions = if (isNil "_conditions") then {"true"} else {_conditions};

	if (["TIMEOUT",_conditions] call BIS_fnc_inString) then {
		_conditions = format ["time > %1",time + (_waypointTimeout select 0)];
	};

	_conditions = if (isNil "_conditions") then {"true"} else {_conditions};

	//-- wait until group units have landed
	while { {canMove (vehicle _x) && {_x getVariable ["A3C_VAR_LANDING",false]}} count units _unit > 0 } do {
		sleep 1;
	};

	//-- wait for continue conditions
	if (_conditions != "false") then {
		while {!(call compile _conditions)} do {
			sleep 0.2;
		};
	};

	sleep (random 1);

	private _keepGoing = false;

	if ({_x select 1 > (currentWaypoint _group)} count (waypoints _group) > 1) then {
		_keepGoing = true;
	};

	if ((currentWaypoint _group) == _currentWaypoint) then {
	};

	if (_keepGoing) then {
		[_unit] spawn A3C_ai_shared_fnc_planeOrganizeGroupTakeOff;
	};
};
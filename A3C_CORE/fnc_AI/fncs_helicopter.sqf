



A3C_getVehicleBodyDimensions = {
	params ["_vehicleType"];

	_isInDatabase = false;
	_measures = [];


	_dataBase = profileNameSpace getVariable ["A3C_VehicleBodyDimensions",[]];
	{
		if (_x select 0 == _vehicleType) then {
			_measures = _x select 1;
		};
	} foreach _dataBase;
	if (count _measures > 0) exitWith {_measures}; //-- measures in database >> no need to do the costly checks


	//-- create static measurement model
	_refVehicle = _vehicleType createVehicleLocal [100,100,1000];
	_refVehicle enablesimulation false;
	_refVehicle setPosASL (ATLtoASL [100,100,1000]);

	_vehicleHeight = _refVehicle call BIS_fnc_objectHeight;

	_refBbox = [_refVehicle,0] call MCSS_fnc_BBOX;
	{
		_x set [2,1000];
	} foreach _refBbox;

	_testPosRoot = ATLtoASL (_refBbox select 0);
	_testPosZ = _testPosRoot select 2;

	_reference_L1 = ((_refBbox select 1) distance2D (_refBbox select 2)); //   WIDTH    7;
	_reference_L2 = ((_refBbox select 0) distance2D (_refBbox select 1)); //   LENGHT   3;


	_rotorWidth = if (_refVehicle isKindOf "HELICOPTER") then {_reference_L2} else {0};


	//systemchat str [_reference_L2,_reference_L1];

	//width and length might be swapped?


	_maxWidth = 0;
	_length = 0;

	_bodyStartY = [0,0,0];
	_isBodyY = false;

	//-- take body measures

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

	deletevehicle _refVehicle;
	_measures = [_maxWidth - 1,_length - 1,_vehicleHeight,_rotorWidth];
	_dataBase pushBack [_vehicleType,_measures];
	profileNameSpace setVariable ["A3C_VehicleBodyDimensions",_dataBase];
	_measures
	//width and length might be swapped?
};


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
		//systemchat str _subMatrixEntryCount;
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
			//diag_log _histoClean;

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




A3C_JET_TAKEOFF = { //~~ remotexec within fnc here!
	private _unit = _this select 0;
	if (isPlayer _unit) exitWith {};
	_vehicle = vehicle _unit;
	if !(_vehicle isKindOf "PLANE") exitWith {};
	//if (isengineOn _vehicle) exitWith {}; //-- issue with vehicles that are already airborne
	if !(isTouchingGround _vehicle) exitWith {};

	[_vehicle,1] remoteExec ["setVehicleAmmo", _vehicle];

	private _airportData = [getPosATL _vehicle] call MCSS_fnc_getNearestAirportData;
	_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];
	//_taxiInPoses spawn {
	//	{
	//		player setpos _x;
	//		sleep 2;
	//	} foreach _this;
	//};
	//player setpos _airportTaxiIn;
	//systemchat str [_airportID,_airportTaxiOff];
	_planeDir = if (count _taxiInPoses > 1) then {(_taxiInPoses select 0) getDir _airportTaxiIn} else {0};
	_unit setvariable ["A3C_TAKING_OFF",true,true];

	//-- weird workaround to see if the vehicle can move
	private _canMove = false;
	while {alive _vehicle && !isNull driver _vehicle} do {
		[_vehicle,1] remoteExec ["setFuel",_vehicle];
		sleep 0.2;
		if (canMove _vehicle) then {
			_canMove = true;;
		};
		[_vehicle,0] remoteExec ["setFuel",_vehicle];
		if (_canMove) exitWith {};
		sleep 3;
	};

	if !(_canMove) exitWith {};
	//'yay' remoteExec ["systemChat",0];

	if (_airportID >= 0) then {
		//-- Airfield TakeOff

		for "_i" from 1 to 5 do { //-- why the loop you aks? - Because some weird thing kept teleporting the planes back to their parking position
			[_vehicle,_planeDir] remoteExec ["setDir",_vehicle];
			[_vehicle,_airportTaxiOff] remoteExec ["setPos",_vehicle];
			sleep 0.05;
		};
		[_vehicle,1] remoteExec ["setFuel",_vehicle];
		sleep 0.5; // -- security for refuel
		if (_unit != leader (group _unit)) then {

			//while {isTouchingGround _vehicle} do {
			while {((getPosATL _vehicle) select 2) < 10} do {
				//(str (((getPosATL _vehicle) select 2))) remoteExec ["systemchat",0];
				private _movePos = waypointPosition [group _unit, currentWaypoint (group _unit)];

				[_unit,_movePos] remoteExec ["doMove",_unit];
				if (!alive _vehicle) exitWith {deletevehicle _vehicle}; //~~ CHANGE THIS TO MOVE THE WRECK TO AN EMPTY POSITION
				if (!alive _unit) exitWith {}; //-- ~~ADD VEHICLE PARKING HERE!! ILSPOSITIONS NEED TO BE CLEAR!
				if (!canMove _vehicle) exitWith {}; //-- ~~ADD VEHICLE PARKING HERE!! ILSPOSITIONS NEED TO BE CLEAR!
				sleep 2;
				//"loop" remoteExec ["systemchat",0];
			};
			//"loop exit" remoteExec ["systemchat",0];
			[_unit, leader (group _unit)] remoteExec ["commandFollow",_unit];
		};


	} else { //-- _airportID < 0 == dynamic airfield
		//-- CARRIER TAKEOFF
		//if (surfaceIsWater _airportTaxiPos) exitWith {
			[_vehicle,A3C_CatapultLaunch] remoteExec ["bis_fnc_spawn", _vehicle];
		//};
	};

	//{
	//	[(vehicle _unit),[_x,0]] remoteExec ["animateDoor",(vehicle _unit)];
	//} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
};

A3C_JET_DYNAMICELANDING_HANDLEDAMAGE = {
	params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];


	if (_projectile != "") exitWith {
		_explosive = getNumber (configfile >> "CfgAmmo" >> _projectile >> "explosive");
		//systemchat str [_projectile,_explosive];
		_unit setDamage (damage _unit + _explosive);
	};

	if ( !(side _source in [civilian,sideUnknown,sideFriendly,sideEmpty]) && { (side _source) getFriend (side _unit) <= 0.6  }) exitWith {
		_unit setDamage (damage _unit + _damage);


	};
	0
};

A3C_LANDPLANE2 = { //-- not used
	params ['_vehicle'];
	_dynamicArports = (allAirports select 1);
	_exit = false;
	//systemchat "2";
	//if (count _dynamicArports > 0) then {
		{
			if ((_vehicle distance2d (position _x)) < 200) exitWith {
				//_vehicle landAt _x;
				[_vehicle,_x] remoteExec ["landAt",_vehicle];
				_ecit = true;
			};
		} foreach _dynamicArports;
	//};
	if (_exit) exitWith {
		//systemchat "exit";
	};

	_vehicle land 'LAND';
};

A3C_LANDPLANE = {
	params ["_unit","_inputPosition"];
	private ["_dir","_pos","_vehicle","_exit"];

	if (isPlayer _unit) exitWith {};
	private _vehicle = vehicle _unit;
	_vehicle setUnloadInCombat [false,false];
	private _dynamicArports = (allAirports select 1);
	private _dynamicLanding = false;
	private _moving = false;
	private _currentWaypoint = currentWaypoint (group _unit);

	_unit setVariable ["A3C_VAR_LANDING",true,true];
	//player commandchat str _vehicle;

	private _airportData = [_inputPosition] call MCSS_fnc_getNearestAirportData;
	_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];
	private _airportAreas = _airportData call MCSS_fnc_getAirFieldRunwayAreas;
	_airportAreas params ["_mainAirfieldArea","_prohibitedAreas"];
	_mainAirfieldArea params ["_areaCenter","_areaSizeX","_areaSizeY","_areaDir","_areaIsRectangle"];
	private _mainAirFieldAreaConverted = [_areaCenter,[_areaSizeX,_areaSizeY,_areaDir,_areaIsRectangle]];


	if (typeName _airportName == "OBJECT") then {
		_tailHook = (getNumber (configfile >> "CfgVehicles" >> typeOf _vehicle >> "tailHook")) > 0;
		_airportID = _airportName;
		if (_tailHook) then {
			//systemchat 'tailhook yes';
			_dynamicLanding = true;
		} else {
			_moving = true;
			[_vehicle,"LAND"] remoteExec ["land",_vehicle];
		};
	};
	if !(_moving) then {
		//systemchat str _airportID;
		[_vehicle,_airportID] remoteExec ["landAt",_vehicle];
	};

	_exit = false;
	//_slowDown = true;
	_carrierLanding = false;

	private _delete = false;

	_vehicleHandle = -2;
	_unitHandle = -2;
	if (_dynamicLanding) then {
		_vehicle allowDamage false;
		[_vehicle,false] remoteExec ["allowDamage",_vehicle];
		private _addEHFunc = {
			params ["_object","_func"];
			if !(local _object) exitWith {};
			if (isNil '_func') exitWith {};
			private _handle = _object addEventHandler
			[
				"HandleDamage",
				compile format
				[
					"_this spawn %1",
					_func
				]
			];
			_object setvariable ["A3C_DAMAGE_HANDLE",_handle,true];
		};
		{
			[_x,A3C_JET_DYNAMICELANDING_HANDLEDAMAGE] call _addEHFunc;
		} foreach [_unit,_vehicle];
		//_vehicleHandle = _vehicle addEventhandler ["HandleDamage",{_this call A3C_JET_DYNAMICELANDING_HANDLEDAMAGE}];
		//_unitHandle = _unit addEventhandler ["HandleDamage",{_this call A3C_JET_DYNAMICELANDING_HANDLEDAMAGE}];
	};


	//-- alive exit
	if (_vehicle getvariable ["alive_combatsupport",false]) exitWith {
		systemchat "A3C: You are using A3C's controls on ALIVE support planes. Plane will take off again. Use ALIVE-RTB to land thins plane";
	};


	private _landingTime = -1;
	private _touchDownCount = if (_dynamicLanding) then {3} else {0};
	private _sleep = if (_dynamicLanding) then {0.5} else {1};
	while {alive _unit} do {
		if (!canMove _vehicle) exitWith {};
		if (isTouchingGround _vehicle) then { //((getposATL _vehicle) select 2) < 10
			_touchDownCount = _touchDownCount + 1;
			if (_landingTime == -1) then {
				_landingTime = time;
				//systemchat format ["landingtime: %1",time];
			};
			//if (_slowDown) then {
				//_slowDown = false;
				//_vehicle allowdamage false;
				if (surfaceIsWater _inputPosition) then {
					_carrierObjects = _vehicle nearObjects ["Land_Carrier_01_base_F", 200];
					if (count _carrierObjects > 0) then {
						_exit = true;
						_carrier = _carrierObjects select 0;
						//-- only works if plane has configs!
						[_vehicle,true] spawn bis_fnc_aircraftTailhookAI;
						[_vehicle,0] remoteExec ["setFuel",_vehicle];
						sleep 5;
						//systemchat str (alive _unit && _vehicle == vehicle _unit);
						if (alive _vehicle && {_vehicle == vehicle _unit}) then {
							_carrierLanding = true;
							_storageData = [_vehicle,_carrier] call A3C_FindCarrierPlaneStorage;
							if (count _storageData > 0) then {
								[_vehicle,(_storageData select 0)] remoteExec ["setPosASL",_vehicle];
								[_vehicle,(_storageData select 1)] remoteExec ["setDir",_vehicle];
								[_vehicle,0] remoteExec ["setFuel",_vehicle];
								[_vehicle,[0,0,0]] remoteExec ["setVelocity",_vehicle];
							};
						};

					};

				};
			//};
			if (speed _vehicle < 40) then {
				_exit = true;
			};
			if (_landingTime != -1) then {
				if (time > _landingTime + 10) then {
					//systemchat "exit landingtime";
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
		if (_exit && _touchDownCount >= 3) exitWith {};
		if (_dynamicLanding) then {
			if (speed _vehicle < 10) then {
				if (surfaceIsWater _inputPosition) then { //_dynamicLanding??
					_carrierObjects = _vehicle nearObjects ["Land_Carrier_01_base_F", 200];
					if (count _carrierObjects > 0) then {
						_carrier = _carrierObjects select 0;
						//systemchat "messup";
						_storageData = [_vehicle,_carrier] call A3C_FindCarrierPlaneStorage;
						//systemchat str _data;
						[_vehicle,0] remoteExec ["setFuel",_vehicle];
						[_vehicle,[0,0,0]] remoteExec ["setVelocity",_vehicle];
						//sleep 0.5;
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
			_handle = _x getVariable ["A3C_DAMAGE_HANDLE",-2];
			if (_handle != -2) then {
				[_x,['HandleDamage',_handle]] remoteExec ["removeEventHandler",_x];
			};
		} foreach [_vehicle,_unit];
		sleep 1;
		waitUntil {speed _vehicle == 0};
	};

	//if (_unit ==  (leader group _unit)) then {
	//	systemchat '1';
	//};


	//if ({alive _x} count [_vehicle,_unit] == 0) then {

	if (!alive _vehicle) then {

//		_refPos1 = getPosASL _vehicle;
//		_refPos2 = +(_refPos1);
//		_refPos2 set [2, (_refPos1 select 2) + 100];
//		_refPos1 set [2,0];
//		private _interSects = lineintersectsSurfaces [_refPos2, _refPos1, _unit, _vehicle, true, 1, "GEOM", "FIRE"];
//		//systemchat str _intersects;
//		if (count _interSects > 0) then {
//			//if ({_x select 2 in (allAirports select 1)} count _intersects > 0) then {
//			if ({_x select 2 isKindOf 'STATIC'} count _intersects > 0) then {
				sleep 5;
				{deletevehicle _x} foreach [_unit,_vehicle]
//			};
//		};


		//if (isTouchingGround _vehicle) then {
		//	{deletevehicle _x} foreach [_unit,_vehicle];
		//};
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
	//if (_unit ==  (leader group _unit)) then {
	//	systemchat '2';
	//};
	//if (_delete) then {
	//	{deletevehicle _x} foreach [_unit,_vehicle];
	//};
	//player commandchat  str (alive _unit);

	if !(_dynamicLanding) then {
		_mode = "TENT";
		_hangars = [];
		_vehicle setfuel 0;
		[_vehicle,["Door_1_source",1]] remoteExec ["animateDoor",_vehicle];
		_hangar = objnull;
		if (_carrierLanding) exitWith {};
		_dir = 0;
		_pos = [];
		_runwayLanding = ((getNumber (configfile >> "CfgVehicles" >> typeOf _vehicle >> "landingSpeed")) > 10);
		private _waypointTimeout = waypointTimeout [group _unit, currentWaypoint group _unit];
		if ((alive _vehicle) && _runwayLanding) then {
			//-- park vehicle, disband pilot to the reserve
			[[_unit],true,false] spawn A3C_AI_Shared_cancelUnitPlot;	//-- end units current plans just in case the player was being insane :)
			_hangars = nearestObjects [_vehicle, ["Land_TentHangar_V1_F"], 1500];
			if (count _hangars == 0) then {
				_hangars = nearestObjects [_vehicle, A3C_HangarTypes, 1500];
			};
			private _exit = false;
			{
				_dir = getdir _x;
				if !(typeof _x == "Land_TentHangar_V1_F") then {_dir = _dir + 180};
				_pos = (position _x);
				private _nearestObjects = (nearestObjects [_pos, ["Stall_base_F","VASI","Motorcycle","WheeledAPC","WheeledAPC","Wreck","UnknownObject","Ammobox","Thing","air","Car","Tank"], 12]);
				if ((sizeOf (typeOf _vehicle)) < (sizeOf (typeOf _x)) ) then {
					//if !( count (_pos isFlatEmpty [5,-1,-1,-1,0,false,_x]) == 0 ) exitWith { //[10, -1, -1, -1, -1, false, _x]
					if (count _nearestObjects == 0) then {
						_hangar = _x;
						_exit = true;
						//systemchat '1';
					};
					if (isNull _hangar) then {
						_pos = ([(position _x),((sizeOf typeOf _x) * 0.7),_dir] call BIS_fnc_RelPos);
						_nearestObjects = (nearestObjects [_pos, ["Stall_base_F","VASI","Motorcycle","WheeledAPC","WheeledAPC","Wreck","UnknownObject","Ammobox","Thing","air","Car","Tank"], 12]);
						if !( count (_pos isFlatEmpty [10,-1,-1,20,0,false,_x]) == 0 ) exitWith { //[10, -1, -1, -1, -1, false, _x]
							if (count _nearestObjects == 0) then {
								if ({_pos inArea _x} count _prohibitedAreas == 0) then {
									// aaa here
									_hangar = _x;
									//systemchat '2';
									_exit = true;
								};
							};
						};
					};
				};
				if (_exit) exitWith {};

			} foreach _hangars;
			if !(isNull _hangar) then {
				//systemchat str time;
				[_vehicle,_dir] remoteExec ["setDir",_vehicle];
				[_vehicle,_pos] remoteExec ["setPos",_vehicle];
			} else {
				//-- we have NOT found a suitable position yet. Bummer. We have to go hardcore.
				_exit = false;

				for "_i" from 1 to 20000 do {
					private _testPos = [0,0,0];
					for "_t" from 1 to 1000 do {
						private _testPos1 = (_mainAirFieldAreaConverted call BIS_fnc_randomPosTrigger);
						if ({_testPos1 inArea _x} count _prohibitedAreas == 0) exitWith {
							_testPos = _testPos1;
						};
					};
					if !(_testPos isEqualTo [0,0,0]) then {
						if !( count (_testPos isFlatEmpty [(sizeOf (typeOf _vehicle)) / 1.5,-1,-1,1,0,false,objNull]) == 0 ) then { //[10, -1, -1, -1, -1, false, _x]
							_nearestObjects = (nearestObjects [_testPos, ["Stall_base_F","VASI","Motorcycle","WheeledAPC","WheeledAPC","Wreck","UnknownObject","Ammobox","Thing","air","Car","Tank"], (sizeOf (typeOf _vehicle)) / 1.5]);
							if (count _nearestObjects == 0) then {
								_pos = _testPos;
								_exit = true;
							};
						};
					};
					if (_exit) exitWith {
						[_vehicle,_airportIlsDir] remoteExec ["setDir",_vehicle];
						[_vehicle,_pos] remoteExec ["setPos",_vehicle];
						//systemchat format ["%1: SUCCESS",_vehicle];
					};
				};
				//systemchat format ["%1: SUCCESS",_vehicle];

			};
		};
		[_vehicle,0] remoteExec ["setFuel",_vehicle];
	};


	//systemchat "landed";
	_unit setVariable ["A3C_VAR_LANDING",false,true];

	//-- spawn Maintenance Loop in parallel
	[_vehicle] spawn {
		params ["_vehicle"];
		private _counter = 1;
		private _reArm = true;
		while {_counter < 60} do {
			sleep 1;
			if ((fuel _vehicle > 0.1) && (isEngineOn _vehicle)) exitWith {_reArm = false};
			_counter = _counter + 1;
			//_vehicle setdamage (damage _vehicle - 0.017);
			[_vehicle,(damage _vehicle - 0.017)] remoteExec ["setdamage",_vehicle];
		};
		if (_reArm) then {
			//_vehicle setVehicleAmmo 1;
			[_vehicle,1] remoteExec ["setVehicleAmmo",_vehicle];
		};
	};

	//if (true) exitWith {};

	if (_unit ==  (leader group _unit)) then {

		private _currentWaypoint = currentWaypoint (group _unit);
		
		//[group _unit,_currentWaypoint,"POSITION",position _vehicle] call A3C_ai_highCommand_fnc_changeWaypointData;
		
		_conditions = (waypointStatements [group _unit,_currentWaypoint]) select 0;

		_conditions = if (isNil '_conditions') then {"true"} else {_conditions};
		if (["TIMEOUT",_conditions] call BIS_fnc_inString) then {
			_conditions = format ["time > %1",time + (_waypointTimeout select 0)];
		};

		_conditions = if (isNil '_conditions') then {"true"} else {_conditions};
		//systemchat str _conditions;
		//-- wait until group units have landed
		while { {canMove (vehicle _x) && _x getVariable ["A3C_VAR_LANDING",false]} count units _unit > 0     } do {
			sleep 1;
			//systemchat 'wait';
		};
		//systemchat "all units have landed";

		//-- wait for continue conditions
		if (_conditions != "false") then {
			while {!(call compile _conditions)} do {
				sleep 0.2;
			};
		};

		//systemchat "conditions fulfilled";
		sleep (random 1);
		_keepGoing = false;

		//systemchat '2';


		//if (count (waypoints (group _unit)) > 1) then {
		if ({_x select 1 > (currentWaypoint group _unit)} count (waypoints group _unit) > 1) then {
			_keepGoing = true;
		};
		//systemchat str [currentWaypoint group _unit , _currentWaypoint];
		if ((currentWaypoint group _unit) == _currentWaypoint) then {
		//if (_conditions != "true") then {
		//	deletewaypoint [group _unit,_currentWaypoint]; //-- really delete?
			//[group _unit,_currentWaypoint] setWaypointType "MOVE";
			//[group _unit,_currentWaypoint] setWaypointPosition [(getPos vehicle _unit),0];
			//[group _unit,_currentWaypoint] setWaypointStatements ["false",""];
		};

		if (_keepGoing) then {
			//systemchat "keep going";
			[_unit] spawn A3C_JET_organizeGroupTakeOff;
		};
	};
};

A3C_JET_organizeGroupTakeOff = {
	params ["_leader"];

	private _airportData = [getPosATL (vehicle _leader)] call MCSS_fnc_getNearestAirportData;
	_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];
	private _limit = if (_airportID > -1) then {1} else {2};
	//systemchat format ["limit %1, %2",_limit,_airportID];
	//systemchat str _airportTaxiOff;
	{
		_u = _x;
		_v = vehicle _x;
		_execute = true;
		if (_v isKindOf "PLANE" && {_u == driver _v}) then {
			if (isTouchingGround _v) then { //-- only schedule takeoff for non airborne plane
				if ((getNumber (configfile >> "CfgVehicles" >> typeOf _v >> "landingSpeed")) > 10) then { //-- prevent runway takeoff for VTOLS
					{_v animateDoor [_x, 0]} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
					while {alive _v} do {
						sleep 1 + (random 1);
						if ({alive _x && (_x getvariable ["A3C_TAKING_OFF",false])} count units _u <= _limit) exitWith {};
						sleep 1 + (random 1);
						if (_v != vehicle _u) exitWith {_execute = false;};
						if (!alive _v) exitWith {_execute = false;};
					};
					//systemchat "go";
					if (_execute) then {
						[_u] spawn A3C_JET_TAKEOFF;
						//sleep 1;/////////////////
						//systemchat str (_v distance2D _airportTaxiOff);/////////////////
						waitUntil {speed _v > 15 && {_v distance2D _airportTaxiOff > ((sizeOf (typeOf _v))* 2) }};
						sleep 5;
						_u setvariable ["A3C_TAKING_OFF",false,true];
					};
				} else {
					[_v,1] remoteExec ["setFuel",_v];
				};
			};
		};
	} foreach units _leader;
};


A3C_AI_Fnc_Command_Helicopter_evasiveMove = {
	params ["_vehicle"];
	private ["_vel","_dir","_speed","_deg","_newVel"];
	_vel = velocity _vehicle;
	_deg = [90,-90] call BIS_fnc_selectRandom;
	_dir = (direction _vehicle) + _deg;
	_speed = 10; //comment "Added speed";
	_newVel =
	[
		(_vel select 0) + (sin _dir * _speed),
		(_vel select 1) + (cos _dir * _speed),
		(_vel select 2)
	];
	[_vehicle,_newVel] remoteExec ["setVelocity",_vehicle];
};


A3C_FindCarrierPlaneStorage = {
	params ["_plane","_carrier"];
	private ["_box","_size"];
	//if !(["Land_Carrier_01",(typeOf _carrier)] call BIS_fnc_instring) exitWith {[]};
	_box = ([_plane,0] call MCSS_fnc_BBOX);
	_size = (_box select 0) distance2D (_box select 1);
	//systemchat str _size;
	_pos = [];
	{
		_tePos = ATLtoASL (_carrier modelToWorld (_x select 0));
		_refPos1 = [_tePos select 0, _tePos select 1, -200];
		_refPos2 = [_tePos select 0, _tePos select 1, 200];
		_interSects = lineintersectsSurfaces [_refPos2,_refPos1,objNull,objnull];
		_tPos = [];
		if (count _interSects > 0) then {
			{
				//systemchat str (typeOf (_x select 2)); //((_x select 2) distance2d _carrier);
				//systemchat str ( (_x select 3) == _carrier);
				//systemchat str (vehicleVarname (_x select 2));
				if (["Land_Carrier_01",typeOf (_x select 2)] call BIS_fnc_instring) exitWith {
					_tPos = (_x select 0);

				};
			} foreach _interSects;
			//systemchat str ((_interSects select 0) );

			//if ( ((_interSects select 0) select 3) == _carrier) then {
				//player commandChat "yo";
				//systemchat str (_interSects select 0); //((_interSects select 0) select 0);
			//};
		} else {
			//systemchat "no intersect";
		};
		//_tPos set [2,24];
		//systemchat str _tPos;
		//_tPos = ASLtoATL _tPos;


		//~~ flatEmptyCheck did not work for some reason
		//if !( count ((ASLtoAGL _tpos) isFlatEmpty [_size,1,-1,-1,-1,false,_carrier]) == 0 ) exitWith {
		_nearObjects = if (count _tPos > 0) then {_tPos nearObjects _size} else {[]}; //_size

		{
			_ob = _x;
			if ({_ob isKindOf _x} count ["CAR","TANK","HELICOPTER","JET","PLANE","staticWeapon","ReammoBox","ReammoBox_F"] == 0) then {
				_nearObjects = _nearObjects - [_x];
			};
		} foreach _nearObjects;
		if (count _nearObjects > 0) then {
			//_tarray = [];
			//{
			//	_tarray pushBack _x;
			//} foreach _nearObjects;
			//systemchat str _tarray ;
		};
		if (count _nearObjects == 0 && !(_tpos isEqualTo [])) exitWith {
			_tPos set [2,(_tPos select 2) + 1];
			_pos = [_tPos,[(getDir _carrier) + (_x select 1)] call MCSS_fnc_CorrectDir];
			//systemchat "2";
		};
	} foreach A3C_CarrierArray;
	_pos
};


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
		[_unit,position _vehicle] spawn A3C_LANDPLANE;
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
		[_unit,position _vehicle] spawn A3C_LANDPLANE;
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



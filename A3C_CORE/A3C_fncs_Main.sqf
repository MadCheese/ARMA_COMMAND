
#include "ui\radial\radialMenu\script_component.hpp"
#include "ui\radial\radialMenu\dialog_defines.hpp"
#include "ui\SHARED\shared_ui_defines.hpp"




//---------------------------------------------------------------------------------------------
//---------- GETTERS --------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------

A3C_fnc_getNearDetonationTargets = {
	params ["_unit","_position","_distance","_mustKnowAbout"];
	_nearObjects = nearestObjects [_position, ["CAR","TANK","HELICOPTER","JET","PLANE","SHIP","staticWeapon","ReammoBox","ReammoBox_F"],_distance];
	{
		if ( isClass (configFile >> "CFGVehicles" >> typeOf _x)) then {
			if (speed _x > 1) then {_nearobjects = _nearobjects - [_x]};
			if (_mustKnowAbout && (_unit knowsabout _x) < 0.1 ) then {_nearobjects = _nearobjects - [_x]};
		};
	} foreach _nearobjects;
	_nearobjects
};

A3C_fnc_getRemoteDetonatorUnits = {
	params ["_units"];
	{
		private _unit = _x;
		private _mags = magazines _unit;
		if ({getText (configfile >> "CfgMagazines" >> _x >> "nameSound") in ["satchelcharge","mine"]} count _mags == 0) then {
			_units = _units - [_x];
		};
	} foreach _units;
	_units
};

A3C_fnc_getRemoteDetonatableUnitMagazines = {
	params ["_unit"];

	private _result = [];

	{
		private _magCfg = configFile >> "CfgMagazines" >> _x;

		if (getText (_magCfg >> "nameSound") in ["satchelcharge", "mine"]) then {
			private _ammoCfg = configFile >> "CfgAmmo" >> getText (_magCfg >> "ammo");

			if (getText (_ammoCfg >> "mineTrigger") == "RemoteTrigger") then {
				_result pushBack _x;
			};
		};
	} forEach (magazines _unit arrayIntersect magazines _unit);

	_result
};

A3C_fnc_getCursortargetCustom = {
	private _vehicle = vehicle player;
	private _cursorTarget = cursorTarget;
	if (!isNull _cursorTarget && {player == driver _vehicle && {_cursorTarget != _vehicle}}) then {
		_startPos = AGLToASL positionCameraToWorld [0,0,0];
		_endPos = AGLToASL positionCameraToWorld [0,0,viewDistance];
		_endPos set [2,(_startPos select 2) max (_endPos select 2)]; //-- level refpos with player's view height
		private _ins = lineIntersectsSurfaces
		[
			_startPos,
			_endPos,
			vehicle cameraOn,
			cameraon,
			true,
			1,
			"GEOM",
			"NONE"
		];
		if (count _ins > 0) then {
			_cursorTarget = (_ins select 0 select 2);
		};

	};
	_cursorTarget
};



A3C_fnc_getBoardableVehicles = {
	private _playerSide = side player;

	private _allVics = (
		(allMissionObjects "CAR")
		+ (allMissionObjects "TANK")
		+ (allMissionObjects "AIR")
		+ (allMissionObjects "STATICWEAPON")
		+ (allMissionObjects "SHIP")
	);

	_allVics = _allVics select {
		side _x == civilian || {
			{
				alive _x && { (side _x) getFriend _playerSide < 0.6 }
			} count (crew _x) == 0
		}
	};

	private _return = _allVics apply {
		[_x, [25,25], getPos _x]
	};

	_return
};


//---------------------------------------------------------------------------------------------
//---------- Setters --------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------





//---------------------------------------------------------------------------------------------
//---------- Predicates ('is x') --------------------------------------------------------------
//---------------------------------------------------------------------------------------------


//---------- State predicates

A3C_fnc_isAttackHelicopter = {
	params ["_vehicle"];
	private _return = false;
	private _exit = false;
	if (_vehicle isKindOf "HELICOPTER") then {
		private _turrets = allTurrets [_vehicle, false];
		{
			private _weapons = _vehicle weaponsTurret _x;
			if (count _weapons > 1) exitWith {_return = true};
		} foreach _turrets;
	};
	_return		
};

A3C_fnc_isArmedVehicle = {
	params ["_vehicle"];
	private _turrets = allTurrets [_vehicle, true]; //-- FFV has to be true - since ffv turret has no weapons, it will still work?
	private _return = false;
	{
		private _weapons = _vehicle weaponsTurret _x;
		if (count _weapons > 0) exitWith {_return = true};
	} foreach _turrets;
	_return	
};

A3C_fnc_isVehicleDamaged = {
	params ["_callerSide","_entity"];
	
	private _mode = if (count _this > 1) then {_this select 1} else {"NONE"};
	private _return = false;
	if (side _entity in [_callerSide, civilian]) then {
		if ([_entity] call MCSS_fnc_isObjectFlipped) then {
			_return = true;
		} else {
			if (speed _entity < 1) then {
				_allHPD = getAllHitPointsDamage _entity;
				
				if !(_allHPD isEqualTo []) then {
					_allHitPointValues = _allHPD select 2;

					{
						if ({_x > 0.15} count _allHitPointValues > 0) exitWith {
							_return = true;
						};
					} foreach _allHitPointValues;
				};
				
			};
		};			
	};
	_return
};


A3C_fnc_isNVGoggles = {
	params ["_weaponclass"];

	private _return = false;

	if (getText (configfile >> "CfgWeapons" >> _weaponclass >> "_generalMacro") == "NVGoggles") then {
		_return = true;
	};

	_return
};

A3C_fnc_isIRMagazine = {
	params ["_mag"];
	private _ammo = getText (configfile >> "CfgMagazines" >> _mag >> "ammo");
	private _sim = getText (configfile >> "CfgAmmo" >> _ammo >> "simulation");
	_sim == "shotNVGMarker"
};

//---------- Posession predicates

A3C_fnc_hasWeaponItem = {
	params ["_unit","_itemType"];
	private _return = false;
	if (_itemType == "SILENCER") exitWith {
		_unit weaponAccessories currentMuzzle _unit param [0, ""] != ""
	};
	private _itemName = (_unit weaponAccessories (currentMuzzle _unit)) param [1, ""];
	switch (_itemType) do {
		case ("FLASHLIGHT") : {
			if (getNumber (configfile >> "CfgWeapons" >> _itemName >> "ItemInfo" >> "FlashLight" >> "intensity") != 0) then {
				_return = true;
			} else {
				_rhsText = toLower (getText (configfile >> "cfgWeapons" >> _itemName >> "rhs_acc_combo_text"));
				if ("light" in _rhsText) then {
					_return = true;
				} else {
					_smaText = toLower (getText (configfile >> "cfgWeapons" >> _itemName >> "MRT_switchItemHintText"));
					if ("laser" in _smaText) then {
						_return = true;
					};
				};
			};

		};
		case ("LASER") : {
			if (getNumber (configfile >> "CfgWeapons" >> _itemName >> "ItemInfo" >> "Pointer" >> "irDistance") != 0) then {
				_return = true;
			} else {
				private _rhsText = toLower (getText (configfile >> "cfgWeapons" >> _itemName >> "rhs_acc_combo_text"));
				if ("laser" in _rhsText) then {
					_return = true;
				} else {
					_smaText = toLower (getText (configfile >> "cfgWeapons" >> _itemName >> "MRT_switchItemHintText"));
					if ("light" in _smaText) then {
						_return = true;
					};
				};
			};
		};
	};
	_return
};

//---------- Ability predicates

A3C_fnc_canRepair = {
	params ["_unit"];
	private _return = false;
	if (isNull objectParent _unit && {vehicle _unit isKindOf "MAN"}) then {
		if ( {[_x] call TAG_fnc_baseWeapon == "ToolKit"}  count items _unit > 0) then {
			_return = true;
		};
	} else {
		private _veh = vehicle _unit;
		if (_unit == driver _veh OR {!(_unit isKindOf "MAN")}) then {
			if (getNumber (configFile >> "CfgVehicles" >> typeof _veh >> "transportRepair" ) > 1000) then {
				_return = true;
			};
		};
	};
	_return
};

//---------------------------------------------------------------------------------------------
//---------- Generators ----------------------------------------------------------------------
//---------------------------------------------------------------------------------------------



A3C_fnc_generateWpWedgePositions = {
	params ["_pos","_refArray1","_amount","_dir","_spacing"];
	private _poses = [_pos];
	private _currentSpacing = +(_spacing);
	private _doWedge = true;
	if (isOnRoad _pos) then {
		_doWedge = false;
		if (count _refArray1 > 0) then {
			_usedRoads = [];
			_refArray1 = [_refArray1,[],{(vehicle leader _x) distance _pos},"ASCEND"] call BIS_fnc_sortBy;
			_refGroup = _refArray1 select 0;

			private _currentSpacing = 30;

			private _isGroupOnFinalWP = currentWaypoint _refGroup >= count waypoints _refGroup;
			//systemchat str _isGroupOnFinalWP;
			private _refPosStart = if (_isGroupOnFinalWP) then {position (vehicle leader _refGroup)} else {waypointPosition [_refGroup,((waypoints _refGroup) select ((count waypoints _refGroup) - 1)) select 1]};
			_refDIr = _refPosStart getDIr _pos;
			_nearRoads = (_pos nearroads 20);
			if (count _nearRoads > 0) then {
				_startRoad = _nearRoads select 0;
				_poses = [position _startRoad];
				_usedRoads = [_startRoad];
				_currentRoad = _startRoad;
				//for "_i" from 1 to (count _refArray1 - 1) do {
				_counter = 0;
				while {count _poses < count _refArray1} do {
					_connectedRoads = (roadsConnectedTo _currentRoad) - _usedRoads;
					if (count _connectedRoads == 0) exitWith {
						_doWedge = true;
					};
					_connectedRoads = [_connectedRoads,[],{_x distance2d _refPosStart},"ASCEND"] call BIS_fnc_sortBy; //abs (_refDir - (_x getDir _currentRoad))
					

					_currentRoad = _connectedRoads select 0;
					_usedRoads set [count _usedRoads,_currentRoad];
					_roadPos = position _currentRoad;
					_currentGroup = _refArray1 select _counter;
					_currentSpacing = 30 max (sizeOf (typeOf (vehicle leader _currentGroup)));
					//hintsilent str [_currentRoad,(count _connectedRoads),count _poses,time];
					_cond = 
					(
						count _poses == 0 OR 
						{
							_lastPos = _poses select ((count _poses) -1);
							_roadPos distance2D _lastPos > _currentSpacing
						}
					);
					if (_cond) then {
						_poses pushBack _roadPos;
						_counter = count _poses;
					};
					
				};
				//hintsilent "";
			};
		};
	};
	if (_doWedge) then {
		_poses = [_pos];
		for "_i" from 0 to (_amount - 1) do {
			_stepAngle = if ((_i % 2) == 0) then {(_dir + 180) + 45} else {(_dir + 180) - 45};
			if (_i != 0 && {(_i % 2) == 0}) then {_currentSpacing = _currentSpacing + _spacing};
			//systemchat str _stepAngle;
			_poses pushBack ([_pos,_currentSpacing,_stepAngle] call BIS_fnc_relPos); //(_pos getPos [_i * _spacing,_stepAngle]);
		};
	};
	_poses
};



/////////////////////////////




A3C_fnc_toggle_WeaponAttachMent = {
	params ["_type","_mode"];



	//systemchat str _refGroups;


	_msgBody = "";
	_maxSleep = 0; //-- highest group sleep without individual unit sleep
	_totalSleep = 0; //-- highest group sleep including individual unit sleep
	_refGroups = [];
	switch (_type) do {
		case ("LASER") : {
			_refGroups = if (_mode == "ON") then {A3C_HC_IR_Laser_On_Units} else {A3C_HC_IR_Laser_Off_Units};
			_msgBody  = if (_mode == "ON") then {"Engage IR-LASER"} else {"Disengage IR-Laser"};
		};
		case ("FLASHLIGHT") : {
			_refGroups = if (_mode == "ON") then {A3C_HC_LightsOnUnits} else {A3C_HC_LightsOffUnits};
			_msgBody  = if (_mode == "ON") then {"Engage Flashlight"} else {"Disengage Flashlight"};

		};
	};
	_msgTarget = if (count _refGroups == 1) then {
		groupID  (_refGroups select 0)
	} else {
		"All Target Groups"
	};


	// player commandchat format
	// [
	// 	"%1: %2, %3",
	// 	name player,
	// 	_msgTarget,
	// 	_msgBody
	// ];


	{

		_gp = _x;
		_unitSleepArray = [];
		{
			_unitSleepArray pushBack (random 1);
		} foreach units _gp;
		_randomSleepGroup = random 7;
		if (_maxSleep < _randomSleepGroup) then {
			 _maxSleep = _randomSleepGroup;
			 _totalSleep = _randomSleepGroup;
			 {_totalSleep = _totalSleep + _x} foreach _unitSleepArray; //!!!!!!! NOT CORRECT. just needs to be + 1 sec??
		};


		if (!isPlayer (leader _gp) && {player != leader _gp}) then {

			[_gp,_type,_mode,_randomSleepGroup,_unitSleepArray] spawn {
				params ["_gp","_type","_mode","_randomSleepGroup","_unitSleepArray"];
				//player groupchat str _this;
				sleep _randomSleepGroup;
				{
					_unitSleep = _unitSleepArray select _foreachIndex;
					sleep _unitSleep;
					_u = _x;
					if (_mode == "ON") then {
						//{
							_u = _x;
							switch (_type) do {
								case ("LASER") : {[_u,true] remoteExec ["enableIRLasers",_u];};
								case ("FLASHLIGHT") : {[_u,"ForceOn"] remoteExec ["enablegunlights",_u];};
							};

							[_u,["Middle","UP"] call BIS_fnc_selectRandom] remoteExec ["setUnitPos",_u];
							[_u,"combat"] remoteExec ["setBehaviourStrong",_u];
						//} foreach units _gp;
					} else {
						_condition = switch (_type) do {
							case ("LASER") : {{(getNumber (configfile >> "CfgWeapons" >> _x >> "ItemInfo" >> "Pointer" >> "irDistance") != 0)} count (primaryWeaponItems _u) > 0};
							case ("FLASHLIGHT") : {true};
						};
						//if (_condition) then {
							switch (_type) do {
								case ("LASER") : {
									[_u,false] remoteExec ["enableIRLasers",_u];
								};
								case ("FLASHLIGHT") : {
									[_u,"ForceOff"] remoteExec ["enablegunlights",_u];
									//systemchat str (group _u);
								};
							};
							[_u,"AUTO"] remoteExec ["setUnitPos",_u];
							[_u,"aware"] remoteExec ["setBehaviourStrong",_u];
						//};
					};
				} foreach units _gp;
			};
		};
	} foreach _refGroups;

	switch (_type) do {
		case ("LASER") : {A3C_Prevent_attach_IR_Laser = true;};
		case ("FLASHLIGHT") : {A3C_Prevent_attach_Flashlight = true};
	};
	_refGroups = [];
	
	[false] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
	[_totalSleep,_type,_mode] spawn {
		params ["_totalSleep","_type","_mode"];
		sleep _totalSleep;
		switch (_type) do {
			case ("LASER") : {
				A3C_Prevent_attach_IR_Laser = false;
				//hintSilent format ["A3C: Toggle IR-Lasers %1 completed",_mode];
			};
			case ("FLASHLIGHT") : {
				A3C_Prevent_attach_Flashlight = false;
				//hintSilent format ["A3C: Toggle Flashlights %1 completed",_mode];
				//systemchat str _maxSleep;
			};
		};
		sleep 1;
		[false] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
	};
};



MCSS_fnc_getNearestAirportData = {
	params ["_inputPos"];
	private _airports = ["MAIN"];
	private _secAir = "true" configClasses (configfile >> "CfgWorlds" >> worldName >> "SecondaryAirports");
	private _secArray = [];
	private _startPos = +(_inputPos);
	private _touchDownPos = +(_inputPos);
	{
		_airports pushback (configName _x);
		//_poses pushback (getArray (configfile >> "CfgWorlds" >> worldName >> "SecondaryAirports" >> (configname _x) >> "ilsPosition"));
	} foreach _secAir;
	private _airportsOriginal = +(_airports);
	_airports =
	[
		_airports,
		[],
		{
			private _t = [];
			if (_x == "MAIN") then {
				_t = getarray (configfile >> "CfgWorlds" >> worldName >> "ilsPosition")
			} else {
				_t = (getArray (configfile >> "CfgWorlds" >> worldName >> "SecondaryAirports" >> _x >> "ilsPosition"))
			};
			//systemchat str [_t,_inputPos];
			_inputpos distance2D _t
		},
		"ASCEND"
	] call BIS_fnc_sortBy;
	private _selection = _airports select 0;
	private _ilsDir = []; ///-- ilsDir: NON CONSISTEND direnction of main strip? Mostly in direction of takeOff but sometimes exactly opposite
	private _taxiOff = [];
	private _taxiIn = [];
	if (_selection == "MAIN") then {
		_taxiIn =  getarray (configfile >> "CfgWorlds" >> worldName >> "ilsTaxiIn");
		_taxiOff = getarray (configfile >> "CfgWorlds" >> worldName >> "ilsTaxiOff");
		_ilsDir = getarray (configfile >> "CfgWorlds" >> worldName >> "ilsDirection");
	} else {
		_taxiIn = (getArray (configfile >> "CfgWorlds" >> worldName >> "SecondaryAirports" >> _selection >> "ilsTaxiIn"));
		_taxiOff = (getArray (configfile >> "CfgWorlds" >> worldName >> "SecondaryAirports" >> _selection >> "ilsTaxiOff"));
		_ilsDir = (getArray (configfile >> "CfgWorlds" >> worldName >> "SecondaryAirports" >> _selection >> "ilsDirection"));
	};




	//--StartPos
	if (count _taxiOff > 0) then {
		private _pX = _taxiOff select ((count _taxiOff) -2);
		private _pY = _taxiOff select ((count _taxiOff) -1);
		_startPos = [_pX,_pY];
	};
	//--LandingPos
	if (count _taxiIn > 0) then {
		//systemchat str _taxiIn;
		//copyToClipboard  str _taxiIn;
		private _pX = _taxiIn select ((count _taxiIn) -2);
		private _pY = _taxiIn select ((count _taxiIn) -1);
		_touchDownPos = [_pX,_pY];
	};
	_ilsDir = (_ilsDir select 0) atan2 (_ilsDir select 2);
	private _airportIndex = [_selection,_airportsOriginal] call MCSS_fnc_GetArrayIndex;
	private _dynamicAirports =  allAirports select 1;
	private _taxiOffDir = 0;
	if (count _dynamicAirports > 0) then {
		 _closestDynamicAirport= (_dynamicAirports select 0);
		_dynamicAirports =
		[
			_dynamicAirports,
			[],
			{
				_x distance2D _inputPos
			},
			"ASCEND"
		] call BIS_fnc_sortBy;
		if ( (_startPos distance2D _inputPos) > (_closestDynamicAirport distance2D _inputPos) ) then {
			_selection = _closestDynamicAirport;
			_airportIndex = -1;
			_startPos = position _closestDynamicAirport;
			_ilsDir = 0;
		};

	};
	private _taxiInPosArray = [];
	private _taxiOffPosArray = [];

	for "_i" from 0 to (((count _taxiIn) - 1) max 0) step 2 do {
		private _ilsPosArray = 
		[
			_taxiIn select _i,
			_taxiIn select (_i + 1)
		];
		_taxiInPosArray set [count _taxiInPosArray,_ilsPosArray];
	};

	for "_i" from 0 to (((count _taxiOff) - 1) max 0) step 2 do {
		//if (_i >= count _taxiOff) exitWith {};
		private _ilsPosArray = 
		[
			_taxiOff select _i,
			_taxiOff select (_i + 1)
		];
		_taxiOffPosArray set [count _taxiOffPosArray,_ilsPosArray];
	};

	//while {count _taxiIn > 0} do {
	//	_newPosition = [_taxiIn select 0,_taxiIn select 1];
	//	_taxiIn = _taxiIn - [_taxiIn select 0,_taxiIn select 1];
	//	_taxiInPosArray pushBack _newPosition;
	//};

	//while {count _taxiOff > 0} do {
	//	_newPosition = [_taxiOff select 0,_taxiOff select 1];
	//	_taxiOff = _taxiOff - [_taxiOff select 0,_taxiOff select 1];
	//	_taxiOffPosArray pushBack _newPosition;
	//};

	//_taxiInPosArray = _taxiInPosArray call MCSS_fnc_reverseArray;
	//_taxiOffPosArray = _taxiOffPosArray call MCSS_fnc_reverseArray;

	private _taxiPosCount = count _taxiOffPosArray;
	if (_taxiPosCount > 1) then {
		_taxiOffDir = (_taxiInPosArray select 0) getDir (_taxiInPosArray select 1);

		//player setpos (_taxiOffPosArray select 0);
		//player setDir _taxiOffDir;
		_taxiOffPosArray spawn {
			{
				//player setpos _x;
				sleep 2;
			} foreach _this;
		};
	};

	[_airportIndex, _selection,_touchDownPos,_startPos,_ilsDir,_taxiInPosArray,_taxiOffPosArray]
};




//-- this function creates 2 runway areas and two connecting areas, as well as a main airfield areas
//-- it is used to find positions within the main area that are NOT in any of the subareas, so they can be tested for aircraft parking

MCSS_fnc_getAirFieldRunwayAreas = {
	params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];

	_airportIlsDir = [_airportIlsDir] call MCSS_fnc_CorrectDir;
	//player setDir _airportIlsDir;

	private _runwayPositions = _taxiInPoses + _taxiOffPoses;

	

//	[_taxiOffPoses,_airportIlsDir] spawn {
//		params ["_taxiOffPoses","_airportIlsDir"];
//		_airportIlsDir = [_airportIlsDir] call MCSS_fnc_CorrectDir;
//		{
//
//			player setpos _x;
//			//if (_foreachINdex > 0) then {
//
//				if (_foreachINdex < (count _taxiOffPoses) - 1) then {
//					_refPos = _taxiOffPoses select (_foreachIndex + 1);
//					systemChat str [_airportIlsDir,(_x getDir _refPos)];
//					systemchat str (abs (_airportIlsDir - (_x getDir _refPos)));
//				};
//			//};
//			sleep 3;
//		} foreach _taxiOffPoses;
//	};



	//private _averageX = 0;
	//private _averageY = 0;
	//{
	//	_averageX = _averageX + (_x select 0);
	//	_averageY = _averageY + (_x select 1);
	//} foreach _runwayPositions;
	//if (_averageX > 0) then {
	//	_averageX = _averageX / (count _runwayPositions);
	//	_averageX = (_averageX + (_airportTaxiIn select 0)) / 2;
	//};
	//if (_averageY > 0) then {
	//	_averageY = _averageY / (count _runwayPositions);
	//};


	private _sizeX = 30; //-- diameter
	if (A3C_Debug) then {
		markerCount = if (isNil 'markerCount') then {0} else {markerCount};
	};
	private _areas = [];

	{
		if (_foreachIndex < (count _runWayPositions - 1)) then {
			private _startPos = _x;
			private _endPos = (_runWayPositions select (_forEachIndex + 1));
			
			private _length = _startPos distance2D _endPos;
			private _areaDir = _startPos getDir _endPos;
			private _sizeY = (_length / 2); // max a60;
			_sizeY = _sizeY max 50;
			private _areaCenter = _startPos getPos [_sizeY,_areaDir];
			private _area = [_areaCenter,_sizeX,_sizeY,_areaDir,true];
			_areas pushbackUnique _area;

			if (A3C_Debug) then {
				_marker = [(format ['A3C_Mark_P%1',markerCount]),_areaCenter,"RECTANGLE","RECTANGLE",[_sizeX,_sizeY],"","ColorOrange",1] call MCSS_fnc_createMarker;
				_marker setMarkerDir _areaDir;
				markerCount = markerCount + 1;
			};
		};
	} foreach _runWayPositions;

	//-- CREATE MAIN AIRFIELD AREA
	//-- find extreme values for x and y coordinates of runway positions
	private _highestX = -1;
	private _lowestX = 1e39; //-- 1e39 == infinity
	private _highestY = -1;
	private _lowestY = 1e39;
	{
		if (_x select 0 > _highestX) then {
			_highestX = _x select 0;
		};
		if (_x select 0 < _lowestX) then {
			_lowestX = _x select 0;
		};
		if (_x select 1 > _highestY) then {
			_highestY = _x select 1;
		};
		if (_x select 1 < _lowestY) then {
			_lowestY = _x select 1;
		};
	} foreach _runwayPositions;
	//-- use extreme values to generate width, length and center positoin
	_airportWidth = (_highestX - _lowestX) / 2;
	_airportLength = (_highestY - _lowestY) / 2;
	_airportCenter = [_lowestX + _airportWidth,_lowestY + _airportLength,0];


	//[_lowestX,_lowestY,0] [_lowestX,_highestY,0]
	//[_highestX,_lowestY,0] [_highestX,_highestY,0]

	_airportWidth = ([_lowestX,_lowestY,0] distance2D [_highestX,_lowestY,0]) / 4;
	_airportLength = ([_lowestX,_lowestY,0] distance2D [_lowestX,_highestY,0]) / 2;


	//player setpos _airportCenter;


	_mainArea = [_airportCenter,_airportWidth,_airportLength,_airportIlsDir,true];

	if (A3C_Debug) then {
		//systemchat str _airportCenter;
		//systemchat str _mainArea;
		//systemchat str [[_highestX,_lowestX],[_highestY,_lowestY]];
		_marker = [(format ['A3C_Mark_P%1',markerCount]),_airportCenter,"RECTANGLE","RECTANGLE",[_airportWidth,_airportLength],"","ColorBlufor",0.5] call MCSS_fnc_createMarker;
		_marker setMarkerDir _airportIlsDir;
		markerCount = markerCount + 1;
	};
	_allAreas = [_mainArea, _areas];
	_allAreas
};

MCSS_fnc_getAirFieldRunwayAreas1 = {
	params ["_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];

	_airportIlsDir = [_airportIlsDir] call MCSS_fnc_CorrectDir;

	private _approxLength =  _airportTaxiIn distance2D _airportTaxiOff;
	private _diameter = 40;


	//-- Landing
	//private _landingDir = [_airportIlsDir + 180] call MCSS_fnc_CorrectDir;
	private _landingDir = (_taxiOffPoses select (count _taxiOffPoses -1)) getDir (_taxiOffPoses select 0);
	_landingAreaPos = (_airportTaxiIn getPos [_approxLength /2,_landingDir]);
	_relDir = ((_airportTaxiOff getDir _airportTaxiIn) - _airportIlsDir);
	_relDir = ([_relDir] call MCSS_fnc_CorrectDir);
	//player commandChat str _relDir;

	//-- TakeOff
	_ilsAdjust = if (_relDir <= 180) then {90} else {-90};

	_takeOffAreaPos = (_airportTaxiOff getPos [_approxLength /2,_airportIlsDir]);

	_connectPos1_1 =  (_airportTaxiOff getPos [_approxLength + (_diameter / 2),_airportIlsDir]); //-- position End of TAKEOFFrunway

	_connectPos1_2 =  (_airportTaxiIn getPos [(_diameter / 2),_airportIlsDir]);
	_connectLength1 = _connectPos1_1 distance2D _connectPos1_2;
	_connectDir1 = [_airportIlsDir + _ilsAdjust] call MCSS_fnc_CorrectDir;
	_connectAreaPos1 = _connectPos1_1 getPos [_connectLength1 / 2,_connectDir1 ];

	_connectPos2_1 =  (_airportTaxiIn getPos [_approxLength + (_diameter / 2),_landingDir]); //-- connects to _airportTaxiOff
	_connectPos2_2 =  (_airportTaxiOff getPos [(_diameter / 2),_landingDir]);
	_connectLength2 = _connectPos2_1 distance2D _connectPos2_2;
	_connectDir2 = [_landingDir + _ilsAdjust] call MCSS_fnc_CorrectDir;
	_connectAreaPos2 = _connectPos2_1 getPos [_connectLength2 / 2,_connectDir2 ];


	_mainAreaLength = _connectAreaPos1 distance2D _connectAreaPos2;
	_mainAreaDir = _connectAreaPos1 getDir _connectAreaPos2;
	_mainAreaCenter = _connectAreaPos1 getPos [_mainAreaLength / 2,_mainAreaDir];

	_area0 = [_mainAreaCenter,_connectLength1 * 1.5,((_mainAreaLength / 2) + (_diameter * 2)),_mainAreaDir,true];   //-- Main Airfield Area
	_area1 = [_landingAreaPos,_diameter,(_approxLength /2),_airportIlsDir,true]; //-- LandingRunway
	_area2 = [_takeOffAreaPos,_diameter,(_approxLength /2),_airportIlsDir,true]; //-- TakeOff runway
	_area3 = [_connectAreaPos1,_diameter * 2,_connectLength1,_connectDir1,true]; //-- connect 1, LandingEnd to TakeoffStart
	_area4 = [_connectAreaPos2,_diameter * 2,_connectLength2,_connectDir2,true]; //-- connect 2


	//systemchat str _landingDir;

	{
		_marker = _x select 0;
		_area = _x select 1;
		_marker setMarkerPos (_area select 0);
		_marker setMarkerSize [(_area select 1),(_area select 2)];
		_marker setMarkerDir (_area select 3);
	} foreach [["airMark0",_area0],["airMark1",_area1],["airMark2",_area2] ,["airMark3",_area3] ,["airMark4",_area4]];

	[_area0,[_area1,_area2,_area3,_area4]]
};

//"A3\functions_f\waypoints\fn_wpLand.sqf"
A3C_HC_WPACTION_LANDING_FULL = {
	if (isNil 'A3C_IsA3CServer') exitWith {};

	params ["_leader","_waypointPos","_caller","_vectorDir","_forceDefaultLanding"];

	//systemchat str (_waypointPos);



	private _group = group _leader;
	private _leaderVehicle = vehicle _leader;
	private _scripts = [];
	if (isPlayer driver _leaderVehicle) exitWith {};

	_vectorDir = if (!isNil '_vectorDir') then {_vectorDir} else {[_leaderVehicle getDir _landingPos] call MCSS_fnc_DegreeToVector};

	//if !([_caller,_group] call A3C_HC_findExecutingMachine) exitWith {};
	if (!local _group) exitWith {};
	if (_group getVariable ["A3C_ISwpLANDING",false]) exitWith {};
	_group setVariable ["A3C_ISwpLANDING",TRUE,TRUE];

	//private _units = (units _group) call MCSS_fnc_reverseArray; //-- reverse, so that leader lands last, preventing crashes due to keeping formation
	_units = units _group;
	{
		private _vehi = vehicle _x;
		if (_x == driver _vehi) then {
			private _runwayLanding = ((getNumber (configfile >> "CfgVehicles" >> typeOf _vehi >> "landingSpeed")) > 10);
			if (_vehi isKindOf "PLANE" && {_runwayLanding}) then {
				private _airportData = [_waypointPos] call MCSS_fnc_getNearestAirportData;
				_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];
				[_x, _vehi getPos [10000,_airportIlsDir]] call A3C_DOMOVE;
			};
		};
	} foreach _units;
	{
		private _vehi = vehicle _x;
		if (_x == driver _vehi) then {
			private _runwayLanding = ((getNumber (configfile >> "CfgVehicles" >> typeOf _vehi >> "landingSpeed")) > 10);
			if (_runwayLanding && {_vehi isKindOf "PLANE"}) then {
				if (_x == (driver _vehi)) then {
					_scr = [_x,_waypointPos] spawn A3C_LANDPLANE;
					_currentActions = _group getvariable ["A3C_SCRIPTS",[]];
					_currentActions pushBackUnique ["landing_full_2",_scr];
					_group setvariable ["A3C_SCRIPTS",_currentActions,true];
					//_scripts pushback _scr;
					sleep 20;
				};
			} else {
				//_waypointPos = position _vehi;
				if (_forceDefaultLanding) then {
					_scr = [_group,_waypointPos] spawn {
						params ["_group","_waypointPos"];
						private ["_vehsMove","_vehsLand"];
						_vehsMove = [];
						_vehsLand = [];
						waituntil {
							private ["_countReady","_vehsGroup"];
							_countReady = 0;
							_vehsGroup = [];

							{
								private ["_veh"];
								_veh = vehicle _x;
								if (_x == effectivecommander _x) then {
									if (!(_veh in _vehsMove)) then {
										[effectivecommander _x,_waypointPos] call A3C_DOMOVE;
										_vehsMove set [count _vehsMove,_veh];
									} else {
										if !(istouchingground _veh) then {
											if (unitready _veh && !(_veh in _vehsLand)) then {


												_veh land "LAND";
												_vehsLand set [count _vehsLand,_veh];
											};
										} else {

											_veh engineon false;
											_countReady = _countReady + 1;
										};
									};
									_vehsGroup set [count _vehsGroup,_veh];
								};
							} foreach units _group;


							_vehsMove = _vehsMove - (_vehsMove - _vehsGroup);
							_vehsLand = _vehsLand - (_vehsLand - _vehsGroup);

							sleep 1;
							count _vehsGroup == _countReady
						};
					};
					_scripts pushback _scr;
					/*
					_scr = _vehi spawn {
						_padPos = ((getPosASL _this) select [0,2]) + [0];
						private _heliPad = "Land_HelipadEmpty_F" createvehicle _padPos;
						private _getLZ = {
							params ["_movePos"];
							private _maxdist = 20;
							private _landingpos = [];
							while {count _landingpos == 0} do {
								_landingpos = ([_movePos,[0,_maxdist]] call MCSS_fnc_getSafePos);
								//hint str time;
								_maxdist = _maxdist + 20;
							};
							_landingpos
						};
						waituntil {
							sleep 5;
							if (canMove _this && {_this distance2D (formationPosition (driver _this)) < 70 OR {speed _this < 1}}) then { //vehicle (leader group (driver _this))
								_padPos = ((getPosASL _this) select [0,2]) + [0];
								_padPos = [_padPos] call _getLZ;
								if (count _padPos > 0) then {
									_heliPad setPos _padPos;
								};
								//systemchat "land";
								_this land "LAND";
							};
							!canMove _this OR {isTouchingGround _this}
						};
						deletevehicle _heliPad;
					};
					_scripts pushback _scr;
					sleep 20;
					*/
				} else {
					//-- rail landing is specific to radial - not used by waypointscript
					if (_vehi == _leaderVehicle) then {
						[_vehi,_waypointPos,_vectorDir] spawn {
							params ["_vehi","_waypointPos","_vectorDir"];
							private _exit = false;
							while {alive _vehi} do {
								if (_vehi distance2D _waypointPos < 500) then {
									[_vehi,_waypointPos,_vectorDir] spawn A3C_RAIL_HELI_LANDING;	
									_exit = true;
								};
								if (_exit) exitWith {};
								sleep 1;
							};
						};
					} else {
						_vehi land "LAND";
					};

				};
				sleep 10;
			};
		};
	} foreach _units;
	_group setVariable ["A3C_ISwpLANDING",false,true];
	private _currentActions = _group getvariable ["A3C_SCRIPTS",[]];
	{
		_currentActions pushBackUnique ["landing_full_2",_x];
	} foreach _scripts;
	//systemchat str [_scripts];
	_group setvariable ["A3C_SCRIPTS",_currentActions,true];
	waituntil {
		{!scriptDone _x} count _scripts == 0
	};
	//systemchat "DUNZO";
};

A3C_OBJECTSEL_RESIZE = {
	params ["_parent","_listBox", "_amount"];
	private _boxSize = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1) * (_amount + 1);
	{
		_x ctrlSetPosition 
		[
			if (_foreachIndex == 0) then {0.383108 * safezoneW + safezoneX} else {(ctrlPosition _x) select 0},
			if (_foreachIndex == 0) then {0.378986 * safezoneH + safezoneY} else {(ctrlPosition _x) select 1},
			(ctrlPosition _x) select 2,
			if (_foreachIndex == 0) then {(0.0440051 * safezoneH) + _boxSize} else {_boxSize}
		];
		_x ctrlCommit 0;
	} foreach [_parent,_listBox];
};


TER_fnc_editString = {
  params ["_str", "_toFind", "_subsitution", ["_numLimit",10,[1]], ["_limit",true,[true]]];
  if (typeName _toFind != typeName []) then {_toFind = [_toFind]};
  {
      _char = count _x;
      _no = _str find _x;
      private _loop = 0;
      while {-1 != _str find _x && _loop < _numLimit} do {
          _no = _str find _x;
          _splitStr = _str splitString "";
          _splitStr deleteRange [(_no +1), _char -1];
          _splitStr set [_no, _subsitution];
          _str = _splitStr joinString "";
          if (_limit) then {_loop = _loop +1;};
      };
  } forEach (_toFind);
  _str
};





//-- check if a waypoint is completed
A3C_ExitRoute_isWpCompleted = {
	private ["_unit","_pos","_variDist","_inBuilding","_precision","_veh","_bool"];
	_unit = _this select 0;
	_pos = _this select 1;
	_variDist = _this select 2;

	private _exP = (expectedDestination _unit);
	
	_inBuilding = if (isNull objectParent _unit) then {true} else {false}; //_this select 3; //-- temp solution - in this fnc _inbuilding only checks for precise height
	_veh = vehicle _unit;
	if (isPlayer _unit) exitWith {true};
	//systemchat str _inbuilding;
	//systemchat str _inBuilding;
	_radius = _this select 4;
	_timeout = if (count _this > 5) then {_this select 5} else {false};
	_variDist = _variDist + _radius;
	
	if (_timeout == 0) then {
		if (_veh isKindOf "AIR") then {
			//if ((speed _veh) > 100) then {
				if !((_unit getvariable "A3C_CURRENTWAYPOINT_INDEX") == (count (_unit getvariable "A3C_PLOT"))) then {
					_variDist = 500;
					//systemChat str _variDist;
				} else {
					//_variDist = 5;
					//systemChat str _variDist;
				};
			//};
		};
	};
	_precision = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _veh) >> "precision")) + _variDist);
	private _bool = false;
	if (isnull objectParent _unit) then {
		if (_inBuilding) then {
			//systemchat "in building";
			if (([((getposATL _unit) select 2),(_pos select 2)] call MCSS_fnc_FindDifference) < 1) then {
				_precision = 1.5;
				//if ( (((getposASL _veh) select [0,2]) distance (_wPos select [0,2])) < (2 + _radius)) then {_bool = true};
				if ( ((getposASL _veh) distance2D _wPos) < _precision) then {
					//-- experimental: do not move on unless room is clear
					private _tgts = [(side _unit),10,"ENEMY",_wPos,["MAN"]] call MCSS_fnc_NearEntities;
					_bool = true;
					//systemchat 'yooooooo';
					{
						if ([_x,_unit] call MCSS_fnc_LOS_SIMPLE)  then {
							//if () then { aaaaa
								_bool = false;
							//};
						};
					} foreach _tgts;
				};

			};
		} else {
			if ( (((getposASL _veh) select [0,2]) distance (_wPos select [0,2])) < _precision) then {_bool = true};
		};
	} else {
		if ( (((getposASL _veh) select [0,2]) distance (_wPos select [0,2])) < _precision) then {_bool = true};
	};

	private _addFactor = if (isNull objectParent _unit) then {10} else {1.5};
	////---- Questionable bit!
	//_testPoses = [[0,0,0],_wPos];
	//systemchat str ({(_exP select 0) distance2D _x < 1} count _testPoses > 0);
	if (!isPlayer (effectiveCommander _veh)) then { // && {!(_inBuilding)}
		//systemchat '2';
		
		if ((unitReady _unit OR { moveToCompleted _unit}) ) then { //&& {{(_exP select 0) distance2D _x < 1} count _testPoses > 0}
			//systemchat '3';
			if ( ((getposASL _veh) distance2D _wPos) < (_precision * _addFactor)) then {
				
				if (A3C_DEBUG) then {
					systemchat format ["complete %1 | unitReady :%2 | moveToCompleted %3",_bool,unitReady _unit , moveToCompleted _unit];
				};
				_bool = true;
			};
		};
	};
	///////

	//if (A3C_DEBUG) then {hintsilent str (((getposASL _veh) select [0,2]) distance (_wPos select [0,2]))};
	//systemchat format ["unit: %1,wp-inbuilding: %2 wp complete: %3" ,_unit,_inBuilding, (str _bool)];

	//if (_unit == leader group _unit) then {
	//	systemchat format ["%1 wp completed %2",_unit,_bool];
	//};
	if (_bool && A3C_DEBUG) then {
		systemchat "waypoint was reached"
	};
	_bool
};

//-- check if a waypoint is aborted
A3C_ExitRoute_isWpAborted = {
	params ["_unit"]; //-- _wPos and _mode currently unused!!
	private ["_exP","_abort","_vehicle"];
	_vehicle = vehicle _unit;

	_exp = expectedDestination _unit;
	_abort = false;

	//-- The usual suspects:
	if (!isPlayer (leader group _unit)) exitWith {false}; //-- leader is AI - checks not relevant
	if (isNull _unit) exitWith {true};
	if !(alive _unit) exitWith {true};

	private _abortData = _unit getvariable ["A3C_ABORT_Data", [false, false]];
	//-- unit has ABORT DATA
	if ({_x} count _abortData > 0) exitWith { //-- Unit has command to abort one or all waypoints
		// systemchat format ['firing %1', _abortData];
		if (A3C_DEBUG) then {player commandchat format ['aborted, variable : %1 (%2)', name _unit, _abortData]};
		true
	};
	//~~ HC Groups abort anything that is NOT in all HC groups (WHAT EXATLY IS THIS?)
	if ((group _unit) != (group player)) then {
		if !((group _unit) in A3C_HC_getAllGroups_Player_CURRENT) then {
			_abort = true;
		};
	};
	//~~ unit is no longer driver of vehicle (REMOVE WHEN MAKING STANDBY WHILE IN VEHICLES)
	//if !(_unit == (driver vehicle _unit)) then {
	//	_abort = true;
	//};

	if (_abort && {A3C_DEBUG}) then {
		systemchat "aborted true"
	};
	_abort
};

//-- check if a unit has stopped
A3C_ExitRoute_isUnitStopped = {
	params ["_unit","_wPos","_mode"];
	private ["_return"];
	_return = false;
	if (!isPlayer (leader group _unit)) exitWith {false}; //-- since AI led by AI need to be in STOP mode in order to not fall back constantly
	private _exP = (expectedDestination _unit );
	if (currentcommand _unit == "STOP") then {
		if (_mode == 0) then {
			//-- mode == 0 - used BEFORE unit arrives at waypoint
			if !(A3C_BOOL_MOVINGMARKER) then {
				if !( (effectivecommander (vehicle _unit)) == _unit) then {
					if ((effectivecommander (vehicle _unit)) == player) then {
						if !((_exp select 0) isEqualTo _wPos) then {
							_return = true;
						};
					} else {
						if !( ((expectedDestination (effectivecommander (vehicle _unit))) select 1) in ["LEADER PLANNED","VEHICLE PLANNED"]) then {
							_return = true;
						};
					};
				} else {
					if !( (_exp select 1) in ["LEADER PLANNED","VEHICLE PLANNED"]) then {
						_return = true;
					};
				};
			};
		} else {
			//-- mode == 1 - used AFTER unit arrives at waypoint
			if !(A3C_BOOL_MOVINGMARKER) then {
				//-- if _unit is commander - abort.
				//-- if _unit is NOT commander and expDest is something else but "LEADER PLANNED" for both _unit and it's commander - abort
				private _effCom = (effectivecommander (vehicle _unit));
				if !( ((expectedDestination _unit ) select 1) == "LEADER PLANNED") then {
					if !( _effCom  == _unit) then {
						//if !( (effectivecommander (vehicle _unit)) == player) then {
							if !( ((expectedDestination _effCom) select 1) == "LEADER PLANNED") then {
								if ( ({((expectedDestination _effCom) select 0) distance2D _x <= 10} count [position (vehicle _effCom),[0,0,0]]) > 0) then {
									_return = true;
								};
							};
						//};
					} else {
						//-- stop means: unit is in STOP and expdest is close to unit's position (or [0,0,0])
						if ( ({((expectedDestination _unit ) select 0) distance2D _x <= 10} count [position (vehicle _unit),[0,0,0]]) > 0) then {
							_return = true;
						};
					};
				};
			};
		};
	};
	if (_return && {A3C_DEBUG}) then {systemchat "stop true"};
	_return
};

//-- Checks if WP is broken away from - movement order to position other than waypoint, not on units own position, unit is in formation
A3C_ExitRoute_isBrokenFrom = {
	private["_unit","_origDest","_data","_cycle","_return","_movePos","_vehicle","_debugString"];
	_unit = _this select 0;
	_origDest = _this select 1;
	_data = _this select 2;
	_cycle = _this select 3;
	_mode = _this select 4; //-- MODE: 0: BEFORE arrival at WP | 1: AFTER arrival at WP (during condition checks)
	_refDist = if (_mode== 0) then {20} else {0};
	_return = false;
	_movePos = ((_data select _cycle) select 0) select 0;
	_vehicle = vehicle _unit;
	//_precision = 0; //[_unit] call A3C_VehicleRadius;
	_precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf (vehicle _unit)) >> "precision"));
	_debugString = "";
	if (_unit getVariable ["A3C_CLEARING",false]) exitWith {false};
	if (!isPlayer (leader group _unit)) exitWith {false};
	if (A3C_BOOL_MOVINGMARKER) exitWith {false};
	//systemchat "1";
	if (isnil '_movePos') exitWith {true};
	//systemchat "2";
	private _expectedDestination = expectedDestination _unit;
	if (count _expectedDestination == 0) exitWith {false};
	_expectedDestination params ["_unitDestination","_orderType"];
	private _effectiveCommander = effectiveCommander _vehicle;
	private _ComDest = if (_unit == _effectiveCommander) then {_unitDestination} else {(expectedDestination _effectiveCommander) select 0};


	//-- check if unit is in formation
	if ((tolower (_orderType)) in ["donotplanformation", "formation planned"]) then {
		//systemchat str (tolower (_orderType));
		_return = true;
		_debugString = "Formation"
	};
	if (_unit != _effectiveCommander) then {
		if (!isPlayer _effectiveCommander) then {
			if (_ComDest distance2D [0,0,0] == 0) then { //-- comdest [0,0,1e+009] >> driver in formation (?)
				_return = true;
				_debugString = "Commander Snitch Formation"
			};
		};
	};

	if (toLower (_orderType) in ["leader planned","vehicle planned"]) then { //-- _orderType needs to be actual given order
		//if (_origDest distance2D [0,0,0] > 0) then {
			if (_unitDestination distance2D [0,0,0] > 0) then { //-- _unitDestination may not be at [0,0,0] (happens when unit is at it's destination already (?)
				if (_unitDestination distance2D _movePos > _precision) then {
					if (_unitDestination distance2D (getPosASL _vehicle) > _precision) then { //-- ASL is used because it's faster and we only check 2D.
						_return = true;
						_debugString = "destination change post arrival";
					};
				};
			};
		//};
	};

	_diag_message = [];
	if (_return) then {
		_diag_message =
		[
			"WAYPOINT DATA",
			lineBreak,
			format ["unit: %1", name _unit],
			lineBreak,
			format ["position: %1",getPosATL _unit],
			lineBreak,
			format ["orig dest: %1",_origDest],
			lineBreak,
			format ["movePos: %1",_movePos],
			lineBreak,
			format ["current dest: %1",(expectedDestination _unit) select 0],
			lineBreak,
			format ["distance destination|movePos: %1",((expectedDestination _unit) select 0) distance _movePos],
			lineBreak,
			format ["distance between destinations: %1",((expectedDestination _unit) select 0) distance _origDest],
			lineBreak,
			format ["distance between destination / unit: %1",((expectedDestination _unit) select 0) distance (getPosATL _unit)],
			lineBreak,
			format ["current destination mode: %1",(expectedDestination _unit) select 1],
			lineBreak,
			format ["current command type: %1",currentCommand _unit]
		];
	};
	if ( A3C_DEBUG) then { //_return && {}
		hint composeText _diag_message;
		//systemchat ("break from " + "(" + _debugString + ")")
	}; //format ["break from %1",_mode]
	_return
};


//-- is unit inside of specific building?
A3C_fnc_INSIDE = {
	params ["_clickPos","_building"];
	private ["_return","_refPos","_intersects"];
	if (count _clickpos ==2) exitWith {};
	_clickPos = +(_clickPos);
	_return = false;
	_refPos = ATLtoASL [(_clickPos select 0),(_clickPos select 1),30];
	_clickPos set [2,0];
	_clickPos = ATLtoASL _clickPos;
	_intersects = (lineintersectswith [_refPos,_clickPos,objnull,objnull]);
	if (_building in _intersects) then {
		_return = true;
	};
	_return
};





//-- Collect Data of a House. Heavy WIP, creates 'rooms' and finds doors.
A3C_HouseData = {
	private ["_building","_rooms","_fnc","_pos","_rooms","_room"];
	_building = _this select 0;
	_bDir = getDir _building;
	_bpC = ([_building] call MCSS_fnc_countBPos);
	_fnc = {
		_p = _this select 0;
		_p set [2,((_p select 2) + 1)];
		_p
	};
	_rooms = [];
	_pos = [];
	_numbers = [];
	for "_i" from 0 to _bpc do {
		_numbers pushback _i;
	};
	//~~ NOTE: this is way too complicated, find simple solution :)
	for "_i" from 0 to _bpc do {
		// 01 take a building position (should numbers check be here?
		_pos = [(_building buildingpos _i)] call _fnc;
		_room = [];

		// 02 check Bpos against all other positions that are still in numbers (means: excluding the ones that already checked everything
		_numbers = _numbers - [_i];  // _i can be removed
		if ([_pos, _building] call A3C_fnc_INSIDE) then {
			if ( ({_i in _x} count _rooms) == 0) then {
				_rooms pushbackunique [_i];
			};
			{
				_n = _x;
				if !(_building in  (lineIntersectsObjs  [(ATLtoASL _pos),(ATLtoASL ([(_building buildingpos _n)] call _fnc))])) then {
						{
							_r = _x;

							if (_i in _r) exitWith {
								(_rooms select _foreachindex) pushbackunique _n;
							};
						} foreach _rooms;
				};
			} foreach _numbers;
		};
	};

	// TEMPORARY NOOB SOLUTION TO COMBINE WRONGLY SEPERATED ARRAYS
	_combine = [];
	_array = [];
	for "_i" from 0 to ((count _rooms) -1) do {
		if (count _rooms <= _i ) exitWith {};
		_r = _rooms select _i;
		{
			_rc = _x;
			if ( (count (_r arrayIntersect _rc)) > 0) then {
				{_combine pushbackUnique _x} foreach (_r +_rc);
				_rooms = _rooms - [_r,_rc];
			};
		} foreach (_rooms - [_r]);
		if (count _combine > 0) then {_rooms pushBackUnique _combine};
	};
	//-- sort positions by height
	_rooms = [_rooms,[],{(_building buildingpos (_x select 0)) select 2},"ASCEND"] call BIS_fnc_sortBy;
	{
		// GET ROOM DIMENSIONS HERE?
		_pos = _x select 0;
	} foreach _rooms;

	_rooms
};

//-- Get Door-Positions of a building
A3C_DOORPOSITIONS = {
	private ["_building","_result","_doorpos"];
	_building = _this select 0;
	_result = [];
	_doorpos = [];
	_amount = (getNumber (configfile >> "CfgVehicles" >> (typeOf _building) >> "numberOfDoors"));
	for "_i" from 1 to _amount do {
		_doorPos = _building selectionPosition (format ["Door_%1_trigger", _i]);
		if (_doorPos isEqualTo [0,0,0]) exitWith {};
		_result pushback (_building modelToWorld _doorPos);
	};
	_result
};

//-- mockup-function to get the direction of a door
A3C_DOOR_DIR = {
	_building = _this select 0;
	_doorpos =_this select 1;
	_bDir = getDir _building;
	_doorDirection = 90;
	_refpos1 = [_doorPos,0.15,_bDir] call BIS_fnc_RelPos;
	_refPos2 = [_refPos1,0.5,_bDir] call BIS_fnc_RelPos;
	if (_building in  (lineIntersectsObjs  [(ATLtoASL _refpos1),(ATLtoASL _refPos2)])) then {
		 _doorDirection = 90;
	} else {
		_doorDirection = 0;
	};
	_doorDirection = _bDir + _doorDirection;
	_doorDirection
};

A3C_FORCEORIENT = {
	params ["_unit","_destination"];
	private ["_fnc"];
	_relDir = _unit getRelDir _destination;
	_dirto = [(getPos _unit),_destination] call BIS_fnc_dirTo;
	_pos = getpos _unit;
	_pos set [2,0];
	_offset = switch (true) do {
		case (_unit isKindOf "MAN") : {0.01};
		case (_unit isKindOf "TANK") : {0.002};
		case (_unit isKindOf "HELICOPTER") : {0.02};
	};

	_timer = time;
	if (_unit isKindOf "HELICOPTER") exitWith {
		[driver _unit,(vehicle _unit) getPos [100,(vehicle _unit) getDir _destination]] call A3C_DOMOVE;
		//_unit disableAI "MOVE";
		while {canMove _unit} do {
			_dir = (_unit getRelDir _destination);
			_range = _dir <= 30 OR _dir >= 330;
			if (_range) exitWith {
				//	"good exit" remoteExec ["systemchat",0];
			};
			if (time > _timer + 10) exitWith {
				//	"time" remoteExec ["systemchat",0];
			};
		};
		//_unit enableAI "MOVE";
	};
	//_unit enablesimulation false;
	_extraSleep = 0;
	if (isDedicated) then {
		_offSet = 1;
		_extraSleep = 0.01;
	};

	if (_relDir > 180) then {
		_offset = (_offset * -1);
	};

	_fnc = {
		params ["_veh","_dir"];
		private ["_trues","_return"];
		_trues = 0;
		{
			if ((abs ([_veh, (getDir _veh) + _x] call BIS_fnc_terrainGradAngle)) > 5) then {
				_trues = _trues + 1;
			};
		} foreach [0,90,180,270];
		_return = if (_trues > 0) then {true} else {false};
		_return
	};


	_endDiff = 3;
	_gradient = (_unit isKindOf "TANK") && ([_unit,getdir _unit] call _fnc);
	if (_gradient) then {
		_endDiff = 15;
		_offset = 10;
	};


	_step = 1;
	_vd = vectorDir _unit;
	_vU = vectorUp _unit;
	_timer = time;
	//systemchat str _gradient;
	_vel = velocity _unit;
	while {_reldir > _endDiff} do { //
		_relDir = _unit getRelDir _destination;

		//_unit setdir ((getdir _unit) + (_offset * accTime)); // 1 was accTime
		[_unit,((getdir _unit) + (_offset * accTime))] remoteExec ["setDir",_unit];

		//[_unit,_vel] remoteExec ["setVelocity",_unit];
		//_unit setVelocity _vel;

		if (time > _timer + 10) exitWith {};

		if (_gradient) then {
			//_unit setVectorUp _vU;
			[_unit,_vU] remoteExec ["setVectorUp",_unit];
			sleep 0.1;
		};
		//if (isServer) then {
		//	(str [getDir _unit,((getdir _unit) + (_offset * accTime))]) remoteExec ["systemChat",0];
		//	sleep _extraSleep;
		//} else {
		//	'Client' remoteExec ["systemChat",0];
		//};
	};
	//systemchat "done";
	//_unit setdir _dirto;
	//_unit setPos _pos; //[(getPos _unit select 0),(getPos _unit select 1),0];
};

A3C_calculateVelocity = {
	params ["_speed","_dir"];
	private _vel = [0,0,0]; //velocity _vehicle;
	_speed = .5; //_speed / 8;
	private _newVel =
	[
		(_vel select 0) + (sin _dir * _speed),
		(_vel select 1) + (cos _dir * _speed),
		0
	];
	_newVel
};


A3C_unitDYN_inf = {
	params ["_unit","_destination","_anims"];
	private _startpos = getPosASL _unit;
	_destination = ATLtoASL _destination;

	_anims set [0,"amovpercmevasraswrfldf"];


	private _path = [];
	private _dir = _startPos getDir _destination;
	private _pathlength = round (_startPos distance _destination);
	private _frameTime = .2;
	_oldPos = _startPos;
	_unit setVectorUp [0,0,1];
	private _nearBuildings = ((_startPos select [0,2]) + [0]) nearObjects 100;
	{
		if !(_x isKindOf "HOUSE") then {
			_nearBuildings = _nearBuildings - [_x];
		};
	} foreach _nearBuildings;
	_nearBuildings = [_nearBuildings,[],{_x distance2d _unit},"ASCEND"] call BIS_fnc_sortBy;
	if (count _nearBuildings > 0) then {
		_nearBuildings = _nearBuildings select 0;
	} else {
		_nearBuildings = objNull;
	};
	_inBuilding = false;
	if ([(_startPos select [0,2]) + [0], _nearBuildings] call A3C_fnc_INSIDE) then {
		_inBuilding = true;

	};
	//systemchat str [_pathLength,_inBuilding];
	for "_i" from 0 to _pathlength do {
		_newPos = _startPos getPos [_i,_dir];
		_newPos set [2,_oldPos select 2];
		_height = _oldPos select 2;
		if (_inBuilding) then {
			_refPos = _newPos vectorAdd [0,0,1.8]; //player setposASL _refPos; //1.8 is the max allowed 'jump'
			_newPos set [2,_height];
			_intsSurf = (lineintersectsSurfaces [_refPos, ATLtoASL ((_newPos select [0,2]) + [0]),(vehicle _unit), objNull, true]); //([_unit] call MCSS_fnc_Switch_Eyepos)

			if (count _intsSurf > 0) then {
				{
					if (_x select 2 == _nearBuildings) then {
						_newPos = (_intsSurf select 0) select 0;
						//player setposASL _newPos;
					};
				} foreach _intsSurf;
			};
		};

		_vectorDir = _startPos getPos [_i,_dir];
		_path pushBack
		[
			_frameTime * _i,
			if (_inBuilding) then {_newPos} else {ATLtoASL ((_newPos select [0,2]) + [0])},
			[0,0,0],   //(_oldPos vectorFromTo _newPos) does not work >> makes the unit perform a headbang
			[0,0,1],
			[6.75,_oldPos getDir _newPos] call A3C_calculateVelocity
		];
		if (_i == _pathlength) then {
			//-- add final position
			_path pushBack
			[
				_frameTime * _i,
				_destination,
				[0,0,0],   //(_oldPos vectorFromTo _newPos) does not work >> makes the unit perform a headbang
				[0,0,1],
				[6.75,_oldPos getDir _newPos] call A3C_calculateVelocity
			];
		};
		_oldPos = _newPos;
	};

	//{
	//	systemchat str (_x select 0);
	//} foreach _path;
	_uPlay = [_unit, _path] spawn BIS_fnc_UnitPlay;
	while {alive _unit} do {
		if (animationState _unit != (_anims select 0)) then {
			_unit switchMove (_anims select 0);
		};
		if (scriptdone _uPlay) exitWith {
			_unit switchMove (_anims select 1);
		};
		sleep .1;
	};
	//systemchat 'done';
	{[_unit,_x] remoteExec ["enableAI",_unit]} foreach ["ANIM","MOVE","PATH"];
};








A3C_VehicleRadius = {
	params ["_unit"];
	private ["_vehicle","_vari","_radius","_precision"];
	_vehicle = vehicle _unit;
	_vari = switch (true) do {
		case (_vehicle isKindOf "MAN") : {5};
		case (_vehicle isKindOf "AIR") : {150};
		default {15};
	};
	_precision = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "precision")) + _vari);
	(_vari + _precision)
};



////////////////////////////////////////////////////////////////







A3C_AI_HighCommand_wpAction_plantExplosive = {
	params ["_group","_magType"];

	if (!local _group) exitWith {};
	
	private _attachToObject = waypointAttachedVehicle [_group, currentWaypoint _group];
	// systemchat format ["DEBUG DETO MAIN - _attachToObject: %1", _attachToObject];
	if (!alive _attachToObject OR {_attachToObject in units _group} ) then { //isNil '_attachToObject' OR {isNull _attachToObject OR {}}
		_attachToObject = objNull;
	};
	private _detoUnits = [units _group] call A3C_fnc_getRemoteDetonatorUnits;
	if (typename _attachToObject == "STRING") then {
		_attachToObject = missionNamespace getVariable _attachToObject;

	};
	if (count _detoUnits == 0) exitWith {};
	//(str _attachToObject) remoteExec ["systemchat",0];
	// systemchat "DEBUG DETO HC";
	[_detoUnits select 0, waypointPosition [_group, currentWaypoint _group], [_attachToObject,_magType]] spawn A3C_AI_Squad_wpAction_plantExplosive;
};


A3C_AI_Squad_wpAction_plantExplosive = {
	params ["_unit","_targetPos","_orderDetails"];
	_orderDetails params ["_targetVeh","_ammoType"];
	// systemchat format ["DEBUG DETOINFO: %1", _orderDetails];
	_detoInfo = if (count _orderDetails > 2) then {_orderDetails select 2} else {[]};
	// systemchat format ["DEBUG DETOINFO: %1", _detoInfo];
	private ["_mags","_chargeType","_cf","_ordenance","_targetPos","_var"];

	
	//-- check for charge

	_mags = magazines _unit;
	_chargeType = "";

	if (_ammoType == "") then {
		{
			if !(getText (configfile >> "CfgMagazines" >> _x >> "nameSound") in ["satchelcharge","mine"]) then {_mags = _mags - [_x]};
		} foreach _mags;
		if (count _mags > 0) then {
			_ammoType = _mags select 0;
		};
	};
	if (_ammoType == "") exitWith {};
	
	//-- get charge position

	private _targetDist = 1e39;
	private _exit = false;

	private _getAttachWorldPos = {
		params ["_targetVeh","_vehicleLength","_h"];
		private _attachPosMTW = [0,0,0];	
		private _attachPosAGL = (getpos _targetVeh) getPos [_vehicleLength,(getDir _targetVeh + 180)];
		_attachPosAGL set [2,_h];

		private _ins = lineintersectsSurfaces
		[
			AGLtoASL _attachPosAGL,
			(AGLtoASL (((position _targetVeh) select [0,2]) + [_h])),
			objNull,
			objNull,
			true,
			-1
		];
		//RED_LINES = [ [AGLtoASL _attachPosAGL, (AGLtoASL (((position _targetVeh) select [0,2]) + [_h]))] ];
		_ins = _ins select {_x select 2 == _targetVeh};
		if (count _ins > 0) then {
			_attachPosAGL = ASLtoATL ((_ins select 0) select 0);
			_attachPosAGL set [2,_h];
			_attachPosMTW = _targetVeh worldToModel _attachPosAGL;
			//_attachPosMTW set [2,_h];			
		} else {
			_attachPosAGL = position _targetVeh;
		};
		[_attachPosAGL,_attachPosMTW]
	};

	private _vehicleLength = 0;
	private _h = 0;
	private _attachMTW = [0,0,0];

	//-- get attachdata or exit if vehicle left
	if (!isNull _targetVeh && {typeName _targetVeh == "OBJECT"}) then {
		_vehicleLength = (((boundingboxreal _targetVeh) select 1) select 1) * 2;
		_h = ((((boundingBoxReal _targetVeh) select 1) select 2) * 0.75) min 1.3;
		_targetDist = 50; //(sizeOf typeOf _targetVeh) * 1.3;
		if (!isPlayer leader group _unit) then {
			_targetDist = _targetDist * 1.3; //-- be more generous for AI led groups
		};
		if (_targetVeh distance _targetPos > _targetDist OR {speed _targetVeh > 0}) then { //-- the target object is no longer at the position
			_exit = true;
			//systemchat 'oi';
		} else {
			_attachData = [_targetVeh,_vehicleLength,_h] call _getAttachWorldPos;			
			_targetPos = _attachData select 0;
			_attachMTW = _attachData select 1;
		};		
	};
	// systemchat format ["DEBUG DETO - %1, %2",_targetVeh,  _exit];
	if (_exit) exitWith {};


	//-- move to position
	[_unit,_targetPos] call A3C_DOMOVE;
	waitUntil {((expectedDestination _unit) select 0) distance2d _targetPos == 0};
	// systemchat "DEBUG DETO - Destination Active";
	sleep 2;
	waitUntil {
		_unit distance2d _targetPos < 7 &&
		{
			!(isPlayer (leader group _unit)) || {unitReady _unit} 
		}
	};
	// systemchat "DEBUG DETO - Destination Reached";
	//-- execute placement


	_unit playMove "ainvpknlmstpslaywrfldnon_medic";
	sleep 2;
	[_unit,_ammoType] remoteExec ["removeMagazine",_unit];

	_ammo = getText (configfile >> "CfgMagazines" >> _ammoType >> "ammo");
	private _mineTrigger = getText (configfile >> "CfgAmmo" >> _ammo >> "mineTrigger");

	_chargeType = _ammo;

	//-- ordenance requires MP-global varname
	A3C_VARNAME_INDEX = if (!isNil 'A3C_VARNAME_INDEX') then {A3C_VARNAME_INDEX} else {1};
	_uid = if (!isNull player) then {getPlayerUID player} else {"111011101111"};
	_chargeName = format ["A3C_REMOTE_CHARGE_%1_%2",_uid,A3C_VARNAME_INDEX];
	A3C_VARNAME_INDEX = A3C_VARNAME_INDEX + 1;
	_ordenance = call compile format
	[
		"

			%1 = '%2' createvehicle %3;
			publicVariable '%1';
			%1
		",
		_chargeName,
		_chargeType,
		(_unit getPos [0.5,getDir _unit])
	];


	sleep 2;
	//-- attach to vehicle
	if ( typeName _targetVeh == "OBJECT" &&  {!isNull _targetVeh}) then {
		// systemchat "DEBUG DETO TEST 1";
		if (count _attachMTW isEqualTo [0,0,0]) then {
			_ordenance setPos (position _targetVeh);
		} else {
			_ordenance attachTo [_targetVeh,_attachMTW];
			_ordenance setvectorDirAndUp  [[-1,0,0],[0,-1,0]];
		};
	} else {
		// systemchat format ["DEBUG DETO TEST 2 , %1, %2", _targetPos select 2, typeOf _ordenance];
		_targetPos set [2,0]; //-- #NOTE: WHY IS IT NECESSARY? CAN BE NEGATIVE Z-VALUE
		_ordenance setPos _targetPos; //(ASLtoATL _targetPos);
	};


	waituntil {animationState _unit != "ainvpknlmstpslaywrfldnon_medic"};

	if (_mineTrigger == "RemoteTrigger") then {
		//private _doBroadcast = if (isPlayer leader group _unit) then {false} else {true};
		_unit setVariable ["A3C_UNIT_EXPLOSIVES",(_unit getvariable ["A3C_UNIT_EXPLOSIVES",[]]) + [_ordenance],true];
	};

};

A3C_AIGetOut = {
	params ["_unit"];
	private _v = objectParent _unit;
	if (!isNull _v) then {
		// _unit action["Eject",_v]; //-- not used because helicopter
		_unit leaveVehicle _v;
		_unit remoteExec ["unassignVehicle",0]; //-- needs to be executed on every machine
		dogetout _unit;
		[_unit] orderGetin false;
	};
	_v //-- return vehicle, used in highCommand.sqfd
};

//-- REVERT AND DELETE ALL DATA FOR EXISTING ORDERS  // purpose vs below??
A3C_RESET = {
	_unit = _this select 0;
	_data = (_unit getvariable "A3C_PLOT");
	_amount = ((count _data) + 5) ;
	_unitnumber = _unit getvariable "A3C_VVNI"; //"A3C_FORMATION_INDEX";
	if ((vehicle _unit) isKindOf "AIR") then {
		{
			if ((assignedvehicle _x) == (vehicle _unit)) then {
				if !(_x in (vehicle _unit)) then {
					[[_x], A3C_AIGetOut] remoteExec ['bis_fnc_call', _x];
				};
			};
		} foreach allunits;
	};
	{_unit enableAI _x} foreach ["MOVE","TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //,"THREAT_PATH","PATHPLAN"
	{_unit setskill [_x,((_unit getvariable "A3C_SKILLDATA") select _foreachindex)]} foreach ["commanding","spotDistance","spotTime"];

	{
		_syncArray = _x select 5;
		{
			[_x,_unit,"A3C_PLOT"] call A3C_DELETE_MARKER;
		} foreach (_x select 1);
	} foreach (_unit getvariable "A3C_PLOT");
	_unit setvariable ["A3C_PLOT",[],true];
	_unit setvariable ["A3C_PLOT_TEMP",[],true];
	[(vehicle _unit),"UNLOCKED"] remoteExec ["setvehicleLock", (vehicle _unit)];

	_unit forceSpeed -1; //-- reset unit speed
	if (!isnull objectParent _unit) then {
		if (_unit == (driver (vehicle _unit)) ) then {
			(vehicle _unit) limitspeed 1000; //-- reset vehicle speed
		};
	};
};

A3C_VARNAME_INDEX_HC = 0;


//-- Set Init-Values for new units. All units need A3C-Vars and a vehicleVarName. Adds "killed"-EVH in case unit dies while HUD-selector is active.
A3C_UNIT_INIT = {
	private ["_unit","_mode","_index"];
	_unit = _this select 0;
	_mode = if (count _this > 1) then {_this select 1} else {1};
	//systemchat 'start';
	//systemchat str _mode;
	_irType = switch (side _unit) do {
		case (WEST) : {"B_IR_Grenade"};
		case (EAST) : {"O_IR_Grenade"};
		default {"I_IR_Grenade"};
	};
	


	if (profileNameSpace getVariable "A3C_SKILL_VAR")  then {
		_unit setskill 1;
	};
	if ( (typename (_unit getvariable ["A3C_VVNI",[]])) == "SCALAR" && {!([(getplayerUID player),(vehicleVarname _unit)] call BIS_fnc_inString )}) exitWith { //~~ ALERT: is this really compatible when joining units that were previoudly assigned a number??
		//systemchat format ["unit %1 is already initialized", vehiclevarname _unit];
	};

	if (_mode == 1) then {
		//params ["_unit"];
		if ((vehicleVarName _unit) == "") then {
			while {(vehicleVarName _unit) == ""} do {
				//systemchat 'varname loop';
				call compile format
				[
					"
						_unit setvehicleVarName 'A3C_MEMBER_%1_%2';
						A3C_MEMBER_%1_%2 = _unit;
					",
					getPlayerUID player,
					A3C_VARNAME_INDEX
				];
			};
		} else {
			call compile format
			[
				"
					%1 = _unit;
				",
				(vehiclevarname _unit)
			];
		};

		_unit setvariable ["A3C_FORMATION_INDEX", [_unit] call A3C_GETUNITINDEX, true];
		_unit setvariable ["A3C_VVNI",A3C_VARNAME_INDEX,true]; //-- VEHICLE VARNAME INDEX
		A3C_VARNAME_INDEX = A3C_VARNAME_INDEX + 1;
	};
	_count = count  (_unit getvariable ["A3C_PLOT_TEMP",[]]);
	if (_count > 0) exitWith {};
	_count = count  (_unit getvariable ["A3C_PLOT",[]]);
	if (_count > 0) exitWith {};
	//systemchat 'hello';
	_unit setvariable ["A3C_PEEL_ACTIVE",false,false];
	_unit setvariable ["A3C_PLOT",[],true];
	_unit setvariable ["A3C_PLOT_TEMP",[],true];
	_unit setvariable ["A3C_CURRENTWAYPOINT_INDEX",1,true];
	_unit setvariable ["A3C_PLOT_ACTIVE",false,true];
	_unit setvariable ["A3C_SYNC_WPINDEX",0,true];
	_unit setvariable ["A3C_SYNC_ITEMS",[],true];
	_unit setvariable ["A3C_WP_LINES",[],true];
	_unit setvariable ["A3C_SUPPRESSION_TARGET",[0,false,-1],true];
	_unit setvariable ["A3C_UNIT_POLYS",[],true];
	_unit setvariable ["A3C_UNIT_EXPLOSIVES",[],false];
	_unit setvariable ["A3C_POLY_ACTIVE",[],true];
	_unit setvariable ["A3C_STROBE",[],true];
	_unit setvariable ["A3C_CLEARING",false,true];
	_unit setVariable ["A3C_DEST",[],true];
	_unit setVariable ["babe_em_vars", [false, false, true],true];
	_unit setVariable ["A3C_EM_climbing",false,false];
	_unit setVariable ["A3C_EM_default_animspeedcoef",(getAnimSpeedCoef _unit),false];
	_unit setVariable ["A3C_EM_helper",objnull,false];
	_unit setVariable ["A3C_PAUSE_PLAN",false,false];
	_unit setVariable ["A3C_HOLD",false,false];
	_unit setVariable ["A3C_HOLD_COVER",false,false];

	//-- exclude team AI from AI-Enhancing addons
	_unit setVariable ["NOAI",1,false];
	_unit setVariable ["asr_ai_exclude", true,true];
	//_unit setVariable ["TCL_Disabled", true, true];
	_unit setVariable ["Vcm_Disable",true,true];
	_unit setVariable ["dangerAIEnabled",false,true];
	_unit setVariable ["lambs_danger_dangerAIEnabled",false,true];

	private _eventhandlers = _unit getVariable ["A3C_UNIT_EHs",[]];
	if (count _eventhandlers == 0) then {
		if (_unit != player) then {
			private _eh = _unit addeventhandler
			[
				"KILLED",
				{
					private ["_body","_unitArray"];
					_body = _this select 0;
					if ( (count (_body getvariable 'A3C_HUD_DATA')) > 0) then {
						[_body] spawn A3C_HUD_REMOVE_SELECTED;
					};
					private _eventhandlers = _unit getVariable ["A3C_UNIT_EHs",[]];
					{
						_body removeEventHandler [_x select 0,_x select 1];
					} foreach _eventhandlers;
				}
			];
			
			// if (isClass(configFile >> "CfgPatches" >> "mavik_Data")) then {
			// 	private _id = player getVariable ["DB_playerPutID", -1];
			// 	if (_id != -1) then { player removeEventHandler ["Put", _id] };
			// 	private _id = player addEventHandler ["Put", { _this call mavic_fnc_createMavicOnItemCheck }];
			// 	player setVariable ["DB_playerPutID", _id];
			// };
			
			
			
			_unit setVariable
			[
				"A3C_UNIT_EHs",
				[["KILLED",_eh]]
			];
		};
	};
	

	//systemchat 'adding EH';
	
	{
		private ["_am","_array"];
		_it = _x;
		_am = (getText (configfile >> "CfgMagazines" >> _x >> "ammo"));
		_array = "true" configClasses (configfile >> "CfgAmmo" >> _am >> "NVGMarkers");
		if (count _array == 0) exitWith {
			_unit addMagazine _irType;
		};
	} foreach (magazines _unit);
	//systemchat 'unit init done';
};

if (isDedicated) exitWith {};



//----------------------------------  G E N E R A L  F U N C T I O N S  ------------------------
//---------------------------------------  General MCSS-Functions  -----------------------------
//----------------------------------------------------------------------------------------------










MCSS_fnc_RevealCursorPos = {
	params ["_caller","_pos"];
	private ["_intersects","_collider","_startPos"];
	_collider = objNull;
	_startPos = [_caller] call MCSS_fnc_Switch_Eyepos;
	_intersects = lineIntersectssurfaces [_startPos,(ATLtoASL _pos),_caller];
	if (count _intersects > 0) then {
		_collider = (_intersects select 0) select 2;
		if ([_caller,_collider] CALL MCSS_fnc_LOF) then {
			_caller reveal [_collider,4];
		};
	};
};




//----------------------------------  S H A R E D  F U N C T I O N S  --------------------------
//----------------------------------------------------------------------------------------------
//-----------------------------  functions to that affect multiple A3C-modes  -------------------





A3C_UNIT_HOLD = {
	private ["_units","_unitNames","_coverUnits"];
	_units = _this;
	{
		if (isPlayer _x) then {_units = _units - [_x]};
	} foreach _units;
	_unitNames = "";
	_coverUnits = [];


	{
		_exP = (expectedDestination _x);
		if ((_exP select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
			if !(_x getVariable ["A3C_HOLD_COVER",false]) then {
				_x setVariable ["A3C_HOLD_COVER",true,false];
				_coverUnits pushBackUnique _x;
			};
		};
		_x setVariable ["A3C_HOLD",true,false];
		_unitNames = _unitNames + ([_x,1] call MCSS_fnc_NAMESTRING)
	} foreach _units;
	[_coverUnits,1] spawn A3C_AI_Squad_action_FindCoverExecute;
	player groupchat  _unitNames + " HOLD";
	[A3C_MAP_CommandMode] call A3C_UI_MAP_UFSB_RefreshControlBar;
};

A3C_UNIT_CONTINUE = {
	private ["_units","_unitNames"];
	_units = _this;
	{
		if (isPlayer _x) then {_units = _units - [_x]};
	} foreach _units;
	_unitNames = "";
	{
		_x setVariable ["A3C_HOLD",false,false];
		_x setVariable ["A3C_HOLD_COVER",false,false];
		_unitNames = _unitNames + ([_x,1] call MCSS_fnc_NAMESTRING)
	} foreach _units;
	player groupchat  _unitNames + " MOVE";
	[A3C_MAP_CommandMode] call A3C_UI_MAP_UFSB_RefreshControlBar;
};













A3C_LB_TICKTIME = time;

A3C_LB_Change = {
	// systemchat "A3C_LB_Change";
	if (A3C_CurSel) exitWith {};

	params ["_mode","_lb","_a3c_dsp"];
	
	/*
		Currently a shared function between map and Radial.
		Radial uses it for Right Extension- and teamcolor-listboxes
		Map uses it for target assignment, Teamcolor assignment and the Squad waypoint context menu
		ToDo: Split them up For radial and Map :)

	*/

	
	//~~ #TODO: rearrange to have logical order
	//-- modes:
	//-- 0: SQ-WPContext-Heli
	//-- 1: Assign Target | Attack/Ignore (Shared by SQ & HC)
	//-- 2: SQ-WPContext-Infantry
	//-- 3: Squad-Level Teamcolor assignment


	private _doubleClick = false;
	if (isnil "_mode") exitWith {};





	private _btn = 0;
	private _gp = objnull;
	private _targetUnits = A3C_SELECTED_UNITS;
	if ((typeName _mode) == "ARRAY") then {
		_btn = _mode select 1;
		_mode = _mode select 0;
	};

	private _tickTime = (time - A3C_LB_TICKTIME);
	if ((_tickTime > 0.07) && (_tickTime < 0.3)) then {
		_doubleClick = true;
	};
	A3C_LB_TICKTIME = time;
	private _dest = switch (_mode) do {
		case (1) : {A3C_TRACKED_ENEMYGROUP};
		case (2) : {A3C_GCUNITS};
		default {objnull}; //-- for _mode in [1,3]
	};


		
	switch (_mode) do {
		case (0) : {
			[_lb] call A3C_SWITCHMARKER;
		};
		case (1) : {
			{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
			if (count A3C_SELECTED_UNITS > 0) then {
				if (typeName (A3C_SELECTED_UNITS select 0) == "GROUP") then {

					{
						{
							_soldier = _x;
							_target = objNull;
							if ((count units _dest) >= (_foreachIndex + 1)) then {
								_target = ((units _dest) select _forEachIndex);
							} else {
								_target = ((units _dest) select 0);
							};
							if (_lb == 1) then {
								[
									[_soldier, _target],
									{
										params ["_soldier","_target"];
										_soldier reveal [_target,4];
										_soldier commandTarget _target;
										_soldier commandFire _target;
									}
								] remoteExec ['bis_fnc_spawn', _soldier];
								
								
							};

						} foreach (units _x);
						player groupChat format ["%1 - target that enemy!",groupID _x];
					} foreach A3C_SELECTED_UNITS;
				} else {
					{
						_un = _x;

						if (   ({_un in (vehicle _x)} count A3C_SELECTED_UNITS) > 0) then {
							if !(_x in _targetUnits) then {
								if ( ((assignedVehicleRole _x) select 0) == "Turret") then {
									if ((count ((vehicle _un) weaponsTurret ((assignedVehicleRole _un) select 1))) > 0) then {
										_targetUnits pushback _x;
									};
								};
							};
						};
					} foreach units group player;
					{
						_soldier = _x;
						_target = objnull;
						if ((count units _dest) >= (_foreachIndex + 1)) then {
							_target = ((units _dest) select _forEachIndex);
						} else {
							_target = ((units _dest) select 0);
						};
						_soldier reveal [_target,4];
						if (_lb == 0) then {
							if ((assignedTarget _soldier) in (units _dest)) then {
								_soldier dotarget _objnull;
								_soldier lookAt objnull;
								_soldier doWatch objnull;
							};
						} else {
							_soldier commandtarget (vehicle _target);
							_soldier lookAt (vehicle _target);
							_soldier doWatch (vehicle _target);
						};
					} foreach _targetUnits;
				};
			};
		};
		case (2) :{
			(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlShow false;
			_lb call A3C_GoCode_Switch;
		};
		case (3) : {
			_units = [_dest];
			_color = "MAIN";
			
			_backCol = [1,1,1,1];
			_isMap = (!isNull (findDisplay 100020));



			_compare = if (_isMap) then {A3C_SELECTED_UNITS} else {A3C_RD_UNITS};
			if (_dest in _compare) then {
				{_units pushback _x} foreach _compare - [_dest];
			};
			switch (_lb) do {
				case (0) : {
					_color = "RED";
					_backCol = [A3C_UI_COLOR_RED,1] call A3C_UI_fnc_setOpacity;
				};
				case (1) : {
					_color = "GREEN";
					_backCol = [0,1,0,1];
				};
				case (2) : {
					_color = "BLUE";
					_backCol = [A3C_UI_COLOR_BLUE,1] call A3C_UI_fnc_setOpacity;
				};
				case (3) : {
					_color = "YELLOW";
					_backCol = [A3C_UI_COLOR_YELLOW,1] call A3C_UI_fnc_setOpacity;
				};
				case (4) : {
					_color = "MAIN";
					_backCol = [1,1,1,1];
				};
			};

			{

				_x assignTeam _color;
				_x setVariable ["A3C_ASSIGNEDTEAM",_color];
				private _treeVar = _x getVariable ["A3C_TREESEL_INDEX",[]];
				if (count _treeVar > 0) then {
					private _btn = _treeVar select ((count _treeVar) -1); //-- make sure we fetch the sub-button
					private _ct_tree1 = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
					_ct_tree1 tvSetColor [_btn,_backCol];
				};
			} foreach _compare;

			if (_isMap) then {
				{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
			} else {
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX) ctrlShow false;
				//-- to do: update tree!
			};
			[_a3c_dsp,A3C_MAP_CommandMode] call A3C_UI_MAP_Overlay_ResizeTeamColorsXWH;
			[] spawn {
				sleep 0.1;
				[0] call A3C_UI_MAP_RESIZE_TEAMCOLORS_Y;
			};
		};
		case (4) : {
			_gp = [A3C_HC_getAllGroups_Player_Current select (_btn - 1)];
			{
				if !(_x in _gp) then {_gp pushback _x};
			} foreach A3C_SELECTED_UNITS;
			{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
			[1,_gp] spawn A3C_BTN_HC;
		};
		case (5) : {
			//-- WP loop
		};
		case (6) : {
			//-- medic
			//systemchat "triggered";
			private _medics = (group player) getVariable ["A3C_MEDICS",[]];
			if (_lb >= 0) then {
				private _medics_lb = [];
				if ((_lb == 0) && ((count _medics) > 1) ) then {
					_medics_lb = _medics
				} else {
					if ((count _medics) > 1) then {
						_medics_lb = [(_medics select (_lb - 1))];
					} else {
						_medics_lb = [(_medics select 0)];
					};
				};
				(group player) setVariable ["A3C_MEDICS_LB",_medics_lb];
			};
		};
		case (7) : {
			//-- patient
			//-- default: all patients - to be overridden by single selections
			private _patients = (group player) getVariable ["A3C_PATIENTS",[]];
			
			if (_lb >= 0) then {
				private _patients_lb = [];
				if ((_lb == 0) && ((count _patients) > 1) ) then {
					_patients_lb = _patients;
				} else {
					if ((count _patients) > 1) then {
						_patients_lb = [(_patients select (_lb - 1))];
					} else {
						_patients_lb = [(_patients select 0)];
					};
				};
				private _lbMin = if (lbSize (findDisplay _a3c_dsp displayCtrl 8055) == 1) then {0} else {1};
				
				if (_doubleClick && (_lb >= _lbMin)) then { //-- lb > 0 means 'heal all' was not selected :)
					//-- double click: cancel for individual unit
					private _patient = _patients select (_lb - 1);
					// systemchat format ["Double click - patients: %1", _patient];
					_patient setVariable ["A3C_AbortHealing", true];
					
					{
						private _evaluatedPatients = (group player) getVariable[_x, [] ];
						_evaluatedPatients = _evaluatedPatients - [_patient];
						(group player) setVariable [_x, _evaluatedPatients];
						
					} foreach ["A3C_PATIENTS_ASSIGNED", "A3C_PATIENTS_DESIGNATED"]; //"A3C_PATIENTS_LB", 
					systemchat format ["HEALING CANCELLED FOR %1", name _patient];
					[] call A3C_UI_RADIAL_UPDATE_MEDICAL;
					
					

				} else {
					//-- single click: select individual unit
					(group player) setVariable ["A3C_PATIENTS_LB", _patients_lb];
				};
				
			};
		};
		case (8) : {
			//-- LB 1
			if (_lb >= 0) then {
				
					//systemchat '11';
					A3C_TARGETVEH = A3C_VEHSAV select _lb;
					
					["VEHICLES",1] call A3C_UI_RADIAL_LABEL_LB;
					
					
				
			};
		};
		case (9) : {
			//-- LB 2
			if (_lb >= 0) then {
				
					// insert function here
				
			};
		};
		case (10) : {
			[_lb] call A3C_Rearm_LBChange_Source;
		};
		case (11) : {
			[_lb, _doubleClick] call A3C_Rearm_LBChange_SourceContent;
		};
		case (12) : {
			
				_mode = switch _lb do {
					case 0 : {"CARELESS"};
					case 1 : {"SAFE"};
					case 2 : {"AWARE"};
					case 3 : {"COMBAT"};
					case 4 : {"STEALTH"};
				};
				{
					[_x,["BEHAVIOUR",_mode]] call MCSS_fnc_orderIndividual;
				} foreach A3C_RD_UNITS;
			
		};
		case (13) : {
			
				_mode = switch _lb do {
					case 0 : {"BLUE"};
					case 1 : {"GREEN"};
					case 2 : {"WHITE"};
					case 3 : {"YELLOW"};
					case 4 : {"RED"};
				};
				{
					[_x,["COMBATMODE",_mode]] call MCSS_fnc_orderIndividual;
				} foreach A3C_RD_UNITS;
			
		};
	};
};


//---------------------------------------  G R O U P  M A N A G E M E N T   -------------------------------------------
//---------------------------------------------------------------------------------------------------------------------


// -- Save the unit's indexNumber within group.
// -- Var has to be saved because (units group player) is not a reliable way to fetch this number
// -- Var is used to find the correct units to assign to keyBinds and ui-buttons.
A3C_GETUNITINDEX = {
	private ["_teamMembers","_unit","_index"];
	_unit = _this select 0;
	_index = 2;
	_teamMembers = (profileNamespace getvariable "A3C_GROUPUNITS");
	for "_i" from 0 to ((count _teamMembers) -1) do {
		if (_unit == (_teamMembers select _i)) exitWith {_index = _i};
	};
	_index = _index + 1;
	_index;
};




//-- New Unit(s) joining the player's group - updates A3C-Groupdata.
A3C_JOIN_UNIT = {
	private ["_aliveUnits","_unitArray","_initArray"];
	_aliveUnits = [];
	_initArray = [];
	_unitArray = +(profileNamespace getvariable "A3C_GROUPUNITS");
	_aliveActual = {alive _x} count units player;
	_aliveRef = {alive _x} count _unitArray;
	//if (A3C_UNITCOUNTER < (count units group player)) then {
	//systemchat str [_aliveActual , _aliveRef];

	 group player setvariable ["TCL_Disabled", True];
	 group player  setvariable ["asr_ai_exclude", True];

	//-- remove Dead units (only a safety, most likely it gets removed from kill-EH
	{
		_soldier = _x;
		if !(_soldier in (units group player)) then {
			_unitArray set [_forEachIndex,objnull];
			if (_soldier in A3C_HUD_UNITS) then { // can not work coz unit is not in _unitarray anymore
				[_soldier] call A3C_HUD_REMOVE_SELECTED;
			};
		};
	} foreach _unitArray;

	//-- add new units to _unitArray
	{
		_soldier = _x;
		if !(_soldier in _unitArray) then {
			for "_i" from 0 to (count _unitArray) do {
				if ( (!alive (_unitArray select _i)) && !( (_unitArray select _i) in (units group player) ) ) exitWith {
					//[_soldier] call A3C_UNIT_INIT; //-- need to init later because it requires the unit to be in _unitArray
					_initArray pushBackUnique _soldier;
					_unitArray set [_i,_soldier];

				};

				if ( _i == (count _unitArray)  ) then {

					_unitArray pushbackUnique _soldier;
					_initArray pushbackUnique _soldier;

				};
			};
		};
	} foreach (units group player);

	/*
	if (_aliveActual > _aliveRef) then {
		{

			_soldier = _x;
			if !(_soldier in _unitArray) then {
				for "_i" from 0 to (count _unitArray) do {
					if ( (!alive (_unitArray select _i)) && !( (_unitArray select _i) in (units group player) ) ) exitWith {
						[_soldier] call A3C_UNIT_INIT;
						_unitArray set [_i,_soldier];

					};

					if ( _i == (count _unitArray)  ) then {

						_unitArray pushback _soldier;
						_initArray pushback _soldier;

					};
				};
			};
		} foreach (units group player);
	} else {
		{
			_soldier = _x;
			if !(_soldier in (units group player)) then {
				_unitArray set [_forEachIndex,objnull];
				if (_soldier in A3C_HUD_UNITS) then { // can not work coz unit is not in _unitarray anymore
					[_soldier] call A3C_HUD_REMOVE_SELECTED;
				};
			};
		} foreach _unitArray;
	};
	*/
	A3C_UNITCOUNTER = (count (units group player));
	profileNamespace setvariable ["A3C_GROUPUNITS",_unitArray];
	{
		[_x] call A3C_UNIT_INIT;
	} foreach _initArray;
	//systemchat str A3C_MAP_CommandMode;
	[A3C_MAP_CommandMode] call A3C_UI_MAP_UFSB_ApplyMode; //-- refresh table if open
};


//-- PLAYER HAS SWITCHED GROUPS
A3C_Teamswitch = {
	A3C_PLAYERGROUP = group player;
	profileNamespace setvariable ["A3C_GROUPUNITS",(units group player)];
	{[_x] call A3C_UNIT_INIT} foreach (units group player);
	{_x setvariable ["A3C_FORMATION_INDEX", [_x] call A3C_GETUNITINDEX, true]} foreach units group player;

	player removeEventHandler ["KILLED",A3C_KILLED]; //-- just to be sure
	A3C_KILLED = player addEventHandler ["killed",{[_this select 0] spawn A3C_KILLED_EVH}];

	player removeEventHandler ["FIRED",A3C_FIRED]; //-- just to be sure
	A3C_FIRED = player addEventHandler ["FIRED",{_this spawn A3C_FIRED_EVH}];


	player removeEventHandler ["SlotItemChanged",A3C_SlotItemChanged_Handler]; //-- just to be sure
	A3C_SlotItemChanged_Handler = player addEventHandler ["SlotItemChanged",{_this spawn A3C_SlotItemChanged_HandlerFnc}];

	//if (player == leader group player) then {
//		[(units group player) - [player]] call A3C_GROUP_RESET;
	//};
};

KK_fnc_objectVarNames = {
	private "_names";
	_names = [];
	{
		if (missionNamespace getVariable _x isEqualTo _this) then {
			_names pushBack _x;
		};
	} forEach allVariables missionNamespace;
	_names
};



A3C_REFRESHING = false;
//-- RESET ALL GROUP SETTINGS

A3C_GROUP_RESET = {
	if (is3DEN) exitWith {};
	setGroupIconsVisible [false,false];
	private ["_units","_knowData","_recreateLogic"];
	private _a3c_dsp = if (!isNull (findDisplay 100020)) then {100020} else {100040};


	//////////////////////
	//-- EXTRAS FIRST: unflip all vehicles
	//////////////////////
	private _flipVehicles = [];
	{
		{
			if (!isNull objectParent _x) then {
				_vU = vectorUp (vehicle _x);
				_stable = (({(abs _x) > 0.5} count [(_vU select 0),(_vU select 1)] == 0) && (_vu select 2 > 0));
				if !(_stable) then {
					if !(vehicle _x isKindOf "AIR") then {
						_flipVehicles pushBackUnique (vehicle _x);
					};
				};
			};
		} foreach (units _x);
	} foreach ([(group player)] + A3C_HC_getAllGroups_Player_Current);
	{
		if (isTouchingGround _x) then {
			_x setPosASL (getPosASL _x);
			//systemchat '1';
			//_x setPos ( ((getposASL _x) select [0,2]) + [0]);
		};
	} foreach _flipVehicles;
	//////////////////////
	//////////////////////




	
	if !(player == leader group player) exitWith {};

	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	
	private _units = (units player) - [player];
	
	A3C_REFRESHING = true;
	_hud = shownHud;
	_hud set [0,true]; //-- fix for AIS etc hiding the main game's hood

	_groupInitial = group player;
	_gpID = groupID _groupInitial;
	private _groupVarnames = _groupInitial call KK_fnc_objectVarNames;
	//systemchat str _groupVarnames;

	//-- store all things that we know about as this will be reset when unjoining units
	_knowData = [];

	{
		if ((player knowsabout _x) > 0) then {
			_knowData pushback [_x,(player knowsabout _x)];
		};
	} foreach (allmissionObjects "ALL");





	_stayLeader = true; //if (player == (leader group player)) then {true} else {false}; //~~ assumption: entire fnc is only ever run on player group and exits if player is not leader. will always be true
	{player reveal [_x,4]} foreach units group player; //~~ why this? dying units somehow a problem
	_side = side player;
	
	_leader = leader _groupInitial;  //~~ !! given that we exit above if leader is not a player, this seems to be code residue. player will always be leader if this gets reached.

//	//-- leader is AI and within _units || player is not leader
//	if (_leader in _units) then {
//		_units = _units - [_leader];
//		_units pushback player;
//	};



//	_units2 = [];
	_groupTemporary = creategroup _side;
	
	{
		[vehicle _x,"LOCKED"] remoteExec ["setvehicleLock", vehicle _x];
		private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
		_x setvariable ["A3C_REFRESH_DATA",[_assignedTeam,(expecteddestination _x),(assignedvehicle _x),_x getVariable ["A3C_PLOT_TEMP",[]],_x getVariable ["A3C_PLOT",[]]],true];
		[_x] joinSilent _groupTemporary;
	} foreach _units;


	//-- Put Player back into the UNIT-1 slot
	if (_stayLeader) then {
		//if !(isMultiPlayer) then { //-- ~~ WHY NOT IN MP? Did it crash things??
			if !((player getvariable "A3C_FORMATION_INDEX") == 1) then {
				_groupNew = createGroup (side player);
				[player] joinSilent _groupNew;
				_groupNew setGroupIDGlobal [_gpID];
				deletegroup _groupInitial;
			};
		//};
	};


	_units joinSilent (group _leader); //-- (group _leader) is used as it could either be _groupNew or _groupInitial, depending on reshuffle occurrence
	deletegroup _groupTemporary;
	A3C_DISABLE_RADIAL = false;

	{
		_u = _x;
		_x assignTeam ((_x getvariable "A3C_REFRESH_DATA") select 0);
		_x setVariable ["A3C_ASSIGNEDTEAM",((_x getvariable "A3C_REFRESH_DATA") select 0)];

		switch (((_x getvariable "A3C_REFRESH_DATA") select 1) select 1) do {
			case ("LEADER PLANNED") : {
				if (_x == (driver (vehicle _x))) then {
					if !(_x getvariable ["A3C_HOLD",false]) then {
						[_x,(((_x getvariable "A3C_REFRESH_DATA") select 1) select 0)] call A3C_DOMOVE;
					};
				};
			};
			case ("DoNotPlan") : {
				if (_x == (driver (vehicle _x))) then {
					//if !(_x getvariable ["A3C_HOLD",false]) then {
						[_x,(position (vehicle _x))] call A3C_DOMOVE;
					//};
				};
			};
			case ("VEHICLE PLANNED") : {
				if (_x == (driver (vehicle _x))) then {
					[(vehicle _x),"LOCKED"] remoteExec ["setvehicleLock",(vehicle _x)];
					if !(_x getvariable ["A3C_HOLD",false]) then {
						[_x,(((_x getvariable "A3C_REFRESH_DATA") select 1) select 0)] call A3C_DOMOVE;
					};
					_x assignasdriver (vehicle _x);
					(vehicle _x) spawn {
						sleep 5;
						[_this,"UNLOCKED"] remoteExec ["setvehicleLock", _this];
					};
				};
			};
		};


		_x setdestination ((_x getvariable "A3C_REFRESH_DATA") select 1);
		if !(isnull ((_x getvariable "A3C_REFRESH_DATA") select 2)) then {
			if !(_x in ((_x getvariable "A3C_REFRESH_DATA") select 2)) then {
				_x assignAsCargo ((_x getvariable "A3C_REFRESH_DATA") select 2);
				[_x] allowGetIn true;
				[_x] ordergetin true;
				//if ( (_x == (driver (vehicle _x))) && !(isnull objectparent _x) ) then {
				//	player commandchat "ALARM";
				//};
			};
		};
		[_u] call MCSS_fnc_setVehicleVarname;
		//_x spawn {
		//	sleep 1;
		//	systemchat str ((_this getvariable "A3C_REFRESH_DATA") select 4);
		//	_this setVariable ["A3C_PLOT_TEMP",(_this getvariable "A3C_REFRESH_DATA") select 3,true];
		//	_this setVariable ["A3C_PLOT",(_this getvariable "A3C_REFRESH_DATA") select 4,true];
		//};
		//_x setVariable ["A3C_PLOT_TEMP",(_x getvariable "A3C_REFRESH_DATA") select 3,true];
		//_x setVariable ["A3C_PLOT",(_x getvariable "A3C_REFRESH_DATA") select 4,true];

	} foreach _units;
	{
		//if (isNull (_x getVariable [")) then {
			[_x] call A3C_UNIT_INIT;
		//};
		if (profileNameSpace getVariable "A3C_SKILL_VAR") then {_x setskill 1};
	} foreach (units group player);
	profileNamespace setvariable ["A3C_GROUPUNITS",(units group player)];
	

	{_x setvariable ["A3C_FORMATION_INDEX", [_x] call A3C_GETUNITINDEX, true];} foreach (units group player);
	if (_stayLeader) then {(group player) selectLeader player};
	for "_i" from 7025 to 7040 do {(findDisplay _a3c_dsp displayCtrl _i) ctrlShow false};
	if (A3C_MAP_CommandMode == "HC") then {
		if ((count A3C_HC_getAllGroups_Player_Current ) > 0) then {
		} else {
			A3C_MAP_CommandMode = "INF";
			["INF"] call A3C_UI_MAP_UFSB_ApplyMode;
		};
	};

	{
		player reveal [(_x select 0),(_x select 1)];
	} foreach _knowData;
	_units spawn {
		sleep 3;
		{
			[(vehicle _x),"UNLOCKED"] remoteExec ["setvehicleLock", (vehicle _x)];
		} foreach _this;
	};
	{
		_marker = _x;
		_delete = true;
		{
			_vari = _x;
			{
				_soldier = _x;
				_data = _soldier getvariable _vari;
				{
					if (_marker in (_x select 1)) then {
						_delete = false
					};
				} foreach _data;
		 	} foreach ((units group player) - [player]);
		} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
		if ({_marker in (_x select 2)} count A3C_ALL_POLYS > 0) then {_delete = false};
		if (_delete) then {
			deleteMarkerLocal _x;
		};
	} foreach A3C_MARKERS;

	

	
	//-- re-issue group varnames
	{
		call compile format ["%1 = group player",_x]
	} foreach _groupVarnames;

	A3C_UNITCOUNTER = count (units player);

	if (isMultiPlayer) then {
		{
			[_x,(_x getvariable "A3C_REFRESH_DATA") select 0] spawn {
				params ["_unit","_c"];
				sleep 0.5;
				_unit assignTeam _c;
				_unit setVariable ["A3C_ASSIGNEDTEAM",_c];
			};
		} foreach _units;
	}; //~~ this bit seems like a security residue from the rockapes mp-crashes??

	{
		{
			private _veh = (vehicle _x);
			private _vU = vectorUp _veh;
			private _stable = {(abs _x) > 0.5} count [(_vU select 0),(_vU select 1)] == 0;

			if !(_stable) exitWith {
				//_veh setPos (((position _veh) select [0,2]) + [0]);
				if (isTouchingGround _veh) then {
					_veh setPosASL (getPosASL _veh);
				};
			};
		} foreach (units _x);
	} foreach ([group player] +  A3C_HC_getAllGroups_Player_Current);
	if (player == driver vehicle player) then {
		[] spawn {
			sleep 1;
			player doFollow player;
			if (currentCommand player == "STOP") then {
				player doMove (position vehicle player); //-- what does this do again?
				player moveTo (position vehicle player);
			};
		};
	};

	[] call A3C_UI_FNC_ADD_KEYBINDS;
	[_a3c_dsp] call A3C_UI_MAP_TREE_LABEL; 

	if (behaviour player != "AWARE") then {
		player setBehaviour "AWARE";
	};
	if (combatMode player != "YELLOW") then {
		player setCombatMode "YELLOW";
	};

	//systemchat 'hey';
	
	//-- refresh map UI and HUD UI
	[] execVM "A3C_CORE\ui\mapOverlay\LEGACY\UI_DSP_MAP_drawMapUI.sqf";
	[] execVM "A3C_CORE\ui\HUD\A3C_fnc_drawHudUI.sqf";



	[] spawn {
		sleep 0.5;
		A3C_REFRESHING = false;
	};
};





//-- author note: move to A3C_UI_MAP_Main_init.sqf
A3C_GET_OPAC = {
	_return = _this select 0;
	_obj = _this select 1;
	_index = _this select 2;
	_return = _return select [0,3];
	_op = 1;
	if (visibleMap) then {
		if (isNull (findDisplay 100020)) then {
			_op = 0;
		};
	};

	if (_op == 0) then {
		if (difficulty <=1) then {
			_op = 1;
		};
	};

	_return pushback _op;
	//hintsilent str _return;
	_return

};





//----------------------------------  O T H E R  S H A R E D  F U C T I O N S   ---------------------------------------
//---------------------------------------------------------------------------------------------------------------------

A3C_DeleteGroup = {
	params ["_group"];

	private _unitsRaw = units _group;
	private _groupVehicleDrivers = _unitsRaw select {
		private _oP = objectParent _x;
		!isNull _oP && {_x == driver _oP}
	};
	private _groupVehicles = _groupVehicleDrivers apply {objectParent _x};
	{deleteVehicle _x} foreach (_unitsRaw + _groupVehicles);

	deleteGroup _group;

};

//-- Activate a GoCode
//-- Used by Radial and Tablet
A3C_ACTIVATEGOCODE = {
	_code = _this select 0;
	private _a3c_dsp = 100020;
	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	_ctrls = switch (_code) do {
		case ("A") : {[709100,709101]};
		case ("B") : {[709102,709103]};
		case ("C") : {[709104,709105]};
		case ("D") : {[709106,709107]};
	};
	call compile format
	[
		"
			[] spawn {
				A3C_GoCode_Activate_%1 = true;
				if (%2) then {
					publicVariable 'A3C_GoCode_Activate_%1';
				};
				sleep 2.1;
				A3C_GoCode_Activate_%1 = false;
				publicVariable 'A3C_GoCode_Activate_%1';
				if (%2) then {
					publicVariable 'A3C_GoCode_Activate_%1';
				};
			};
		",
		(parseText _code),
		{["A3C_Terminal", _x] call BIS_fnc_instring} count ((Items player) + (assignedItems player)) > 0
	];
	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach _ctrls;
	if (!isNil 'A3C_GOCODES_HC') then {
		//-- #TODO: find out why 'A3C_GOCODES_HC' is sometimes not defined anymore (overridden by server somehow where it's not defined? we are exiting if isDedicated above)
		A3C_GOCODES_HC = A3C_GOCODES_HC - [_code];
		publicVariable 'A3C_GOCODES_HC';
	};
	
	[] spawn {
		sleep 0.5;
		[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];
		sleep 2;
		[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];
	};
};

//////// -- Squad Level Infantry Movement Control (client)-- ///////
////////////////////////////////////////////////////////////////////


//-- Change group-formation according to input. Used by radial formation section
A3C_Shared_setFormation = {
	private _formation = _this select 0;
	private _groups= if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {[group player]} else {A3C_RD_UNITS};
	{
		_x setFormation _formation;
	} foreach _groups;

	showCommandingMenu "";
};





A3C_fnc_leaveServer = {
	{

		{
			_x spawn {
				private ["_veh"];
				_veh = (vehicle _this);
				_veh setdamage 1;
				sleep 10;
				deletevehicle _this;
				deletevehicle _veh;
			};
		} foreach (units _x);
	} foreach A3C_HC_DISBANDED;
};





A3C_fnc_getSideName = {
	params ["_sideNumber"];
	private _sideName = switch (_sideNumber) do {
		case 0 : {EAST};
		case 1 : {WEST};
		case 2 : {resistance};
		case 3 : {civilian};
		default {"UNKNOWN"};
	};
	_sideName
};

//-- get all HC-Groups (real, disbanded, custom HC)
A3C_HC_getAllGroups_Player = {
	private ["_hcArray","_configurationMode","_side","_addAll"];

	_side =  (getNumber (configfile >> "CfgFactionClasses" >> (faction player) >> "side"));
	_side = [_side] call BIS_fnc_sideType;
	_addAll = false;


	// _hcArray = A3C_HC_DISBANDED + ((hcAllgroups player) - A3C_HC_DISBANDED);
	_hcArray = A3C_HC_DISBANDED + ((hcAllgroups player) - A3C_HC_DISBANDED);


	if ({["A3C_Terminal", _x] call BIS_fnc_instring} count ((Items player) + (assignedItems player)) > 0) then {
		_addAll = true;
	};

	if (_addAll) then {
		
		// {
		// 	systemChat str [side _x,_side];
		// 	// if (side _x == _side) then {
		// 	if (side _x getFriend _side > 0.6) then {
		// 		_hcArray pushBackUnique _x;
		// 	};
		// } foreach A3C_MON_SERVER_checkGroups; //allGroups;
		_hcArray = A3C_MON_SERVER_checkGroups;
	};
	_hcArray = _hcArray select {
		!(_x getVariable ["A3C_HC_BLACKLIST",false]) &&
		{
			{alive _x} count units _x > 0 &&
			{
				!(captive leader _x )
			}
		}
	};
	if (side player != civilian) then { //-- only show civilian units if player is himself civilian (#Note: civilian usage of A3C is not really developed)
		_hcArray = _hcArray select {side _x != civilian};
	} else {
		_hcArray = _hcArray select {!(side _x in [EAST,WEST]) && {!(leader _x isKindOf "ANIMAL")}}; //-- only civilians and resistance are visible to civilian player
	};

	//-- bug with side uav's that might come up as civilian (For example CROCUS has this bug)
	private _civilianUAVsCaptive = allunitsUAV select {
		captive _x && {
			side _x == civilian && {
				private _uavOwner = (UAVControl _x) select 0;
				private _isAvailable = isNull _uavOwner || {_uavOwner == player};

				_isAvailable && {
					private _uavSideNumber = getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "side");
					private _uavSide = [_uavSideNumber] call A3C_fnc_getSideName;
					private _isFriendly = (side player) == _uavSide;
					_isFriendly 
				}
			};
		}
		
	};
	// hintSilent str _civilianUAVsCaptive;
	{
		_x setCaptive false;
	} foreach _civilianUAVsCaptive;

	_hcArray
};


//-- ui functions (client)




A3C_GET_UB_COLOR = {
	params ["_unit"];
	_hold = (_unit getvariable ["A3C_HOLD",false]);
	private _assignedTeam = if (player == cameraOn) then {assignedTeam _unit} else {_unit getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
	switch (_assignedTeam) do {
		case ("RED") : {
			if (_hold) then {
				_backCol = [[1,0.55,0.52,1],0.5] call A3C_UI_fnc_setOpacity;

			} else {
				_backCol = [A3C_UI_COLOR_RED,0.7] call A3C_UI_fnc_setOpacity;

			};
		};
		case ("GREEN") : {

			if (_hold) then {
				_backCol = [0.6,1,0.5,0.5];
			} else {
				_backCol = [0,1,0,0.5];
			};
		};
		case ("BLUE") : {
			if (_hold) then {
				_backCol = [0.5,0.67,0.98,0.5];
			} else {
				_backCol = [A3C_UI_COLOR_BLUE,0.5] call A3C_UI_fnc_setOpacity;
			};

		};
		case ("YELLOW") : {
			if (_hold) then {
				_backCol = [[0.98,0.95,0.63,1],0.5] call A3C_UI_fnc_setOpacity;

			} else {
				_backCol = [A3C_UI_COLOR_YELLOW,0.7] call A3C_UI_fnc_setOpacity;
			};


		};
		case ("MAIN") : {
			if (_hold) then {
				_backCol = [0.52,0.52,0.52,0.2];
			} else {
				_backCol = [0.5,0.5,0.5,0.7];
			};

		};
	};
	_backCol
};


A3C_RESETDIFFICULTY = {
	A3C_OPACITY = if (difficulty <=1) then {1} else {0};
	A3C_DIFFICULTY = difficulty;
	if (difficulty <= 1) then {
		{
			_x setmarkeralphaLocal 1;
		} foreach (A3C_MARKERS + A3C_HC_MARKERS);
	} else {
		{
			_x setmarkeralphaLocal A3C_OPACITY;
		} foreach (A3C_MARKERS + A3C_HC_MARKERS);
	};
};


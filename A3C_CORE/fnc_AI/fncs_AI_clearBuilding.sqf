profilenamespace setvariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT",profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]];
profilenamespace setvariable ["A3C_PROFILEVAR_BUILDINGS_CLEAR",profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_CLEAR", []]];

[] spawn {
	private _data = profilenamespace getvariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT",[]];
	{
		_bT = _x select 0;
		_pgs = _x select 1;
		private _exct = true;
		{
			if (_x select 0 == _bt) exitWith {
				_exct = false;
			};
		} foreach _data;
		if (_exct) then {
			_data pushBack _x;
		};
	} foreach A3C_DATA_bPosNoAccess;
	profilenamespace setvariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT",_data];
	//systemchat 'done';
};
	


//profilenamespace setvariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT",[]];
//profilenamespace setvariable ["A3C_PROFILEVAR_BUILDINGS_CLEAR",[]];
//profilenamespace setvariable ["A3C_PROFILEVAR_BUILDINGS",nil];

/*
[] spawn {
	
	_tickTime = diag_tickTime;
	_mapSize = (getnumber (configfile >> "CfgWorlds" >> worldName >> "mapSize"));
	_allBuildings = [_mapSize / 2,_mapSize / 2] nearObjects ["House", _mapSize * 1.5];
	waituntil {alive player};
	sleep 3;
	//{
	//	if (typeOf _x != "Land_i_Barracks_V2_F") then {
	//		_allBuildings = _allBuildings - [_x];
	//	};
	//	systemchat str _foreachindex;
	//} foreach _allBuildings;
	sleep 2;
	//systemchat str _allBuildings;
	{
		_house = _x;
		_houseType = typeOf _x;
		player commandchat str [_foreachindex,_houseType];
		private _add = true;
		{
			if ((_x select 2) >= 7&& {_x select 0 == _houseType}) exitWith {
				_add = false;
				//player sidechat str (_x select 2);
			};
		} foreach ((profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]) +  (profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_CLEAR", []]));
		
		
		if (_add) then {
			//systemchat 'go';
			_scr = [_x] spawn A3C_Control_BPoses;
			waitUntil {scriptDone _scr};
		};
		
		//sleep 5;
		//systemchat str _foreachindex;
		//player commandchat str [_foreachIndex,_houseType];
	} foreach _allBuildings;
	_newData = [];
	{
		_x params ["_buildingType","_problemPositions","_testedObjects"];
		{
			_p = _x;
			_count = {_x == _p} count _problemPositions;
			if (_count < (3 max _testedObjects)) then {
				_problemPositions = _problemPositions - [_p];
			};
			
		} foreach _problemPositions;
		_newData = [_buildingType,_problemPositions,_testedObjects];
	} foreach (profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT",[]]);
	profileNameSpace setVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT",_newData];
	
	systemchat str (diag_tickTime - _tickTime);
};
*/


A3C_Control_BPoses = { 
	params ["_building"];
	private _bpC = ([_building] call MCSS_fnc_countBPos);
	if (_bpc < 1) exitWith {
		(profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_CLEAR", []]) pushBackUnique [typeOf _building,nil,7];
	};
	private _houseType = typeOf _building;
	//if (_houseType == "Land_i_Barracks_V2_F") then {
	//	{_x setpos (position _building)} foreach units player;
	//};
	_building setVariable ["A3C_BPOS_NOACCESS",[]];
	_timer = diag_ticktime;
	_startPos = []; //position player; //_building buildingPos 0;
	_buildingPos = position _building;
	for "_i" from 20 to 60 step 5 do {
		for "_t" from 1 to 10  do {
			_tPos = ([_buildingPos,[0,_i]] call MCSS_fnc_getSafePos);
			if (count _tPos > 0) exitWith {
				_startPos = _tPos;
			};
		};
		if (count _startPos > 0) exitWith {};
	};
	if (count _startPos == 0) then {
		_startPos = _building buildingPos 0;
	};
	//player setpos _startPos;
	for "_i" from 1 to _bpc  do {
		player groupchat str ["CHECKING BPOS",_i];
		_pathAgent = calculatePath ["man","safe",_startPos,_building buildingPos _i];
		//systemchat str _pathAgent;
		_pathEH = _pathAgent addEventHandler 
		[
			"PathCalculated",
			{
				params ["_agent", "_path"];
				_pathData = _agent getVariable "A3C_PathEH";
				_pathData params ["_building","_bPosIndex","_pathEH"];
				
				_finalPos = [];
				if (count _path > 0) then {
					_finalPos = _path select ((count _path) - 1);
				};
				
				if (count _finalPos > 0) then {
					_bPosATL = _building buildingPos _bPosIndex;
					_hDif = abs (((ATLtoASL _bPosATL) select 2) - (_finalPos select 2));
					//systemchat str _hDif;
					if ( _hDif > 0.3   ) then {
						(_building getVariable "A3C_BPOS_NOACCESS") pushBack _bPosIndex; 
						//systemchat str _bPosIndex;
					};
				};
				_agent removeEventHandler ["PathCalculated",_pathEH];
				_agent setVariable ["A3C_PathEH",nil];
				deletevehicle _agent;
				//systemchat '2';
			}
		];
		_pathAgent setVariable ["A3C_PathEH",[_building,_i, _pathEH]];
		_timerSub = diag_ticktime;
		while {true} do {
			if (diag_ticktime - _timerSub > 2) exitWith {
				_pathAgent removeEventHandler ["PathCalculated",_pathEH];
				_pathAgent setVariable ["A3C_PathEH",nil];
				deletevehicle _pathAgent;
				(_building getVariable ["A3C_BPOS_NOACCESS",[]]) pushBack _i; 
			};
			if (isNull _pathAgent OR {typename (_pathAgent getVariable ["A3C_PathEH",objNull]) == "OBJECT"}) exitWith {};
			sleep 0.1;
		};

	};
	_prohibitedPoses = _building getVariable "A3C_BPOS_NOACCESS";
	if (count _prohibitedPoses > 0) then {
		_lapCount = 0;
		private _added = false;
		_return = [];
		{
			_entry = _x;
			if (_x select 0 == _houseType) exitWith {
				_added = true;
				{
					(_entry select 1) pushBack _x;
					//systemchat str _x;
				} foreach _prohibitedPoses;
				_entry set [2,(_entry select 2) + 1];
			};
		} foreach (profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]);
		if !(_added) then {
			_return = [_houseType,_prohibitedPoses,1];
			(profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]) pushBackUnique _return;
			//player commandChat "FIRST ADD";
		};
		
		
		//systemchat str _return;
		
		hint str (profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]);
	} else {
		if ({(_x select 0) == _houseType} count (profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]) == 0) then {
			(profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_CLEAR", []]) pushBackUnique [_houseType,nil,7];
		};
		
	};
	
	_building setVariable ["A3C_BPOS_NOACCESS",nil];
	
	//systemchat format ["done in %1 sec",diag_ticktime - _timer];
	//player commandchat str _return;
};



//-- DEV EXPERIMENT
A3C_CLEARING_PATH_BY_ROOMS = {
	params ["_building"];
	private _roomdata = [_building] call A3C_FULL_ROOM_ARRAY;

};

//-- DEV EXPERIMENT
A3C_BUILDINGPATH = {
	params ["_building","_mode"];
	//-- modes:
	// 0: returns complete path data in [_pbPosIndex,_bPosATL]
	// 1: returns path array of buildingPos-Indexes
	// 2: returns path array in ATL poses
	private _bposAmount = [_building] call MCSS_fnc_countBPos;
	private _bPosesCombo = [];
	private _pathComplete = [ [0,_building buildingPos 0] ];
	for "_i" from 1 to _bposAmount do {
		_bPosesCombo pushBack [_i,(_building buildingPos _i)];
	};
	_bPosesCombo = [_bPosesCombo,[],{(_x select 1) select 2},"ASCEND"] call BIS_fnc_sortBy; //-- sort poses by height
	private _sortedByLevel = [];
	private _highestATLpos = (_bPosesCombo select ((count _bPosesCombo) - 1)) select 1;
	private _maxATL = _highestATLpos select 2;
	private _splitArray = [];
	
	for "_i" from 0 to (ceil _maxATL) step 0.5 do {
		private _subArray = [];
		{
			_atlPos = _x select 1;
			_h = _atlPos select 2;
			_abs = abs (_h - _i);
			if (_abs <= 0.5) then {
				_subArray pushBack _x;
				_bPosesCombo = _bPosesCombo - [_x];
			};
		} foreach _bPosesCombo;
		if (count _subArray > 0) then {
			_splitArray pushBack _subArray;
		};
		
	};
	{
		_subArray = _x;
		while {count _subArray > 0} do {
			_refPos = (_pathComplete select ((count _pathComplete) - 1)) select 1;
			_subArray = [_subArray,[],{(_x select 1) distance2D _refPos},"ASCEND"] call BIS_fnc_sortBy; //-- sort poses by refpos 2d Distance
			_closest = _subArray select 0;
			_pathComplete pushBack _closest;
			_subArray deleteAt 0;
		};
	} foreach _splitArray;
	_pathByIndex = [];
	_pathByATL = [];
	{
		_pathByIndex pushBack (_x select 0);
		_pathByATL pushBack (_x select 1);
	} foreach _pathComplete;
	_return = switch (_mode) do {
		case (0) : {_pathComplete};
		case (1) : {_pathByIndex};
		case (2) : {_pathByATL};
	};
	_return
	
};


A3C_fnc_createRooms = {
	//--Creating Rooms
	params ["_building","_bpC","_roofSensitive"];
	private _bPosArray = [];
	private _rooms = [];
	
	
	for "_i" from 1 to _bpc do { //-- SKIP 0 BECAUSE IT'S ENTRY POINT
		private _bPos = ATLtoASL (_building buildingPos _i);
		_bPos set [2,(_bPos select 2) + 0.2]; //-- 1.5
		if (_roofSensitive OR ([ASLtoATL _bPos,_building] call A3C_fnc_INSIDE)) then {
			_bPosArray pushBackUnique [_i,_bPos];
		};
	};
	//copytoclipboard str _bPosArray;
	private _removePositions = [];
	private _buildingType = typeOf _building;
	{
		if (_x select 0 == _buildingType) exitWith {
			_removePositions = _x select 1;
			//player commandChat str _removePositions;

		};
	} foreach (profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]);
//	if  !(["ruin",typeOf _building] call BIS_fnc_instring) then {
//		if  (["barracks",typeOf _building] call BIS_fnc_instring) then {	
//			_removePositions = [1,3,17,34,35,36,37];
//		};
//		if  (["Big_02_V3",typeOf _building] call BIS_fnc_instring) then {	
//			_removePositions = [0,3];
//		};
//		if  (["Land_jbad_House6",typeOf _building] call BIS_fnc_instring) then {	
//			_removePositions = [0,1];
//		};
//	};
	
	{
		if (_x select 0 in _removePositions) then {
			_bPosArray = _bPosArray - [_x];
		};
	} foreach _bPosArray;

	//-- create rooms from positions that have LOS to each other
	{
		_bPosIndex = _x select 0;
		_bPosASL = _x select 1;
		_bPosHeight = _bPosASL select 2;
		if ({_bPosIndex in _x} count _rooms == 0) then { //-- problem: this way, a rsecond room could be created because of a corner. Not too bad but could be adressed. 
			_roomPoses = [_bPosIndex];
			{
				_refPosi = (_x select 1);
				_refHeight = _refPosi select 2;
				if (([_bPosHeight,_refHeight] call MCSS_fnc_FindDifference) < 1) then {
					_intersectsOBJS = lineIntersectsObjs [_bPosASL, _refPosi, objnull,objnull,false];
					if !(_building in _intersectsOBJS) then {
						//-- there's a direct LOS between positions
						//if ({(_x select 0) in _x} count _rooms == 0) then {
							_roomPoses pushBackUnique (_x select 0);
						//};
					};
				};
			} foreach _bPosArray;
			_rooms pushBackUnique _roomPoses;
		};
	} foreach _bPosArray;

	//-- sloppy solution to the problem that doors are not picked up by INTERSECTS. Therefore, we need to find bpos-Id's that are in multiple rooms and reOrganize them
	//-- step 1: bundle rooms with positoins in question
	{
		_id = _x select 0;
		if ({_id in _x} count _rooms > 1) then {
			//systemchat str _id;
			private _newArray = [];
			{
				if (_id in _x) then {
					{_newArray pushBackUnique _x} foreach _x;
					_rooms = _rooms - [_x];
				};
			} foreach _rooms;
			_rooms pushBack _newArray
		};
	} foreach _bPosArray;
	
	//-- step 2: reOrganize roomPositions by distance from building center (not perfect but solves some issues)
	//player commandchat str _rooms;
	{
		_posArray = _x;
		
		_sort = [_posArray,[],{(_building buildingPos _x) distance2D (position _building)},"DESCEND"] call BIS_fnc_sortBy;
		_rooms set [_foreachindex,_sort];
	} foreach _rooms;
			
	_newFloorsArray = +(_rooms); //-- to do: rename Variable
	_rooms = [];
	{
		//{
			_roomPoses = _x;
			_doorPoses = [_building,_roomPoses] call A3C_findRoomDoors;
			_rooms pushBack [_roomPoses,_doorPoses];
		//} foreach _x;
	} foreach _newFloorsArray;
	_rooms
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



MCSS_fnc_findClosestBpos = {
	//-- find closest building Position
	params ["_refPos","_building","_groundLevelOnly"]; //-- inputs: 0: positionATL, 1: enterable object  2: bool: ignore elevated positions
	private ["_closestBposATL","_distance"];
	_refObject = objnull;
	if (typeName _refPos == "OBJECT") then {
		_refObject = _refPos;
		_refPos = getposATL _refPos;
	};
	_closestBposATL = _building buildingPos 0;
	_closestBposID = 0;
	_distance = _refPos distance _closestBposATL; //500000; //-- random overly igh number to begin distance reference far away
	private _bpc = ([_building] call MCSS_fnc_countBPos);
	for "_i" from 0 to _bpC do {
		_checkPos = (_building buildingPos _i);
		_refDist = (_checkPos distance _refPos);
		//if (!_groundLevelOnly OR (_checkPos select 2 < 2) ) then {
			if !(!isNull _refObject && {(_refObject distance _checkPos < 2)}) then {
				if (_refDist < _distance) then {
					_distance = _refDist;
					_closestBposATL = (_building buildingPos _i);
					_closestBposID = _i;
				};
			};
		//};
	};
	[_closestBposID,_closestBposATL]
};




A3C_FULL_ROOM_ARRAY = {
	params ["_building"];
	private _return = [];
	private _rooms = [_building] call A3C_HouseData;

	{
		_doors = [_building,_x] call A3C_findRoomDoors;
		_return pushBack [_doors,_x];
	} foreach _rooms;
	_return
};



A3C_findRoomDoors = {
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
	_roomDoorsArray;
};

A3C_AI_Shared_action_CLEARBUILDING = {
	params ["_units","_building"];
	private ["_buddyArrays","_roomArrays"];
	//systemchat 'yo';
	if (typeName _building == "STRING" && {_building == "cursortarget"}) then {
		_building = cursortarget;
		
	};
	//systemchat str _this;
	
	
	private _bpc = ([_building] call MCSS_fnc_countBPos);
	private _targets = [(side (_units select 0)),(sizeOf (typeOf _building)),"ENEMY",(position _building),["MAN"]] call MCSS_fnc_NearEntities;
	private _doors = [_building] call A3C_DOORPOSITIONS;
	private _outerBuildingPositions = [_building,0] call MCSS_fnc_BBOX;
	


	{
		_u = _x;
		{
			//_u reveal [_x,1.4];
		} foreach _targets;
		if (_x getVariable ["A3C_CLEARING",false]) then {
			_units = _units - [_x];
		};
	} foreach _units;
	
	private _roofSensitive = false;
	
	{
		if (((getPosATL _x) select 2) > 7) then {
			if  (["barracks",typeOf _building] call BIS_fnc_instring) then {
				if  !(["ruin",typeOf _building] call BIS_fnc_instring) then {
					_roofSensitive = true;
				};	
			};

		};
	} foreach _targets;
	if  (["Land_jbad_House6",typeOf _building] call BIS_fnc_instring) then {
		_roofSensitive = true;	
	};
	
	
	_fnc_createBuddyTeams = {
		//-- bundle units into groups of 2
		params ["_assignedUnits"];
		private _returnArray = [];
		while {(count _assignedUnits) > 0} do {
			private _subArray = [];
			_subArray pushBack (_assignedUnits select 0);
			if (count _assignedUnits > 1) then {
				_subArray pushBack (_assignedUnits select 1);
			};
			_assignedUnits = _assignedUnits - _subArray;
			_returnArray pushBack _subArray;
		};
		_returnArray;
	};
	
	_fnc_assignRoomPoses = {
		//-- assign roomPoses to unitArray
		params ["_units","_building","_roomData","_radius"];
		private ["_roomID","_roomPosAmount","_roomPoses","_roomDoorPoses"];
		//player sidechat  STR _roomData ;
		_roomPoses = _roomData select 0;
		_doorPoses = _roomData select 1;
	//	_roomPoses = _roomPoses + [(_doorPoses select 0)]; // + _doorPoses; //-- add doorPoses too room array: purpose: if room has only one position, teambuddy will go to the door instead of falling behind ADVANTAGE: if room has no door, then nothing will be added
		//if (count _roomPoses == 1) then {
		//	_roomPoses pushBack (_doorPoses select 0); //(_roomPoses select 0);
		//};
		_roomID = +(_roomPoses select 0);
		_roomPosAmount = ((count _roomPoses) - 2) max 0;
//systemChat str _roomData;
		while {(count _roomPoses) > _roomPosAmount} do {
			{
				//~~ the last two building poses in room need an identical main-markername so that units will wait for one another!
				if ((count _roomPoses) == _roomPosAmount) exitWith {};

				_roomPosATL = if ((typeName (_roomPoses select 0)) == "SCALAR") then {_building buildingPos (_roomPoses select 0)} else {(_roomPoses select 0)};
//systemChat str [_x,((typeName (_roomPoses select 0)) == "SCALAR"),_roomPosATL];

				_data = _x getVariable ["A3C_PLOT",[]];
				_markername = format ["A3C_BUILDINGMARKER_%1_Room_%2",str _building,_roomID];
				_wp =
				[
						[_roomPosATL,_roomPosATL getPos [50,0]],
						[_markerName,"",""],
						["NONE",nil],
						["NONE",nil],
						["UP","AUTO"],
						[[0,false]],
						false,
						0,
						-1,
						25,
						-1,
						3 //-- radius
				];
				_data pushBack _wp;
				_x setvariable ["A3C_PLOT",_data,true];
				_roomPoses deleteAt 0;
			} foreach _units;
		};
	};

	if !(isDedicated) then { 
		_units = [_units,[],{vehicle _x distance2D (_building buildingPos 0)},"ASCEND"] call BIS_fnc_sortBy; //-- script gets stuck here!
		{_x setVariable ["A3C_PLOT",[],true]} foreach _units;
	};

	//-- create buddy Teams and array of rooms
	private _buddyArrays = [_units] call _fnc_createBuddyTeams;
	private _roomArrays = [_building,_bpC,_roofSensitive] call A3C_fnc_createRooms;

	//systemchat str _roomArrays;
	

	//(str _roomArrays) remoteExec ["systemchat",0];
	if ({player == leader group _x} count _units == count _units) then {
		[_units,true,false] call A3C_AI_Shared_cancelUnitPlot; //~~ ideally: _busyUnits only! || some issue with HC units not resetting A3C_PLOT
	} else {
		//"HC wp" remoteExec ["systemchat",0];
		{
			if (count (_x getvariable ["A3C_PLOT",[]]) > 0) then {
				_x setvariable ["A3C_ABORT_Data",[true,false],true];
			};
		} foreach _units;
		
		waitUntil {{count (_x getVariable ["A3C_PLOT",[]]) > 0} count _units == 0};
		//_unit setvariable ["A3C_ABORT_Data",[false,false],true];
		//_unit setvariable ["A3C_PLOT",[],true];
		//_unit setvariable ["A3C_PLOT_TEMP",[],true];
	};
	
	
	
	while {({(count(_x getvariable ["A3C_PLOT",[]])) > 0} count _units) > 0} do {sleep 0.1}; //~~ ideally: _clearingUnits

	sleep 0.5;
	
	_doorPoses = [_building] call A3C_DOORPOSITIONS;
	
	//-- add entry wp to each unit
	{
		if (_foreachIndex < (count _roomArrays) ) then {
			_entryPosition = _building buildingPos 0; //[getPosATL _x,_building,true] call MCSS_fnc_findClosestBpos;
			//systemchat str _entryPosition;
			_data = _x getVariable ["A3C_PLOT",[]];
			_wp =
			[
					[_entryPosition,_entryPosition getPos [50,0]],
					["","",""],
					["NONE",nil],
					["NONE",nil],
					["UP","AUTO"],
					[[0,false]],
					false,
					0,
					-1,
					25,
					-1,
					7
			];
			_data pushBack _wp;
			_x setvariable ["A3C_PLOT",_data,true];
		} else {
			if (count _outerBuildingPositions > 0) then {
				_edgePos = (_outerBuildingPositions select 0);
				_guardDir = [_building, _edgePos] call BIS_fnc_dirTo;
				_guardLookPos = [_edgePos,50,_guardDir] call BIS_fnc_relPos;
				[_x,_edgePos] remoteExec ["doMove",_x];
				[_x,_guardLookPos] remoteExec ["lookAt",_x];
				_outerBuildingPositions deleteAt 0;
			};
		};
	} foreach _units;
	//(str (_roomArrays)) remoteExec ["systemchat",0];
	
	_originalRooms = +(_roomArrays);
	{
		_leader = _x select 0;
		_roomArrays1 = +(_roomArrays);
		if ({([(_building buildingPos ((_x select 0) select 0)) select 2,(getPosATL _leader) select 2] call MCSS_fnc_FindDifference) < 1 } count _roomArrays1 > 0) then {
			{
				if (([(_building buildingPos ((_x select 0) select 0)) select 2,(getPosATL _leader) select 2] call MCSS_fnc_FindDifference) >= 1 ) then {
					_roomArrays1 = _roomArrays1 - [_x];
				};
			} foreach _roomArrays1;
		};
		_roomArrays1 = [_roomArrays1,[],{_test = if (count (_x select 1) > 0) then {((_x select 1) select 0)} else {_building buildingPos ((_x select 0) select 0)}; _test distance (_building buildingPos 0)},"ASCEND"] call BIS_fnc_sortBy;
		if (count _roomArrays1 > 0) then {
			_nextRoom = _roomArrays1 select 0;
			_roomArrays = _roomArrays - [_nextRoom];
			[_x,_building,_nextRoom,3] call _fnc_assignRoomPoses;
		};
	} foreach _buddyArrays;

	//(str [_units, _originalRooms]) remoteExec ["systemchat",0];
	//"7" remoteExec ["systemchat",0];
	//--execute assigned data
		
	//-- individual unit monitor
	{
		_wpData = (_x getvariable "A3C_PLOT");
		//player groupchat str (count _wpData);
		_x setVariable ["A3C_CLEARING",true,true];
		if (count _wpData > 0) then {
			if (_foreachIndex > 0) then {
				[_x,_units select (_forEachIndex -1)] execFSM "A3C_CORE\FSM\A3C_AI_CLEAR_SPEED.fsm";
				//[_x,_doors,_building] execFSM "A3C_CORE\FSM\A3C_AI_CLEAR.fsm";  
			};
			_scr = ([_x,_wpData] spawn A3C_AI_Shared_executeUnitPlot);


			///// --------------------------------------- /////
			///// ----------- P A R A L L E L ----------- /////
			///// ----------- UNIT BEHAVIOUR  ----------- /////
			///// --------------------------------------- /////
			[_x,_building,_units] spawn {
				params ["_unit","_building","_units","_bPosArray"];

				_resetDanger = if !(_unit in A3C_AutoCombatDisabledUnits) then {true} else {false};
				
				_pauseCounter = 0;
				
				while {_unit getVariable "A3C_CLEARING"} do {
					//_unit disableAI "AUTOCOMBAT";
					[_unit,"AUTOCOMBAT"] remoteExec ["disableAI",_unit];
					if (!alive _unit) exitWith {
						_unit setVariable ["A3C_CLEARING",false,true];
					};
					if (count ( lineIntersectsObjs [eyepos _unit, ((eyepos _unit select [0,2]) + [(eyepos _unit select 2) + 5]), objnull, _unit]) == 0) then {
						//_unit setUnitPos "UP";
						[_unit,"UP"] remoteExec ["setUnitPos",_unit];
					} else {
						//_unit setUnitPos "UP";
						[_unit,"UP"] remoteExec ["setUnitPos",_unit];
					};
					if ((_unit distance2D _building) < ((sizeOf (typeOf _building)) * 1.3)) then {
						// _unit forceSpeed 2;
					} else {
						//_unit forceSpeed -1;
					};
					_target = objNull;
					private _targets = [(side _unit),(sizeOf (typeOf _building)),"ENEMY",(position _building),["MAN"]] call MCSS_fnc_NearEntities;
					[_targets,[],{_x distance _unit},"ASCEND"] call BIS_fnc_sortBy;
					
					{
						_dif = [(getPosATL _unit) select 2,(getPosATL _x) select 2] call MCSS_fnc_FindDifference;
						if (_dif > 1.5) then {
							_targets = _targets - [_x];
						};
						if ({isPlayer _x} count units _x == 0) then {
							//_x setSkill 0.1;
							[_unit,0.1] remoteExec ["setSkill",_unit];
						};
					} foreach _targets;
					if (count _targets > 0) then {
						_target = _targets select 0; //-- '_target' is specifically the UNIT's target. not to be confused with '_t'
					};
					_doFire = false;
					{
						_t = _x;
						
						//if ([_unit,_x] call MCSS_fnc_LOS_SIMPLE) then {
						if !(_building in ((lineIntersectsWith [eyepos _unit,eyepos _t,_unit,_t,false]))) then {
							_doFire = true;
							_target = _x;
							A3C_ENGAGEDTARGETS pushBackUnique _target;
						} else {
							if !(_x in A3C_ENGAGEDTARGETS) then {
								//_unit forgetTarget _x;
								[_unit,_x] remoteExec ["forgetTarget",_unit];
							} else {
								if ({_u = _x; !(_building in ((lineIntersectsWith [eyepos _u,eyepos _t,_u,_t,false])))} count (_units - [_unit]) == 0) then {
									A3C_ENGAGEDTARGETS = A3C_ENGAGEDTARGETS - [_t];
								};
							};
						};
					} foreach _targets;
					if (!isNull _target) then {
						//_unit doTarget _target;
						[_unit,_target] remoteExec ["doTarget",_unit];
					};
					if (_doFire) then {
						//hintSilent format ["%1 fire at target",_unit];
						//_unit reveal [_target,4];
						//_unit doFire _target;
						[_unit,[_target,4]] remoteExec ["reveal",_unit];
						[_unit,_target] remoteExec ["doFire",_unit];
						sleep 2;
					};
					_targets = [(side _unit),(sizeOf (typeOf _building)),"ENEMY",(position _building),["MAN"]] call MCSS_fnc_NearEntities;
					if (speed _unit == 0) then {
						if !(_unit getVariable ["A3C_ClearingPause",false]) then {
							_pauseCounter = _pauseCounter + 0.1;
							if (_pauseCounter >= 30) then {
								_pauseCounter = 0;
								{
									_t = _x;
									if (_t distance (expectedDestination _unit select 0) < 1) then {
										{
											[_t,_x] remoteExec ["enableAI",_t];
										} foreach [ "MOVE","PATH"]; //-- unit stuck may have something to do with enemy unit blocking path
										{
											[_t,_x] remoteExec ["doMove",_t];
											[_t,_x] remoteExec ["moveTo",_t];

										} foreach [_building buildingPos 0];
									};
								} foreach _targets;
							};
						};
					};
					sleep 0.1;
				};
				//_unit setUnitPos "AUTO";
				[_unit,"AUTO"] remoteExec ["setUnitPos",_unit];
				//_unit forceSpeed -1;
				[_unit,-1] remoteExec ["forceSpeed",_unit];
				//-- loop over: unit is no longer clearing!
				//systemchat format ["%1 is done clearing building",_unit];
				if (_resetDanger) then {
					//_unit enableAI "AUTOCOMBAT";
					[_unit,"AUTOCOMBAT"] remoteExec ["enableAI",_unit];
				};
			};
		};
		sleep 2;
	} foreach _units;
	
	///// --------------------------------------- /////
	///// ----------- P A R A L L E L ----------- /////
	///// ----------- BUDDY WP DISTRO ----------- /////
	///// --------------------------------------- /////
	//-- buddyTeam monitor and room assigner
	[_units, _buddyArrays,_building,_roomArrays,_originalRooms,_fnc_assignRoomPoses] spawn {
		params ["_units","_buddyArrays","_building", "_roomArrays","_originalRooms","_fnc_assignRoomPoses"];
		private _group = group (_units select 0);
		private _currentWaypoint = currentWaypoint _group;
		private _waypointPos = +(waypointPosition [_group,_currentWaypoint]);
		private _fnc_breakFromOrders = {
			params ["_unit","_building"];
			private _bbox = [_building,0] call MCSS_fnc_BBOX;
			private _area = [((_bbox select 0) distance2d (_bbox select 1)) / 2,((_bbox select 1) distance2d (_bbox select 2)) / 2];
			private _expDest = (expectedDestination _unit) select 0;
			private _result = _expDest inArea [position _building, _area select 0, _area select 1, getDir _building, false ];
			IF (_result) then {
				//systemchat str _expDest;
				////systemchat format ["%1 break from Clearing",_unit]
			};
			_result
		};
		
		//(STR ((count _roomArrays > 0) OR ({(_x getVariable ["A3C_CLEARING",false])} count _units > 0))) remoteExec ["systemchat",0];
		
		//-- Q: Why would the script run without any roomarray entries left?
		//-- A: wait for units to complete orders, or waypoint will complete on executing last order

		

		while 
		{ 
			_cwp = currentWaypoint _group;
			(_cwp == _currentWaypoint && {(waypointPosition [_group,_cwp]) isEqualTo _waypointPos}) && 
			{
				(count _roomArrays > 0) OR 
				{
					{count (_x getVariable ["A3C_PLOT",[]]) > 0} count _units > 0
				}
			} 
		} do {  
			//"loop teams" remoteExec ["systemchat",0];
			{
				if (isnull _x OR !alive _x) then {
					A3C_ENGAGEDTARGETS = A3C_ENGAGEDTARGETS - [_x];
				};
			} foreach A3C_ENGAGEDTARGETS;
			{
				_team = _x;
				_teamIndex = _foreachINdex;
				_exit1 = false;
				{
					_exp = if (alive _x) then {(expectedDestination _x) select 1} else {""};
					private _c = !(alive _x) OR 
					{
						((isPlayer leader group _x) && {currentCommand _x == "STOP"}) OR 
						{
							((isPlayer leader group _x) && {["formation",_exp] call MCSS_fnc_isInString})
						}
					}; 
					if (_c) then { // OR ([_x,_building] call _fnc_breakFromOrders)     //--OR !([(expectedDestination _x) select 0,_building] call A3C_fnc_INSIDE)
						_exit1 = true;
						if (count (_x getVariable ["A3C_PLOT",[]]) > 0) then {
							_x setvariable ["A3C_ABORT_Data",[true,false],true]; 
						};
						systemchat 'error 1 clearb / or unit is dead';					
						//for "_i" from 0 to 3 do { //-- DEBUG HC Building Clearing with VR units 
						//	_x setObjectTexASture [_i, "#(rgb,8,8,3)color(1,0,0,1)"];
						//};
						//systemchat format ["%1 terminated script",_x];
						_x setVariable ["A3C_CLEARING",false,true];
						_team = _team - [_x];
						_buddyArrays set [_teamIndex, _team];
						if (!alive _x) then {
							_closestBpos = ([getposATL _x,_building,false] call MCSS_fnc_findClosestBpos) select 0;
							_closestRoomArray = [];
							{
								if (_closestBpos in _x) then {
									_closestRoomArray = _x;
								};
							} foreach _originalRooms;
							if (count _closestRoomArray > 0) then {
								_roomArrays pushBackUnique _closestRoomArray;
							};
						};
					};
				} foreach _team;
				if (_exit1) exitWith {
					//'exit1' remoteExec ["systemchat",0];
				};
				if ({alive _x} count _team == 0) then {
					_buddyArrays = _buddyArrays - [_team];
				} else {

					
					if ({count (_x getVariable ["A3C_PLOT",[]]) > 0} count _team == 0) then {
						if (count _roomArrays  > 0 ) then {
							//systemchat 'next';
							_leader = objNull;
							{
								if (alive _x) exitWith {
									_leader = _x;
								};
							} foreach _team;

							_roomArrays1 = +(_roomArrays);
							if ({([(_building buildingPos ((_x select 0) select 0)) select 2,(getPosATL _leader) select 2] call MCSS_fnc_FindDifference) < 1 } count _roomArrays1 > 0) then {
								{
									if (([(_building buildingPos ((_x select 0) select 0)) select 2,(getPosATL _leader) select 2] call MCSS_fnc_FindDifference) >= 1 ) then {
										_roomArrays1 = _roomArrays1 - [_x];
									};
								} foreach _roomArrays1;
							};
							//_roomArrays1 = [_roomArrays1,[],{_test = if (count (_x select 1) > 0) then {((_x select 1) select 0)} else {_building buildingPos ((_x select 0) select 0)}; _test distance (_building buildingPos 0)},"ASCEND"] call BIS_fnc_sortBy;
							_roomArrays1 = [_roomArrays1,[],{_test = if (count (_x select 1) > 0) then {((_x select 1) select 0)} else {_building buildingPos ((_x select 0) select 0)}; _test  distance _leader},"ASCEND"] call BIS_fnc_sortBy; //-- assign next room by closest door
							_nextRoom = _roomArrays1 select 0;
							if (!isNil '_nextRoom') then {
								_roomArrays = _roomArrays - [_nextRoom];
								//(str [_team, _nextRoom]) remoteExec ["systemchat",0];
								[_x,_building,_nextRoom,3] call _fnc_assignRoomPoses;
								//player commandchat "NEW RUN";
								sleep 0.1;
								
								{
									_scr = ([_x,(_x getvariable "A3C_PLOT")] spawn A3C_AI_Shared_executeUnitPlot);
								} foreach _team;
							};
						};
					};
				};	
			} foreach _buddyArrays;
			
			_exit = true;
			//player groupchat str (count _buddyArrays);
			{
				_team = _x select {alive _x};
				
				{
					if (count (_x getVariable ["A3C_PLOT",[]]) > 0) then { //_x getvariable ["A3C_unitIsOnMainRoute",false]
						
						_exit = false;
					} else {
					//	'exit2' remoteExec ["systemchat",0];
					};
					//player commandchat 
					//hintsilent str [_exit, (count (_x getVariable ["A3C_PLOT",[]]))];
				} foreach _team;
			} foreach _buddyArrays;
			if (_exit) exitWith {
				//'exit3' remoteExec ["systemchat",0];
			};
			sleep 1;
			//systemChat 'oioi';
			
		};

		//"WPSCRIPT COMPLETE" remoteExec ["systemchat",0];
		//systemchat "CLEARING COMPLETE";
		{
			{
				//player commandchat str (count (_x getVariable ["A3C_PLOT",false]));
				_x setVariable ["A3C_CLEARING",false,true];	
				_x setVariable ["A3C_PLOT",[],true];
			} foreach _x;
		} foreach _buddyArrays;
	};
};



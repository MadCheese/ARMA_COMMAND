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





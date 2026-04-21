

MCSS_fnc_relDirRange = {
	params ["_objectFrom","_objectTo","_range"];
	private _relDir = _objectFrom getRelDir _objectTo;
	private _return = _relDir < _range OR {_relDir > (360 - _range)};
	_return
};

MCSS_fnc_ShortHint = {
	private _str = _this;
	hint _str;
	sleep 2;
	hintSilent "";
};


/*
MCSS_fnc_ShortHint = {
	private _str = _this;
	_str remoteExec ["hintSilent",0];
	sleep 2;
	"" remoteExec ["hintSilent",0];
};
*/


MCSS_fnc_getCargoGroups = {
	params ["_group"];
	private _drivers = (units _group) select {_oP = objectParent _x; !isNull _oP && {_x == driver _oP} };
	private _cargoGroups = [];
	{
		private _vic = objectParent _x;
		{
			_refGroup = group _x;
			if (_refGroup != _group) then {
				_cargoGroups pushBackUnique _refGroup;
			};
		} foreach (crew _vic);
	} foreach _drivers;
	_cargoGroups
};


ttt = if (!isNil 'ttt') then {ttt} else {[]};

MCSS_fnc_getRealBoundingBox = {
	params ["_object"];
	private _objectDir = getDir _object;
	private _corners = [_object,0] call MCSS_fnc_BBOX;

	private _boxW = (_corners select 0) distance2D (_corners select 1);
	private _boxH = (_corners select 1) distance2D (_corners select 2);
	
	private _realCorners = [];
	private _objectASL = getPosASL _object;
	_t = time;
	{deleteVehicle _x} foreach ttt;
	RED_LINES = [];
	GREEN_LINES = [];
	{
		private _checkData = switch (_foreachIndex) do {
			case (0) : {[_objectDir,_objectDir + 90]};
			case (1) : {[_objectDir,_objectDir - 90]};
			case (2) : {[_objectDir + 180,_objectDir - 90]};
			case (3) : {[_objectDir + 180,_objectDir + 90]};
		};
		{_checkData set [_foreachIndex,[_x] call MCSS_fnc_CorrectDir]} foreach _checkData;

		_startPosition = _x;
		_lastPosition = +_startPosition;
		
		private _testPosition1 = [0,0,0];
		_checkData params ["_refDir1","_refDir2"];
		_i1 = 0;//
		//systemchat str ((_boxW * 0.2) / 0.1);
		_tHeight = (_object call BIS_fnc_objectHeight) * 0.3; //2;
		_checkW = 50; //(_boxW * 0.25);
		for "_i" from 0 to 50 step 0.1 do {
			_testPosition1 = _startPosition getPos [_i,_refDir1];
			_testPosition1 set [2,_tHeight];
			_testPosition2 = _testPosition1 getPos [_checkW,_refDir2];
			_testPosition2 set [2,_tHeight];
			_insObjects = lineIntersectsObjs [(ATLtoASL _testPosition1),(ATLtoASL _testPosition2)];
			//systemchat str (ATLtoASL _testPosition1);
			_i1 = _i;
			if (_object in _insObjects) exitWith {};
			GREEN_LINES pushBack [(ATLtoASL _testPosition1),(ATLtoASL _testPosition2)];
			_lastPosition = +_testPosition1;
		};
		
		
		
		_startPosition2 = +_testPosition1;
		_lastPosition1 = +_startPosition2;
		
		for "_i" from 0 to 50 step 0.1 do {
			_testPosition3 = _startPosition2 getPos [_i,_refDir2];
			_testPosition3 set [2,_tHeight];
			_testPosition4 = _testPosition3 getPos [0.1,_refDir2];
			_testPosition4 set [2,_tHeight];
			_insObjects = lineIntersectsObjs [(ATLtoASL _testPosition3),(ATLtoASL _testPosition4)];
			_i1 = _i;
			if (_object in _insObjects) exitWith {};
			RED_LINES pushBack [(ATLtoASL _testPosition3),(ATLtoASL _testPosition4)];
			_lastPosition1 = +_testPosition3;
		};
		
		if (_foreachIndex == 2) then {};
		
		
		_realCorners set [count _realCorners,_lastPosition1];
	} foreach _corners;
	_finalCorners = _realCorners;
	player groupchat str _finalCorners;
	//player setpos (_realCorners select 0);
	//_realCorners = [_realCorners,[],{_objectASL distance2D _x},"DESCEND"] call BIS_fnc_sortBy;
	//_finalDistance = (_realCorners select 0) distance2D _objectASL;
	//_finalDir = _objectASL  getDir (_realCorners select 0);
	/*
	_finalCorners = [];
	_testArray = _realCorners select [0,2];
	if (_objectASL distance2D (_testArray select 0) < _objectASL distance2D (_testArray select 1)) then {
		_dir = _objectASL getDir (_testArray select 0);
		_finalCorners = _finalCorners +
		[
			_objectASL getPos [_objectASL distance2D (_testArray select 0),_dir],
			_objectASL getPos [_objectASL distance2D (_testArray select 0),[_dir - 90] call MCSS_fnc_CorrectDir]
		];
	} else {
		_dir = _objectASL getDir (_testArray select 1);
		_finalCorners = _finalCorners +
		[
			_objectASL getPos [_objectASL distance2D (_testArray select 0),_dir],
			_objectASL getPos [_objectASL distance2D (_testArray select 0),[_dir + 90] call MCSS_fnc_CorrectDir]
		];
	};


	_testArray = _realCorners select [2,3];
	if (_objectASL distance2D (_testArray select 0) < _objectASL distance2D (_testArray select 1)) then {
		_dir = _objectASL getDir (_testArray select 0);
		_finalCorners = _finalCorners +
		[
			_objectASL getPos [_objectASL distance2D (_testArray select 0),_dir],
			_objectASL getPos [_objectASL distance2D (_testArray select 0),[_dir - 90] call MCSS_fnc_CorrectDir]
		];
	} else {
		_dir = _objectASL getDir (_testArray select 1);
		_finalCorners = _finalCorners +
		[
			_objectASL getPos [_objectASL distance2D (_testArray select 0),_dir],
			_objectASL getPos [_objectASL distance2D (_testArray select 0),[_dir + 90] call MCSS_fnc_CorrectDir]
		];
	};
	*/
	//for "_i" from 0 to 3 do {
	//	_refDir = [_finalDir + (_i * 90)] call MCSS_fnc_CorrectDir;
	//	_refPos = _objectASL getPos [_finalDistance,_refDir];
	//	_finalCorners set [count _finalCorners,_refPos];
	//};

	{
		_x set [2,0];
		_v = 'Sign_Sphere10cm_F' createVehicleLocal _x;
		_v enableSimulation false;
		_v setpos _x;
		ttt pushback _v;
	} foreach _finalCorners;
	
	systemchat str [time - _t, _finalCorners];
};



MCSS_fnc_getMainRotorSelections = {
	params ["_vehicle"];
	private _selections = selectionNames _vehicle;
	private _filteredSelections = [];
	{
		_selectionName = toLower _x;
		if !("\" in _selectionName) then {
			if ("rotor" in _selectionName) then {
				if ("main" in _selectionName) then {
					if ({_x in _selectionName} count ["static","blur","damage","bend"] == 0) then {
						_filteredSelections set [count _filteredSelections,_selectionName];
					};
				};
			};
		};
		if ("vrtule" in _selectionName) then {
			if ("velka" in _selectionName) then {
				if ({_x in _selectionName} count ["static","blur","damage","bend"] == 0) then {
					_filteredSelections set [count _filteredSelections,_selectionName];
				};
			};
		};
	} foreach _selections;
	_filteredSelections
};



MCSS_fnc_isInBoundingBox = {
	private["_unit1","_object","_type","_relPos","_boundingBox","_min","_max","_myX","_myY","_myZ","_inside"];

	_unit1 = _this select 0;
	_object = _this select 0;

	_type = typeOf _object;
	_relPos = _object worldToModel (getPosATL _unit1);
	_boundingBox = boundingBox _object;

	_min = _boundingBox select 0;
	_max = _boundingBox select 1;

	_myX = _relPos select 0;
	_myY = _relPos select 1;
	_myZ = _relPos select 2;

	 _inside = false;

	if ((_myX > (_min select 0)) and (_myX < (_max select 0))) then {
		if ((_myY > (_min select 1)) and (_myY < (_max select 1))) then {
			if ((_myZ > (_min select 2)) and (_myZ < (_max select 2))) then {
				_inside = true;
			};
		};
	};
	_inside
};

//-- convert degree to vectorDir
MCSS_fnc_DegreeToVector = {
	params ["_degree"];
	_return =
	[
		sin _degree,
		cos _degree,
		0
	];
	_return
};

MCSS_fnc_getClosestReference = {
	params ["_value","_refArray"];
	_return = _refArray select 0;
	_closestAbs = 1e39;
	{
		_abs = abs (_value - _x);
		if (_abs < _closestAbs) then {
			_closestAbs = _abs;
			_return = _x;
		};
	} foreach _refArray;
	_return
};

//-- reverse the order of an array (SINCE REVERSE COMMAND SEEMS BROKEN)
MCSS_fnc_reverseArray = {
	private _inputArray = _this;
	private _return = [];
	while {count _inputArray > 0} do {
		private _entry = _inputArray select (count _inputArray - 1);
		_return pushBack _entry;
		_inputArray = _inputArray - [_entry];
	};
	_return
};

//-- get the array index of an array's entry
MCSS_fnc_GetArrayIndex = {
	params ["_tested","_compared"];
	private ["_return","_tested","_compared","_tN"];
	_return = -1;
	{
		if (_x isEqualTo _tested) exitWith {_return = _foreachindex};
	} foreach _compared;
	_return
};

//-- find out if a unit is in copilot seat

MCSS_fnc_isUnitCopilot = {

	private _veh = vehicle _this;
	if (_veh == _this) exitWith {false};

	private [ "_trts", "_return", "_trt"];

	private _trts = configFile >> "CfgVehicles" >> typeOf (vehicle _this) >> "turrets";

	private _return = false;

	for "_i" from 0 to (count _trts - 1) do {
		private _trt = _trts select _i;
		if(getNumber(_trt >> "iscopilot") == 1) exitWith {
			_return = (_veh turretUnit [_i] == _this);
		};
	};

	_return
};


//-- Function to find the absolute difference between two Scalar values
MCSS_fnc_FindDifference = {
	// ~ essentially the same as: abs(x)??
	_a = _this select 0;
	_b = _this select 1;
	_difference = _a - _b;
	if (_difference < 0) then {_difference = (_difference * -1)};
	_difference
};

MCSS_fnc_findOverwatchNear = {
	//~~ idea: optional parameter: polygon. if polygon is given, check for lineIntersectSurfaces and check if it is in poly
	params ["_input", "_targetPos"];
	private ["_unit", "_targetPos","_pos","_return","_posArray","_addPos"];
	if (typeName _input =="OBJECT") then {_input = position _input};

	_return = _pos;
	_posArray = [];
	_addPos = [];
	for "_i" from 1 to 300 do {
		_addPos = [_input,0,100,2,0,50,0,[],[]] call BIS_Fnc_findSafePos;
		_addPos pushback 0;
		if ({_x distance _addPos < 5} count _posArray == 0) then {
			_posArray pushback _addPos;
		};
	};

	_posArray = [_posArray,[],{_x distance2D _input},"ASCEND"] call BIS_fnc_sortBy;
	{
		private ["_refPos"];
		_refPos = +(_x); _refPos set [2, (_refPos select 2) + 1];
		if ([(ATLtoASL _refPos),(ATLtoASL _targetPos)] call MCSS_fnc_LOS_SIMPLE) exitwith {
			_return = _x;
		};

	} foreach _posArray;
	_return;
};


MCSS_fnc_countVehicleCargoSeats = {
	params ["_vehicle"];
	//private _vehicleType = if (typeName _vehicle == "STRING") then {_vehicle} else {typeOf _vehicle};
	private _vehicleType = typeOf _vehicle;
	private _count = 0;
	_allCrewCount = [_vehicleType,true] call BIS_fnc_crewCount;
	_allTurretCount = [_vehicleType,false] call BIS_fnc_crewCount;
	_allCrewCount - _allTurretCount
};

//-- function to get bounding box of objects
MCSS_fnc_BBOX = {
	private ["_objct","_bbox","_arr"];
	_objct = _this select 0;
	_mode = if (count _this > 1) then {_this select 1} else {0};
	_bbox = 0 boundingboxreal _objct;
	_arr = [];
	_FL = _objct modeltoworld (_bbox select 0); _FL = [(_FL select 0),(_FL select 1),0];
	_FR = _objct modeltoworld [((_bbox select 1) select 0),((_bbox select 0) select 1),0]; _FR = [(_FR select 0),(_FR select 1),0];
	_BR = _objct modeltoworld [((_bbox select 1) select 0),((_bbox select 1) select 1),0]; _BR = [(_BR select 0),(_BR select 1),0];
	_BL = _objct modeltoworld [((_bbox select 0) select 0),((_bbox select 1) select 1),0]; _BL = [(_BL select 0),(_BL select 1),0];

	_ML = [];
	_MF = [];
	_MR = [];
	_MB = [];
	if (_mode == 1) then {
		_w = ((_FL distance2d _FR) / 2);
		_h = ((_FL distance2d _BL) / 2);
		_dirW = ([_FL,_FR] call BIS_fnc_DirTo);
		_dirH = ([_FL,_BL] call BIS_fnc_DirTo);
		_MF = [_FL,_w,_dirW] call BIS_fnc_RelPos;
		_MB = [_BL,_w,_dirW] call BIS_fnc_RelPos;
		_ML = [_FL,_h,_dirH] call BIS_fnc_RelPos;
		_MR = [_FR,_h,_dirH] call BIS_fnc_RelPos;
		_arr = [_FL,_MF,_FR,_MR,_BR,_MB,_BL,_ML];
	} else {
		_arr = [_FL,_FR,_BR,_BL];
	};
	_arr
};

//-- Function to get the amount of available building position
MCSS_fnc_countBPos = {
	_house = _this select 0;
	_effpos = [0,0,0];
	_m = 0;
	while { format ["%1", (_house) buildingPos _m] != "[0,0,0]" } do {_m=_m+1};
	_m = _m-1;
	_m;
};

// Find Near Entities that are Friendly or Enemy  || [WEST,100,"FRIENDLY",(position player)] call MCSS_fncNearEntities;
MCSS_fnc_nearEntities = {
	private ["_input","_side","_Entities","_distance","_return","_mode"];
	_input = _this select 0;
	_distance = _this select 1;
	_mode = _this select 2;
	_pos = if (count _this > 3) then {_this select 3} else {position _input};
	_side = if (typename _input == "OBJECT") then {side _input} else {_input};
	_filter = if (count _this > 4) then {_this select 4} else {["MAN","CAR","SHIP","TANK","AIR"]};
	_entities = [];
	{
		if (_mode == "FRIENDLY") then {
			if ( ((side _x) getFriend _side) >= 0.6) then {
				_entities pushback _x;
			};
		} else {
			if !(side _x == civilian) then {
				if ( ((side _x) getFriend _side) < 0.6) then {
					_entities pushback _x;
				};
			};
		};
	} foreach (_pos nearEntities [_filter,_distance]);
	_entities
};

//-- find Near Enemies (can be replaced by above??)
MCSS_fnc_NearEnemies = {
	private ["_unit","_mode","_result"];
	_unit = _this select 0;
	_mode = if ((count _this) > 1) then {_this select 1} else {"ARRAY"};
	_result = [];
	{
		if ( ((side _x) getFriend (side player)) < 0.6) then {
			if !([_x,_unit] call MCSS_fnc_LOS_SIMPLE) then {
				_result pushback _x;
			};
		};
	} foreach ((position _unit) nearEntities [["MAN","CAR","SHIP","TANK","AIR"],200]);

	if (_mode == "COUNT") then {_result = (count _result)};
	_result
};



//-- finds the height of aimPosition (when looking at building) CURRENTLY NOT USED, REPLACED BY BETTER lineIntersectsSurfaces stuff
MCSS_fnc_HeightAtTarget = {
	_unit = _this select 0;
	_building = _this select 1;
	_buildingASL = getposASL _building;
	_buildingATL = getposATL _building;
	_buildingHeightASL = _buildingASL select 2;
	_buildingHeightATL = _buildingATL select 2;
	_unitASL =   if ({unitIsUAV _x} count crew _unit == 0) then {eyepos _unit} else {getPosASL _unit};        //eyepos _unit;
	_unitHeightASL = (_unitASL select 2);
	_dist2d = (_buildingASL select [0,2]) distance (_unitASL select [0,2]);
	_alpha = atan ((_unit weapondirection (currentweapon _unit) ) select 2) ;
	_lookingheight = _dist2d * (tan _alpha);
	_differenceHeight = _unitHeightASL - _buildingHeightASL;
	_heightAtBuilding = (_unitHeightASL - _buildingHeightASL) + _lookingheight;

	if (unitIsUAV cameraOn) then {
		_LIntSf = lineintersectsSurfaces [ATLtoASL (positionCameraToWorld [0,0,0]), agltoasl (screenToWorld [0.5,0.5]), cameraOn, objNull, true, 1, "GEOM", "FIRE"];
		_heightAtBuilding = (ASLtoATL ((_LIntSf select 0) select 0)) select 2;
	};
	//hintSilent str _heightAtBuilding;
	_heightAtBuilding
};


MCSS_fnc_GetOut = {
	params ["_unit"];
	private _vehicle = vehicle _unit;
	//systemchat str _unit;
	//-- dismount unit
	//-- why the loop you ask? because something sucks the unit back into the vehicle and leaves it there with no assigned vehicleRole. And we don't like that. So - loop.
	//[_unit] spawn {
	//	params ["_unit"];
	//	for "_i" from 1 to 40 do {
	//		[_unit,vehicle _unit] remoteExec ["leaveVehicle",_unit];
	//		_unit remoteExec ["unassignVehicle",_unit];
	//		//_unit remoteExec ["doGetout",_unit];
	//		
	//		//-- leaveVehicle can not be used because it unassigns all group members from vehicle and leaves it in them with no assigned roles
	//		//_unit action ["eject",vehicle _unit];
	//		waituntil {isNull objectParent _unit};
	//		sleep 0.1;
	//	};
	//};
	while {alive _unit} do {
		if (isNull _unit) exitwith {_abort = true};
		if (!isNull objectParent _unit) then {
			[_unit,vehicle _unit] remoteExec ["leaveVehicle",_unit];
			_unit remoteExec ["unassignVehicle",0];
			_unit remoteExec ["doGetout",_unit];
			//systemChat str time;
			//_unit action ["eject",vehicle _unit];
		};
		if (isNull objectParent _unit) exitwith {};
		sleep 0.1;
	};
	sleep 2;
	if ((_unit getVariable ["A3C_PLOT",[]]) isEqualTo []) then {
		[_unit,leader (group _unit)] remoteExec ["doFollow",_unit];
	};
	
	//doStop _unit;
	//~~ instead of doStop, pass additional (optional) position into this func with a destination pos )for 360 security)
	_unit setVariable ["A3C_PAUSE_PLAN",false,false];
};//_x doFollow player;


//-- Get position that meets saftey requirements
MCSS_fnc_getSafePos = {
	scopeName "main";
	private ["_pos", "_minDist", "_maxDist", "_objDist", "_waterMode", "_maxGradient", "_shoreMode", "_defaultPos", "_blacklist","_newPos", "_posX", "_posY","_attempts"];
	_countThis	= count _this;
	_pos		= (_this select 0);
	_range	=  _this select 1;
	_waterMode	= 0;
	_maxGradient = 0.1;
	_minDist = -1;
	_maxDist = -1;
	switch (typeName _range) do {
		case (typeName []) : {
			_minDist = _range select 0;
			_maxDist = _range select 1;
		};
		case (typeName 0) : {
			_minDist = 0;
			_maxDist = _range;
		};
		default {
			_minDist = 0;
			_maxDist = getNumber(configFile >> "CfgWorlds" >> worldName >> "safePositionRadius");
		};
	};
	_newPos = [];
	_posX = _pos select 0;
	_posY = _pos select 1;
	_attempts = 0;
	_exit = false;
	while {_attempts < 1000} do {
		private ["_newX", "_newY", "_testPos"];
		_newX = _posX + (_maxDist - (random (_maxDist * 2)));
		_newY = _posY + (_maxDist - (random (_maxDist * 2)));
		if (_attempts == 0) then {
			_newX = _posX;
			_newY = _posY;
		};
		_testPos = [_newX, _newY];
		if ( (_pos distance _testPos) >= _minDist) then {
			if ! ( count(_testPos isFlatEmpty [10,1,0.1,20,0,false]) == 0 ) then {
				_newPos = _testPos;
				_exit = true;
			};
		};
		if (_exit) exitwith {};
		_attempts = _attempts + 1;
	};
	_exit = false;
	if !( (count _newPos) == 0 ) then {
		_newPos = [(_newPos select 0),(_newPos select 1),0];
	};
	_newPos
};


//-- Checks if a string is included in another string
//-- "AID" is included in "fistAID"
MCSS_fnc_isInString = {
	private _checked = (_this select 0) splitstring "";
	private _compared = (_this select 1) splitstring "";
	private _return = false;
	if ((count _checked) > (count _compared)) exitWith {_return};
	{
		private ["_exit"];
		_exit = false;
		if (_x == (_checked select 0)) then {
			for "_i" from 1 to ((count _checked) min ((count _compared) - _forEachIndex)) do {
				if !((_checked select _i) == (_compared select (_forEachIndex + _i))) exitwith {_return = false};
				if (_i == (count _checked)) then {
					_exit = true;
					_return = true;
				};
			};
		};
		if (_exit) exitwith {};
	} foreach _compared;
	_return
};

//-- Get String with combinations of UNITINDEX and Nameparts, alternatively return name of vehicle
MCSS_fnc_NAMESTRING = {
	private ["_unit"];
	_unit = _this select 0;

	if (isNil '_unit' OR {isNull _unit}) exitWith {'N/A'};

	//_disableVeh = if (count _this > 2) then {_this select 2} else {false};
	_disableComm = if (count _this > 3) then {_this select 3} else {false};
	_namearray = [(name _unit),"' "] call BIS_fnc_splitString;

	

	private _return = "";
	_formationIndex = _unit getvariable "A3C_FORMATION_INDEX";

	if (isNil '_formationIndex') exitWith {'N/A'};
	
	if (count _nameArray > 1) then {
		{
			if (_forEachIndex > 0) then {_return = _return + _x;};
		} foreach _nameArray;
	} else {
		_return = (_nameArray select 0);
	};

	//if !(_disableVeh) then {
	//	if !( _unit == (vehicle _unit) ) then {
	//		if (_unit == (driver (vehicle _unit)) ) then {
	//			_namearray = getText (configFile >> "CfgVehicles" >> (typeOf (vehicle _unit)) >> "displayName");
	//			_return = ([_namearray,"' "] call BIS_fnc_splitString) select 0;
	//		};
	//	};
	//};

	if (isNil'_return') exitWith {'NAMEFNC FAILED'};

	
	if (isPlayer _unit) then {
		_return = format ["%1: %2 (Player)",_formationIndex,(name _unit)];
	} else {
		if ((count _this) == 1) then {

			_return = (str _formationIndex) + ": " + _return;
			if (getResolution select 5 == 0.7) then {
				if (count _return >= 11) then {
					_return = (_return splitstring "") select [0,7];
					_return = (_return joinstring "") + "...";

				};
			};
		} else {
			if !(_disableComm) then {
				_return = _return + ",";
			} else {
				//_return = _return + " ";
			};
		};
	};
	
	//-- #WIP #ISSUE : somehow _return might not be assigned. Insert bughunt-helper:
	_return = if (isNil'_return') then {'NAMEFNC FAILED'} else {_return};
	
	_return
};

//-- Always get correct dir with values >360 or <0
MCSS_fnc_CorrectDir = {
	private ["_dir"];
	_dir = _this select 0;
	while {_dir >= 360} do {_dir = (_dir - 360)};
	while {_dir < 0} do {_dir = (_dir + 360)};
	_dir
};

//-- Shuffle Array Left or Right
//-- [1,2,3] -> LEFT: [2,3,1] -> Right: [3,2,1]
MCSS_fnc_ShuffleArray = {
	_data = _this select 0;
	_mode = _this select 1;
	_switchVal = _data select 0;
	_newData = [];
	switch (_mode) do {
		case ("LEFT") : {
			_data = _data - [_switchVal];
			_data pushback _switchVal;
		};
		case ("RIGHT") : {
			_switchVal = (_data select ((count _data) -1));
			_data =  _data - [_switchVal];
			_newData pushback _switchVal;
			{
				_newData pushback _x;
			} foreach _data;
			_data = _newData;
			_newData = 0;
		};
	};
	_data
};

//-- get index of array-entry

A3C_OCC_BPOSES = [];


MCSS_fnc_get_buildingPoses_roof = {
	params ["_building"];
	private _bpc = [_building] call MCSS_fnc_countBPos;
	private _roofPoses = [];
	for "_i" from 0 to _bpc do {
		_bPosATL = _building buildingPos _i;
		_bPosASL = ATLtoASL _bPosATL;
		_bPosASL set [2,(_bPosASL select 2) + 0.5];
		private _refPos = +(_bPosASL);
		_refPos set [2,(_refPos select 2) + 20];
		_ins = lineIntersectsSurfaces
		[
			_refPos,
			_bPosASL,
			objNull,
			objNull,
			true,
			1,
			"GEOM",
			"NONE"
		];
		//hintSilent str _ins;
		if (count _ins == 0) then {
			_roofPoses pushBack [_i,_bPosATL];
		};
	};
	_roofPoses
};


MCSS_fnc_getClosestBPos = {
	//-- mode:
	//-- 0: ignore positions with intersects compared to _aslPos
	//-- 1: include positions with intersects compared to _aslPos
	params ["_unit","_bld","_mode"];
	private ["_aslPos"];
	_aslPos = +(getPosASL _unit);
	_aslPos set [2, (_aslPos select 2) + 0.1];
	_bpc = ([_bld] call MCSS_fnc_countBPos);
	if (_bpc == 0) exitwith {[]};
	_poses = [];
	for "_i" from 0 to _bpc do {
		_poses pushback (_bld buildingpos _i);
	};
	{
		_security = false;
		if (abs ((getPosATL _unit select 2) - (_x select 2)) < 5) then {
			//-- make sure there's no gap in height that we can not handle
			if (_x in A3C_OCC_BPOSES) then {//-- security: only skip occupied positions if
				_poses = _poses - [_x];
			};
		};

	} foreach _poses;

	if (_mode == 0) then {
		{
			if (count (lineIntersectsObjs [(ATLToASL _x),_aslPos, _unit, objnull, false]) > 0) then {
				_poses = _poses - [_x];
			};
			if (count (lineIntersectsObjs [(ATLToASL _x),(_aslPos select [0,2]) + [(_aslPos select 2) + 15], _unit, objnull, false]) > 0) then {
				_poses = _poses - [_x];
			};
		} foreach _poses;
	};
	if (count _poses == 0) then {
		//-- security: there is no more unoccupied positions for the AI to chose from. In this case, we accept the units stacking  :)
		if (count A3C_OCC_BPOSES > 0) then {
			_poses = A3C_OCC_BPOSES;
		};
	};
	if (count _poses == 0) exitwith {[]};
	_poses = [_poses,[],{_x distance _unit},"ASCEND"] call BIS_fnc_sortBy;
	_poses select 0
};

//------------------------------  L I N E  O F  S I G H T - R E L A T E D  F U N C T I O N S   ----------------------------------
//-------------------------------------------------------------------------------------------------------------------------------

//-- If unit is not in vehicle, eyepos is used. otherwise, a position 0.4m above the vehicle's maxHeight is used
MCSS_fnc_Switch_Eyepos = {
	_unit = _this select 0;
	_result = getposASL (vehicle _unit);
	_bb = [];
	if (_unit == (vehicle _unit)) then {
		_result = eyepos _unit;
	} else {
		_bb = boundingboxreal (vehicle _unit);
		_result set [2,((_result select 2) + (((_bb select 1) select 2) + 1))];
	};
	if (unitIsUAV cameraOn OR (_unit == player)) then {
		_result = ATLtoASL (positionCameraToWorld [0,0,0]);
	};
	_result
};

MCSS_fnc_LOS_Vehicle = {
	//-- currently only gunner (b) turret LOS to a ATL-POSITION (a)
	params ["_a","_b"];
	private ["_rangeVal","_rangeLeft","_return","_vehicleDir","_turretDeg","_aimingDir","_aPos","_bPos","_aPos1","_BposL","_BPosT","_dirTo","_inRange"];
	_rangeVal = if (count _this > 2) then {_this select 2} else {13};
	_rangeLeft = 360 - _rangeVal;
	_return = false;
	_apos = _a; _apos set [2,0];
	_bpos = getposASL vehicle _b;

	_BposL = [];
	_BposT = [];

	_vehicleDir = GetDir (vehicle _b);
	_turretDeg = Deg ((vehicle _b) AnimationPhase "mainturret");
	_aimingDir = _vehicleDir - _turretDeg;
	if (_aimingDir > 360) then { _aimingDir = _aimingDir - 360};

	_bposL = _bpos;
	_bposT = [(_bpos select 0),(_bpos select 1),(_bpos select 2) + 1.4];

	_dirTo = [_bpos,_apos] call BIS_fnc_dirTo;
	if (_dirto < 0) then {_dirto = _dirto + 360;};
	_abs = abs(_dirTo - _aimingDir);
	//_inRange = (_abs <= 13) OR (_abs >= 347);
	_inRange = (_abs <= _rangeVal) OR (_abs >= _rangeLeft);
	_inRange
};

MCSS_fnc_weaponHasGL = {
	params ["_wpn"];
	private ["_return","_mzls","_mgs"];
	_mzls = (getarray (configfile >> "CfgWeapons" >> _wpn >> "muzzles"));
	{
		private _muzzle = _x; 
		{_x in (toLower _muzzle)} count ["gl","gp","ubs","203","vhs_bg"] > 0 //
	} count _mzls > 0
};




//-- Main fnc (created by SaOk)
MCSS_fnc_LOS_INF = {
	private ["_a","_b","_dirTo","_eyeD","_eyePb","_eyePa","_eyeDV","_abs","_boolean","_range"];
	//object
	_a = (vehicle (_this select 0));
	//observer
	_b = _this select 1;
	_dirMode = _this select 2;
	_eyeDV = eyeDirection _b;
	_eyeD = ((_eyeDV select 0) atan2 (_eyeDV select 1));
	if (_dirMode == "AREA") then {_eyeD = getdir _b};
	if (_eyeD < 0) then {_eyeD = 360 + _eyeD};
	_dirTo = [_b, _a] call BIS_fnc_dirTo;
	_eyePb = eyePos _b;
	_eyePa = eyePos _a;
	_abs = abs(_dirTo - _eyeD);
	_range = if (_a distance _b < 20) then {_abs >= 90 && _abs <= 270} else {_abs >= 60 && _abs <= 240};
	if (_range || (lineIntersects [_eyePb, _eyePa]) || (terrainIntersectASL [_eyePb, _eyePa])) then {
		_boolean = false; //NOT IN SIGHT
	} else {
		_boolean = true; //IN SIGHT
	};
	_boolean;
};

//-- Simplified version of above (Autnor Nore: Combine LOS-Functions into one powerful function)
//-- observer does not need FOV on object, this is a simple direct check for lineIntersects
MCSS_fnc_LOS_SIMPLE = {
	_a = _this select 0;
	_b = _this select 1;
	_ign1 = if (typename _a == "ARRAY") then {objnull} else {_a};
	_ign2 = if (count _this > 2) then {_this select 2} else {objNull};
	_resetASL = if (count _this > 3) then {_this select 3} else {true};
	_return = false;
	_aslPos1 = if (typename _a == "ARRAY") then {if (_resetASL) then {ATLtoASL _a} else {_a}} else {if ((vehicle _a) == _a) then {eyepos _a} else {[((getposASL (vehicle _a)) select 0),((getposASL (vehicle _a)) select 1),( ((getposASL (vehicle _a)) select 2) + ((((boundingboxreal (vehicle _a)) select 1) select 2) + 0.1))]};};
	_aslPos2 = if (typename _b == "ARRAY") then {if (_resetASL) then {ATLtoASL _b} else {_b}} else {if ((vehicle _b) == _b) then {eyepos _b} else {[((getposASL (vehicle _b)) select 0),((getposASL (vehicle _b)) select 1),(((getposASL (vehicle _a)) select 2) + ((((boundingboxreal (vehicle _b)) select 1) select 2) + 0.1))]};};
	_refob1 = if (typename _a == "ARRAY") then {objnull} else {(vehicle _a)};
	_refob2 = if (typename _b == "ARRAY") then {objnull} else {(vehicle _b)};
	if ((lineIntersects [_aslPos1, _aslPos2,_ign1,_ign2]) || (terrainIntersectASL [_aslPos1, _aslPos2])) then {
		_return = false;
	} else {
		_return = true;
	};
	_return
};

//-- LOS COVER: Attention: if this returns false, then the position is safe and in cover. The reason for this inversion is that no units may be able to see it, so the fnc needs to return true for 0 units in order to be allowed
MCSS_fnc_LOS_Cover = {
	params ["_pos","_observer","_object"];
	
	_eyePos = eyepos _observer;

	_return =
	{
		_pos set [2,_x];
		_pos = ATLtoASL _pos;
		_ins = lineIntersectsObjs [_pos, _eyePos, _observer, objNull];
		//systemchat str (_ins);
		(_object in _ins)
	} count [0.2,1] == 0; //-- height array: 0 for feet, 1 for crouch, ////////////// 1.8 for standing (rough eyepos) removed
	_return

};

MCSS_fnc_LOS_Cover_old = {
	_pos = ATLtoASL (_this select 0);
	_observer = _this select 1;
	_object = _this select 2;
	_eyePos = eyepos _observer;
	_ins = lineIntersectsSurfaces
	[
		_pos,
		_eyePos,
		_observer,
		objNull,
		true,
		1,
		"GEOM",
		"NONE"
	];
	_return = count _ins == 0;
//	_return = true;
//	_objs = lineIntersectsObjs [_eyePos, _pos, _observer, objnull, false];
//	if (count _objs == 0) then {
//		if (terrainIntersectASL [_eyePos, _pos]) then {
//			_return = false;
//		};
//	} else {
//		{
//			_armor = getnumber (configfile >> "Cfgvehicles" >> typeof _x >> "armor");
//			if (_armor >= 100) exitwith {
//				_return = false;
//			};
//		} foreach _objs;
//	};
	_return
};


mcss_inAngleSector = {
    params ["_center", "_dir", "_sector", "_pos"];

    private _dirTo = _center getDir _pos;
    //systemchat str (acos ([sin _dir, cos _dir, 0] vectorCos [sin _dirTo, cos _dirTo, 0]));
    acos ([sin _dir, cos _dir, 0] vectorCos [sin _dirTo, cos _dirTo, 0]) <= _sector
};

//-- Line Of Fire: Check if unit has it's weapon aimed at a target sufficiently
MCSS_fnc_LOF = {
	private ["_a","_b","_WDir","_WDeg","_abs","_bolean","_range"];
	
	//Unit with the weapon
	_a = _this select 0;
	//Unit to be in line of weapon
	_b = _this select 1;

	if (weaponlowered _a) exitwith {false};
	
	_range = [position _a, getDir _a , 45, position _b ] call mcss_inAngleSector;
	//systemchat str [([_a, position _b] call BIS_fnc_relativeDirTo),_range];
	_bolean = if (_range) then {true} else {false};

	_bolean
};

MCSS_fnc_TiltTowardsPos = {
	params ["_obj","_targetPos"];
	
	private ["_objPos","_vDif","_tVal","_angle","_dir","_pitch","_vecdx","_vecdy","_vecdz","_vecux","_vecuy","_vecuz"];
	_objPos = getposATL _obj;

	_vDif = _objPos vectorDiff _targetPos;
	_tVal = if ((_vDif select 1) == 0) then {0} else {(_vDif select 2) / (_vDif select 1)};

	_angle = abs (atan _tVal);
	_dist = _objPos distance _targetPos;


	if ((_objPos select 2) > (_targetPos select 2)) then {

		_angle = (_angle * -1);
		if (_dist > 200) then {
			//_angle = _angle max 10;
		};
		if ((_objPos select 2) < 25) then {
			//_angle = _angle max 10;
		};
	};

	if ((_objPos select 2) < 2) then {
		//_angle = _angle max 2;
	};
	//systemchat str _angle;
	_dir = _objPos getdir _targetPos;
	_pitch = 0;
	_vecdx = sin(_dir) * cos(_angle);
	_vecdy = cos(_dir) * cos(_angle);
	_vecdz = sin(_angle);
	_vecux = cos(_dir) * cos(_angle) * sin(_pitch);
	_vecuy = sin(_dir) * cos(_angle) * sin(_pitch);
	_vecuz = cos(_angle) * cos(_pitch);

	//_obj setVectorDirAndUp [ [_vecdx,_vecdy,_vecdz], [_vecux,_vecuy,_vecuz] ];
	[ [_vecdx,_vecdy,_vecdz], [_vecux,_vecuy,_vecuz] ]
};





 MCSS_fnc_TerrainTilt = {
	params ["_pos"];
	private _y = if (count _this > 1) then {_this select 1} else {if (typeName _pos == "OBJECT") then {getDir _pos} else {0}};
	_pos = if (typeName _pos == "ARRAY") then {_pos} else {position _pos};	
	private _p = [_pos, _y] call BIS_fnc_terrainGradAngle;
	_r = 0;
	_vDU =
	[
		[sin _y * cos _p,cos _y * cos _p,sin _p],
		[[sin _r,-sin _p,cos _r * cos _p],-_y] call BIS_fnc_rotateVector2D
	];
	_vDU
};

MCSS_fnc_isObjectFlipped = {
	params ["_obj"];
	private _terrainVectors = [_obj,getDir _obj] call MCSS_fnc_TerrainTilt;
	private _vehicleVectors = [vectorDir _obj, vectorUp _obj];
	private _flipped = false;
	private _exit = false;
	for "_i" from 0 to 1 do {
		for "_t" from 0 to 2 do {
			_n = abs (((_terrainVectors select _i) select _t) - ((_vehicleVectors select _i) select _t));
			if (_n > 0.2) exitWith {
				_flipped = true;
				_exit = true;
			};
		};
		if (_exit) exitWith {};
	};
	_flipped
};




MCSS_fnc_ICONTYPE = {
	private ["_checkedGroup","_markerType"];
	_checkedGroup = _this select 0;
	_markerType = "n_inf";
	if (({(vehicle _x) isKindOf "CAR"} count units _checkedGroup) > 0) then {_markerType = 'n_motor_inf'};
	if (({(vehicle _x) isKindOf "TANK"} count units _checkedGroup) > 0) then {_markerType = 'n_armor'};
	if (({(vehicle _x) isKindOf "HELICOPTER"} count units _checkedGroup) > 0) then {_markerType = 'n_air'};
	if (({(vehicle _x) isKindOf "AIR"} count units _checkedGroup) > 0) then {_markerType = 'n_plane'};
	//if( (faction (leader _checkedGroup)) in ["BLU_F","BLU_G_F","OPF_F","OPF_G_F","IND_F","IND_G_F","CIV_F"]) then {
	//	_markerType = ((_checkedGroup getGroupIcon (_checkedGroup getVariable "BIS_MARTA_ICON_TYPE")) select 0);
	//	_markerType = _checkedGroup getGroupIcon (_checkedGroup getVariable "BIS_MARTA_ICON_TYPE");
	//};
	_markerType
};

//-- switch marker visualisation
MCSS_fnc_SwitchMarker = {
	(_this select 0) setMarkerTypeLocal (_this select 1);
	if ((count _this) > 2) then {(_this select 0) setMarkerColorLocal (_this select 2)};
};


MCSS_fnc_orderIndividual_HC = {
	private ["_unit","_data","_unitindex","_unitArray","_dir","_logics","_c","_d"];
	_unit = _this select 0;
	if (isPlayer _unit) exitWith {};
	_data =_this select 1; //-- examples: ["BEHAVIOUR","STEALTH"] OR ["COMBATMODE","YELLOW"]
};

//-- Assign global group-state to individual units within player's group
//-- Ungroups the unit, assigns state, regroups the unit
//-- can be used to assign individual combatMode and behaviour
//-- Also used by Fire On My Lead - Function
A3C_BHV_CBM_MACRO = {
    params ["_mode", "_value"];
    
    // Determine the radio message based on mode and value
    private _radioMsg = if (_mode == "BEHAVIOUR") then {
        switch (_value) do {
            case "CARELESS": {"SentBehaviourSafe"};
            case "SAFE": {"SentBehaviourSafe"};
            case "STEALTH": {"SentBehaviourStealth"};
            case "AWARE": {"SentBehaviourAware"};
            case "COMBAT": {"SentBehaviourCombat"};
        }
    } else {
        switch (_value) do {
            case "BLUE": {"SentHoldFire"};
            case "GREEN": {"SentHoldFire"};
            case "WHITE": {"SentEngageNoTarget"};
            case "YELLOW": {"SentOpenFire"};
            case "RED": {"SentOpenFireInCombat"};
        }
    };

    // Execute the radio call
    player groupradio _radioMsg;

    // Execute the function for each unit
    {
        [_x, [_mode, _value]] call MCSS_fnc_orderIndividual;
    } foreach A3C_RD_UNITS;
};


MCSS_fnc_orderIndividual = {

	params ["_unit","_data"];
	private ["_unitindex","_unitArray","_dir","_logics","_c","_d"];
	_data params ["_command","_value"];

	//systemchat str _unit;
	private _group = group _unit;
	private _expD = (expectedDestination _unit);
	//systemchat str _expD;
	if (isPlayer _unit) exitWith {};

	//-- security for FIRE ON MY LEAD
	if (_command == "BEHAVIOUR") then {
		if (_unit in A3C_ROE3_UNITS) then {
			_unit setCombatMode "BLUE";
		};
	} else {
		if (_value in ["YELLOW","RED"]) then {
			//-- open fire: remove units from fire on my lead
			A3C_ROE3_UNITS = A3C_ROE3_UNITS - [_unit];

			if (count A3C_ROE3_UNITS == 0) then {
				//-- no more units: reset FOML and remove EH
				A3C_BOOL_ROE_3 = false;
				A3C_ROE3_UNITS = [];
				if (!isNil "A3C_FIRED_COMMAND") then {
					player removeEventHandler ["fired", A3C_FIRED_COMMAND];
					A3C_FIRED_COMMAND = nil;
				};
			};
		};
	};

	if (_command == "COMBATMODE") then {
		//-- note: since introduction of 'setUnitCombatMode' command there is no more need to ungroup/regroup unit
		_unit setUnitCombatMode _value; 
		
	} else {
		_logics = [];
		_unit disableAI "FSM";

		_unitArray = if (player == leader _group) then {profileNamespace getvariable "A3C_GROUPUNITS"} else {units _group}; //-- player can be objnull on dedicated server

		//-- get unit data
		_unitIndex = if (player == leader _group) then {_unit getvariable "A3C_FORMATION_INDEX"} else {[_unit,units _group] call MCSS_fnc_GetArrayIndex,};
		_c = if (player == cameraOn) then {assignedTeam _unit} else {_unit getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
		_d = expectedDestination _unit;
		_tgt = assignedTarget _unit;
		_dir = getdir _unit;

		//-- ungroup unit
		[_unit] join grpNull;

		//-- apply new settings

		private _commandString = if (_command == "BEHAVIOUR") then {"setBehaviour"} else {"setCombatMode"};
		[_unit,_value] remoteExec ["setBehaviour",_unit];



		if (!isPlayer leader _group) exitWith {
			[_unit] joinSilent _group;
		};

		

		for "_i" from 1 to (_unitIndex - 2) do {
			_un = _unitArray select _i;
			if !(_un in units player) then {
				_gL = (group player) createUnit ["LOGIC", [0,0,0], [], 0, ""];
				_logics pushbackUnique _gL;
			};
		};


		[_unit] joinsilent (group player);
		{_logics = _logics - [_x]; deletevehicle _x; } foreach _logics;
		_unit assignTeam _c;
		_unit setVariable ["A3C_ASSIGNEDTEAM",_c];
		if !(A3C_C_FORM_ACTIVE) then {
			if ((_d select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
				_unit doFollow player;
			} else {
				if (isNull objectParent _unit) then { //~~ should this not be: if _d select 0 distance _vehicle > 2 or similar?
					if ((_d select 0) distance2D [0,0,0] > 0) then {
						[_unit,(_d select 0)] call A3C_DOMOVE;
					};
				};
			};
		} else {
			if (_unit getVariable ["A3C_FORM_MEMBER",false]) then {
				[_unit] spawn {
					params ["_unit"];
					private ["_var","_formDist","_formDir","_formPos"];
					_var = _unit getVariable "A3C_FORM";
					_formDist = (_var select 0);
					_formDir = (getDir player) + (_var select 1);
					_formPos = (player getpos [_formDist,_formDir]);
					doStop _unit;
					sleep 0.2;
					//_unit doMove _formPos;
					_unit moveTo _formPos;
					if !(isMultiplayer) then {
						_unit doFSM ["A3C_CORE\fsm\doFormation.fsm", position _unit,_unit];
					};
				};
			};
		};

		if (!isnil '_target' && {isnull _tgt}) then {
			_unit dotarget _tgt;
		};
		_unit enableAI "FSM";

		if !(["form",tolower (_expD select 1)] call BIS_fnc_instring) then {
			private _movePos = _expD select 0;
			if (_movePos distance2D [0,0,0] > 0) then {
				[_unit,_movePos] call A3C_DOMOVE;
			} else {
				[_unit,position (vehicle _unit)] call A3C_DOMOVE;
			};
		};

		if (isMultiPlayer) then {
			[_unit,_c] spawn {
				params ["_unit","_c"];
				sleep 0.5;
				_unit assignTeam _c;
				_unit setVariable ["A3C_ASSIGNEDTEAM",_c];
			};
		};

		
	};

	
	
};



//-- get magazine muzzlename
MCSS_fnc_GetMuzzle = {
	private ["_mag"];
	_mag = _this select 0;
	_return = "";
	if ( !((typename _mag) == "STRING") && {isnull _mag}) exitwith {_return};
	{
		_magazines = getarray (configfile >> "CfgWeapons" >> "Throw" >> _x >> "magazines");
		if (_mag in _magazines) exitwith {
			_return = _x;
		};
	} foreach A3C_THROW_MUZZLES;
	_return
};

//-- Get a unit's weaponItems of specific slot
//[player,"MuzzleSlot",0] call MCSS_fnc_getWeaponItems;
MCSS_fnc_getWeaponItems = {
	private ["_unit","_slot","_arr","_wp"];
	_unit = _this select 0;
	_slot = _this select 1; // CowsSlot / "MuzzleSlot" / "PointerSlot"
	_mode = _this select 2;
	_wp = if (count _this > 3) then {_this select 3} else {primaryWeapon _unit};
	_check = if (_mode == 0) then {items _unit} else {primaryweaponitems _unit};
	_arr = [];
	{
		if (isclass (configfile >> "CfgWeapons" >> _wp >> "WeaponSlotsInfo" >> _slot >> "compatibleItems")) then {
			if !( (configname (configfile >> "CfgWeapons" >> _wp >> "WeaponSlotsInfo" >> _slot >> "compatibleItems" >> _x)) == "") then {
				_arr pushback _x;
			};
		};
	} foreach _check;
	{
		if !(_x in _arr) then {_arr pushback _x};
	} foreach (getarray (configfile >> "CfgWeapons" >> _wp >> "WeaponSlotsInfo" >> "MuzzleSlot" >> "compatibleItems"));
	_arr
};

MCSS_fnc_getNearSlingLoadObjects = {
	params ["_vehicle","_position"];
	private ["_return"];
	_return = [];
	_nearObjects = nearestObjects [_position, [],250];
	//systemchat str [_vehicle,_position, _nearobjects];
	{
		if ( isClass (configFile >> "CFGVehicles" >> typeOf _x)) then {
			//systemchat str _x;
			if (_vehicle canSlingLoad _x) then {
				_return pushback _x;
			};

		};
	} foreach _nearobjects;
	_return
};

MCSS_fnc_getUnitIdentity = { //-- not used since not working
	params ["_unit"];
	_identity =
	{
		if ( getText( _x >> "Name" ) isEqualTo ( name _unit ) ) exitWith { configName _x };
	} forEach ( "true" configClasses( missionConfigFile >> "CfgIdentities" ));
	systemchat str [_identity];
	_nameString = (name _unit) splitString " ";
	_ref = _nameSTring select ((count _nameString -1) max 0);
	_cf = "true" configClasses (configFile >> "CfgIdentities");
	_return = "";
	//systemchat "1";
	if (isNil '_ref') exitWith {_return};
	{
		//_class = configfile >> "CfgIdentities" >> configname _x;
		_name = getText (configfile >> "CfgIdentities" >> configname _x >> "name");
		//systemchat str [_ref,_name];
		//systemchat str [_ref,_name];
		if ([_ref,_name] call BIS_fnc_inString) exitWith {
			_return = configname _x;
		};
	} foreach _cf;
	_return
};


MCSS_fnc_posIntersect = {
	params ["_unit","_ignore"];
	private _startPos = if (player == _unit) then {AGLToASL positionCameraToWorld [0,0,0]} else {([_unit] call MCSS_fnc_Switch_Eyepos)};
	private _ignore = if (count _this > 1) then {_this select 1} else {objNull};
	private _endPos = if (count _this > 2) then {_this select 2} else {AGLToASL positionCameraToWorld [0,0,viewDistance]};

	_ins = lineIntersectsSurfaces
	[
		_startPos,_endPos,
		vehicle _unit,
		_ignore,
		true,
		1,
		"GEOM",
		"NONE"
	];
	if (count _ins == 0) exitWith {if (_unit == player) then {screenToWorld [0.5,0.5]} else {_unit getPos [viewDistance,getDir vehicle _unit]}};
	_intsPos = (_ins select 0 select 0);
	_intsPos
};

MCSS_fnc_isClickPosInCTRLArea = {
	params ["_clickPos","_ctrl"];
	private ["_boxSize","_center","_return"];
	if !(ctrlShown _ctrl) exitWith {false};
	_boxSize = ctrlPosition _ctrl;
	_boxSize params ["_x","_y","_w","_h"];
	if (ctrlIDC _ctrl == 7078) then {
		_h = _h + (2 * _h);
	};
	_center = [ _x + (_w / 2) , _y + (_h / 2) ];
	_return = _clickPos inArea [_center, (_w / 2), (_h / 2), 0, true];
	_return
};
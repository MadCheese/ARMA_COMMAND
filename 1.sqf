params ["_unit"];
AIO_cancel_Taxi = false;
AIO_Taxi_move =
{
	params ["_veh", "_pointA", "_pointB", "_centPos", "_radius"];
	private ["_exit","_maxTurnSpeed", "_maxStraightSpeed", "_isRight", "_deltaX", "_deltaT", "_diff", "_diffV", "_normal", "_div", "_angle", "_angleA","_newAng","_cos"];
	_maxTurnSpeed = 50/3.6;
	_maxStraightSpeed = 80/3.6;
	_isRight = _veh getRelDir _centPos < 180;
	
	if (_radius != 0) then {
		//hint "Turning";
		_deltaX = _maxTurnSpeed*0.01;
		_deltaT = asin(_deltaX/_radius);
		_cos = (_pointA vectorDiff _centPos) vectorCos (_pointB vectorDiff _centPos); _angle = acos _cos;
		_div = _angle/_deltaT;
		_markerName = format ["marker%1%2", _veh, _radius];
		createMarkerLocal [_markerName,_centPos];
		_markerName setMarkerTypeLocal "hd_dot";
		_markerName setMarkerSizeLocal [0.6, 0.6];
		_markerName setMarkerDirLocal 0;
		_markerName setMarkerColorLocal "ColorBlack";
		_angleA = [_centPos, _pointA] call BIS_fnc_dirTo;
		_newAng = _angleA;
		_exit = false;
		//hint str _isright;
		for "_j" from 0 to (_div - 2) do
		{ 
			if (AIO_cancel_Taxi) exitWith {};
			_newPos = nil;
			_multi = accTime;
			if !(_isRight) then {_newAng = _newAng - _deltaT*_multi; if (_newAng <= _angleA - _angle) then {_exit = true; _newAng = (_angleA - _angle)}} else {_newAng = _newAng + _deltaT*_multi; if (_newAng >= _angleA + _angle) then {_exit = true; _newAng = (_angleA + _angle)}};
			if (_newAng/360 > 1) then {_newAng = _newAng mod 360};
			_xp = _radius*sin(_newAng);
			_yp = _radius*cos(_newAng);
			_newPos = _centPos vectorAdd [_xp, _yp, 0];
			_veh setPos [_newPos select 0, _newPos select 1];
			_markerName = format ["marker%1%2",_radius, _j];
			createMarkerLocal [_markerName,_newPos];
			_markerName setMarkerTypeLocal "hd_dot";
			_markerName setMarkerSizeLocal [0.6, 0.6];
			_markerName setMarkerDirLocal 0;
			_markerName setMarkerColorLocal "ColorBlue";
			waitUntil {!isNil "_newPos"};
			_normal = if (_isRight) then {[0,0,-1] vectorCrossProduct [_xp, _yp, 0]} else {[0,0,1] vectorCrossProduct [_xp, _yp, 0]};
			_veh setVectorDir (_normal);
			if (_exit) exitWith {};
			sleep 0.01;
		};
	} else {
	//hint "now moving";
		_deltaX = _maxStraightSpeed*0.01;
		_deltaT = 5;
		_multi = accTime;
		_isRight = _veh getRelDir _pointB < 180;
		while {_veh distance2D _pointB > _deltaX*_multi && !AIO_cancel_Taxi} do {
			_multi = accTime;
			_diff = (getPos _veh) vectorFromTo _pointB;
			_newPos = (getPos _veh) vectorAdd [(_diff select 0)*_deltaX*_multi,(_diff select 1)*_deltaX*_multi, 0];
			_veh setPos [_newPos select 0, _newPos select 1];
			_isRight = abs(_veh getRelDir _pointB) < 180;
			if (abs(_veh getRelDir _pointB) < 360 - 5) then {
				if (_multi > 1) then {_veh setDir ([_pointA, _pointB] call BIS_fnc_dirTo)} else {
				if (_isRight) then {
				_veh setDir (getDir _veh + _deltaT)} else {_veh setDir (getDir _veh - _deltaT)};
			};
		};
		sleep 0.01;
	};
	
};
};


AIO_getPath_fnc =
{
	params ["_veh", "_pos"];
	private ["_select", "_back", "_isDone","_roads", "_road1", "_road", "_road2", "_path", "_dist", "_forward", "_right", "_left", "_distArray", "_posArray", "_arrayT", "_averageF", "_averageR", "_averageL"];
	//_roads = _veh nearRoads 10;
	//if (count _roads != 0) then {_dist = 25} else {_dist = 50};
	_dist = 50;
	_isDone = false;
	_path = [[], []];
	_forward = [];
	_right = [];
	_left = [];
	_back = [];
	_roads = _veh nearRoads _dist;
	_roads = [_roads,[],{_veh distance2D _x},"ASCEND"] call BIS_fnc_sortBy;
	for "_i" from 0 to (count _roads - 1) do
	{
		_road = _roads select _i;
		_done = false;
		if (_road distance2D _veh > 10) then {
			if (_veh getRelDir _road >= 315 OR _veh getRelDir _road <= 45) then {_done = true; _forward = _forward + [_road] - _right - _left - _back};
			if (!_done &&_veh getRelDir _road <= 135) then {_done = true; _right = _right + [_road] - _forward - _left - _back};
			if (!_done &&_veh getRelDir _road >= 225) then {_done = true; _left = _left + [_road] - _right - _forward - _back};
			if (!_done &&_veh getRelDir _road > 135 &&_veh getRelDir _road < 225) then {_back = _back + [_road] - _right - _forward - _left};
		};
	};
	_sumF = 0;
	{
		_sumF = _sumF + (_x distance _pos);
	} forEach _forward;
	_sumR = 0;
	{
		_sumR = _sumR + (_x distance _pos);
	} forEach _right;
	_sumL = 0;
	{
		_sumL = _sumL + (_x distance _pos);
	} forEach _left;

	if (count _forward != 0) then {_averageF = _sumF/(count _forward)} else {_averageF = 0};
	if (count _right != 0) then {_averageR = _sumR/(count _right)} else {_averageR = 0};
	if (count _left != 0) then {_averageL = _sumL/(count _left)} else {_averageL = 0};
	_max = [_averageF, _averageL, _averageR];
	_max sort false;
	_max = _max select 0;
	
	
	//if (count _right >  OR count _left > count _forward) then {_turn = true} else {_turn = false};
	
	if (count _forward != 0 OR _averageF == _max) then {
		_roadF = _forward select 0;
		_roads = _roadF nearRoads _dist;
		_roads = _roads - _forward - _right - _left - _back;
		_roads = [_roads,[],{_pos distance2D _x},"ASCEND"] call BIS_fnc_sortBy;
		if (count _roads != 0) then {
			_done = false;
			for "_i" from 0 to (count _roads - 1) do
			{
				_road = _roads select _i;
				if (_veh getRelDir _road >= 315 OR _veh getRelDir _road <= 45) then {
					if (_road distance2D _veh > _roadF distance2D _veh) then {_done = true; _forward = _forward + [_road]};
				};
				if (_done) exitWith {_isDone = true};
			};
		};
	};
	if (count _right != 0 OR _averageR == _max) then {
		_roadR = _right select 0;
		_roads = _roadR nearRoads _dist;
		_roads = _roads - _forward - _right - _left - _back;
		_roads = [_roads,[],{_pos distance2D _x},"ASCEND"] call BIS_fnc_sortBy;
		if (count _roads != 0) then {
			_done = false;
			for "_i" from 0 to (count _roads - 1) do
			{
				_road = _roads select _i;
				if (_veh getRelDir _road <= 135 && _veh getRelDir _road >= 45) then {
					if (_road distance2D _veh > _veh distance2D _roadR) then {_done = true; _right = _right + [_road]};
				};
				if (_done) exitWith {_isDone = true};
			};
		};
	};
	if (count _left != 0 OR _averageL == _max) then {
		_roadL = _left select 0;
		_roads = _roadL nearRoads _dist;
		_roads = _roads - _forward - _right - _left - _back;
		_roads = [_roads,[],{_pos distance2D _x},"ASCEND"] call BIS_fnc_sortBy;
		if (count _roads != 0) then {
			_done = false;
			for "_i" from 0 to (count _roads - 1) do
			{
				_road = _roads select _i;
				if (_veh getRelDir _road <= 315 && _veh getRelDir _road >= 225) then {
					if (_road distance2D _veh > _veh distance2D _roadL) then {_done = true; _left = _left + [_road]};
				};
				if (_done) exitWith {_isDone = true};
			};
		};
	};
	if (count _back != 0 && !_isDone) then {
		_roadL = _back select 0;
		_roads = _roadL nearRoads _dist;
		_roads = _roads - _forward - _right - _left - _back;
		_roads = [_roads,[],{_pos distance2D _x},"ASCEND"] call BIS_fnc_sortBy;
		if (count _roads != 0) then {
			_done = false;
			for "_i" from 0 to (count _roads - 1) do
			{
				_road = _roads select _i;
				if (_veh getRelDir _road <= 225 && _veh getRelDir _road >= 135) then {
					if (_road distance2D _veh > _veh distance2D _roadL) then {_done = true; _back = _back + [_road]};
				};
				if (_done) exitWith {};
			};
		};
	};
	_distArray = [];
	_arrayT = [_forward, _right, _left, _back];
	for "_i" from 0 to 3 do
	{
		_road = (_arrayT select _i);
		if (_i == 3 && _isDone) exitWith {};
		if (count _road > 1) then {
		_distArray = _distArray + [[(_road select 1) distance2D _pos, _i]]};
		
	};
	_distArray = [_distArray,[],{(_x select 0)},"ASCEND"] call BIS_fnc_sortBy;
	_select = ((_distArray select 0) select 1);
	
	if (_select == 1 OR _select == 2) then {
		if (count _distArray > 1) then {
		_roadL = (_arrayT select _select) select 0;
		private _select1 = ((_distArray select 1) select 1);
		_roadF = (_arrayT select _select1) select 0;
		if ((_roadL distance2D _pos) + (_veh distance2D _roadL) - 5 >= _roadF distance2D _pos) then {_select = _select1};
		};
	};
	_posArray = if (count _distArray > 0) then {_arrayT select _select} else {[]};
	_road1 = if (count _posArray > 0) then {_posArray select 0};
	_road2 = if (count _posArray > 1) then {_posArray select 1};
	
	if (!isNil "_road2") then {_path set [1, getPos _road2]};
	if (!isNil "_road1") then {_path set [0, getPos _road1]};
	_path
};



/*
AIO_getPath_fnc =
{
	params ["_veh", "_pos"];
	private ["_roads", "_road1", "_road", "_road2", "_path", "_dist"];
	_roads = _veh nearRoads 10;
	if (count _roads != 0) then {_dist = 25} else {_dist = 50};
	_path = [[], []];
	_roads = _veh nearRoads _dist;
	_roads = [_roads,[],{_pos distance _x},"DESCEND"] call BIS_fnc_sortBy;
	_min1 = 1e10;
	_min2 = -1;
	for "_i" from 0 to (count _roads - 1) do
	{
		_road = _roads select _i;
		_dir = abs((_veh getRelDir _road) - 180);
		if (_dir > 90 && _veh distance _road > 5) then {
			if (_dir >= _min2) then {_road1 = _road; _min2 = _dir}};
	};
	if (!isNil "_road1") then {
		_roads = _road1 nearRoads _dist;
		_roads = [_roads,[],{_pos distance _x},"DESCEND"] call BIS_fnc_sortBy;
		_min1 = 1e10;
		_min2 = -1;
		for "_i" from 0 to (count _roads - 1) do
		{
			_road = _roads select _i;
			_dir = abs((_veh getRelDir _road) - 180);
			if (_dir > 60 && _road1 distance _road > 5) then {
				if (_dir <= _min1) then {_road2 = _road; _min1 = _dir}};
		};
		if (!isNil "_road2" && abs((_veh getRelDir _road2) - 180) < 160) then {
			_roads = _veh nearRoads _dist;
			_roads = _roads - [_road2];
			_roads = [_roads,[],{_pos distance _x},"DESCEND"] call BIS_fnc_sortBy;
			_min1 = 1e10;
			_min2 = -1;
			for "_i" from 0 to (count _roads - 1) do
			{
				_road = _roads select _i;
				_dir = abs((_veh getRelDir _road) - 180);
				if (_dir > 90 && _veh distance _road > 5) then {
					if (_dir <= _min1) then {_road1 = _road; _min1 = _dir}};
			};
		};
	};
	if (!isNil "_road2") then {_path set [1, getPosATL _road2]};
	if (!isNil "_road1") then {_path set [0, getPosATL _road1]};
	_path
};
*/


AIO_Taxi_fnc1 =
{
	params ["_veh", "_posArray"];
	private ["_maxTurnSpeed", "_maxStraightSpeed","_centPos", "_radius", "_isTurn", "_pointA", "_pointB", "_pointC", "_vehDir", "_dirV", "_dir", "_isRight", "_initHeight"];
	_maxTurnSpeed = 30/3.6;
	_maxStraightSpeed = 80/3.6;
	_initHeight = (getPos _veh) select 2;
	for "_i" from 1 to (count _posArray - 1) do
	{
		_pointA = (getPos _veh);
		_pointB = _posArray select (_i);
		if (_i == (count _posArray - 1)) exitWith {[_veh, _pointA, _pointB, [0, 0, 0], 0] spawn AIO_Taxi_move};
		_isRight = abs(_veh getRelDir _pointB) < 180;
		_pointC = _posArray select (_i+1);
		_pointA set [2, _initHeight];
		_pointB set [2, 0];
		_pointC set [2, 0];
		_vehDir = vectorDir _veh;
		_vehDir set [2, 0];
		//_dirV = _pointA vectorFromTo _pointB;
		_dir = _veh getRelDir _pointB;
		//_dir = (_dirV select 0) atan2 (_dirV select 1);
		_isTurn = (_pointA distance _pointB < 50 && abs (_dir - 180) < 175);
		if (_isTurn) then {
			_slope1 = [0,0,1] vectorCrossProduct _vehDir;
			_m1 = (_slope1 select 1)/(_slope1 select 0);
			_tempVector = _pointC vectorDiff _pointB;
			_tempVector set [2, 0];
			_slope2 = [0,0,1] vectorCrossProduct _tempVector;
			_m2 = (_slope2 select 1)/(_slope2 select 0);
			_x1 = _pointA select 0;
			_x2 = _pointB select 0;
			_y1 = _pointA select 1;
			_y2 = _pointB select 1;
			_xi = (_m1*_x1 - _m2*_x2 +_y2 - _y1)/(_m1-_m2);
			_yi = _m1*(_xi - _x1) + _y1;
			_centPos = [_xi, _yi, _initHeight];
			_radius = _centPos distance _pointA;
		} else {_centPos = [0, 0, 0]; _radius = 0};
		_script_hand = [_veh, _pointA, _pointB, _centPos, _radius] spawn AIO_Taxi_move;
		waitUntil {!alive _veh OR scriptDone _script_hand};
	};

};

AIO_Taxi_fnc =
{
	params ["_veh", "_pos"];
	private ["_size","_maxTurnSpeed", "_maxStraightSpeed","_centPos", "_radius", "_isTurn", "_pointA", "_pointB", "_pointC", "_vehDir", "_dirV", "_dir", "_isRight", "_initHeight", "_posArray", "_xi", "_yi"];
	_posArray = [_veh, _pos] call AIO_getPath_fnc;
	_initHeight = (getPos _veh) select 2;
	_size = sizeOf (typeOf _veh);
	while {alive _veh && _veh distance _pos > _size && !AIO_cancel_Taxi} do
	{
	if (count (_posArray select 0) == 0 OR count (_posArray select 1) == 0) exitWith {}; 
	//for "_i" from 0 to (count _posArray - 1) do
	//{
		_pointA = (getPos _veh);
		_pointB = _posArray select (0);
		//if (_i == (count _posArray - 1)) exitWith {[_veh, _pointA, _pointB, [0, 0, 0], 0] spawn AIO_Taxi_move};
		_isRight = abs(_veh getRelDir _pointB) < 180;
		_pointC = _posArray select (1);
		_pointA set [2, _initHeight];
		_pointB set [2, 0];
		_pointC set [2, 0];
		_vehDir = vectorDir _veh;
		_vehDir set [2, 0];
		//_dirV = _pointA vectorFromTo _pointB;
		_dir = _veh getRelDir _pointB;
		//_dir = (_dirV select 0) atan2 (_dirV select 1);
		//_isTurn = (abs (_dir - 180) < 135 && abs (_dir - 180) > 10 && _veh distance2D _pointB > 10 && _veh distance2D _pointB < 20);
		_isTurn = false;
		if (_isTurn) then {
			_slope1 = [0,0,1] vectorCrossProduct _vehDir;
			_m1 = (_slope1 select 1)/(_slope1 select 0);
			_tempVector = _pointC vectorDiff _pointB;
			_tempVector set [2, 0];
			_slope2 = [0,0,1] vectorCrossProduct _tempVector;
			if ((_slope2 select 0) == 0) then {_xi = _pointA select 0;_yi = _pointA select 1} else {
			_m2 = (_slope2 select 1)/(_slope2 select 0);
			_x1 = _pointA select 0;
			_x2 = _pointB select 0;
			_y1 = _pointA select 1;
			_y2 = _pointB select 1;
			_xi = (_m1*_x1 - _m2*_x2 +_y2 - _y1)/(_m1-_m2);
			_yi = _m1*(_xi - _x1) + _y1};
			_centPos = [_xi, _yi, _initHeight];
			_radius = _centPos distance _pointA;
		} else {_centPos = [0, 0, 0]; _radius = 0};
		
		_script_hand = [_veh, _pointA, _pointB, _centPos, _radius] spawn AIO_Taxi_move;
		//sleep 5;
		waitUntil {!alive _veh OR scriptDone _script_hand};
		_posArray = [_veh, _pos] call AIO_getPath_fnc;
		//sleep 2;
	//};
	};

};


[_unit] spawn {
params ["_unit"];
private ["_cnt", "_arr", "_posLandA", "_posLandB", "_posTOA", "_posTOB", "_plane", "_array"];
	AIO_land_action =
	{
		params ["_unit", "_pos"];
		private _plane = vehicle _unit;
		_unit doMove _pos;
		waitUntil {unitReady _unit OR (getPosATL _plane) select 2 < 1};
		_unit action ["Land", _plane];
		waitUntil {(getPosATL _plane) select 2 < 1 && speed _plane < 80};
		//_array = [getPos _plane] + _array;
		[_plane, _pos] spawn AIO_Taxi_fnc;
	};
	AIO_selectedunits1 = _unit;
	waitUntil {visibleMap};
	onMapSingleClick "[AIO_selectedunits1, _pos] spawn AIO_land_action";
	waitUntil {!visibleMap};
	onMapSingleClick "";
};


/*
AIO_pos_array = [];
[_unit] spawn {
params ["_unit"];
private ["_cnt", "_arr", "_posLandA", "_posLandB", "_posTOA", "_posTOB", "_plane", "_array"];
	AIO_land_action =
	{
		params ["_unit", "_pos"];
		AIO_pos_array = AIO_pos_array + [_pos];
	};
	AIO_selectedunits1 = _unit;
	waitUntil {visibleMap};
	onMapSingleClick "[AIO_selectedunits1, _pos] spawn AIO_land_action";
	waitUntil {!visibleMap};
	 _plane = vehicle _unit;
	[_plane, AIO_pos_array] spawn AIO_Taxi_fnc1;
	onMapSingleClick "";
};
*/

/*
[_unit] spawn {
	params ["_unit"];
	private ["_cnt", "_arr" , "_plane", "_array"];
	_plane = vehicle _unit;
	_array = [];
	_arr = getarray (configfile >> "CfgWorlds" >> worldName >> "ilsTaxiOff");
	_cnt = count _arr;

	for "_i" from 0 to (_cnt/2 - 1) do
	{
		_pos = [_arr select (_i*2), _arr select (_i*2) + 1, 0];
		if (_i != 0) then {_array pushBack _pos};
		if (_i == 0) then {_posLandB = _pos};
		if (_i == _cnt/2 - 1) then {_posTOB = _pos};
		_markerName = format ["marker%1", _i];
		createMarkerLocal [_markerName,_pos];
		_markerName setMarkerTypeLocal "mil_end";
		_markerName setMarkerSizeLocal [0.6, 0.6];
		_markerName setMarkerDirLocal 0;
		_name = format ["%1", _i];
		_markerName setMarkerTextLocal _name;
		_markerName setMarkerColorLocal "ColorRed";
	};
	_arr = getarray (configfile >> "CfgWorlds" >> worldName >> "ilsTaxiin");
	_cnt = count _arr;

	for "_i" from 0 to (_cnt/2 - 1) do
	{
		_pos = [_arr select (_i*2), _arr select (_i*2) + 1, 0];
		if (_i != 0) then {_array pushBack _pos};
		if (_i == 0) then {_posTOA = _pos};
		if (_i == _cnt/2 - 1) then {_posLandA = _pos};
		_markerName = format ["marker1%1", _i];
		createMarkerLocal [_markerName,_pos];
		_markerName setMarkerTypeLocal "mil_end";
		_markerName setMarkerSizeLocal [0.6, 0.6];
		_markerName setMarkerDirLocal 0;
		_name = format ["%1", _i];
		_markerName setMarkerTextLocal _name;
		_markerName setMarkerColorLocal "ColorGreen";
	};
	waitUntil {(getPosATL _plane) select 2 < 1 && speed _plane < 80};
	_array = [getPos _plane] + _array;
	_temp = _array;
	_cnt = count _array - 1;
	for "_i" from 0 to _cnt do
	{
		_array set [_i, _temp select (_cnt - _i)];
	};
	[_plane, _array] spawn AIO_Taxi_fnc1;
};
*/



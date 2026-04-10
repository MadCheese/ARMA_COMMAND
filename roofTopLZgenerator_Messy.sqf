_building = ofb;

_bDir = getDir _building;
_highestZ_ATL = 0;
_highestZ_ASL = 0;

_refType =
[
	"B_Heli_Light_01_F",
	"B_Heli_Attack_01_F",
	"B_Heli_Transport_01_camo_F",
	"B_Heli_Transport_03_F"
] call BIS_fnc_SelectRandom;

//-- to do: calculate the measures when helper object is spawned and set them as object namespace variable
_refType = "B_Heli_Transport_03_F"; //"B_G_Quadbike_01_F";

_refVehicle = _refType createVehicleLocal [100,100,1000];
_refVehicle enablesimulation false;
_refVehicle setPosASL (ATLtoASL [100,100,1000]);

_vehicleHeight = ((boundingBoxReal _refVehicle) select 1) select 2;
_refBbox = [_refVehicle,0] call MCSS_fnc_BBOX;
{
	_x set [2,1000];
} foreach _refBbox;

_testPosRoot = ATLtoASL (_refBbox select 0);
_testPosZ = _testPosRoot select 2;

_reference_L1 = ((_refBbox select 1) distance2D (_refBbox select 2)) *  1.2; //   WIDTH    7;
_reference_L2 = ((_refBbox select 0) distance2D (_refBbox select 1)) *  1.2; //   LENGHT   3;
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
systemchat format ["Vehicle type %1, WIDTH %2, LENGHT %3", _refType,_reference_L1,_reference_L2];
//if (true) exitWith {deletevehicle _refVehicle};

_reference_L2 = _maxWidth + 1; //   WIDTH    7;
_reference_L1 = _length + 1; //   LENGHT   3;
//width and length might be swapped?







helpers = if (isNil 'helpers') then {[]} else {helpers};
{deletevehicle _x} foreach helpers;
sleep 1;

_isSquareEmpty = {
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
	//systemChat str _intsPos;
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
//_isUsable = true;
	_isUsable
};

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


{
	_helper= 'Sign_Sphere100cm_F' createVehicleLocal [0,0,0];
	
	_helper setPosASL _x;
	helpers pushBack _helper;
	//systemchat str (_x select 2);
	switch (_foreachIndex) do {
		case (0) : {
			_helper setObjectTexture [0, "#(rgb,8,8,3)color(1,0,0,1)"];
		};
		case (1) : {
			_helper setObjectTexture [0, "#(rgb,8,8,3)color(0,1,0,1)"];
		};
		case (2) : {
			_helper setObjectTexture [0, "#(rgb,8,8,3)color(0,0,1,1)"];
		};
		case (3) : {
			_helper setObjectTexture [0, "#(rgb,8,8,3)color(1,1,0,1)"];
		};
	};
} foreach _bboxASL;



//if (true) exitWith {};

_building_width = (_bboxASL select 0) distance2D (_bboxASL select 1);
_building_length = (_bboxASL select 1) distance2D (_bboxASL select 2);

_testPosRoot = (_bboxASL select 3);
_matrix = [];

_finalPosition = [0,0,0];

_stashPosFound = false;

_reference_Length = 14; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
_reference_Width = 2;
systemchat str [_building_width,_building_length]; 

//-- MATRIX
for "_building_length_step" from 0 to (floor _building_length) do {
	_testPos1 = _testPosRoot getPos [_building_length_step, _bDir - 180];
	//_testPos1 set [2,_highestZ_ASL];
	_subMatrix = [];
	//systemchat str [_building_length_step,_testPos1 distance2d (helpers select 0)];
	for "_building_width_step" from 0 to (floor _building_width)  do {
		_testPos = _testPos1 getPos [_building_width_step,_bDir + 90];
		_testPos set [2,_highestZ_ASL];
		//player enablesimulation false;
		//player setposASL _testPos;
		//player setdir (player getdir _building);
		//sleep 0.01;
		_matrixValue = 0;
		
		//private _helper = objNull;

		if ([_testPos,_building,_bDir,_highestZ_ASL] call _isSquareEmpty) then {
			//_helper = "Land_VR_Shape_01_cube_1m_F" createVehicleLocal [0,0,0];
			//helpers pushBack _helper;
			//_helper setDir _bDir;
			//_helper setPosASL _testPos;
			_matrixValue = 1;
		};
		
		/*
		_connectionsY = false;
		
		
		if (_matrixValue == 1) then {
			if (_building_width_step > _reference_Width) then { //-- minimum width has to be reached || NOTE: SHOULD THESE BE >= ??
				if ( _building_length_step > _reference_Length) then { //-- minimum length is reached: check if previous squares are empty
					//systemchat str [_building_length_step,_building_width_step];
					_connectionsY = true;

					for "_reference_length_step" from 0 to (_reference_Length - 1) do {
						_refMatrixRow = if (_reference_length_step == 0) then {
							_subMatrix
						} else {
							_matrix select (_building_length_step - (_reference_length_step - 0))
						};
						//if (isnil '_refMatrixRow') then {
						//	player sidechat format ["ALARM %1", _reference_length_step];
						//	setacctime 0;
						//};
						
						for "_reference_width_step" from 1 to (_reference_Width - 1) do {
							_subSelect = (_refMatrixRow select (_building_width_step - _reference_width_step)) select 1;
						
							
							if (_subSelect == 0) exitWith {
								_connectionsY = false;
							};
						};
						
						if !(_connectionsY) exitWith {};
					};
					
					
					
					//systemchat str _connectionsY;
					if (_connectionsY) then {

						_aslPosH = getPosASL _helper;
						_aslPosH set [2, (_aslPosH select 2) + 0.5];
						_helper setPosASL _aslPosH;
						_helper enablesimulation false;
						_stashPosFound = true;
						
						_finalPosition = _testPos getPos [_reference_Length / 2, _bDir - 180];
						_finalPosition = _finalPosition getPos [_reference_Width / 2, _bDir - 90];
						_finalPosition set [2, _highestZ_ASL];
						
					};
				};
			};
		};
		*/
		

		_subMatrix pushBack [_testPos,_matrixValue]; 
		//if (_stashPosFound) exitWith {};
		//sleep 0.01; //-- use this sleep to see the buildingBlocks
		
	};
	//if (_stashPosFound) exitWith {systemchat 'done'};

	_matrix pushBack _subMatrix;
};

//--
_subMatrixEntryCount = count (_matrix select 0); //-- identical to ceil(_buildingWith)
_histogram = [];
for "_i" from 1 to _subMatrixEntryCount do {
	_histogram pushBack [[0,0,0],0];
};


_largestRectangle = [[0,0,0],0,0]; //-- [bottom lect corner,width,length];




{
	_subMatrix = _x;
	//_feid = _foreachINdex;
	//-- create submatrix histogram
	{
		//systemchat str  _x;
		//setacctime 0;
		
		_x params ["_aslPos","_isEmpty"];
		
		_histoValue = (_histogram select _foreachIndex) select 1;
		if (_isEmpty == 1) then {
			_histogram set [_foreachIndex, [_aslPos,_histoValue + 1]];
		} else {
			_histogram set [_foreachIndex,[_aslPos,0]];
		};
		
	} foreach _subMatrix;
	//player commandchat str _histogram;
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
			
			if ((_currentW * _histoValue) > ( (_largestRectangle select 1) * (_largestRectangle select 2)) ) then {
				_largestRectangle = [_aslPos1,_currentW,_histoValue];
			};

		};

	} foreach _histogram;
} foreach _matrix;


//-- Flip the matrix 90 degrees:


_newMatrix = [];
for "_i" from (_subMatrixEntryCount - 1) to 0 step -1 do {
	_subMatrix = [];
	{
		_subMatrix pushBack (_x select _i);
	} foreach _matrix;
	_newMatrix pushBack _subMatrix;

};

_matrix = _newMatrix;


if (true) exitwith {deletevehicle _refVehicle};


if !(_stashPosFound) then {
	systemchat format ["No possible stashing Pos for %1",	gettext (configfile >> "CfgVehicles" >> _refType >> "displayName")];
} else {
	_refVehicle setPosASL _finalPosition;
	_refVehicle setDir (_bDir - 180);
	sleep 3;
};
deletevehicle _refVehicle;
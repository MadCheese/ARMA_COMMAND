// A3C_ai_shared_fnc_getHeliRoofLZ


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

		if ([_testPos,_building,_bDir,_highestZ_ASL] call A3C_main_fnc_isEmptySquareOnSurfaceLevel) then {
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


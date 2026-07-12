// MCSS_fnc_getRealBoundingBox

params ["_object"];

private _objectDir = getDir _object;
private _bboxCorners = [_object, 0] call MCSS_fnc_getBoundingBox;

private _realCorners = [];

{ deleteVehicle _x } forEach MCSS_RealBB_Vehicles;

MCSS_RED_LINES = [];
MCSS_GREEN_LINES = [];

{
	private _cornerPos = _x;
	private _cornerIndex = _forEachIndex;

	private _checkData = switch (_cornerIndex) do {
		case 0: { [_objectDir, _objectDir + 90] };
		case 1: { [_objectDir, _objectDir - 90] };
		case 2: { [_objectDir + 180, _objectDir - 90] };
		case 3: { [_objectDir + 180, _objectDir + 90] };
	};

	{
		_checkData set [_forEachIndex, [_x] call MCSS_fnc_correctDir];
	} forEach _checkData;

	_checkData params ["_refDir1", "_refDir2"];

	private _startPosition = _cornerPos;
	private _testHeight = (_object call BIS_fnc_objectHeight) * 0.3;
	private _checkWidth = 50;

	private _testPosition1 = [0, 0, 0];

	for "_i" from 0 to 50 step 0.1 do {
		_testPosition1 = _startPosition getPos [_i, _refDir1];
		_testPosition1 set [2, _testHeight];

		private _testPosition2 = _testPosition1 getPos [_checkWidth, _refDir2];
		_testPosition2 set [2, _testHeight];

		private _intersectedObjects = lineIntersectsObjs [
			ATLtoASL _testPosition1,
			ATLtoASL _testPosition2
		];

		if (_object in _intersectedObjects) exitWith {};

		MCSS_GREEN_LINES pushBack [
			ATLtoASL _testPosition1,
			ATLtoASL _testPosition2
		];
	};

	private _startPosition2 = +_testPosition1;
	private _lastPosition1 = +_startPosition2;

	for "_i" from 0 to 50 step 0.1 do {
		private _testPosition3 = _startPosition2 getPos [_i, _refDir2];
		_testPosition3 set [2, _testHeight];

		private _testPosition4 = _testPosition3 getPos [0.1, _refDir2];
		_testPosition4 set [2, _testHeight];

		private _intersectedObjects = lineIntersectsObjs [
			ATLtoASL _testPosition3,
			ATLtoASL _testPosition4
		];

		if (_object in _intersectedObjects) exitWith {};

		MCSS_RED_LINES pushBack [
			ATLtoASL _testPosition3,
			ATLtoASL _testPosition4
		];

		_lastPosition1 = +_testPosition3;
	};

	_realCorners set [count _realCorners, _lastPosition1];
} forEach _bboxCorners;

private _finalCorners = _realCorners;

// player groupChat str _finalCorners;

{
	_x set [2, 0];

	private _marker = 'Sign_Sphere10cm_F' createVehicleLocal _x;
	_marker enableSimulation false;
	_marker setPos _x;

	MCSS_RealBB_Vehicles pushBack _marker;
} forEach _finalCorners;
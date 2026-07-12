// A3C_ai_shared_fnc_planeFindCarrierStorage

params ["_plane","_carrier"];

private _planeBbox = [_plane,0] call MCSS_fnc_getBoundingBox;
private _planeWidth = (_planeBbox select 0) distance2D (_planeBbox select 1);

private _storageData = [];

{
	private _carrierStorageOffset = _x select 0;
	private _carrierStorageDirOffset = _x select 1;

	private _testPosASL = ATLtoASL (_carrier modelToWorld _carrierStorageOffset);
	private _rayStartASL = [_testPosASL select 0, _testPosASL select 1, 200];
	private _rayEndASL = [_testPosASL select 0, _testPosASL select 1, -200];

	private _surfaceIntersections = lineIntersectsSurfaces [_rayStartASL,_rayEndASL,objNull,objNull];
	private _carrierSurfacePosASL = [];

	if (count _surfaceIntersections > 0) then {
		{
			private _intersectObject = _x select 2;

			if (["Land_Carrier_01",typeOf _intersectObject] call BIS_fnc_inString) exitWith {
				_carrierSurfacePosASL = _x select 0;
			};
		} forEach _surfaceIntersections;
	};

	private _nearBlockingObjects = if (count _carrierSurfacePosASL > 0) then {
		_carrierSurfacePosASL nearObjects _planeWidth
	} else {
		[]
	};

	{
		private _nearObject = _x;

		if ({_nearObject isKindOf _x} count ["CAR","TANK","HELICOPTER","JET","PLANE","staticWeapon","ReammoBox","ReammoBox_F"] == 0) then {
			_nearBlockingObjects = _nearBlockingObjects - [_nearObject];
		};
	} forEach _nearBlockingObjects;

	if (count _nearBlockingObjects == 0 && {!(_carrierSurfacePosASL isEqualTo [])}) exitWith {
		_carrierSurfacePosASL set [2,(_carrierSurfacePosASL select 2) + 1];

		_storageData = [
			_carrierSurfacePosASL,
			[(getDir _carrier) + _carrierStorageDirOffset] call MCSS_fnc_correctDir
		];
	};
} forEach A3C_CarrierArray;

_storageData
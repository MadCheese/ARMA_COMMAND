// MCSS_fnc_getBuildingRoofPositions

params ["_building"];

private _lastBuildingPosIndex = [_building] call MCSS_fnc_getLastBuildingPosIndex;
private _roofPositions = [];

for "_buildingPosIndex" from 0 to _lastBuildingPosIndex do {
	private _buildingPosATL = _building buildingPos _buildingPosIndex;
	private _buildingPosASL = ATLtoASL _buildingPosATL;

	_buildingPosASL set [2, (_buildingPosASL select 2) + 0.5];

	private _rayStartASL = +_buildingPosASL;
	_rayStartASL set [2, (_rayStartASL select 2) + 20];

	private _intersections = lineIntersectsSurfaces [
		_rayStartASL,
		_buildingPosASL,
		objNull,
		objNull,
		true,
		1,
		"GEOM",
		"NONE"
	];

	if ((count _intersections) == 0) then {
		_roofPositions pushBack [_buildingPosIndex, _buildingPosATL];
	};
};

_roofPositions
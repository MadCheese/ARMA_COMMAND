// A3C_main_fnc_buildingGetDoorDirection

//-- improvised function to get the direction of a door

params ["_building", "_doorPosition"];

private _buildingDirection = getDir _building;
private _doorDirectionOffset = 90;

private _firstCheckPosition = [_doorPosition, 0.15, _buildingDirection] call BIS_fnc_relPos;
private _secondCheckPosition = [_firstCheckPosition, 0.5, _buildingDirection] call BIS_fnc_relPos;

private _intersectsBuilding = _building in lineIntersectsObjs [
	ATLtoASL _firstCheckPosition,
	ATLtoASL _secondCheckPosition
];

if (_intersectsBuilding) then {
	_doorDirectionOffset = 90;
} else {
	_doorDirectionOffset = 0;
};

private _doorDirection = _buildingDirection + _doorDirectionOffset;

_doorDirection
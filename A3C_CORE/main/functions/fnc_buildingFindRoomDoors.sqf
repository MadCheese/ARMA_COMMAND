// A3C_main_fnc_buildingFindRoomDoors

//-- find 'room doors' for building position

params ["_building", "_roomPositionIds"];

private _doorPositions = [_building] call A3C_main_fnc_buildingGetDoorPositions;
private _roomDoorPositions = [];

private _fnc_countVisibleRoomPositions = {
	params ["_checkPosition"];

	private _checkPositionASL = ATLtoASL _checkPosition;

	{
		private _buildingPositionASL = ATLtoASL (_building buildingPos _x);

		!(_building in lineIntersectsWith [_buildingPositionASL, _checkPositionASL])
	} count _roomPositionIds
};

{
	private _doorPosition = _x;
	private _doorDirection = [_building, _doorPosition] call A3C_main_fnc_buildingGetDoorDirection;

	//-- check 'in front' and 'behind door'
	private _frontCheckPosition = [_doorPosition, 0.5, _doorDirection] call BIS_fnc_relPos;
	private _frontVisibleRoomPositionCount = [_frontCheckPosition] call _fnc_countVisibleRoomPositions;

	private _rearCheckPosition = [_doorPosition, 0.5, _doorDirection + 180] call BIS_fnc_relPos;
	private _rearVisibleRoomPositionCount = [_rearCheckPosition] call _fnc_countVisibleRoomPositions;

	private _visibleRoomPositionCount = _frontVisibleRoomPositionCount + _rearVisibleRoomPositionCount;
	private _matchingDoorIndex = -1;

	if (_visibleRoomPositionCount > 0) then {
		_matchingDoorIndex = _forEachIndex;
	};

	if (_matchingDoorIndex != -1) then {
		if (_visibleRoomPositionCount != -1) then {
			_roomDoorPositions pushBack _doorPosition;
		};
	};
} forEach _doorPositions;

if (count _roomDoorPositions > 1) then {
	_roomDoorPositions = [_roomDoorPositions, [], { _x distance2D (position _building) }, "ASCEND"] call BIS_fnc_sortBy;
};

_roomDoorPositions
// A3C_main_fnc_buildingCreateRooms

//-- Somewhat brute method to determine what building positions are part of the same room

params ["_building", "_buildingPosCount", "_roofSensitive"];

private _buildingPosArray = [];
private _rooms = [];

for "_i" from 1 to _buildingPosCount do { //-- SKIP 0 BECAUSE IT'S ENTRY POINT
	private _buildingPos = ATLtoASL (_building buildingPos _i);
	_buildingPos set [2, (_buildingPos select 2) + 0.2]; //-- 1.5

	if (_roofSensitive || { [ASLtoATL _buildingPos, _building] call A3C_main_fnc_isPositionInsideBuilding }) then {
		_buildingPosArray pushBackUnique [_i, _buildingPos];
	};
};

private _removePositions = [];
private _buildingType = typeOf _building;
private _defunctBuildingData = profileNamespace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []];

{
	_x params ["_defunctBuildingType", "_defunctPositions"];

	if (_defunctBuildingType == _buildingType) exitWith {
		_removePositions = _defunctPositions;
	};
} forEach _defunctBuildingData;

{
	private _buildingPosEntry = _x;
	_buildingPosEntry params ["_buildingPosIndex"];

	if (_buildingPosIndex in _removePositions) then {
		_buildingPosArray = _buildingPosArray - [_buildingPosEntry];
	};
} forEach _buildingPosArray;

//-- create rooms from positions that have LOS to each other
{
	_x params ["_buildingPosIndex", "_buildingPosASL"];

	private _buildingPosHeight = _buildingPosASL select 2;

	if ({ _buildingPosIndex in _x } count _rooms == 0) then { //-- problem: this way, a second room could be created because of a corner. Not too bad but could be addressed.
		private _roomPoses = [_buildingPosIndex];

		{
			_x params ["_refPosIndex", "_refPos"];

			private _refHeight = _refPos select 2;

			if ((abs (_buildingPosHeight - _refHeight)) < 1) then {
				private _intersectsObjs = lineIntersectsObjs [_buildingPosASL, _refPos, objNull, objNull, false];

				if !(_building in _intersectsObjs) then {
					//-- there's a direct LOS between positions
					_roomPoses pushBackUnique _refPosIndex;
				};
			};
		} forEach _buildingPosArray;

		_rooms pushBackUnique _roomPoses;
	};
} forEach _buildingPosArray;

//-- sloppy solution to the problem that doors are not picked up by INTERSECTS. Therefore, we need to find bpos-Id's that are in multiple rooms and reOrganize them
//-- step 1: bundle rooms with positions in question
{
	_x params ["_id"];

	if ({ _id in _x } count _rooms > 1) then {
		private _newArray = [];

		{
			private _room = _x;

			if (_id in _room) then {
				{
					_newArray pushBackUnique _x;
				} forEach _room;

				_rooms = _rooms - [_room];
			};
		} forEach _rooms;

		_rooms pushBack _newArray;
	};
} forEach _buildingPosArray;

//-- step 2: reOrganize roomPositions by distance from building center (not perfect but solves some issues)
{
	private _posArray = _x;
	private _sort = [_posArray, [], { (_building buildingPos _x) distance2D (position _building) }, "DESCEND"] call BIS_fnc_sortBy;

	_rooms set [_forEachIndex, _sort];
} forEach _rooms;

private _newFloorsArray = +_rooms; //-- to do: rename Variable
_rooms = [];

{
	private _roomPoses = _x;
	private _doorPoses = [_building, _roomPoses] call A3C_main_fnc_buildingFindRoomDoors;

	_rooms pushBack [_roomPoses, _doorPoses];
} forEach _newFloorsArray;

_rooms
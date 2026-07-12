// MCSS_fnc_getClosestBuildingPosition
// Mode:
// 0: ignore positions with intersects compared to _unitPosASL
// 1: include positions with intersects compared to _unitPosASL

params ["_unit", "_building", "_mode"];

private _unitPosASL = +getPosASL _unit;
_unitPosASL set [2, (_unitPosASL select 2) + 0.1];

private _lastBuildingPosIndex = [_building] call MCSS_fnc_getLastBuildingPosIndex;

if (_lastBuildingPosIndex == 0) exitWith {
	[]
};

private _buildingPositions = [];

for "_buildingPosIndex" from 0 to _lastBuildingPosIndex do {
	_buildingPositions pushBack (_building buildingPos _buildingPosIndex);
};

{
	if ((abs (((getPosATL _unit) select 2) - (_x select 2))) < 5) then {
		// Security: only skip occupied positions if the height difference is manageable.
		if (_x in A3C_OCCUPIED_BPOSES) then {
			_buildingPositions = _buildingPositions - [_x];
		};
	};
} forEach _buildingPositions;

if (_mode == 0) then {
	{
		if ((count (lineIntersectsObjs [
			ATLtoASL _x,
			_unitPosASL,
			_unit,
			objNull,
			false
		])) > 0) then {
			_buildingPositions = _buildingPositions - [_x];
		};

		private _unitPosRaisedASL = (_unitPosASL select [0, 2]) + [(_unitPosASL select 2) + 15];

		if ((count (lineIntersectsObjs [
			ATLtoASL _x,
			_unitPosRaisedASL,
			_unit,
			objNull,
			false
		])) > 0) then {
			_buildingPositions = _buildingPositions - [_x];
		};
	} forEach _buildingPositions;
};

if ((count _buildingPositions) == 0) then {
	// Security: there are no more unoccupied positions for the AI to choose from.
	// In this case, accept unit stacking.
	if ((count A3C_OCCUPIED_BPOSES) > 0) then {
		_buildingPositions = A3C_OCCUPIED_BPOSES;
	};
};

if ((count _buildingPositions) == 0) exitWith {
	[]
};

_buildingPositions = [
	_buildingPositions,
	[],
	{ _x distance _unit },
	"ASCEND"
] call BIS_fnc_sortBy;

_buildingPositions select 0
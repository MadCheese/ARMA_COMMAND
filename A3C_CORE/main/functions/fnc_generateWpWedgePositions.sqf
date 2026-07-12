// A3C_main_fnc_generateWpWedgePositions

params ["_pos", "_refGroups", "_amount", "_dir", "_spacing"];

private _positions = [_pos];
private _useWedge = true;

if (isOnRoad _pos && { !(_refGroups isEqualTo []) }) then {
	_useWedge = false;

	private _sortedRefGroups = [
		_refGroups,
		[],
		{ (vehicle leader _x) distance _pos },
		"ASCEND"
	] call BIS_fnc_sortBy;

	private _refGroup = _sortedRefGroups select 0;
	private _refWaypoints = waypoints _refGroup;

	private _isGroupOnFinalWP = currentWaypoint _refGroup >= count _refWaypoints;

	private _refPosStart = if (_isGroupOnFinalWP || { _refWaypoints isEqualTo [] }) then {
		position (vehicle leader _refGroup)
	} else {
		private _lastWaypoint = _refWaypoints select ((count _refWaypoints) - 1);
		waypointPosition [_refGroup, _lastWaypoint select 1]
	};

	private _nearRoads = _pos nearRoads 20;

	if (_nearRoads isEqualTo []) then {
		_useWedge = true;
	} else {
		private _currentRoad = _nearRoads select 0;
		private _usedRoads = [_currentRoad];

		_positions = [position _currentRoad];

		while { count _positions < count _sortedRefGroups } do {
			private _connectedRoads = (roadsConnectedTo _currentRoad) - _usedRoads;

			if (_connectedRoads isEqualTo []) exitWith {
				_useWedge = true;
			};

			_connectedRoads = [
				_connectedRoads,
				[],
				{ _x distance2D _refPosStart },
				"ASCEND"
			] call BIS_fnc_sortBy;

			_currentRoad = _connectedRoads select 0;
			_usedRoads pushBack _currentRoad;

			private _roadPos = position _currentRoad;
			private _slotIndex = (count _positions) min ((count _sortedRefGroups) - 1);
			private _currentGroup = _sortedRefGroups select _slotIndex;
			private _currentSpacing = 30 max sizeOf typeOf vehicle leader _currentGroup;

			private _lastPos = _positions select ((count _positions) - 1);

			if (_roadPos distance2D _lastPos > _currentSpacing) then {
				_positions pushBack _roadPos;
			};
		};
	};
};

if (_useWedge) then {
	_positions = [_pos];

	private _currentSpacing = _spacing;

	for "_i" from 0 to (_amount - 1) do {
		private _stepAngle = if ((_i % 2) == 0) then {
			(_dir + 180) + 45
		} else {
			(_dir + 180) - 45
		};

		if (_i != 0 && { (_i % 2) == 0 }) then {
			_currentSpacing = _currentSpacing + _spacing;
		};

		_positions pushBack ([_pos, _currentSpacing, _stepAngle] call BIS_fnc_relPos);
	};
};

_positions
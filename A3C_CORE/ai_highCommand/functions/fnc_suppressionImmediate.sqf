// A3C_ai_highCommand_fnc_suppressionImmediate

params ["_group", "_pos"];

private _waypointIndex = currentWaypoint _group;
private _playerUid = getPlayerUID player;
private _leader = leader _group;
private _leaderVehicle = vehicle _leader;
private _waypointPosition = getPosASL _leaderVehicle;
private _dirToTarget = _leaderVehicle getDir _pos;

private _markerName = format [
	"A3C_%1_MAIN_Mark_%2_%3",
	parseText "SUP",
	_playerUid,
	A3C_SUP_POLY_IND_MARK
];

private _polygon = [
	[
		_pos,
		_markerName,
		_waypointIndex
	]
] + ([
	_pos,
	_dirToTarget,
	"SUPPRESSION",
	true
] call A3C_ai_shared_fnc_polygonAreaCreate);

A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;

private _unitPolygons = _group getVariable ["A3C_UNIT_POLYS", []];
_unitPolygons = [_polygon] + _unitPolygons;

_group setVariable ["A3C_UNIT_POLYS", _unitPolygons, true];

[
	[
		_playerUid,
		_group,
		_waypointPosition,
		_markerName
	],
	{
		// Match the old remote helper's authority and group-locality checks.
		if (isNil "A3C_IsA3CServer") exitWith {};

		params ["_callerUID", "_group", "_waypointPosition", "_markerName"];

		if !([_callerUID, _group] call A3C_ai_highCommand_fnc_findExecutingMachine) exitWith {};

		private _existingWaypoints = waypoints _group;
		private _isFirstWaypoint = _existingWaypoints isEqualTo [] || {
			currentWaypoint _group > selectMax (_existingWaypoints apply {_x select 1})
		};

		// Insert BEFORE the current pending waypoint, including the final one.
		// Completed history remains in place; an exhausted route simply appends.
		private _insertIndex = if (_isFirstWaypoint) then {-1} else {currentWaypoint _group};
		private _waypoint = _group addWaypoint [_waypointPosition, -1, _insertIndex];
		private _insertedWaypointIndex = _waypoint select 1;

		_waypoint setWaypointType "SCRIPTED";
		_waypoint setWaypointScript format [
			"A3C_CORE\waypointScripts\wpScript_Suppression.sqf ['%1',%2,%3,%4,'%5']",
			_callerUID,
			["ARRIVAL", ""],
			["GoCode", "D"],
			_insertedWaypointIndex,
			_markerName
		];
		_waypoint showWaypoint "NEVER";

		// Keep polygon ordering; shift only references to displaced waypoints.
		private _unitPolygons = _group getVariable ["A3C_UNIT_POLYS", []];
		{
			private _polyData = _x select 0;
			if ((_polyData select 1) == _markerName) then {
				_polyData set [2, _insertedWaypointIndex];
			} else {
				if ((_polyData select 2) >= _insertedWaypointIndex) then {
					_polyData set [2, (_polyData select 2) + 1];
				};
			};
		} forEach _unitPolygons;
		_group setVariable ["A3C_UNIT_POLYS", _unitPolygons, true];

		_group setCurrentWaypoint _waypoint;

		// Notify clients using the actual insertion boundary.
		[
			[_group, _insertedWaypointIndex],
			A3C_ai_highCommand_fnc_onWaypointInsertedClient
		] remoteExec ["BIS_fnc_call", 0];
		[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls", 0];
	}
] remoteExec ["bis_fnc_call", 0];

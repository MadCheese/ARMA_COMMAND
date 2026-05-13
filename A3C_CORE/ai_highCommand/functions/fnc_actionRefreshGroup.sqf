private _selectedGroups = +A3C_SELECTED_HC_GROUPS_SETTINGS;
private _newGroups = [];

{
	private _oldGroup = _x;
	private _waypointData = [];
	private _groupID = groupID _oldGroup;
	private _currentWaypoint = currentWaypoint _oldGroup;
	private _oldGroupSide = side _oldGroup;
	private _oldGroupUnits = units _oldGroup;
	private _oldGroupWaypoints = waypoints _oldGroup;
	private _wpIndex = 0;

	private _allVariables = (allVariables _oldGroup) apply {
		private _name = _x;
		[_name, _oldGroup getVariable [_name, nil]]
	};

	{
		private _wp = _x;

		if ((_wp select 1) >= _currentWaypoint) then {
			_waypointData set [
				_wpIndex,
				[
					waypointBehaviour _wp,
					waypointCombatMode _wp,
					waypointCompletionRadius _wp,
					waypointDescription _wp,
					waypointFormation _wp,
					waypointName _wp,
					waypointPosition _wp,
					waypointScript _wp,
					waypointSpeed _wp,
					waypointStatements _wp,
					waypointTimeout _wp,
					waypointType _wp,
					waypointVisible _wp
				]
			];

			_wpIndex = _wpIndex + 1;
		};
	} forEach _oldGroupWaypoints;

	private _newGroup = createGroup _oldGroupSide;

	_oldGroupUnits joinSilent _newGroup;

	[_newGroup] call A3C_ai_highCommand_fnc_reInitGroupMovement;

	{
		_x params ["_name", "_val"];

		if (!isNil "_name" && {!isNil "_val"}) then {
			_newGroup setVariable [_name, _val, true];
		};
	} forEach _allVariables;

	deleteGroup _oldGroup;

	_newGroup setGroupIdGlobal [_groupID];

	{
		private _wpData = _x;
		private _wp = _newGroup addWaypoint [[0, 0, 0], 0];

		_wp setWaypointBehaviour (_wpData select 0);
		_wp setWaypointCombatMode (_wpData select 1);
		_wp setWaypointCompletionRadius (_wpData select 2);
		_wp setWaypointDescription (_wpData select 3);
		_wp setWaypointFormation (_wpData select 4);
		_wp setWaypointName (_wpData select 5);
		_wp setWaypointPosition [(_wpData select 6), 0];
		_wp setWaypointScript (_wpData select 7);
		_wp setWaypointSpeed (_wpData select 8);
		_wp setWaypointStatements (_wpData select 9);
		_wp setWaypointTimeout (_wpData select 10);
		_wp setWaypointType (_wpData select 11);
		_wp setWaypointVisible (_wpData select 12);
	} forEach _waypointData;

	private _newCurrentWaypoint = currentWaypoint _newGroup;
	private _wpPos = waypointPosition [_newGroup, _newCurrentWaypoint];
	private _leaderVehicle = vehicle leader _newGroup;

	if (_wpPos distance2D _leaderVehicle > 20) then {
		[_newGroup, _wpPos] call A3C_ai_shared_fnc_approachWaypointRegular;
	};

	private _newGroupUnits = units _newGroup;
	private _enabledVehicles = [];

	{
		private _unit = _x;
		private _vehicle = objectParent _unit;

		_unit enableAI "ALL";

		if (!isNull _vehicle) then {
			if !(_vehicle in _enabledVehicles) then {
				_vehicle enableAI "ALL";
				_enabledVehicles pushBack _vehicle;
			};
		};
	} forEach _newGroupUnits;

	[_newGroup] call A3C_ai_highCommand_fnc_reInitGroupMovement;
	_newGroups set [count _newGroups, _newGroup];

} forEach _selectedGroups;


if (visibleMap) then {
	A3C_SELECTED_UNITS = _newGroups;
} else {
	A3C_SELECTED_HC_GROUPS_SETTINGS = _newGroups;
	A3C_RD_UNITS = _newGroups;
};
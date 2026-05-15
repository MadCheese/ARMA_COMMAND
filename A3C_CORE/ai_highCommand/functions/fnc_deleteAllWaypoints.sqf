// A3C_ai_highCommand_fnc_deleteAllWaypoints


params ["_group"];
private _mode = if (count _this > 1) then {_this select 1} else {"ALL"};
private _waypoints = waypoints _group;

if (_mode == "ACTIVE") then {
	_waypoints = _waypoints select {_x select 1 >= currentWaypoint _group};
};
//-- reverse array because last
reverse _waypoints;
{
	if ((count (waypoints _group)) == 1) exitWith {};
	for "_i" from 1 to 10 do {
		if !(_x in (waypoints _group)) exitWith {};
		A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_x];
		deleteWaypoint _x;
	};
} foreach _waypoints;
private _leaderVic = vehicle leader _group;
private _standByPos = _leaderVic getPos [5, getDir _leaderVic];
((waypoints _group) select 0) setWaypointPosition [_standByPos, 0];
[leader _group, _standByPos] call A3C_ai_shared_fnc_doMove;


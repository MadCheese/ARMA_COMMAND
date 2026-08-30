// A3C_main_fnc_isWaypointRelevant

params ["_waypoint"];

_waypoint params [
	"_group",
	"_waypointIndex"
];

if (
	isNull _group
	|| {{alive _x} count units _group == 0}
) exitWith {
	false
};

private _waypoints =
	waypoints _group;

// The group may exist, but this waypoint index may not.
if !(_waypoint in _waypoints) exitWith {
	false
};

private _currentWaypoint =
	currentWaypoint _group;

// The waypoint is currently active or still ahead.
if (_waypointIndex >= _currentWaypoint) exitWith {
	true
};

// An upcoming CYCLE waypoint may return the group to an earlier waypoint.
_waypoints findIf {
	private _checkedIndex =
		_x select 1;

	_checkedIndex >= _currentWaypoint
	&& {_checkedIndex > _waypointIndex}
	&& {waypointType _x isEqualTo "CYCLE"}
} != -1
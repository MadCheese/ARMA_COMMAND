// A3C_main_fnc_resolveWaypointUID

params [
	"_group",
	"_waypointUID"
];

if (
	isNull _group
	|| {_waypointUID isEqualTo ""}
) exitWith {
	[]
};

private _matchingWaypoints =
	(waypoints _group) select {
		waypointName _x isEqualTo _waypointUID
	};

if (count _matchingWaypoints != 1) exitWith {
	[]
};

_matchingWaypoints select 0
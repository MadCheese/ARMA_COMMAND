// A3C_main_fnc_getWaypointUID

params ["_waypoint"];

if !([_waypoint] call A3C_main_fnc_isWaypointRelevant) exitWith {
	""
};

waypointName _waypoint
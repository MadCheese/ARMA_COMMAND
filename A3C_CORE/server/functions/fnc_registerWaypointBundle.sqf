// A3C_server_fnc_registerWaypointBundle

params [
	["_waypointBundle", [], [[]]]
];

if (!isServer) exitWith {};

if (count _waypointBundle < 2) exitWith {};

private _hasInvalidEntry =
	_waypointBundle findIf {
		!(_x isEqualType [])
		|| {count _x != 2}
		|| {!((_x select 0) isEqualType grpNull)}
		|| {isNull (_x select 0)}
		|| {!((_x select 1) isEqualType "")}
		|| {(_x select 1) isEqualTo ""}
		|| {(_x select 1) find "A3C_CONVOY_WP_" != 0}
	} != -1;

if (_hasInvalidEntry) exitWith {};

// Protect against the same registration request arriving twice.
if (_waypointBundle in A3C_WAYPOINT_BUNDLES) exitWith {};

A3C_WAYPOINT_BUNDLES pushBack _waypointBundle;

publicVariable "A3C_WAYPOINT_BUNDLES";
// A3C_main_fnc_getRelevantWaypointBundle

params ["_waypoint"];

if !([_waypoint] call A3C_main_fnc_isWaypointRelevant) exitWith {
	[]
};

private _waypointUID =
	waypointName _waypoint;

if (_waypointUID isEqualTo "") exitWith {
	[]
};

private _waypointIdentity = [
	_waypoint select 0,
	_waypointUID
];

private _waypointBundles =
	missionNamespace getVariable [
		"A3C_WAYPOINT_BUNDLES",
		[]
	];

private _bundleIndex =
	_waypointBundles findIf {
		_waypointIdentity in _x
	};

if (_bundleIndex == -1) exitWith {
	[]
};

private _storedBundle =
	_waypointBundles select _bundleIndex;

private _relevantBundle = [];

{
	_x params [
		"_group",
		"_uid"
	];

	private _resolvedWaypoint = [
		_group,
		_uid
	] call A3C_main_fnc_resolveWaypointUID;

	if (
		!(_resolvedWaypoint isEqualTo [])
		&& {
			[_resolvedWaypoint]
				call A3C_main_fnc_isWaypointRelevant
		}
	) then {
		_relevantBundle pushBack _resolvedWaypoint;
	};
} forEach _storedBundle;

// Ensure the originally requested waypoint survived resolution.
if !(_waypoint in _relevantBundle) exitWith {
	[]
};

_relevantBundle
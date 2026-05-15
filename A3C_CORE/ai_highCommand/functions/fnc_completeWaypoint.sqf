// A3C_ai_highCommand_fnc_completeWaypoint

params ["_group"];

private _currentWaypoint = currentWaypoint _group;
private _waypoints = waypoints _group;

// -- edit waypoint statements
private _hasCycleWaypoint = {
	waypointType _x == "CYCLE"
} count _waypoints > 0;


/*
	#UNCLEAR: need to verify if this changes behavior. Before it checked only the waypoint itself
	>> but if this works it's better as it would preserve the initial conditions
	>> it needs to be found out if this entire fnc is even fully needed apart from ui reaction.
*/

if (!_hasCycleWaypoint) then { 
	[_group, _currentWaypoint] setWaypointStatements ["false", ""];
};

// -- potential client reaction
[
	[_group, _currentWaypoint],
	{
		params ["_group", "_currentWaypoint"];

		if (isDedicated) exitWith {};

		// -- limit to friendly players who may have AI-command ability
		if ((side _group) getFriend (side player) < 0.6) exitWith {};

		// -- update UI for all relevant clients
		if (!isNil "A3C_ui_mapOverlay_fnc_completeWaypointUiResponse") then {
			[_group, _currentWaypoint] call A3C_ui_mapOverlay_fnc_completeWaypointUiResponse;
		};
	}
] remoteExec ["BIS_fnc_call", 0];
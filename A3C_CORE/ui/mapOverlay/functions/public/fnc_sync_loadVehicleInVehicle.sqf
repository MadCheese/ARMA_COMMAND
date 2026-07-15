// A3C_ui_mapOverlay_fnc_sync_loadVehicleInVehicle

//-- note: this could technically be in ai_highCommand - but since it's tied to map sync it's placed here.

private _hostWaypoint = [
	A3C_UI_MAP_SYNC_HOSTGROUP,
	A3C_UI_MAP_SYNC_HostWPI
];

private _synchronizedWaypoints = synchronizedWaypoints _hostWaypoint;

A3C_UI_MAP_SYNC_HOSTGROUP setVariable [
	"A3C_HC_SYNCWPS",
	_synchronizedWaypoints,
	true
]; //~~ necessary?

private _playerUid = getPlayerUID player;

private _hostPrecondition = [
	(waypointStatements _hostWaypoint) select 0,
	waypointTimeout _hostWaypoint
] call A3C_ai_highCommand_fnc_getConditionFromStatements;

_hostWaypoint setWaypointType "SCRIPTED";
_hostWaypoint setWaypointScript format [
	"A3C_CORE\fnc_AI\wpFncs\wpScript_LoadVehicleInVehicle.sqf ['%1',%2]",
	_playerUid,
	_hostPrecondition
];
_hostWaypoint setWaypointTimeout [0, 0, 0];

{
	private _precondition = [
		(waypointStatements _x) select 0,
		waypointTimeout _x
	] call A3C_ai_highCommand_fnc_getConditionFromStatements;

	_x setWaypointType "SCRIPTED";
	_x setWaypointScript format [
		"A3C_CORE\fnc_AI\wpFncs\wpScript_groupGetVehicleInVehicle.sqf ['%1',%2]",
		_playerUid,
		_precondition
	];
	_x setWaypointTimeout [0, 0, 0];
} forEach _synchronizedWaypoints;
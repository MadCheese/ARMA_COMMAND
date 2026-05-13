// A3C_ai_highCommand_fnc_suppressionImmediate

params ["_group", "_pos"];

private _waypointIndex = currentWaypoint _group + 1;
private _playerUid = getPlayerUID player;
private _leader = leader _group;
private _leaderVehicle = vehicle _leader;
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
] call A3C_SUP_CREATE_POLY);

A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;

private _unitPolygons = _group getVariable ["A3C_UNIT_POLYS", []];
_unitPolygons = [_polygon] + _unitPolygons;

_group setVariable ["A3C_UNIT_POLYS", _unitPolygons, true];

[
	[
		_playerUid,
		_leader,
		[["GoCode", "D"], "SUPPRESSION"],
		"LINE",
		_waypointIndex
	],
	A3C_HC_INSERT_ACTION_WP
] remoteExec ["bis_fnc_call", 0];
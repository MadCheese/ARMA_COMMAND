params [
	"_group",
	"_waypointPosition",
	"_target",
	"_callerUID",
	"_preCondition",
	"_postCondition",
	"_landingRailType",
	"_landingData",
	"_goCode",
	"_callerUID"
];

if ([_callerUID, _group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;

//-- Approach phase. Keep this loop tight enough that the rail receives a slow, stable aircraft.
while {true} do {
	_leader = leader _group;
	_leaderVehicle = vehicle _leader;

	if !(alive _leaderVehicle && {canMove _leaderVehicle}) exitWith {};

	private _distance2D = _leaderVehicle distance2D _waypointPosition;

	if (_distance2D < 200) exitWith {};

	[
		_group,
		_waypointPosition,
		30,     //-- final approach speed in km/h before landing rail takes over
		25,     //-- final approach altitude ATL
		1600,   //-- slowdown starts here; higher value helps fast VTOLs bleed momentum earlier
		350     //-- anti-overshoot damping starts here
	] call A3C_ai_shared_fnc_approachWaypointHelicopter;

	sleep (if (_distance2D < 500) then {0.5} else {1});
};

if !(alive _leaderVehicle && {canMove _leaderVehicle}) exitWith {};
if (_leaderVehicle getVariable ["A3C_isBeingRailed", false]) exitWith {};

_leaderVehicle setVariable ["A3C_isBeingRailed", true, true];

//-- ALERT: EVERY TIME THE WAYPOINT IS MOVED, THE SCRIPT GETS EXECUTED.
//-- Keep the rail handoff immediate after approach to avoid AI hover/repath gaps.

private _execFNC = {
	params [
		"_leaderVehicle",
		"_landingRailType",
		"_landingData",
		"_goCode",
		"_callerUID"
	];

	_landingData params ["_landingPosASL", "_landingVectorDir", "_forceDefaultLanding"];

	private _shouldExit = if (A3C_IsA3CServer) then {
		!isServer
	} else {
		getPlayerUID player != _callerUID
	};

	if (_shouldExit) exitWith {};

	private _railExitDescription = switch (_landingRailType) do {
		case "COMBAT LANDING": {
			_goCode
		};

		case "TRANSPORT UNLOAD": {
			"UNLOAD"
		};

		case "FULL LANDING": {
			"NONE"
		};

		default {
			"NONE"
		};
	};

	[
		[
			_leaderVehicle,
			_landingPosASL,
			_landingVectorDir,
			_landingRailType,
			_railExitDescription
		],
		A3C_ai_rail_fnc_helicopterLanding
	] remoteExec ["BIS_fnc_spawn", _leaderVehicle];
};

[
	[
		_leaderVehicle,
		_landingRailType,
		_landingData,
		_goCode,
		_callerUID
	],
	_execFNC
] remoteExec ["BIS_fnc_spawn", 0];

waitUntil {
	!(_leaderVehicle getVariable ["A3C_isBeingRailed", false])
};

sleep 2;

true
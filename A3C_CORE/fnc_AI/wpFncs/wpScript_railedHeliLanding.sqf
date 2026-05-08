//systemchat str _this;

params ["_group","_waypointPosition","_target","_callerUID","_preCondition","_postCondition","_landingRailType","_landingData","_goCode","_callerUID"];

if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

_wp = [_group,currentwaypoint _group];
//systemchat str _goCode;
/*
if (true) exitWith {
	for "_i" from 1 to 5 do {
		systemchat str _i;
		sleep 1;
	};
	_wp synchronizeWaypoint [];
	true
};
*/


private _leader = leader _group;
private _leaderVehicle = vehicle _leader;

while {true} do {
	if !(alive _leaderVehicle && {canMove _leaderVehicle}) exitWith {};
	if (_leaderVehicle distance2D _waypointPosition < 200) exitWith {};

	[
		_group,
		_waypointPosition,
		20,     //-- final approach speed in km/h before landing rail takes over
		25,     //-- final approach altitude ATL
		1600,   //-- slowdown starts here; higher value helps fast VTOLs bleed momentum earlier
		350     //-- anti-overshoot damping starts here
	] call A3C_ai_shared_fnc_approachWaypointHelicopter;

	sleep 1;
};

if (_leaderVehicle getVariable ["A3C_isBeingRailed", false]) exitWith {};

_leaderVehicle setVariable ["A3C_isBeingRailed", true, true];

//-- ALERT: EVERYTIME THE WAYPOINT IS MOVED, THE SCRIPT GETS EXECUTED!!


private _execFNC = {
	params ["_group","_leader","_leaderVic","_landingRailType","_landingData","_goCode","_callerUID"];
	_landingData params ["_landingPosASL","_landingVectorDir","_forceDefaultLanding"];


	_exitCondition = if (A3C_IsA3CServer) then {!isServer} else {getPlayerUID player != _callerUID};
	if (_exitCondition) exitWith {};
	
	_railExitDescription = switch (_landingRailType) do {
		case ("COMBAT LANDING") : {_goCode};
		case ("TRANSPORT UNLOAD") : {"UNLOAD"};
		case ("FULL LANDING") : {"NONE"};
	};
	

	[
		[
			_leaderVic,
			_landingPosASL,
			_landingVectorDir,
			_landingRailType,
			_railExitDescription
		],
		A3C_RAIL_HELI_LANDING
	] remoteExec ["bis_fnc_spawn",_leaderVic];
	
	

};

[
	[
		_group,
		_leader,
		_leaderVic,
		_landingRailType,
		_landingData,
		_goCode,
		_callerUID
	],
	_execFNC
] remoteExec ["bis_fnc_spawn",0];


//-- question: how to determine if script is completed, remotely?


waitUntil {!(_leaderVic getVariable ["A3C_isBeingRailed",false])};


sleep 2;
//systemchat 'wp rail done';
true



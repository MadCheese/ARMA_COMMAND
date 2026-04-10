//systemchat str _this;

params ["_group","_waypointPosition","_target","_callerUID","_preCondition","_postCondition","_landingRailType","_landingData","_goCode","_callerUID"];

if ([_callerUID,_group] call A3C_HC_WPScriptBlock) exitWith {};

[_group] call A3C_HC_ReInitGroupMovement;

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


//systemChat str _this;
private _leader = leader _group;
private _leaderVic = vehicle _leader;
[_group,_waypointPosition] call A3C_HC_MoveToWaypoint;


while {true} do {
	if !(alive _leaderVic && {canMove _leaderVic}) exitWith {};
	if (_leaderVic distance2D _waypointPosition < 200) exitWith {};
	sleep 1;
};

if (_leaderVic getVariable ["A3C_isBeingRailed",false]) exitWith {};
_leaderVic setVariable ["A3C_isBeingRailed",true,true];



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



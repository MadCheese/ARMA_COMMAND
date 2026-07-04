params ["_group", "_pos", "_target", "_callerUID", "_preCondition", "_postCondition"];

if ([_callerUID, _group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;
private _wp = [_group, currentWaypoint _group];

//-- terminate previous execution
private _currentActions = _group getVariable ["A3C_SCRIPTS", []];

{
	_x params ["_actionID", "_script"]; //-- move this to 'A3C_ai_highCommand_fnc_isWpScriptBlocked'???

	if ("landing_full" in toLower _actionID) then {
		terminate _script;
		_currentActions = _currentActions - [_x];
	};
} forEach _currentActions;

_group setVariable ["A3C_SCRIPTS", _currentActions, true]; //-- guarantee at least the 2 sec of no script so that old one can exit

private _vehicleConfig = configFile >> "CfgVehicles" >> typeOf _leaderVehicle;

//-- determine landing distance
private _landingDistance = (getNumber (_vehicleConfig >> "precision")) + 50;

private _shouldContinueApproach = {
	params ["_vehicle", "_destinationPos", "_landingDistance"];

	!unitReady driver _vehicle || {
		_vehicle distance2D _destinationPos > (_landingDistance * 2)
	}
};



private _groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;


//-- default enabling all vehicles
{
	_x flyInHeight (_x getVariable ["A3C_FLYINHEIGHT", 75]);
	_x limitSpeed 5000;
} foreach _groupVehicles;


while {[_leaderVehicle, _pos, _landingDistance] call _shouldContinueApproach} do {
	_leader = leader _group;
	_leaderVehicle = vehicle _leader; //-- has to be refreshed in case of crash

	if !(alive _leaderVehicle && {canMove _leaderVehicle}) exitWith {};

	private _wpPos = waypointPosition _wp;

	//-- Compare waypoint movement in 2D only; preserve original Z/ATL/ASL data in _pos.
	private _pos2D = +_pos;
	private _wpPos2D = +_wpPos;

	{
		_x set [2, 0];
	} forEach [_pos2D, _wpPos2D];

	if !(_pos2D isEqualTo _wpPos2D) then {
		_pos = _wpPos;
	};

	private _distance2D = _leaderVehicle distance2D _pos;

	[
		_group,
		_pos,
		30,     //-- final approach speed in km/h before combat landing logic takes over
		25,     //-- final approach altitude ATL
		1600,   //-- slowdown starts here; higher value helps fast VTOLs bleed momentum earlier
		350     //-- anti-overshoot damping starts here
	] call A3C_ai_shared_fnc_approachWaypointHelicopter;

	sleep ([_leaderVehicle, _distance2D] call A3C_ai_highCommand_fnc_getHeliWaypointSleep);
};

//-- refresh _groupVehicles
_groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;

{
	_x limitSpeed 5000;
} forEach _groupVehicles; //-- release slowdown after approach / before combat landing handling

//-- compose pre- and post conditions, wait for pre-condition
private _exitCondition = {};

{
	_x params ["_conditionType", "_conditionValue"];

	_exitCondition = switch (toUpper _conditionType) do {
		case "TIMEOUT": {
			private _timeAtCompletion = time + _conditionValue;
			compile format ["time > %1", _timeAtCompletion]
		};

		case "GOCODE": {
			compile format ["A3C_GoCode_Activate_%1", _conditionValue]
		};

		case "DAYTIME": {
			private _conditionParts = _conditionValue splitString ":";
			private _checkParams = [];

			{
				_checkParams pushBack parseNumber _x;
			} forEach _conditionParts;

			compile format ["%1 call A3C_main_fnc_isDaytimeCompleted", _checkParams]
		};

		default {
			{true}
		};
	};

	if (_forEachIndex == 0) then {
		waitUntil {
			[] call _exitCondition
		}; //-- _forEachIndex == 0 is for pre-condition

		if !((_preCondition select 0) in ["ARRIVAL", ""]) then {
			_wp setWaypointScript format [
				"A3C_CORE\fnc_AI\wpFncs\wpScript_Landing_Combat.sqf ['%1',%2,%3]",
				_callerUID,
				["ARRIVAL", ""],
				_postCondition
			];

			_wp setWaypointPosition [_pos, 0];

			private _statements = waypointStatements _wp;
			_statements set [0, "true"];

			_wp setWaypointStatements _statements;
		};
	};
} forEach [_preCondition, _postCondition];



//-- Problems with landing: we would want to:
//-- 1: Create helipads to land on
//-- 2: Add touchdown eventhandlers 
//-- BUT: these would need to be managed as they will remain as residue if waypoint is reset. 
//-- result: we currently still raw-dog landings with rudimental 'ground gluing' and no helipads for assisted landing
private _vehiclesLanding = [];

waitUntil {

	_vehiclesLanding = [_group, _vehiclesLanding] call A3C_ai_highCommand_fnc_wpActionLandingTick;

	sleep 0.1;

	[] call _exitCondition
};

private _isFinalWP = [_group] call A3C_main_fnc_isGroupOnFinalWP;

//-- refresh _groupVehicles
_groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;

if !(_isFinalWP) then {
	{
		_x land "NONE";
	} forEach _groupVehicles;
};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls", 0]; //-- check gocodes and assign color



true
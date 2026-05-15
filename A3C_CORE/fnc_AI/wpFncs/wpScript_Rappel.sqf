//-- REQUIRED PARAMETERS. ADD CUSTOM PARAMETERS AS YOU WISH.
params [
	"_group",
	"_pos",
	"_target",
	"_callerUID",
	"_preCondition", //-- _preCondition: ARRAY >> example: ["GOCODE", "A"]
	"_postCondition", //-- _postCondition: ARRAY >> example: ["GOCODE", "A"]
	"_wpFormation",
	"_casMode"
];

if ([_callerUID, _group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

private _wpIndex = currentWaypoint _group;
private _wp = [_group, _wpIndex];
private _leader = leader _group;
private _leaderVehicle = vehicle _leader;
private _precision = (getNumber (configFile >> "CfgVehicles" >> typeOf _leaderVehicle >> "precision")) * 1.3;

//-- WAIT FOR ARRIVAL
while {_leaderVehicle distance2D _pos >= _precision} do {
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
		40,     //-- final approach speed in km/h before rail/rappel logic takes over
		25,     //-- final approach altitude ATL
		1600,   //-- slowdown starts here; higher value helps fast VTOLs bleed momentum earlier
		350     //-- anti-overshoot damping starts here
	] call A3C_ai_shared_fnc_approachWaypointHelicopter;

	sleep (if (_distance2D < 500) then {0.5} else {1});
};

//-- CONDITIONS: Step 1
private _exitCondition = {true};

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

	//-- Pre-condition other than 'arrival' waits and re-triggers waypoint script.
	//-- When script is re-triggered, condition is satisfied and script continues.
	//-- Second cycle is only relevant if post-condition exists. In that case, _exitCondition is stored for later reference.
	if (_forEachIndex == 0) then {
		waitUntil {
			[] call _exitCondition
		};

		if !((_preCondition select 0) in ["ARRIVAL", ""]) then {
			private _wpScript = waypointScript _wp;

			if ("[" in _wpScript) then {
				//-- Assign new params for script re-trigger.
				private _wpScriptParts = _wpScript splitString " ";
				_wpScriptParts params ["_scriptPath", "_scriptParamsRaw"];

				private _scriptParams = call compile _scriptParamsRaw;
				_scriptParams set [1, ["ARRIVAL", ""]];
				_scriptParams set [2, _postCondition];

				_wpScript = format ["%1 %2", _scriptPath, str _scriptParams];
			};

			_wp setWaypointScript _wpScript;
			_wp setWaypointPosition [_pos, 0];

			private _statements = waypointStatements _wp;
			_statements set [0, "true"];

			_wp setWaypointStatements _statements;
		};
	};
} forEach [_preCondition];

//-------------------------------//
//-- INSERT ACTION SCRIPT here --//
//-------------------------------//
private _currentActions = _group getVariable ["A3C_SCRIPTS", []];

private _rappelScript = [
	driver _leaderVehicle,
	_leader,
	_pos
] spawn A3C_ai_shared_fnc_actionAircraftRappell;

_currentActions pushBack ["rappel", _rappelScript];
_group setVariable ["A3C_SCRIPTS", _currentActions, true];

//-- CONDITIONS: Step 2
waitUntil {
	[] call _exitCondition
};

//-- SCRIPT END
[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls", 0]; //-- check gocodes and assign color

true;
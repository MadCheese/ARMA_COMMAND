params ["_group", "_pos", "_target", "_callerUID", "_preCondition", "_postCondition"];

if ([_callerUID, _group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;
private _wp = [_group, currentWaypoint _group];

//-- terminate previous execution
private _currentActions = _group getVariable ["A3C_SCRIPTS", []];

{
	_x params ["_actionID", "_script"];

	if ("landing_full" in toLower _actionID) then {
		terminate _script;
		_currentActions = _currentActions - [_x];
	};
} forEach _currentActions;

_group setVariable ["A3C_SCRIPTS", _currentActions, true]; //-- guarantee at least the 2 sec of no script so that old one can exit

private _isHoverCapableAircraft =
	_leaderVehicle isKindOf "HELICOPTER"
	|| {_leaderVehicle isKindOf "VTOL_Base_F"}
	|| {_leaderVehicle isKindOf "VTOL_01_base_F"}
	|| {_leaderVehicle isKindOf "VTOL_02_base_F"};

private _isConventionalPlane = !_isHoverCapableAircraft && {_leaderVehicle isKindOf "PLANE"};

private _vehicleConfig = configFile >> "CfgVehicles" >> typeOf _leaderVehicle;

//-- determine landing distance
private _landingDistance = if (
	_isConventionalPlane &&
	{(getNumber (_vehicleConfig >> "landingSpeed")) > 10}
) then {
	5000
} else {
	(getNumber (_vehicleConfig >> "precision")) + 50
};

private _shouldContinueApproach = {
	params ["_vehicle", "_destinationPos", "_landingDistance", "_isConventionalPlane"];

	if (_isConventionalPlane) exitWith {
		_vehicle distance2D _destinationPos > _landingDistance
	};

	!unitReady driver _vehicle || {
		_vehicle distance2D _destinationPos > (_landingDistance * 2)
	}
};

//-- WAIT FOR ARRIVAL / APPROACH
while {[_leaderVehicle, _pos, _landingDistance, _isConventionalPlane] call _shouldContinueApproach} do {
	_leader = leader _group;
	_leaderVehicle = vehicle _leader;

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

	if (_isHoverCapableAircraft) then {
		[
			_group,
			_pos,
			40,     //-- final approach speed in km/h before landing action takes over
			25,     //-- final approach altitude ATL
			1600,   //-- slowdown starts here; higher value helps fast VTOLs bleed momentum earlier
			350     //-- anti-overshoot damping starts here
		] call A3C_ai_shared_fnc_approachWaypointHelicopter;
	} else {
		[_group, _pos] call A3C_ai_shared_fnc_approachWaypointRegular;
	};

	sleep (if (_isHoverCapableAircraft) then {
		if (_distance2D < 500) then {0.75} else {1.25}
	} else {
		5
	});
};

private _drivers = units _group select {
	private _vehicle = objectParent _x;
	!isNull _vehicle && {_x == driver _vehicle}
};

private _drivenVehicles = _drivers apply {
	vehicle _x
};

{
	_x limitSpeed 5000;
} forEach _drivenVehicles; //-- reset slowdown

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

			compile format ["%1 call A3C_fnc_DAYTIME_COMPLETED", _checkParams]
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
				"A3C_CORE\fnc_AI\wpFncs\wpScript_Landing.sqf ['%1',%2,%3]",
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

if !(_isHoverCapableAircraft) then {
	sleep 2;
};

private _landingScript = [_leader, _pos, _callerUID, [], true] spawn A3C_ai_highCommand_fnc_wpAction_landingFull;

_currentActions pushBack ["landing_full_1", _landingScript];
_group setVariable ["A3C_SCRIPTS", _currentActions, true];

[_group, _wp] spawn {
	params ["_group", "_wp"];

	private _currentActions = [];

	waitUntil {
		sleep 1;

		_currentActions = _group getVariable ["A3C_SCRIPTS", []];

		private _currentWaypointIndex = currentWaypoint _group;

		({"landing_full" in (_x select 0)} count _currentActions == 0) || {
			_currentWaypointIndex != (_wp select 1) || {
				waypointType [_group, _currentWaypointIndex] != "SCRIPTED" || {
					private _waypointScript = waypointScript [_group, _currentWaypointIndex];
					!("wpscript_landing.sqf" in toLower _waypointScript)
				}
			}
		}
	};

	A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_wp];

	{
		_x params ["_actionID", "_script"];

		if ("landing_full" in _actionID) then {
			_currentActions = _currentActions - [_x];
			terminate _script;
		};
	} forEach _currentActions;

	_group setVariable ["A3C_SCRIPTS", if (count _currentActions > 0) then {_currentActions} else {nil}, true];

	{
		private _vehicle = objectParent _x;

		if (!isNull _vehicle && {_x == driver _vehicle && {((getPosATL _vehicle) select 2) > 1 && {_vehicle isKindOf "AIR"}}}) then {
			_vehicle land "NONE";
			_x setVariable ["A3C_VAR_LANDING", nil, true];
		};
	} forEach units _group;

	_group setVariable ["A3C_ISwpLANDING", nil, true];
};

waitUntil {
	scriptDone _landingScript
};

private _isStillLanding = {
	params ["_unit"];

	private _vehicle = objectParent _unit;

	!isNull _vehicle && {
		_unit == driver _vehicle && {
			!isTouchingGround _vehicle && {
				speed _vehicle > 0 && {
					_vehicle isKindOf "AIR"
				}
			}
		}
	}
};

waitUntil {
	sleep 1;

	{[_x] call _isStillLanding} count units _group == 0
};

sleep 15;

_currentActions = _group getVariable ["A3C_SCRIPTS", []];

{
	if ("landing_full" in (_x select 0)) then {
		_currentActions = _currentActions - [_x];
	};
} forEach _currentActions;

_group setVariable ["A3C_SCRIPTS", if (count _currentActions > 0) then {_currentActions} else {nil}, true];

A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_wp];
publicVariable "A3C_BLACKLIST_WAYPOINT_EDIT";

true
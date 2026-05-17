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

private _isHoverCapableAircraft =
	_leaderVehicle isKindOf "HELICOPTER"
	|| {_leaderVehicle isKindOf "VTOL_Base_F"}
	|| {_leaderVehicle isKindOf "VTOL_01_base_F"}
	|| {_leaderVehicle isKindOf "VTOL_02_base_F"};

private _addRadius = if (_leaderVehicle isKindOf "AIR") then {50} else {0};

private _vehicleConfig = configFile >> "CfgVehicles" >> typeOf _leaderVehicle;

//-- determine landing distance
private _landingDistance = (getNumber (_vehicleConfig >> "precision")) + _addRadius;

private _shouldContinueApproach = {
	params ["_vehicle", "_landingDistance"];

	!unitReady driver _vehicle || {
		_vehicle distance2D _pos > (_landingDistance * 2)
	}
};

while {[_leaderVehicle, _landingDistance] call _shouldContinueApproach} do {
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

	if (_isHoverCapableAircraft) then {
		[
			_group,
			_pos,
			30,     //-- final approach speed in km/h before unload / GET IN landing logic takes over
			25,     //-- final approach altitude ATL
			1600,   //-- slowdown starts here; higher value helps fast VTOLs bleed momentum earlier
			350     //-- anti-overshoot damping starts here
		] call A3C_ai_shared_fnc_approachWaypointHelicopter;

		sleep (if (_distance2D < 500) then {0.5} else {1});
	} else {
		[_group, _pos] call A3C_ai_shared_fnc_approachWaypointRegular;

		sleep 2;
	};
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
} forEach _drivenVehicles; //-- release slowdown after approach / before unload handling

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

private _vehiclesMoved = [];
private _vehiclesLanding = [];

waitUntil {
	private _groupVehicles = [];

	{
		private _vehicle = vehicle _x;
		private _driver = driver _vehicle;

		if (_x == effectiveCommander _x) then {
			private _isHoverCapableVehicle =
				_vehicle isKindOf "HELICOPTER"
				|| {_vehicle isKindOf "VTOL_Base_F"}
				|| {_vehicle isKindOf "VTOL_01_base_F"}
				|| {_vehicle isKindOf "VTOL_02_base_F"};

			if (_isHoverCapableVehicle) then {
				if !(isTouchingGround _vehicle) then {
					[
						_group,
						_pos,
						10,     //-- final unload speed in km/h
						4,      //-- low final altitude ATL before GET IN landing behavior takes over
						500,    //-- short approach envelope; main approach already happened
						150     //-- soft anti-overshoot damping near unload point
					] call A3C_ai_shared_fnc_approachWaypointHelicopter;

					_vehicle flyInHeight 0;

					if !(_vehicle in _vehiclesLanding) then {
						_vehicle land "GET IN";
						_vehiclesLanding pushBack _vehicle;
					};
				} else {
					_vehicle flyInHeight 0;

					private _crewNonGroup = crew _vehicle select {
						group _x != group _driver &&
						{
							assignedVehicle _x == _vehicle
						}
					};

					if !(_crewNonGroup isEqualTo []) then {
						{
							[
								[_x],
								{
									params ["_unit"];

									[_unit] call A3C_AIGetOut;
								}
							] remoteExec ["BIS_fnc_call", _x];
						} forEach _crewNonGroup;
					};
				};
			} else {
				if (!(_vehicle in _vehiclesMoved) && {!(isTouchingGround _vehicle)}) then {
					_vehicle doMove _pos;
					_vehicle moveTo _pos;
					_vehiclesMoved pushBack _vehicle;
				} else {
					if !(isTouchingGround _vehicle) then {
						_vehicle land "GET IN";
						_vehiclesLanding pushBack _vehicle;
					} else {
						_vehicle flyInHeight 0; //-- is this ever executed really? it should be, but check

						private _crewNonGroup = crew _vehicle select {
							group _x != group _driver &&
							{
								assignedVehicle _x == _vehicle
							}
						};

						if !(_crewNonGroup isEqualTo []) then {
							{
								[
									[_x],
									{
										params ["_unit"];

										[_unit] call A3C_AIGetOut;
									}
								] remoteExec ["BIS_fnc_call", _x];
							} forEach _crewNonGroup;
						};
					};
				};
			};

			_groupVehicles pushBack _vehicle;
		};
	} forEach units _group;

	_vehiclesMoved = _vehiclesMoved arrayIntersect _groupVehicles;
	_vehiclesLanding = _vehiclesLanding arrayIntersect _groupVehicles;

	sleep 1;

	private _doExit = {
		private _vehicle = objectParent _x;

		!isNull _vehicle &&
		{
			_x == driver _vehicle &&
			{
				canMove _vehicle &&
				{
					{!(_x in units _group)} count crew _vehicle > 0
				}
			}
		}
	} count units _group == 0;

	_doExit
};

if !([_group] call A3C_main_fnc_isGroupOnFinalWP) then {
	{
		private _vehicle = vehicle _x;

		if (_x == effectiveCommander _x && {_vehicle isKindOf "HELICOPTER"}) then {
			_vehicle land "NONE";
		};
	} forEach units _group;
};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls", 0]; //-- check gocodes and assign color

true
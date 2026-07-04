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

private _isHoverCapableAircraft = [_leaderVehicle] call A3C_main_fnc_canHoverAircraft;

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

private _vehiclesLanding = [];

//-- Cache the TR unload vehicle kind per vehicle.
//-- This keeps the expensive/semantic checks to one classification per vehicle object.
private _fnc_getTRUnloadVehicleKind = {
	params ["_vehicle"];

	private _vehicleKind = _vehicle getVariable ["A3C_TR_UNLOAD_KIND", ""];

	if (_vehicleKind isNotEqualTo "") exitWith {
		_vehicleKind
	};

	_vehicleKind = if ([_vehicle] call A3C_main_fnc_canHoverAircraft) then {
		"HOVER"
	} else {
		if (_vehicle isKindOf "Air") then {
			"IGNORE"
		} else {
			"GROUND"
		};
	};

	_vehicle setVariable ["A3C_TR_UNLOAD_KIND", _vehicleKind, false];

	_vehicleKind
};

// private _fnc_unloadNonGroupCrew = {
// 	params ["_vehicle", "_groupUnits"];

// 	private _crewNonGroup = crew _vehicle select {
// 		!(_x in _groupUnits) &&
// 		{
// 			assignedVehicle _x == _vehicle
// 		}
// 	};

// 	if (_crewNonGroup isNotEqualTo []) then {
// 		{
// 			[
// 				[_x],
// 				{
// 					params ["_unit"];

// 					[_unit] call A3C_AIGetOut;
// 				}
// 			] remoteExec ["BIS_fnc_call", _x];
// 		} forEach _crewNonGroup;
// 	};
// };

private _fnc_unloadNonGroupCrew = {
	params ["_vehicle"];

	private _driver = driver _vehicle;

	_groupUnits = units group _driver;
	private _crewNonGroup = (crew _vehicle) select {
		!(_x in _groupUnits)
	};

	private _cargoGroups = [];



	{
		private _unitGroup = group _x;
		if !(_unitGroup in _cargoGroups) then {
			_cargoGroups set [count _cargoGroups, _unitGroup];
		};
	} foreach _crewNonGroup;

	

	[_vehicle, _driver, _crewNonGroup] spawn {
		params ["_vehicle", "_driver","_crewNonGroup"];
		waitUntil {
			// _vehicle flyInHeight 0;
			// _vehicle setVelocity [0,0,-0.5]; //-- OVERRIDE HELI COMPULSION TO LIFT OFF
			_vehicle land "GET IN";
			_vehicle flyinHeight 0;

			{
				_x in _crewNonGroup && {alive _x}
			} count (crew _vehicle) == 0
		};
	};

	{
		[_x, _vehicle] remoteExec ["leaveVehicle", leader _x];
	} foreach _cargoGroups;

	// _vehicle land "GET IN";
	// _vehicle flyinHeight 0;
};



waitUntil {
	private _groupUnits = units _group;
	private _processedVehicles = [];
	private _actionableVehicles = [];

	{
		private _vehicle = objectParent _x;

		if (!isNull _vehicle && {!(_vehicle in _processedVehicles)}) then {
			_processedVehicles pushBack _vehicle;

			private _driver = driver _vehicle;

			if (!isNull _driver && {_driver in _groupUnits}) then {
				private _vehicleKind = [_vehicle] call _fnc_getTRUnloadVehicleKind;

				switch (_vehicleKind) do {
					case "HOVER": {
						if !(isTouchingGround _vehicle) then {
							if !(_vehicle in _vehiclesLanding) then {
								_vehicle land "GET IN";
								// _vehicle flyInHeight 0;
								_vehiclesLanding pushBack _vehicle;
							};
						} else {
							[_vehicle] call _fnc_unloadNonGroupCrew;
							_vehicle flyInHeight 0;
						};

						_actionableVehicles pushBack _vehicle;
					};

					case "GROUND": {
						//-- Ground vehicles unload in place once the approach phase has completed.
						//-- Do not issue final moveTo/doMove commands here; that causes convoy clumping.
						[_vehicle] call _fnc_unloadNonGroupCrew;

						_actionableVehicles pushBack _vehicle;
					};

					default {
						//-- Non-hover aircraft and other ignored vehicles receive no TR unload actions.
					};
				};
			};
		};
	} forEach _groupUnits;

	_vehiclesLanding = _vehiclesLanding arrayIntersect _actionableVehicles;

	sleep 1;

	// systemchat str [_actionableVehicles, _vehiclesLanding];

	//-- Refresh group units after sleep so recently unloaded units do not keep blocking exit.
	_groupUnits = units _group;

	private _doExit = {
		canMove _x &&
		{
			{
				!(_x in _groupUnits)
			} count (crew _x) > 0
		}
	} count _actionableVehicles == 0;



	_doExit
};


if !([_group] call A3C_main_fnc_isGroupOnFinalWP) then {
	{
		private _vehicle = vehicle _x;

		if (_x == effectiveCommander _vehicle && {_vehicle isKindOf "HELICOPTER"}) then {
			_vehicle land "NONE";
		};
	} forEach units _group;
};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls", 0]; //-- check gocodes and assign color

true
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

_group setVariable [
	"A3C_SCRIPTS",
	_currentActions,
	true
]; //-- guarantee at least the 2 sec of no script so that old one can exit

private _isLeaderVTOL =
	getNumber (configOf _leaderVehicle >> "vtol") > 0;

private _vehicleConfig =
	configFile >> "CfgVehicles" >> typeOf _leaderVehicle;

//-- determine landing distance
private _landingDistance =
	(getNumber (_vehicleConfig >> "precision")) +
	(if (_isLeaderVTOL) then {
		100
	} else {
		50
	});

private _shouldContinueApproach = {
	params [
		"_vehicle",
		"_destinationPos",
		"_landingDistance"
	];

	_vehicle distance2D _destinationPos >
		(_landingDistance * 2)
};

private _groupVehicles =
	[_group] call A3C_main_fnc_getGroupDrivenVehicles;

//-- default enabling all vehicles
{
	_x flyInHeight (
		_x getVariable [
			"A3C_FLYINHEIGHT",
			75
		]
	);

	_x limitSpeed 9999;
} forEach _groupVehicles;

//-- wait for arrival / approach
while {
	[
		_leaderVehicle,
		_pos,
		_landingDistance
	] call _shouldContinueApproach
} do {
	_leader = leader _group;
	_leaderVehicle = vehicle _leader; //-- has to be refreshed in case of crash

	if !(alive _leaderVehicle && {canMove _leaderVehicle}) exitWith {};

	_isLeaderVTOL =
		getNumber (configOf _leaderVehicle >> "vtol") > 0;

	private _wpPos = waypointPosition _wp;

	//-- Compare waypoint movement in 2D only; preserve original Z/ATL/ASL data in _pos.
	private _pos2D = +_pos;
	private _wpPos2D = +_wpPos;

	{
		_x set [2, 0];
	} forEach [
		_pos2D,
		_wpPos2D
	];

	if !(_pos2D isEqualTo _wpPos2D) then {
		_pos = _wpPos;
	};

	private _distance2D =
		_leaderVehicle distance2D _pos;

	if (_isLeaderVTOL) then {
		/*
			VTOL approach helper is deliberately movement-command-free.

			The active waypoint remains solely responsible for navigation.
			The helper only shapes altitude, speed and horizontal momentum.
		*/
		[
			_group,
			_pos,
			90,     //-- controlled forward speed near the landing handoff area
			60,     //-- ATL approach altitude; landAt owns the final descent
			3000,   //-- VTOL slowdown starts substantially earlier
			1000    //-- minimum anti-overshoot damping envelope
		] call A3C_ai_shared_fnc_approachWaypointVTOL;
	} else {
		/*
			Existing helicopter approach behavior remains unchanged for all
			non-VTOL groups using this waypoint.
		*/
		[
			_group,
			_pos,
			30,     //-- final approach speed in km/h before combat landing logic takes over
			25,     //-- final approach altitude ATL
			1600,   //-- slowdown starts here
			350     //-- anti-overshoot damping starts here
		] call A3C_ai_shared_fnc_approachWaypointHelicopter;
	};

	sleep (
		[
			_leaderVehicle,
			_distance2D
		] call A3C_ai_highCommand_fnc_getHeliWaypointSleep
	);
};

//-- refresh _groupVehicles
_groupVehicles =
	[_group] call A3C_main_fnc_getGroupDrivenVehicles;

{
	_x limitSpeed 9999;
} forEach _groupVehicles; //-- release slowdown after approach / before combat landing handling

//-- compose pre- and post conditions, wait for pre-condition
private _exitCondition = {};

{
	_x params [
		"_conditionType",
		"_conditionValue"
	];

	_exitCondition = switch (toUpper _conditionType) do {
		case "TIMEOUT": {
			private _timeAtCompletion =
				time + _conditionValue;

			compile format [
				"time > %1",
				_timeAtCompletion
			]
		};

		case "GOCODE": {
			compile format [
				"A3C_GoCode_Activate_%1",
				_conditionValue
			]
		};

		case "DAYTIME": {
			private _conditionParts =
				_conditionValue splitString ":";

			private _checkParams = [];

			{
				_checkParams pushBack parseNumber _x;
			} forEach _conditionParts;

			compile format [
				"%1 call A3C_main_fnc_isDaytimeCompleted",
				_checkParams
			]
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
				"A3C_CORE\waypointScripts\wpScript_Landing_Combat.sqf ['%1',%2,%3]",
				_callerUID,
				["ARRIVAL", ""],
				_postCondition
			];

			_wp setWaypointPosition [
				_pos,
				0
			];

			private _statements =
				waypointStatements _wp;

			_statements set [
				0,
				"true"
			];

			_wp setWaypointStatements _statements;
		};
	};
} forEach [
	_preCondition,
	_postCondition
];

private _vehiclesLanding = [];

private _landingSpacing = _group getVariable [
	"A3C_HELI_LANDING_SPACING",
	30
];

private _heliLandingSlots = [
	_group,
	_pos,
	_landingSpacing,
	_leaderVehicle
] call A3C_ai_shared_fnc_getHeliGroupLandingSlots;

private _fnc_getHeliLandingPosition = {
	params [
		"_vehicle",
		"_landingSlots",
		"_fallbackPos"
	];

	private _slot = _landingSlots select {
		(_x select 0) == _vehicle
	};

	if (_slot isEqualTo []) exitWith {
		+_fallbackPos
	};

	+((_slot select 0) select 1)
};

private _currentDrivenVehicles =
	[_group] call A3C_main_fnc_getGroupDrivenVehicles;

/*
	Separate helicopters and VTOLs so that their landing states can be
	maintained independently.

	VTOL classification takes priority in case a modded VTOL also inherits
	from a helicopter base class.
*/
private _groupVTOLs = _currentDrivenVehicles select {
	getNumber (configOf _x >> "vtol") > 0
};

private _groupHelicopters = _currentDrivenVehicles select {
	_x isKindOf "HELICOPTER" &&
	{!(_x in _groupVTOLs)}
};

/*
	Existing helicopter landing behavior remains unchanged.

	Helicopters receive the established one-shot Get Out landAt command.
*/
{
	private _vehicle = _x;

	private _landingPos = [
		_vehicle,
		_heliLandingSlots,
		_pos
	] call _fnc_getHeliLandingPosition;

	_vehicle landAt [
		_landingPos,
		"Get Out",
		99999
	];

	if !(_vehicle in _vehiclesLanding) then {
		_vehiclesLanding pushBack _vehicle;
	};
} forEach _groupHelicopters;

/*
	VTOLs receive the same initial Get Out landAt command.

	The landing-slot helper may not return a VTOL slot. In that case,
	_fnc_getHeliLandingPosition returns the original waypoint position as the
	fallback.
*/
{
	private _vehicle = _x;

	private _landingPos = [
		_vehicle,
		_heliLandingSlots,
		_pos
	] call _fnc_getHeliLandingPosition;

	_vehicle landAt [
		_landingPos,
		"Get Out",
		99999
	];

	if !(_vehicle in _vehiclesLanding) then {
		_vehiclesLanding pushBack _vehicle;
	};
} forEach _groupVTOLs;

private _groupLandingAircraft =
	+_groupHelicopters;

{
	_groupLandingAircraft pushBackUnique _x;
} forEach _groupVTOLs;

_vehiclesLanding =
	_vehiclesLanding arrayIntersect _groupLandingAircraft;

//-- wait for post-condition
waitUntil {
	sleep 0.1;

	/*
		A VTOL's Get Out landAt state does not reliably keep it grounded while
		the scripted combat-landing waypoint remains active.

		Reassert the proven normal Get Out landing command after touchdown and
		for the entire duration of the post-condition wait. Helicopter behavior
		remains untouched.
	*/
	{
		private _vehicle = _x;

		if (
			alive _vehicle &&
			{canMove _vehicle} &&
			{isTouchingGround _vehicle}
		) then {
			_vehicle land "Get Out";
		};
	} forEach _groupVTOLs;

	[] call _exitCondition
};

private _isFinalWP =
	[_group] call A3C_main_fnc_isGroupOnFinalWP;

//-- refresh _groupVehicles
_groupVehicles =
	[_group] call A3C_main_fnc_getGroupDrivenVehicles;

{
	_x limitSpeed 9999;
} forEach _groupVehicles; //-- release slowdown after combat landing handling

private _currentGroupVTOLs = _groupVehicles select {
	getNumber (configOf _x >> "vtol") > 0
};

if !(_isFinalWP) then {
	/*
		Release the landing state for all existing landing-capable aircraft.

		This is the original combat-landing behavior and remains unchanged for
		helicopters.
	*/
	{
		_x land "NONE";
	} forEach _groupVehicles;

	/*
		Restore VTOL cruise settings explicitly.

		The engine-off/on workaround is intentionally not used because current
		testing shows that it is unnecessary.
	*/
	{
		private _vehicle = _x;

		_vehicle limitSpeed 9999;

		_vehicle flyInHeight (
			_vehicle getVariable [
				"A3C_FLYINHEIGHT",
				75
			]
		);
	} forEach _currentGroupVTOLs;

	/*
		Apply the same VTOL-only departure handoff used by the working
		LoadVehicleInVehicle waypoint.

		This is only issued when another waypoint exists. Helicopter drivers
		receive no additional movement command.
	*/
	if !(_currentGroupVTOLs isEqualTo []) then {
		private _groupDrivers = [
			_group
		] call A3C_main_fnc_getGroupDrivers;

		private _currentWP =
			currentWaypoint _group;

		if (
			{
				(_x select 1) > _currentWP
			} count (waypoints _group) > 0
		) then {
			private _nextWpPos = waypointPosition [
				_group,
				_currentWP + 1
			];

			{
				private _driver = _x;
				private _vehicle = vehicle _driver;

				if (_vehicle in _currentGroupVTOLs) then {
					[
						_driver,
						_nextWpPos
					] call A3C_ai_shared_fnc_doMove;
				};
			} forEach _groupDrivers;
		};
	};
};

/*
	Preserve the established movement reinitialization for helicopter and other
	non-VTOL groups.

	The working VTOL implementation currently runs without this final call, so
	it is deliberately skipped whenever the group contains a VTOL.
*/
if (_currentGroupVTOLs isEqualTo []) then {
	[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;
} else {
	// [_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;
};

[] remoteExec [
	"A3C_ui_shared_fnc_toggleGocodeCtrls",
	0
]; //-- check gocodes and assign color

true
params ["_group", "_pos", "_target", "_callerUID", "_preCondition"];

if ([_callerUID, _group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

private _wp = [_group, currentWaypoint _group];

private _leader = leader _group;
private _loadVic = vehicle _leader;

private _vehicleConfig = configFile >> "CfgVehicles" >> typeOf _loadVic;

//-- determine landing distance
private _landingDistance = (getNumber (_vehicleConfig >> "precision")) + 100;

private _shouldContinueApproach = {
	params ["_vehicle", "_destinationPos", "_landingDistance"];

	_vehicle distance2D _destinationPos > (_landingDistance * 2)
};

private _groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;

//-- default enabling all vehicles
{
	_x flyInHeight (_x getVariable ["A3C_FLYINHEIGHT", 75]);
	_x limitSpeed 9999;
} forEach _groupVehicles;

while {[_loadVic, _pos, _landingDistance] call _shouldContinueApproach} do {
	_leader = leader _group;
	_loadVic = vehicle _leader; //-- has to be refreshed in case of crash

	if !(alive _loadVic && {canMove _loadVic}) exitWith {};

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

	private _distance2D = _loadVic distance2D _pos;

	[
		_group,
		_pos,
		90,     //-- controlled forward speed near the landing handoff area
		60,     //-- ATL approach altitude; landAt will own the final descent later
		3000,   //-- VTOL slowdown starts substantially earlier than helicopter slowdown
		1000    //-- minimum anti-overshoot damping envelope
	] call A3C_ai_shared_fnc_approachWaypointVTOL;

	sleep (
		[_loadVic, _distance2D]
		call A3C_ai_highCommand_fnc_getHeliWaypointSleep
	);
};

//-- refresh _groupVehicles
_groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;

{
	_x limitSpeed 9999;
} forEach _groupVehicles; //-- release slowdown after approach / before landing handling

_loadVic setVariable [
	"A3C_HC_groupVehicleReadyToBoard",
	true,
	true
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
	_loadVic
] call A3C_ai_shared_fnc_getHeliGroupLandingSlots;

private _fnc_getHeliLandingPosition = {
	params ["_vehicle", "_landingSlots", "_fallbackPos"];

	private _slot = _landingSlots select {
		(_x select 0) == _vehicle
	};

	if (_slot isEqualTo []) exitWith {
		+_fallbackPos
	};

	+((_slot select 0) select 1)
};

//-- This waypoint is VTOL-only, so no additional rotorcraft/aircraft distinction is required.
private _groupVTOLs = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

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

_vehiclesLanding = _vehiclesLanding arrayIntersect _groupVTOLs;

waitUntil {
	private _countReady = 0;

	private _currentGroupVTOLs = [
		_group
	] call A3C_main_fnc_getGroupDrivenVehicles;

	_vehiclesLanding =
		_vehiclesLanding arrayIntersect _currentGroupVTOLs;

	{
		private _vehicle = _x;

		if !(isTouchingGround _vehicle) then {
			private _doorState = if (
				(getPosVisual _vehicle) select 2 < 5
			) then {
				1
			} else {
				0
			};

			{
				_vehicle animateDoor [
					_x,
					_doorState
				];
			} forEach [
				"door_rear",
				"door_rear_source",
				"Door_1_source"
			];
		} else {
			{
				_vehicle animateDoor [
					_x,
					1
				];
			} forEach [
				"door_rear",
				"door_rear_source",
				"Door_1_source"
			];

			_vehicle engineOn true;
			_countReady = _countReady + 1;
		};
	} forEach _vehiclesLanding;

	sleep 1;

	count _vehiclesLanding == _countReady
};

/*
	Resolve synchronized cargo vehicles immediately after landing.

	This captures the relevant synchronization state before the cargo-side
	script completes the transfer and removes its own synchronization link.
*/
private _syncWps = synchronizedWaypoints _wp;
private _cargoVehicles = [];

{
	_x params [
		"_cargoGroup",
		"_cargoWaypointIndex"
	];

	{
		private _cargoVehicle = objectParent _x;

		if (
			!isNull _cargoVehicle &&
			{
				_x == driver _cargoVehicle
			} &&
			{
				_cargoVehicle != _loadVic
			}
		) then {
			_cargoVehicles pushBackUnique _cargoVehicle;
		};
	} forEach units _cargoGroup;
} forEach _syncWps;

sleep 3;

/*
	The cargo-side waypoint script owns setVehicleCargo.

	This script only waits until every vehicle identified from the
	post-landing synchronization snapshot is physically present inside the
	VTOL.
*/
waitUntil {
	private _loadedCargo = getVehicleCargo _loadVic;

	sleep 1;

	!(_cargoVehicles isEqualTo []) &&
	{
		_cargoVehicles findIf {
			!(_x in _loadedCargo)
		} == -1
	}
};

/*
	Compile and check the waypoint condition only after all synchronized
	cargo vehicles have been loaded.
*/
private _exitCondition = {};

{
	_x params [
		"_condType",
		"_condVal"
	];

	_exitCondition = switch (toUpper _condType) do {
		case "TIMEOUT": {
			private _timeAtCompletion =
				time + _condVal;

			compile format [
				"time > %1",
				_timeAtCompletion
			]
		};

		case "GOCODE": {
			private _goCodeActivationVariableName = [
				_condVal,
				side _group
			] call A3C_main_fnc_getGoCodeActivationVariableName;

			compile format [
				"missionNamespace getVariable [%1, false]",
				str _goCodeActivationVariableName
			]
		};

		case "DAYTIME": {
			private _conditionParts =
				_condVal splitString ":";

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
			sleep 0.1;
			[] call _exitCondition
		};

		if !((_preCondition select 0) in ["ARRIVAL", ""]) then {
			_wp setWaypointScript format [
				"A3C_CORE\waypointScripts\wpScript_LoadVehicleInVehicle.sqf ['%1',%2]",
				_callerUID,
				["ARRIVAL", ""]
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
} forEach [_preCondition];

_loadVic setVariable [
	"A3C_HC_groupVehicleReadyToBoard",
	nil,
	true
];

//-- release the hosting VTOL's synchronized waypoint
_wp synchronizeWaypoint [];

{
	private _veh = vehicle _x;

	if (_x == effectiveCommander _veh) then {
		{
			_veh animateDoor [
				_x,
				0
			];
		} forEach [
			"door_rear",
			"door_rear_source",
			"Door_1_source"
		];
	};
} forEach units _group;

/*
	Release the landing command and restore the normal cruise settings.

	The VTOL approach helper no longer issues group move, doMove or moveTo
	orders. No compensating movement nudge should be necessary here.
*/
{
	private _vehicle = _x;

	_vehicle land "NONE";
	_vehicle limitSpeed 9999;

	_vehicle flyInHeight (
		_vehicle getVariable [
			"A3C_FLYINHEIGHT",
			75
		]
	);
} forEach _vehiclesLanding;




/*
	The legacy engine reset is intentionally disabled for this test.

	It can be restored if later testing proves that a specific VTOL still
	requires it to leave its grounded flight state.
*/
private _groupDrivers = [
	_group
] call A3C_main_fnc_getGroupDrivers;

private _currentWP = currentWaypoint _group;
if ({(_x select 1) > _currentWP} count (waypoints _group) > 0) then {
	private _nextWpPos = waypointPosition [
		_group,
		_currentWP + 1
	];

	{[_x, _nextWpPos] call A3C_ai_shared_fnc_doMove;} forEach _groupDrivers;


};

// [_groupDrivers] call A3C_ai_shared_fnc_actionEngineOff;
// sleep 0.5;
// [_groupDrivers] call A3C_ai_shared_fnc_actionEngineOn;

/*
	Also test without final movement reinitialization.

	The function only restores MOVE/PATH, speed, altitude and land state.
	It does not need to run if all of those states were restored above.
*/
// [_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

true
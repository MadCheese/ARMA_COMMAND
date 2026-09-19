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

private _isHoverCapableAircraft = [
	_leaderVehicle
] call A3C_main_fnc_canHoverAircraft;

private _addRadius = if (_leaderVehicle isKindOf "AIR") then {
	50
} else {
	20
};

private _vehicleConfig =
	configFile >> "CfgVehicles" >> typeOf _leaderVehicle;

//-- determine landing distance
private _landingDistance =
	(getNumber (_vehicleConfig >> "precision")) +
	(if (_isLeaderVTOL) then {
		100
	} else {
		_addRadius
	});

/*
	Approach completion is distance-only for every vehicle class.

	VTOLs use the same larger landing handoff envelope as the working
	LoadVehicleInVehicle implementation.
*/
private _shouldContinueApproach = {
	params [
		"_vehicle",
		"_destinationPos",
		"_landingDistance"
	];

	_vehicle distance2D _destinationPos >
		(_landingDistance * 2)
};

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
			The VTOL helper only shapes speed, altitude and momentum.

			It must not issue doMove, moveTo, group move or setDestination
			commands because those can survive the landing handoff and suppress
			subsequent waypoint navigation.
		*/
		[
			_group,
			_pos,
			90,     //-- controlled forward speed near the landing handoff area
			60,     //-- ATL approach altitude; landAt owns the final descent
			3000,   //-- VTOL slowdown starts substantially earlier
			1000    //-- minimum anti-overshoot damping envelope
		] call A3C_ai_shared_fnc_approachWaypointVTOL;

		sleep (
			[
				_leaderVehicle,
				_distance2D
			] call A3C_ai_highCommand_fnc_getHeliWaypointSleep
		);
	} else {
		if (_isHoverCapableAircraft) then {
			/*
				Existing helicopter/hover-capable approach remains unchanged.
			*/
			[
				_group,
				_pos,
				30,     //-- final approach speed in km/h before unload / Get Out landing logic takes over
				25,     //-- final approach altitude ATL
				1600,   //-- slowdown starts here
				350     //-- anti-overshoot damping starts here
			] call A3C_ai_shared_fnc_approachWaypointHelicopter;

			sleep (
				if (_distance2D < 500) then {
					0.5
				} else {
					1
				}
			);
		} else {
			/*
				Existing regular approach remains unchanged for ground vehicles
				and non-hover aircraft.
			*/
			[
				_group,
				_pos
			] call A3C_ai_shared_fnc_approachWaypointRegular;

			sleep 2;
		};
	};
};

private _drivenVehicles = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

{
	_x limitSpeed false;
} forEach _drivenVehicles; //-- release slowdown after approach / before unload handling

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
			private _goCodeActivationVariableName = [
				_conditionValue,
				side _group
			] call A3C_main_fnc_getGoCodeActivationVariableName;

			compile format [
				"missionNamespace getVariable [%1, false]",
				str _goCodeActivationVariableName
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
				"A3C_CORE\waypointScripts\wpScript_TR_Unload.sqf ['%1',%2,%3]",
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
private _vehiclesUnloading = [];

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

/*
	Cache the TR unload vehicle kind per vehicle.

	VTOL detection occurs before reading the old cache so that a vehicle
	previously cached as IGNORE by an older script version is immediately
	reclassified correctly.
*/
private _fnc_getTRUnloadVehicleKind = {
	params ["_vehicle"];

	private _isVTOL =
		getNumber (configOf _vehicle >> "vtol") > 0;

	if (_isVTOL) exitWith {
		_vehicle setVariable [
			"A3C_TR_UNLOAD_KIND",
			"VTOL",
			false
		];

		"VTOL"
	};

	private _vehicleKind =
		_vehicle getVariable [
			"A3C_TR_UNLOAD_KIND",
			""
		];

	if (_vehicleKind isNotEqualTo "") exitWith {
		_vehicleKind
	};

	_vehicleKind = if (_vehicle isKindOf "HELICOPTER") then {
		"HOVER"
	} else {
		if (_vehicle isKindOf "Air") then {
			"IGNORE"
		} else {
			"GROUND"
		};
	};

	_vehicle setVariable [
		"A3C_TR_UNLOAD_KIND",
		_vehicleKind,
		false
	];

	_vehicleKind
};

private _fnc_getNonGroupCrew = {
	params ["_vehicle"];

	private _driver = driver _vehicle;

	if (isNull _driver) exitWith {
		[]
	};

	private _groupUnits =
		units group _driver;

	(crew _vehicle) select {
		!(_x in _groupUnits)
	}
};

private _fnc_unloadNonGroupCrew = {
	params [
		"_vehicle",
		["_landingPos", []]
	];

	private _crewNonGroup = [
		_vehicle
	] call _fnc_getNonGroupCrew;

	if (_crewNonGroup isEqualTo []) exitWith {};

	private _cargoGroups = [];

	{
		private _unitGroup =
			group _x;

		if !(_unitGroup in _cargoGroups) then {
			_cargoGroups set [
				count _cargoGroups,
				_unitGroup
			];
		};
	} forEach _crewNonGroup;

	{
		[
			_x,
			_vehicle
		] remoteExec [
			"leaveVehicle",
			leader _x
		];
	} forEach _cargoGroups;
};

waitUntil {
	private _groupUnits =
		units _group;

	private _processedVehicles = [];
	private _actionableVehicles = [];

	{
		private _vehicle =
			objectParent _x;

		if (
			!isNull _vehicle &&
			{!(_vehicle in _processedVehicles)}
		) then {
			_processedVehicles pushBack _vehicle;

			private _driver =
				driver _vehicle;

			if (
				!isNull _driver &&
				{_driver in _groupUnits}
			) then {
				private _vehicleKind = [
					_vehicle
				] call _fnc_getTRUnloadVehicleKind;

				private _crewNonGroup = [
					_vehicle
				] call _fnc_getNonGroupCrew;

				switch (_vehicleKind) do {
					case "HOVER": {
						/*
							Existing helicopter unload behavior remains
							unchanged.
						*/
						if (_crewNonGroup isNotEqualTo []) then {
							private _landingPos = [
								_vehicle,
								_heliLandingSlots,
								_pos
							] call _fnc_getHeliLandingPosition;

							private _landingPosWorld =
								AGLToASL _landingPos;

							if !(_vehicle in _vehiclesLanding) then {

								[_vehicle, _landingPosWorld, "Get Out"] call A3C_ai_shared_fnc_landAt;
								

								_vehiclesLanding pushBack _vehicle;
							};

							if (isTouchingGround _vehicle) then {
								if !(_vehicle in _vehiclesUnloading) then {
									[
										_vehicle,
										_landingPos
									] call _fnc_unloadNonGroupCrew;

									_vehiclesUnloading pushBack _vehicle;
								};

								_vehicle flyInHeight 0;
							};

							_actionableVehicles pushBack _vehicle;
						};
					};

					case "VTOL": {
						/*
							VTOL landing mirrors Combat Landing and
							LoadVehicleInVehicle.

							The landing-slot helper may not return a VTOL slot.
							In that case, _fnc_getHeliLandingPosition returns the
							original waypoint position as the fallback.
						*/
						if (_crewNonGroup isNotEqualTo []) then {
							private _landingPos = [
								_vehicle,
								_heliLandingSlots,
								_pos
							] call _fnc_getHeliLandingPosition;

							private _landingPosWorld =
								AGLToASL _landingPos;

							if !(_vehicle in _vehiclesLanding) then {
								commandStop (driver _vehicle);
							
								[_vehicle, _landingPosWorld, "Get Out"] call A3C_ai_shared_fnc_landAt;

								_vehiclesLanding pushBack _vehicle;
							};

							if (isTouchingGround _vehicle) then {
								if !(_vehicle in _vehiclesUnloading) then {
									[
										_vehicle,
										_landingPos
									] call _fnc_unloadNonGroupCrew;

									_vehiclesUnloading pushBack _vehicle;
								};
								_vehicle land "Get Out";
							};

							_actionableVehicles pushBack _vehicle;
						};
					};

					case "GROUND": {
						/*
							Ground vehicles unload in place once the approach
							phase has completed.

							Do not issue final moveTo/doMove commands here; that
							causes convoy clumping.
						*/
						if (_crewNonGroup isNotEqualTo []) then {
							if !(_vehicle in _vehiclesUnloading) then {
								[
									_vehicle
								] call _fnc_unloadNonGroupCrew;

								_vehiclesUnloading pushBack _vehicle;
							};

							_actionableVehicles pushBack _vehicle;
						};
					};

					default {
						/*
							Non-hover conventional aircraft and other ignored
							vehicles receive no TR unload actions.
						*/
					};
				};
			};
		};
	} forEach _groupUnits;

	_vehiclesLanding =
		_vehiclesLanding arrayIntersect _actionableVehicles;

	_vehiclesUnloading =
		_vehiclesUnloading arrayIntersect _actionableVehicles;

	sleep 1;

	//-- Refresh group units after sleep so recently unloaded units do not keep blocking exit.
	_groupUnits =
		units _group;

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

_drivenVehicles = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

{
	_x limitSpeed false;
} forEach _drivenVehicles;

private _groupVTOLs = _drivenVehicles select {
	alive _x &&
	{getNumber (configOf _x >> "vtol") > 0}
};

private _isFinalWP = [
	_group
] call A3C_main_fnc_isGroupOnFinalWP;

if !(_isFinalWP) then {
	/*
		Preserve the existing helicopter landing release behavior.
	*/
	{
		private _vehicle =
			vehicle _x;

		if (
			_x == effectiveCommander _vehicle &&
			{_vehicle isKindOf "HELICOPTER"}
		) then {
			_vehicle land "NONE";
		};
	} forEach units _group;

	/*
		Release VTOL landing state and restore cruise settings.
	*/
	{
		private _vehicle = _x;

		_vehicle land "NONE";
		_vehicle limitSpeed false;

		_vehicle flyInHeight (
			_vehicle getVariable [
				"A3C_FLYINHEIGHT",
				75
			]
		);
	} forEach _groupVTOLs;

	/*
		Apply the same VTOL-only next-waypoint handoff used by the working
		Combat Landing and LoadVehicleInVehicle scripts.
	*/
	if !(_groupVTOLs isEqualTo []) then {
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
				private _vehicle =
					vehicle _driver;

				if (_vehicle in _groupVTOLs) then {
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
	Preserve the established movement reinitialization for groups without a
	VTOL.

	The tested VTOL handoff does not use this final reinitialization.
*/
if (_groupVTOLs isEqualTo []) then {
	[
		_group
	] call A3C_ai_highCommand_fnc_reInitGroupMovement;
} else {
	// [_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;
};

[] remoteExec [
	"A3C_ui_shared_fnc_toggleGocodeCtrls",
	0
]; //-- check gocodes and assign color

true
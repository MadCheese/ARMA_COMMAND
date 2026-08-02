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

/*
	VTOL classification takes priority over the broader hover-capable
	classification so that VTOLs use their dedicated approach helper.
*/
private _useVerticalLanding =
	_isLeaderVTOL ||
	{_isHoverCapableAircraft};

private _isConventionalPlane =
	!_isLeaderVTOL &&
	{!_isHoverCapableAircraft} &&
	{_leaderVehicle isKindOf "PLANE"};

private _vehicleConfig =
	configFile >> "CfgVehicles" >> typeOf _leaderVehicle;

//-- determine landing distance
private _landingDistance = if (
	_isConventionalPlane &&
	{(getNumber (_vehicleConfig >> "landingSpeed")) > 10}
) then {
	5000
} else {
	(getNumber (_vehicleConfig >> "precision")) + 50
};

/*
	Approach completion is distance-only for all vehicle classes.

	Conventional planes retain their existing larger landing-distance
	threshold. Hover-capable aircraft and VTOLs retain the doubled precision
	envelope, without unitReady preventing completion.
*/
private _shouldContinueApproach = {
	params [
		"_vehicle",
		"_destinationPos",
		"_landingDistance",
		"_isConventionalPlane"
	];

	if (_isConventionalPlane) exitWith {
		_vehicle distance2D _destinationPos >
			_landingDistance
	};

	_vehicle distance2D _destinationPos >
		(_landingDistance * 2)
};

private _groupVehicles = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

//-- default enabling all vehicles
{
	_x flyInHeight (
		_x getVariable [
			"A3C_FLYINHEIGHT",
			75
		]
	);

	_x limitSpeed 5000;
} forEach _groupVehicles;

//-- WAIT FOR ARRIVAL / APPROACH
while {
	[
		_leaderVehicle,
		_pos,
		_landingDistance,
		_isConventionalPlane
	] call _shouldContinueApproach
} do {
	_leader = leader _group;
	_leaderVehicle = vehicle _leader;

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
		if (_isHoverCapableAircraft) then {
			/*
				Existing helicopter/hover-capable approach behavior remains
				unchanged.
			*/
			[
				_group,
				_pos,
				40,     //-- final approach speed in km/h before landing action takes over
				25,     //-- final approach altitude ATL
				1600,   //-- slowdown starts here
				350     //-- anti-overshoot damping starts here
			] call A3C_ai_shared_fnc_approachWaypointHelicopter;
		} else {
			/*
				Existing conventional-plane and regular-vehicle approach
				behavior remains unchanged.
			*/
			[
				_group,
				_pos
			] call A3C_ai_shared_fnc_approachWaypointRegular;
		};
	};

	sleep (
		if (_useVerticalLanding) then {
			[
				_leaderVehicle,
				_distance2D
			] call A3C_ai_highCommand_fnc_getHeliWaypointSleep
		} else {
			5
		}
	);
};

//-- Refresh _groupVehicles
_groupVehicles = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

{
	_x limitSpeed 9999;
} forEach _groupVehicles; //-- reset slowdown

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
				"A3C_CORE\waypointScripts\wpScript_Landing.sqf ['%1',%2,%3]",
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

if !(_useVerticalLanding) then {
	sleep 2;
};

// systemchat "START LANDING";

private _landingScript = if (_useVerticalLanding) then {
	[
		_group,
		+_pos,
		_leaderVehicle
	] spawn {
		params [
			"_group",
			"_pos",
			"_leaderVehicle"
		];

		private _landingSpacing = _group getVariable [
			"A3C_HELI_LANDING_SPACING",
			30
		];

		/*
			The landing-slot helper remains the source of the established
			helicopter landing-aircraft list and their individual positions.

			VTOLs are added independently below because the slot helper is not
			guaranteed to include airplaneX VTOL aircraft.
		*/
		private _landingSlots = [
			_group,
			_pos,
			_landingSpacing,
			_leaderVehicle
		] call A3C_ai_shared_fnc_getHeliGroupLandingSlots;

		private _fnc_getLandingPosition = {
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
			Preserve the exact existing helicopter selection.

			Every aircraft returned by the landing-slot helper continues to
			receive the same full landAt order as before.
		*/
		private _groupHelicopters = _landingSlots apply {
			_x select 0
		};

		/*
			Resolve VTOLs independently.

			This mirrors the working LoadVehicleInVehicle implementation. If a
			VTOL has no entry in _landingSlots, _fnc_getLandingPosition returns
			the original waypoint position as its fallback landing position.
		*/
		private _groupVTOLs = (
			[_group] call A3C_main_fnc_getGroupDrivenVehicles
		) select {
			alive _x &&
			{canMove _x} &&
			{getNumber (configOf _x >> "vtol") > 0}
		};

		private _groupLandingAircraft =
			+_groupHelicopters;

		{
			_groupLandingAircraft pushBackUnique _x;
		} forEach _groupVTOLs;

		{
			private _vehicle = _x;

			private _landingPos = [
				_vehicle,
				_landingSlots,
				_pos
			] call _fnc_getLandingPosition;

			/*
				"Land" is the full landing mode for this waypoint.

				The VTOL receives this immediately after the dedicated approach
				loop hands control over to the landing phase.
			*/
			_vehicle landAt [
				_landingPos,
				"Land",
				99999
			];
		} forEach _groupLandingAircraft;

		waitUntil {
			sleep 1;

			{
				alive _x &&
				{canMove _x} &&
				{!isTouchingGround _x}
			} count _groupLandingAircraft == 0
		};
	};
} else {
	/*
		Existing conventional-plane landing action remains unchanged.
	*/
	[
		_leader,
		_pos,
		_callerUID,
		[],
		true
	] spawn A3C_ai_highCommand_fnc_wpAction_landingFull
};

_currentActions pushBack [
	"landing_full_1",
	_landingScript
];

_group setVariable [
	"A3C_SCRIPTS",
	_currentActions,
	true
];

[
	_group,
	_wp
] spawn {
	params [
		"_group",
		"_wp"
	];

	private _currentActions = [];

	waitUntil {
		sleep 1;

		_currentActions =
			_group getVariable [
				"A3C_SCRIPTS",
				[]
			];

		private _currentWaypointIndex =
			currentWaypoint _group;

		(
			{
				"landing_full" in (_x select 0)
			} count _currentActions == 0
		) || {
			_currentWaypointIndex != (_wp select 1) || {
				waypointType [
					_group,
					_currentWaypointIndex
				] != "SCRIPTED" || {
					private _waypointScript =
						waypointScript [
							_group,
							_currentWaypointIndex
						];

					!(
						"wpscript_landing.sqf" in
						toLower _waypointScript
					)
				}
			}
		}
	};

	A3C_BLACKLIST_WAYPOINT_EDIT =
		A3C_BLACKLIST_WAYPOINT_EDIT - [_wp];

	{
		_x params [
			"_actionID",
			"_script"
		];

		if ("landing_full" in _actionID) then {
			_currentActions =
				_currentActions - [_x];

			terminate _script;
		};
	} forEach _currentActions;

	_group setVariable [
		"A3C_SCRIPTS",
		if (count _currentActions > 0) then {
			_currentActions
		} else {
			nil
		},
		true
	];

	{
		private _vehicle =
			objectParent _x;

		if (
			!isNull _vehicle &&
			{_x == driver _vehicle} &&
			{_vehicle isKindOf "AIR"}
		) then {
			private _isVTOL =
				getNumber (configOf _vehicle >> "vtol") > 0;

			/*
				Preserve the original cleanup condition for helicopters and
				conventional planes.

				A VTOL's model origin can remain more than one metre above ATL
				while its landing gear is physically touching the ground. For
				VTOLs, do not cancel the full landing state while grounded.
			*/
			private _shouldCancelLanding = if (_isVTOL) then {
				!isTouchingGround _vehicle &&
				{((getPosATL _vehicle) select 2) > 1}
			} else {
				((getPosATL _vehicle) select 2) > 1
			};

			if (_shouldCancelLanding) then {
				_vehicle land "NONE";

				_x setVariable [
					"A3C_VAR_LANDING",
					nil,
					true
				];
			};
		};
	} forEach units _group;

	_group setVariable [
		"A3C_ISwpLANDING",
		nil,
		true
	];
};

waitUntil {
	scriptDone _landingScript
};

/*
	For VTOLs, landAt "Land" does not provide the persistent grounded hold
	used by helicopters.

	Only take fuel when this is genuinely the group's final waypoint. If a
	following waypoint already exists, leave the VTOL's fuel unchanged so it
	can perform the normal departure sequence below.

	Conventional-plane fuel handling remains owned by the existing fixed-wing
	landing action outside this VTOL-specific branch.
*/
_groupVehicles = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

private _groupVTOLsAtTouchdown = _groupVehicles select {
	alive _x &&
	{getNumber (configOf _x >> "vtol") > 0}
};

private _isFinalWPAtTouchdown = [
	_group
] call A3C_main_fnc_isGroupOnFinalWP;

if (
	_isFinalWPAtTouchdown &&
	{!(_groupVTOLsAtTouchdown isEqualTo [])}
) then {
	{
		_x setFuel 0;
	} forEach _groupVTOLsAtTouchdown;
};

private _isStillLanding = {
	params ["_unit"];

	private _vehicle =
		objectParent _unit;

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

	{
		[_x] call _isStillLanding
	} count units _group == 0
};

sleep 15;

_groupVehicles = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

{
	_x limitSpeed 9999;
} forEach _groupVehicles;

_currentActions = _group getVariable [
	"A3C_SCRIPTS",
	[]
];

{
	if ("landing_full" in (_x select 0)) then {
		_currentActions =
			_currentActions - [_x];
	};
} forEach _currentActions;

//-- #CURRENTBUG: this might be the issue but not sure. something can keep vehicles unresponsive after landing waypoint.
//-- likely set var to nil anyways?? if vehicle is unresponsive, have server remote-chatlog the variable of the group
_group setVariable [
	"A3C_SCRIPTS",
	if (count _currentActions > 0) then {
		_currentActions
	} else {
		nil
	},
	true
];

/*
	VTOL departure handling is isolated from helicopters and conventional
	planes.

	When another waypoint already exists, release the VTOL landing state,
	restore its cruise settings and hand it toward the following waypoint.

	Final-waypoint VTOLs do not enter this branch; their fuel was set to zero
	immediately after touchdown.
*/
private _groupVTOLs = _groupVehicles select {
	alive _x &&
	{getNumber (configOf _x >> "vtol") > 0}
};

private _isFinalWP = [
	_group
] call A3C_main_fnc_isGroupOnFinalWP;

if (
	!_isFinalWP &&
	{!(_groupVTOLs isEqualTo [])}
) then {
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
	} forEach _groupVTOLs;

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

			if (_vehicle in _groupVTOLs) then {
				[
					_driver,
					_nextWpPos
				] call A3C_ai_shared_fnc_doMove;
			};
		} forEach _groupDrivers;
	};
};

A3C_BLACKLIST_WAYPOINT_EDIT =
	A3C_BLACKLIST_WAYPOINT_EDIT - [_wp];

publicVariable "A3C_BLACKLIST_WAYPOINT_EDIT";

true
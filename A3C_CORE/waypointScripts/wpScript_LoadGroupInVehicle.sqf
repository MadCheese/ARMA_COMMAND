params ["_group", "_pos", "_target", "_callerUID", "_preCondition"];

private ["_syncWps", "_wp"];

if ([_callerUID, _group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

private _leader = leader _group;

_wp = [
	_group,
	currentWaypoint _group
];

private _synchroWPS =
	synchronizedWaypoints _wp;

_syncWps = _group getVariable [
	"A3C_HC_SYNCWPS",
	[]
]; //-- syncwps is used to access boarding groups

private _vehsMove = [];
private _vehsLand = [];

private _loadVic =
	vehicle leader _group;

private _isLeaderVTOL =
	getNumber (configOf _loadVic >> "vtol") > 0;

private _isHoverCapableAircraft = [
	_loadVic
] call A3C_main_fnc_canHoverAircraft;

private _vehicleConfig =
	configFile >> "CfgVehicles" >> typeOf _loadVic;

private _precision = (
	(getNumber (_vehicleConfig >> "precision")) *
	1.2
) max 30;

/*
	VTOLs use the same larger landing handoff envelope as the working
	LoadVehicleInVehicle waypoint.

	Ground vehicles and helicopters retain the existing precision calculation.
*/
private _landingDistance = if (_isLeaderVTOL) then {
	(getNumber (_vehicleConfig >> "precision")) + 100
} else {
	_precision
};

/*
	VTOL and helicopter approach completion is distance-only.

	The original unitReady-and-distance completion condition remains intact for
	ground vehicles.
*/
private _shouldContinueApproach = {
	params [
		"_vehicle",
		"_destinationPos",
		"_landingDistance",
		"_useDistanceOnly"
	];

	if (_useDistanceOnly) exitWith {
		_vehicle distance2D _destinationPos >
			(_landingDistance * 2)
	};

	!unitReady driver _vehicle ||
	{
		_vehicle distance2D _destinationPos >
			_landingDistance
	}
};

private _groupVehicles = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

//-- Restore normal approach settings before beginning.
{
	private _vehicle = _x;

	if (_vehicle isKindOf "AIR") then {
		_vehicle flyInHeight (
			_vehicle getVariable [
				"A3C_FLYINHEIGHT",
				75
			]
		);
	};

	_vehicle limitSpeed false;
} forEach _groupVehicles;

//-- WAIT FOR ARRIVAL / APPROACH
while {
	[
		_loadVic,
		_pos,
		_landingDistance,
		_isLeaderVTOL || {_isHoverCapableAircraft}
	] call _shouldContinueApproach
} do {
	_leader =
		leader _group;

	_loadVic =
		vehicle _leader; //-- has to be refreshed in case of crash

	if !(alive _loadVic && {canMove _loadVic}) exitWith {};

	_isLeaderVTOL =
		getNumber (configOf _loadVic >> "vtol") > 0;

	_isHoverCapableAircraft = [
		_loadVic
	] call A3C_main_fnc_canHoverAircraft;

	private _wpPos =
		waypointPosition _wp;

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
		_loadVic distance2D _pos;

	if (_isLeaderVTOL) then {
		/*
			VTOL approach helper is deliberately movement-command-free.

			The active waypoint remains responsible for navigation. The helper
			only shapes altitude, speed and horizontal momentum before landAt
			takes ownership of the final descent.
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
				_loadVic,
				_distance2D
			] call A3C_ai_highCommand_fnc_getHeliWaypointSleep
		);
	} else {
		if (_isHoverCapableAircraft) then {
			/*
				Helicopters use the established helicopter approach helper.
			*/
			[
				_group,
				_pos,
				30,     //-- final approach speed before Get In landing logic
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
				Existing ground-vehicle approach behavior remains unchanged.
			*/
			[
				_group,
				_pos
			] call A3C_ai_shared_fnc_approachWaypointRegular;

			sleep 2;
		};
	};
};

//-- Refresh driven vehicles and release approach slowdown.
_groupVehicles = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

{
	_x limitSpeed false;
} forEach _groupVehicles;

private _landingSpacing = _group getVariable [
	"A3C_HELI_LANDING_SPACING",
	30
];

private _landingSlots = [
	_group,
	_pos,
	_landingSpacing,
	_loadVic
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
	Resolve one stable VTOL array after the approach.

	This mirrors Combat Landing: the same aircraft receive the initial landAt
	command and all subsequent normal landing commands.
*/
private _groupVTOLs = _groupVehicles select {
	alive _x &&
	{canMove _x} &&
	{getNumber (configOf _x >> "vtol") > 0}
};

/*
	Preserve the original readiness-variable timing for groups without VTOLs.

	VTOL groups advertise readiness only after every VTOL has physically
	touched down.
*/
if (_groupVTOLs isEqualTo []) then {
	_loadVic setVariable [
		"A3C_HC_groupVehicleReadyToBoard",
		true,
		true
	];
};

/*
	Issue the VTOL positional landing order once before entering any landing or
	boarding wait.

	This matches the Combat Landing structure. The landing-slot helper may not
	return a VTOL slot, in which case the waypoint position is used.
*/
{
	private _vehicle = _x;

	private _landingPos = [
		_vehicle,
		_landingSlots,
		_pos
	] call _fnc_getLandingPosition;

	private _landingPosWorld =
		AGLToASL _landingPos;

	[_vehicle, _landingPosWorld, "GET IN"] call A3C_ai_shared_fnc_landAt;
} forEach _groupVTOLs;

/*
	Reassert the normal VTOL landing command using the same conditions and
	cadence as Combat Landing.

	This function is called inline by the waypoint script. No spawned holder,
	token state or waypoint-index guard is involved.
*/
private _fnc_holdGroundedVTOLs = {
	{
		private _vehicle = _x;

		if (
			alive _vehicle &&
			{canMove _vehicle} &&
			{isTouchingGround _vehicle}
		) then {
			_vehicle land "GET IN";
		};
	} forEach _groupVTOLs;
};

/*
	Classify each hosting vehicle once per iteration.

	VTOL classification takes priority in case a modded VTOL also inherits
	from a helicopter base class.
*/
private _fnc_getLoadVehicleKind = {
	params ["_vehicle"];

	if (
		getNumber (configOf _vehicle >> "vtol") > 0
	) exitWith {
		"VTOL"
	};

	if (_vehicle isKindOf "HELICOPTER") exitWith {
		"HOVER"
	};

	"GROUND"
};

/*
	Wait until every hosting vehicle is ready for its synchronized boarding
	group.

	Helicopter and ground-vehicle branches remain unchanged.

	For VTOL groups, the loop follows the Combat Landing cadence:

		sleep 0.1
		reassert land for grounded VTOLs
		evaluate readiness
*/
waitUntil {
	if !(_groupVTOLs isEqualTo []) then {
		sleep 0.1;

		[] call _fnc_holdGroundedVTOLs;
	};

	private _countReady = 0;
	private _vehsGroup = [];

	{
		private _veh =
			vehicle _x;

		if (_x == effectiveCommander _veh) then {
			private _vehicleKind = [
				_veh
			] call _fnc_getLoadVehicleKind;

			switch (_vehicleKind) do {
				case "VTOL": {
					if (isTouchingGround _veh) then {
						/*
							Issue the normal landing command directly from the
							same scheduled script that detected touchdown.

							This mirrors the Combat Landing implementation.
						*/
						_veh land "GET IN";

						_countReady =
							_countReady + 1;
					};
				};

				case "HOVER": {
					/*
						Existing helicopter movement and landing sequence.
					*/
					if !(_veh in _vehsMove) then {
						_veh doMove _pos;
						_veh moveTo _pos;

						_vehsMove pushBack _veh;
					} else {
						if !(isTouchingGround _veh) then {
							if (
								unitReady _veh &&
								{!(_veh in _vehsLand)}
							) then {
								_veh land "GET IN";

								_vehsLand pushBack _veh;
							};
						} else {
							_veh engineOn true;

							_countReady =
								_countReady + 1;
						};
					};
				};

				default {
					/*
						Existing ground-vehicle movement sequence.

						Ground vehicles move to the boarding position and are
						ready once their approach command has been issued and
						they remain physically grounded.
					*/
					if !(_veh in _vehsMove) then {
						_veh doMove _pos;
						_veh moveTo _pos;

						_vehsMove pushBack _veh;
					} else {
						if (isTouchingGround _veh) then {
							_veh engineOn true;

							_countReady =
								_countReady + 1;
						};
					};
				};
			};

			_vehsGroup pushBack _veh;
		};
	} forEach units _group;

	_vehsMove =
		_vehsMove - (_vehsMove - _vehsGroup);

	_vehsLand =
		_vehsLand - (_vehsLand - _vehsGroup);

	if (_groupVTOLs isEqualTo []) then {
		sleep 1;
	};

	count _vehsGroup == _countReady
};

/*
	Every VTOL has now touched down and the inline landing hold is active.

	Only now advertise the VTOL group as ready to synchronized cargo groups.
	Helicopter and ground-vehicle groups retained the original earlier timing.
*/
if !(_groupVTOLs isEqualTo []) then {
	_loadVic setVariable [
		"A3C_HC_groupVehicleReadyToBoard",
		true,
		true
	];
};

//"vehicle is ready to board" remoteExec ["systemchat",0];

private _dest =
	(expectedDestination (driver _loadVic)) select 0;

//-- compose precondition and wait for completion
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
		if (_groupVTOLs isEqualTo []) then {
			/*
				Preserve the original precondition wait for helicopter and
				ground-vehicle groups.
			*/
			waitUntil {
				[] call _exitCondition
			};
		} else {
			/*
				Mirror the Combat Landing loop exactly for VTOLs: the normal
				landing command is reasserted every 0.1 seconds until the
				precondition is satisfied.
			*/
			waitUntil {
				sleep 0.1;

				[] call _fnc_holdGroundedVTOLs;

				[] call _exitCondition
			};
		};

		if !((_preCondition select 0) in ["ARRIVAL", ""]) then {
			_wp setWaypointScript format [
				"A3C_CORE\waypointScripts\wpScript_LoadGroupInVehicle.sqf ['%1',%2]",
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

/*
	Wait for synchronized cargo groups to complete boarding.

	For VTOLs, this loop retains the same inline 0.1-second landing hold used
	by Combat Landing. The hold remains active until the exact cycle in which
	the boarding-completion condition becomes true.

	Helicopter and ground-vehicle groups retain their original one-second loop.
*/
while {canMove _loadVic} do {
	if !(_groupVTOLs isEqualTo []) then {
		sleep 0.1;

		[] call _fnc_holdGroundedVTOLs;
	};

	private _emptySeats = [];

	{
		private _vehicle =
			objectParent _x;

		if (
			!isNull _vehicle &&
			{_x == driver _vehicle}
		) then {
			_emptySeats pushBack (
				fullCrew [
					_vehicle,
					"cargo",
					true
				] select {
					isNull (_x select 0)
				}
			);
		};
	} forEach units _group;

	private _exit = true;

	if (count _emptySeats > 0) then {
		private _synchronizedWaypoints =
			synchronizedWaypoints _wp;

		{
			_x params [
				"_group1",
				"_wpi"
			];

			private _condition =
				_group1 getVariable [
					"A3C_HC_groupVehicleReadyToBoard",
					false
				] ||
				{
					{
						!(
							driver (vehicle _x) in
							units _group
						)
					} count units _group1 > 0
				};

			if (_condition) exitWith {
				_exit = false;
			};
		} forEach _synchronizedWaypoints;
	};

	if (_exit) exitWith {};

	if (_groupVTOLs isEqualTo []) then {
		sleep 1;
	};
};

//"boarding complete" remoteExec ["systemchat",0];

_loadVic setVariable [
	"A3C_HC_groupVehicleReadyToBoard",
	nil,
	true
];

/*
	VTOL departure handling.

	Ground vehicles and helicopters retain their existing post-boarding
	behavior. Only VTOLs receive the explicit landing release and next-waypoint
	handoff used by the tested VTOL loading waypoints.
*/
private _currentDrivenVehicles = [
	_group
] call A3C_main_fnc_getGroupDrivenVehicles;

private _currentGroupVTOLs =
	_currentDrivenVehicles select {
		alive _x &&
		{getNumber (configOf _x >> "vtol") > 0}
	};

private _isFinalWP = [
	_group
] call A3C_main_fnc_isGroupOnFinalWP;

if (
	!_isFinalWP &&
	{!(_currentGroupVTOLs isEqualTo [])}
) then {
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
	} forEach _currentGroupVTOLs;

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

			if (_vehicle in _currentGroupVTOLs) then {
				[
					_driver,
					_nextWpPos
				] call A3C_ai_shared_fnc_doMove;
			};
		} forEach _groupDrivers;
	};
};

true
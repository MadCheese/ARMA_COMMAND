#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_resetPlayerGroup

/*
	Rebuilds the player's group while preserving unit assignment data,
	destinations, team colors, vehicle assignments, knowledge, formation
	indices, plot references, and relevant UI state.
*/

if (is3DEN) exitWith {};

setGroupIconsVisible [false, false];

private _displayId = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_RADIAL_MENU
};

private _display = findDisplay _displayId;

/*
	Preserved two-pass vehicle recovery behavior.

	The initial pass additionally requires a positive vectorUp Z component.
	The later pass preserves the original looser XY-only stability test.
*/
private _fnc_resetFlippedVehicles = {
	params [
		"_groups",
		"_requirePositiveVectorZ"
	];

	private _vehiclesToReset = [];

	{
		private _group = _x;

		{
			private _unit = _x;

			if (!isNull objectParent _unit) then {
				private _vehicle = vehicle _unit;
				private _vectorUp = vectorUp _vehicle;

				private _isHorizontallyStable = {
					abs _x > 0.5
				} count [
					_vectorUp select 0,
					_vectorUp select 1
				] == 0;

				private _isStable =
					_isHorizontallyStable
					&& {
						!_requirePositiveVectorZ
						|| {
							(_vectorUp select 2) > 0
						}
					};

				if (
					!_isStable
					&& {
						!(_vehicle isKindOf "AIR")
					}
				) then {
					_vehiclesToReset pushBackUnique _vehicle;
				};
			};
		} forEach units _group;
	} forEach _groups;

	{
		if (isTouchingGround _x) then {
			_x setPosASL getPosASL _x;
		};
	} forEach _vehiclesToReset;
};

[
	[group player] + A3C_HC_allGroupsClient_Current,
	true
] call _fnc_resetFlippedVehicles;

if !(A3C_isPlayerLeader) exitWith {};

if (!isNull _display) then {
	{
		private _control = _display displayCtrl _x;

		if (!isNull _control) then {
			_control ctrlShow false;
		};
	} forEach [
		IDC_MAP_DynamicCombo,
		IDC_MAP_SQWP_Parent
	];
};

private _units = (units group player) - [player];

A3C_REFRESHING = true;

/*
	The legacy implementation modified the shownHud array but did not apply
	it. showHUD is required for the change to take effect.
*/
private _hudState = shownHUD;
_hudState set [0, true];
showHUD _hudState;

private _initialGroup = group player;
private _groupId = groupID _initialGroup;

private _groupVariableNames = _initialGroup call MCSS_fnc_getObjectVarnames;

/*
	Store the player's known-target values before regrouping, because
	changing group membership may reset portions of AI knowledge.
*/
private _knownTargets = [];

{
	private _target = _x param [1, objNull];

	if (!isNull _target) then {
		private _knowledge = player knowsAbout _target;

		if (_knowledge > 0) then {
			_knownTargets pushBack [
				_target,
				_knowledge
			];
		};
	};
} forEach (
	player targetsQuery [
		objNull,
		sideUnknown,
		"",
		[],
		0
	]
);

{
	player reveal [_x, 4];
} forEach units group player;

private _temporaryGroup = createGroup side player;
private _lockedVehicles = [];

{
	private _unit = _x;
	private _vehicle = vehicle _unit;

	/*
		The legacy code also attempted setVehicleLock on soldiers who were
		on foot. Only actual vehicles are locked here.
	*/
	if (_vehicle != _unit) then {
		_lockedVehicles pushBackUnique _vehicle;

		[
			_vehicle,
			"LOCKED"
		] remoteExec [
			"setVehicleLock",
			_vehicle
		];
	};

	private _assignedTeam = if (player == cameraOn) then {
		assignedTeam _unit
	} else {
		_unit getVariable [
			"A3C_ASSIGNEDTEAM",
			"MAIN"
		]
	};

	_unit setVariable [
		"A3C_REFRESH_DATA",
		[
			_assignedTeam,
			expectedDestination _unit,
			assignedVehicle _unit,
			_unit getVariable ["A3C_PLOT_TEMP", []],
			_unit getVariable ["A3C_PLOT", []]
		],
		true
	];

	[_unit] joinSilent _temporaryGroup;
} forEach _units;

/*
	Recreate the player group when the player is not occupying formation
	index 1. By this point, every other original group member is temporarily
	in _temporaryGroup, so the original group is empty apart from the player.
*/
if (
	(player getVariable ["A3C_FORMATION_INDEX", -1]) != 1
) then {
	private _newGroup = createGroup side player;

	[player] joinSilent _newGroup;
	_newGroup setGroupIDGlobal [_groupId];

	deleteGroup _initialGroup;
};

_units joinSilent group player;

deleteGroup _temporaryGroup;

A3C_DISABLE_RADIAL = false;

{
	private _unit = _x;

	private _refreshData = _unit getVariable [
		"A3C_REFRESH_DATA",
		[]
	];

	private _assignedTeam = _refreshData param [
		0,
		"MAIN",
		[""]
	];

	private _expectedDestination = _refreshData param [
		1,
		[
			position vehicle _unit,
			"DoNotPlan"
		],
		[[]]
	];

	private _assignedVehicle = _refreshData param [
		2,
		objNull,
		[objNull]
	];

	private _destinationPosition = _expectedDestination param [
		0,
		position vehicle _unit,
		[[]]
	];

	private _destinationMode = _expectedDestination param [
		1,
		"DoNotPlan",
		[""]
	];

	_unit assignTeam _assignedTeam;

	_unit setVariable [
		"A3C_ASSIGNEDTEAM",
		_assignedTeam
	];

	switch (_destinationMode) do {
		case "LEADER PLANNED": {
			if (_unit == driver vehicle _unit) then {
				if !(_unit getVariable ["A3C_HOLD", false]) then {
					[
						_unit,
						_destinationPosition
					] call A3C_ai_shared_fnc_doMove;
				};
			};
		};

		case "DoNotPlan": {
			if (_unit == driver vehicle _unit) then {
				[
					_unit,
					position vehicle _unit
				] call A3C_ai_shared_fnc_doMove;
			};
		};

		case "VEHICLE PLANNED": {
			if (_unit == driver vehicle _unit) then {
				private _vehicle = vehicle _unit;

				[
					_vehicle,
					"LOCKED"
				] remoteExec [
					"setVehicleLock",
					_vehicle
				];

				if !(_unit getVariable ["A3C_HOLD", false]) then {
					[
						_unit,
						_destinationPosition
					] call A3C_ai_shared_fnc_doMove;
				};

				_unit assignAsDriver _vehicle;

				_vehicle spawn {
					sleep 5;

					[
						_this,
						"UNLOCKED"
					] remoteExec [
						"setVehicleLock",
						_this
					];
				};
			};
		};
	};

	_unit setDestination _expectedDestination;

	if (!isNull _assignedVehicle) then {
		if !(_unit in _assignedVehicle) then {
			_unit assignAsCargo _assignedVehicle;

			[_unit] allowGetIn true;
			[_unit] orderGetIn true;
		};
	};

	[_unit] call A3C_main_fnc_setVehicleVarname;
} forEach _units;

private _setMaximumSkill = profileNamespace getVariable [
	"A3C_SKILL_VAR",
	false
];

{
	private _unit = _x;

	[_unit] call A3C_ai_squad_fnc_initializeUnit;

	if (_setMaximumSkill) then {
		_unit setSkill 1;
	};
} forEach units group player;

profileNamespace setVariable [
	"A3C_GROUPUNITS",
	units group player
];

{
	private _unit = _x;

	_unit setVariable [
		"A3C_FORMATION_INDEX",
		[_unit] call A3C_main_fnc_getUnitIndex,
		true
	];
} forEach units group player;

(group player) selectLeader player;

if (
	A3C_MAP_CommandMode == "HC"
	&& {
		A3C_HC_allGroupsClient_Current isEqualTo []
	}
) then {
	A3C_MAP_CommandMode = "INF";

	["INF"] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
};

{
	_x params [
		"_target",
		"_knowledge"
	];

	player reveal [
		_target,
		_knowledge
	];
} forEach _knownTargets;

/*
	Unlock only the actual vehicles locked during the temporary regrouping
	stage, rather than evaluating vehicle _unit again after three seconds.
*/
(+_lockedVehicles) spawn {
	sleep 3;

	{
		if (!isNull _x) then {
			[
				_x,
				"UNLOCKED"
			] remoteExec [
				"setVehicleLock",
				_x
			];
		};
	} forEach _this;
};

/*
	Delete local markers that are no longer referenced by any current unit
	plot or shared polygon.
*/
{
	private _marker = _x;
	private _keepMarker = false;

	{
		private _unit = _x;

		{
			private _plotVariable = _x;
			private _plotData = _unit getVariable [
				_plotVariable,
				[]
			];

			if (
				_plotData findIf {
					private _markerReferences = _x param [
						1,
						[]
					];

					_marker in _markerReferences
				} > -1
			) exitWith {
				_keepMarker = true;
			};
		} forEach [
			"A3C_PLOT",
			"A3C_PLOT_TEMP"
		];

		if (_keepMarker) exitWith {};
	} forEach (
		(units group player) - [player]
	);

	if (!_keepMarker) then {
		_keepMarker = A3C_ALL_POLYS findIf {
			private _polygonMarkers = _x param [
				2,
				[]
			];

			_marker in _polygonMarkers
		} > -1;
	};

	if (!_keepMarker) then {
		deleteMarkerLocal _marker;
	};
} forEach A3C_MARKERS;

/*
	Reissue missionNamespace references to the rebuilt player group.

	This replaces:
	call compile format ["%1 = group player", _x]
*/
{
	private _variableName = _x;

	if (
		_variableName isEqualType ""
		&& {
			_variableName != ""
		}
	) then {
		missionNamespace setVariable [
			_variableName,
			group player
		];
	};
} forEach _groupVariableNames;

A3C_UNITCOUNTER = count units group player;

/*
	Preserved delayed multiplayer team reassignment. This appears to defend
	against team assignments being lost shortly after the regroup operation.
*/
if (isMultiplayer) then {
	{
		private _unit = _x;

		private _refreshData = _unit getVariable [
			"A3C_REFRESH_DATA",
			[]
		];

		private _assignedTeam = _refreshData param [
			0,
			"MAIN",
			[""]
		];

		[
			_unit,
			_assignedTeam
		] spawn {
			params [
				"_unit",
				"_assignedTeam"
			];

			sleep 0.5;

			_unit assignTeam _assignedTeam;

			_unit setVariable [
				"A3C_ASSIGNEDTEAM",
				_assignedTeam
			];
		};
	} forEach _units;
};

[
	[group player] + A3C_HC_allGroupsClient_Current,
	false
] call _fnc_resetFlippedVehicles;

if (player == driver vehicle player) then {
	[] spawn {
		sleep 1;

		player doFollow player;

		if (currentCommand player == "STOP") then {
			player doMove position vehicle player;
			player moveTo position vehicle player;
		};
	};
};

[] call A3C_UI_FNC_ADD_KEYBINDS;

[_displayId] call A3C_ui_shared_fnc_Tree_labelItems;

if (behaviour player != "AWARE") then {
	player setBehaviour "AWARE";
};

if (combatMode player != "YELLOW") then {
	player setCombatMode "YELLOW";
};

// Refresh map and HUD UI.
[] call A3C_ui_mapOverlay_fnc_refreshMapUiDrawHandler;

[] call A3C_UI_mainDisplay_fnc_refreshHudUiDrawHandler;

[] spawn {
	sleep 0.5;

	A3C_REFRESHING = false;
};
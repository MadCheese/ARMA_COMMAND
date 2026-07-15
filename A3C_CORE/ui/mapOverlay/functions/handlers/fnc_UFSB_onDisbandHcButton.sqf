#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onDisbandHcButton

private _display = findDisplay IDD_MAP_OVERLAY;

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
];

//~~ below is not bulletproof! what if AICOmmand, but not synced to module
private _isHighCommand = (
	{
		typeOf _x in [
			"HighCommand",
			"AdvancedAICommand_Commanders"
		]
	} count synchronizedObjects player > 0
) && {hcShownBar};

private _isLoop = false;
private _loopPos = [0, 0, 0];
private _loopDest = [0, 0, 0];

if (
	count A3C_SELECTED_UNITS == 0
	|| {A3C_MAP_CommandMode == "HC"}
) exitWith {};

private _unitArray =
	profileNamespace getVariable "A3C_GROUPUNITS";

// Disband units.
private _units = A3C_SELECTED_UNITS;

{
	private _subordinate = _x;

	if !(_subordinate in A3C_SELECTED_UNITS) then {
		if (
			{
				_subordinate in vehicle _x
			} count A3C_SELECTED_UNITS > 0
		) then {
			if !(_subordinate in vehicle player) then {
				_units pushBack _subordinate;
			};
		};
	};
} forEach (
	(units group player) - [player]
);

private _newGroup = createGroup side player;

private _disbandedPhonetics = [];

{
	if (
		[
			"A3C-",
			groupID _x
		] call BIS_fnc_inString
	) then {
		_disbandedPhonetics pushBackUnique _x;
	};
} forEach A3C_HC_allGroupsClient_Current;

_newGroup setGroupIDGlobal [
	format [
		"A3C-%1",
		[
			(count _disbandedPhonetics + 1) max 1
		] call A3C_main_fnc_numberToPhonetic
	]
];

private _unit = A3C_SELECTED_UNITS select 0;

_loopPos = position _unit;

{
	private _candidate = _x;

	{
		if (_x == _candidate) then {
			_unitArray set [_forEachIndex, objNull];
		};
	} forEach _unitArray;

	deleteMarkerLocal (
		_x getVariable "A3C_TAB_MARKER"
	); //~~ HCWP ALERT

	{
		_unit setVariable [_x, false];
	} forEach [
		"A3C_HOLD",
		"A3C_HOLD_COVER"
	];
} forEach _units;

_units joinSilent _newGroup;

A3C_HC_DISBANDED pushBack _newGroup;

_newGroup setVariable [
	"d_do_not_delete",
	true,
	true
];

if (_isHighCommand) then {
	player groupChat "Group Added To High Command";
	player hcSetGroup [
		_newGroup,
		"HQ",
		"teamred"
	];
};

[
	(units group player) - [player]
] call A3C_GROUP_RESET;

[
	_newGroup,
	"ALL"
] call A3C_ai_highCommand_fnc_deleteAllWaypoints;

if (count (_unit getVariable "A3C_PLOT") > 0) then {
	{
		private _waypointData = _x;

		_waypointData params [
			"_wpPositions",
			"_wpMarkers",
			"_wpAction",
			"_wpCondition",
			"_wpStances",
			"_wpSyncData",
			"_wpCompleted",
			"_wpCombatMode",
			"_wpSpeed",
			"_wpFlyInHeight",
			"_wpLoopValue",
			"_wpRadius"
		];

		private _timeout = if ((_wpAction select 0) == "TIMEOUT") then {
			_wpAction select 1
		} else {
			0
		};

		private _landingData = if ((_wpAction select 0) == "LANDING") then {
			_wpAction select 1
		} else {
			"NONE"
		};

		if (_forEachIndex == 0) then {
			[
				_newGroup,
				position leader _newGroup,
				[],
				"MOVE",
				[
					0,
					_timeout,
					_wpStances select 0,
					_wpStances select 1,
					_wpSpeed,
					"NONE"
				],
				false
			] call A3C_ai_highCommand_fnc_addWaypoint;
		};

		if (
			_forEachIndex
				>= ((_unit getVariable "A3C_CURRENTWAYPOINT_INDEX") - 1)
		) then {
			private _params = [
				_newGroup,
				_wpPositions select 0,
				[],
				"MOVE",
				[
					0,
					_timeout,
					_wpStances select 0,
					_wpStances select 1,
					_wpSpeed,
					_landingData
				]
			];

			if (_wpLoopValue < -1) then {
				_isLoop = true;
				_loopPos = _wpPositions;
			};

			if (_wpLoopValue > -1) then {
				_loopDest = _wpPositions;
			};

			if (_isLoop) then {
				_params pushBack true;
			};

			_params call A3C_ai_highCommand_fnc_addWaypoint;
		};
	} forEach (
		_unit getVariable "A3C_PLOT"
	);

	if (_isLoop) then {
		[
			_newGroup,
			[
				_loopPos,
				5,
				[
					_loopPos,
					_loopDest
				] call BIS_fnc_dirTo
			] call BIS_fnc_relPos,
			[],
			"CYCLE"
		] call A3C_ai_highCommand_fnc_addWaypoint;
	};

	[
		_newGroup,
		0
	] setWaypointPosition [
		_loopPos,
		0
	];
} else {
	_newGroup setVariable [
		"AIC_Waypoints",
		[
			0,
			[]
		],
		true
	];
};

[
	A3C_SELECTED_UNITS,
	true,
	false
] spawn A3C_AI_Shared_cancelUnitPlot;

if (hcShownBar) then {
	hcShowBar false;
	sleep 0.1;
	hcShowBar true;
};

if (A3C_MAP_CommandMode in ["INF", "AIR"]) then {
	if (count units group player == 1) then {
		["HC"] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
		A3C_MAP_CommandMode = "HC";
	};
};

A3C_SELECTED_UNITS = [];

{
	[_x] spawn A3C_ai_highCommand_fnc_restoreUnitRole;
} forEach units _newGroup;

sleep 0.2;

if (A3C_MAP_CommandMode == "HC") then {
	if (count units group player == 1) then {
		["HC"] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
		A3C_MAP_CommandMode = "HC";
	};
};

A3C_BOOL_MAP_MD = false;
A3C_BOOL_MAP_MU = false;

[] spawn {
	sleep 1;

	{
		vehicle _x setVehicleLock "UNLOCKED";
	} forEach units group player;
};
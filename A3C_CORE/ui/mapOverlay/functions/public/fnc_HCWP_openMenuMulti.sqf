#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCWP_openMenuMulti

//-- Stage 1 implementation:
//-- Opens and lays out the multi-waypoint menu without applying or deleting
//-- waypoints. Confirm and Delete remain disabled until later stages.


disableSerialization;

params [
	"_gp",
	"_wpiC",
	"_mode",
	"_a3c_dsp",
	"_ctrlPosWPM",
	[
		"_selection",
		+A3C_Selection_MultiWaypoint
	]
];

private _normalizedSelection = [];

{
	_normalizedSelection pushBackUnique _x;
} forEach _selection;

if (count _normalizedSelection <= 1) exitWith {};

private _clickedWaypoint = [
	_gp,
	_wpiC
];

if !(_clickedWaypoint in _normalizedSelection) exitWith {};

private _groups = [];

{
	_groups pushBackUnique (_x select 0);
} forEach _normalizedSelection;

private _containsBlacklistedWaypoint = _normalizedSelection findIf {
	_x in A3C_BLACKLIST_WAYPOINT_EDIT
} > -1;

if (_containsBlacklistedWaypoint) exitWith {
	hint "At least one selected waypoint can no longer be edited";
};

private _containsPlayer = _groups findIf {
	private _group = _x;

	{
		isPlayer _x
	} count (units _group) > 0
} > -1;

if (_containsPlayer) exitWith {
	hint "Player detected in selected groups - action prohibited";
};

private _display = findDisplay _a3c_dsp;

if (isNull _display) exitWith {};

_display setVariable [
	"A3C_HCWP_MULTI_ACTIVE",
	true
];
_display setVariable [
	"A3C_HCWP_MULTI_INITIALIZING",
	true
];
_display setVariable [
	"A3C_HCWP_MULTI_SELECTION",
	+_normalizedSelection
];
_display setVariable [
	"A3C_HCWP_MULTI_GROUPS",
	+_groups
];

A3C_HC_ACTIVEGROUP = _gp;
A3C_HC_ACTIVE_IND = _wpiC;
A3C_HC_EDIT_ACTION = "NO CHANGE";

private _menu =
	_display displayCtrl IDC_MAP_HCWP_Parent;
private _header =
	_display displayCtrl IDC_MAP_HCWP_GROUPNAME_TXT;
private _behaviourCombo =
	_display displayCtrl IDC_MAP_HCWP_Behaviour_Combo;
private _combatModeCombo =
	_display displayCtrl IDC_MAP_HCWP_CombatMode_Combo;
private _speedCombo =
	_display displayCtrl IDC_MAP_HCWP_Speed_Combo;
private _formationCombo =
	_display displayCtrl IDC_MAP_HCWP_Formation_Combo;
private _completionParent =
	_display displayCtrl IDC_MAP_HCWP_Completion_Parent;
private _completionHeader =
	_display displayCtrl IDC_MAP_HCWP_Completion_Header_TXT;
private _completionTypeCombo =
	_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Type;
private _completionValueCombo =
	_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode;
private _typeParent =
	_display displayCtrl IDC_MAP_HCWP_Type_Parent;
private _typeCombo =
	_display displayCtrl IDC_MAP_HCWP_Type_Action;
private _actionMainParent =
	_display displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN;
private _actionFormationCombo =
	_display displayCtrl IDC_MAP_HCWP_Action_Formation_Combo;
private _actionCompletionTypeCombo =
	_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type;
private _actionCompletionValueCombo =
	_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode;
private _actionAdditionalParent =
	_display displayCtrl IDC_MAP_HCWP_Action_Parent_ADD;
private _confirmButton =
	_display displayCtrl IDC_MAP_HCWP_Confirm_TEXT;
private _deleteButton =
	_display displayCtrl IDC_MAP_HCWP_Delete_TEXT;
private _confirmBackground =
	_display displayCtrl IDC_MAP_HCWP_Confirm_BG;
private _deleteBackground =
	_display displayCtrl IDC_MAP_HCWP_Delete_BG;


//-- Show the outer controls group first. Showing it after hiding nested groups
//-- re-exposes those groups in Arma's controls-group hierarchy.

_menu ctrlShow true;

_header ctrlSetText "MULTIPLE WAYPOINTS";
_completionHeader ctrlSetText "COMPLETION";

_completionParent ctrlShow true;
_typeParent ctrlShow true;
_completionValueCombo ctrlShow false;
_actionMainParent ctrlShow false;
_actionAdditionalParent ctrlShow false;


//-- Keep the button row visible for layout testing, but disable its active
//-- controls until multi-confirm and multi-delete are implemented.

{
	_x ctrlShow true;
} forEach [
	_confirmBackground,
	_confirmButton,
	_deleteBackground,
	_deleteButton
];

// {
// 	_x ctrlEnable false;
// } forEach [
// 	_confirmButton,
// 	_deleteButton
// ];

private _fncPopulateCombo = {
	params [
		"_control",
		"_entries",
		[
			"_selectedIndex",
			0
		]
	];

	lbClear _control;

	{
		[
			_control,
			_x
		] call A3C_ui_shared_fnc_addLbEntry;
	} forEach _entries;

	_control lbSetCurSel _selectedIndex;
};

[
	_behaviourCombo,
	[
		"KEEP CURRENT",
		"UNCHANGED",
		"CARELESS",
		"SAFE",
		"AWARE",
		"COMBAT",
		"STEALTH"
	]
] call _fncPopulateCombo;

_behaviourCombo lbSetTooltip [
	0,
	"Preserve the behaviour of each selected waypoint."
];
_behaviourCombo lbSetTooltip [
	1,
	"Assign Arma's native UNCHANGED behaviour value to every selected waypoint."
];

[
	_combatModeCombo,
	[
		"KEEP CURRENT",
		"NO CHANGE",
		"NEVER FIRE",
		"HOLD FIRE, DEFEND",
		"HOLD FIRE, ENGAGE",
		"OPEN FIRE",
		"FIRE & ENGAGE"
	]
] call _fncPopulateCombo;

private _combatModeColors = [
	[0.5, 0.5, 0.5, 1],
	[0.5, 0.5, 0.5, 1],
	A3C_UI_COLOR_BLUE,
	[0, 1, 0, 1],
	[1, 1, 1, 1],
	A3C_UI_COLOR_YELLOW,
	A3C_UI_COLOR_RED
];

{
	_combatModeCombo lbSetColor [
		_forEachIndex,
		_x
	];
} forEach _combatModeColors;

_combatModeCombo lbSetTooltip [
	0,
	"Preserve the combat mode of each selected waypoint."
];
_combatModeCombo lbSetTooltip [
	1,
	"Assign Arma's native NO CHANGE combat-mode value to every selected waypoint."
];

[
	_speedCombo,
	[
		"KEEP CURRENT",
		"UNCHANGED",
		"LIMITED",
		"NORMAL",
		"FULL"
	]
] call _fncPopulateCombo;

_speedCombo lbSetTooltip [
	0,
	"Preserve the speed of each selected waypoint."
];
_speedCombo lbSetTooltip [
	1,
	"Assign Arma's native UNCHANGED speed value to every selected waypoint."
];

[
	_formationCombo,
	[
		"KEEP CURRENT",
		"COLUMN",
		"STAG. COL.",
		"WEDGE",
		"ECH LEFT",
		"ECH RIGHT",
		"VEE",
		"LINE",
		"FILE",
		"DIAMOND",
		"NO CHANGE"
	]
] call _fncPopulateCombo;

_formationCombo lbSetTooltip [
	0,
	"Preserve the formation of each selected waypoint."
];
_formationCombo lbSetTooltip [
	10,
	"Assign Arma's native NO CHANGE formation value to every selected waypoint."
];

[
	_completionTypeCombo,
	[
		"KEEP CURRENT",
		"ARRIVAL",
		"GO-CODE",
		"TIMEOUT",
		"DAYTIME"
	]
] call _fncPopulateCombo;

_completionTypeCombo lbSetTooltip [
	0,
	"Preserve the completion condition of each selected waypoint."
];

private _availableActions = [
	"NO CHANGE",
	"MOVE",
	"SEARCH / DESTROY"
];

private _allGroupsCanTransportUnload = true;
private _allGroupsCanCombatLand = true;
private _allGroupsCanLand = true;

{
	private _group = _x;
	private _leader = leader _group;
	private _leaderVehicle = vehicle _leader;
	private _groupControlsLeaderVehicle =
		!isNull objectParent _leader
		&& {
			driver _leaderVehicle in units _group
		};

	if !(
		_groupControlsLeaderVehicle
		&& {
			count fullCrew [
				_leaderVehicle,
				"cargo",
				true
			] > 0
		}
	) then {
		_allGroupsCanTransportUnload = false;
	};

	if !(
		_groupControlsLeaderVehicle
		&& {
			[
				_leaderVehicle
			] call A3C_main_fnc_canHoverAircraft
		}
	) then {
		_allGroupsCanCombatLand = false;
	};

	if !(
		_groupControlsLeaderVehicle
		&& {_leaderVehicle isKindOf "AIR"}
	) then {
		_allGroupsCanLand = false;
	};
} forEach _groups;

if (_allGroupsCanTransportUnload) then {
	_availableActions pushBack "TRANSPORT UNLOAD";
};

if (_allGroupsCanCombatLand) then {
	_availableActions pushBack "COMBAT LAND";
};

if (_allGroupsCanLand) then {
	_availableActions pushBack "LAND";
};

[
	_typeCombo,
	_availableActions
] call _fncPopulateCombo;

_typeCombo lbSetTooltip [
	0,
	"Preserve the current type of each selected waypoint."
];

private _fullWidth = (
	ctrlPosition (
		_display displayCtrl IDC_MAP_HCWP_GROUPNAME_BG
	)
) select 2;

private _completionTypePosition =
	ctrlPosition _completionTypeCombo;
_completionTypePosition set [
	2,
	_fullWidth
];
_completionTypeCombo ctrlSetPosition _completionTypePosition;
_completionTypeCombo ctrlCommit 0;

private _referencePosition =
	ctrlPosition _formationCombo;
private _referenceY =
	(_referencePosition select 1)
	+ (_referencePosition select 3);

private _controlPosition =
	ctrlPosition _completionParent;
_controlPosition set [
	1,
	_referenceY
];
_completionParent ctrlSetPosition _controlPosition;
_completionParent ctrlCommit 0;

_referenceY =
	_referenceY
	+ (_controlPosition select 3);

_controlPosition =
	ctrlPosition _typeParent;
_controlPosition set [
	1,
	_referenceY
];
_typeParent ctrlSetPosition _controlPosition;
_typeParent ctrlCommit 0;

_referenceY =
	_referenceY
	+ (_controlPosition select 3);

_controlPosition =
	ctrlPosition _actionMainParent;
_controlPosition set [
	1,
	_referenceY
];
_actionMainParent ctrlSetPosition _controlPosition;
_actionMainParent ctrlCommit 0;

{
	private _buttonPosition = ctrlPosition _x;
	_buttonPosition set [
		1,
		_referenceY
	];
	_x ctrlSetPosition _buttonPosition;
	_x ctrlCommit 0;
} forEach [
	_display displayCtrl IDC_MAP_HCWP_Confirm_BG,
	_confirmButton,
	_display displayCtrl IDC_MAP_HCWP_Delete_BG,
	_deleteButton
];

_ctrlPosWPM = [
	_a3c_dsp,
	IDC_MAP_HCWP_Parent,
	_ctrlPosWPM
] call A3C_ui_mapOverlay_fnc_findCtrlSafePos;

_menu ctrlSetPosition _ctrlPosWPM;
_menu ctrlCommit 0;

_display setVariable [
	"A3C_HCWP_MULTI_INITIALIZING",
	false
];

ctrlSetFocus _menu;

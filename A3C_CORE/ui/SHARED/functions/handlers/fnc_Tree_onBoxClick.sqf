#include "..\..\..\mapOverlay\dialog_defines.hpp"

// A3C_ui_shared_fnc_Tree_onBoxClick

/*
	Handles mouse-button interaction with the shared tree on the map overlay.

	Right-click:
		Center the map on the first selected unit or group.

	Shift + right-click in squad mode:
		Open the team-color selection list.

	Shift + right-click in HC mode:
		Open the high-command group action menu.

	The CTRL and ALT event parameters are retained for event-handler
	compatibility but are not currently used.
*/
params [
	["_displayCtrl", controlNull, [controlNull]],
	["_mouseButton", 0, [0]],
	["_screenX", 0, [0]],
	["_screenY", 0, [0]],
	["_shiftPressed", false, [false]],
	["_ctrlPressed", false, [false]],
	["_altPressed", false, [false]]
];

/*
	This handler is map-overlay-specific. Its actions depend on map controls
	and the main map display.
*/
private _mapOverlayDisplay = findDisplay IDD_MAP_OVERLAY;

if (isNull _mapOverlayDisplay) exitWith {};

/*
	Only right-clicks act on the current tree selection.
*/
if (_mouseButton == 0) exitWith {};

private _selectedEntities = +(
	missionNamespace getVariable [
		"A3C_SELECTED_UNITS",
		[]
	]
);

if (_selectedEntities isEqualTo []) exitWith {};

private _commandMode = missionNamespace getVariable [
	"A3C_MAP_CommandMode",
	"SQUAD"
];

/*
	Shift + right-click in squad mode opens the team-color selector.
*/
if (
	_shiftPressed
	&& {_commandMode != "HC"}
) exitWith {
	private _selectedUnit = _selectedEntities select 0;

	/*
		Team assignment is valid only for squad-unit selections.
	*/
	if !(_selectedUnit isEqualType objNull) exitWith {};

	private _combo = _mapOverlayDisplay displayCtrl IDC_MAP_DynamicCombo;

	if (isNull _combo) exitWith {};

	lbClear _combo;

	_combo ctrlShow true;
	ctrlSetFocus _combo;

	A3C_LB_MODE = 3;

	_combo ctrlSetPosition [
		_screenX,
		_screenY
	];

	_combo ctrlCommit 0;

	{
		[
			_combo,
			_x
		] call A3C_ui_shared_fnc_addLbEntry;
	} forEach [
		"RED",
		"GREEN",
		"BLUE",
		"YELLOW",
		"WHITE"
	];

	private _assignedTeam = if (player == cameraOn) then {
		assignedTeam _selectedUnit
	} else {
		_selectedUnit getVariable [
			"A3C_ASSIGNEDTEAM",
			"MAIN"
		]
	};

	private _teamIndex = [
		"RED",
		"GREEN",
		"BLUE",
		"YELLOW",
		"MAIN"
	] find _assignedTeam;

	if (_teamIndex >= 0) then {
		[
			_combo,
			_teamIndex
		] call A3C_ui_shared_fnc_lbSetCurSel;
	};
};

/*
	Shift + right-click in HC mode opens the group action menu.
*/
if (_shiftPressed) exitWith {
	A3C_SELECTED_HC_GROUPS_SETTINGS = _selectedEntities select {
		_x isEqualType grpNull
	};

	private _selectedGroupCount =
		count A3C_SELECTED_HC_GROUPS_SETTINGS;

	if (_selectedGroupCount > 1) then {
		[
			A3C_SELECTED_HC_GROUPS_SETTINGS,
			1
		] call A3C_ui_mapOverlay_fnc_HCGP_openMenu;
	} else {
		if (_selectedGroupCount == 1) then {
			[
				A3C_SELECTED_HC_GROUPS_SETTINGS select 0,
				0
			] call A3C_ui_mapOverlay_fnc_HCGP_openMenu;
		};
	};
};

/*
	Normal right-click centers the main map on the first selected unit or
	group.
*/
private _selectedEntity = _selectedEntities select 0;

private _targetPosition = if (
	_selectedEntity isEqualType grpNull
) then {
	private _leader = leader _selectedEntity;

	if (isNull _leader) exitWith {
		[]
	};

	position _leader
} else {
	if (_selectedEntity isEqualType objNull) then {
		if (isNull _selectedEntity) exitWith {
			[]
		};

		position _selectedEntity
	} else {
		[]
	}
};

if (_targetPosition isEqualTo []) exitWith {};

private _mainMapDisplay = findDisplay 12;

if (isNull _mainMapDisplay) exitWith {};

private _mapControl = _mainMapDisplay displayCtrl 51;

if (isNull _mapControl) exitWith {};

_mapControl ctrlEnable true;

_mapControl ctrlMapAnimAdd [
	0.1,
	ctrlMapScale _mapControl,
	_targetPosition
];

ctrlMapAnimCommit _mapControl;

/*
	The map is enabled briefly so the animation can execute, then restored
	to its previous disabled interaction state.
*/
[
	_mapControl
] spawn {
	params [
		"_mapControl"
	];

	sleep 0.2;

	if (!isNull _mapControl) then {
		_mapControl ctrlEnable false;
	};
};
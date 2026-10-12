#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\hcgp_layout.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCGP_openMenu

disableSerialization;

params [
	"_group",
	"_modeNum"
];

A3C_HC_NearStatics = [];

private _display = findDisplay IDD_MAP_OVERLAY;

private _startupBar =
	_display displayCtrl IDC_MAP_HCGP_STARTUP_BAR;

private _startupText =
	_display displayCtrl IDC_MAP_HCGP_STARTUP_TEXT;

_startupText ctrlSetText "CONNECTING";
_startupBar progressSetPosition 0.1;

{
	_x ctrlShow true;
} forEach [
	_startupBar,
	_startupText
];

private _groupMenuControlsGroup =
	_display displayCtrl IDC_MAP_HCGP_Parent;

// Hide the controls group until the dashboard has been initialized. DO NOT use the external function here
_groupMenuControlsGroup ctrlShow false;

_groupMenuControlsGroup ctrlSetPosition [
	0.5,
	0.3
];

_groupMenuControlsGroup ctrlCommit 0;

// Remove groups that are currently controlled by another player.
{
	private _selectedGroup = _x;
	private _leader = leader _selectedGroup;

	if (
		isPlayer _leader
		&& {_leader != player}
	) then {
		A3C_SELECTED_HC_GROUPS_SETTINGS =
			A3C_SELECTED_HC_GROUPS_SETTINGS - [_selectedGroup];

		systemChat format [
			"A3C: %1 is controlled by another player",
			_selectedGroup
		];
	};
} forEach A3C_SELECTED_HC_GROUPS_SETTINGS;

if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) exitWith {};

// A new owner on every opening, including multi-group selection. Closing or
// reopening invalidates any dashboard worker holding an earlier context.
private _serial = (_groupMenuControlsGroup getVariable ["A3C_HCGP_LayoutSerial", 0]) + 1;
_groupMenuControlsGroup setVariable ["A3C_HCGP_LayoutSerial", _serial];
private _layoutContext = [_serial, +A3C_SELECTED_HC_GROUPS_SETTINGS];
_groupMenuControlsGroup setVariable ["A3C_HCGP_LayoutContext", _layoutContext];
[_display, A3C_MAP_DASH_BG_H, _layoutContext] call A3C_ui_mapOverlay_fnc_HCGP_layout;


if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
	private _groupStance =
		_group getVariable ["A3C_GROUP_STANCE", "AUTO"];

	//-- WHY>?
	[
		_groupStance
	] call A3C_ui_mapOverlay_fnc_HCGP_onStanceButton;
} else {
	{
		_x ctrlSetTextColor [1, 1, 1, 0.1];
	} forEach (
		[
			"map_hcgp_imgs_Stance"
		] call FUNC(ctrlGroup)
	);
};

if (_modeNum == 0) then {
	A3C_Map_HC_groupContext_Color =
		_group getVariable ["A3C_HC_GroupColor", "blue"];
};

private _listboxDefinitions = [
	[
		IDC_MAP_HCGP_LISTBOX_BEHAVIOUR,
		[
			"Careless",
			"Safe",
			"Aware",
			"Combat",
			"Stealth"
		]
	],
	[
		IDC_MAP_HCGP_LISTBOX_COMBATMODE,
		[
			"Never Fire",
			"Defend Only",
			"Engage At Will",
			"Fire At Will",
			"F&E At Will"
		]
	],
	[
		IDC_MAP_HCGP_LISTBOX_FORMATION,
		[
			"Column",
			"Stag Column",
			"Wedge",
			"Ech Left",
			"Ech Right",
			"Vee",
			"Line",
			"File",
			"Diamond"
		]
	],
	[
		IDC_MAP_HCGP_LISTBOX_TEAMCOLOR,
		[
			"Red",
			"Blue",
			"Green",
			"Black",
			"White"
		]
	]
];

{
	_x params [
		"_controlId",
		"_entries"
	];

	private _control =
		_display displayCtrl _controlId;

	private _definitionIndex = _forEachIndex;

	lbClear _control;

	[
		_control,
		-1
	] call A3C_ui_shared_fnc_lbSetCurSel;

	{
		private _entry = _x;
		private _entryIndex = _forEachIndex;

		[
			_control,
			_entry
		] call A3C_ui_shared_fnc_addLbEntry;

		if (_modeNum == 0) then {
			switch (_definitionIndex) do {
				case 0: {
					if (behaviour leader _group == _entry) then {
						A3C_Map_HC_groupContext_Behaviour = _entry;

						[
							_control,
							_entryIndex
						] call A3C_ui_shared_fnc_lbSetCurSel;
					};
				};

				case 1: {
					{
						private _combatModeCode = _x;
						private _combatModeIndex = _forEachIndex;

						if (
							combatMode _group
								== _combatModeCode
						) then {
							A3C_Map_HC_groupContext_CMode =
								_combatModeCode;

							[
								_control,
								_combatModeIndex
							] call A3C_ui_shared_fnc_lbSetCurSel;
						};
					} forEach [
						"BLUE",
						"GREEN",
						"WHITE",
						"YELLOW",
						"RED"
					];
				};

				case 2: {
					if (formation _group == _entry) then {
						A3C_Map_HC_groupContext_Form = _entry;

						[
							_control,
							_entryIndex
						] call A3C_ui_shared_fnc_lbSetCurSel;
					};
				};

				case 3: {
					if (
						_group getVariable [
							"A3C_HC_GroupColor",
							"Blue"
						] == _entry
					) then {
						A3C_Map_HC_groupContext_Color = _entry;

						[
							_control,
							_entryIndex
						] call A3C_ui_shared_fnc_lbSetCurSel;
					};
				};
			};
		};
	} forEach _entries;
} forEach _listboxDefinitions;

_startupBar progressSetPosition 0.75;

// Population can yield in a scheduled caller; do not show an obsolete menu.
if (isNull _display || {!((_groupMenuControlsGroup getVariable ["A3C_HCGP_LayoutContext", []]) isEqualTo _layoutContext)}
    || {!(A3C_SELECTED_HC_GROUPS_SETTINGS isEqualTo (_layoutContext select 1))}) exitWith {};

if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
    // The shell is synchronous. Its final worker notifies the same layout
    // helper after resizing; ctrlShown is not a completion signal.
    [_layoutContext] call A3C_ui_shared_fnc_createDashBoard;
} else {
    (_display displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
};
if (isNull _display || {!((_groupMenuControlsGroup getVariable ["A3C_HCGP_LayoutContext", []]) isEqualTo _layoutContext)}) exitWith {};

{
	_x ctrlShow false;
} forEach [
	_startupBar,
	_startupText
];

_groupMenuControlsGroup ctrlShow true;

if (
	profileNamespace getVariable [
		"HC_GROUP_RESPONSE",
		false
	]
) then {
	{
		(
			_display displayCtrl _x
		) ctrlShow false;
	} forEach [
		IDC_MAP_HCGP_CONFIRM_BG,
		IDC_MAP_HCGP_CONFIRM_BTN
	];
};

// Unfortunately, this has to happen after the controls group is shown.
[
	false
] call A3C_ui_shared_fnc_highCommand_actionsLabel;

playSound "ReadOutHideClick1";
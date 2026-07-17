#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
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

// Hide the controls group until the dashboard has been initialized.
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

if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
	[] call A3C_ui_shared_fnc_createDashBoard;

	waitUntil {
		isNull findDisplay IDD_MAP_OVERLAY
		|| {
			ctrlShown (
				findDisplay IDD_MAP_OVERLAY
					displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT
			)
		}
	};

	private _dashboardDisplay =
		findDisplay IDD_MAP_OVERLAY;

	if (isNull _dashboardDisplay) exitWith {};

	private _dashboardControl =
		_dashboardDisplay
			displayCtrl IDC_SHARED_UI_DASHBOARD_BG;

	if (isNull _dashboardControl) exitWith {
		systemChat "layout failed: 11015 not found";
	};

	private _showResponseButton = !(
		profileNamespace getVariable [
			"HC_GROUP_RESPONSE",
			false
		]
	);

	private _dashboardPosition =
		ctrlPosition _dashboardControl;

	private _dashboardBottom =
		(_dashboardPosition select 1)
			+ (_dashboardPosition select 3);

	// Controls defining the bottom edge of the row above the listboxes.
	private _topRowControlIds = [
		IDC_MAP_HCGP_STANCES_AUTO_IMG
	];

	private _topBoundary = -1;

	{
		private _control =
			_dashboardDisplay displayCtrl _x;

		if !(isNull _control) then {
			private _position = ctrlPosition _control;

			private _bottom =
				(_position select 1)
					+ (_position select 3);

			if (_bottom > _topBoundary) then {
				_topBoundary = _bottom;
			};
		};
	} forEach _topRowControlIds;

	if (_topBoundary < 0) exitWith {
		systemChat "layout failed: no top row controls found";
	};

	// Height reserved for the optional response button.
	private _responseButtonHeight = 0;

	if (_showResponseButton) then {
		private _responseControl =
			_dashboardDisplay
				displayCtrl IDC_MAP_HCGP_CONFIRM_BG;

		if !(isNull _responseControl) then {
			_responseButtonHeight =
				(ctrlPosition _responseControl) select 3;
		};
	};

	// Divide the remaining dashboard height between two listbox rows.
	private _availableHeight =
		_dashboardBottom
			- _topBoundary
			- _responseButtonHeight;

	private _rowHeight =
		_availableHeight / 2;

	// Top listbox row.
	{
		private _control =
			_dashboardDisplay displayCtrl _x;

		if !(isNull _control) then {
			private _position =
				ctrlPosition _control;

			_position set [
				1,
				_topBoundary
			];

			_position set [
				3,
				_rowHeight
			];

			_control ctrlSetPosition _position;
			_control ctrlCommit 0;
		};
	} forEach [
		IDC_MAP_HCGP_LISTBOX_BEHAVIOUR,
		IDC_MAP_HCGP_LISTBOX_COMBATMODE
	];

	// Bottom listbox row.
	{
		private _control =
			_dashboardDisplay displayCtrl _x;

		if !(isNull _control) then {
			private _position =
				ctrlPosition _control;

			_position set [
				1,
				_topBoundary + _rowHeight
			];

			_position set [
				3,
				_rowHeight
			];

			_control ctrlSetPosition _position;
			_control ctrlCommit 0;
		};
	} forEach [
		IDC_MAP_HCGP_LISTBOX_FORMATION,
		IDC_MAP_HCGP_LISTBOX_TEAMCOLOR
	];

	// Optional response button pair.
	{
		private _control =
			_dashboardDisplay displayCtrl _x;

		if !(isNull _control) then {
			if (_showResponseButton) then {
				private _position =
					ctrlPosition _control;

				_position set [
					1,
					_dashboardBottom
						- _responseButtonHeight
				];

				_control ctrlSetPosition _position;
				_control ctrlCommit 0;
				_control ctrlShow true;
			} else {
				_control ctrlShow false;
			};
		};
	} forEach [
		IDC_MAP_HCGP_CONFIRM_BG,
		IDC_MAP_HCGP_CONFIRM_BTN
	];
};

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
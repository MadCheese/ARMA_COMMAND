#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCWP_onLbChangeMulti

/*
 * Stage 1 implementation:
 * Handles visual state only. No waypoint property, type, script, statement,
 * condition, or deletion command is executed here.
 */

disableSerialization;

params [
	"_mode",
	"_lb"
];

private _display = findDisplay IDD_MAP_OVERLAY;

if (isNull _display) exitWith {};

if !(
	_display getVariable [
		"A3C_HCWP_MULTI_ACTIVE",
		false
	]
) exitWith {};

if (
	_display getVariable [
		"A3C_HCWP_MULTI_INITIALIZING",
		false
	]
) exitWith {};

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

	_display setVariable [
		"A3C_HCWP_MULTI_INITIALIZING",
		true
	];
	_control lbSetCurSel _selectedIndex;
	_display setVariable [
		"A3C_HCWP_MULTI_INITIALIZING",
		false
	];
};

private _fncGetUpcomingTimes = {
	date params [
		"_year",
		"_month",
		"_day",
		"_hour",
		"_minute"
	];

	_minute = if (
		((round (_minute * 0.1)) * 10) < _minute
	) then {
		(floor (_minute * 0.1)) * 10
	} else {
		(ceil (_minute * 0.1)) * 10
	};

	private _times = [];

	for "_i" from 1 to 7 do {
		if (_minute >= 60) then {
			_hour = _hour + 1;

			if (_hour >= 24) then {
				_hour = 0;
			};

			_minute = 0;
		};

		_times pushBack format [
			"%1:%2",
			[
				_hour
			] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp,
			[
				_minute
			] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp
		];

		_minute = _minute + 5;
	};

	_times
};

switch (_mode) do {
	case IDC_MAP_HCWP_Condition_Pre_Type: {
		private _typeCombo =
			_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Type;
		private _valueCombo =
			_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode;
		private _selectedType =
			toUpper (_typeCombo lbText _lb);
		private _fullWidth = (
			ctrlPosition (
				_display displayCtrl IDC_MAP_HCWP_GROUPNAME_BG
			)
		) select 2;
		private _typePosition =
			ctrlPosition _typeCombo;

		switch (_selectedType) do {
			case "GO-CODE": {
				[
					_valueCombo,
					[
						"A",
						"B",
						"C",
						"D"
					]
				] call _fncPopulateCombo;

				_valueCombo ctrlShow true;
				_typePosition set [
					2,
					_fullWidth / 2
				];
			};

			case "TIMEOUT": {
				[
					_valueCombo,
					[
						"30SEK",
						"60SEK",
						"90SEK",
						"2MIN",
						"3MIN",
						"4MIN"
					],
					2
				] call _fncPopulateCombo;

				_valueCombo ctrlShow true;
				_typePosition set [
					2,
					_fullWidth / 2
				];
			};

			case "DAYTIME": {
				[
					_valueCombo,
					call _fncGetUpcomingTimes
				] call _fncPopulateCombo;

				_valueCombo ctrlShow true;
				_typePosition set [
					2,
					_fullWidth / 2
				];
			};

			default {
				lbClear _valueCombo;
				_valueCombo ctrlShow false;
				_typePosition set [
					2,
					_fullWidth
				];
			};
		};

		_typeCombo ctrlSetPosition _typePosition;
		_typeCombo ctrlCommit 0;
	};

	case IDC_MAP_HCWP_Condition_Post_Type: {
		private _typeCombo =
			_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type;
		private _valueCombo =
			_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode;
		private _selectedType =
			toUpper (_typeCombo lbText _lb);

		switch (_selectedType) do {
			case "TIMEOUT": {
				[
					_valueCombo,
					[
						"30SEK",
						"60SEK",
						"90SEK",
						"2MIN",
						"3MIN",
						"4MIN"
					],
					2
				] call _fncPopulateCombo;
			};

			case "DAYTIME": {
				[
					_valueCombo,
					call _fncGetUpcomingTimes
				] call _fncPopulateCombo;
			};

			default {
				[
					_valueCombo,
					[
						"A",
						"B",
						"C",
						"D"
					]
				] call _fncPopulateCombo;
			};
		};
	};

	case IDC_MAP_HCWP_Type_Action: {
		private _typeCombo =
			_display displayCtrl IDC_MAP_HCWP_Type_Action;
		private _selectedAction =
			toUpper (_typeCombo lbText _lb);
		private _actionMainParent =
			_display displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN;
		private _actionAdditionalParent =
			_display displayCtrl IDC_MAP_HCWP_Action_Parent_ADD;
		private _typeParent =
			_display displayCtrl IDC_MAP_HCWP_Type_Parent;
		private _requiresActionSettings =
			_selectedAction == "COMBAT LAND";

		_actionAdditionalParent ctrlShow false;

		if (_requiresActionSettings) then {
			[
				_display displayCtrl IDC_MAP_HCWP_Action_Formation_Combo,
				[
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
				],
				6
			] call _fncPopulateCombo;

			[
				_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type,
				[
					"TIMEOUT",
					"GOCODE",
					"DAYTIME"
				],
				1
			] call _fncPopulateCombo;

			[
				_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode,
				[
					"A",
					"B",
					"C",
					"D"
				]
			] call _fncPopulateCombo;
		};

		private _referencePosition =
			ctrlPosition _typeParent;
		private _referenceY =
			(_referencePosition select 1)
			+ (_referencePosition select 3);

		private _actionMainPosition =
			ctrlPosition _actionMainParent;
		_actionMainPosition set [
			1,
			_referenceY
		];
		_actionMainParent ctrlSetPosition _actionMainPosition;
		_actionMainParent ctrlCommit 0;
		_actionMainParent ctrlShow _requiresActionSettings;

		if (_requiresActionSettings) then {
			_referenceY =
				_referenceY
				+ (_actionMainPosition select 3);
		};

		{
			private _buttonPosition =
				ctrlPosition _x;
			_buttonPosition set [
				1,
				_referenceY
			];
			_x ctrlSetPosition _buttonPosition;
			_x ctrlCommit 0;
		} forEach [
			_display displayCtrl IDC_MAP_HCWP_Confirm_BG,
			_display displayCtrl IDC_MAP_HCWP_Confirm_TEXT,
			_display displayCtrl IDC_MAP_HCWP_Delete_BG,
			_display displayCtrl IDC_MAP_HCWP_Delete_TEXT
		];

		private _menu =
			_display displayCtrl IDC_MAP_HCWP_Parent;
		private _menuPosition =
			ctrlPosition _menu;

		_menuPosition = [
			IDD_MAP_OVERLAY,
			IDC_MAP_HCWP_Parent,
			_menuPosition
		] call A3C_ui_mapOverlay_fnc_findCtrlSafePos;

		_menu ctrlSetPosition _menuPosition;
		_menu ctrlCommit 0;
	};
};

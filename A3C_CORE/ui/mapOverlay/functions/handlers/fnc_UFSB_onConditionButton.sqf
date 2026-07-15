#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onConditionButton

params ["_mode", "_shift"];

if (_mode < 0) then {
	_mode = 0;
};

if (_mode > 1) then {
	_mode = 1;
};

private _display = findDisplay IDD_MAP_OVERLAY;

private _conditionImage =
	_display displayCtrl IDC_MAP_UFSB_WPCONDITION_IMG;

private _conditionButton =
	_display displayCtrl IDC_MAP_UFSB_WPCONDITION_BTN;

private _timeoutPopup =
	_display displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP;

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
];

switch (A3C_TEMP_CONDITION select 0) do {
	case "NONE": {
		if (_mode == 0) then {
			A3C_TEMP_CONDITION = [
				"TIMEOUT",
				A3C_TIMEOUT_VAL
			];

			_conditionImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_condition_Timer.paa";

			_conditionButton ctrlSetToolTip
				"WP Condition: TIMEOUT (LMB to cycle through options)";

			(_display displayCtrl 7008) ctrlSetText "(";
			_timeoutPopup ctrlShow true;
		} else {
			A3C_TEMP_CONDITION = ["GOCODE", "D"];

			_conditionImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";

			_conditionButton ctrlSetToolTip
				"WP Condition: GoCode D (LMB to cycle through options)";

			_timeoutPopup ctrlShow false;
		};
	};

	case "TIMEOUT": {
		if (_mode == 0) then {
			A3C_TEMP_CONDITION = ["GOCODE", "A"];

			_conditionImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";

			_conditionButton ctrlSetToolTip
				"WP Condition: GoCode A (LMB to cycle through options)";
		} else {
			A3C_TEMP_CONDITION = ["NONE", "NONE"];

			_conditionImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";

			_conditionButton ctrlSetToolTip
				"WP Condition: NONE (LMB to cycle through options)";
		};

		_timeoutPopup ctrlShow false;
	};

	case "GOCODE": {
		private _goCode = A3C_TEMP_CONDITION select 1;

		A3C_TEMP_CONDITION = switch (_goCode) do {
			case "NONE": {
				if (_mode == 0) then {
					["GOCODE", "A"]
				} else {
					["GOCODE", "D"]
				}
			};

			case "A": {
				if (_mode == 0) then {
					["GOCODE", "B"]
				} else {
					["TIMEOUT", A3C_TIMEOUT_VAL]
				}
			};

			case "B": {
				if (_mode == 0) then {
					["GOCODE", "C"]
				} else {
					["GOCODE", "A"]
				}
			};

			case "C": {
				if (_mode == 0) then {
					["GOCODE", "D"]
				} else {
					["GOCODE", "B"]
				}
			};

			case "D": {
				if (_mode == 0) then {
					["NONE", "NONE"]
				} else {
					["GOCODE", "C"]
				}
			};
		};

		_timeoutPopup ctrlShow false;

		if ((A3C_TEMP_CONDITION select 0) == "GOCODE") then {
			private _goCodeIcon = format [
				"A3C_CORE\ui\pictures\icon_menu_gocode_%1.paa",
				A3C_TEMP_CONDITION select 1
			];

			_conditionImage ctrlSetText _goCodeIcon;
		} else {
			if (_mode == 0) then {
				_conditionImage ctrlSetText
					"A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";

				_conditionButton ctrlSetToolTip
					"WP Condition: NONE (LMB to cycle through options)";
			} else {
				A3C_TEMP_CONDITION = [
					"TIMEOUT",
					A3C_TIMEOUT_VAL
				];

				_conditionImage ctrlSetText
					"\a3\ui_f\data\IGUI\RscTitles\MPProgress\timer_ca.paa";

				_conditionButton ctrlSetToolTip
					"WP Condition: TIMEOUT (LMB to cycle through options)";

				_timeoutPopup ctrlShow true;
			};
		};
	};
};
#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onFormationButton

params ["_mode"];

if (_mode < 0) then {
	_mode = 0;
};

if (_mode > 1) then {
	_mode = 1;
};

private _display = findDisplay IDD_MAP_OVERLAY;

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
];

private _formationImage =
	_display displayCtrl IDC_MAP_UFSB_WPFORMATION_IMG;

switch (A3C_FORMMODE_TEMP) do {
	case 0: {};

	case 1: {
		if (_mode == 0) then {
			A3C_FORMMODE_TEMP = 2;

			_formationImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_formDir_Right.paa";
		} else {
			A3C_FORMMODE_TEMP = 5;

			_formationImage ctrlSetText
				"\a3\ui_f\data\Map\Markers\Military\circle_ca.paa";

			A3C_SPLIT_UNITS = [];
		};

		A3C_SPLIT_UNITS = [];
	};

	case 2: {
		if (_mode == 0) then {
			A3C_FORMMODE_TEMP = 3;

			_formationImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_formDir_Left.paa";
		} else {
			A3C_FORMMODE_TEMP = 1;

			_formationImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa";
		};

		A3C_SPLIT_UNITS = [];
	};

	case 3: {
		if (_mode == 0) then {
			A3C_FORMMODE_TEMP = 4;

			_formationImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_formDir_split.paa";

			A3C_SPLIT_UNITS = A3C_SELECTED_UNITS;
		} else {
			A3C_FORMMODE_TEMP = 2;

			_formationImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_formDir_Right.paa";

			A3C_SPLIT_UNITS = [];
		};
	};

	case 4: {
		if (_mode == 0) then {
			A3C_FORMMODE_TEMP = 5;

			_formationImage ctrlSetText
				"\a3\ui_f\data\Map\Markers\Military\circle_ca.paa";
		} else {
			A3C_FORMMODE_TEMP = 3;

			_formationImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_formDir_Left.paa";
		};

		A3C_SPLIT_UNITS = [];
	};

	case 5: {
		if (_mode == 0) then {
			A3C_FORMMODE_TEMP = 1;

			_formationImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa";

			A3C_SPLIT_UNITS = [];
		} else {
			A3C_FORMMODE_TEMP = 4;

			_formationImage ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_formDir_split.paa";

			A3C_SPLIT_UNITS = A3C_SELECTED_UNITS;
		};
	};
};
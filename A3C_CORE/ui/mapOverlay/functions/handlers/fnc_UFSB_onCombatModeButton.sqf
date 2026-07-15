#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onCombatModeButton

private _display = findDisplay IDD_MAP_OVERLAY;

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
];

private _combatModeImage =
	_display displayCtrl IDC_MAP_UFSB_COMBATMODE_IMG;

private _combatModeButton =
	_display displayCtrl IDC_MAP_UFSB_COMBATMODE_BTN;

switch (A3C_CMODE_TEMP) do {
	case 0: {
		A3C_CMODE_TEMP = 1;

		_combatModeImage ctrlSetTextColor
			[0.52, 0.78, 0.97, 0.6];

		_combatModeButton ctrlSetToolTip
			"WP Combat-Mode: Disengage";
	};

	case 1: {
		A3C_CMODE_TEMP = 0;

		_combatModeImage ctrlSetTextColor
			[1, 1, 1, 1];

		_combatModeButton ctrlSetToolTip
			"WP Combat-Mode: Default/Engage";
	};
};
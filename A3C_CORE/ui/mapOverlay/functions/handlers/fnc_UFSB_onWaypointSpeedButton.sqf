#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onWaypointSpeedButton

private _display = findDisplay IDD_MAP_OVERLAY;

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
];

private _speedImage =
	_display displayCtrl IDC_MAP_UFSB_WP_SPEED_IMG;

if (A3C_WP_SPEED_TEMP == -1) then {
	A3C_WP_SPEED_TEMP = 2;

	_speedImage ctrlSetText
		"A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
} else {
	A3C_WP_SPEED_TEMP = -1;

	_speedImage ctrlSetText
		"A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
};
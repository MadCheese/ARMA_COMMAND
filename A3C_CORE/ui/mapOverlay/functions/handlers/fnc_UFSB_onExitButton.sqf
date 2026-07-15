#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onExitButton

private _display = findDisplay IDD_MAP_OVERLAY;
_display closeDisplay 0;

A3C_SELECTED_UNITS = [];

{
	_x setVariable ["A3C_PLOT_TEMP", [], true];
} forEach (units group player);

openMap false;

[1] call A3C_Btn_fnc_Cancel;
// A3C_ui_mapOverlay_fnc_closeMapOverlay

params ["_displayId"];

(findDisplay _displayId) closeDisplay 0;
(findDisplay 12 displayCtrl 51) ctrlEnable true;

[1] call A3C_Btn_fnc_Cancel;

A3C_MAP_CommandMode = "INF";
A3C_SELECTED_UNITS = [];

{
	_x setVariable ["A3C_PLOT_TEMP", [], true];
} forEach (units group player);

[1] call A3C_ui_mapOverlay_fnc_resetMapClick;
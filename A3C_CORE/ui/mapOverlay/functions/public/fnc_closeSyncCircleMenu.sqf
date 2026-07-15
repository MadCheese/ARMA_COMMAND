// A3C_ui_mapOverlay_fnc_closeSyncCircleMenu

params ["_displayId", "_ctrlId"];

// Closes the small circle menu used to select sync or board actions
// while synchronizing waypoints.
private _display = findDisplay _displayId;

{
	{
		ctrlDelete (_display displayCtrl _x);
	} forEach _x;
} forEach A3C_UI_MAP_CircleMenu_CTRLS;

A3C_UI_MAP_isCircleMenu = false;
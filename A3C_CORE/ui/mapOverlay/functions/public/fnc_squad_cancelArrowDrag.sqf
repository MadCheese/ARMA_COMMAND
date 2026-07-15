// A3C_ui_mapOverlay_fnc_squad_cancelArrowDrag

// Cancels LookDir-arrow and AIC-waypoint-arrow dragging when the mouse
// is moved over map-overlay controls.
//
// This solution is still somewhat indirect. Pausing the active drag would
// likely be cleaner, but would require more complex drag-state handling.
A3C_BOOL_MAP_MU = true;

if (A3C_BOOL_MAP_MD) then {
	A3C_BOOL_MAP_MD = false;

	if (A3C_BOOL_DRAGLINE) then {
		[
			0,
			0,
			0,
			0,
			false,
			false,
			false
		] spawn A3C_UI_MAP_onOnMouseButtonUp_Overlay;
	};
};
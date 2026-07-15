// A3C_ui_mapOverlay_fnc_squad_deleteBposMarkers

// TODO: After moving building-position markers to drawn map UI,
// replace this cleanup with the corresponding visibility flag.
{
	deleteMarkerLocal _x;
} forEach A3C_BPMARKERS;

A3C_BPICONS = [];
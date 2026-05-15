// A3C_ai_squad_fnc_actionSuppressionStop

A3C_UI_RADIAL_Current_Remfire_Units = A3C_RD_UNITS select {
	_x in A3C_SUPPRESSION_UNITS_SQ
};

if (A3C_UI_RADIAL_Current_Remfire_Units isEqualTo []) exitWith {};

[A3C_UI_RADIAL_Current_Remfire_Units, "SUPPRESSION"] call A3C_POLY_ACTION_OFF;
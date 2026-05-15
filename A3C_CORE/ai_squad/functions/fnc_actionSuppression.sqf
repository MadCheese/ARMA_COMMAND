// A3C_ai_squad_fnc_actionSuppression

if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
	private _units = +(A3C_UI_RADIAL_Current_Remfire_Units);
	[_units,[A3C_UI_HUD_3D_TAG_ICON_POS,""],'SUPPRESSION',true] spawn A3C_POLY_ACTION_ON;
};

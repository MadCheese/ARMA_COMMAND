// A3C_ai_highCommand_fnc_actionSuppression


if (count A3C_RD_UNITS > 0 && {A3C_UI_HUD_3D_TAG_ICON_TYPE != ""}) then {
	{
		[_x,A3C_UI_HUD_3D_TAG_ICON_POS] call A3C_ai_highCommand_fnc_suppressionImmediate;
	} foreach A3C_UI_RADIAL_Current_Remfire_Units;
};
A3C_HC_GroupMenu_SuppressionRequested = false;
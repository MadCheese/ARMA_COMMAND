A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
A3C_UI_HUD_3D_TAG_reposition = false;
A3C_UI_HUD_3D_TAG_ICON_COL = [0.5, 0.5, 0.5, 1]; //-- Debug grey; probably not needed
A3C_UI_HUD_3D_TAG_ICON_POS = [0, 0, 0];

if (!isNull A3C_OBJECTPLACER) then {
	deleteVehicle A3C_OBJECTPLACER;
	A3C_OBJECTPLACER = objNull;
};

if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
	A3C_AI_Squad_Action_ID = "";
} else {
	A3C_AI_HighCommand_Action_ID = "";
};

A3C_UI_RADIAL_Current_Remfire_Units = [];
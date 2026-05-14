//-- This dispatcher is only for the RADIAL artillery action. 
//-- A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel is shared by RADIAL and mapOverlay

A3C_HC_FOCUS_ARTY = objNull;
A3C_HC_FOCUS_ARTY_AMMO = "";
A3C_HC_FOCUS_ARTY_POS = +(A3C_UI_HUD_3D_TAG_ICON_POS);

with uiNamespace do {
	A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
};


["ARTY"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;
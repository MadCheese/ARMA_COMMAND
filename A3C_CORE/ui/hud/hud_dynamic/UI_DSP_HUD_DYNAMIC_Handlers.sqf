//---------------------------------------  HANDLER-FUNCTIONS  ------------------------------------
//------------------------------------------------------------------------------------------------

//-- HUD DYNAMIC "KeyUp"
A3C_UI_HUD_DYNAMIC_onKeyUp = {
	params ["_display", "_key", "_shift", "_ctrl", "_alt"];
	if (_key == (A3C_RadialMenu_KEY_ID select 0)) then {
		A3C_DISABLE_RADIAL = false;
		A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
		(findDisplay 100100) closeDisplay 0;
		A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];
		{player groupSelectUnit [_x,false]} foreach units player; 
		showCommandingMenu "";
	};
};




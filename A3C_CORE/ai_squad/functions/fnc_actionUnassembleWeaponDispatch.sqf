// A3C_ai_squad_fnc_actionUnassembleWeaponDispatch 

/*
	NOTE: 
	The squad variant does not use the confusing shared methos. here we have to do the flicker directly or use it in lb fnc.
*/

A3C_DISABLE_RADIAL = true;
[] call A3C_ui_radialMenu_fnc_closeDisplay;

private _target = cursorTarget;
private _isStaticWeapon = _target isKindOf "STATICWEAPON";

if (
	_isStaticWeapon
	&& {
		crew _target isEqualTo []
		|| {gunner _target in A3C_UI_RADIAL_Current_Remfire_Units}
	}
) exitWith {
	//-- Cursortarget mode flicker
	A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configFile >> "CfgVehicles" >> typeOf _target >> "picture");
	A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
	private _tagPos = +position _target;
	[_tagPos, ""] spawn A3C_ui_mainDisplay_fnc_3D_TagFlicker;

	[A3C_UI_RADIAL_Current_Remfire_Units, _target] spawn A3C_ai_shared_fnc_actionStaticWeaponPack;
};




[] call A3C_ui_selectionPromptPanel_fnc_squadActionUnassembleWeaponStartPrompt;
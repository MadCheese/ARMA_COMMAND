// A3C_ai_squad_fnc_actionUnassembleWeaponDispatch 

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
	[A3C_UI_RADIAL_Current_Remfire_Units, _target] spawn A3C_ai_shared_fnc_actionStaticWeaponPack;
};

[] call A3C_ui_selectionPromptPanel_fnc_squadActionUnassembleWeaponStartPrompt;
// A3C_ai_highCommand_fnc_actionUnAssembleWeaponDispatch

/*

	NOTE:
	This dispatch gets called twice if selectionPromptPanel is needed. Likely needs some clarification. 
	Flow currently: If mode is 0, then _wpn will not be passed and end up objNull
	#ToDo: Might profit from some cleanup, since fnc is not exactly intuitive to read and understand.

*/ 

params ["_mode", ["_wpn", objNull]];

if !(count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) exitWith {};

private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
private _groupUnits = units _group;

if (_mode == 0) then {
	_wpn = objNull;
};

private _groupHasStaticWeapon = {
	(vehicle _x) isKindOf "staticweapon"
} count _groupUnits > 0;

[] spawn A3C_ui_shared_fnc_mapRadial_actionStandardResponse;

if (
	_mode == 0 &&
	{count A3C_HC_NearStatics > 0} &&
	{!_groupHasStaticWeapon}
) exitWith {
	[_group, A3C_HC_NearStatics] call A3C_ui_selectionPromptPanel_fnc_actionUnassembleWeaponPromptStart;
};

if (isNull _wpn) then {
	{
		if ((vehicle _x) isKindOf "staticweapon") exitWith {
			_wpn = vehicle _x;
		};
	} forEach _groupUnits;
};

if (isNull _wpn) exitWith {};


//-- Shared Flicker: Happens if _wpn is autoselected or targeted by selectionPromptPanel
A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configFile >> "CfgVehicles" >> typeOf _wpn >> "picture");
A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
private _tagPos = +position _wpn;
[_tagPos, ""] spawn A3C_ui_mainDisplay_fnc_3D_TagFlicker;

//-- Order autoselected weapon disassembly
[_mode, _group, _wpn] spawn A3C_ai_highCommand_fnc_actionUnassembleWeapon;
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

[] call A3C_ui_shared_fnc_mapRadial_actionStandardResponse;

if (
	_mode == 0 &&
	{count A3C_HC_NearStatics > 0} &&
	{!_groupHasStaticWeapon}
) exitWith {
	[_group, A3C_HC_NearStatics] call A3C_ui_selectionPromptPanel_fnc_actionUnassembleWeaponPromptStart;
};

[_mode, _group, _wpn] spawn A3C_ai_highCommand_fnc_actionUnassembleWeapon;
// A3C_ai_shared_fnc_reArm_autoEvaluated

// Exit if run on a machine that does not run A3C.
if !(isClass (configFile >> "CfgPatches" >> "A3C_OBJECTS")) exitWith {};


params [
	"_unit",
	["_crate", objNull]
];

if (isPlayer _unit) exitWith {};
if (vehicle _unit != _unit) exitWith {};
// Script may only affect foot soldiers.

private _primaryMagazines = getArray (
	configFile >> "CfgWeapons" >> primaryWeapon _unit >> "magazines"
);

private _secondaryMagazines = getArray (
	configFile >> "CfgWeapons" >> secondaryWeapon _unit >> "magazines"
);

private _weaponMagazines = _primaryMagazines + _secondaryMagazines;

// Determine rearm modes: ammo, swap rifle, take backpack, take launcher.
private _rearmModes = [_unit] call A3C_main_fnc_getReArmModes;
_rearmModes params ["_primaryMode", "_secondaryMode", "_backpackMode"];

// If no target is given, find possible sources to rearm from.
if (isNull _crate) then {
	private _sources = [
		_unit,
		_primaryMode,
		_secondaryMode,
		_backpackMode,
		_weaponMagazines
	] call A3C_main_fnc_getRearmSources;

	_sources = [
		_sources,
		[],
		{ ["LIGHT", _x] call A3C_main_fnc_getRearmSourceQuality },
		"DESCEND"
	] call BIS_fnc_sortBy;

	if !(_sources isEqualTo []) then {
		_crate = _sources select 0;
	};
};

// Spawn action if sources are close, otherwise send negative chat.
if (!isNull _crate) then {
	([_unit, _crate] + _rearmModes) spawn A3C_ai_shared_fnc_reArm_autoIssueOrder;
} else {
	_unit groupChat (
		[
			"I do not see any way to resupply",
			"Nothing here to benefit from",
			"No way to resupply here"
		] call BIS_fnc_selectRandom
	);
};
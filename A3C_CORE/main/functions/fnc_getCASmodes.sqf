// A3C_main_fnc_getCASmodes

params ["_planeClass"];

private _planeWeapons = _planeClass call BIS_fnc_weaponsEntityType;
private _weaponTypeGroups = [
	["machinegun"],
	["missilelauncher"],
	["machinegun","missilelauncher"],
	["bomblauncher"]
];

private _casModes = [];

{
	private _requiredWeaponTypes = _x;

	{
		private _weapon = _x;
		private _weaponType = toLower ((_weapon call BIS_fnc_itemType) select 1);

		if (_weaponType in _requiredWeaponTypes) then {
			_casModes pushBackUnique _requiredWeaponTypes;
		};
	} forEach _planeWeapons;
} forEach _weaponTypeGroups;

_casModes
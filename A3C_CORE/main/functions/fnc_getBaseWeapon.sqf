// A3C_main_fnc_getBaseWeapon

//-- Find the base weapon of another weapon.
//-- "Base weapon" means the weapon class without attached weapon items.

params ["_weapon"];

private _baseConfig = configFile >> "CfgWeapons";
private _weaponConfig = _baseConfig >> _weapon;

while {isClass (_weaponConfig >> "LinkedItems")} do {
	_weaponConfig = inheritsFrom _weaponConfig;
};

configName _weaponConfig
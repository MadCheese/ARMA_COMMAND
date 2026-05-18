// A3C_main_fnc_unitHasUGL

//-- Check if a unit has UGL capabilities.

params ["_unit"];

if (_unit != vehicle _unit) exitWith {
	false
};

private _primaryWeapon = primaryWeapon _unit;
private _weaponConfig = configFile >> "CfgWeapons" >> _primaryWeapon;
private _muzzles = getArray (_weaponConfig >> "muzzles");

if (count _muzzles < 2) exitWith {
	false
};

private _uglMuzzle = _muzzles select 1;
private _uglMagazines = getArray (_weaponConfig >> _uglMuzzle >> "magazines");
private _primaryWeaponMagazines = primaryWeaponMagazine _unit;

_primaryWeaponMagazines findIf {
	_x in _uglMagazines
} != -1
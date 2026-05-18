// A3C_main_fnc_unitHasAT

//-- Check if a unit has AT capabilities.

params ["_unit"];

if (_unit != vehicle _unit) exitWith {
	false
};

private _secondaryWeapon = secondaryWeapon _unit;

if (
	_secondaryWeapon == ""
	|| {!(_secondaryWeapon isKindOf ["Launcher", configFile >> "CfgWeapons"])}
) exitWith {
	false
};

private _weaponConfig = configFile >> "CfgWeapons" >> _secondaryWeapon;
private _weaponMagazines = getArray (_weaponConfig >> "magazines");
private _secondaryWeaponMagazines = secondaryWeaponMagazine _unit;

_secondaryWeaponMagazines findIf {
	_x in _weaponMagazines
} != -1
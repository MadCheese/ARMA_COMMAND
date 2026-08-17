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


//-- RHS-style disposable launchers can appear unloaded until readied.
//-- Fired disposable launchers are replaced with a "_used" weapon class.
if (
    isClass (_weaponConfig >> "EventHandlers" >> "RHS_DisposableWeapon")
    && {!(_secondaryWeapon regexMatch ".*_used$")}
) exitWith {
    true
};


private _weaponMagazines = getArray (_weaponConfig >> "magazines");
private _secondaryWeaponMagazines = secondaryWeaponMagazine _unit;


_secondaryWeaponMagazines findIf {
    _x in _weaponMagazines
} != -1
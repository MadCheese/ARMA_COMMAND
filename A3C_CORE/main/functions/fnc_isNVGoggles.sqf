// A3C_main_fnc_isNVGoggles

params ["_weaponClass"];

if !(_weaponClass isEqualType "") exitWith {
	false
};

_weaponClass isKindOf ["NVGoggles", configFile >> "CfgWeapons"]
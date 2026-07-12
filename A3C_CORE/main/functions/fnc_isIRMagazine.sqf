// A3C_main_fnc_isIRMagazine

params ["_magazine"];

if !(_magazine isEqualType "") exitWith {
	false
};

private _ammo = getText (
	configFile >> "CfgMagazines" >> _magazine >> "ammo"
);

if (_ammo isEqualTo "") exitWith {
	false
};

getText (
	configFile >> "CfgAmmo" >> _ammo >> "simulation"
) == "shotNVGMarker"
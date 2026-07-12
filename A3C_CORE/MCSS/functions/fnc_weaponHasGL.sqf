// MCSS_fnc_weaponHasGL
// Returns true if a weapon has at least one muzzle that can fire grenade-launcher-style ammunition.

params ["_weapon"];

private _weaponConfig = configFile >> "CfgWeapons" >> _weapon;

if !(isClass _weaponConfig) exitWith { false };
if (_weapon in ["Throw", "Put"]) exitWith { false };

private _muzzles = getArray (_weaponConfig >> "muzzles");
if (_muzzles isEqualTo []) then {
	_muzzles = ["this"];
};

private _glAmmoSimulations = [
	"shotgrenade",
	"shotsmoke",
	"shotilluminating"
];

(_muzzles findIf {
	private _compatibleMagazines = compatibleMagazines [_weapon, _x];

	(_compatibleMagazines findIf {
		private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
		if (_ammo isEqualTo "") exitWith { false };

		private _simulation = toLowerANSI getText (configFile >> "CfgAmmo" >> _ammo >> "simulation");
		_simulation in _glAmmoSimulations
	}) >= 0
}) >= 0
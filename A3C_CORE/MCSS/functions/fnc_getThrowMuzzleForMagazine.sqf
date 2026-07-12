// MCSS_fnc_getThrowMuzzleForMagazine
// Returns the Throw weapon muzzle that accepts the given magazine.
// Returns "" if no matching muzzle is found.

params ["_magazine"];

if !(_magazine isEqualType "") exitWith {
	""
};

private _muzzleIndex = A3C_THROW_MUZZLES findIf {
	_magazine in getArray (
		configFile >> "CfgWeapons" >> "Throw" >> _x >> "magazines"
	)
};

if (_muzzleIndex == -1) exitWith {
	""
};

A3C_THROW_MUZZLES select _muzzleIndex
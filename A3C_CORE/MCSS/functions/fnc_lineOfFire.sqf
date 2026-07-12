// MCSS_fnc_lineOfFire
// Checks whether a unit is facing a target within a fixed angle sector.
// NOTE: This does not check actual weapon muzzle direction or obstruction.

params ["_shooter", "_target"];

if (weaponLowered _shooter) exitWith {
	false
};

private _isInFireArc = [
	position _shooter,
	getDir _shooter,
	45,
	position _target
] call MCSS_fnc_isInAngleSector;

_isInFireArc
// A3C_ai_shared_fnc_restoreWeaponFromBinoculars

params [
	["_unit", objNull, [objNull]]
];

if (
	isNull _unit
	|| {!local _unit}
	|| {isPlayer _unit}
	|| {!alive _unit}
	|| {!isNull objectParent _unit}
) exitWith {};

private _gp = group _unit;

if (isNull _gp || {_gp getVariable ["A3C_HC_BLACKLIST", false]}) exitWith {};

private _leader = leader _gp;

if (isNull _leader) exitWith {};

//-- Recheck group conditions at execution time on the unit's owner.
if (
	!isPlayer _leader
	&& {
		private _currentWpIndex = currentWaypoint _gp;

		_currentWpIndex <= 0
		|| {_currentWpIndex >= count waypoints _gp}
		|| {waypointType [_gp, _currentWpIndex] == "HOLD"}
	}
) exitWith {};

private _binocular = binocular _unit;

if (_binocular == "" || {currentWeapon _unit != _binocular}) exitWith {};

private _weapon = primaryWeapon _unit;

if (_weapon == "") then {
	_weapon = handgunWeapon _unit;
};

if (_weapon == "") then {
	_weapon = secondaryWeapon _unit;
};

if (_weapon == "") exitWith {};

//-- selectWeapon takes a muzzle; "this" denotes the weapon class itself.
private _muzzle = (getArray (
	configFile
	>> "CfgWeapons"
	>> _weapon
	>> "muzzles"
)) param [0, "this"];

if (_muzzle == "this") then {
	_muzzle = _weapon;
};

_unit selectWeapon _muzzle;

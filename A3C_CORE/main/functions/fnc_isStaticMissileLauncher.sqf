// A3C_main_fnc_isStaticMissileLauncher

//-- determine if static weapon is ROCKET LAUNCHER (Used by Remote Fire Fncs)

params ["_input"];

private _type = if (_input isEqualType objNull) then {
	typeOf _input
} else {
	_input
};

if !(_type isKindOf "STATICWEAPON") exitWith {false};

private _cfgVehicles = configFile >> "CfgVehicles";
private _cfgMagazines = configFile >> "CfgMagazines";
private _cfgAmmo = configFile >> "CfgAmmo";

private _magazineArray = getArray (_cfgVehicles >> _type >> "Turrets" >> "MainTurret" >> "magazines");

private _isMissileLauncher = false;

{
	private _magazine = _x;
	private _ammo = getText (_cfgMagazines >> _magazine >> "ammo");
	private _effectsMissile = toLower (getText (_cfgAmmo >> _ammo >> "effectsMissile"));

	if (_effectsMissile find "missile" > -1) exitWith {
		_isMissileLauncher = true;
	};
} forEach _magazineArray;

_isMissileLauncher
// A3C_ai_shared_fnc_fireCounterMeasures 

/*
    Checks whether a vehicle has a usable countermeasure weapon and optionally fires it.

    Params:
        _vehicle - vehicle to inspect
        _mode    - 0: only check, 1: fire if possible

    Returns:
        Boolean - true if a countermeasure weapon was found
*/

params [
    ["_vehicle", objNull, [objNull]],
    ["_mode", 0, [0]]
];

if (isNull _vehicle) exitWith { false };

private _counterWeapon = "";
private _found = false;

private _cfgWeapons = configFile >> "CfgWeapons";
private _cfgMagazines = configFile >> "CfgMagazines";
private _cfgAmmo = configFile >> "CfgAmmo";

{
    private _turret = _x;
    private _turretMags = _vehicle magazinesTurret _turret;

    if !(_turretMags isEqualTo []) then {
        private _turretWeapons = _vehicle weaponsTurret _turret;

        {
            private _weapon = _x;
            private _weaponMags = getArray (_cfgWeapons >> _weapon >> "magazines");
            private _usableMags = _weaponMags select { _x in _turretMags };

            if !(_usableMags isEqualTo []) then {
                private _magIndex = _usableMags findIf {
                    private _mag = _x;
                    private _ammo = getText (_cfgMagazines >> _mag >> "ammo");
                    private _aiAmmoUsageFlags = getText (_cfgAmmo >> _ammo >> "aiAmmoUsageFlags");
                    private _flagTokens = _aiAmmoUsageFlags splitString "+ ";

                    ("4" in _flagTokens) || { "8" in _flagTokens }
                };

                if !(_magIndex isEqualTo -1) exitWith {
                    _counterWeapon = _weapon;
                    _found = true;
                };
            };

            if (_found) exitWith {};
        } forEach _turretWeapons;
    };

    if (_found) exitWith {};
} forEach (allTurrets _vehicle);

if (_mode isEqualTo 1 && { _found } && { !(_counterWeapon isEqualTo "") }) then {
    [_vehicle, _counterWeapon] call BIS_fnc_fire;
};

_found
// A3C_main_fnc_getTankAmmoHE


// Returns ammo class of the most explosive MainTurret magazine

params [
    ["_tank", objNull, [objNull]]
];

if (isNull _tank) exitWith { "" };

private _cfgVehicles = configFile >> "CfgVehicles";
private _cfgMagazines = configFile >> "CfgMagazines";
private _cfgAmmo = configFile >> "CfgAmmo";

private _mags = getArray (
    _cfgVehicles >> typeOf _tank >> "Turrets" >> "MainTurret" >> "magazines"
);

private _chosenAmmo = "";
private _highestExplosive = -1;

{
    private _ammo = getText (_cfgMagazines >> _x >> "ammo");
    private _explosive = getNumber (_cfgAmmo >> _ammo >> "explosive");

    if (_explosive > _highestExplosive) then {
        _highestExplosive = _explosive;
        _chosenAmmo = _ammo;
    };
} forEach _mags;

_chosenAmmo
// Cached CONFIG evidence only. The caller must check live stock and operators.
// Cache belongs to one Overwatch worker; no object/global/public state here.
params ["_weapon", "_muzzle", "_magazine", "_cache"];
private _key = format ["ammo:%1:%2:%3", toLower _weapon, toLower _muzzle, toLower _magazine];
if (_key in _cache) exitWith {_cache get _key};
private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
private _cfg = if (_muzzle == "this" || {_muzzle == _weapon}) then {_weaponCfg} else {_weaponCfg >> _muzzle};
private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
private _flagCfg = _ammoCfg >> "aiAmmoUsageFlags";
private _flags = getNumber _flagCfg;
private _flagsResolved = isNumber _flagCfg;
// Configs also store sums as text ("64 + 128 + 256"). Parse only decimal sums;
// never compile arbitrary config text or search for a decimal substring.
if (isText _flagCfg) then {
    private _text = getText _flagCfg;
    private _terms = _text splitString ("+ " + toString [9, 10, 13]);
    _flagsResolved = _terms isNotEqualTo []
        && {(toArray _text) findIf {!(_x in [9, 10, 13, 32, 43]) && {_x < 48 || {_x > 57}}} < 0};
    _flags = 0;
    if (_flagsResolved) then {{_flags = _flags + parseNumber _x;} forEach _terms;};
};
// Numeric bit test: handles combined masks, e.g. 448 = 64 + 128 + 256.
private _offensiveAir = _flagsResolved && {(floor (_flags / 256)) % 2 == 1};
private _otherOffensive = [64, 128, 512] findIf {(floor (_flags / _x)) % 2 == 1} >= 0;
private _airOnly = getNumber (_ammoCfg >> "airLock") == 2;
private _simulation = toLower getText (_ammoCfg >> "simulation");
private _damaging = getNumber (_ammoCfg >> "hit") > 0
    || {getNumber (_ammoCfg >> "indirectHit") > 0 && {getNumber (_ammoCfg >> "indirectHitRange") > 0}};
private _range = getNumber (_cfg >> "maxRange");
private _minRange = getNumber (_cfg >> "minRange");
private _sustainedReload = -1;
private _modes = getArray (_cfg >> "modes");
if (_modes isEqualTo []) then {_modes = ["this"];};
{
    private _mode = if (_x == "this") then {_cfg} else {_cfg >> _x};
    _range = _range max getNumber (_mode >> "maxRange");
    _minRange = _minRange min getNumber (_mode >> "minRange");
    // Physical per-shot delay in a real automatic mode; burst/multiplier and
    // AI burst preferences do not establish sustained rounds per second.
    private _reload = getNumber (_mode >> "reloadTime");
    private _automatic = isClass _mode && {getNumber (_mode >> "autoFire") > 0};
    if (_automatic && {_reload > 0} && {_sustainedReload < 0 || {_reload < _sustainedReload}}) then {
        _sustainedReload = _reload;
    };
} forEach _modes;
private _hit = getNumber (_ammoCfg >> "hit");
private _aa = 0;
if (_damaging) then {
    // Generic MGs, AT canLock alone and countermeasures are not dedicated AA.
    if (_simulation == "shotmissile" && {_offensiveAir || {_airOnly}}) then {_aa = 1;};
    // Initial config calibration, not universal physics: hit >= 30 and an
    // automatic per-shot delay <= 0.06 s indicate dedicated AA; <= 0.2 s is
    // secondary/uncertain autocannon evidence only. Unknown rates fail closed.
    if (_simulation in ["shotbullet", "shotshell"] && {_offensiveAir}
        && {_hit >= 30} && {_sustainedReload > 0} && {_sustainedReload <= 0.2}) then {
        _aa = 2;
        if (_sustainedReload <= 0.06) then {_aa = 1;};
    };
};
private _evidence = format ["%1/%2 ammo=%3 sim=%4 flags=%5 resolved=%6 airOnly=%7 AA-grade=%8 range=%9..%10 hit=%11 sustainedReload=%12",
    _weapon, _magazine, _ammo, _simulation, _flags, _flagsResolved, _airOnly, _aa, _minRange, _range, _hit, _sustainedReload];
private _result = createHashMapFromArray [
    ["aa", _aa], ["airAmmo", _offensiveAir || {_airOnly}], ["damaging", _damaging],
    ["range", _range], ["minRange", _minRange], ["evidence", _evidence], ["simulation", _simulation],
    ["hit", _hit], ["sustainedReload", _sustainedReload]
];
_cache set [_key, _result];
_result

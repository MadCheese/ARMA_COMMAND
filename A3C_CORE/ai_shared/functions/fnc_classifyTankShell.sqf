// A3C_ai_shared_fnc_classifyTankShell
// Read-only result: [usable shell, AP/HE/AP_HE/UNKNOWN, reason, ammunition class].
params [["_magazine", "", [""]], ["_cannonCore", false, [true]]];

private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
private _cfg = configFile >> "CfgAmmo" >> _ammo;
private _simulation = toLower getText (_cfg >> "simulation");
private _hit = getNumber (_cfg >> "hit");
private _indirectHit = getNumber (_cfg >> "indirectHit");
if (!isClass _cfg || {!(_simulation == "shotshell" || {_cannonCore && {_simulation == "shotbullet"}})}
    || {_hit <= 0 && {_indirectHit <= 0}}) exitWith {[false, "UNKNOWN", "not a damaging cannon shell", _ammo]};

private _warhead = toUpper getText (_cfg >> "warheadName");
private _name = toUpper (_ammo + "_" + _magazine);
private _tokens = _name splitString "_- ";
private _explosive = getNumber (_cfg >> "explosive");
private _blast = _indirectHit > 0 && {getNumber (_cfg >> "indirectHitRange") > 0};
if (["SMOKE", "PRACTICE", "TRAINING"] findIf {_name find _x >= 0} >= 0)
    exitWith {[false, "UNKNOWN", "smoke/practice shell", _ammo]};
// Canister remains usable when already loaded, without guessing an AP/HE role.
if (_name find "CANISTER" >= 0)
    exitWith {[true, "UNKNOWN", "special-purpose shell; keep loaded choice", _ammo]};

// Vanilla HEAT-MP advertises an HE warhead and an anti-armor name. Explicit
// multipurpose HEAT with blast damage is suitable for either target category.
if (_explosive > 0 && {_blast}
    && {_name find "HEAT_MP" >= 0 || {"MPAT" in _tokens}}
    && {_warhead in ["HE", "HEAT", "TANDEMHEAT", "", "DEFAULT"]})
    exitWith {[true, "AP_HE", "explicit multipurpose HEAT shell with blast damage", _ammo]};

// Warhead metadata is authoritative where recognized. Names supplement mods
// whose shell inherits a generic warhead (HEAT must not be inferred as plain HE).
if (_warhead in ["AP", "APFSDS", "APDS", "APHE", "HEAT", "TANDEMHEAT"])
    exitWith {[true, "AP", "anti-armor warheadName", _ammo]};
if (["APFSDS", "APDS", "SABOT", "HEAT"] findIf {_name find _x >= 0} >= 0
    || {"AP" in _tokens} || {"APHE" in _tokens})
    exitWith {[true, "AP", "anti-armor ammo/magazine naming", _ammo]};
if (_warhead in ["HE", "HEFRAG", "HESH", "HEP"])
    exitWith {[true, "HE", "high-explosive warheadName", _ammo]};

// Unknown custom warhead semantics are not guessed from damage values.
if !(_warhead in ["", "DEFAULT"]) exitWith {[true, "UNKNOWN", "unrecognized warheadName", _ammo]};
if (_explosive > 0 && {(["HE", "HEFRAG", "HEF", "HESH", "HEP"] findIf {_x in _tokens}) >= 0})
    exitWith {[true, "HE", "explosive HE ammo/magazine naming", _ammo]};
if (_explosive > 0 && {_blast})
    exitWith {[true, "HE", "explosive shell with blast damage", _ammo]};
if (_explosive == 0 && {_hit > 0} && {getNumber (_cfg >> "caliber") >= 5})
    exitWith {[true, "AP", "non-explosive penetrating shell", _ammo]};
[true, "UNKNOWN", "insufficient shell classification data", _ammo]

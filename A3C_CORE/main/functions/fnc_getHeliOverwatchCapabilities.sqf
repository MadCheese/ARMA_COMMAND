// A3C_main_fnc_getHeliOverwatchCapabilities
/*
    Read-only structural classification; NOT connected to waypoint eligibility.
    Usage: [_helicopter] call A3C_main_fnc_getHeliOverwatchCapabilities

    Returns a HashMap, including on invalid input:
      vehicleClass, eligible, primaryGunnerTurret ([] if unresolved),
      hasGuidedMissiles, hasTraversableGun, guidedWeapons, guidedMagazines,
      gunWeapons, turretLimits ([minTurn,maxTurn,minElev,maxElev,overridden]),
      traverseDegrees, elevationDegrees, stations, candidates, reasons.
    guidedMagazines contains evidence maps: weapon, muzzle, magazine, ammo,
      source (turret/pylon), guidance (native seeker/manual/ACE).
    stations describes every turret; candidates describes primary weapons and
      their assessed ammunition. No round count, crew or AI check gates eligibility.
    Requires the mission's existing CBA dependency to resolve nested turret configs.
*/
params [["_vehicle", objNull, [objNull]]];

private _reasons = [];
private _result = createHashMapFromArray [
    ["vehicleClass", typeOf _vehicle], ["eligible", false],
    ["primaryGunnerTurret", []], ["hasGuidedMissiles", false],
    ["hasTraversableGun", false], ["guidedWeapons", []],
    ["guidedMagazines", []], ["gunWeapons", []], ["turretLimits", []],
    ["traverseDegrees", 0], ["elevationDegrees", 0],
    ["stations", []], ["candidates", []], ["reasons", _reasons]
];
if (isNull _vehicle || {!(_vehicle isKindOf "Helicopter")}) exitWith {
    _reasons pushBack "Rejected: input must be a helicopter object.";
    _result
};
if (isNil "CBA_fnc_getTurret") exitWith {
    _reasons pushBack "Rejected: CBA turret-config resolver is unavailable.";
    _result
};

private _primary = [];
private _unresolved = false;
{
    private _cfg = [_vehicle, _x] call CBA_fnc_getTurret;
    if (!isClass _cfg) then {
        _unresolved = true;
        _reasons pushBack format ["Cannot resolve turret config for %1.", _x];
    } else {
        (_result get "stations") pushBack (createHashMapFromArray [
            ["path", +_x], ["configClass", configName _cfg],
            ["primaryGunner", getNumber (_cfg >> "primaryGunner")],
            ["isPersonTurret", getNumber (_cfg >> "isPersonTurret")],
            ["proxyType", getText (_cfg >> "proxyType")],
            ["isCopilot", getNumber (_cfg >> "isCopilot")],
            ["weapons", _vehicle weaponsTurret _x]
        ]);
        if (getNumber (_cfg >> "primaryGunner") == 1) then {
            _primary pushBack [+_x, _cfg];
        };
    };
} forEach allTurrets [_vehicle, true];
if (_unresolved || {count _primary != 1}) exitWith {
    _reasons pushBack format ["Rejected: need one unambiguous primaryGunner station; found %1.", count _primary];
    _result
};

(_primary select 0) params ["_path", "_turretCfg"];
_result set ["primaryGunnerTurret", _path];
private _proxy = toLower getText (_turretCfg >> "proxyType");
if (getNumber (_turretCfg >> "isPersonTurret") != 0 || {_proxy in ["cpcargo", "cppassenger", "cpdriver"]}) exitWith {
    _reasons pushBack "Rejected: primary station is a person/passenger/driver turret.";
    _result
};

private _limits = _vehicle getTurretLimits _path;
_result set ["turretLimits", _limits];
private _traverse = 0;
private _elevation = 0;
if (count _limits >= 4) then {
    _traverse = ((_limits select 1) - (_limits select 0)) max 0;
    _elevation = ((_limits select 3) - (_limits select 2)) max 0;
} else {
    _reasons pushBack "Turret movement limits unavailable; gun capability rejected.";
};
_result set ["traverseDegrees", _traverse];
_result set ["elevationDegrees", _elevation];
private _movable = _traverse >= 60 && {_elevation >= 15}
    && {getText (_turretCfg >> "body") != ""}
    && {getText (_turretCfg >> "gun") != ""};
if (!_movable) then {
    _reasons pushBack format ["Gun movement rejected: %1 deg traverse / %2 deg elevation; need 60/15 and body/gun animations.", _traverse, _elevation];
};

// Preserve magazine identity even when empty. Compatibility never adds armament.
private _magazines = [];
{
    if ((_x select 1) isEqualTo _path) then {
        _magazines pushBackUnique [_x select 0, "turret"];
    };
} forEach magazinesAllTurrets [_vehicle, true];
private _pylons = getAllPylonsInfo _vehicle;
{
    if ((_x select 2) isEqualTo _path && {(_x select 3) != ""}) then {
        _magazines pushBackUnique [_x select 3, "pylon"];
    };
} forEach _pylons;

// Bounded config evidence, not a damage simulation. Return:
// [damaging, resolved, terminal projectiles, reasons]. Ignore carrier damage
// whenever it declares payloads; unknown branches reject that ammunition.
private _checkGunAmmo = {
    params ["_ammo", ["_depth", 0], ["_parents", []], ["_budget", [32]]];
    private _cfg = configFile >> "CfgAmmo" >> _ammo;
    if ((_budget select 0) <= 0 || {_depth > 2} || {toLower _ammo in _parents} || {!isClass _cfg}) exitWith {
        [false, false, [], [format ["%1: unresolved/cyclic payload or damage-inspection bound reached.", _ammo]]]
    };
    _budget set [0, (_budget select 0) - 1];
    private _entry = _cfg >> "submunitionAmmo";
    private _payloads = [];
    private _malformed = false;
    if (isText _entry) then {
        private _payload = getText _entry;
        if (_payload != "") then {_payloads = [_payload];};
    } else {
        if (isArray _entry) then {
            private _pairs = getArray _entry;
            _malformed = _pairs isEqualTo [] || {(count _pairs) % 2 != 0} || {count _pairs > 64};
            if (!_malformed) then {
                for "_i" from 0 to (count _pairs - 2) step 2 do {
                    private _payload = _pairs select _i;
                    private _probability = _pairs select (_i + 1);
                    if (!(_payload isEqualType "") || {!(_probability isEqualType 0)}) then {
                        _malformed = true;
                    } else {
                        if (_payload == "" || {_probability < 0} || {_probability > 1}) then {
                            _malformed = true;
                        } else {
                            if (_probability > 0) then {_payloads pushBackUnique _payload;};
                        };
                    };
                };
            };
            if (_payloads isEqualTo []) then {_malformed = true;};
        } else {
            _malformed = !isNull _entry;
        };
    };
    if (_malformed) exitWith {
        [false, false, [], [format ["%1: malformed/empty submunitionAmmo; carrier damage not counted.", _ammo]]]
    };
    if (_payloads isNotEqualTo []) exitWith {
        private _damaging = false;
        private _resolved = true;
        private _projectiles = [];
        private _notes = [];
        {
            private _check = [_x, _depth + 1, _parents + [toLower _ammo], _budget] call _checkGunAmmo;
            _damaging = _damaging || {_check select 0};
            _resolved = _resolved && {_check select 1};
            _projectiles append (_check select 2);
            _notes append (_check select 3);
        } forEach _payloads;
        _notes pushBack format ["%1: checked submunition payloads; carrier hit ignored.", _ammo];
        [_damaging && {_resolved}, _resolved, _projectiles, _notes]
    };
    private _simulation = toLower getText (_cfg >> "simulation");
    if !(_simulation in ["shotbullet", "shotshell", "shotrocket", "shotmissile", "shotgrenade"]) exitWith {
        [false, false, [], [format ["%1: simulation %2 has no recognised damaging projectile/payload evidence.", _ammo, _simulation]]]
    };
    private _hit = getNumber (_cfg >> "hit");
    private _indirect = getNumber (_cfg >> "indirectHit");
    private _radius = getNumber (_cfg >> "indirectHitRange");
    private _damaging = _hit > 0 || {_indirect > 0 && {_radius > 0}};
    [_damaging, true, [[_ammo, _simulation, _hit, _indirect, _radius]],
        [format ["%1: projectile hit=%2, indirectHit=%3, radius=%4; damaging=%5.", _ammo, _hit, _indirect, _radius, _damaging]]]
};

private _weapons = _vehicle weaponsTurret _path;
private _weaponKeys = _weapons apply {toLower _x};
{
    private _weapon = _x;
    private _weaponKey = toLower _weapon;
    private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
    private _gunCore = switch (true) do {
        case (_weapon isKindOf ["MGunCore", configFile >> "CfgWeapons"]): {"MGunCore"};
        case (_weapon isKindOf ["CannonCore", configFile >> "CfgWeapons"]): {"CannonCore"};
        default {""};
    };
    // A gun pod remains fixed even when assigned to a movable optics turret.
    private _pylonGun = _pylons findIf {
        (_x select 2) isEqualTo _path && {(_x select 3) != ""} && {
            toLower getText (configFile >> "CfgMagazines" >> (_x select 3) >> "pylonWeapon") == _weaponKey
        }
    } >= 0;
    private _gunCandidate = _gunCore != "" && {_movable} && {!_pylonGun};
    private _gunAmmo = false;
    if (_gunCore != "" && {_pylonGun}) then {
        _reasons pushBack format ["%1: pylon gun pod is not evidence of a traversable turret gun.", _weapon];
    };
    private _ammoEvidence = [];
    private _candidate = createHashMapFromArray [
        ["weapon", _weapon], ["parentClass", configName inheritsFrom _weaponCfg],
        ["gunCore", _gunCore], ["gunQualifies", false], ["gunAmmoQualifies", false],
        ["pylonGun", _pylonGun], ["ammunition", _ammoEvidence]
    ];
    (_result get "candidates") pushBack _candidate;

    private _muzzles = getArray (_weaponCfg >> "muzzles");
    if (_muzzles isEqualTo []) then {_muzzles = ["this"];};
    {
        private _muzzle = _x;
        private _muzzleCfg = if (_muzzle == "this") then {_weaponCfg} else {_weaponCfg >> _muzzle};
        private _compatible = compatibleMagazines [_weapon, _muzzle];
        {
            _x params ["_magazine", "_source"];
            private _magCfg = configFile >> "CfgMagazines" >> _magazine;
            // pylonWeapon is direct evidence for mounted pylon magazine ownership.
            private _pylonMatch = _source == "pylon"
                && {toLower getText (_magCfg >> "pylonWeapon") == _weaponKey}
                && {_muzzle == "this"};
            if (_magazine in _compatible || {_pylonMatch}) then {
                private _ammo = getText (_magCfg >> "ammo");
                private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
                private _simulation = toLower getText (_ammoCfg >> "simulation");
                private _sensorManager = _ammoCfg >> "Components" >> "SensorsManagerComponent";
                private _sensors = _sensorManager >> "Components";
                private _sensorTypes = [];
                {
                    private _type = getText (_x >> "componentType");
                    if (_type in ["IRSensorComponent", "VisualSensorComponent", "LaserSensorComponent", "NVSensorComponent", "ActiveRadarSensorComponent", "PassiveRadarSensorComponent", "ManSensorComponent"]) then {
                        _sensorTypes pushBackUnique _type;
                    };
                } forEach configProperties [_sensors, "isClass _x", true];
                // A modern SensorsManager replaces legacy lock flags, even if empty.
                private _seeker = if (isClass _sensorManager) then {
                    _sensorTypes isNotEqualTo []
                } else {
                    ["irLock", "laserLock", "nvLock"] findIf {getNumber (_ammoCfg >> _x) > 0} >= 0
                };
                private _manual = getNumber (_ammoCfg >> "manualControl") > 0
                    && {getNumber (_ammoCfg >> "maxControlRange") > 0};
                private _lock = getNumber (_muzzleCfg >> "canLock");
                private _nativeLock = _lock > 0 && {_seeker}
                    && {getNumber (_ammoCfg >> "missileLockCone") > 0}
                    && {getNumber (_ammoCfg >> "missileLockMaxDistance") > 0};
                private _native = _simulation == "shotmissile"
                    && {getNumber (_ammoCfg >> "maneuvrability") > 0}
                    && {_manual || {_nativeLock}};
                private _aceCfg = _ammoCfg >> "ace_missileguidance";
                private _ace = isClass (configFile >> "CfgPatches" >> "ace_missileguidance")
                    && {getNumber (_aceCfg >> "enabled") == 1}
                    && {getText (_aceCfg >> "defaultSeekerType") != ""}
                    && {_simulation in ["shotmissile", "shotrocket"]};
                private _guidance = [];
                if (_native && {_manual}) then {_guidance pushBack "native manual";};
                if (_native && {_nativeLock}) then {_guidance pushBack "native seeker";};
                if (_ace) then {_guidance pushBack "ACE (configured; firing-time availability not checked)";};
                private _lockCfg = _muzzleCfg >> "weaponLockSystem";
                private _evidence = createHashMapFromArray [
                    ["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine],
                    ["ammo", _ammo], ["source", _source], ["simulation", _simulation],
                    ["canLock", _lock], ["sensorTypes", _sensorTypes],
                    ["maneuvrability", getNumber (_ammoCfg >> "maneuvrability")],
                    ["manualControl", getNumber (_ammoCfg >> "manualControl")],
                    ["maxControlRange", getNumber (_ammoCfg >> "maxControlRange")],
                    ["missileLockCone", getNumber (_ammoCfg >> "missileLockCone")],
                    ["missileLockMaxDistance", getNumber (_ammoCfg >> "missileLockMaxDistance")],
                    ["weaponLockSystem", if (isNumber _lockCfg) then {getNumber _lockCfg} else {getText _lockCfg}],
                    ["guidance", _guidance], ["qualifies", _native || {_ace}]
                ];
                if (_gunCore != "") then {
                    private _damage = [_ammo] call _checkGunAmmo;
                    _evidence set ["gunAmmoQualifies", _damage select 0];
                    _evidence set ["gunDamageResolved", _damage select 1];
                    _evidence set ["gunDamageProjectiles", _damage select 2];
                    _evidence set ["gunDamageReasons", _damage select 3];
                    _gunAmmo = _gunAmmo || {_damage select 0};
                    if !(_damage select 0) then {
                        _reasons pushBack format ["%1 / %2: no qualifying damaging gun ammunition: %3", _weapon, _magazine, (_damage select 3) joinString " "];
                    };
                };
                _ammoEvidence pushBack _evidence;
                if (_native || {_ace}) then {
                    (_result get "guidedWeapons") pushBackUnique _weapon;
                    (_result get "guidedMagazines") pushBack _evidence;
                };
            };
        } forEach _magazines;
    } forEach _muzzles;
    private _gun = _gunCandidate && {_gunAmmo};
    _candidate set ["gunAmmoQualifies", _gunAmmo];
    _candidate set ["gunQualifies", _gun];
    if (_gun) then {(_result get "gunWeapons") pushBackUnique _weapon;};
    if (_ammoEvidence isEqualTo []) then {
        _reasons pushBack format ["%1: no identifiable installed compatible magazine (empty magazines also count); guidance not inferred from compatibility alone.", _weapon];
    };
} forEach _weapons;

// Report stale/mismatched pylon ownership instead of inventing an installed weapon.
{
    if ((_x select 2) isEqualTo _path && {(_x select 3) != ""}) then {
        private _weapon = getText (configFile >> "CfgMagazines" >> (_x select 3) >> "pylonWeapon");
        if (_weapon != "" && {!(toLower _weapon in _weaponKeys)}) then {
            _reasons pushBack format ["Pylon %1: %2 absent from primary weaponsTurret; not counted.", _x select 0, _weapon];
        };
    };
} forEach _pylons;
private _guided = (_result get "guidedWeapons") isNotEqualTo [];
private _gun = (_result get "gunWeapons") isNotEqualTo [];
_result set ["hasGuidedMissiles", _guided];
_result set ["hasTraversableGun", _gun];
_result set ["eligible", _guided || {_gun}];
if (_guided) then {_reasons pushBack "Accepted capability: installed primary-gunner missile/rocket with configured guidance.";};
if (_gun) then {_reasons pushBack "Accepted capability: installed primary-gunner MGunCore/CannonCore weapon with sufficient turret movement and damaging ammunition.";};
if (!_guided) then {_reasons pushBack "No qualifying guided ammunition identified; warning bitmasks and launcher ancestry alone do not qualify.";};
if (!_gun) then {_reasons pushBack "No qualifying traversable primary-gunner MGunCore/CannonCore weapon.";};
if (!_guided && {!_gun}) then {_reasons pushBack "Rejected: neither primary-gunner capability is present.";};
_result

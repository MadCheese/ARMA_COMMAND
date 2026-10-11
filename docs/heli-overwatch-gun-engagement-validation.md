# Helicopter Overwatch: Milestone 1B-A validation

Restart the mission with the updated files and the usual CBA/RHS dependencies.
Use AI crews and the existing Overwatch waypoint. Name the helicopter being
tested `A3C_OW_TestHeli` in Eden. Keep infantry on foot, within the gun's configured
range and visible to the turret. Test on the machine owning the AI gunner/turret;
the gun branch deliberately skips player, absent, dead or nonlocal operators.

## A-D checks

| Test | Setup | Expected observation |
| --- | --- | --- |
| A: Blackfoot, normal armament | Enemy vehicle plus infantry; then remove the vehicle threat. | Existing vehicle missile selection, rotation, firing and guidance still work. Infantry fallback selects the primary 20 mm Gatling and consumes its ammunition. No first-weapon assumption or gun selection during the missile engagement. |
| B: Blackfoot, no usable guided missiles | Leave the 20 mm gun loaded; configure missile pylons empty, or expend the final missile during Overwatch. Use infantry and no remaining vehicle/aircraft threat. | Infantry discovery and gun engagement continue with missile ammunition unavailable. The hover/waypoint does not finish solely because missiles are empty. Repeat with the gun also empty: normal departure and cleanup resume. |
| C: RHS Mi-24V | Infantry and loaded Yak-B. | Selected gun is `rhs_weap_yakB` on the classified primary-gunner path. Yak-B rounds decrease; `rhs_weap_fcs_mi24` is never selected by the gun fallback. |
| D: RHS Mi-24P | Infantry, then a vehicle target with usable missiles. | No scripted infantry gun engagement with the FCS or pilot's fixed cannon. Existing missile behavior continues. With missiles exhausted, there is no gun fallback keeping the waypoint active. |

Also cancel/change the waypoint during a gun window, kill/remove the primary
gunner, take player control of that station, and put infantry outside gun range.
Expect no new gun orders to invalid operators/targets, no stuck hover after
completion/cancellation, and no gun-only continuation without ammunition. Check
the RPT for script errors. For aircraft with multiple approved guns/muzzles or
reserve magazines, verify selection of a loaded combination and ordinary reload
when only reserve rounds remain; no rounds should be created by the script.

## Independent diagnostic block

Run this complete block using **Local Exec** in the mission debug console while
the gun window is active. Run it again to compare round counts. It only reads the
vehicle and writes a snapshot to the RPT and clipboard; it does not select, load,
fire, reveal targets or install event handlers. Keep each case's snapshot together
with observations of actual firing and waypoint completion.

```sqf
private _heli = missionNamespace getVariable ["A3C_OW_TestHeli", objNull];
if (isNull _heli || {!(_heli isKindOf "Helicopter")}) exitWith {
    hint "Name the test helicopter A3C_OW_TestHeli in Eden before preview.";
};
if (isNil "A3C_main_fnc_getHeliOverwatchCapabilities") exitWith {
    hint "Capability function unavailable: restart the updated mission with CBA.";
};
private _caps = [_heli] call A3C_main_fnc_getHeliOverwatchCapabilities;
private _path = _caps get "primaryGunnerTurret";
private _lines = [
    format ["A3C OW 1B-A: time=%1 vehicle=%2 class=%3", time, _heli, typeOf _heli],
    format ["structural guided=%1 gun=%2 gunWeapons=%3 primary=%4",
        _caps get "hasGuidedMissiles", _caps get "hasTraversableGun",
        _caps get "gunWeapons", _path],
    format ["freeze=%1 fireComplete=%2",
        _heli getVariable ["A3C_Freeze_helicopter", []],
        _heli getVariable ["A3C_fireComplete", []]],
    format ["classifier reasons=%1", _caps get "reasons"]
];
if (_path isNotEqualTo []) then {
    private _operator = _heli turretUnit _path;
    _lines pushBack format ["operator=%1 alive=%2 player=%3 local=%4 turretLocal=%5 actualPath=%6 behaviour=%7 assignedTarget=%8",
        _operator, alive _operator, isPlayer _operator, local _operator,
        _heli turretLocal _path, _heli unitTurret _operator,
        behaviour _operator, assignedTarget _operator];
    _lines pushBack format ["selected weapon=%1 state=%2",
        _heli currentWeaponTurret _path, weaponState [_heli, _path]];
    private _stock = magazinesAllTurrets [_heli, true];
    _lines pushBack format ["primary stock=%1", _stock select {(_x select 1) isEqualTo _path}];
    {
        private _weapon = _x get "weapon";
        if (_x getOrDefault ["gunQualifies", false]) then {
            private _cfg = configFile >> "CfgWeapons" >> _weapon;
            {
                private _mag = _x get "magazine";
                private _muzzleName = _x get "muzzle";
                private _muzzle = if (_muzzleName == "this") then {_weapon} else {_muzzleName};
                private _muzzleCfg = if (_muzzleName == "this") then {_cfg} else {_cfg >> _muzzleName};
                private _range = getNumber (_muzzleCfg >> "maxRange");
                {
                    private _modeCfg = if (_x == "this") then {_muzzleCfg} else {_muzzleCfg >> _x};
                    _range = _range max getNumber (_modeCfg >> "maxRange");
                } forEach getArray (_muzzleCfg >> "modes");
                private _rounds = 0;
                {
                    if ((_x select 1) isEqualTo _path && {toLower (_x select 0) == toLower _mag}) then {
                        _rounds = _rounds + ((_x select 2) max 0);
                    };
                } forEach _stock;
                _lines pushBack format ["gun=%1 muzzle=%2 mag=%3 damaging=%4 totalRounds=%5 rangeCeiling=%6 state=%7",
                    _weapon, _muzzle, _mag, _x getOrDefault ["gunAmmoQualifies", false],
                    _rounds, _range min 3000, weaponState [_heli, _path, _weapon, _muzzle]];
            } forEach (_x get "ammunition");
        };
    } forEach (_caps get "candidates");
};
_lines pushBack "weaponState: [weapon,muzzle,mode,magazine,rounds,roundReloadPhase,magazineReloadPhase]";
private _report = _lines joinString toString [13, 10];
diag_log _report;
copyToClipboard _report;
hint "Overwatch snapshot copied to clipboard and RPT.";
```

## Scope and engine checks still pending

The old missile ammunition helper still gates the unchanged missile scan/firing
branch. A remembered missile selection suppresses gun fallback for that iteration,
including the existing air-target path. Infantry search is independent when no
missile target is selected. Completion now requires both the old missile stock
and usable primary-gunner gun stock to be unavailable.

The new gun branch uses the classifier only for guns; `isAttackHelicopter` and UI
availability remain unchanged. Eligibility activation and reconciliation between
the classifier and legacy missile detection belong to Milestone 1B-B. Threat
scoring, directional weighting, target retention and revised air engagement are
also deferred.

Source checks cannot establish engine firing behavior. Verify normal gunner AI
actually aims/fires under the existing pilot/group behavior, and that
`selectWeaponTurret`, explicit-muzzle `weaponState` and ordinary `loadMagazine`
behave correctly for RHS and any multi-muzzle/reserve-magazine aircraft. Gun
orders are issued once per bounded window; if AI switches away after the order,
the window ends and the assigned watch target is cleared. Native AI can still
make its own combat decisions between checks. The script does not force shots or
change AI behavior to override those decisions.

The range guard uses the largest positive muzzle/fire-mode `maxRange`, capped at
the old 3000 m search ceiling. This is configured AI range evidence, not a
ballistic or turret line-of-fire guarantee. Guns without a positive configured
range are conservatively unavailable. The diagnostic prints that ceiling so a
mod-specific missing/incorrect range can be identified before any further change.

Native command references: [weaponState](https://community.bohemia.net/wiki/weaponState),
[selectWeaponTurret](https://community.bohemia.net/wiki/selectWeaponTurret),
[loadMagazine](https://community.bohemia.net/wiki/loadMagazine),
[doFire](https://community.bohemia.net/wiki/doFire).

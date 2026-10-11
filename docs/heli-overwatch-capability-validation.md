# Helicopter Overwatch capability classification (Milestone 1A)

`A3C_main_fnc_getHeliOverwatchCapabilities` is registered but has no gameplay callers. `isAttackHelicopter`, waypoint availability, rotation, target selection and firing remain unchanged.

The classifier returns a HashMap on every path, including null/non-helicopter input. Call it with `[_helicopter] call A3C_main_fnc_getHeliOverwatchCapabilities`. It only reads vehicle/config state; it does not cache, log or dispatch work. CBA is already a required mission dependency; its [turret-config resolver](https://cbateam.github.io/CBA_A3/docs/files/common/fnc_getTurret-sqf.html) handles nested paths.

## Result and classification rules

| Key | Meaning |
| --- | --- |
| `vehicleClass` | Actual vehicle classname |
| `eligible` | One valid primary station AND (`hasGuidedMissiles` OR `hasTraversableGun`) |
| `primaryGunnerTurret` | Full turret path; `[]` if no unique station can be resolved |
| `hasGuidedMissiles` | Installed primary weapon with identified mounted ammunition and guidance evidence |
| `hasTraversableGun` | Installed primary MGunCore/CannonCore weapon with damaging ammunition and at least 60 degrees horizontal and 15 degrees vertical movement |
| `guidedWeapons`, `gunWeapons` | Qualifying weapon classnames |
| `guidedMagazines` | Evidence HashMaps: weapon, muzzle, magazine, ammo, turret/pylon source, guidance and underlying config values |
| `turretLimits` | `[minTurn,maxTurn,minElev,maxElev,overridden]` in degrees; `[]` if unavailable |
| `traverseDegrees`, `elevationDegrees` | Total spans from current engine limits |
| `stations` | All turret paths, role flags, config classes and installed weapons, including rejected/person stations |
| `candidates` | Primary weapon class/parent, gun family, `gunAmmoQualifies`, final gun verdict and ammo evidence including rejected ammunition |
| `reasons` | Acceptance, rejection and ambiguity explanations |

Exactly one `primaryGunner = 1` is required across all turret paths. Missing/multiple flags or an unresolved config return a conservative rejection. Person, cargo, passenger and driver proxies are rejected. A gunship copilot who is explicitly the primary gunner is allowed; `isCopilot` alone is not grounds for rejection. Secondary door-gunner/observer stations never contribute qualifying weapons. An unarmed primary observer cannot borrow weapons from another station.

Guns also require declared `body`/`gun` movement animations. Pylon gun pods do not count as traversable guns. No extra gun ancestry equivalence is guessed for mods.

Gun qualification now waits for installed compatible ammunition evidence. Ordinary terminal projectiles require positive `hit`, or positive `indirectHit` with a positive `indirectHitRange`. The recognised terminal simulations are bullet, shell, rocket, missile and grenade. When `submunitionAmmo` declares a payload, the carrier's own damage is ignored: string references and classname/probability arrays are inspected for real damaging payloads. Inherited empty-string defaults are treated as absent; `shotSubmunitions` without a resolvable payload is rejected. Malformed arrays, empty references, invalid probabilities, unresolved classes, cycles and excessive nesting reject that ammunition with reasons. Zero-probability entries supply no damage evidence. This is bounded to two payload levels, 32 config visits and 32 pairs per descriptor, not a damage/trigger simulation. See the [submunition format](https://community.bistudio.com/wiki/Arma_3_Weapon_Config_Guidelines) and [damage properties](https://community.bistudio.com/wiki/CfgAmmo).

Each assessed gun magazine adds `gunAmmoQualifies`, `gunDamageResolved`, `gunDamageProjectiles` (terminal `[class,simulation,hit,indirectHit,radius]` records) and `gunDamageReasons` to its existing ammo evidence. A candidate only enters `gunWeapons` after at least one magazine qualifies. Empty identified magazines still count. Auxiliary FCS carriers with dummy payloads cannot qualify from a large parent `hit` alone; real submunition guns can qualify from their payloads even when the parent has no damage.

`pylonWeapon` comparisons now ignore classname case for gun-pod detection, ammunition matching and missing-weapon diagnostics. Returned weapon classnames retain the engine's original spelling; turret ownership and selection do not change.

The classifier intersects actual turret magazines with each installed weapon/muzzle's `compatibleMagazines`. It also reads current `getAllPylonsInfo` turret ownership and magazine identity; `pylonWeapon` can establish the magazine association when compatibility omits a mounted pylon magazine. The weapon must still appear in the primary station's `weaponsTurret`. Magazines/pylons assigned to the pilot or other turrets do not supply guidance evidence for the primary gunner.

[`magazinesAllTurrets`](https://community.bistudio.com/wiki/magazinesAllTurrets) includes empty magazines. Round counts are never eligibility prerequisites. A zero-round mounted pylon also retains its magazine identity. Compatible but uninstalled ammunition and factory default pylon loadouts do not establish capability.

Native guidance requires missile simulation, positive manoeuvrability and either manual control with a positive control range, or weapon locking plus an ammo seeker and a positive lock cone/range. Modern ammo sensor components take precedence over legacy IR/laser/NV flags. Ordinary `shotRocket` ammo is not native guided ammo. Configured ACE guidance is recognised for missile/rocket ammo when the loaded ACE guidance addon declares `enabled = 1` and a default seeker. This is technical capability, not a claim that AI or current mission settings can use it. See the [Bohemia targeting reference](https://community.bistudio.com/wiki/A3_Targeting_config_reference), [sensor reference](https://community.bistudio.com/wiki/Arma_3_Sensors_config_reference) and [ACE guidance framework](https://ace3.acemod.org/wiki/framework/missile-guidance-framework).

`weaponLockSystem` is diagnostic only: values can combine warning/countermeasure flags and do not establish guidance. Numeric values and expression strings are reported without evaluating config strings or comparing a bitmask to a single flag. `aiAmmoUsageFlags` is not a guidance test.

## Complete read-only debug-console block

Select exactly one helicopter in Eden, or look at a helicopter in mission preview and run this block using **Local Exec**. Optionally replace the first `objNull` with the helicopter's variable name. The block compiles the classifier directly from the mission files, so it also works before the newly registered function has been loaded by a restarted mission. It does not replace a global function or modify the helicopter. It writes the same readable report to the RPT and clipboard.

```sqf
private _vehicle = objNull; // Optional explicit instance, e.g. heliTest.
if (isNull _vehicle) then {
    if (is3DEN) then {
        private _selected = get3DENSelected "object";
        if (count _selected == 1) then {_vehicle = _selected select 0;};
    } else {
        _vehicle = vehicle cursorObject;
        if (!(_vehicle isKindOf "Helicopter") && {vehicle player isKindOf "Helicopter"}) then {
            _vehicle = vehicle player;
        };
    };
};
if (isNull _vehicle || {!(_vehicle isKindOf "Helicopter")}) exitWith {
    private _message = "[A3C HELI CAP] Select one helicopter in Eden, look at one in preview, or specify its variable name.";
    diag_log _message;
    copyToClipboard _message;
    hint _message;
};

private _classify = compile preprocessFileLineNumbers "A3C_CORE\main\functions\fnc_getHeliOverwatchCapabilities.sqf";
private _cap = [_vehicle] call _classify;
private _lines = [
    "[A3C HELI CAP] Classification only; no waypoint eligibility change.",
    format ["Vehicle: %1", _cap get "vehicleClass"],
    format ["Primary gunner path: %1", _cap get "primaryGunnerTurret"],
    format ["Primary limits [minTurn,maxTurn,minElev,maxElev,overridden]: %1", _cap get "turretLimits"],
    format ["Spans: horizontal %1 deg; vertical %2 deg", _cap get "traverseDegrees", _cap get "elevationDegrees"],
    format ["Guided capability: %1; movable gun: %2; ELIGIBLE: %3", _cap get "hasGuidedMissiles", _cap get "hasTraversableGun", _cap get "eligible"],
    format ["Qualifying guided weapons: %1", _cap get "guidedWeapons"],
    format ["Qualifying gun weapons: %1", _cap get "gunWeapons"],
    "Station roles and installed candidate weapon classes:"
];
{
    private _path = _x get "path";
    _lines pushBack format ["  %1 / %2: primaryGunner=%3; person=%4; proxy=%5; copilot=%6; limits=%7", _path, _x get "configClass", _x get "primaryGunner", _x get "isPersonTurret", _x get "proxyType", _x get "isCopilot", _vehicle getTurretLimits _path];
    {
        private _cfg = configFile >> "CfgWeapons" >> _x;
        _lines pushBack format ["    Weapon class %1; parent %2; MGunCore=%3; CannonCore=%4", _x, configName inheritsFrom _cfg, _x isKindOf ["MGunCore", configFile >> "CfgWeapons"], _x isKindOf ["CannonCore", configFile >> "CfgWeapons"]];
    } forEach (_x get "weapons");
} forEach (_cap get "stations");
_lines pushBack "Primary weapon and ammo evidence (including rejections):";
{
    _lines pushBack format ["  %1; parent=%2; gunCore=%3; gunQualifies=%4; pylonGun=%5; damagingAmmo=%6", _x get "weapon", _x get "parentClass", _x get "gunCore", _x get "gunQualifies", _x get "pylonGun", _x get "gunAmmoQualifies"];
    {
        _lines pushBack format ["    %1", _x];
    } forEach (_x get "ammunition");
} forEach (_cap get "candidates");
_lines pushBack format ["Current pylons [index,name,ownerPath,magazine,rounds,...]: %1", getAllPylonsInfo _vehicle];
_lines pushBack format ["Current magazines [class,path,rounds,...] (rounds do not gate eligibility): %1", magazinesAllTurrets [_vehicle, true]];
_lines pushBack "Reasons:";
{_lines pushBack ("  " + _x);} forEach (_cap get "reasons");
{diag_log _x;} forEach _lines;
copyToClipboard (_lines joinString toString [13,10]);
hint format ["%1: guided=%2, movable gun=%3, eligible=%4. Report copied to clipboard and RPT.", _cap get "vehicleClass", _cap get "hasGuidedMissiles", _cap get "hasTraversableGun", _cap get "eligible"];
_cap
```

## Eden validation

1. Load the usual A3C/CBA/mod set and this mission. Place Blackfoot, Kajman, Pawnee, unarmed and door-gun helicopters; add Apache/Hind variants from the mods actually installed. Include an empty helicopter: crew presence must not decide structural eligibility.
2. Run the block for each selected instance. Repeat in mission preview, where actual pylon/turret loadouts are authoritative; Eden and preview instances can differ. Record classname, mod set and the complete report. No helicopter listed here has been engine-verified by this implementation task.
3. Expect Blackfoot/Apache to qualify through guided ammo and a movable gun, Kajman through gun and/or guided ammo, and Hind according to its variant. Expect Pawnee/pilot-fixed guns, ordinary unguided rockets, door-gun-only transports and unarmed helicopters to be rejected. These are review expectations, not classname overrides.
4. For copies with configurable pylons, use Eden loadout attributes to compare guided vs ordinary rocket magazines and gunner vs pilot ownership. Removing a pylon must not count its factory default magazine. A gunner-mounted fixed gun pod must not count as a movable gun.
5. Use a test instance with zero remaining rounds but retained magazine/pylon identity. Its structural capability should remain the same. If the engine/mod entirely removes magazine identity, inspect the conservative rejection and rearm to confirm the capability evidence returns.
6. Inspect nested primary paths and primary-gunner role flags. Missing or multiple primary flags must reject with a reason. For gun-only candidates, verify both movement spans meet 60/15 degrees; aim the gun in preview to confirm model animations actually move the weapon. Optical movement alone is not engine proof of gun movement.
7. Confirm existing UI availability and Helicopter Overwatch still use `isAttackHelicopter`, with the working rotation/firing behavior unchanged. Do not connect the new function until these reports have been reviewed.

For the classification correction, repeat Mi-24V/P and the baseline aircraft. Expected Mi-24V: guided=true, movable gun=true with Yak-B only. Expected Mi-24P: guided=true, movable gun=false (the fixed cannon is pilot-owned). The FCS must be absent from both `gunWeapons` lists, with its dummy payload rejection visible in ammo evidence. Check that differently cased pylon launcher names match the original installed weapon name. Blackfoot and Kajman should retain both capabilities; Pawnee should retain neither. These remain engine verification expectations for the corrected code.

## Remaining config uncertainties

- The classifier trusts explicit station roles. A mod incorrectly declaring a door gun as the sole primary gunner, with an ordinary gunner proxy, provides no universal config flag that distinguishes it from a dedicated gunner. Review the station report and actual seat before activating new rules; no name/localisation/classname guess is made.
- Magazine identity completely removed by the engine, scripts or a custom loadout is not distinguishable from an intentionally uninstalled ammunition family. The classifier does not resurrect capability from compatibility lists. Empty identified magazines still qualify.
- Current turret limits and declared animation names are structural evidence, not proof that a mod's model animates correctly. Pylon gun pods are conservatively excluded, including an unusual mod implementing a movable pod.
- Script-only guidance outside the recognised native/ACE configuration, missing native steering/lock data, DataLink-only seekers, or non-MGunCore/CannonCore gun families can produce conservative false negatives. The candidate evidence exposes what was found; no launcher inheritance guess compensates for missing evidence.
- ACE configuration recognition does not verify runtime enablement, seeker registration, AI support or a successful launch. Those checks belong to engagement/integration work.
- Damage evidence does not prove that submunitions actually deploy, or predict damage after velocity, penetration, armour, triggers or script changes. Nonstandard terminal simulations, deeper chains, incomplete payload mixtures or inspection bounds produce conservative rejection. The Mi-24V payload classes' actual damage and the corrected aircraft results need a fresh engine report.
- This function uses `getTurretLimits` (Arma 3 2.12+) and `compatibleMagazines` (2.10+), alongside the existing CBA dependency. See [turret limits](https://community.bistudio.com/wiki/getTurretLimits) and [magazine compatibility](https://community.bistudio.com/wiki/compatibleMagazines).

Source validation is separate from engine validation. No individual helicopter classification or missile launch is claimed without a captured engine/config report.

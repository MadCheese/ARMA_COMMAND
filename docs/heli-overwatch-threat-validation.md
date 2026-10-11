# Helicopter Overwatch: Milestone 2A

Implementation is on local `dev_branch`. No commit or push. Source checks do not
verify engine firing behavior; all in-game results below are pending.

## Changed files

- `A3C_CORE/waypointScripts/wpScript_heli_overwatch.sqf`: shared selection before
  either existing engagement sequence, worker-local retention/cache, bounded
  reevaluation and opt-in local snapshots.
- `A3C_CORE/main/functions/fnc_selectHeliOverwatchTarget.sqf`: discovery,
  feasibility, live threat classification, fixed-sector tiers and hysteresis.
- `A3C_CORE/main/functions/fnc_getHeliOverwatchAmmoInfo.sqf`: cached weapon/muzzle/
  magazine configuration evidence and numeric AA flag handling.
- `A3C_CORE/main/functions/XEH_PREP.hpp`: register the two helpers.
- This validation document.

`getHeliOverwatchCapabilities`, `isAttackHelicopter`, shared rotation/guidance
helpers and other waypoint systems are unchanged.

## Feasibility before priority

One `MCSS_fnc_nearEntities` call discovers hostile AIR/TANK/CAR/SHIP/MAN candidates
inside the largest currently usable gun/missile configured range. This radius
does not increase because an enemy has an attack order. No perception, sensor or
`knowsAbout` gate is applied. Each candidate gets a diagnostic row, but only an
eligible candidate enters the ranking tuple.

- Infantry must be alive, hostile and on foot. An executable gun option must
  come from the structural classifier's traversable primary-gunner weapons and
  damaging ammunition, have positive live rounds on that station and cover the
  helicopter-to-target 3D distance. The AI operator must be alive, local, not a
  player and on the correct local turret. Gun range remains the largest positive
  muzzle/mode `maxRange`, capped at the existing 3000 m ceiling. Existing infantry
  discovery has no additional LOS gate; this milestone preserves that behavior.
- Ground/marine vehicles retain the legacy alive/crew/LOS checks, `canFire`,
  speed below 100 km/h and non-horn/non-smoke armament checks. The helicopter must
  have compatible live ammunition on its current gunner's station for an
  installed weapon accepted by the existing lock-system gate (`2` or `4`). The
  accepted ammunition must be a damaging missile with a positive configured
  muzzle/mode range and be classified for ground use; target distance must lie
  within its configured minimum/maximum range. The gunner and helicopter must
  be local, the gunner must be a live AI, and its turret must be local.
- Aircraft retain alive/crew/LOS assessment and threat diagnostics but have no
  executable method in 2A. Their row explicitly says air execution is deferred.
  They never enter the eligible ranking or block infantry/vehicle engagement.
- Guns are still used only for infantry; the existing missile route is still
  used only for supported ground/marine vehicles. No new weapon/target route is
  inferred from a high threat tier. Empty, unsupported or out-of-range options
  cannot retain a target. Reserve compatible gun rounds remain usable through
  the existing ordinary reload sequence.

Feasibility means there is a supported command path with crew, ammunition and
configured range evidence. It does not promise native AI will fire, guarantee
turret line of fire or infer failure from one seven-second gun window. The
legacy missile gate is deliberately narrow; this is not an activation of the
broader structural guided-missile classifier.

## AA evidence and priority

`aiAmmoUsageFlags` is read numerically, including decimal additive text such as
`"64 + 128 + 256"`. The OffensiveAir bit is tested with
`floor(flags / 256) % 2 == 1`, so combined masks work and decimal substrings do
not. Unknown expressions are conservatively unresolved and identified in the
evidence; they are never compiled. Native configuration supports additive flags;
see [CfgAmmo](https://community.bistudio.com/wiki/CfgAmmo).

For infantry, only the actual secondary weapon's compatible live rounds count:
loaded secondary magazines or compatible reserve magazines in inventory. Empty
launchers, classname guesses, magazines loaded in another weapon and AT-only
locking missiles do not establish a usable MANPADS threat.

For vehicles, driver and non-person turret weapons are matched to live stock on
their station, including matching pylon weapon ownership. Each relevant station
needs a live, non-incapacitated operator for immediate readiness. Threat
classification reads remote enemies without requiring their operators to be
local; locality is a constraint on **our firing operators**, not enemy discovery.

Damaging `shotmissile` ammunition with OffensiveAir or `airLock == 2` is strong
AA evidence. Air-only bullet/shell flags also qualify; a shell cannon needs
OffensiveAir plus weapon locking evidence for strong mixed-purpose AA evidence.
Mixed-purpose shells with OffensiveAir but without that additional evidence are
conservatively credible/uncertain AA. Generic mixed-purpose MG bullets do not
establish dedicated AA. `canLock` alone never qualifies an AT missile or MG.
Configured range, stock, `canFire` and operator readiness are checked live.
Armed aircraft additionally need a real damaging gun/missile/rocket system with
remaining rounds; they remain unengageable by this worker regardless of tier.

| Tier | Rule |
| --- | --- |
| 1 | Strong AA (or credible armed aircraft) with compatible live rounds, ready operator, `canFire` and range covering this helicopter. |
| 2 | Remaining credible AA with rounds: mixed-purpose cannon evidence, uncertain operator readiness or unknown/outside configured range. |
| 3 | Other discovered candidates whose `getAttackTarget` or `assignedTarget`, including live vehicle crew, points at this helicopter or its crew. |
| 4 | Other eligible candidates within ±60° of the assigned Overwatch direction. |
| 5 | Other eligible candidates outside that sector. |

AA tiers disregard sector. Out-of-sector targets remain eligible. Sector bearing
is from the helicopter to the candidate, normalized to [-180,180) against the
original `_direction`, never the helicopter's rotating heading. Attack orders
only classify already discovered candidates. See
[getAttackTarget](https://community.bohemia.net/wiki/getAttackTarget).

The eligible acquisition tuple is ascending: tier, actual attack evidence,
in-sector preference, distance, network/object identity, then a worker-local
stable identity fallback. There are no armor/damage multipliers. Existing valid
retention is applied before accepting a same-tier replacement.

## Retention, responsiveness and execution

Each helicopter owns a private retained object, its live priority, acquisition
time and identity/cache data. Invalid or unengageable targets lose retention on
the next evaluation. Any strictly higher priority tier preempts without waiting
for the 12-second period. Within a tier, retain for at least 12 seconds; afterward
a replacement needs either a sector advantage or to be more than 35% closer
with at least 150 m saved. Minor distance changes do not switch targets, even
after 12 seconds. A no-fire gun window does not invalidate or reset retention.

Idle evaluations run every two seconds. The same worker reevaluates at two-second
intervals during the normal seven-second gun window and during missile rotation.
A preempted gun window clears its old target order; a preempted missile rotation
finishes the helper's speed-limit cleanup, discards its owned laser and proceeds
to the new target. Preemption skips the ordinary inter-engagement pacing delay.
The existing rotation cancellation checks remain active.

**An already started missile firing/projectile-completion sequence is not
interrupted.** Its engagement identifiers, original-projectile capture, owner
routing, guidance, waits and laser lifetime/cleanup remain unchanged. A threat
introduced during those waits is considered at the next safe evaluation after
completion. Existing indefinite completion waits when no missile fires are not
redesigned in 2A. This is a responsiveness limitation of preserving that sequence.

The gun still uses ordinary weapon selection, optional ordinary magazine load,
`reveal`/`doTarget`/`doWatch`, and one normal `doFire` order in a window lasting at
most seven seconds. Behavior settings, weapon-state readiness, locality checks
and the defensive `_gunIndex` guard are preserved. No forced shots, aim changes,
guided bullets, extra EHs or background targeting workers are added.

Weapon/magazine config evidence is cached per worker. Structural gun capabilities
refresh when installed weapons, magazine identities, pylons or turret limits
change. Live rounds, crews, target validity, attack evidence, distance and LOS
are reread. Diagnostics are off by default, never automatically log to the RPT,
and their transient snapshot is never broadcast.

## Complete in-game procedure

1. Restart this mission using the updated local files and usual dependencies.
   Use single-player Eden preview first. For multiplayer, run the console blocks
   on the machine owning the helicopter AI/turrets (Server Exec if server-owned).
2. Place a normally armed **Blackfoot** with AI pilot and AI gunner. Name it
   `A3C_OW_TestHeli`. Keep the player outside its group/crew. Use open, flat terrain,
   hover around 100 m AGL and make sure targets have clear vehicle LOS.
3. Use the existing A3C Overwatch waypoint and set its direction to **0° (north)**,
   precondition ARRIVAL and a postcondition TIMEOUT of at least 300 seconds.
   Avoid an immediately true/empty postcondition. Add a following MOVE waypoint
   for departure/cleanup tests. Retest with direction 350° and targets bearing
   10°/290° to verify circular wrapping and the inclusive ±60° boundary.
4. Enable diagnostics with the standalone block below **before issuing Overwatch**.
   Execute it again after acquisition or preemption, and save snapshots with
   observations of actual firing/ammunition consumption. The first invocation
   enables capture; an active missile wait may delay the next snapshot.
5. Prepare each case independently (restart the preview or remove previous test
   enemies). Position distances/bearings from the helicopter's hover position.
   Check snapshots for `eligible=true` and a suitable method before expecting
   that enemy to compete. For close gun tests, start at 200–300 m horizontal range.

| Case | Independent setup/action | Expected selection and execution |
| --- | --- | --- |
| A: MANPADS vs tank | Crewed enemy tank 500 m north; enemy `O_Soldier_AA_F` 250 m bearing 140°, with actual loaded/reserve AA rounds; normal Blackfoot gun/missiles. | Both eligible; MANPADS tier 1/GUN outranks north tank tier 4/MISSILE regardless of sector. |
| B: Two tank groups | Crewed tanks north and southeast (bearing 135°), similar ranges and no actual attack orders against the helicopter. | North tier 4 wins over southeast tier 5. Continued iterations retain a viable target. Comparable tanks within north sector should not alternate on minor distance changes. |
| C: Immediate override | Start with one ordinary crewed enemy vehicle. Add a crewed, armed `O_APC_Tracked_02_AA_F` 600 m bearing 140°, or an armed MANPADS operator within gun range. | Executable AA tier 1 (or conservatively tier 2 if config is ambiguous) preempts tier 4/5 before 12 s expires. During rotation, wait for rotation cleanup. During a fired missile's flight/completion wait, replacement follows safe completion. |
| D: Threat removed | Destroy the selected MANPADS/vehicle using Zeus or its named object `setDamage 1`; alternatively embark infantry or move it outside weapon range. | Next evaluation releases the unengageable target and selects the next eligible enemy. Existing fired missiles retain their laser until their original projectiles complete. |
| E: Feasibility | Start a fresh normal Blackfoot; remove only approved gun magazines, retaining a supported ground missile. Place MANPADS at 250 m outside sector and a crewed enemy tank north. | MANPADS may be tier 1 but `eligible=false`, method empty; tank wins and uses the existing missile route. |
| F: Missile regression | Normal Blackfoot guided-missile loadout, crewed enemy ground vehicle north, no infantry/AA competitors. | Rotation, laser attachment, `fireAtTarget`, engagement IDs, captured original projectiles, guidance, completion and cleanup still work. Compare actual rounds and RPT, not just selection. |
| G: Gun regression | Normal Blackfoot, nearby ordinary enemy on-foot infantry north; remove other competing enemies. | GUN selected; primary gun consumes rounds with existing AI behavior and normal `doFire`. Seven-second no-fire attempts retain preference and do not trigger forced-fire assistance. |

Also place an enemy armed aircraft inside the discovery radius along with a
valid tank/infantry target. Its diagnostic row must report air execution deferred
and `eligible=false`; it must never suppress either supported engagement route.
Repeat AA classification with an AT-only launcher, an empty AA launcher and an
ordinary MG vehicle: none should qualify for operational AA merely by class or
locking ability. For tier 3, give an already nearby ordinary enemy gunner a
`doTarget A3C_OW_TestHeli` order and inspect its assigned target evidence; do not
expect distant attackers outside the discovery radius to be discovered.

For E, this complete console block removes only the classifier-approved gun
magazines from the test helicopter. It intentionally changes test ammunition;
restart the preview afterward for F/G.

```sqf
private _heli = missionNamespace getVariable ["A3C_OW_TestHeli", objNull];
if (isNull _heli || {!local _heli}) exitWith {hint "Run where A3C_OW_TestHeli is local.";};
private _caps = [_heli] call A3C_main_fnc_getHeliOverwatchCapabilities;
private _path = _caps get "primaryGunnerTurret";
if (_path isEqualTo [] || {!(_heli turretLocal _path)}) exitWith {hint "No local primary turret.";};
private _mags = [];
{
    if (_x getOrDefault ["gunQualifies", false]) then {
        {_mags pushBackUnique (_x get "magazine");} forEach (_x get "ammunition");
    };
} forEach (_caps get "candidates");
{_heli removeMagazinesTurret [_x, _path];} forEach _mags;
hint format ["Removed approved gun magazines %1; inspect remaining missile stock.", _mags];
```

## Standalone ranking diagnostic block

This entire block can be pasted into the debug console independently. It enables
local snapshots and reads the last worker evaluation. It installs no EH, starts
no worker, creates no targets and issues no weapon/AI commands. Logging occurs
only when you execute it. Snapshot time/age expose potentially stale readings
during preserved missile waits.

```sqf
private _heli = missionNamespace getVariable ["A3C_OW_TestHeli", objNull];
if (isNull _heli || {!(_heli isKindOf "Helicopter")}) exitWith {
    hint "Name the AI test helicopter A3C_OW_TestHeli in Eden.";
};
if (!local _heli) exitWith {hint "Run this block on the helicopter owner.";};
if (isNil "A3C_main_fnc_selectHeliOverwatchTarget") exitWith {
    hint "Restart the mission with updated 2A files and dependencies.";
};
_heli setVariable ["A3C_OW_Debug", true];
private _snapshot = _heli getVariable ["A3C_OW_Ranking", createHashMap];
if (count _snapshot == 0) exitWith {
    hint "Ranking capture enabled. Issue Overwatch, then rerun after its next evaluation.";
};
private _caps = [_heli] call A3C_main_fnc_getHeliOverwatchCapabilities;
private _path = _caps get "primaryGunnerTurret";
private _lines = [
    format ["A3C OW 2A: now=%1 snapshot=%2 age=%3 heli=%4 class=%5 FIXED direction=%6 radius=%7",
        time, _snapshot get "time", time - (_snapshot get "time"), _heli, typeOf _heli,
        _snapshot get "direction", _snapshot get "radius"],
    format ["selected=%1 tier=%2 previous=%3 retained=%4 previousAcquisitionAge=%5 reason=%6",
        _snapshot get "selected", _snapshot get "priority", _snapshot get "previous",
        _snapshot get "retained", _snapshot get "age", _snapshot get "decision"],
    format ["freeze=%1 fireComplete=%2 capturedShot=%3 gunner=%4 gunnerLocal=%5 primaryPath=%6",
        _heli getVariable ["A3C_Freeze_helicopter", []],
        _heli getVariable ["A3C_fireComplete", []],
        _heli getVariable ["A3C_Guided_Projectile", []], gunner _heli, local gunner _heli, _path],
    format ["live turret stock=%1 pylons=%2", magazinesAllTurrets [_heli, true], getAllPylonsInfo _heli]
];
if (_path isNotEqualTo []) then {
    _lines pushBack format ["primary operator=%1 turretLocal=%2 selectedState=%3",
        _heli turretUnit _path, _heli turretLocal _path, weaponState [_heli, _path]];
};
{
    _lines pushBack format ["candidate=%1 type=%2 distance=%3 threat=%4 tier=%5 sector=%6 angle=%7 method=%8 eligible=%9 option=%10 rejection=%11 evidence=%12",
        _x get "target", _x get "type", _x get "distance", _x get "threat",
        _x get "tier", _x get "sector", _x get "angle", _x get "method",
        _x get "eligible", _x get "option", _x get "reason", _x get "evidence"];
} forEach (_snapshot get "candidates");
private _report = _lines joinString toString [13, 10];
diag_log _report;
copyToClipboard _report;
hint "2A ranking snapshot copied to clipboard and RPT; capture remains enabled locally.";
```

Disable local capture with this independent block:

```sqf
private _heli = missionNamespace getVariable ["A3C_OW_TestHeli", objNull];
if (!isNull _heli && {local _heli}) then {
    _heli setVariable ["A3C_OW_Debug", false];
    _heli setVariable ["A3C_OW_Ranking", nil];
};
```

Finally cancel/change the waypoint during rotation and gun engagement; remove or
kill the gunner; take player control; exhaust all supported ammunition; and let
the postcondition finish. Check departure to the next waypoint, PATH/height
restoration, freeze reset and Fired-EH removal. Review the RPT for script errors,
record actual missile/gun rounds consumed and verify temporary lasers disappear
after owned shots complete. Repeat on the owner machine in multiplayer; transient
ranking must not appear as public state on other clients.

## Source-level checks performed

- `git diff --check` passed; changes are limited to the five listed files on
  `dev_branch`.
- Bracket/string/comment structure passed for the three SQF sources and all
  three standalone console blocks. This is not an Arma compiler/runtime test.
- Exact comparisons against the local starting revision passed for the
  `_doFire` helper, Fired EH, engagement IDs/guidance, missile firing/completion
  sequence, gun selection/reload/target setup and readiness/normal `doFire`
  sequence. Laser geometry matched after ignoring moved indentation.
- Behavior commands, seven-second window and `_gunIndex` guard remain present.
  Helper registrations resolve to their files; no extra EHs/workers, perception
  gates or public ranking updates were introduced.
- Independent arithmetic checks passed for 2520 fixed-bearing/wrap cases and
  all 2048 masks from 0 through 2047, including combined OffensiveAir flags.
  These checks establish the arithmetic, not engine target-selection behavior.

## Deferred cases

Air firing (2B), RHS Mi-24 missile compatibility, eligibility/UI activation through
`isAttackHelicopter`, native long-range infantry firing limitations, perfect
universal AA/payload analysis, ballistic assistance and incoming-fire tracking
remain out of scope. Ambiguous config sums beyond decimal addition and gun AA
without sufficient purpose evidence remain conservative. The legacy missile
execution and its existing completion-wait failure modes need in-game regression
testing, not claims of verification from source checks.

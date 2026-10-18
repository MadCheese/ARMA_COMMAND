# Shilka AA threat classification

Work is on local `dev_branch`, preserving the uncommitted LOS/reselection fix.
No commit or push. Production edits are confined to `_threat` in
`fnc_selectHeliOverwatchTarget.sqf` and the AA-grade branch of
`fnc_getHeliOverwatchAmmoInfo.sqf`.

## Cause and correction

The supplied `rhs_zsu234_aa` observation reports 1734 rounds of
`rhs_mag_AZP23_2000` on turret `[0]`, with `RHS_ammo_23mm_AA`, `shotBullet`, and
`aiAmmoUsageFlags = "64 + 128 + 256"`. The previous station list could omit that
turret. Independently, mixed-purpose `shotBullet` ammunition with explicit
OffensiveAir evidence fell through to AA grade 0; mixed shells already had a
grade-2 fallback.

Station discovery now deduplicates driver `[-1]`, `allTurrets [vehicle,true]`
and turret paths from positive live ammunition inventory. Inventory is only a
source of candidate paths: each non-driver path must resolve to a real turret
configuration through the mission's existing CBA dependency. Person/FFV turrets
and passenger/cargo/driver proxies on non-driver paths are excluded. Dedicated
driver-operated weapons on `[-1]` remain supported. No class-name exceptions or
`CfgVehicles >> threat[]` override is used.

Each station still enumerates its installed `weaponsTurret` weapons and actual
muzzles, requires a compatible magazine (or the existing exact pylon-weapon
match), and requires positive rounds on the same turret path. Cargo inventory
and another turret's rounds cannot qualify its weapons. Immediate readiness
now also verifies that the live, non-incapacitated operator is actually inside
the vehicle on that exact turret path. No enemy-locality requirement is added.

Numeric/additive-text flag parsing and bit tests are unchanged. Bohemia defines
`256` as OffensiveAir and permits additive flags; see its
[CfgAmmo reference](https://community.bistudio.com/wiki/CfgAmmo#aiAmmoUsageFlags).
Damaging bullets and shells with explicit OffensiveAir evidence now both retain
grade 2 when mixed offensive flags prevent the existing dedicated-AA grade-1
test. Mere physical damage, `canLock` alone, or ordinary flags `64`/`192` do not
establish AA evidence. Dedicated-AA ammunition rules remain unchanged.

The existing conversion remains: ammunition grade 1 plus confirmed readiness
gives live AA grade/Tier 1; other credible AA with positive compatible stock
gives live grade/Tier 2. Readiness requires a live target, the correct ready
operator, `canFire` for vehicles, and configured range covering the helicopter.
There is no reload, mobility, damage-threshold or neutralization redesign.
[Bohemia's canFire documentation](https://community.bistudio.com/wiki/canFire)
describes its broad vehicle/operator/weapon test; it is retained conservatively,
not treated as a guarantee of every modded turret's firing behavior.

For the supplied Shilka, the expected ammunition AA grade is **2** and its
expected priority is **Tier 2**, assuming normal candidate engageability.
`canFire=false` prevents confirmed immediate readiness; even with
`canFire=true`, mixed-purpose grade-2 ammunition remains Tier 2. It outranks
eligible ordinary Tier 3-5 vehicles. Uncrewed, destroyed or otherwise ineligible
objects do not enter ranking merely because their diagnostic AA evidence is
credible. No positive compatible rounds means no AA grade contribution.

## Evidence and unchanged behavior

Existing opt-in `A3C_OW_Debug` candidate `evidence` now identifies station path,
installed weapons, actual operator, operator readiness and `canFire`. Qualifying
ammunition evidence includes weapon, magazine, ammo, parsed flags, ammunition
AA grade, exact turret, remaining rounds, range/readiness booleans and resulting
live grade. Rejected FFV/unresolved paths and matched non-AA ammunition have
explicit debug notes. There is no periodic RPT logging added.

Acquisition, static detection, LOS, exclusions, eligibility/neutralization,
five-tier ordering and hysteresis are unchanged outside the threat closure.
The waypoint script, firing cadence, rotations, weapon selection, missile
accounting/reservations/0.5-second assessment/quarantine, native/scripted/ACE
guidance and gun bursts/guidance remain untouched by this operation. The ammo
helper's `airAmmo`, damage, range and simulation fields used by firing remain
unchanged.

## Automated checks performed

Run from the mission root:

```powershell
python -B tests/check_heli_overwatch_threats.py
python -B tests/check_heli_overwatch_missile_control.py
git diff --check
```

The focused checker evaluates the actual production AA-grade assignment/if
block and extracted pure bit-test/readiness predicates against fixture inputs.
Its small evaluator handles only the engine-free expressions in those blocks;
it is not an Arma interpreter. The decimal sum fixture supplies 448, while a
source comparison verifies the production numeric/text parser remains exactly
unchanged. Fixtures cover numeric/text 448, ordinary flags 64/192, explicit
air-only bullets, mixed/locking shells, AA/AT missiles, nondamaging ammunition,
unresolved flag text, readiness with missing crew/disabled guns/dead targets,
and operational dedicated AA. Exact-path stock fixtures reject zero rounds or
rounds on an unrelated station.

Static station contracts verify inventory-path union including omitted `[0]`,
deduplication, config/person/proxy guards, driver support, installed weapons,
compatibility, exact stock path, positive rounds and operator identity. They do
not invoke engine turret enumeration. Existing missile/LOS/exclusion checks
pass, with their acquisition comparison allowing only the explicitly changed
threat closure; detection and eligibility outside it remain compared verbatim.
`git diff --check` passes. The earlier waypoint, shared LOS helper/registration
and LOS validation document were checked against their pre-task content, as
were selector content before and after `_threat`.

All of these are source/fixture results. Arma/RHS configuration integration,
collision, firing and gameplay results remain pending.

## Runtime verification (pending)

Use the existing preview helicopter `testBlackFoot`, a hostile crewed Shilka
named `A3C_OW_TestShilka`, and an ordinary eligible hostile vehicle. Keep both
inside executable engagement range with clear LOS; use the normal Overwatch
waypoint. Enable debug before acquisition, then rerun to inspect:

```sqf
testBlackFoot setVariable ["A3C_OW_Debug", true];
private _snapshot = testBlackFoot getVariable ["A3C_OW_Ranking", createHashMap];
private _rows = _snapshot getOrDefault ["candidates", []];
diag_log format ["OW Shilka: enum=%1 stock=%2 crew=%3 canFire=%4 selected=%5 rows=%6",
    allTurrets [A3C_OW_TestShilka, true], magazinesAllTurrets [A3C_OW_TestShilka, true],
    fullCrew A3C_OW_TestShilka, canFire A3C_OW_TestShilka,
    _snapshot getOrDefault ["selected", objNull],
    _rows select {(_x get "target") isEqualTo A3C_OW_TestShilka}];
```

| Case | Expected evidence/outcome |
| --- | --- |
| Reported Shilka, `canFire=false` | `[0]` considered via inventory even if engine enumeration omits it; correct installed weapon and compatible 1734-round magazine; flags 448; AA grade 2; ready false; Tier 2, ahead of ordinary eligible Tier 3-5 targets. |
| Same mixed cannon, operational | Correct turret/operator and live stock; ready true if in range, still AA grade 2/Tier 2. |
| Ordinary flags 64 or 64+128 | No AA evidence for bullets/shells, regardless of physical damage; ordinary attack/sector tiers still apply. |
| Empty magazine/station | Zero rounds ignored. Another station's ammunition cannot restore this station's AA evidence. |
| Missing/incapacitated gunner or `canFire=false` | No immediate Tier 1; positive compatible AA stock may retain diagnostic Tier 2. With no live crew, normal candidate validity prevents selection. |
| Operational dedicated AA | Dedicated AA ammo, correct ready operator, positive stock, canFire and range yield Tier 1 and preempt Tier 2 under unchanged ranking. |
| FFV/passenger seat | Person/proxy station excluded even if inventory reports an air-flagged round there; cannot establish the vehicle's dedicated AA capability. |
| Driver-operated dedicated AA | `[-1]` installed weapon, exact compatible stock and actual driver can qualify normally. |

Start a fresh disposable preview or restore the intended test fixtures between
cases. No runtime result is claimed by this document.

Changed for this operation: the two production classification files above,
`tests/check_heli_overwatch_threats.py` (new focused checks),
`tests/check_heli_overwatch_missile_control.py` (isolate the threat block in its
otherwise unchanged acquisition comparison), and this new validation document.

# TANKSHOT aiming investigation and deadline correction

## Confirmed defects and implemented fixes

`fnc_executeTankShot.sqf` retained a ready ammunition candidate after the loop timed out. Its final settle guard then replaced `AIM_TIMEOUT` with `AIM_LOST`. The loop now explicitly marks successful preparation as `AIM_READY` (internal only); other outcomes exit before that guard. Later ownership checks resolve only unfinished/invalid execution or capture results, preserving specific preparation failures.

Accepted aim still means the existing `aimedAtTarget == 1 OR MCSS horizontal arc` condition. It must remain accepted continuously for three seconds before it counts as established. `AIM_LOST` requires this established state followed by loss, or loss at the final recheck after successful settling. An isolated/transient acceptance that never settles ends as `AIM_TIMEOUT`. Cannon alignment and horizontal fallback are logged separately; fallback acceptance does not prove cannon alignment.

The independent aiming clock now starts when the preferred shell, or the existing deadline-selected fallback, is physically ready. Both round and magazine reload phases must be zero. There is ten seconds to acquire aim, with up to three seconds to finish settling if acceptance begins before that deadline. A cannon direction change of at least 0.5 degrees accompanying a reduction of at least one degree in angular error toward the watch point records traversal progress. Progress in the preceding three seconds, after readiness, can grant one additional ten-second allowance. It is capped at the original hard wait bound minus settling time; instruction refreshes and subsequent reloads do not restart the clock.

Physical reload allowance remains 15–60 seconds. The hard wait remains `reloadDeadline + 10 + 3`, and capture remains three seconds: the existing maximum of 76 seconds of waits is unchanged. Server/local lifecycle watchdogs, token-aware recovery and commander delivery are unchanged. No-response examples, excluding preparation and polling overhead: ready HE fails after ten seconds; HE ready eight seconds into a predicted 17-second reload fails around 18 seconds instead of 27. Recent traversal can use more time within the same overall cap.

## Evidence and unresolved targeting cause

The reviewed owner RPT, `Arma3_x64_2026-10-10_19-56-04.rpt`, records the 20:15:19–20:15:46 attempt against `Land_i_Stone_Shed_V1_F`. The cannon was selected successfully, and HE magazine reload phase reached zero by 20:15:27. Nevertheless, the old aim deadline retained the full 27-second budget. An initial combined acceptance became false; the old log cannot tell whether it was cannon alignment or only horizontal fallback, nor whether the turret physically moved.

The designation was ASL `[12227.6,16966.7,40.7916]`, the unattached proxy was ASL `[12227.6,16966.7,40.2916]`, and positional `doWatch` received AGL `[12227.6,16966.7,1.59785]`. Source inspection confirms the following sequence:

1. Select the validated cannon on the gunner's local turret.
2. Issue `lookAt` and `doTarget` against the existing proxy, then `doWatch` against the designation position for building/terrain targets. Vehicle targets retain the existing object watch/attachment behavior.
3. Perform the same physical ammunition switch while aiming; refresh the same commands after magazine reload and periodically when acceptance is absent.
4. Require the same ready shell and three-second accepted settle, then recheck before the unchanged magazine-instance firing/capture sequence.

No source or existing log proves that command order, proxy side, vegetation, or weapon selection causes the inconsistent rotation. The position watch and proxy differ vertically by 0.5 metres; the proxy's model aim position may also differ from its object origin. Nearby building points can change elevation/geometry relative to these positions. These remain hypotheses for comparison, not reasons to change the target mechanism. The proxy, side, offsets, attachments, selection and all three aiming commands remain unchanged.

`MCSS_fnc_lineOfSightVehicle` checks the main turret's horizontal animation within 13 degrees; it ignores elevation and performs no obstruction test. Its accepted fallback remains intact for assisted remote fire. Bohemia documents [aimedAtTarget](https://community.bistudio.com/wiki/aimedAtTarget) as a weapon-specific numeric aiming-quality query, rather than guaranteed impact accuracy, and [weaponDirection](https://community.bistudio.com/wiki/weaponDirection) as a weapon direction vector, with primary-turret limitations. This path already requires the primary gunner. Logged angles use gunner `eyePos` as an approximate origin; they are not ballistic alignment or zeroing checks. Invalid/zero direction produces an empty vector and angles `-1`, and earns no traversal extension.

## A/B runtime comparison — pending

Enable diagnostics before each normal A3C order on every executing owner:

```sqf
missionNamespace setVariable ["A3C_DEBUG", true, true];
```

Leave tank position, crew, building and vegetation unchanged. Identify traces by order token, and wait for cleanup before repeating.

| Test | Setup | Compare / required result |
| --- | --- | --- |
| A | Previously failing point on the same building; repeat it several times | Original ASL, proxy ASL/ATL/model aim position, watch AGL, selected cannon, independent numeric quality/arc, cannon vector and angular deviation; determine whether direction ever changes |
| B | Nearby successful point on that building, same tank position | Compare coordinates, elevation/limits, reload state, first acceptance and first cannon alignment against A; record the successful point exactly |
| C | Repeat A/B with ready HE, then APFSDS requiring HE reload | No response ends near readiness + ten seconds; physically incomplete reload retains its budget; turning can earn one capped extension; successful shot retains three-second settling |
| D | Existing vehicle-target engagement | Same AP preference/object watch; one physical switch if needed, one captured cannon projectile and existing DIRECT guidance |
| E | Deliberately unsuitable aim, then repeat a viable order | Accurate timeout/loss reason; temporary watch/target/look cleared, original AUTOTARGET restored, tokens/active entry/handler/unfired proxy released; new order accepted after cleanup |

Initial instruction logs and phase-completion logs include independent aiming samples. The first loop sample is immediate; meaningful quality/arc/readiness/reload/selected-weapon transitions are limited to one log per second, with periodic samples every five seconds. `physical ammo ready` records absolute completion time, elapsed time, magazine and both zero phases. Completion includes final reason and a summary:

`[elapsed, firstAccepted, firstCannon, settledEver, acceptedLost, cannonLost, readyElapsed, traverseExtended, watchRequests, lastSample]`

The last sample is `[quality, arc, accepted, direction, designationDeg, proxyDeg, watchDeg]`. First-event/ready times are elapsed seconds from the initial aim request; `-1` means never observed. `cannonLost=true` with accepted aim still true identifies continued horizontal fallback after cannon quality was lost. A ready shell with unchanged direction, no acceptance and `AIM_TIMEOUT` supports the no-response case; changing direction with persistent error supports traversal without alignment. These observations do not by themselves identify the responsible engine instruction.

## Validation performed

- Passed lexical SQF delimiter/string checks and diagnostic format-argument checks; no engine compiler was available.
- Passed source comparisons for ammunition preference/muzzle selection, the single `loadMagazine`, both readiness phases, ready fallback selection, exact `UseMagazine` instance validation, `FiredMan` capture and DIRECT guidance. Aiming commands and reservation/recovery setup remain identical.
- Passed thirteen deterministic deadline/history model cases: no reload, early/maximum reload completion, traversal extension/cap, late settling, transient versus established loss, both blocked reload phases, reload settle reset and oscillation. This model checks timing decisions, not engine AI or physical reload behavior.
- All runtime A–E comparisons remain pending. No claim is made that the inconsistent turret response has been reproduced or fixed in-game.

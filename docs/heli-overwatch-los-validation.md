# Helicopter Overwatch LOS consistency and temporary rejection

Work starts from clean `dev_branch`, `a6568c2`. No commit or push.

This document covers the complete LOS and rejected-target cycling fix, including
the requirements supplied in the follow-up message.

## Behavior

`A3C_main_fnc_hasHeliOverwatchLOS` is registered in `XEH_PREP.hpp`. It tests
`eyePos _heli` to `aimPos _target`, both ASL, ignoring both endpoint objects,
using `VIEW` with `GEOM` fallback. The selector's optical ray and vehicle
eligibility, and the controller's `_engagementCurrent`, share this function.
The selector reuses the just-computed optical clearance when available; firing
authorization always checks current geometry. Knowledge and sensor detection
do not bypass vehicle LOS eligibility.

The full ray is divided into equal segments of at most 4000 m. Internal
segments begin one metre before the previous endpoint, so even with overlap
each command remains below 5000 m. Every segment must be clear; the first
obstruction stops the test. Empty results from a single overlong ray are never
used as clearance evidence. No weapon range or AA range cap is introduced.

The knowledge threshold, sensor snapshot/contact identity, optical range/cone
rules, weapon options, ranking, hysteresis, missile records, guidance, gun
behavior and lifecycle remain unchanged. Infantry firing eligibility keeps its
existing policy. No new worker, event handler, global variable or configuration
is added. AA threat classification and `aiAmmoUsageFlags` are untouched.

This supersedes the older acquisition validation document's statement that
knowledge/sensor vehicles retain origin-based LOS, and that firing LOS is
untouched. An elevated clear target should now pass both LOS checks; a blocked
target should fail vehicle eligibility regardless of acquisition path.

## Temporary exclusions and diagnostics

The existing worker owns `_engagementRejections`, an array of exact object
references with `[target, until, cause]` entries. Firing authorization failures
for `LOS_BLOCKED`, `TARGET_OUT_OF_RANGE`, or `TARGET_INVALID` exclude that target
for five seconds. The existing final aircraft and ground neutralization guards
also report `TARGET_INVALID` without changing their neutralization predicates.
An attempt latches its first authorization rejection so repeated polling does
not extend the deadline or overwrite the cause with a later preemption.

After cleanup, a target rejection skips the ordinary one-second pacing sleep
and reevaluates candidates immediately. The selector receives exclusions as an
optional eighth argument. Detection, feasibility checks and threat assessment
still run, and excluded candidates retain diagnostic rows. Active exclusions
force `eligible=false` before ranking. The existing retained-target lookup
requires `eligible`, so hysteresis cannot restore an excluded target. The next
candidate competes using the unchanged five-tier tuple.

Expired/deleted entries are pruned on ordinary evaluations. After expiry the
target competes again subject to all live eligibility checks, even if its
original failure cause has changed. There is no permanent target blacklist.
An unchanged blocked target will normally be rejected by the shared selector
LOS check itself, without starting another firing attempt.

`WEAPON_UNAVAILABLE` covers the existing live operator, locality, session lease,
turret, weapon and stock predicates. Reloading continues through the original
weapon-state/readiness loop. These weapon failures do not populate target
exclusions. Neither do `TARGET_PREEMPTED`, `SESSION_CANCELLED`, or
`TARGET_TEMPORARILY_UNAVAILABLE` from missile reservations/quarantine. The
separate missile-flight ledger remains authoritative for reservations and the
0.5-second post-flight assessment. A command's own reservation is an ordinary
reason to finish its firing loop, not an early-rejection diagnostic.

With `A3C_OW_Debug` enabled, the first rejection or a change of rejected target,
cause, or scope emits `A3C OW authorization rejected`, including target,
specific cause, exclusion flag and deadline. Renewing an unchanged rejection
does not emit another message. One worker-local last-rejection map is replaced
on rejection and cleared after confirmed shots. This bounds diagnostic state;
the existing generic `A3C OW fire` summary now requires an issued firing command,
so failures before request creation do not produce `fire -1`. Target-specific
early rejection does not set the missile-launch failure flag or apply the
weapon-wide failure backoff. Existing readiness/acknowledgement failures retain
their original handling.

The existing `A3C_OW_Ranking` debug snapshot adds:

- `engagementRejections`: active `[target, until, cause]` entries.
- `lastEngagementRejection`: historical `time`, `target`, `cause`, `scope`,
  `excluded`, and `until`. Its flags describe the rejection at that time; use the
  active array and current `time` for current availability.
- Each detected candidate row adds `temporarilyExcluded`, `rejectedUntil`, and
  `rejectionCause`. Active exclusions also explain `TARGET_TEMPORARILY_UNAVAILABLE`
  and the underlying cause in the row's existing `reason`.

`session.lastFire` preserves its existing array format and receives the latched
reason even when no request ID was allocated. Exclusions remain private to the
worker and disappear with it; normal waypoint/session cleanup is untouched.

## Runtime checks (pending)

On the helicopter owner, use the existing hostile, crewed `rhs_bmd1` reproduction
at approximately 2129.71 m with DAGR range 600–5000 m. Enable the existing
`A3C_OW_Debug` snapshot. For named helicopter `testBlackFoot` and target
`A3C_OW_TestGround`, run:

```sqf
private _heli = testBlackFoot;
private _target = A3C_OW_TestGround;
diag_log format ["OW LOS: distance=%1 shared=%2 legacy=%3 elevated=%4",
    _heli distance _target,
    [_heli, _target] call A3C_main_fnc_hasHeliOverwatchLOS,
    lineIntersects [getPosASL _heli, getPosASL _target, _heli, _target],
    lineIntersectsSurfaces [eyePos _heli, aimPos _target, _heli, _target, true, 1, "VIEW", "GEOM"]];
```

Use that final direct ray only within 5000 m. Confirm the shared result is true
in the reported reproduction, the selector remains eligible, and actual Fired
events replace repeated zero-shot authorization rejection. This does not promise
a launch if another live firing prerequisite fails.

Repeat with a building and a ridge blocking the elevated ray, beyond 1000 m.
With knowledge or a sensor contact, the target may remain detected but must be
ineligible; without those paths, optical acquisition must fail. Remove the
obstruction and confirm ordinary reevaluation permits engagement again.

For an aircraft known or sensor-reported beyond 5000 m but within an installed
AA option's actual range, test the shared helper with a fully clear path, then
with an obstruction in the first segment, at an internal seam, and beyond
5000 m. Clear paths should remain eligible; each obstructed path must fail.
Do not increase the 3000 m optical acquisition range for this test. Also test
just below/at/above 4000 m and 5000 m eye-to-aim distances. Observe native or
scripted guidance and per-target flight tracking continue normally after a
confirmed launch. Engine collision and gameplay outcomes remain unverified here.

For selection diagnostics, enable the existing debug switch before issuing
Overwatch, then repeat the block after the relevant transition:

```sqf
testBlackFoot setVariable ["A3C_OW_Debug", true];
private _snapshot = testBlackFoot getVariable ["A3C_OW_Ranking", createHashMap];
diag_log format ["OW rejection snapshot: now=%1 captured=%2 selected=%3 active=%4 last=%5 candidates=%6",
    time, _snapshot getOrDefault ["time", -1], _snapshot getOrDefault ["selected", objNull],
    _snapshot getOrDefault ["engagementRejections", []],
    _snapshot getOrDefault ["lastEngagementRejection", createHashMap],
    _snapshot getOrDefault ["candidates", []]];
```

| Case | Manual setup and expected evidence (all pending in game) |
| --- | --- |
| 1. Reported BMD-1 | Original 2129.71 m DAGR reproduction: legacy origin result true, shared elevated LOS true, selector eligible, and firing authorization passes LOS. Confirm a real Fired event if all other prerequisites still hold. |
| 2. Obstruction and alternative | Two acquired hostile vehicles. A stable building/ridge obstruction must make the blocked vehicle ineligible and allow the other vehicle. Also move cover into the elevated ray after selection, during rotation/settling: expect `LOS_BLOCKED`, five-second exclusion, preserved candidate row, and immediate reevaluation of the alternative. |
| 3. Recovery/range/validity | Remove the transient obstruction and allow five seconds from rejection; target competes again. Similarly move a selected target out of weapon range before authorization, then back, observing `TARGET_OUT_OF_RANGE`. Changing hostility, embarking infantry or removing live crew during preparation should report `TARGET_INVALID`; restore a valid disposable test target and confirm bounded recovery. |
| 4. Reservation safety | With an operational hostile aircraft's actual missile still alive, no second missile may launch at that aircraft; the rejection array must not acquire an entry merely for its reservation. Preserve the 0.5-second assessment after all associated projectiles terminate. |
| 5. Independent launches | Two operational aircraft, compatible missiles, confirmed guidance and no quarantine: an existing flight against A must still permit B through the original command path/cadence. See the Phase 2 validation document for the overlap setup. |
| 6. Gun and guidance regression | Exercise the normal eight-round gun burst, native AA guidance, unsupported native-AA scripted fallback, and the existing ACE reservation behavior where installed. Confirm actual Fired counts, captured original targets and unchanged ownership/quarantine behavior. |
| 7. Quiet repeated rejection | Keep a target blocked after rejection, with debug enabled. No repeated blank `fire -1` messages. Its unchanged rejection does not log each retry; active exclusion and cause remain inspectable. Repeat with a readiness/lease issue: inspect a weapon-scope reason, with no target exclusion, and restore readiness. |

## Static verification

`python tests/check_heli_overwatch_missile_control.py` passes. Its acquisition
comparison normalizes only the explicit shared-LOS substitutions, retaining
verbatim checks of acquisition conditions. Existing Phase 1, threat-tier,
ranking and retention comparisons remain. Added contracts check helper
registration and segmentation, exclusion-before-ranking/retention, expiry and
immediate alternatives, target-versus-controller failure separation, reason
propagation, changed-state logging, and the issued-command log guard. Full
flight/assessment/quarantine, Fired/guidance, and readiness/firing/ammunition
sections are compared against committed Phase 2 source `a6568c2`, allowing only
the new final-target-rejection reporting calls. Both SQF sources, the new helper
and console blocks pass balanced string/comment/delimiter checks.
`git diff --check` passes. These checks do not execute SQF or establish runtime
collision, selection timing, concurrency or gameplay results.

Files changed: `A3C_CORE/main/functions/fnc_hasHeliOverwatchLOS.sqf` (new shared
helper), `A3C_CORE/main/functions/XEH_PREP.hpp` (registration),
`A3C_CORE/main/functions/fnc_selectHeliOverwatchTarget.sqf` (shared LOS and
exclusion eligibility/diagnostics),
`A3C_CORE/waypointScripts/wpScript_heli_overwatch.sqf` (authorization, private
exclusions and diagnostics), `tests/check_heli_overwatch_missile_control.py`
(static contracts), and this validation document.

Bohemia's [surface-ray documentation](https://community.bistudio.com/wiki/lineIntersectsSurfaces)
documents terrain intersections, the 5000 m limit and fallback-only LOD behavior;
its [eyePos documentation](https://community.bistudio.com/wiki?mobileaction=toggle_view_desktop&title=eyePos&useskin=vector)
identifies the object's eyes/main turret position.

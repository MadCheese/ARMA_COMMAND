# Helicopter Overwatch per-target missile control (Phase 2)

Implemented from clean `dev_branch` at `f981344`. Static verification passed;
Arma gameplay/multiplayer testing is pending. No commit or push was performed.

## Modified files

- `A3C_CORE/waypointScripts/wpScript_heli_overwatch.sqf`: session-private flight
  collection, separate global quarantine, Fired ownership/accounting, worker
  maintenance/assessment, target-specific final authorization, safe launch
  acknowledgement, laser ownership and optional diagnostic snapshots.
- `A3C_CORE/main/functions/fnc_selectHeliOverwatchTarget.sqf`: optional seventh
  parameter containing exact target objects unavailable for missiles. Missile
  matching skips those objects; ground gun fallback remains possible. A narrow
  ground missile-effectiveness check prevents repeated missiles against armed
  vehicles that can neither move nor fire.
- `tests/check_heli_overwatch_missile_control.py`: reproducible
  structural, unchanged-section and production state-transition contract checks.
- This document: private/public state semantics, limitations and runtime tests.

Earlier validation documents are historical and unchanged. This guide supersedes
their single-flight description. Shared guidance, weapon classification and
other High Command files are unchanged.

## Records, selection and firing

`session.missileFlights` is an array of request/flight HashMaps. Targets are
compared by their actual object references; names, classes and `netId` are not
reservation keys. The record retains `target`, `id`, `sessionId`, `spec`,
`expectedEvent`, `projectile`, all distinct `projectiles`, `state`, `started`,
`flightStart`, `handoff`/deadline/diagnostic flags, `safetyHold`, `terminated`,
`assessmentUntil`, optional unresolved-round counts and its own ground `laser`.

The normal states are:

```text
PREPARING (request only)
  -> RESERVED (atomic authorization, before the sole forceWeaponFire)
  -> FLIGHT (actual projectile captured by matching Fired)
  -> ASSESSING (every associated projectile terminated; time + 0.5 s)
  -> COMPLETE (assessment performed, record removed)
```

An issued request without an observed projectile can become `UNRESOLVED` in
global quarantine. Trusted late recovery restores its original flight/target.
If an already confirmed flight has unaccounted extra rounds, its existing
record remains reserved and cannot start assessment until those rounds resolve.

The worker supplies reserved targets to the selector, including reservations
under assessment. Acquisition is untouched: records remain visible in candidate
diagnostics. Only the missile option is withheld. A ground target can still use
its existing gun fallback; an AIR target with only missiles cannot remain the
retained winner while reserved. The five tiers, tuple ordering and hysteresis
code are unchanged for eligible candidates.

Only one worker/request sequence issues firing commands. The final unscheduled
block checks both global quarantine and exact-target reservations before
reserving the target, changing launch flags and issuing its single command.
Phase 1's full AIR alive/canMove/live-crew guard remains intact. Ground target
effectiveness is also checked again there.

Missile acknowledgement waits for its captured projectile, the existing
three-second deadline or session/combat cancellation. Selecting B or detecting
A's own reservation cannot prematurely cancel A's launch-acknowledgement window.
The worker then cleans up the request and returns to ordinary evaluation,
without either former flight-completion wait. Existing readiness, rotation,
settling and normal worker pacing still apply. Multiple distinct confirmed
projectiles can therefore remain airborne against different targets.

## Global safety and ownership

The existing singular `session.missileFlight` is now exclusively the quarantine
container, separate from ordinary confirmed flights. It holds observed unknown
`projectiles`, captured `unresolved` requests, an `unobservable` latch,
assessment/deadline fields and a reason. Any nonempty container blocks all new
missile commands; ordinary guns remain available as before. A confirmed record's
`safetyHold` also blocks missiles globally.

- Unexpected or ambiguous Fired events go into global quarantine, never the
  selected target's record. Actual objects are retained until termination. A
  null projectile without attributable request context latches unobservable
  uncertainty until session replacement.
- Ammunition consumption is compared with captured projectile count after
  acknowledgement, including when one projectile was confirmed. Any missing
  rounds remain globally fail-closed. The original request, target and expected
  weapon/muzzle/magazine/mode/operator tuple are retained for recovery.
- Late recovery requires exactly one matching unresolved request and the full
  original session/turret/operator/event checks. It never uses the current
  selected target. A conflicting live missile request or multiple matching
  recovery contexts remain ambiguous and quarantined.
- Distinct extra projectiles matching the still-open original request are added
  to that engagement, reset its termination/assessment state and set a global
  safety hold. All must terminate. Extra objects receive no new A3C guidance,
  preserving the previous first-missile-only guidance behavior. Duplicate events
  for an already captured object are ignored, rather than counted as new rounds.
- A local projectile claim `[sessionId, engagementId]` guards already captured
  objects against reassignment by later/new-session handlers. Claims are private
  bookkeeping and do not change guidance ownership or shot parents.
- Guidance ownership that cannot be confirmed on the firing machine, including
  exceptional remote projectile ownership, sets a global hold until completion.
  `ACE_RESERVED` also holds: that marker does not prove ACE activation. No ACE
  internal functions are called and its guidance is left untouched.
  The existing three-second handoff and 120-second diagnostic limits remain;
  neither timeout releases a live or unaccounted projectile.
- Observed unknown projectiles must terminate and pass a further 0.5-second
  assessment before global quarantine clears. Missing/unobservable launches
  cannot clear merely because other observed objects expired. A known flight's
  reservation/laser also remains while global launch uncertainty could hide
  an additional associated projectile.

The native-AA/ACE/scripted-guidance code and dispatch arguments are unchanged.
Each guidance invocation still receives the actual Fired object and original
captured real target. Several ground flights retain separate surface-attached
lasers. Their real-target guidance is independent of the laser and later
selection; each laser survives through termination/assessment and the closed
Fired acceptance window, or the
existing session cleanup deletes it. No monitoring worker or lifecycle handler
was introduced. Session replacement clears both private collections; previous
guidance continues under its established projectile lifecycle.

Audit found no executable consumers outside Overwatch for `A3C_Guided_Projectile`
or `A3C_fireComplete`; older docs only read them. They retain their tuple formats
and describe the latest launch attempt/primary confirmed shot, not all flights.
The full authoritative collection stays private. Completion/recovery/failed
request cleanup checks each variable's own engagement ID before writing or
clearing it, so flight A cannot clear or overwrite later engagement B's state.

## Assessment and diagnostics

Maintenance runs only through the existing worker's validity/evaluation calls.
The 0.5-second interval begins when it first observes every associated projectile
gone/dead, never at launch. Normal worker polling may observe/release later.
Projectile disappearance is not treated as a hit.

- AIR: alive, mobile and at least one living crew member means operational;
  otherwise neutralized. The selector independently retains Phase 1.
- Non-static ground vehicles/ships: alive/crew validation remains. A target
  that can move **or** fire remains operational. If both are false, mounted
  damaging-ammunition evidence establishes an armed vehicle and withholds
  missiles. Unarmed/uncertain configurations remain indeterminate and keep
  ordinary eligibility. This same narrow condition is recomputed by the
  selector, so removing a completed record does not immediately reauthorize a
  neutralized vehicle; repairs can restore eligibility without a blacklist.
- Static weapons: no mobility criterion. A crewed, firing weapon is operational;
  `canFire=false` alone remains indeterminate and preserves existing eligibility.
  Destroyed/uncrewed weapons fail ordinary validation.

`canFire` is imperfect across vehicle types. This policy intentionally preserves
uncertain static/unarmed cases; installed mod behavior needs testing. See the
[Bohemia command reference](https://community.bistudio.com/wiki/canFire).

With `A3C_OW_Debug`, event-based messages report reservation, confirmation,
termination/assessment start, assessment completion/release/neutralization and
unknown-launch quarantine/release. There is no per-frame RPT output. The existing
ranking snapshot gains `missileFireControl`: active records, actual projectile
objects/alive flags, reservation state, start/assessment times, handoff/hold
reason, global quarantine, unknown objects, unresolved requests and the latest
assessment. Each candidate also explains missile withholding. Only the most
recent completed assessment is retained; completed flight records are removed.

## Practical two-target and failed-missile tests (runtime pending)

Restart the mission with AI-crewed `testBlackFoot` and appropriate live AA/ground
missiles. Name two crewed hostile helicopters `A3C_OW_TestAirA` and
`A3C_OW_TestAirB`. Put them in clear LOS, close in bearing, at sufficient range
within the actual installed weapon/sensor limits for flight overlap to be
observable. Use the normal Overwatch waypoint with a long TIMEOUT. On the
Blackfoot AI/turret owner, enable and inspect diagnostics with:

```sqf
testBlackFoot setVariable ["A3C_OW_Debug", true];
private _snapshot = testBlackFoot getVariable ["A3C_OW_Ranking", createHashMap];
if (count _snapshot == 0) exitWith {hint "Capture enabled. Issue Overwatch, then rerun.";};
private _report = format ["OW now=%1 snapshot=%2 selected=%3 fireControl=%4 candidates=%5",
    time, _snapshot get "time", _snapshot get "selected",
    _snapshot getOrDefault ["missileFireControl", createHashMap], _snapshot get "candidates"];
diag_log _report;
copyToClipboard _report;
hint "Fire-control snapshot copied to clipboard and RPT; check snapshot age.";
```

For the two-target case, require two different engagement IDs, original targets
and distinct actual projectiles with overlapping `alive=true` observations.
One target's reservation must not suppress the other's missile option. Confirm
that native guidance logs still name each original target and there are no
independently authorized duplicate missiles against A.

For a simulated ineffective missile, use a disposable preview with only A
competing and still operational. After its missile is confirmed, execute this
block where those actual projectiles are local. It deliberately deletes the
test missiles, producing disappearance without target damage:

```sqf
private _session = testBlackFoot getVariable ["A3C_OW_Session", createHashMap];
private _flights = _session getOrDefault ["missileFlights", []];
private _index = _flights findIf {(_x get "target") isEqualTo A3C_OW_TestAirA && {(_x get "state") == "FLIGHT"}};
if (_index < 0) exitWith {hint "No confirmed flight to A.";};
private _projectiles = ((_flights select _index) get "projectiles") select {!isNull _x && {alive _x}};
if (_projectiles isEqualTo [] || {_projectiles findIf {!local _x} >= 0}) exitWith {
    hint "No local live projectiles; run on their owner.";
};
{deleteVehicle _x;} forEach _projectiles;
hint "Test missiles deleted. Inspect termination, assessment deadline and reauthorization.";
```

Expect termination, a deadline at least 0.5 seconds after observation, assessment
as operational, release, and normal eligibility for another missile. For the
neutralization variant, first remove A's fuel on its owner and verify it remains
alive/crewed with `canMove=false`; it must not be reauthorized. Restore the
preview afterward. Finish by disabling the existing debug flag.

| Case | Required observation; static contract checked, gameplay pending |
| --- | --- |
| A / G | A reserved in flight/assessment cannot remain the missile-retention winner or receive another command. |
| B / C | Two helicopters, then add a ZSU: distinct per-target records/projectiles can overlap; compatibility and normal priority still decide launch order. |
| D / E | Disabled/dead/uncrewed targets fail reauthorization; an operational survivor returns after last termination and assessment. |
| F | Immobilized firing tank and crewed static weapon remain eligible. Check indeterminate modded/unarmed cases. |
| H | A controlled unexpected/unmatched launch produces a global hold until the actual object terminates and assessment expires. |
| I | Missing Fired capture or ammo consumption exceeding captured objects cannot time out into authorization. Only trustworthy recovery/session replacement resolves missing objects. |
| J | Controlled multi-projectile mode: distinct extras extend the reservation; unaccounted extras hold globally; duplicate event objects do not count twice. |
| K | Cancel/edit/reissue waypoint and preempt during flights; verify isolated sessions, captured targets and ID-guarded public state. |
| L | Native AA, scripted ground missiles, lasers, eight-round gun bursts, acquisition and normal lifecycle remain functional. |

Repeat on a dedicated server/headless owner and with the usual ACE/mod set.
Exceptional remote projectile ownership and unverified ACE reservations can
deliberately serialize missiles via the conservative handoff hold. The engine's
[Fired payload](https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#Fired)
carries no firing-command ID:
association uses the sole open request and existing full event checks. A mod or
external launch perfectly mimicking a pending command is not distinguishable
from that command through the vanilla payload alone. Validate late/extra event
timing with the installed weapons. Indistinguishable untagged events and local
metadata across owner changes remain gameplay-dependent risks; distinguishable
ambiguity is quarantined. No synthetic locking or guidance changes address it.

## Reproducible static verification

Run `python tests/check_heli_overwatch_missile_control.py`
and `git diff --check`. The checker compares unchanged regions against
`f981344` and passed these production-source contracts:

- Balanced SQF delimiters/strings/comments and both console blocks.
- Unchanged guidance, guns, acquisition, aiming/rotation, Phase 1, tiers and
  ranking/retention regions.
- All-projectile termination and absence of missing rounds before assessment;
  deadline, closed acceptance window and resolved quarantine before release.
- No timeout path silently completes live/unknown flights.
- No global flight-completion waits; one serial force-fire path with atomic
  reservation and acknowledgement independent of target preemption.
- Exact target identity, duplicate protection, unique late recovery and extra
  round accounting; ground fallback and ID-guarded public-state/laser handling.

These are structural/static state-machine checks on production source, not an
SQF emulator or an executed engine test. No projectile concurrency, damage,
collision, mod behavior or multiplayer success is claimed from them.

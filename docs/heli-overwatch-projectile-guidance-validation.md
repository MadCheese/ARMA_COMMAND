# Helicopter Overwatch projectile guidance

## Current correction: native ground acquisition and bounded fallback (2026-10-22)

This section supersedes the missile implementation descriptions below. Base:
`dev_branch` at `b8bc47a`. No Arma runtime, SQF compiler, hit-rate measurement or
dedicated-server test was available. Only the two guidance SQF files change
executable behavior; remote launch was inspected and remains unchanged.

### Native decision (Task A)

The existing matched `Fired` projectile receiver now handles both air and ground
targets. It samples `typeOf` of that actual projectile and its inherited
`CfgAmmo`, not the selected weapon's predicted ammunition. Existing claims exit
without reassignment. Loaded ACE plus `ace_missileguidance.enabled = 1` reserves
the projectile for ACE regardless of target type, ACE AI settings or Fired-handler
order. This reservation does not prove ACE actually starts guidance.

Native eligibility still requires a live captured target, configured
`shotMissile` and positive `maneuvrability`. With a SensorsManagerComponent,
IR/visual/active-radar/passive-radar components qualify for object acquisition;
LaserSensorComponent qualifies for designation acquisition. The manager,
including an empty one, supersedes legacy flags. Without a manager, `irLock = 1`
and `laserLock = 1` supply the respective eligibility. Manual control or
`weaponLockSystem` alone supplies neither.

The real target vehicle is tried first when object seeking qualifies. Proxy
objects and laser objects cannot be object candidates. A ground launch can then
try its already retained laser if the ammo advertises laser seeking and that
live LaserTarget is still attached to the captured target. The laser reference
is passed to the existing projectile-owner receiver; no new designation is
created. Each eligible candidate gets at most one ordinary `setMissileTarget`
attempt, without forced-lock syntax. A true return AND exact `missileTarget`
match are required. A laser seeker alone is not proof the command works for that
ammo. A rejected object attempt may be followed by the eligible laser attempt;
an accepted attempt exits the candidate loop.

Accepted native guidance gets the existing `NATIVE` owner marker. Neither native
nor ACE-reserved flights enter the helper, reacquire later or fall back after
lock loss/countermeasures. Otherwise the captured real target enters the shared
scripted helper. Selection, `forceWeaponFire`, firing cadence, gunner controls,
shot matching/counting, reservations, quarantine, assessment and laser lifecycle
are unchanged, including conservative holds for unconfirmed ownership. The
successive-missile symptom is outside this correction.

This follows the documented ordinary-acquisition restrictions in
[setMissileTarget](https://community.bistudio.com/wiki/setMissileTarget?useskin=vector)
and the seeker distinctions in the
[targeting](https://community.bistudio.com/wiki/A3_Targeting_config_reference) and
[sensor](https://community.bistudio.com/wiki/Arma_3_Sensors_config_reference)
references. Sensor eligibility is a configuration heuristic; the command result
and target readback decide acceptance. The conservative ACE boundary follows its
[Fired handler's separate controller](https://github.com/acemod/ACE3/blob/master/addons/missileguidance/functions/fnc_onFired.sqf).

### Scripted corrections (Task B)

The helper retains its atomic local claim, permanent duplicate guard, HitPart
release, unscheduled check/write section, locality rechecks and single scheduled
worker. It adds no remote workers or locality-migration restart. The helper also
rejects an existing native/ACE owner or ACE-configured ammo so other callers
cannot inadvertently start competing A3C guidance. Three-argument callers keep
their existing interface; an optional fourth boolean enables diagnostics.

For each correction, normalize current engine velocity and the target offset.
Measure their angle with a clamped dot product, then rotate along their great
circle by at most `90 * min(actual elapsed simulation seconds, 0.10)` degrees.
The antiparallel case uses a stable perpendicular reference rather than a
singular linear blend. Model facing independently turns toward the corrected
velocity by the same angular bound. Its existing up vector is projected onto the
new facing plane, retaining roll continuity for ordinary engine orientations.
This avoids instantly snapping either velocity or facing to the target.

The worker requests `sleep 0.05` (nominally 20 Hz) and measures actual `time`
differences; it does not assume exact wakeups or replay missed ticks. Ordinary
50 ms updates permit 4.5 degrees of correction. A stalled worker gets at most
9 degrees on resumption and discards the excess turn budget. The immediate first
correction uses one `diag_deltaTime`, capped at 50 ms. Zero-speed launch retries
do not invent speed or accumulate turn debt. Changes at or below 0.05 degrees
skip writes; orientation is written only when facing needs correction. A velocity
write restores the pre-write engine-calculated speed whenever a correction is
made, including when orientation changed.

The original projectile, ammo, shot parents and engine collision/damage remain.
No replacement objects, repositioning, scripted damage, imposed muzzle speed,
lead prediction or new flight profile are introduced. Fixed ASL aim, attached
proxy tracking, OVERFLY's 3.5 m offset, DIRECT's existing terminal window/first
correction, passage release and hit/locality guards remain. Launched shots keep
their captured target when the engagement is canceled or preempted.

Limitations: this bounds A3C's commanded corrections, not the engine's own
acceleration, seeker physics or network interpolation. It still writes velocity
and sometimes orientation on a real projectile; SQF cannot guarantee a smooth
remote render. Reduced frequency alone establishes no MP result. A 90-degree/s
limit can reduce close-range/agile-target hit reliability compared with the old
instant correction. Scheduler stalls reduce available turning authority, and the
initial bounded correction can expose poor launch alignment, especially DIRECT
tank rounds. Unknown third-party controllers without detectable configuration
or A3C ownership markers are not automatically identified. Test actual installed
RHS/CUP/ACE versions; do not relax seeker restrictions to make a test pass.

### Diagnostics and exact runtime checks

Use an otherwise quiet test mission. Name the AI Blackfoot `testBlackFoot` and
one crewed hostile ground vehicle `owGroundTarget`. Start 800-1200 m apart over
open terrain, give the target lateral MOVE waypoints, and use an Overwatch
ARRIVAL / 300-second TIMEOUT waypoint facing its route. Repeat stationary and
moving cases. Enable on the owner (Execute Server for server-local AI):

```sqf
testBlackFoot setVariable ["A3C_OW_Debug", true, true];
A3C_DEBUG = true; // Local flag for shared-helper callers outside Overwatch.
diag_log ["GUIDANCE TEST OWNER", clientOwner, local testBlackFoot, owner testBlackFoot];
A3C_GuidanceTestEH = testBlackFoot addEventHandler ["Fired", {
    params ["_heli", "_weapon", "_muzzle", "_mode", "_ammo", "_mag", "_p"];
    if (toLower getText (configFile >> "CfgAmmo" >> _ammo >> "simulation") != "shotmissile") exitWith {};
    A3C_GuidanceTestProjectile = _p;
    diag_log ["GUIDANCE TEST FIRED", typeOf _p, local _p, owner _p, clientOwner, getShotParents _p];
}];
```

Correlate `projectile matched`, `native acquisition`, `missile guidance decision`
and helper records by projectile/engagement. Decisions include actual ammo,
captured target class, seeker flags, candidate class/result, final owner and
fallback reason. Native acceptance needs `assigned=true`, `accepted=true` and
`owner=NATIVE`; there must be no scripted start for that shot. ACE reservation
must produce neither native assignment nor scripted start. Dispatch alone never
proves receiver execution.

The helper emits one start and one stop record per accepted worker; rejections
log once per rejected call. Stop includes reason, sample count, actual simulation
dt min/mean/max, dt-cap count, velocity/orientation write counts, largest commanded
turns and largest observed aim error. No periodic/frame RPT logging. Max turns
must be <=9 degrees; the first <=4.5. `PROJECTILE_GONE` alone does not prove a hit;
record real target damage, impact location, kill/instigator attribution and misses.

1. **ASRAAM / moving aircraft:** replace the ground target with a crewed hostile
   aircraft at 600-1000 m, about 100 m AGL, on lateral MOVE waypoints. Use Blackfoot
   ASRAAM. Require ordinary object acquisition and no helper when accepted.
   Repeat evasive/CM flights; no later A3C fallback or retargeting is expected.
2. **Scalpel / ground:** restore the ground scenario and use Blackfoot Scalpel.
   Record the actual ammo class and sensor config. Require the object attempt
   first if its ammo advertises an object seeker. If rejected or absent, a valid
   laser seeker must attempt the retained designation. Only accepted/readback-
   verified targeting gets `NATIVE`. Rejection must explain fallback. Check moving
   as well as cold stationary vehicles; do not force or heat a target to mask a
   normal acquisition rejection. Compare damage and hit counts with the base.
3. **RHS/CUP/ACE:** repeat with installed ammo representing object seekers, laser
   seekers, legacy lock flags, empty modern sensor managers and manual-only
   guidance. Record actual class/config and observed decision per case; no class
   allowlist is assumed. Test with ACE absent and present, then its AI guidance
   enabled and disabled. Enabled ACE ammo stays reserved in both settings;
   guidance can be inactive when ACE declines it. Non-ACE ammo can still use
   native/fallback with ACE loaded.
4. **Scripted moving-ground fallback:** use an installed non-ACE round whose
   decision actually reports unsupported/rejected native acquisition. Do not
   assume a specific mod class always falls back. Use the same route/ranges and
   verify a single helper start, actual writes, terminal stop, original shot
   parents and real impacts. Repeat at close launch range and under ordinary
   server load. Run at least ten comparable shots per baseline/new condition;
   log hits/launches, range, target speed and misses, not only selected successes.
5. **Dedicated/remote visual:** run these cases with all AI server-owned and a
   separate remote player observing, without taking a helicopter seat. Require
   the server Fired record to say projectile local/owner=server; keep server and
   client RPTs and simultaneous observer video. Watch launch, turns and terminal
   impact for flips/tumbling/corrections that differ from server flight. Repeat
   under representative low server FPS/latency, record dt maxima/caps, and compare
   hit reliability with the baseline under the same conditions. Repeat with an
   HC owner if used. A lower write count is not a visual-stability pass.
6. **Duplicates/release/destruction:** during a long scripted flight, on its
   recorded owner run the block below after its helper start. Both calls must log
   `ALREADY_CLAIMED`, with no second start. On a fresh launch, delete the captured
   projectile from the debug console (`deleteVehicle A3C_GuidanceTestProjectile`);
   require `PROJECTILE_GONE` and no more writes. Let another shot impact normally;
   expect `HIT_OR_RELEASED` if HitPart is observed, otherwise projectile loss.
   After a release, repeated calls must never reclaim that projectile.

   ```sqf
   private _p = missionNamespace getVariable ["A3C_GuidanceTestProjectile", objNull];
   [_p, owGroundTarget, "MISSILE", true] call A3C_ai_shared_fnc_guideProjectileMissile;
   [_p, owGroundTarget, "MISSILE", true] call A3C_ai_shared_fnc_guideProjectileMissile;
   ```

7. **Locality:** from a remote observer, calling that helper with a nonlocal
   projectile must log `NOT_LOCAL`, without a worker or trajectory writes. For a
   real migration, start a long-range fallback from a client/HC owner, then
   disconnect that owner while the projectile is alive and check the surviving
   server's ownership. Alternatively, where the ammo/engine permits it, request
   transfer of the captured projectile from the server using `setOwner`, and
   verify that `owner` actually changed before recording a pass. A surviving old
   worker must stop with `LOCALITY_LOST`, and the helper never dispatches or
   restarts on the new owner. Shooter ownership transfer alone does not prove
   projectile migration; unsupported transfer/despawn leaves this case unverified.
8. **Cancellation / regression:** delete the Overwatch waypoint or introduce a
   higher-priority threat during native and scripted flights. No new aim target
   may be assigned to the old shot, and flight reservations/lasers must remain
   until existing cleanup conditions. Recheck eight-round cannon engagements.
   Also repeat remote-launch MISSILE, OVERFLY (where offered) and plain-rocket
   fixed-ASL orders against stationary and moving vehicles, plus DIRECT tank
   shots at 50-200 m and normal range. Check the overfly height, frozen aim point,
   immediate close correction/handoff, impact attribution and zero-speed launch
   retry. Repeat all core scenarios in SP, including pause/resume and time
   acceleration; no accumulated wall-clock turn should occur after a pause.

Remove the temporary test Fired handler on its owner and disable debug afterward:

```sqf
testBlackFoot removeEventHandler ["Fired", A3C_GuidanceTestEH];
testBlackFoot setVariable ["A3C_OW_Debug", false, true];
A3C_DEBUG = false;
```

Static validation: `python -B tests/check_projectile_guidance.py` checks SQF
delimiters, exact Overwatch boundaries against `b8bc47a`, unchanged remote launch,
ownership/aim/handoff contracts and 14,028 independent double-precision steering
property cases. It does not execute SQF or establish engine float precision or
network behavior. `git diff --check` is also required. The existing
`check_heli_overwatch_missile_control.py` and `check_heli_overwatch_threats.py`
already fail their historical selector comparisons on the untouched base; those
unrelated tests are unchanged.

## Historical implementation notes

Source review only. No Arma gameplay or multiplayer hit-accuracy test has been
performed. Implementation starts from `dev_branch` at
`824b80261b65dbc19c97a698bb9a173076686136`.

## Implementation and ownership

The existing session-owned `Fired` handler still matches weapon, muzzle,
magazine, mode, operator, turret path/locality and ammunition simulation before
acknowledging/counting a shot. Every matched `GUN` event enters cannon guidance,
including unexpected extra rounds; guidance never issues a firing command.
The controller's eight-round limits and extra-event mode quarantine are unchanged.

The suppression bullet helper was assessed with its explicit
`[handlerId, target, operator, weapon, token]` snapshot. Its target snapshot is
suitable, but its base-position aim, scheduled deletion/replacement and lack of
replacement shot-parent restoration are unsuitable here. Shared functions are
unchanged. Overwatch uses the same velocity-to-target calculation on the original
projectile, immediately inside `Fired`, with `aimPos` in ASL and orthogonalized
orientation. Each correction preserves current engine speed rather than restoring
muzzle speed. Ammo class, shot parents, lifetime, penetration and explosive damage
remain properties of the real shot; there is no scripted damage or replacement.

A cannon worker receives only the original projectile, captured target object,
deadline, correction code and diagnostic scalars. It follows that object's aim
position, never a future session target. It stops on projectile death/deletion,
locality loss, target death/deletion, invalid position/speed, target passage,
terminal handoff or deadline. The deadline uses configured ammo lifetime capped
at 30 seconds (0.1-second fallback for missing/nonpositive lifetime). There are no
new event handlers. Terminal handoff gives the engine the final impact; guidance
does not intentionally steer a projectile back after passing its target.

The missile's one-second delay is removed. For ground targets, the existing helper is called
unscheduled immediately with the captured real target and `"MISSILE"` policy.
It already claims the local projectile atomically, prevents duplicate workers,
performs an initial correction when velocity exists, and retries zero launch
velocity in its own worker. A nonlocal missile is dispatched to its projectile's
owner with an unscheduled receiver, which checks locality again. No session or
request references are sent. Flight-slot bookkeeping and actual missile
confirmation remain separate from cannon guidance and continue after preemption.

## Requested source scenarios

| Scenario | Source verification and remaining engine check |
| --- | --- |
| 1. Blackfoot cannon, infantry, eight rounds | Original live-ammo readiness and `forceWeaponFire` path still request at most eight one-round discharges. `shotBullet` and `shotShell` events qualify. Confirm actual eight discharges in game. |
| 2. Guidance for all eight actual projectiles | Accounting increments before the `GUN` branch; each matching event calls the immediate correction and may spawn its own bounded worker. No first-round-only gate in that branch. Confirm eight start logs and impacts. |
| 3. MANPADS infantry preempts tank | Unchanged selector prioritizes live AA threats and higher tiers preempt at evaluation. Existing engagement guards stop issuing old requests. |
| 4. Previous-target bullets retain ownership | Every worker receives `_shotTarget` captured from the matched request, with no session/request/selected-target lookup. Already launched missiles retain the same captured-object ownership. |
| 5. Gun versus ground vehicle without missiles | Unchanged selector offers compatible guns for ground vehicles when a compatible missile option is unavailable. Same matched gun guidance path applies. |
| 6. Missile/cannon separation | Gun branch exits before all missile slot, projectile-list, handoff and helper operations. Ground missiles and non-ACE air missiles without a verified native lock still receive `"MISSILE"`; native air flights bypass the helper. |
| 7. Short-distance missiles | No one-second scheduled gap. Local helper attempts its first correction inside `Fired`; zero-speed launch is retried by the helper. Engine launch/mod compatibility and actual close hits remain unverified. |
| 8. Waypoint deletion during gun burst | Existing validity checks, request invalidation, worker termination and exact Fired-handler removal stop new commands. Captured cannon workers finish independently or stop at their shot/target/deadline guards. |
| 9. Waypoint deletion with missile in flight | Initial guidance has already been attempted; existing helper owns only the projectile/target and does not depend on the session. Release does not delete the shot or retarget it. |
| 10. Repeated cannon engagements | No additional persistent handlers or controllers. At most one claimed cannon worker per projectile; each has explicit termination/deadline guards and retains no session references. Profile scheduler load in game. |

## Optional diagnostics and runtime follow-up

Enable the existing diagnostic flag on the AI/turret-owning machine:

```sqf
A3C_OW_TestHeli setVariable ["A3C_OW_Debug", true];
```

RPT messages distinguish raw `projectile fired`, `projectile matched` with
engagement/round/target, cannon correction execution or failure, and worker end
reason. Missile receiver logs distinguish a completed helper initial correction,
ownership while awaiting launch velocity, duplicate ownership, immediate release
and inability to start. A remote `dispatched` message explicitly does not confirm
receiver execution. Existing three-second handoff diagnostics check helper
ownership or the native/ACE reservation marker for locally observable missiles.
An ACE reservation acknowledges handling, not successful ACE activation.
A zero-speed ownership message does
not establish that a later correction actually ran.

The cannon start message confirms trajectory commands executed, not a successful
hit. Low FPS/scheduler pressure can delay later corrections. Moving targets,
terminal ballistic flight, cover, engine collision behavior and other mods can
still affect hits. Cannon correction requires projectile locality; locality loss
ends its worker rather than writing remotely. The exceptional missile route
requires a network-resolvable projectile and permission for `bis_fnc_call` in the
server's remote-execution settings; a dispatched message alone is insufficient.
Dedicated-server/headless-client ownership and remote visual synchronization
require runtime testing. Inspect impact attribution with `getShotParents` and
Killed/HandleDamage observations during those tests.

Static checks: full patch review, `git diff --check`, string/comment-aware SQF
delimiter checks and comparison against HEAD to ensure every source change is
inside the existing Fired handler. These are not an SQF engine/compiler test.

## Native guidance for AIR missile engagements (2026-10-18)

This follow-up starts from clean `dev_branch` at `b7eee92`. The only executable
changes are in `_startGuidance` inside the existing Overwatch `Fired` handler and
the existing three-second handoff diagnostic's ownership check. No engine test
has been performed for this follow-up.

After the existing live-projectile, captured-target and projectile-locality
checks, AIR targets use the actual projectile's `typeOf` / `CfgAmmo`. Native
eligibility requires `shotMissile`, positive `maneuvrability`, a live aircraft,
no existing guidance claim, and an object seeker: IR, visual, active radar or
passive radar. An existing `SensorsManagerComponent` supersedes legacy lock
flags, including an empty manager; only ammunition without that manager may
qualify through `irLock = 1`. Missile ancestry, `weaponLockSystem`, laser/NV
seeking and manual control alone do not qualify. The existing weapon/ammunition
classification and compatibility decisions are unchanged.

Eligible ammunition receives exactly one ordinary
`_projectile setMissileTarget _target` call, on the local projectile. Both a
`true` command result and `missileTarget _projectile isEqualTo _target` are
required for acceptance. This follows the object-seeker/configuration and
verification principles in remote launch, without copying its forced target
syntax. The [Bohemia command reference](https://community.bistudio.com/wiki/setMissileTarget?useskin=vector)
documents that ordinary acquisition can fail and requires the target inside
the configured targeting cone; this change never forces acquisition.

On success, the projectile receives a local
`A3C_OW_MissileGuidanceOwner = "NATIVE"` acknowledgement and exits before the
shared helper. It receives no A3C trajectory corrections, lock retries or
later fallback, including after countermeasures or loss of native lock. The
engine owns the rest of the flight. This does not guarantee a hit.

For unsupported or rejected native targeting on non-ACE ammunition, control
falls through immediately to the exact existing
`[_projectile,_target,"MISSILE"] call A3C_ai_shared_fnc_guideProjectileMissile`.
The helper and its calculations, launch-velocity handling, duplicate guard,
locality-loss release and diagnostics are unchanged. A missing helper is
reported and no worker is created. An already claimed AIR projectile is left
with its existing owner; it is never reacquired or given another worker.

### ACE boundary

If ACE is loaded (patch/function evidence) and this actual ammunition has
`ace_missileguidance.enabled = 1`, both native assignment and A3C scripted
steering are skipped. The local owner marker is `ACE_RESERVED`, and the log
explicitly says activation is unverified. Merely loading ACE does not exclude
ordinary native-seeker ammunition that lacks enabled ACE guidance.

This is a conservative reservation, not an ACE integration or proof of active
guidance. [ACE's Fired handler](https://github.com/acemod/ACE3/blob/master/addons/missileguidance/functions/fnc_onFired.sqf)
can independently start a per-frame controller, subject to its setting, AI and
explicit ammo-config checks. Overwatch does not call its internal functions,
alter its settings, assign ACE target variables or stop its controller. The
reservation deliberately includes inherited enabled configs and disabled/AI-off
settings to avoid assuming ownership from Fired-handler order or a setting
snapshot. Consequently, ACE-configured rounds may have no active guidance when
ACE declines to start. Test the installed ACE/mod version in game; resolving
that limitation is deferred. Other mods' independent guidance systems are not
automatically detectable by this change.

### Preserved behavior and runtime checks

The captured `_shotTarget`, engagement ID, matched real projectile, event
filtering and local/remote dispatch arguments are unchanged. The remote receiver
still validates actual projectile locality and runs unscheduled. A native or
ACE reservation marker only acknowledges the guidance-start path; it never
releases the launch slot. The existing projectile list holds that slot until
the actual projectile expires. No polling, extra worker, new EH, target refresh
or generic locality system is introduced.

Ground missile/laser behavior, all cannon guidance and eight-round firing,
target discovery/ranking/retention/preemption, helicopter flight, AI feature
management and waypoint lifecycle remain unchanged. Shared missile guidance,
remote AT launching and all other callers are untouched. Projectiles are not
replaced, repositioned or given different damage, speed or shot parents by the
native path.

With `A3C_OW_Debug`, one `A3C OW AA missile guidance` record per start attempt
reports engagement, captured target, projectile, actual ammo, native
applicability/attempt, command result, verified target, owner and reason.
`SCRIPTED_FALLBACK_REQUESTED` is followed by the existing helper status log;
only that latter log establishes whether the helper claimed/started/released.
Dead/missing/nonlocal projectile failures remain explicit start-failure logs.

Use the mission's `testBlackFoot` Blackfoot for the following test:

1. Restart Eden preview with updated files. Keep its AI pilot/gunner and a
   supported AA missile loadout. Put a crewed hostile helicopter in clear LOS,
   initially 600-1000 m ahead and about 100 m AGL. Give the enemy lateral MOVE
   waypoints so it is moving across the Blackfoot's nose at launch. Exclude
   competing enemies for this first case.
2. On the machine owning the Blackfoot AI/turret, run:

   ```sqf
   testBlackFoot setVariable ["A3C_OW_Debug", true];
   ```

   Issue the usual A3C Helicopter Overwatch waypoint facing the enemy route,
   with an ARRIVAL precondition and a long TIMEOUT postcondition (e.g. 300 s).
3. In RPT, correlate `projectile matched` and `AA missile guidance` by engagement
   and projectile. A native flight must show `nativeApplicable=true`,
   `attempted=true`, `setMissileTarget=true`, the captured aircraft in
   `missileTarget`, and `owner=NATIVE`. It must have no helper-start log for that
   projectile and no false three-second handoff warning while it remains local.
   Observe turns/interception against the moving helicopter, actual ammo
   consumption, impact/damage and attribution. Record misses as well as hits.
4. Repeat with enemy countermeasures/evasive movement. A successful initial
   native lock must never trigger later A3C reacquisition or scripted fallback.
   Repeat with a compatible modded AA missile that lacks an object seeker, or
   a launch where ordinary acquisition is rejected. Expect the stated reason,
   `SCRIPTED_FALLBACK_REQUESTED` and the unchanged helper status log. Do not
   force acquisition, move the projectile or change config just to obtain a hit.
5. While a native missile is still alive, introduce a higher-priority target or
   cancel the waypoint. Confirm the launched missile is never assigned the new
   target, a replacement launch waits for real projectile expiry while the
   session remains active, and normal waypoint cleanup/departure still occurs.
6. Recheck stationary-ground missile/temporary-laser engagements and an
   eight-round cannon engagement. Repeat AIR cases with the usual ACE/mod set;
   enabled ACE ammo must report `ACE_RESERVED` with no A3C helper or native
   assignment. Check whether ACE actually steers it with AI guidance enabled
   and disabled, recording the conservative limitation above.
7. Repeat on a dedicated server and, if used, a headless-client AI owner. Inspect
   the projectile owner's RPT for actual execution, not just the helicopter
   owner's dispatch log. Exercise any real ownership handoff. Existing fallback
   guidance stops on locality loss; this patch adds no migration/restart worker.
   Native flight across locality changes, mod EH timing, ordinary acquisition
   at Fired time and the installed missiles' turning/CM behavior require engine
   validation. Disable the flag afterward with the same block using `false`.

Static validation for this follow-up: `git diff --check`, comment/string-aware
SQF delimiter checks, and exact comparison against HEAD outside the guidance
receiver and its one diagnostic ownership predicate. Review confirms no added
trajectory writes, workers or event handlers, and no changes to the shared
helper or remote-launch function. No SQF compiler, Arma runtime, hit-accuracy or
dedicated-server result is claimed. No commit or push was performed.

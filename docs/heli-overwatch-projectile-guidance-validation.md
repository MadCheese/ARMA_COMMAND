# Helicopter Overwatch projectile guidance

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

The missile's one-second delay is removed. The existing helper is called
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
| 6. Missile/cannon separation | Gun branch exits before all missile slot, projectile-list, handoff and helper operations. Missile helper still receives `"MISSILE"` for ground and air targets. |
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
receiver execution. Existing three-second handoff diagnostics still check helper
ownership for locally observable missiles. A zero-speed ownership message does
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

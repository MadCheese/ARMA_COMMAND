# TANKSHOT completion reporting and recovery

## Scope and validation status

This change builds on the uncommitted first-shot aiming and preliminary obstruction changes. It adds lifecycle reporting and recovery; it does not change shell classification/preference, physical loading, turret aiming criteria, obstruction classification/ranking, `UseMagazine`, projectile matching, or DIRECT guidance. The existing infantry AT, UGL, static and artillery switch bodies are unchanged. `fnc_setTankShotActive` and `fnc_structureRemoteLaunchUiResponse` were audited and remain unchanged.

Source validation passed: delimiter/string checks, function registration, reason-message coverage, timeout arithmetic, and comparison of protected firing/selection blocks against the task-start working tree. `git diff --check` passed. No SQF compiler or running-game test harness was available. **The runtime cases below are pending; source checks do not establish engine or multiplayer correctness.**

## Protocol and state ownership

1. `structureRemoteLaunch` retains one ranked shooter per selected group. `findBestShooters` optionally returns selection reasons without changing its result or score. A group excluded by the existing hard-blocker check gets `HARD_OBSTRUCTION`; a group with no live candidate gets `NO_SHOOTER`. Each failing tank group is identified once on the commanding client. Empty TANKSHOT candidate lists also report `NO_SHOOTER`.
2. Tank dispatch registers an ID, commanding client ID and group/shooter label with the server. FIND selections resolved to TANKSHOT use the same path. Explicit/direct TANKSHOT calls through `orderRemoteLaunch` reach the helper before the generic silent guards. Existing calls without context register themselves before claiming state.
3. `manageTankShot` serializes registry transitions in an unscheduled block. Only its first terminal transition is accepted. Each dispatched order becomes FIRED, FAILED with a stable reason, or CANCELLED. FIRED requires the existing matching FiredMan event and a non-null projectile, not a cleared remote-firing flag.
4. `executeTankShot` saves recovery metadata before reservation mutations, after proxy creation and after handler installation. The metadata is also replicated on the gunner under a token-specific key. The public two-element `A3C_TANK_SHOT`, five-element `A3C_REMOTE_HANDLE` and four-element infantry `A3C_AT_SHOT` layouts remain unchanged.
5. A local observer detects unexpected worker completion or a stalled worker. An independent server watchdog covers owner disconnection, destruction, crew changes and execution timeout. After claim, execution is not restarted on a new owner: only recovery moves to that owner.
6. `recoverTankShot` removes only this token's locally registered handler on its installing machine, clears its capture/receipt state, terminates its stalled worker, and deletes its unfired proxy. Its separate OWNER phase clears temporary watch/target/look control, restores saved AUTOTARGET, and releases only matching unit/tank reservations and handles. The server uses the existing token-guarded active-list delta helper after acknowledgment.
7. `reportTankShot` stores one terminal receipt and emits at most one failure chat per order to the original commander. Both installer capture cleanup and owner reservation release must be acknowledged; together they upgrade that receipt without another chat. The UI waits for both result and cleanup; it never interprets a remote-firing flag as tank-shot success. Successful shots produce debug receipts without extra success chat.

The existing fired-projectile lifetime worker stays intact. Captured proxies survive unit recovery; the server also cleans them after the known projectile ends, covering installer disconnection. Delayed CLAIM messages recover their own resources without changing an already terminal outcome. Local handler ownership is removed from a map once, so a retry cannot remove a subsequently reused EH ID. Newer unit/tank tokens prevent old recovery from overwriting new orders.

## Bounds and diagnostics

- Existing physical reload maximum: 60 seconds. Existing aim/settle allowance: 10 + 3 seconds. Existing projectile capture window: 3 seconds. Total existing wait maximum: 76 seconds, plus configuration/preparation work.
- Server dispatch allowance: 100 seconds; first claim starts a fresh 100-second execution allowance. Later preparation checkpoints do not extend it.
- Local observer: 105 seconds from worker creation. Pre-claim forwarding remains limited to two hops.
- Commander UI: 220 seconds, accommodating dispatch plus execution/observer and result delivery. Expiration requests emergency completion/recovery for pending tank receipts and always returns UI control. Other firing mechanics retain their existing execution; only the shared UI wait gains a bound.
- Server watchdog samples once per second. Unacknowledged installer/owner recovery retries every two seconds. A disconnected installer is considered clean because its local handlers no longer exist; `allPlayers` includes headless clients, as documented in [Arma 3 Headless Client](https://community.bistudio.com/wiki/Arma_3_Headless_Client). Pending recovery logs every 30 seconds. Terminal registry entries remain at least 120 seconds for late-message deduplication; old client receipts are pruned on subsequent results after 360 seconds.
- These bounds use mission `time`, matching the existing reload/aim waits. Pausing mission simulation also pauses these deadlines.

Set `missionNamespace setVariable ["A3C_DEBUG", true, true]` before ordering shots. Correlate commander, owner and server RPTs by the TANKSHOT ID. Expected trace: selection accepted/rejected, dispatched, claim/checkpoint, existing targeting/reload progress, terminal outcome/reason, cleanup started, cleanup completed, reservation released, result and cleanup receipts delivered. Pre-dispatch rejections have local selection/result traces and never claim state. A dispatched ID without terminal or cleanup acknowledgment identifies an unfinished lifecycle.

## Failure reasons

| Code | Evidence / meaning |
| --- | --- |
| HARD_OBSTRUCTION | Existing shooter-selection direct ray found a confirmed hard blocker |
| NO_SHOOTER | No eligible candidate in the selected tank group/list |
| BUSY / SUPPRESSING | Existing gunner/tank reservation, other remote operation, or suppression |
| UNAVAILABLE | Unit is not available in a valid primary gunner turret |
| NO_CANNON | Existing cannon selection cannot establish a safe compatible cannon |
| NO_AMMO | No usable shell stock and no usable loaded round |
| AMMO_MAPPING / AMMO_CHANGED | Muzzle/loaded-instance identification ambiguous, or final magazine changed |
| AIM_TIMEOUT / AIM_LOST | Existing turret alignment/settle check failed; **does not imply obstruction** |
| RELOAD_TIMEOUT / NOT_READY | No physically ready shell after the reload budget, active magazine phase, or final readiness changed |
| NO_PROJECTILE | Firing action had no matching non-null projectile within the capture window, including a matching FiredMan event with a null projectile |
| CANCELLED | Owned remote-firing/reservation state was cancelled before confirmed capture |
| DESTROYED / CREW_CHANGED / LOCALITY_CHANGED | Unit/tank died, gunner left the turret, or execution ownership changed |
| DISPATCH_TIMEOUT / EXECUTION_TIMEOUT | Owner delivery or execution exceeded its independent deadline |
| UNEXPECTED | Worker stopped without completing its normal result path or invalid execution state |

## Runtime acceptance matrix — pending

For each case, capture all relevant RPTs, record the token/result/reason, confirm at most one commander failure message, and verify cleanup before ordering a subsequent shot. After a failed order, a live usable tank must accept a fresh order with a new token.

| Case | Expected outcome / feedback | Required recovery observation |
| --- | --- | --- |
| 1. Fresh first positional shot | FIRED after matching non-null FiredMan capture; no failure chat | Reservation released before impact; fired proxy remains until projectile ends |
| 2. Target behind terrain | Pre-dispatch HARD_OBSTRUCTION with group label | No dispatch, proxy, handler or reservation; next clear shot accepted |
| 3. Turret cannot align | FAILED AIM_TIMEOUT/AIM_LOST, never an obstruction message | Watch/target/look cleared, original AUTOTARGET restored, next attainable shot accepted |
| 4. AP loaded, positional target, HE stocked | Existing physical HE reload then FIRED | Same load and firing sequence; clean token/list/handle release |
| 5. Interrupt/reject/stall a stocked HE reload | FAILED RELOAD_TIMEOUT unless the unchanged ready fallback succeeds | No readiness bypass; unfired proxy and handler removed; subsequent usable shot accepted |
| 6. Action produces no projectile | FAILED NO_PROJECTILE after the existing capture window | Capture closed; no retry; next order accepted. Include a null-projectile matching event if reproducible |
| 7. Destroy tank/gunner during preparation | FAILED DESTROYED | Both reservations, active entry, handles and unfired proxy released; no later fire. Repeat with revive/usable replacement |
| 8. Repeat immediately after a failed order completes cleanup | New order accepted with a new ID | Old retries cannot alter the new token, handle, AI or target |
| 9. Several tank groups, including one blocked/failing group | One selected shooter per group; failing group identified once | Concurrent active-list deltas leave no completed tank reserved; successful groups still fire |
| 10. Transfer gunner group ownership during preparation | FAILED LOCALITY_CHANGED | Old-machine handler removed; current owner restores AI; new order accepted after migration stabilizes |
| Owner disconnect | Server watchdog finishes/retries on the reassigned owner | No dependence on disconnected machine for tank release; next owner accepts a shot |
| Commander disconnect | Execution still reaches server terminal state and recovery | Server releases tank; delivery to a disconnected commander cannot be guaranteed |
| Cancel during aim/reload | CANCELLED once | No delayed firing; original AUTOTARGET and all owned state restored |
| Busy / suppressing / no cannon / empty ammunition | Distinct BUSY, SUPPRESSING, NO_CANNON or NO_AMMO | Pre-claim rejection owns no state, or claimed failure cleans it; usable next shot accepted |
| Unexpected worker termination | FAILED UNEXPECTED, or FIRED if projectile was already confirmed | Observer/watchdog cleans token-owned resources without touching another order |
| Dedicated server, client-local gunner and split driver ownership | Same results delivered to original commanding client | Handler removal stays on installer; AI recovery follows gunner, not driver |

Inspect the following after cleanup on the server and gunner owner:

```sqf
private _unit = gunner cursorObject; // Retain the original unit reference for crew-loss cases.
private _tank = vehicle _unit;
diag_log ["TANKSHOT RECOVERY PROBE", _unit, _tank,
    _unit getVariable ["A3C_TANK_SHOT_TOKEN", ""],
    _tank getVariable ["A3C_TANK_SHOT", []],
    _unit getVariable ["A3C_unit_is_Remote_Firing", false],
    _unit in A3C_REMFIRE_UNITS_ACTIVE,
    _unit getVariable ["A3C_REMOTE_HANDLE", []],
    _tank getVariable ["A3C_REMOTE_HANDLE", []],
    _unit getVariable ["A3C_TANK_SHOT_CAPTURE", []],
    _unit checkAIFeature "AUTOTARGET"];
```

## Limits of recovery

Recovery requires a running server, a responsive machine that owns the gunner, and a responsive installer if it remains connected. If ownership never stabilizes or that machine cannot execute remote calls, the server records/delivers a terminal outcome and continues retrying, but deliberately does not release the gunner token before local AI restoration is acknowledged. This condition logs `recovery pending`; a safe unconditional guarantee is not possible under permanent communication/execution failure. A mission overriding the addon's permissive CfgRemoteExec must allow the three new lifecycle functions as well as the existing BIS spawn dispatch.

If a captured projectile is unavailable on the server and its installing client disconnects before the existing flight cleanup completes, the server cannot safely infer when to delete that fired proxy. It leaves flight ownership intact and logs that installer cleanup is required. No attempt is made to change targeting or guidance to resolve this case. Likewise, an engine projectile/event arriving after the retained three-second capture window is outside confirmed success; this milestone keeps that firing window unchanged.

The normal UI entry explicitly preserves commander identity. Legacy callers that invoke the helper without context infer it from the current remote execution or local client; callers that already lost the originating identity must pass it explicitly. Feedback cannot be delivered to a disconnected commanding client, although server completion and recovery continue.

Cancellation through the existing remote-firing flag retains token ownership and is recoverable. If unrelated code strips both reservation markers before recovery, ownership of temporary AI control cannot be established safely; recovery cannot reconstruct that lost ownership or safely overwrite an intervening order. Such external state changes must use the lifecycle recovery path instead.

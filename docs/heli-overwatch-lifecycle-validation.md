# Helicopter Overwatch lifecycle and local validation

Implemented on the local `dev_branch`; no commit or push. Source checks only.
Restart the mission so XEH compiles the new helper and updated movement functions.
Run these console blocks with **LOCAL EXEC on the machine owning the AI group,
pilot and helicopter**. A client console cannot inspect a server's local session.
Use an AI pilot and AI gunner. Keep this development switch off for normal play:
the existing gun `doFire` path can be suppressed when FIREWEAPON is disabled.

## Changes and state machine

| File | Change |
|---|---|
| `A3C_CORE/waypointScripts/wpScript_heli_overwatch.sqf` | Begin ownership before movement reset; cancellation checks; altitude admission; owned worker/EH/laser registration; release before departure. |
| `A3C_CORE/main/functions/fnc_heliOverwatchLifecycle.sqf` | Local run/session ownership, phase transitions, independent EachFrame cleanup, exact Boolean restoration and diagnostics. |
| `A3C_CORE/main/functions/XEH_PREP.hpp` | Register lifecycle helper; keep existing Milestone 2A registrations. |
| `A3C_CORE/ai_highCommand/functions/fnc_reInitGroupMovement.sqf` | Optional helicopter PATH preservation; release a previous Overwatch session before an ordinary movement reset. |
| `A3C_CORE/ai_highCommand/functions/fnc_addWaypoint.sqf` | Preserve pre-disabled Overwatch-eligible attack-helicopter PATH during first-waypoint reinitialization, before Overwatch can capture it. Transport helicopters and other vehicle classes retain their existing reset behavior. |
| `A3C_CORE/ai_highCommand/functions/fnc_moveGroupToPosition.sqf` | Optional run identity rejects queued obsolete Overwatch travel orders; local movement callback cleans up an invalid session before movement. |
| `A3C_CORE/ai_highCommand/functions/fnc_removeWaypoint.sqf` | Clean up an invalid Overwatch run after deletion, before onward movement. |
| `A3C_CORE/ai_highCommand/functions/fnc_deleteAllWaypoints.sqf` | Release before deleting/resetting waypoints and issuing standby movement. |
| `docs/validation/check_heli_overwatch_lifecycle.py` | Repeatable source contracts and delimiter checks, including the SQF console blocks in this document. |
| This document | Lifecycle explanation and complete local test blocks A–J. |

Existing uncommitted Milestone 2A ammo/ranking helpers and its validation document
remain in the working tree. They are not part of this lifecycle change.

| Phase | Vehicle PATH | Vehicle FIREWEAPON |
|---|---|---|
| A: TRAVEL | Temporarily enabled, saved original retained | Original, untouched |
| A: BRAKING | Temporarily disabled during existing velocity taper | Original, untouched |
| A: ROTATION | Enabled; original rotation helper retained | Original, untouched |
| A: ALTITUDE | Disabled; existing ±7 m/s adjustment and 20 m tolerance | Original, untouched |
| B: ACTIVE | Disabled for hovering | Disabled only if local development switch was enabled at session creation |
| C: RELEASED | Restore saved Boolean | Restore saved Boolean if the override was acquired; otherwise untouched |

The braking routine no longer disables/enables `ALL` on vehicle or pilot. This
prevents it from enabling previously disabled unrelated features or suppressing
FIREWEAPON during phase A. There is no new pilot PATH override. The existing
CARELESS behavior, manual braking velocity taper, rotation algorithm, ammo
handling, ranking, sector preference, MANPADS classifier, gun command arguments
and missile guidance algorithm are retained. Flight/braking behavior needs the
in-game tests below.

## Ownership, cleanup and audit

Each invocation uses a local `[clientOwner, monotonicSerial]` run identity. Every
helicopter has its own `A3C_OW_Session`, saved PATH/FIREWEAPON, phase, owned handles,
monitor and laser list. Before any movement reset, begin synchronously releases
the older group run and any older session on that vehicle, then captures the
restored original values. PATH ownership starts with travel. FIREWEAPON ownership
starts only at successful ACTIVE admission, with an independent ATL-height check.
The development switch is captured for that session; change it before starting.

Cleanup marks the session released, stops its spawned worker/rotation/delayed
Fired workers, removes its own Fired handler, disposes of its lasers, and restores
owned features with `enableAIFeature [feature, savedBoolean]`. Public compatibility
variables are cleared only by the current local vehicle owner. The monitor removes
its namespace entry and its own EachFrame handler. Normal completion releases all
helicopters before the first departure order and the three-second delay.

EachFrame performs identity, actor/locality, waypoint and completion checks only.
It compares exact script text, statements, formation, speed, behavior, combat mode
and timeout, name/UID, description and completion radius, plus waypoint
type/current index/existence and position (>1 m in 2D).
Thus changing direction, height, conditions or formation at the same position
invalidates the old run. It also notices worker termination, hover release and
normal postcondition completion. No enemy search or firing runs each frame.

The monitor survives termination of the scheduled waypoint scope. Structural
changes are handled on the next EachFrame, independently of pending missile or
rotation waits. When a real main script handle is available, `scriptDone` also
detects termination. Some engine waypoint contexts lack `_thisScript`; this is
reported in [Bohemia issue T183544](https://feedback.bistudio.com/T183544).
For unchanged-waypoint termination without a usable handle, only the main script
renews a mission-time heartbeat; its expiry releases the session after **10 mission
seconds**. Workers never renew it. This fallback is bounded, not instantaneous.
Severe scheduler starvation can also trigger this fail-safe expiry.

Mutation blocks recheck ownership atomically. Handover terminates the exact old
worker handles before a new session is installed. Fired callbacks require their
own handler ID; delayed callbacks carry their originating session and engagement
identity. Rotation is called inside its tracked wrapper handle. Missile waits
poll cancellation; cleanup does not depend on their returning. Already launched
projectiles are not deleted, and already dispatched guidance retains its existing
algorithm. A cancelled session's laser is removed. Delayed departure/follow/AWARE
orders also check the run identity to avoid changing a replacement run.

Audited the complete current local Overwatch, Repair and polygon action loop,
movement reinitialization/approach/movement helpers, rotation and guidance helpers,
single/multi waypoint confirmation, map waypoint move/delete paths, waypoint
statement/data setters, add/remove/delete helpers, action insertion and group
refresh. Repair's run/EachFrame/owned-handler pattern informed the independent
monitor; suppression's saved-feature ownership informed restoration. Their combat
and animation code is unchanged. Overwatch freeze writes are confined to the
owned rotation-entry block and lifecycle release. Map/dashboard readers remain
unchanged. The precondition retrigger now releases the run before changing its own
script and exits rather than continuing as an obsolete invocation.

## Development setup and inspection

Exact switch, before starting the waypoint:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v}) exitWith {hint "testBlackFoot must exist and be local";};
_v setVariable ["A3C_OW_DevExclusiveFire", true];
_v setVariable ["A3C_OW_LifecycleDebug", true];
hint "Lifecycle testing enabled for the NEXT Overwatch session";
```

Standalone inspector; repeat in every phase and after every action:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v) exitWith {hint "testBlackFoot does not exist";};
private _state = ["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle;
hint str _state;
diag_log ["A3C OW manual inspection", _state];
```

`inspect` contains only concise data, so it is safe to stringify. Use it instead of
dumping raw session/run maps, which also contain script code and internal resources.
The run stores vehicle references rather than session maps, avoiding a cyclic
HashMap structure. `lastRelease` is:
`[runID, reason, savedPATH, savedFIREWEAPON, actualPATH, actualFIREWEAPON, restoreLocal]`.
After cleanup, phase is RELEASED, runID is empty, ownership is false, monitor=-1
and monitorCount=0. The last-release array retains the restoration evidence.
Lifecycle diagnostics are separate from `A3C_OW_Debug` / `A3C_OW_Ranking`.

Disable development mode for future sessions:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v}) exitWith {hint "testBlackFoot must exist and be local";};
_v setVariable ["A3C_OW_DevExclusiveFire", false];
_v setVariable ["A3C_OW_LifecycleDebug", false];
hint "Development switches disabled for future sessions; finish/cancel the current session normally";
```

## Manual tests

Prioritize **A, B, C, D, F** first. Use fresh runs for each destructive test. Place
an ordinary following waypoint to check release before onward travel. Use a held
postcondition such as GoCode ALPHA for tests requiring a sustained ACTIVE phase;
keep ALPHA untriggered until test F (the stored code is "A", not its display label).
Use an unused code for the test group so other
groups do not respond to the completion command. Each block below is standalone;
it requires only the running mission and its explicitly stated test phase.

### A — Normal activation

Run while idle, before creating an Overwatch waypoint:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v} || {isNull driver _v} || {!local group driver _v}) exitWith {hint "Use a locally owned helicopter and AI group";};
if (count (_v getVariable ["A3C_OW_Session", createHashMap]) > 0) exitWith {hint "Cancel the current Overwatch before setting a baseline";};
_v enableAIFeature ["PATH", true];
_v enableAIFeature ["FIREWEAPON", true];
_v setVariable ["A3C_OW_DevExclusiveFire", true];
_v setVariable ["A3C_OW_LifecycleDebug", true];
private _code = ["A", side group driver _v] call A3C_main_fnc_getGoCodeActivationVariableName;
missionNamespace setVariable [_code, false, true];
hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
```

Create Overwatch far enough away to observe travel and braking, direction well
away from the initial heading, height 200–300 m, postcondition ALPHA. Inspect PATH
and FIREWEAPON throughout. FIREWEAPON stays true in TRAVEL/BRAKING/ROTATION/ALTITUDE.
At ACTIVE, PATH=false and FIREWEAPON=false. RPT has one log per transition, not a
continuous stream. Repeat with development mode disabled: ACTIVE still owns PATH
but FIREWEAPON stays true and ownsFIREWEAPON=false.

### B — Delete an active waypoint

Run in ACTIVE; this deliberately uses direct engine deletion to test the monitor:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v} || {isNull driver _v}) exitWith {hint "Use a local test helicopter";};
private _g = group driver _v;
deleteWaypoint [_g, currentWaypoint _g];
[_v] spawn {
    params ["_v"];
    sleep 0.2;
    hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
};
```

Expect both saved true values restored, no owned session/monitor, and no further
old firing commands. Repeat using A3C's delete UI to exercise its synchronous hook.

### C — Move an active waypoint

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v} || {isNull driver _v}) exitWith {hint "Use a local test helicopter";};
private _g = group driver _v;
[_g, currentWaypoint _g] setWaypointPosition [_v getPos [1500, (getDir _v) + 90], 0];
[_v] spawn {
    params ["_v"];
    sleep 0.2;
    hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
};
```

Watch the old release log and a distinct new run ID. During new travel FIREWEAPON
is true; it becomes false only at the next successful ACTIVE admission. Also test
dragging with the map UI. An engine/UI build that does not retrigger moved SCRIPTED
waypoints must leave the old run safely released; restart through the waypoint UI.

### D — Edit settings without moving position

The block changes direction and height in the existing trusted waypoint arguments:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v} || {isNull driver _v}) exitWith {hint "Use a local test helicopter";};
private _g = group driver _v;
private _wp = [_g, currentWaypoint _g];
private _text = waypointScript _wp;
private _split = _text find " [";
if (_split < 0 || {(toLower _text) find "wpscript_heli_overwatch.sqf" < 0}) exitWith {hint "Current waypoint is not Helicopter Overwatch";};
private _args = call compile (_text select [_split + 1]);
_args set [3, ((_args select 3) + 90) % 360];
_args set [4, (_args select 4) + 60];
_wp setWaypointScript format ["%1 %2", _text select [0, _split], str _args];
[_v] spawn {
    params ["_v"];
    sleep 0.2;
    hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
};
```

Expect settings-change release at the same position. If execution restarts,
FIREWEAPON is restored for phase A and acquired again only at ACTIVE. Repeat with
the actual waypoint menu: direction, height, formation and postcondition edits.

### E — Cancel during altitude adjustment

Start a fresh test with a substantially different assigned height. Run this block
while approaching/rotating; it waits at most 60 mission seconds for ALTITUDE:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v}) exitWith {hint "Use a local test helicopter";};
[_v] spawn {
    params ["_v"];
    private _deadline = time + 60;
    waitUntil {
        sleep 0.01;
        time > _deadline || {((_v getVariable ["A3C_OW_Session", createHashMap]) getOrDefault ["phase", ""]) == "ALTITUDE"}
    };
    if (((_v getVariable ["A3C_OW_Session", createHashMap]) getOrDefault ["phase", ""]) != "ALTITUDE") exitWith {hint "ALTITUDE was not observed; repeat with a larger height difference";};
    deleteWaypoint [group driver _v, currentWaypoint group driver _v];
    sleep 0.2;
    hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
};
```

Expect saved PATH restored and FIREWEAPON never acquired. RPT must contain no ACTIVE
or acquired-FIREWEAPON transition for the cancelled run ID.

### F — Complete normally

Use test A's held **postcondition GoCode ALPHA**, with an ordinary following waypoint:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v} || {isNull driver _v}) exitWith {hint "Use a local test helicopter";};
private _code = ["A", side group driver _v] call A3C_main_fnc_getGoCodeActivationVariableName;
missionNamespace setVariable [_code, true, true];
[_v] spawn {
    params ["_v"];
    sleep 0.2;
    hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
};
```

Expect restoration before onward travel and before the three-second departure
delay. Repeat with a timeout postcondition and a precondition requiring retrigger.

### G — Initially disabled features

Run while idle **before waypoint creation**. Choose both false first, then repeat
with false/true and true/false by changing the two literal Boolean values:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v} || {isNull driver _v}) exitWith {hint "Use a local test helicopter";};
if (count (_v getVariable ["A3C_OW_Session", createHashMap]) > 0) exitWith {hint "Cancel the existing session before setting the baseline";};
_v enableAIFeature ["PATH", false];
_v enableAIFeature ["FIREWEAPON", false];
_v setVariable ["A3C_OW_DevExclusiveFire", true];
_v setVariable ["A3C_OW_LifecycleDebug", true];
private _code = ["A", side group driver _v] call A3C_main_fnc_getGoCodeActivationVariableName;
missionNamespace setVariable [_code, false, true];
hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
```

Create Overwatch, inspect its saved baseline, then delete or complete it. Saved and
restored values must match these exact literals. Travel may temporarily enable
owned vehicle PATH; FIREWEAPON must remain false in phase A when originally false.
Also pre-disable an unrelated feature such as FSM and inspect it before/after
braking: removing the old ALL reset should preserve that state.

### H — Rapid restarts

Run during active Overwatch; this performs eight same-position script edits:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v}) exitWith {hint "Use a local test helicopter";};
[_v] spawn {
    params ["_v"];
    for "_i" from 1 to 8 do {
        private _g = group driver _v;
        private _wp = [_g, currentWaypoint _g];
        private _text = waypointScript _wp;
        private _split = _text find " [";
        if (_split < 0 || {(toLower _text) find "wpscript_heli_overwatch.sqf" < 0}) exitWith {};
        private _args = call compile (_text select [_split + 1]);
        _args set [3, ((_args select 3) + 35) % 360];
        _wp setWaypointScript format ["%1 %2", _text select [0, _split], str _args];
        sleep 0.15;
    };
    sleep 0.2;
    hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
};
```

Repeat by rapidly dragging the waypoint. After settling, there must be at most
one owned session/monitor per helicopter, original saved baselines and no firing
from old run IDs. Delete the final waypoint and expect monitorCount=0.

### I — Multiple helicopters

Use two AI attack helicopters in the same group, with independently set baselines
and switches before creation. This block inspects every helicopter driver:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {isNull driver _v}) exitWith {hint "testBlackFoot needs an AI driver";};
private _states = [];
{
    private _heli = vehicle _x;
    if (_x == driver _heli && {_heli isKindOf "Helicopter"}) then {
        _states pushBack (["inspect", _heli] call A3C_main_fnc_heliOverwatchLifecycle);
    };
} forEach units group driver _v;
hint str _states;
diag_log ["A3C OW multi-helicopter inspection", _states];
```

Expect a separate monitor/worker/baseline on each local helicopter, sharing the
group invocation ID. Cancel the group waypoint and verify each original pair.
Test with different original FIREWEAPON values and development switches.

### J — Abnormal termination during missile waits

With suitable enemy armor and missile ammunition, observe the existing missile
firing/projectile wait, then use B's direct deletion block or C/D to restart. Both
flags must restore on the monitor frame, without waiting for projectile death.
Old lasers/Fired handlers must be gone and old delayed workers must not update a
new engagement. Also explicitly terminate a per-helicopter worker:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v}) exitWith {hint "Use a local test helicopter";};
private _s = _v getVariable ["A3C_OW_Session", createHashMap];
if (count _s == 0 || {!(_s get "hasWorker")}) exitWith {hint "No Overwatch worker exists yet";};
terminate (_s get "worker");
[_v] spawn {
    params ["_v"];
    sleep 0.2;
    hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
};
```

For main-scope termination, only use the next block if a real handle is available:

```sqf
private _v = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _v || {!local _v}) exitWith {hint "Use a local test helicopter";};
private _run = (group driver _v) getVariable ["A3C_OW_Run", createHashMap];
if (count _run == 0 || {!(_run get "hasMainHandle")}) exitWith {hint "Engine exposed no main handle; test engine termination by moving/deleting the waypoint";};
terminate (_run get "mainHandle");
[_v] spawn {
    params ["_v"];
    sleep 0.2;
    hint str (["inspect", _v] call A3C_main_fnc_heliOverwatchLifecycle);
};
```

## Limits and source validation

Exact restoration is supported while the original machine still owns the vehicle.
Group/pilot locality changes while the vehicle remains local release its flags.
If the **vehicle itself migrates away**, the former owner stops its workers and
removes its local monitor/EH, but cannot guarantee feature restoration on the new
owner. It records `restoreLocal=false` and avoids broadcasting stale compatibility
flag cleanup over a new owner's session. Baselines/sessions are deliberately local;
there is no multiplayer migration protocol in this milestone. Test on one AI owner
without transferring vehicle locality. Mixed-owner group helicopters are skipped,
and a nonlocal/non-helicopter group leader prevents this waypoint from starting.

Other scripts that explicitly overwrite AI features after capture, including the
group-refresh action's broad `enableAI "ALL"`, remain independent writers. The
monitor neither arbitrates their feature ownership nor repeatedly disables AI each
frame. A waypoint position edit of at most 1 m or altitude-only waypoint-position
change is within the existing 2D tolerance; changing the assigned Overwatch height
in script parameters is detected. Engine departure/control can begin before the
next EachFrame on direct engine edits; A3C's delete and movement hooks restore
before A3C issues its own movement orders.

Source validation command:

```powershell
python docs/validation/check_heli_overwatch_lifecycle.py
```

During implementation it also compared live-ammo helpers and cannon command
arguments against a snapshot of the newest uncommitted Milestone 2A waypoint.
Checks cover comments/strings/delimiters, Boolean restore expressions, altitude and
development gating, capture/release ordering, asynchronous ownership checks,
monitor scope, registration and these standalone console blocks. These checks
are not an SQF compiler or a substitute for Arma execution. No in-game, flight,
weapon-effectiveness or multiplayer test has been performed.

Command semantics were checked against Bohemia's
[enableAIFeature documentation](https://community.bohemia.net/wiki/enableAIFeature)
and [checkAIFeature documentation](https://community.bistudio.com/wiki/checkAIFeature).

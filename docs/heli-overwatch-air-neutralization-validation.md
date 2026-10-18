# Overwatch aircraft neutralization: Phase 1

Static/source validation only; gameplay results are pending. Work starts on
`dev_branch` at `b7eee92`, preserving the existing uncommitted three-path
acquisition and native-AA guidance changes.

## Changes and checks

- `fnc_selectHeliOverwatchTarget.sqf`: after normal missile matching, an AIR
  missile candidate with `canMove == false` receives `eligible=false` and an
  explicit operational-disablement reason. Existing validation already requires
  the target alive with surviving crew. Detection is unchanged: such an aircraft
  can remain known, sensed or visible in the snapshot.
- `wpScript_heli_overwatch.sqf`: `_engagementCurrent` additionally requires
  mobility only for AIR/MISSILE. Its existing alive/live-crew conditions complete
  the operational check. This validator runs during rotation, aiming, readiness,
  existing missile-slot waits and the final unscheduled firing scope.
- In that same unscheduled firing scope, after live weapon-readiness validation
  and before any launch bookkeeping, the full check is repeated:
  `alive _target && {canMove _target} && {{alive _x} count crew _target > 0}`.
  Failure stops that firing attempt with a cancellation reason before setting
  pending/accept-shots, increasing commands or invoking `forceWeaponFire`.
  Existing cleanup clears the request normally. No scheduling boundary is added.
- This document records the diagnostic fields, source verification and runtime
  procedure. Earlier acquisition/projectile-guidance documents are untouched.

A disabled aircraft's tier can still be inspected, but it never enters the
ranked list. The retained-target lookup requires `eligible=true`, so it cannot
keep a disabled aircraft through the 12-second retention window. Normal outer
reevaluation selects another eligible target, or idles if none exists. An active
engagement that loses mobility exits through existing validity/cleanup paths.

No ground vehicle, ship, static weapon or gun engagement receives a new mobility
requirement. `canFire` is diagnostic only for this new check; existing threat
classification is unchanged. The five tiers, ranking, hysteresis, acquisition,
native/fallback guidance, real projectile capture, global `missileFlight` slot,
launch acknowledgement, laser handling, flight and lifecycle remain unchanged.
There are no per-target reservations, post-impact delays, monitoring workers,
new helpers or debug settings.

## Diagnostics

With `A3C_OW_Debug` enabled, each detected AIR candidate's existing ranking row
has an `airOperational` map with `alive`, `canMove`, `canFire`, overall `damage`,
`speed`, `distance`, `liveCrew` and `rejectedDisabled`. Object/class, acquisition
paths, method, eligibility and reason remain on that same row. `rejectedDisabled`
means the new mobility gate rejected an otherwise matched AA missile candidate;
already dead, uncrewed or incompatible candidates may have another rejection.

No automatic RPT logging is added. If the final authorization barrier rejects,
its reason reaches the existing fire summary. Earlier validity exits can be
investigated through the selector snapshot. Snapshot time/age matter during
existing engagement waits; these are observations at evaluation time, not a
continuous damage trace.

On the machine owning the Blackfoot AI/turrets, run this block before issuing
Overwatch, then rerun it after the relevant state change:

```sqf
testBlackFoot setVariable ["A3C_OW_Debug", true];
private _snapshot = testBlackFoot getVariable ["A3C_OW_Ranking", createHashMap];
if (count _snapshot == 0) exitWith {hint "Capture enabled. Issue Overwatch, then rerun.";};
private _lines = [format ["OW aircraft state: snapshot=%1 age=%2 selected=%3",
    _snapshot get "time", time - (_snapshot get "time"), _snapshot get "selected"]];
{
    if ((_x get "target") isKindOf "Air") then {
        _lines pushBack format ["target=%1 class=%2 state=%3 eligible=%4 method=%5 reason=%6",
            _x get "target", _x get "type", _x getOrDefault ["airOperational", createHashMap],
            _x get "eligible", _x get "method", _x get "reason"];
    };
} forEach (_snapshot get "candidates");
private _report = _lines joinString toString [13, 10];
diag_log _report;
copyToClipboard _report;
hint "Aircraft operational snapshot copied to clipboard and RPT.";
```

## In-game procedure (pending)

1. Restart Eden preview with updated source. Use the existing AI-crewed
   `testBlackFoot` with live supported AA missiles and the normal Overwatch
   waypoint with a long TIMEOUT. Put a crewed hostile helicopter named
   `A3C_OW_TestAir` in clear LOS and compatible missile range. Add another valid
   enemy for the alternative-target case. Enable diagnostics using the block
   above. An operational aircraft should retain its normal eligibility and
   native/fallback launch behavior.
2. For a controlled loss-of-mobility test, run the following on the enemy
   aircraft's owner before selection, then repeat in a fresh preview while the
   Blackfoot is rotating/settling or waiting for weapon readiness:

   ```sqf
   private _target = missionNamespace getVariable ["A3C_OW_TestAir", objNull];
   if (isNull _target || {!local _target} || {!(_target isKindOf "Air")}) exitWith {
       hint "Run on the owner of the named hostile test aircraft.";
   };
   _target setFuel 0;
   hint format ["After fuel removal: target=%1 alive=%2 canMove=%3 liveCrew=%4 damage=%5",
       _target, alive _target, canMove _target, {alive _x} count crew _target, damage _target];
   ```

   Require the observed state `alive=true`, `canMove=false`, `liveCrew>0` for
   this case; do not infer it merely from a falling animation. Fuel removal is
   confined to this manual test. Restart afterward to restore the scenario.
3. Confirm the disabled aircraft's snapshot shows the operational rejection,
   no further AA command/round is issued against it after the state is observed
   by fire control, and another eligible target is selected without waiting for
   the retention window. An already issued or launched missile is unaffected.
   Count actual ammunition and correlate existing matched-Fired/engagement logs.
4. Repeat with the original Mi-24 and real missile damage. Record its actual
   `canMove` before the next possible launch, along with damage/speed/crew and
   snapshot age. Mod-specific engine/rotor damage can also be tested using the
   actual names from `getAllHitPointsDamage`, but verify the resulting mobility
   state rather than assuming a damaged rotor guarantees `canMove=false`.
5. Check an immobilized, live, crewed hostile tank with a suitable ground missile
   loadout, a static weapon and a normal gun burst. Their previous eligibility
   and engagement behavior must remain. Recheck normal operational aircraft,
   native-AA/fallback logs, waypoint cancellation/departure and dedicated/HC
   ownership. Disable capture afterward by setting `A3C_OW_Debug` to `false`.

The [Bohemia `canMove` reference](https://community.bistudio.com/wiki/canMove)
documents fuel checks for aircraft and limitations around damaged helicopters.
This engine flag is the requested Phase 1 proxy, not proof of aerodynamic flight
capability. If the Mi-24 keeps `canMove=true` while falling, this gate alone will
not prevent further missiles. No alternative damage/descending-speed heuristic
or Phase 2 tracking is introduced. Network state propagation and the installed
mod's damage behavior require actual multiplayer/game testing.

## Static validation

`git diff --check`, SQF string/comment/delimiter checks, and exact comparison to
the saved pre-task sources passed. Removing only the two selector insertions
and the engagement/final-authorization additions restores those sources exactly.
The complete three-path acquisition, threat/tier/ranking/retention code, guidance
dispatch, firing bookkeeping, flight-slot handling and cleanup are preserved.
Hash checks confirm the earlier validation documents and shared guidance/remote
launch helpers are untouched. No SQF compiler or gameplay result is claimed.
No commit or push was performed.

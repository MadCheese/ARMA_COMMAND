# Helicopter Overwatch acquisition validation

Source/static validation only; in-game results are pending. Work starts from
`dev_branch` at `b7eee92` with the already working, uncommitted native-AA changes
in the waypoint script and its projectile-guidance document preserved byte for
byte. This task changes only `fnc_selectHeliOverwatchTarget.sqf` and adds this
validation document. Repeated missile engagements are outside this change.

## Acquisition and scope

Discovery still uses `MCSS_fnc_nearEntities`, including `STATICWEAPON`, with its
objective noncivilian/hostile side filtering. The existing maximum-range formula
now runs after the unchanged live executable-option filter, so options that fail
that filter cannot expand the scan or optical range. No weapon classification,
ammunition checks, minimum range or target compatibility rules change.

Each discovered object enters candidate evaluation once if any path succeeds:

- `KNOWLEDGE`: the driver's group `knowsAbout` value is strictly greater than 1.
  Optical range/cone restrictions do not apply to this path.
- `SENSOR`: its object identity occurs in the single `getSensorTargets _heli`
  snapshot taken for this evaluation. Sensor type is not restricted, so engine
  IR, visual, radar and datalink reports can qualify. Reported `unknown`/friendly
  relationships do not establish hostility; existing objective side checks
  remain independent. No sensors are enabled or simulated.
- `VISUAL`: evaluated only when both previous paths fail. Slant distance must be
  at most `min(executable discovery radius, 1000 m)` for infantry or
  `min(executable discovery radius, 3000 m)` for other targets. The fixed original
  waypoint direction centers the inclusive half-angle: 60 degrees for infantry,
  ground vehicles, ships and static weapons; 120 degrees for aircraft.

`MCSS_fnc_isInAngleSector` was inspected: its parameters are center, direction,
half-angle and target position/object; it compares the angular separation of
two horizontal bearing vectors. It suits the fixed-direction optical test.
The MCSS vehicle LOS helper checks a turret arc, not obstructions. The simple
and infantry helpers use `lineIntersects` and/or unsuitable endpoints, so none
is reused for optical obstruction testing.

Only an in-range, in-cone, otherwise undetected target receives the optical
`lineIntersectsSurfaces` test: `eyePos _heli` to `aimPos _target`, both ASL,
ignoring the helicopter and target objects. It requests one obstruction using
`VIEW` geometry with `GEOM` as the fallback LOD. An empty result is required.
The command includes terrain; its documented 5000 m ray limit exceeds the
3000 m optical cap. See the Bohemia references for
[sensor result structure](https://community.bohemia.net/wiki/getSensorTargets),
[eye position](https://community.bistudio.com/wiki?title=eyePos&useskin=vector), and
[surface-ray behavior](https://community.bistudio.com/wiki/lineIntersectsSurfaces).

For a vehicle accepted through this optical ray, selector validation reuses
that result instead of additionally requiring the old origin-to-origin
`lineIntersects` ray. This is the sole LOS validation adjustment: it prevents
a visible aim point being contradicted by a lower origin behind cover.
Knowledge/sensor candidates keep the old vehicle LOS check. Hostility, life,
surviving crew and every weapon-feasibility check remain independent.

The five tiers, threat assessment, tuple ranking, fixed priority sector,
hysteresis/retention and preemption calculations are unchanged. The waypoint
script, firing-time checks, native AA guidance, scripted fallback, cannon burst
accounting, target snapshots, projectile ownership and helicopter lifecycle are
untouched. There are no knowledge writes, new workers, EHs, settings or RPT logs.

## Diagnostics and practical test

On the machine owning `testBlackFoot` AI/turrets, run this block before issuing
the usual Overwatch waypoint, then run it again after acquisition. It enables
the existing snapshot capture and logs only when manually executed:

```sqf
private _heli = missionNamespace getVariable ["testBlackFoot", objNull];
if (isNull _heli || {!local _heli}) exitWith {hint "Run on the testBlackFoot owner.";};
_heli setVariable ["A3C_OW_Debug", true];
private _snapshot = _heli getVariable ["A3C_OW_Ranking", createHashMap];
if (count _snapshot == 0) exitWith {hint "Capture enabled. Issue Overwatch, then rerun.";};
private _lines = [format ["OW acquisition: snapshot=%1 age=%2 direction=%3 radius=%4 selected=%5",
    _snapshot get "time", time - (_snapshot get "time"), _snapshot get "direction",
    _snapshot get "radius", _snapshot get "selected"]];
{
    _lines pushBack format ["candidate=%1 acquisition=%2 eligible=%3 tier=%4 method=%5 rejection=%6",
        _x get "target", _x get "acquisition", _x get "eligible", _x get "tier",
        _x get "method", _x get "reason"];
} forEach (_snapshot get "candidates");
{
    _lines pushBack format ["excluded by detection: %1", _x];
} forEach (_snapshot getOrDefault ["detectionRejected", []]);
private _report = _lines joinString toString [13, 10];
diag_log _report;
copyToClipboard _report;
hint "Acquisition snapshot copied to clipboard and RPT.";
```

Each candidate's `acquisition` map contains path names, knowledge/sensor booleans,
`knowsAbout`, the matched full sensor record, distance, signed waypoint-relative
angle, optical range/half-angle, and visual result/status. `visualEvaluated`
means the optical ray actually ran. `visual=false` with `NOT_REQUIRED` means
optical detection was skipped, not that visibility failed. Knowledge and sensor
can both be recorded; no redundant ray is run to claim an additional visual
path. Debug-only `detectionRejected` records explain insufficient detection and
`OUT_OF_RANGE`, `OUT_OF_CONE` or `BLOCKED`; these objects never enter ranking or
the retained identity list. No out-of-discovery-radius targets are recorded.

Restart each case or remove competing enemies. Use clear daylight initially,
AI pilot/gunner, suitable live ammunition, and a long Overwatch TIMEOUT. Compare
the snapshot's recorded knowledge and sensor contact before attributing a test
to the optical path; ordinary AI may independently learn about exposed enemies.

| Case | Setup and expected evidence (runtime pending) |
| --- | --- |
| 1. Knowledge | Known hostile target outside its optical cone but inside executable range: `KNOWLEDGE` and the original eligibility/ranking behavior. |
| 2. Visual ground | Crewed hostile ZSU/static weapon inside both 3 km and executable range, within 60 degrees: with knowledge <= 1 and no sensor record, expect `VISUAL`, `CLEAR` and ordinary weapon eligibility. |
| 3. Obstruction | Same unknown, sensor-unreported target behind a ridge or solid building: expect `BLOCKED` in detection rejections, never visual acquisition. Repeat beyond 1 km and near partial cover. |
| 4. Moving aircraft | Crewed hostile helicopter with lateral MOVE waypoints, inside both 3 km and AA range, within 120 degrees: expect visual acquisition when neither other path applies, then the existing working native-AA engagement. |
| 5. Cone limits | Unknown, unreported ground target beyond 60 degrees or aircraft beyond 120: expect `OUT_OF_CONE`. Repeat across north (waypoint 350 degrees, target 10 degrees) and at cone boundaries. Rotate the helicopter physically; the stored waypoint cone must stay fixed. |
| 6. Sensors | Outside optical limits, inside weapon radius, knowledge <= 1, actual engine contact: expect `SENSOR` and its full contact record. Include an `unknown` relationship on a genuinely hostile object; friendly/civilian objects must not become candidates. |
| 7. Weapon limits | Target beyond maximum executable range: absent from discovery regardless of knowledge/contact. Check infantry beyond 1 km without other detection, and ammunition/operator loss. |
| 8. Regression | Existing priority competition, 12-second retention and higher-tier preemption behave as before. Check ground missiles/lasers, eight-round gun bursts, native-AA ownership logs, waypoint cancellation/departure and dedicated-server/HC ownership. |

Disable capture afterward with `testBlackFoot setVariable ["A3C_OW_Debug", false]`.
Snapshots can be stale during existing engagement waits; always inspect age.

The optical path is a bounded geometric visibility test, not a full lighting,
fog, smoke, camouflage or recognition simulation. Correctness depends on model
eye/aim points and obstruction LODs; LOD2 is a fallback, not a second independent
test. Mod geometry and partial cover require in-game checks. Existing separate
firing-time LOS can still decline a target the selector acquired; it was
deliberately not changed. Sensor contacts depend on the installed vehicle,
operating sensors and the local engine state. Dedicated/HC behavior and actual
engagements cannot be established by source checks.

## Static validation

`git diff --check` and comment/string-aware SQF delimiter checks passed. Exact
section comparisons preserve executable-option filtering, threat assessment,
weapon selection, ranking and retention; the only selector validation change is
the optical-LOS reuse described above. Arithmetic checks cover bearing wrapping
and the helper's half-angle semantics. Hash checks confirm the pre-existing
waypoint/native-AA source and projectile-guidance documentation are unchanged.
No SQF compiler or game runtime result is claimed. Nothing was committed or
pushed.

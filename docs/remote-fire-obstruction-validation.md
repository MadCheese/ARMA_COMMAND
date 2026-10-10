# Remote-fire obstruction analysis: milestone 1

This is preliminary selection on the commanding client, once per issued order. Runtime geometry/firing tests below are pending; source/diff checks do not prove engine geometry or ballistic reachability.

## Call chain and scope

The squad/high-command Space confirmation handler `fnc_onKeyDown_Main.sqf` supplies the already eligible AT, UGL, static or tank candidate list and action to `structureRemoteLaunch`. That function groups all candidates, including a singleton, by their existing group; calls `findBestShooters` once per group; and dispatches at most the best eligible unit in each group. Group order remains the first appearance in the supplied list. No new group, capability, ammo or busy-state eligibility rules are added (invalid/dead candidates cannot shoot).

The only runtime caller found for `findBestShooters` is `structureRemoteLaunch`; the key-manager reference is a comment. There is no new Draw3D/EachFrame/UI-loop query. The selected units still receive the existing `BIS_fnc_spawn` remote dispatch to `orderRemoteLaunch`, with the existing explicit snap-object forwarding for ATSHOT/TANKSHOT/FIND. Owner-side firing preparation, final tank aim/readiness, projectile capture/guidance and recovery are unchanged. The preceding uncommitted TANKSHOT aiming correction is preserved exactly by this milestone.

`findBestShooters` still returns an array of eligible units. Its two original arguments are unchanged; optional arguments are `[action = "", snapObject = objNull, notify = true]`. The dispatcher passes `notify=false`, then emits one commanding-client notification for all failed groups, including partial failures. Two-argument callers retain the return shape/default notification, but an unspecified trajectory is deliberately permissive instead of applying the former binary object rejection.

## Evaluator contract

```sqf
[_originASL, _designationASL, _firingUnit, _firingVehicle, _explicitTarget]
    call A3C_ai_shared_fnc_evaluateRemoteFireObstruction
// [status, softCount, hardCount, uncertainCount, details]
// status: CLEAR, SOFT, HARD or UNCERTAIN
// detail: [posASL, hitObject, parentObject, terrain, classification, reason,
//          effectiveObject, configClass, modelPath, hitModelPath, selections, bisurf]
```

- Origin remains approximate: `eyePos` for infantry, vehicle ASL origin plus 1.8 m for mounted candidates, as before. This is not a predicted, rotated cannon muzzle or a ballistic path.
- `lineIntersectsSurfaces` queries ASL endpoints, sorted, with up to 64 unique-object intersections, FIRE geometry and GEOM fallback. Every returned surface is classified; encountering a bush never ends processing. Hit parent objects own proxy classification; counts deduplicate effective parent objects.
- Unit/vehicle geometry, their returned child proxies, A3C targeting proxies and the explicitly selected target's own surfaces are ignored. Endpoint contacts within 0.25 m are ignored, so a designated terrain/wall surface is not treated as intervening cover. Unrelated cover farther from the endpoint is still evaluated, including cover before a selected building.
- Both returned objects null means terrain. A separate `terrainIntersectASL` test ends 0.25 m short of the designation and confirms terrain even behind vegetation or beyond the capped object results. Its supplemental detail has an empty position because that boolean command provides no surface point.
- TREE, SMALL TREE and BUSH recognition requires exact object membership in `nearestTerrainObjects`, using the effective object's own location. The unsorted 2D lookup radius is the bounding sphere radius plus 2 m, clamped to 2–50 m. Nearby vegetation cannot classify a different intersected rock, fence or wall. Config classes are not required for map vegetation/solids.
- Vegetation is SOFT, including intersected trunks/branches. This is intentionally permissive, not proof that a shell can penetrate a tree.
- A FENCE map object/config fence is softened only when its model basename advertises wire/mesh/chainlink and its model height is positive and at most 1.5 m. Other fences remain UNCERTAIN; size alone is not evidence that a concrete fence is foliage. This narrow naming heuristic still needs mod validation.
- HARD solids include exact building/house/church/chapel/bunker/fortress/ruin/wall/rock map-category matches, configured LandVehicle/Air/Ship/Wall/Wall_F/Rock ancestry and House ancestry with positive `numberOfDoors`. Generic House inheritance alone is insufficient because scenery props can inherit it. Unrecognized models, including ambiguous HIDE-category rocks/props and unusual editor-placed structures, remain UNCERTAIN with class/model diagnostics.
- Invalid/degenerate rays, approximate origins below terrain and ranges beyond the engine's 5000 m limit return UNCERTAIN. Reaching 64 intersections adds uncertainty rather than claiming the remainder clear. A confirmed HARD blocker dominates uncertainty; otherwise UNCERTAIN dominates SOFT, then CLEAR.

The helper is stateless and read-only: no scenery/proxy/vehicle mutations, firing, workers, target assignment or persistent cache. API behavior was checked against Bohemia's [surface intersection](https://community.bistudio.com/wiki/lineIntersectsSurfaces), [terrain object](https://community.bistudio.com/wiki/nearestTerrainObjects) and [nested-array sort](https://community.bistudio.com/wiki/sort) documentation.

## Selection policy

Eligible candidates sort ascending by `[hasConfirmedHard, quality, softCount, engagementDistance, originalInputIndex]`, where quality is CLEAR=0, SOFT=1, UNCERTAIN=2, HARD=3. Thus no confirmed hard blocker wins first; clear beats soft; soft beats uncertain; fewer unique soft obstacles then shorter approximate engagement distance decide ties; exact ties retain input order. This is suitability ranking, not a guarantee of a hit.

Confirmed hard blockers reject TANKSHOT (and an explicit future DIRECT action). The old artillery-vehicle exception is preserved. ATSHOT, UGLSHOT, STATICSHOT's missile path, ARTY and unspecified/unknown actions remain eligible even with HARD straight-line cover because their actual trajectory is not established by this ray. Clear alternatives still outrank them. FIND mirrors the existing orderRemoteLaunch capability precedence (UGL, AT, tank gunner, artillery gunner, static missile, EXIT) for policy only; the original FIND dispatch is unchanged. There is no guessing of native/ACE flight profiles and no ballistic simulation.

Under A3C_DEBUG, each order logs candidate/action/origin/target, all capped surface details and reasons, counts, rejection/permissive reason, score/ranked list and the selected shooter per group. Logs stay on the commanding client; there is no firing-owner systemChat and no per-frame sampling.

## Runtime test matrix

Enable `missionNamespace setVariable ["A3C_DEBUG", true]` on the commanding client. Use candidates already provided by the normal action UI. Inspect that client's RPT before checking the unchanged firing-owner logs. Every row requires an in-game run.

| Scene / order | Required selection result |
| --- | --- |
| Clear ray | CLEAR; shortest practical ray wins equal-quality candidates |
| Bushes only | SOFT with exact bush identities; eligible for tank/AT/UGL; fewer distinct bushes wins |
| Dense vegetation followed by wall | All returned hits inspected; wall HARD; direct tank candidate rejected; a clear/soft alternative selected |
| Tree trunk and branches | Exact TREE/SMALL TREE parent SOFT; multiple child proxies count once; real projectile penetration remains unproven |
| Rock beside a tree | Rock remains HARD when categorized as ROCK/ROCKS; ambiguous HIDE rock UNCERTAIN; never SOFT merely due to proximity |
| Intervening building or vehicle | HARD; rejected for direct tank, retained with lower rank for unknown/arcing paths |
| Terrain crest / hillside | HARD terrain distinguished from ordinary objects, including ground behind bushes; endpoint ground contact ignored |
| Building deliberately selected | Building and its child surfaces IGNORED; a different wall/building before it remains HARD |
| Position designation on wall/terrain | Exact endpoint contact ignored within 0.25 m; substantial cover earlier on the ray retained |
| One clear shooter, one behind bushes | Clear wins even if farther away; no confirmed hard rejection needed |
| One behind bushes, one behind wall | Bush shooter wins; direct wall shooter omitted; AT/UGL wall shooter stays in eligible list after the better candidate |
| Equal scores | Original input order is preserved; reverse the input and verify the tied order reverses |
| Small wire fence / concrete or unusual fence | Small classified wire/mesh fence SOFT; unknown fence UNCERTAIN; confirmed wall/building category HARD; inspect model/class reasons |
| UGL over nearby cover | HARD straight-line result does not remove all UGL shooters; engine/A3C arc behavior unchanged |
| Native Titan TopDown / ACE NLAW/Javelin behind cover | AT candidates retained; clearer candidates preferred; existing native mode/ACE profile behavior unchanged |
| Unguided AT / static missile / artillery | Unknown trajectory retained; no premature all-candidate disqualification; existing fixed aim/static/artillery flow unchanged |
| Single direct tank shooter behind wall | Same rejection as multi-candidate filtering; one client notification; no dispatch or claimed tank order |
| Several groups, partial/all failures | At most one best shooter per original group; one aggregate client message; no repeated per-group systemChat |
| Modded terrain object / missing config class | Exact map-category membership works without CfgVehicles; unfamiliar object UNCERTAIN, model path logged |
| More than 64 surfaces / long or invalid ray | Cap/range issue recorded UNCERTAIN; no false CLEAR; confirmed terrain/hard evidence still dominates |
| Dedicated server/client-local AI | Analysis/notification on commander; existing owner dispatch, capture/locality and cleanup unchanged |
| Fresh tank terrain/vehicle shot and subsequent HE reload | Prior aiming/reload correction remains intact after preliminary candidate selection |

Read-only selection probe (does not reload, select weapons or fire):

```sqf
private _candidates = +A3C_REMFIRE_TankShot_Units;
private _posASL = ATLToASL A3C_UI_HUD_3D_TAG_ICON_POS;
private _ranked = [_candidates, _posASL, "TANKSHOT", A3C_SNAP_OBJECT, false]
    call A3C_ui_shared_fnc_findBestShooters;
diag_log ["REMOTE FIRE SELECTION PROBE", _candidates, _ranked];
```

## Remaining limits

Terrain named properties, config metadata and model naming may be inaccurate in mods. Large object pivots can escape the bounded terrain-category lookup; conservative uncertainty preserves the candidate. Geometry may not be streamed on the commanding client, and FIRE/GEOM can omit or overstate obstacles. Approximate firing height and a 0.25 m endpoint tolerance can misrepresent nearby cover. The capped query can miss later objects; vegetation-permissive results do not establish penetration. No lead, zeroing, top-down/UGL path prediction or final-owner obstruction recheck is introduced. Existing owner-side aiming/readiness and guidance retain responsibility for execution.

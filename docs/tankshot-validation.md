# TANKSHOT shell selection and physical reload validation

Runtime tests below are pending. Source/diff checks and installed vanilla/RHS configuration inspection were performed; no in-game firing was performed by the coding agent.

## Selection and firing contract

- Only the explicitly forwarded object classifies the target. `LandVehicle`, `Air` and `Ship` objects prefer AP; infantry, buildings, null/ambiguous objects and position orders prefer HE. No nearby-object search is used.
- The operator must be the actual primary gunner. `unitTurret` determines its path; both the gunner and that turret must be local. Vehicle/driver locality is not required. Ownership changes during preparation abort firing and forward only recovery to the gunner's current owner.
- Cannon candidates must inherit `CannonCore`, or advertise cannon `nameSound`, and accept damaging shell ammunition. A unique `CannonCore` candidate enables automatic shell selection. Ambiguous cannons retain the legacy first weapon's loaded choice if it is a validated cannon; an unidentified cannon aborts rather than firing a coax, missile or smoke launcher.
- Stock comes from `magazinesAllTurrets`, filtered by the actual turret path, positive rounds and cannon compatibility. Counts are aggregated by magazine class. Loaded state comes from `weaponState [vehicle, turret, cannon, muzzle]`.
- Shells must simulate `shotShell`, or `shotBullet` on a confirmed `CannonCore`, and have positive direct or indirect damage. Recognized AP/APFSDS/APDS/APHE/HEAT/TandemHEAT warheads and APFSDS/APDS/SABOT/HEAT or AP/APHE naming identify anti-armor shells. HE/HEFRAG/HESH/HEP warheads identify HE. Explicit HEAT-MP/MPAT with explosive blast damage qualifies for either role, including vanilla HEAT-MP. Unknown/default warheads can use explosive HE naming, positive explosive blast damage, or non-explosive penetration (`caliber >= 5`). Unknown custom warheads otherwise stay UNKNOWN. Smoke/practice/training names are excluded; named canister retains an UNKNOWN role.
- A suitable loaded magazine is retained. A usable loaded shell with an UNKNOWN role also retains its magazine instead of guessing a replacement. Otherwise the first positively classified, stocked compatible magazine is preferred. There is no launcher-class whitelist or universal ranking of APFSDS versus HEAT. When no preference is established, keep a usable loaded shell.
- Aiming starts before inventory inspection and loading. `loadMagazine [turret, cannon, preferred]` is requested at most once when the desired magazine is not already loaded with ammunition. No ammo additions, reload-phase writes or projectile substitutions are used.
- Readiness requires a usable compatible loaded magazine, positive rounds, and both round and magazine reload phases exactly zero. The reload deadline is `2 * configuredReloadTime + 5`, clamped to 15–60 seconds; prediction takes the maximum of weapon, mode and magazine reload settings. Actual readiness, rather than elapsed time, permits firing. Aim retains the original ten-second allowance, horizontal-arc alternative and three-second settle, and is checked again immediately before firing.
- After a failed/timed-out preference, only a physically ready loaded shell can be used as fallback. The requested muzzle's magazine reload must also have finished, even when another muzzle has a ready shell. Otherwise abort and clean up.
- The old hardcoded `UseWeapon` index 0 is replaced by `UseMagazine`, following the installed `BIS_fnc_fire` vehicle implementation. Unlike that helper's class/count match alone, this path also matches a loaded `magazinesAmmoFull` entry by muzzle, ID and creator against `magazinesAllTurrets` on the actual turret. Ambiguous instances or a magazine compatible with another weapon on that turret abort. The action is issued directly once on the gunner/turret owner, without a queued remote firing worker.
- Capture uses the local gunner's synchronous `FiredMan` handler because a `Fired` handler on a driver-owned remote vehicle can be camera-range limited. It validates the order, vehicle, weapon, muzzle and magazine. Only the captured projectile receives the unchanged DIRECT A3C guidance. A token-specific receipt survives close shots deleting the proxy before polling.
- The five-element remote handle remains intact; its TANKSHOT event ID now belongs to the gunner's `FiredMan` handler. The helper removes it on the installing machine, closes capture, clears the handle only if still owned, and deletes only an unfired proxy. Fired-projectile lifetime cleanup remains unchanged. Recovery restores the saved AUTOTARGET state and releases tank/unit tokens and the remote-firing flag. TANKSHOT active-list deltas run on the server to avoid competing snapshots from simultaneous turret owners.

## Test matrix

Enable `missionNamespace setVariable ["A3C_DEBUG", true]` on each executing gunner owner. Inspect that owner's RPT for category, snap object, turret/cannon, stock, preference/reason, initial state, load request, reload outcome, final state and actual fired weapon/magazine/ammunition. Check server logs/state for active-list recovery. Every row below requires an in-game run.

| Case | Setup / action | Required observation |
| --- | --- | --- |
| Vanilla vehicle target | Slammer, Varsuk and Kuma, HE loaded; explicitly select a vehicle | AP/anti-armor preference, one physical magazine switch, aiming overlaps reload, one cannon projectile after both phases reach zero |
| Vanilla position / infantry / building | AP loaded; order terrain, infantry and building shots | HE or explicit HEAT-MP preference; original designated proxy position behavior; no nearby-vehicle classification |
| Already suitable loaded | Repeat both categories with a ready suitable round | `loadMagazine requested=false`; normal aim/settle; ready shell fired |
| Vanilla HEAT-MP | AP loaded, HEAT-MP stocked, no pure HE | HEAT-MP reports AP_HE and is selected for the position order |
| RHS AFRF | T-72/T-90 with 3BM, 3BK and 3OF stock | AP or HEAT for a vehicle, 3OF HE for a position; use the actual configured autoloader duration; no FCS laser/coax capture |
| RHS USAF | Abrams with M829, M830 and M1069/M1147 stock | M829/M830 qualifies as anti-armor; M1069/M1147 as HE; correct loaded instance and physical reload |
| CUP | Representative Western and Soviet MBTs | Verify cannon ancestry, shell simulation/warhead/naming and magazine-instance mapping; unknown configurations keep the loaded choice or abort safely |
| Unknown loaded shell | Damaging cannon shell with an unrecognized role loaded; recognized AP/HE also stocked | Keep the current magazine, report the uncertain classification, and do not request a switch |
| Depleted HE stock | HE magazines empty or absent; usable AP already loaded | Empty HE omitted from stock; no futile preferred switch; ready loaded AP fallback fires |
| Empty cannon / no usable stock | All compatible main-gun rounds exhausted, coax still stocked | No coax/smoke/missile shot; clean abort with no installed handler/proxy/reservation |
| Rejected reload | Request a preferred switch that the engine/mod rejects | Bounded wait; loaded fallback only after both phases are zero; otherwise clean timeout |
| Interrupted / slow reload | Change magazines manually, remove preferred stock, or extend reload beyond the deadline | No firing while magazine reload is incomplete; ready loaded fallback or abort; no delayed retry |
| Multiple muzzle / duplicate spares | Cannon has separate AP/HE muzzles; several identical full spare magazines | Reuse genuinely loaded suitable muzzle; exact loaded ID/creator used; ambiguous mapping aborts rather than firing a spare |
| Short projectile lifetime | Very close target; proxy deleted before the capture wait polls | Receipt still reports shot captured; no stale handler or erroneous recovery of a new order |
| Simultaneous tanks | Order several tanks, including different clients/HC owners | Each tank uses its own target, preference and capture; server delta updates release every active entry |
| Dedicated server / distant camera | Server-local gunner; client observes from far away | Local FiredMan capture and unchanged DIRECT guidance, independent of observer distance |
| Split vehicle/turret ownership | Driver on client A, gunner/AI turret on client B | Loading and firing execute on B; driver ownership does not prevent capture; one shot |
| Ownership / seat migration | Transfer the gunner group or change/eject gunner during loading and aiming | No firing after ownership/crew invalidation; old-machine handler removed; recovery runs on current gunner owner; new orders can proceed |
| Cancellation / destruction | Clear remote-firing flag or destroy tank/gunner during preparation | No firing; flags, active entry, tokens, handler and unfired proxy released |
| Guidance regression | Repeat native Titan Direct/TopDown, ACE AT, unguided fixed-position AT, static and artillery operations | Their source and behavior remain unaffected by TANKSHOT routing |

## Read-only configuration probe

Look at a crewed tank, then run locally where its gunner/turret is owned. This only logs configuration and stock; it does not load or fire ammunition.

```sqf
private _tank = cursorObject;
private _gunner = gunner _tank;
if (!isNull _tank && {!isNull _gunner}) then {
    private _turret = _tank unitTurret _gunner;
    private _weapons = _tank weaponsTurret _turret;
    diag_log ["TANKSHOT PROBE", _tank, _gunner, _turret, local _gunner, _tank turretLocal _turret, _weapons];
    {
        private _weapon = _x;
        private _core = _weapon isKindOf ["CannonCore", configFile >> "CfgWeapons"];
        private _compatible = compatibleMagazines _weapon;
        diag_log ["TANKSHOT WEAPON", _weapon, _core, weaponState [_tank, _turret, _weapon]];
        {
            _x params ["_mag", "_path", "_rounds"];
            if (_path isEqualTo _turret && {_rounds > 0} && {_mag in _compatible}) then {
                diag_log ["TANKSHOT SHELL", _weapon, _x, [_mag, _core] call A3C_ai_shared_fnc_classifyTankShell];
            };
        } forEach magazinesAllTurrets _tank;
    } forEach _weapons;
    diag_log ["TANKSHOT LOADED INSTANCES", magazinesAmmoFull _tank];
};
```

## Limits requiring runtime verification

Classification depends on the effective loaded-mod configuration, including patches and inheritance. Installed vanilla and RHS source configurations support the common cannon and AP/HE families, but do not prove successful runtime reload or firing. CUP, nonstandard scripted loaders, unusual custom warheads, multi-cannon turrets, RC/remote-controlled gunners and loaded-instance reporting on nonstandard primary turret layouts need testing. `magazinesAmmoFull` supplies loaded IDs for the primary gunner; the turret-path cross-check deliberately aborts if this cannot identify the actual requested turret.

The retained MCSS aiming alternative checks the main turret's horizontal arc, not visibility or a full ballistic solution. A3C's existing shell correction remains responsible for assisted trajectory accuracy. The implementation does not add lead, zeroing, prediction or a new flight model.

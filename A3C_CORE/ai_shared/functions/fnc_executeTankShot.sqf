// A3C_ai_shared_fnc_executeTankShot
// Scheduled, gunner-owner execution. Vehicle ownership may belong to the driver.
params ["_unit", "_targetPos", ["_snapObject", objNull, [objNull]], ["_dispatches", 0, [0]]];
private _debug = missionNamespace getVariable ["A3C_DEBUG", false];
if (isNull _unit || {!alive _unit}) exitWith {};
if (!local _unit) exitWith {
    if (_dispatches < 2) then {
        [[_unit, _targetPos, _snapObject, _dispatches + 1], A3C_ai_shared_fnc_executeTankShot]
            remoteExec ["BIS_fnc_spawn", _unit];
    } else {
        if (_debug) then {diag_log "[A3C] TANKSHOT abort: gunner ownership did not stabilize";};
    };
};

private _tank = vehicle _unit;
private _turret = _tank unitTurret _unit;
if (_tank == _unit || {_unit != gunner _tank} || {_turret isEqualTo []}
    || {!(_tank turretLocal _turret)}) exitWith {
    if (_debug) then {diag_log format ["[A3C] TANKSHOT abort: invalid/nonlocal gunner turret (vehicle=%1, gunner=%2, turret=%3)", _tank, _unit, _turret];};
};

private _token = format ["TANK:%1:%2:%3", clientOwner, diag_tickTime, _unit];
private _autoTarget = _unit checkAIFeature "AUTOTARGET";
private _claimed = false;
isNil {
    if (!local _unit || {!(_tank turretLocal _turret)}) exitWith {};
    if (_unit in A3C_REMFIRE_UNITS_ACTIVE
        || {!((_tank getVariable ["A3C_TANK_SHOT", []]) isEqualTo [])}
        || {(_unit getVariable ["A3C_TANK_SHOT_TOKEN", ""]) != ""}) exitWith {};
    _tank setVariable ["A3C_TANK_SHOT", [_token, _unit], true];
    _unit setVariable ["A3C_TANK_SHOT_TOKEN", _token, true];
    [_unit, _token, true] call A3C_ai_shared_fnc_setTankShotActive;
    _unit setVariable ["A3C_unit_is_Remote_Firing", true, true];
    {_x setVariable ["A3C_REMOTE_HANDLE", [], true];} forEach [_unit, _tank];
    _unit disableAI "AUTOTARGET";
    _claimed = true;
};
if (!_claimed) exitWith {};
A3C_HC_FOCUS_ARTY_POS = ASLToATL _targetPos;

private _tankTarget = "A3C_Supression_Target_F" createVehicle (ASLToATL _targetPos);
private _proxyPos = +_targetPos;
_proxyPos set [2, (_proxyPos select 2) - 0.5];
_tankTarget setPosASL _proxyPos;
if ({_snapObject isKindOf _x} count ["Tank", "Car"] > 0) then {
    [_tankTarget, _snapObject] remoteExec ["disableCollisionWith", _tankTarget];
    [_snapObject, _tankTarget] remoteExec ["disableCollisionWith", _snapObject];
    _tankTarget attachTo [_snapObject, [0, 0, 0]];
};
_tankTarget enableSimulation false;

private _handle = -1;
private _remoteHandle = [];
private _firedKey = format ["A3C_TANK_SHOT_FIRED_%1", _token];
private _removedKey = format ["A3C_TANK_SHOT_REMOVED_%1", _token];
private _result = "aborted before preparation";
private _valid = {
    !isNull _unit && {alive _unit} && {!isNull _tank} && {alive _tank}
    && {local _unit} && {_tank turretLocal _turret}
    && {vehicle _unit == _tank} && {_tank turretUnit _turret == _unit}
    && {_unit == gunner _tank} && {!isNull _tankTarget}
    && {(_tank getVariable ["A3C_TANK_SHOT", []]) isEqualTo [_token, _unit]}
    && {(_unit getVariable ["A3C_TANK_SHOT_TOKEN", ""]) == _token}
    && {_unit getVariable ["A3C_unit_is_Remote_Firing", false]}
};
private _prepare = {
    _result = "gunner/turret locality, crew, cancellation or ownership changed";
    if !(call _valid) exitWith {};
    // Start aiming before inspecting inventory or requesting any physical reload.
    _unit lookAt _tankTarget;
    _unit doTarget _tankTarget;
    private _aimDeadline = time + 10;
    private _isVehicleTarget = !isNull _snapObject
        && {{_snapObject isKindOf _x} count ["LandVehicle", "Air", "Ship"] > 0};
    private _category = if (_isVehicleTarget) then {"AP"} else {"HE"};

    private _weapons = _tank weaponsTurret _turret;
    private _cannons = _weapons select {
        private _weapon = _x;
        private _core = _weapon isKindOf ["CannonCore", configFile >> "CfgWeapons"];
        (_core || {(toLower getText (configFile >> "CfgWeapons" >> _weapon >> "nameSound")) find "cannon" >= 0})
        && {(compatibleMagazines _weapon) findIf {([_x, _core] call A3C_ai_shared_fnc_classifyTankShell) select 0} >= 0}
    };
    private _cannon = "";
    private _automatic = count _cannons == 1;
    if (_automatic) then {
        _cannon = _cannons select 0;
        _automatic = _cannon isKindOf ["CannonCore", configFile >> "CfgWeapons"];
    } else {
        // Keep the legacy first weapon's loaded choice when it is a cannon.
        // No automatic ammo switch for an ambiguous multi-cannon turret.
        private _legacy = _weapons param [0, ""];
        if (_legacy in _cannons) then {_cannon = _legacy;};
    };
    if (_debug) then {
        diag_log format ["[A3C] TANKSHOT %1: category=%2, snap=%3, vehicle=%4, gunner=%5, turret=%6, cannon=%7, automatic=%8", _token, _category, _snapObject, _tank, _unit, _turret, _cannon, _automatic];
    };
    _result = "no compatible cannon identified safely";
    if (_cannon == "") exitWith {};
    private _core = _cannon isKindOf ["CannonCore", configFile >> "CfgWeapons"];
    private _weaponCfg = configFile >> "CfgWeapons" >> _cannon;
    private _compatible = compatibleMagazines _cannon;
    private _stock = [];
    {
        _x params ["_magazine", "_path", "_rounds"];
        if (_path isEqualTo _turret && {_rounds > 0} && {_magazine in _compatible}) then {
            private _shell = [_magazine, _core] call A3C_ai_shared_fnc_classifyTankShell;
            if (_shell select 0) then {
                private _index = _stock findIf {(_x select 0) == _magazine};
                if (_index < 0) then {
                    _stock pushBack [_magazine, _rounds, _shell select 1, _shell select 2, _shell select 3];
                } else {
                    private _entry = _stock select _index;
                    _entry set [1, (_entry select 1) + _rounds];
                };
            };
        };
    } forEach magazinesAllTurrets _tank;

    private _initial = weaponState [_tank, _turret, _cannon];
    private _initialMag = _initial param [3, ""];
    private _muzzles = getArray (_weaponCfg >> "muzzles");
    if (_muzzles isEqualTo []) then {_muzzles = ["this"];};
    _muzzles = _muzzles apply {if (_x == "this") then {_cannon} else {_x}};
    private _fireMuzzle = _initial param [1, _muzzles select 0];
    if !(_fireMuzzle in _muzzles) then {_fireMuzzle = _muzzles select 0;};
    private _preferred = "";
    private _reason = "preferred type unavailable; keep usable loaded shell";
    private _initialShell = [_initialMag, _core] call A3C_ai_shared_fnc_classifyTankShell;
    private _loadedUnclassified = (_initial param [4, 0]) > 0
        && {_initialShell select 0} && {(_initialShell select 1) == "UNKNOWN"};
    if (_automatic && {!_loadedUnclassified}) then {
        private _matches = _stock select {(_x select 2) in [_category, "AP_HE"]};
        if !(_matches isEqualTo []) then {
            private _loadedMatch = _matches findIf {(_x select 0) == _initialMag && {(_initial param [4, 0]) > 0}};
            private _entry = _matches select (if (_loadedMatch >= 0) then {_loadedMatch} else {0});
            _preferred = _entry select 0;
            _reason = _entry select 3;
        };
    } else {
        _reason = if (_loadedUnclassified) then {
            "uncertain loaded shell classification; preserve loaded magazine"
        } else {"uncertain cannon mapping; preserve loaded magazine/mode"};
    };
    if (_preferred != "") then {
        private _matchingMuzzles = _muzzles select {
            _preferred in compatibleMagazines [_cannon, if (_x == _cannon) then {"this"} else {_x}]
        };
        // Multiple-muzzle cannons may already have the desired shell loaded.
        private _loaded = _matchingMuzzles findIf {
            private _state = weaponState [_tank, _turret, _cannon, _x];
            (_state param [3, ""]) == _preferred && {(_state param [4, 0]) > 0}
        };
        if (_loaded >= 0) then {_fireMuzzle = _matchingMuzzles select _loaded;} else {
            if !(_fireMuzzle in _matchingMuzzles) then {_fireMuzzle = _matchingMuzzles param [0, ""];};
        };
    };
    if (_debug) then {
        diag_log format ["[A3C] TANKSHOT %1: stock=[magazine,rounds,type,reason,ammo] %2; initial=%3, preferred=%4, muzzle=%5, reason=%6", _token, _stock, _initial, _preferred, _fireMuzzle, _reason];
    };
    _result = "preferred shell has no compatible cannon muzzle";
    if (_fireMuzzle == "") exitWith {};
    if !(call _valid) exitWith {_result = "ownership/cancellation changed before loading";};
    _tank selectWeaponTurret [_cannon, _turret];
    private _loadRequested = false;
    isNil {
        if !(call _valid) exitWith {};
        private _state = weaponState [_tank, _turret, _cannon, _fireMuzzle];
        if (_preferred != "" && {(_state param [3, ""]) != _preferred || {(_state param [4, 0]) <= 0}}) then {
            // One normal loading action; no inventory changes or reload-phase writes.
            _tank loadMagazine [_turret, _cannon, _preferred];
            _loadRequested = true;
        };
    };
    private _state = weaponState [_tank, _turret, _cannon, _fireMuzzle];
    private _modeCfg = if ((_state param [2, ""]) == _cannon) then {_weaponCfg} else {_weaponCfg >> (_state param [2, ""])};
    private _magCfg = configFile >> "CfgMagazines" >> (if (_preferred != "") then {_preferred} else {_initialMag});
    private _reloadTime = (getNumber (_weaponCfg >> "magazineReloadTime")) max (getNumber (_modeCfg >> "reloadTime"))
        max (getNumber (_magCfg >> "magazineReloadTime")) max (getNumber (_magCfg >> "reloadTime"));
    private _reloadTimeout = ((_reloadTime * 2 + 5) max 15) min 60;
    private _reloadDeadline = time + _reloadTimeout;
    private _ready = {
        params ["_state"];
        count _state >= 7 && {(_state select 0) == _cannon}
        && {(_state select 1) in _muzzles} && {(_state select 3) in _compatible}
        && {(_state select 4) > 0}
        && {(_state select 5) == 0} && {(_state select 6) == 0}
        && {([_state select 3, _core] call A3C_ai_shared_fnc_classifyTankShell) select 0}
    };
    private _aimed = {
        (_tank aimedAtTarget [_tankTarget, _cannon]) == 1
        || {[getPosATL _tankTarget, _unit] call MCSS_fnc_lineOfSightVehicle}
    };
    private _aimSince = -1;
    private _final = [];
    private _reloadOutcome = "ready without magazine switch";
    private _reloadFinished = false;
    if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: loadMagazine requested=%2, timeout=%3 s", _token, _loadRequested, _reloadTimeout];};
    _result = "gunner/turret ownership or cancellation changed while waiting";
    // The original ten-second aim allowance and three-second settle run alongside
    // the reload. Recheck the current aim instead of trusting an earlier position.
    while {call _valid} do {
        if (call _aimed) then {
            if (_aimSince < 0) then {_aimSince = time;};
        } else {_aimSince = -1;};
        if (_aimSince < 0 && {time >= _aimDeadline}) exitWith {_result = "turret aiming timed out";};
        _state = weaponState [_tank, _turret, _cannon, _fireMuzzle];
        private _preferredReady = ([_state] call _ready)
            && {_preferred == "" || {(_state select 3) == _preferred}};
        if (_preferredReady) then {
            _final = _state;
            _reloadFinished = true;
            _reloadOutcome = if (_loadRequested) then {"preferred reload completed"} else {"loaded shell ready"};
        } else {
            _final = [];
            if (time >= _reloadDeadline) then {
                // A fallback must also be physically loaded and fully ready.
                // Do not fire another muzzle while the requested muzzle is reloading.
                if ((_state param [6, -1]) == 0) then {
                    {
                        private _fallback = weaponState [_tank, _turret, _cannon, _x];
                        if ([_fallback] call _ready) exitWith {_final = _fallback;};
                    } forEach _muzzles;
                };
                _reloadOutcome = if (_final isEqualTo []) then {"reload timeout; no ready fallback"} else {"preferred reload failed/timed out; usable loaded shell fallback"};
                _reloadFinished = true;
            };
        };
        if (time >= _reloadDeadline && {_final isEqualTo []}) exitWith {_result = "reload timeout: no loaded shell fully ready";};
        if (_reloadFinished && {!(_final isEqualTo [])} && {_aimSince >= 0} && {time - _aimSince >= 3}) exitWith {};
        if (time >= _reloadDeadline + 10) exitWith {_result = "aim/reload readiness did not stabilize";};
        sleep 0.1;
    };
    if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: reload=%2, candidate=%3", _token, _reloadOutcome, _final];};
    if (_final isEqualTo [] || {!(call _valid)}) exitWith {};
    if (_aimSince < 0 || {time - _aimSince < 3} || {!(call _aimed)}) exitWith {};

    // Install on the local gunner: remote vehicle Fired handlers can be camera-
    // range limited when the driver owns the vehicle on another machine.
    isNil {
        if (!(call _valid) || {!(call _aimed)}) exitWith {};
        private _expectedMagazine = _final select 3;
        _final = weaponState [_tank, _turret, _cannon, _final select 1, _final select 2];
        if !([_final] call _ready) exitWith {_result = "cannon readiness changed before firing";};
        if ((_final select 3) != _expectedMagazine) exitWith {_result = "validated magazine changed before firing";};
        if (((weaponState [_tank, _turret, _cannon, _fireMuzzle]) param [6, -1]) != 0) exitWith {_result = "magazine reload still in progress";};
        // BIS_fnc_fire uses UseMagazine for vehicle weapons. Additionally prove
        // that the instance is loaded in this muzzle, rather than choosing a spare
        // of the same class/count. Cross-check its ID/creator against our turret.
        private _loaded = (magazinesAmmoFull _tank) select {
            count _x >= 7 && {(_x select 0) == (_final select 3)}
            && {(_x select 1) == (_final select 4)} && {_x select 2}
            && {(_x select 4) == (_final select 1)}
        };
        private _instances = (magazinesAllTurrets _tank) select {
            _x params ["_mag", "_path", "_rounds", "_id", "_creator"];
            _path isEqualTo _turret && {_mag == (_final select 3)} && {_rounds == (_final select 4)}
            && {_loaded findIf {(_x select 5) == _id && {(_x select 6) == _creator}} >= 0}
        };
        if (count _instances != 1) exitWith {_result = "no unique loaded magazine instance in cannon turret";};
        if (_weapons findIf {_x != _cannon && {(_final select 3) in compatibleMagazines _x}} >= 0)
            exitWith {_result = "loaded magazine also fits another turret weapon; ambiguous firing action";};
        private _instance = _instances select 0;
        _unit setVariable ["A3C_TANK_SHOT_CAPTURE", [_tank, _token, _turret, _cannon, _final select 1, _final select 3, _tankTarget]];
        _handle = _unit addEventHandler ["FiredMan", {
            params ["_gunner", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_firedVehicle"];
            private _capture = _gunner getVariable ["A3C_TANK_SHOT_CAPTURE", []];
            if (count _capture != 7) exitWith {};
            _capture params ["_tank", "_token", "_turret", "_cannon", "_expectedMuzzle", "_expectedMagazine", "_target"];
            private _var = _tank getVariable ["A3C_REMOTE_HANDLE", []];
            if (count _var != 5 || {(_var select 0) != _thisEventHandler} || {(_var select 1) != _target}
                || {!(_target getVariable ["A3C_TANK_SHOT_CAPTURE_OPEN", false])}) exitWith {};
            if (!local _gunner || {!(_tank turretLocal _turret)} || {_firedVehicle != _tank}
                || {!((_tank getVariable ["A3C_TANK_SHOT", []]) isEqualTo [_token, _gunner])}) exitWith {};
            private _matching = _weapon == _cannon && {_muzzle == _expectedMuzzle} && {_magazine == _expectedMagazine};
            if (missionNamespace getVariable ["A3C_DEBUG", false]) then {
                diag_log format ["[A3C] TANKSHOT %1: FIRED weapon=%2, muzzle=%3, mode=%4, magazine=%5, ammo=%6, projectileLocal=%7, matching=%8", _token, _weapon, _muzzle, _mode, _magazine, _ammo, local _projectile, _matching];
            };
            if (!_matching) exitWith {};
            _target setVariable ["A3C_TANK_SHOT_CAPTURE_OPEN", false];
            _gunner removeEventHandler ["FiredMan", _thisEventHandler];
            _gunner setVariable [format ["A3C_TANK_SHOT_REMOVED_%1", _token], true];
            // Receipt survives a close shot deleting its proxy before the wait polls.
            _gunner setVariable [format ["A3C_TANK_SHOT_FIRED_%1", _token], !isNull _projectile];
            _target setVariable ["A3C_Remote_Projectile_Captured", !isNull _projectile];
            _gunner setVariable ["A3C_unit_is_Remote_Firing", false, true];
            [_projectile, _target, "DIRECT"] call A3C_ai_shared_fnc_guideProjectileMissile;
            [_projectile, _target] spawn {
                params ["_projectile", "_target"];
                waitUntil {sleep 0.01; isNull _projectile || {!alive _projectile}};
                if (!isNull _target) then {deleteVehicle _target;};
            };
        }];
        _remoteHandle = [_handle, _tankTarget, objNull, _snapObject, behaviour _tank];
        _tank setVariable ["A3C_REMOTE_HANDLE", _remoteHandle, true];
        _tankTarget setVariable ["A3C_TANK_SHOT_CAPTURE_OPEN", true];
        if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: final=%2, ready=true, aimed=true, UseMagazine instance=%3", _token, _final, _instance];};
        _result = "firing action issued once; awaiting capture";
        // Execute here on the gunner/turret owner, never queue a fire on driver owner.
        _tank action ["UseMagazine", _tank, _unit, _instance select 4, _instance select 3];
    };
    if (_handle < 0) exitWith {};
    private _captureDeadline = time + 3;
    waitUntil {
        sleep 0.05;
        _unit getVariable [_firedKey, false]
        || {!(call _valid)} || {time >= _captureDeadline}
    };
    _result = if (_unit getVariable [_firedKey, false]) then {"shot captured"} else {"no matching Fired capture; no retry"};
};
call _prepare;

// Event IDs belong to the installing machine, even after gunner locality changes.
private _captured = _unit getVariable [_firedKey, false];
isNil {
    _tankTarget setVariable ["A3C_TANK_SHOT_CAPTURE_OPEN", false];
    if (_handle >= 0 && {!(_unit getVariable [_removedKey, false])}) then {
        _unit removeEventHandler ["FiredMan", _handle];
    };
    _unit setVariable ["A3C_TANK_SHOT_CAPTURE", nil];
    _unit setVariable [_firedKey, nil];
    _unit setVariable [_removedKey, nil];
    if (!(_remoteHandle isEqualTo []) && {(_tank getVariable ["A3C_REMOTE_HANDLE", []]) isEqualTo _remoteHandle}) then {
        _tank setVariable ["A3C_REMOTE_HANDLE", [], true];
    };
};
if (!_captured) then {deleteVehicle _tankTarget;};
if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: %2; capture closed, restoring order", _token, _result];};

// Only recovery forwards after migration. No reload or firing worker survives it.
private _restore = {
    params ["_unit", "_tank", "_token", "_autoTarget", "_restoreFunc"];
    if (!isNull _unit && {(_unit getVariable ["A3C_TANK_SHOT_TOKEN", ""]) != _token}) exitWith {};
    if (!isNull _unit && {!local _unit}) exitWith {
        [_this, _restoreFunc] remoteExec ["BIS_fnc_spawn", _unit];
    };
    isNil {
        if (!isNull _unit && {(_unit getVariable ["A3C_TANK_SHOT_TOKEN", ""]) != _token}) exitWith {};
        if (!isNull _unit && {!local _unit}) exitWith {
            [_this, _restoreFunc] remoteExec ["BIS_fnc_spawn", _unit];
        };
        if (!isNull _unit) then {
            _unit doTarget objNull;
            _unit lookAt objNull;
            if (_autoTarget) then {_unit enableAI "AUTOTARGET";} else {_unit disableAI "AUTOTARGET";};
            _unit setVariable ["A3C_unit_is_Remote_Firing", false, true];
            _unit setVariable ["A3C_TANK_SHOT_TOKEN", nil, true];
        };
        if ((_tank getVariable ["A3C_TANK_SHOT", []]) isEqualTo [_token, _unit]) then {
            _tank setVariable ["A3C_TANK_SHOT", [], true];
        };
        [_unit, _token, false] call A3C_ai_shared_fnc_setTankShotActive;
    };
};
[_unit, _tank, _token, _autoTarget, _restore] call _restore;

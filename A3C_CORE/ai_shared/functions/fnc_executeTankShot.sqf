// A3C_ai_shared_fnc_executeTankShot
// Scheduled, gunner-owner execution. Vehicle ownership may belong to the driver.
params ["_unit", "_targetPos", ["_snapObject", objNull, [objNull]], ["_dispatches", 0, [0]], ["_orderContext", [], [[]]], ["_worker", false]];
// Legacy/direct callers also register before touching a reservation.
if (_orderContext isEqualTo []) exitWith {
    private _commander = if (isRemoteExecuted) then {remoteExecutedOwner} else {clientOwner};
    private _sequence = 0;
    isNil {
        _sequence = 1 + (missionNamespace getVariable ["A3C_TANK_SHOT_SEQUENCE", 0]);
        missionNamespace setVariable ["A3C_TANK_SHOT_SEQUENCE", _sequence];
    };
    private _context = [format ["TANK:%1:%2:%3:%4", _commander, clientOwner, diag_tickTime, _sequence], _commander, format ["%1 / %2", groupId group _unit, name _unit]];
    ["DISPATCH", [_unit, _targetPos, _snapObject, _context]] call A3C_ai_shared_fnc_manageTankShot;
};
private _token = _orderContext select 0;
if (!_worker) exitWith {
    // A separate observer detects a stopped/terminated execution script. The
    // server deadline also survives loss of this entire installing machine.
    private _args = +_this;
    _args set [5, true];
    private _script = _args spawn A3C_ai_shared_fnc_executeTankShot;
    private _key = format ["A3C_TANK_SHOT_WORKER_%1", _token];
    _unit setVariable [_key, _script];
    private _observerDeadline = time + 105;
    waitUntil {sleep 0.25; scriptDone _script || {time >= _observerDeadline}};
    if !(_unit getVariable [format ["A3C_TANK_SHOT_DONE_%1", _token], false]) then {
        ["FINISH", [_token, "FAILED", if (scriptDone _script) then {"UNEXPECTED"} else {"EXECUTION_TIMEOUT"}, true]] call A3C_ai_shared_fnc_manageTankShot;
        private _payload = _unit getVariable [format ["A3C_TANK_SHOT_RECOVERY_%1", _token], []];
        if !(_payload isEqualTo []) then {
            ["INSTALL", _payload, true] call A3C_ai_shared_fnc_recoverTankShot;
            ["OWNER", _payload] call A3C_ai_shared_fnc_recoverTankShot;
        };
    };
    _unit setVariable [_key, nil];
    _unit setVariable [format ["A3C_TANK_SHOT_DONE_%1", _token], nil];
    _unit setVariable [format ["A3C_TANK_SHOT_RECOVERY_%1", _token], nil, true];
    _unit setVariable [format ["A3C_TANK_SHOT_STOP_%1", _token], nil];
};
private _finish = {
    params ["_outcome", "_reason"];
    _unit setVariable [format ["A3C_TANK_SHOT_DONE_%1", _token], true];
    ["FINISH", [_token, _outcome, _reason]] call A3C_ai_shared_fnc_manageTankShot;
};
private _debug = missionNamespace getVariable ["A3C_DEBUG", false];
if (time > (_orderContext param [3, time + 100])) exitWith {["FAILED", "DISPATCH_TIMEOUT"] call _finish;};
if (isNull _unit || {!alive _unit}) exitWith {
    ["FAILED", "DESTROYED"] call _finish;
    if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: rejected before claim: invalid/dead gunner %2", _token, _unit];};
};
if (!local _unit) exitWith {
    if (_dispatches < 2) then {
        _unit setVariable [format ["A3C_TANK_SHOT_DONE_%1", _token], true];
        if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: forwarding before claim: gunner=%2, owner=%3, dispatch=%4", _token, _unit, owner _unit, _dispatches + 1];};
        [[_unit, _targetPos, _snapObject, _dispatches + 1, _orderContext], A3C_ai_shared_fnc_executeTankShot]
            remoteExec ["BIS_fnc_spawn", _unit];
    } else {
        ["FAILED", "LOCALITY_CHANGED"] call _finish;
        if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: rejected before claim: gunner ownership did not stabilize", _token];};
    };
};

private _tank = vehicle _unit;
private _turret = _tank unitTurret _unit;
if (_tank == _unit || {_unit != gunner _tank} || {_turret isEqualTo []}
    || {!(_tank turretLocal _turret)}) exitWith {
    ["FAILED", if (_tank == _unit || {_unit != gunner _tank} || {_turret isEqualTo []}) then {"UNAVAILABLE"} else {"LOCALITY_CHANGED"}] call _finish;
    if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: rejected before claim: invalid/nonlocal gunner turret (vehicle=%2, gunner=%3, turret=%4)", _token, _tank, _unit, _turret];};
};

if (_unit in (A3C_SUPPRESSION_UNITS_SQ + A3C_SUPPRESSION_UNITS_AI)) exitWith {["FAILED", "SUPPRESSING"] call _finish;};
if (!((_unit getVariable ["A3C_AT_SHOT", []]) isEqualTo [])
    || {_unit getVariable ["A3C_unit_is_Remote_Firing", false]}) exitWith {["FAILED", "BUSY"] call _finish;};
private _autoTarget = _unit checkAIFeature "AUTOTARGET";
private _checkpoint = {
    params ["_proxy", ["_eventHandle", -1], ["_remote", []]];
    private _payload = [_unit, _tank, _token, _autoTarget, _proxy, _eventHandle, _remote, clientOwner];
    _unit setVariable [format ["A3C_TANK_SHOT_RECOVERY_%1", _token], _payload, true];
    ["CLAIM", [_token, _payload]] call A3C_ai_shared_fnc_manageTankShot;
};
private _claimed = false;
private _claimReason = "LOCALITY_CHANGED";
isNil {
    if (!local _unit || {!(_tank turretLocal _turret)}) exitWith {};
    if (_unit in A3C_REMFIRE_UNITS_ACTIVE
        || {!((_tank getVariable ["A3C_TANK_SHOT", []]) isEqualTo [])}
        || {(_unit getVariable ["A3C_TANK_SHOT_TOKEN", ""]) != ""}) exitWith {
        _claimReason = "BUSY";
    };
    // Save recovery before the first owned-state mutation, without yielding.
    [objNull] call _checkpoint;
    if (_unit getVariable [format ["A3C_TANK_SHOT_STOP_%1", _token], false]) exitWith {_claimReason = "EXECUTION_TIMEOUT";};
    _tank setVariable ["A3C_TANK_SHOT", [_token, _unit], true];
    _unit setVariable ["A3C_TANK_SHOT_TOKEN", _token, true];
    [_unit, _token, true] call A3C_ai_shared_fnc_setTankShotActive;
    _unit setVariable ["A3C_unit_is_Remote_Firing", true, true];
    {_x setVariable ["A3C_REMOTE_HANDLE", [], true];} forEach [_unit, _tank];
    _unit disableAI "AUTOTARGET";
    _claimed = true;
};
if (!_claimed) exitWith {
    ["FAILED", _claimReason] call _finish;
    if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: rejected before claim: %2", _token, _claimReason];};
};
A3C_HC_FOCUS_ARTY_POS = ASLToATL _targetPos;

private _tankTarget = objNull;
isNil {
    _tankTarget = "A3C_Supression_Target_F" createVehicle (ASLToATL _targetPos);
    [_tankTarget] call _checkpoint;
};
private _proxyPos = +_targetPos;
_proxyPos set [2, (_proxyPos select 2) - 0.5];
_tankTarget setPosASL _proxyPos;
if ({_snapObject isKindOf _x} count ["Tank", "Car"] > 0) then {
    [_tankTarget, _snapObject] remoteExec ["disableCollisionWith", _tankTarget];
    [_snapObject, _tankTarget] remoteExec ["disableCollisionWith", _snapObject];
    _tankTarget attachTo [_snapObject, [0, 0, 0]];
};
_tankTarget enableSimulation false;
if (_debug) then {
    diag_log format ["[A3C] TANKSHOT %1: claimed; proxy=%2, designationASL=%3, proxyASL=%4, attachedTo=%5, proxyATL=%6, proxyAimASL=%7", _token, _tankTarget, _targetPos, getPosASL _tankTarget, attachedTo _tankTarget, getPosATL _tankTarget, aimPos _tankTarget];
};

private _handle = -1;
private _remoteHandle = [];
private _firedKey = format ["A3C_TANK_SHOT_FIRED_%1", _token];
private _removedKey = format ["A3C_TANK_SHOT_REMOVED_%1", _token];
private _result = "UNEXPECTED";
private _aimSummary = [];
private _invalidReason = {
    switch (true) do {
        case (isNull _unit || {!alive _unit} || {isNull _tank} || {!alive _tank}): {"DESTROYED"};
        case (!local _unit || {!(_tank turretLocal _turret)}): {"LOCALITY_CHANGED"};
        case (_unit getVariable [format ["A3C_TANK_SHOT_STOP_%1", _token], false]): {"EXECUTION_TIMEOUT"};
        case (vehicle _unit != _tank || {_tank turretUnit _turret != _unit} || {_unit != gunner _tank}): {"CREW_CHANGED"};
        case (!(_unit getVariable ["A3C_unit_is_Remote_Firing", false])
            || {(_unit getVariable ["A3C_TANK_SHOT_TOKEN", ""]) != _token}
            || {!((_tank getVariable ["A3C_TANK_SHOT", []]) isEqualTo [_token, _unit])}): {"CANCELLED"};
        default {"UNEXPECTED"};
    }
};
private _valid = {
    !isNull _unit && {alive _unit} && {!isNull _tank} && {alive _tank}
    && {local _unit} && {_tank turretLocal _turret}
    && {vehicle _unit == _tank} && {_tank turretUnit _turret == _unit}
    && {_unit == gunner _tank} && {!isNull _tankTarget}
    && {(_tank getVariable ["A3C_TANK_SHOT", []]) isEqualTo [_token, _unit]}
    && {(_unit getVariable ["A3C_TANK_SHOT_TOKEN", ""]) == _token}
    && {_unit getVariable ["A3C_unit_is_Remote_Firing", false]}
    && {!(_unit getVariable [format ["A3C_TANK_SHOT_STOP_%1", _token], false])}
};
private _prepare = {
    _result = "INVALID_STATE";
    if !(call _valid) exitWith {};
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
    _result = "NO_CANNON";
    if (_cannon == "") exitWith {};
    if !(call _valid) exitWith {_result = "INVALID_STATE";};
    // Select the validated cannon before the first aim request, including on a
    // fresh tank whose initially selected weapon may be empty or a coax.
    if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: initial selected turret state=%2; selecting cannon=%3", _token, weaponState [_tank, _turret], _cannon];};
    _tank selectWeaponTurret [_cannon, _turret];
    private _watchObject = if (_isVehicleTarget) then {
        if (attachedTo _tankTarget == _snapObject) then {_tankTarget} else {_snapObject}
    } else {objNull};
    private _watchPosAGL = ASLToAGL _targetPos;
    private _aimStarted = time;
    // Sample both tests independently. The MCSS alternative is only a 13-degree
    // horizontal arc, not cannon alignment, visibility or a ballistic solution.
    private _sampleAim = {
        private _quality = _tank aimedAtTarget [_tankTarget, _cannon];
        private _arc = [getPosATL _tankTarget, _unit] call MCSS_fnc_lineOfSightVehicle;
        private _direction = _tank weaponDirection _cannon;
        private _errors = [-1, -1, -1];
        if (_direction isEqualTypeArray [0, 0, 0] && {{finite _x} count _direction == 3}
            && {vectorMagnitude _direction > 0.01}) then {
            _direction = vectorNormalized _direction;
            // Primary-gunner weaponDirection is supported here. eyePos is an
            // approximate origin; these angles do not measure ballistic zeroing.
            private _origin = eyePos _unit;
            _errors = [_targetPos, getPosASL _tankTarget, if (isNull _watchObject) then {_targetPos} else {getPosASL _watchObject}] apply {
                private _delta = _x vectorDiff _origin;
                if (vectorMagnitude _delta > 0.01) then {
                    acos (((_direction vectorDotProduct (vectorNormalized _delta)) max -1) min 1)
                } else {-1}
            };
        } else {_direction = [];};
        [_quality, _arc, _quality == 1 || {_arc}, _direction, _errors select 0, _errors select 1, _errors select 2]
    };
    private _aimInstructions = 0;
    private _issueAim = {
        params ["_phase", ["_log", true]];
        if !(call _valid) exitWith {false};
        _unit lookAt _tankTarget;
        _unit doTarget _tankTarget;
        // Position orders must not depend on an invisible static proxy being
        // accepted as a combat target. doWatch also controls gunner turret aim.
        if (!isNull _watchObject) then {
            _unit doWatch _watchObject;
        } else {_unit doWatch _watchPosAGL;};
        _aimInstructions = _aimInstructions + 1;
        if (_debug && {_log}) then {
            diag_log format ["[A3C] TANKSHOT %1: aim instruction %2 (%3), watchObject=%4, watchPosAGL=%5, selected=%6, AUTOTARGET=%7, WEAPONAIM=%8, TARGET=%9, sample=[quality,arc,accepted,direction,designationDeg,proxyDeg,watchDeg] %10", _token, _aimInstructions, _phase, _watchObject, _watchPosAGL, weaponState [_tank, _turret], _unit checkAIFeature "AUTOTARGET", _unit checkAIFeature "WEAPONAIM", _unit checkAIFeature "TARGET", call _sampleAim];
        };
        true
    };
    if !(["cannon selected; first aim"] call _issueAim) exitWith {_result = "INVALID_STATE";};
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
    _result = "AMMO_MAPPING";
    if (_fireMuzzle == "") exitWith {};
    if !(call _valid) exitWith {_result = "INVALID_STATE";};
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
    if (_loadRequested) then {["magazine reload requested"] call _issueAim;};
    private _state = weaponState [_tank, _turret, _cannon, _fireMuzzle];
    private _modeCfg = if ((_state param [2, ""]) == _cannon) then {_weaponCfg} else {_weaponCfg >> (_state param [2, ""])};
    private _magCfg = configFile >> "CfgMagazines" >> (if (_preferred != "") then {_preferred} else {_initialMag});
    private _reloadTime = (getNumber (_weaponCfg >> "magazineReloadTime")) max (getNumber (_modeCfg >> "reloadTime"))
        max (getNumber (_magCfg >> "magazineReloadTime")) max (getNumber (_magCfg >> "reloadTime"));
    private _reloadTimeout = ((_reloadTime * 2 + 5) max 15) min 60;
    private _reloadDeadline = time + _reloadTimeout;
    // Start the independent aim clock on observed physical readiness, rather
    // than charging unused predicted reload time. Keep the existing hard bound.
    private _aimDeadline = -1;
    private _readyAt = -1;
    private _traverseExtended = false;
    private _waitDeadline = _reloadDeadline + 10 + 3;
    private _ready = {
        params ["_state"];
        count _state >= 7 && {(_state select 0) == _cannon}
        && {(_state select 1) in _muzzles} && {(_state select 3) in _compatible}
        && {(_state select 4) > 0}
        && {(_state select 5) == 0} && {(_state select 6) == 0}
        && {([_state select 3, _core] call A3C_ai_shared_fnc_classifyTankShell) select 0}
    };
    private _aimed = {
        private _sample = call _sampleAim;
        _aimSummary set [9, _sample];
        if !(_sample select 2) then {_aimSummary set [4, true];};
        if (_previousCannonAim && {(_sample select 0) != 1}) then {_aimSummary set [5, true];};
        _sample select 2
    };
    private _aimSince = -1;
    private _firstAim = -1;
    private _firstCannonAim = -1;
    private _aimEstablished = false;
    private _aimLost = false;
    private _cannonAimLost = false;
    private _previousAim = false;
    private _previousCannonAim = false;
    private _progressError = -1;
    private _progressDirection = [];
    private _lastProgress = -1;
    private _final = [];
    private _reloadOutcome = if (_loadRequested) then {"waiting for preferred reload"} else {"waiting for loaded shell readiness"};
    private _reloadFinished = false;
    private _reloadAimPending = _loadRequested;
    private _reloadWasBusy = false;
    private _nextAimRefresh = time + 2;
    private _nextAimLog = time;
    private _lastAimFlags = [];
    private _nextTransitionLog = time;
    if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: loadMagazine requested=%2, muzzle=%3, state=%4, reloadTimeout=%5 s, aimAllowance=10 s after readiness (+10 s once for recent traversal, capped), waitBound=%6 s; tankASL=%7, eyeASL=%8, designationATL=%9, proxyAGL=%10, turretLimits=%11", _token, _loadRequested, _fireMuzzle, _state, _reloadTimeout, _waitDeadline - time, getPosASL _tank, eyePos _unit, ASLToATL _targetPos, ASLToAGL getPosASL _tankTarget, _tank getTurretLimits _turret];};
    _result = "INVALID_STATE";
    // Aim and reload progress together; refreshes never restart either clock.
    while {call _valid} do {
        _state = weaponState [_tank, _turret, _cannon, _fireMuzzle];
        if ((_state param [6, -1]) > 0) then {
            _reloadWasBusy = true;
            _reloadAimPending = true;
        };
        if (_reloadAimPending && {(_state param [6, -1]) == 0}
            && {_reloadWasBusy || {(_state param [3, ""]) == _preferred && {(_state param [4, 0]) > 0}}}) then {
            ["magazine reload phase completed"] call _issueAim;
            _reloadAimPending = false;
            _reloadWasBusy = false;
            _aimSince = -1;
            _nextAimRefresh = time + 2;
        };
        private _sample = call _sampleAim;
        _sample params ["_quality", "_arc", "_isAimed", "_direction", "_designationError", "_proxyError", "_error"];
        if (!_isAimed && {time >= _nextAimRefresh}) then {
            ["recover lost aim", false] call _issueAim;
            _nextAimRefresh = time + 2;
        };
        if (_isAimed) then {
            if (_aimSince < 0) then {_aimSince = time;};
            if (_firstAim < 0) then {_firstAim = time - _aimStarted;};
            if (time - _aimSince >= 3) then {_aimEstablished = true;};
        } else {_aimSince = -1;};
        if (_previousAim && {!_isAimed}) then {_aimLost = true;};
        if (_quality == 1 && {_firstCannonAim < 0}) then {_firstCannonAim = time - _aimStarted;};
        if (_previousCannonAim && {_quality != 1}) then {_cannonAimLost = true;};
        _previousAim = _isAimed;
        _previousCannonAim = _quality == 1;
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
        if (!(_final isEqualTo []) && {_readyAt < 0}) then {
            _readyAt = time;
            _aimDeadline = (time + 10) min (_waitDeadline - 3);
            if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: physical ammo ready at time=%2, elapsed=%3 s, phases=[%4,%5], magazine=%6, aimRemaining=%7 s", _token, _readyAt, _readyAt - _aimStarted, _final select 5, _final select 6, _final select 3, _aimDeadline - time];};
        };
        // Significant decreasing angular error is evidence of traversal toward
        // the watch point. Unknown direction earns no extension; never gate fire
        // on this approximate angle or treat horizontal fallback as cannon aim.
        if (_error >= 0) then {
            if (_progressError < 0 || {_error > _progressError + 1}) then {
                _progressError = _error;
                _progressDirection = +_direction;
            };
            if (_error <= _progressError - 1
                && {acos (((_direction vectorDotProduct _progressDirection) max -1) min 1) >= 0.5}) then {
                _lastProgress = time;
                _progressError = _error;
                _progressDirection = +_direction;
            };
        };
        if (_readyAt >= 0 && {!_traverseExtended} && {time >= _aimDeadline}
            && {_lastProgress >= _readyAt && {time - _lastProgress <= 3}}
            && {_aimDeadline < _waitDeadline - 3}) then {
            _aimDeadline = (_aimDeadline + 10) min (_waitDeadline - 3);
            _traverseExtended = true;
            if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: bounded traversal extension; lastProgress=%2, errorDeg=%3, aimRemaining=%4 s", _token, _lastProgress - _aimStarted, _error, _aimDeadline - time];};
        };
        private _flags = [_quality == 1, _arc, !(_final isEqualTo []), (_state param [5, -1]) > 0, (_state param [6, -1]) > 0, (weaponState [_tank, _turret]) param [0, ""]];
        if (_debug && {time >= _nextAimLog || {!(_flags isEqualTo _lastAimFlags) && {time >= _nextTransitionLog}}}) then {
            diag_log format ["[A3C] TANKSHOT %1: aim sample elapsed=%2 s, aimedAtTarget=%3, horizontalArc=%4, accepted=%5, settle=%6 s, firstAccepted=%7 s, firstCannon=%8 s, settledEver=%9, acceptedLost=%10, cannonLost=%11, direction=%12, designationDeg=%13, proxyDeg=%14, state=%15, selected=%16, aimRemaining=%17 s, reloadRemaining=%18 s, proxyASL=%19, attachedTo=%20", _token, time - _aimStarted, _quality, _arc, _isAimed, if (_aimSince < 0) then {0} else {time - _aimSince}, _firstAim, _firstCannonAim, _aimEstablished, _aimLost, _cannonAimLost, _direction, _designationError, _proxyError, _state, weaponState [_tank, _turret], if (_readyAt < 0) then {-1} else {_aimDeadline - time}, _reloadDeadline - time, getPosASL _tankTarget, attachedTo _tankTarget];
            _lastAimFlags = _flags;
            _nextTransitionLog = time + 1;
            _nextAimLog = time + 5;
        };
        if (time >= _reloadDeadline && {_final isEqualTo []}) exitWith {_result = "RELOAD_TIMEOUT";};
        if (_reloadFinished && {!(_final isEqualTo [])} && {_aimSince >= 0} && {time - _aimSince >= 3}) exitWith {_result = "AIM_READY";};
        if (!(_final isEqualTo []) && {_readyAt >= 0} && {time >= _aimDeadline}
            && {_aimSince < 0 || {time >= _aimDeadline + 3}}) exitWith {
            _result = if (_aimEstablished && {_aimLost}) then {"AIM_LOST"} else {"AIM_TIMEOUT"};
        };
        if (time >= _waitDeadline) exitWith {_result = if (_aimEstablished && {_aimLost}) then {"AIM_LOST"} else {"AIM_TIMEOUT"};};
        sleep 0.1;
    };
    _aimSummary = [time - _aimStarted, _firstAim, _firstCannonAim, _aimEstablished, _aimLost, _cannonAimLost, if (_readyAt < 0) then {-1} else {_readyAt - _aimStarted}, _traverseExtended, _aimInstructions, call _sampleAim];
    if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: reload=%2, candidate=%3", _token, _reloadOutcome, _final];};
    if (_final isEqualTo []) exitWith {
        if (_result == "RELOAD_TIMEOUT") then {
            // Report current availability; inventory can change during preparation.
            private _available = (magazinesAllTurrets _tank) findIf {
                _x params ["_magazine", "_path", "_rounds"];
                _path isEqualTo _turret && {_rounds > 0} && {_magazine in _compatible}
                    && {([_magazine, _core] call A3C_ai_shared_fnc_classifyTankShell) select 0}
            };
            private _loadedUsable = (_state param [4, 0]) > 0
                && {([_state param [3, ""], _core] call A3C_ai_shared_fnc_classifyTankShell) select 0};
            if (_available < 0 && {!_loadedUsable}) then {_result = "NO_AMMO";};
        };
    };
    // A retained ready candidate does not mean the loop succeeded. In particular,
    // preserve its AIM_TIMEOUT/AIM_LOST rather than replacing it in the final guard.
    if (_result != "AIM_READY") exitWith {};
    if !(call _valid) exitWith {_result = "INVALID_STATE";};
    if (_aimSince < 0 || {time - _aimSince < 3} || {!(call _aimed)}) exitWith {_result = "AIM_LOST";};

    // Install on the local gunner: remote vehicle Fired handlers can be camera-
    // range limited when the driver owns the vehicle on another machine.
    isNil {
        if !(call _valid) exitWith {_result = "INVALID_STATE";};
        if !(call _aimed) exitWith {_result = "AIM_LOST";};
        private _expectedMagazine = _final select 3;
        _final = weaponState [_tank, _turret, _cannon, _final select 1, _final select 2];
        if !([_final] call _ready) exitWith {_result = "NOT_READY";};
        if ((_final select 3) != _expectedMagazine) exitWith {_result = "AMMO_CHANGED";};
        if (((weaponState [_tank, _turret, _cannon, _fireMuzzle]) param [6, -1]) != 0) exitWith {_result = "RELOAD_TIMEOUT";};
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
        if (count _instances != 1) exitWith {_result = "AMMO_MAPPING";};
        if (_weapons findIf {_x != _cannon && {(_final select 3) in compatibleMagazines _x}} >= 0)
            exitWith {_result = "AMMO_MAPPING";};
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
                diag_log format ["[A3C] TANKSHOT %1: FiredMan event weapon=%2, muzzle=%3, mode=%4, magazine=%5, ammo=%6, projectileLocal=%7, matching=%8", _token, _weapon, _muzzle, _mode, _magazine, _ammo, local _projectile, _matching];
            };
            if (!_matching) exitWith {};
            _target setVariable ["A3C_TANK_SHOT_CAPTURE_OPEN", false];
            _gunner removeEventHandler ["FiredMan", _thisEventHandler];
            _gunner setVariable [format ["A3C_TANK_SHOT_REMOVED_%1", _token], true];
            // Receipt survives a close shot deleting its proxy before the wait polls.
            _gunner setVariable [format ["A3C_TANK_SHOT_FIRED_%1", _token], !isNull _projectile, true];
            _target setVariable ["A3C_Remote_Projectile_Captured", !isNull _projectile, true];
            _target setVariable ["A3C_TANK_SHOT_PROJECTILE", _projectile, true];
            if (!isNull _projectile) then {["CAPTURED", [_token, _projectile]] call A3C_ai_shared_fnc_manageTankShot;};
            _gunner setVariable ["A3C_unit_is_Remote_Firing", false, true];
            [_projectile, _target, "DIRECT"] call A3C_ai_shared_fnc_guideProjectileMissile;
            [_projectile, _target] spawn {
                params ["_projectile", "_target"];
                waitUntil {sleep 0.01; isNull _projectile || {!alive _projectile}};
                if (!isNull _target) then {deleteVehicle _target;};
            };
        }];
        private _handlers = missionNamespace getVariable ["A3C_TANK_SHOT_HANDLERS", createHashMap];
        _handlers set [_token, [_unit, _handle]];
        missionNamespace setVariable ["A3C_TANK_SHOT_HANDLERS", _handlers];
        _remoteHandle = [_handle, _tankTarget, objNull, _snapObject, behaviour _tank];
        _tank setVariable ["A3C_REMOTE_HANDLE", _remoteHandle, true];
        _tankTarget setVariable ["A3C_TANK_SHOT_CAPTURE_OPEN", true, true];
        [_tankTarget, _handle, _remoteHandle] call _checkpoint;
        if !(call _valid) exitWith {_result = "INVALID_STATE";};
        if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: final=%2, ready=true, aimed=true, UseMagazine instance=%3", _token, _final, _instance];};
        _result = "NO_PROJECTILE";
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
    _result = if (_unit getVariable [_firedKey, false]) then {"CONFIRMED_PROJECTILE"} else {"NO_PROJECTILE"};
};
call _prepare;

// The server owns completion and retries owner-local restoration independently.
// Remove local capture immediately, even if this unit has already migrated.
private _captured = _unit getVariable [_firedKey, false];
private _matchingFired = _unit getVariable [_removedKey, false];
private _payload = [_unit, _tank, _token, _autoTarget, _tankTarget, _handle, _remoteHandle, clientOwner];
if (!_captured && {!_matchingFired} && {_result in ["INVALID_STATE", "NO_PROJECTILE"]}
    && {!(call _valid)}) then {_result = call _invalidReason;};
if (!_captured && {_result == "INVALID_STATE"}) then {_result = call _invalidReason;};
if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: completion requested reason=%2; aim summary=[elapsed,firstAccepted,firstCannon,settledEver,acceptedLost,cannonLost,readyElapsed,traverseExtended,watchRequests,lastSample] %3; installer cleanup started", _token, _result, _aimSummary];};
["INSTALL", _payload] call A3C_ai_shared_fnc_recoverTankShot;
[if (_captured) then {"FIRED"} else {if (_result == "CANCELLED") then {"CANCELLED"} else {"FAILED"}},
    if (_captured) then {"CONFIRMED_PROJECTILE"} else {_result}] call _finish;

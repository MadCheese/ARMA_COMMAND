// A3C_ai_shared_fnc_guideProjectileMissile

params [
    ["_projectile", objNull, [objNull]],
    ["_target", objNull, [objNull]],
    ["_policy", "MISSILE", [""]],
    ["_debug", missionNamespace getVariable ["A3C_DEBUG", false], [true]]
];

// Atomically claim this local projectile before a scheduled caller can yield.
isNil {
    private _ammo = typeOf _projectile;
    private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
    private _aceLoaded = isClass (configFile >> "CfgPatches" >> "ace_main")
        || {isClass (configFile >> "CfgPatches" >> "ace_missileguidance")}
        || {!isNil "ace_missileguidance_fnc_onFired"};
    private _rejectReason = switch (true) do {
        case (isNull _projectile || {!alive _projectile}): {"PROJECTILE_GONE"};
        case (!local _projectile): {"NOT_LOCAL"};
        case (isNull _target): {"TARGET_GONE"};
        case (!(_policy in ["DIRECT", "MISSILE", "OVERFLY"])): {"INVALID_POLICY"};
        case (_projectile getVariable ["A3C_Guidance_Started", false]): {"ALREADY_CLAIMED"};
        case ((_projectile getVariable ["A3C_OW_MissileGuidanceOwner", ""]) != ""): {"OTHER_GUIDANCE_OWNER"};
        // Also protect remote-launch/other callers, including ACE AI guidance disabled.
        case (_aceLoaded && {getNumber (_ammoCfg >> "ace_missileguidance" >> "enabled") == 1}): {"ACE_RESERVED"};
        default {""};
    };
    if (_rejectReason != "") exitWith {
        if (_debug) then {diag_log format ["A3C scripted guidance rejected: projectile=%1 ammo=%2 targetClass=%3 policy=%4 reason=%5", _projectile, _ammo, typeOf _target, _policy, _rejectReason];};
    };

    // State stays local to this exact Fired projectile, including after release.
    _projectile setVariable ["A3C_Guidance_Started", true];
    _projectile setVariable ["A3C_Guidance_Released", false];
    private _contactHandle = _projectile addEventHandler ["HitPart", {
        (_this select 0) setVariable ["A3C_Guidance_Released", true];
    }];

    // Single owner, simulation-time intervals: sleep is only a scheduler request.
    // No catch-up turns after stalls. At 90 deg/s, each 50 ms turn is at most
    // 4.5 degrees; even a delayed update is capped at 9 degrees (100 ms budget).
    private _state = createHashMapFromArray [
        ["lastTime", time], ["reason", ""], ["samples", 0], ["writes", 0], ["facingWrites", 0],
        ["minDt", 1e10], ["maxDt", 0], ["sumDt", 0], ["clamped", 0],
        ["maxTurn", 0], ["maxFacingTurn", 0], ["maxError", 0],
        ["debug", _debug], ["identity", str _projectile], ["ammo", _ammo],
        ["targetClass", typeOf _target], ["policy", _policy]
    ];
    if (_debug) then {diag_log format ["A3C scripted guidance start: projectile=%1 ammo=%2 targetClass=%3 policy=%4 owner=LOCAL_SCRIPTED cadence=0.05 turnRate=90 maxDt=0.10", _projectile, _ammo, typeOf _target, _policy];};

    private _release = {
        params ["_projectile", "_contactHandle", "_state"];
        if (!isNull _projectile) then {
            _projectile setVariable ["A3C_Guidance_Released", true];
            _projectile removeEventHandler ["HitPart", _contactHandle];
        };
        // Two records per accepted worker (start/stop), never per-frame RPT writes.
        if (_state get "debug") then {
            private _samples = _state get "samples";
            diag_log format ["A3C scripted guidance stop: projectile=%1 ammo=%2 targetClass=%3 policy=%4 reason=%5 samples=%6 velocityWrites=%7 dtMinMeanMax=%8 clamped=%9 maxVelocityTurn=%10 maxFacingTurn=%11 maxAimError=%12 orientationWrites=%13",
                _state get "identity", _state get "ammo", _state get "targetClass", _state get "policy", _state get "reason",
                _samples, _state get "writes", [if (_samples > 0) then {_state get "minDt"} else {0}, (_state get "sumDt") / (_samples max 1), _state get "maxDt"],
                _state get "clamped", _state get "maxTurn", _state get "maxFacingTurn", _state get "maxError", _state get "facingWrites"];
        };
    };

    // Rotate a unit vector along its great circle, including antiparallel input.
    // A normalized linear blend would have an angle-dependent turn rate and a
    // singularity at 180 degrees. SQF trigonometric commands use degrees.
    private _turnTowards = {
        params ["_from", "_to", "_limit"];
        private _dot = ((_from vectorDotProduct _to) max -1) min 1;
        private _angle = acos _dot;
        if (_angle <= _limit) exitWith {[_to, _angle, _angle]};
        private _tangent = _to vectorDiff (_from vectorMultiply _dot);
        if (vectorMagnitude _tangent < 0.000001) then {
            private _reference = if (abs (_from select 2) < 0.9) then {[0, 0, 1]} else {[1, 0, 0]};
            _tangent = _reference vectorDiff (_from vectorMultiply (_reference vectorDotProduct _from));
        };
        private _direction = (_from vectorMultiply (cos _limit)) vectorAdd ((vectorNormalized _tangent) vectorMultiply (sin _limit));
        [vectorNormalized _direction, _limit, _angle]
    };

    private _step = {
        params ["_projectile", "_target", "_policy", "_first", "_state", "_turnTowards"];
        private _continue = false;

        // Keep the check and both trajectory writes unscheduled, even in the worker.
        isNil {
            if (isNull _projectile || {!alive _projectile}) exitWith {_state set ["reason", "PROJECTILE_GONE"];};
            if (!local _projectile) exitWith {_state set ["reason", "LOCALITY_LOST"];};
            if (_projectile getVariable ["A3C_Guidance_Released", true]) exitWith {_state set ["reason", "HIT_OR_RELEASED"];};
            if (isNull _target) exitWith {_state set ["reason", "TARGET_GONE"];};
            if ((_projectile getVariable ["A3C_OW_MissileGuidanceOwner", ""]) != "") exitWith {_state set ["reason", "OTHER_GUIDANCE_OWNER"];};

            private _now = time;
            private _elapsed = (_now - (_state get "lastTime")) max 0;
            _state set ["lastTime", _now];
            if (!_first) then {
                _state set ["samples", (_state get "samples") + 1];
                _state set ["minDt", (_state get "minDt") min _elapsed];
                _state set ["maxDt", (_state get "maxDt") max _elapsed];
                _state set ["sumDt", (_state get "sumDt") + _elapsed];
                if (_elapsed > 0.10) then {_state set ["clamped", (_state get "clamped") + 1];};
            };
            // Preserve an immediate, bounded launch correction, including DIRECT.
            // Zero launch speed below consumes no writes and accrues no turn debt.
            private _dt = if (_first) then {(diag_deltaTime max 0) min 0.05} else {_elapsed min 0.10};

            private _fixedAimASL = _projectile getVariable ["A3C_Guidance_FixedAimASL", []];
            private _targetPosASL = [];
            if (_fixedAimASL isEqualTypeArray [0, 0, 0]
                && {{finite _x} count _fixedAimASL == 3}) then {
                _targetPosASL = +_fixedAimASL;
            } else {
                private _aimObject = attachedTo _target;
                if (isNull _aimObject) then {
                    _aimObject = _target;
                };

                _targetPosASL = aimPos _aimObject;
                if (_targetPosASL isEqualTo [0, 0, 0]) then {
                    _targetPosASL = getPosASL _aimObject;
                };
            };
            if (_policy == "OVERFLY") then {
                _targetPosASL = _targetPosASL vectorAdd [0, 0, 3.5];
            };
            if (!(_targetPosASL isEqualTypeArray [0, 0, 0]) || {{finite _x} count _targetPosASL != 3}) exitWith {_state set ["reason", "INVALID_AIM"];};
            private _offset = _targetPosASL vectorDiff getPosASL _projectile;
            private _distance = vectorMagnitude _offset;
            if (!finite _distance || {_distance <= 0.001}) exitWith {_state set ["reason", "INVALID_OR_ZERO_DISTANCE"];};

            private _velocity = velocity _projectile;
            private _currentSpeed = vectorMagnitude _velocity;
            if (!finite _currentSpeed) exitWith {_state set ["reason", "INVALID_SPEED"];};
            // A missile may not have acquired launch velocity yet; do not invent speed.
            if (_currentSpeed <= 0.001) exitWith {_continue = true;};

            private _handoff = ((diag_deltaTime * 3) max 0.035) min 0.10;
            if (!_first && {(_offset vectorDotProduct _velocity) <= 0}) exitWith {_state set ["reason", "PASSED_TARGET"];};
            if (!_first && {_policy == "DIRECT"} && {_distance / _currentSpeed <= _handoff}) exitWith {_state set ["reason", "DIRECT_HANDOFF"];};

            private _desired = _offset vectorMultiply (1 / _distance);
            private _turn = [_velocity vectorMultiply (1 / _currentSpeed), _desired, 90 * _dt] call _turnTowards;
            _turn params ["_direction", "_turnAngle", "_aimError"];
            // Bound visual facing separately; never snap a divergent model axis
            // onto velocity. Project the existing up vector to retain roll continuity.
            private _facing = [vectorNormalized vectorDir _projectile, _direction, 90 * _dt] call _turnTowards;
            _facing params ["_facingDirection", "_facingAngle"];
            private _up = vectorUp _projectile;
            _up = _up vectorDiff (_facingDirection vectorMultiply (_up vectorDotProduct _facingDirection));
            if (vectorMagnitude _up < 0.001) then {
                private _referenceUp = if (abs (_facingDirection select 2) < 0.9) then {[0, 0, 1]} else {[1, 0, 0]};
                _up = _referenceUp vectorDiff (_facingDirection vectorMultiply (_referenceUp vectorDotProduct _facingDirection));
            };
            _up = vectorNormalized _up;

            if (!local _projectile) exitWith {_state set ["reason", "LOCALITY_LOST"];};
            if (_projectile getVariable ["A3C_Guidance_Released", true]) exitWith {_state set ["reason", "HIT_OR_RELEASED"];};
            // Skip sub-0.05-degree changes. Orientation can affect velocity, so
            // restore the sampled engine speed whenever either write is needed.
            if (_dt > 0 && {(_turnAngle max _facingAngle) > 0.05}) then {
                if (_facingAngle > 0.05) then {
                    _projectile setVectorDirAndUp [_facingDirection, _up];
                    _state set ["facingWrites", (_state get "facingWrites") + 1];
                };
                if (!local _projectile) exitWith {_state set ["reason", "LOCALITY_LOST"];};
                if (_projectile getVariable ["A3C_Guidance_Released", true]) exitWith {_state set ["reason", "HIT_OR_RELEASED"];};
                _projectile setVelocity (_direction vectorMultiply _currentSpeed);
                _state set ["writes", (_state get "writes") + 1];
                _state set ["maxTurn", (_state get "maxTurn") max _turnAngle];
                _state set ["maxFacingTurn", (_state get "maxFacingTurn") max _facingAngle];
            };
            if ((_state get "reason") != "") exitWith {};
            _state set ["maxError", (_state get "maxError") max _aimError];

            // Close DIRECT shots still receive the first correction before handoff.
            _continue = !(_policy == "DIRECT" && {_distance / _currentSpeed <= _handoff});
            if (!_continue) then {_state set ["reason", "DIRECT_HANDOFF"];};
        };
        _continue
    };

    if !([_projectile, _target, _policy, true, _state, _turnTowards] call _step) exitWith {
        [_projectile, _contactHandle, _state] call _release;
    };

    [_projectile, _target, _policy, _contactHandle, _step, _release, _state, _turnTowards] spawn {
        params ["_projectile", "_target", "_policy", "_contactHandle", "_step", "_release", "_state", "_turnTowards"];
        private _continue = true;
        while {_continue} do {
            sleep 0.05;
            _continue = [_projectile, _target, _policy, false, _state, _turnTowards] call _step;
        };
        [_projectile, _contactHandle, _state] call _release;
    };
};

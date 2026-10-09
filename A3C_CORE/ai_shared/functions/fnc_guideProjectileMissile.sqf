// A3C_ai_shared_fnc_guideProjectileMissile

params [
    ["_projectile", objNull, [objNull]],
    ["_target", objNull, [objNull]],
    ["_policy", "MISSILE", [""]]
];

// Atomically claim this local projectile before a scheduled caller can yield.
isNil {
    if (isNull _projectile || {!alive _projectile} || {isNull _target}) exitWith {};
    if !(local _projectile) exitWith {};
    if !(_policy in ["DIRECT", "MISSILE", "OVERFLY"]) exitWith {};
    if (_projectile getVariable ["A3C_Guidance_Started", false]) exitWith {};

    // State stays local to this exact Fired projectile, including after release.
    _projectile setVariable ["A3C_Guidance_Started", true];
    _projectile setVariable ["A3C_Guidance_Released", false];
    private _contactHandle = _projectile addEventHandler ["HitPart", {
        (_this select 0) setVariable ["A3C_Guidance_Released", true];
    }];

    private _release = {
        params ["_projectile", "_contactHandle"];
        if (!isNull _projectile) then {
            _projectile setVariable ["A3C_Guidance_Released", true];
            _projectile removeEventHandler ["HitPart", _contactHandle];
        };
    };

    private _step = {
        params ["_projectile", "_target", "_policy", "_first"];
        private _continue = false;

        // Keep the check and both trajectory writes unscheduled, even in the worker.
        isNil {
            if (isNull _projectile || {!alive _projectile} || {!local _projectile}) exitWith {};
            if (_projectile getVariable ["A3C_Guidance_Released", true]) exitWith {};
            if (isNull _target) exitWith {};

            private _aimObject = attachedTo _target;
            if (isNull _aimObject) then {
                _aimObject = _target;
            };

            private _targetPosASL = aimPos _aimObject;
            if (_targetPosASL isEqualTo [0, 0, 0]) then {
                _targetPosASL = getPosASL _aimObject;
            };
            if (_policy == "OVERFLY") then {
                _targetPosASL = _targetPosASL vectorAdd [0, 0, 3.5];
            };
            private _offset = _targetPosASL vectorDiff getPosASL _projectile;
            private _distance = vectorMagnitude _offset;
            if (_distance <= 0.001) exitWith {};

            private _velocity = velocity _projectile;
            private _currentSpeed = vectorMagnitude _velocity;
            // A missile may not have acquired launch velocity yet; do not invent speed.
            if (_currentSpeed <= 0.001) exitWith {_continue = true;};

            private _handoff = ((diag_deltaTime * 3) max 0.035) min 0.10;
            if (!_first && {(_offset vectorDotProduct _velocity) <= 0}) exitWith {};
            if (!_first && {_policy == "DIRECT"} && {_distance / _currentSpeed <= _handoff}) exitWith {};

            private _direction = _offset vectorMultiply (1 / _distance);
            private _up = vectorUp _projectile;
            _up = _up vectorDiff (_direction vectorMultiply (_up vectorDotProduct _direction));
            if (vectorMagnitude _up < 0.001) then {
                private _referenceUp = if (abs (_direction select 2) < 0.9) then {[0, 0, 1]} else {[1, 0, 0]};
                _up = _referenceUp vectorDiff (_direction vectorMultiply (_referenceUp vectorDotProduct _direction));
            };
            _up = vectorNormalized _up;

            if (!local _projectile || {_projectile getVariable ["A3C_Guidance_Released", true]}) exitWith {};
            _projectile setVectorDirAndUp [_direction, _up];
            if (!local _projectile || {_projectile getVariable ["A3C_Guidance_Released", true]}) exitWith {};
            _projectile setVelocity (_direction vectorMultiply _currentSpeed);

            // Close DIRECT shots still receive the first correction before handoff.
            _continue = !(_policy == "DIRECT" && {_distance / _currentSpeed <= _handoff});
        };
        _continue
    };

    if !([_projectile, _target, _policy, true] call _step) exitWith {
        [_projectile, _contactHandle] call _release;
    };

    [_projectile, _target, _policy, _contactHandle, _step, _release] spawn {
        params ["_projectile", "_target", "_policy", "_contactHandle", "_step", "_release"];
        private _continue = true;
        while {_continue} do {
            sleep 0.01;
            _continue = [_projectile, _target, _policy, false] call _step;
        };
        [_projectile, _contactHandle] call _release;
    };
};

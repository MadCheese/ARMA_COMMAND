// A3C_ai_shared_fnc_recoverTankShot -- callable again after locality migration.
// INSTALL runs only on the EH's installing machine; OWNER restores local AI.
params ["_phase", "_payload", ["_emergency", false]];
_payload params ["_unit", "_tank", "_token", "_autoTarget", "_target", "_handle", "_remoteHandle", "_installer"];
private _debug = missionNamespace getVariable ["A3C_DEBUG", false];
if (_phase == "INSTALL") exitWith {
    if (clientOwner != _installer) exitWith {};
    isNil {
        if (!isNull _target) then {
            _target setVariable ["A3C_TANK_SHOT_CAPTURE_OPEN", false, true];
            if !(_target getVariable ["A3C_Remote_Projectile_Captured", false]) then {deleteVehicle _target;};
        };
        private _removedKey = format ["A3C_TANK_SHOT_REMOVED_%1", _token];
        // Local ownership map makes removal idempotent even if the engine later
        // reuses an EH ID, or the server only received the pre-install checkpoint.
        private _handlers = missionNamespace getVariable ["A3C_TANK_SHOT_HANDLERS", createHashMap];
        if (_token in _handlers) then {
            private _installed = _handlers get _token;
            if (!(_unit getVariable [_removedKey, false])) then {
                (_installed select 0) removeEventHandler ["FiredMan", _installed select 1];
            };
            _handlers deleteAt _token;
        };
        if (((_unit getVariable ["A3C_TANK_SHOT_CAPTURE", []]) param [1, ""]) == _token) then {
            _unit setVariable ["A3C_TANK_SHOT_CAPTURE", nil];
        };
        _unit setVariable [format ["A3C_TANK_SHOT_FIRED_%1", _token], nil, true];
        _unit setVariable [_removedKey, nil];
        if (_emergency) then {
            private _key = format ["A3C_TANK_SHOT_WORKER_%1", _token];
            private _worker = _unit getVariable [_key, scriptNull];
            if (!scriptDone _worker) then {
                _unit setVariable [format ["A3C_TANK_SHOT_STOP_%1", _token], true];
                terminate _worker;
            };
        };
    };
    ["INSTALLED", [_token]] call A3C_ai_shared_fnc_manageTankShot;
};
if (_phase != "OWNER") exitWith {};
// The server retries against the current owner; never create forwarding chains.
if (!isNull _unit && {!local _unit}) exitWith {};
private _released = false;
isNil {
    if (!isNull _unit && {!local _unit}) exitWith {};
    if (!isNull _unit && {(_unit getVariable ["A3C_TANK_SHOT_TOKEN", ""]) == _token}) then {
        _unit doWatch objNull;
        _unit doTarget objNull;
        _unit lookAt objNull;
        if (_autoTarget) then {_unit enableAI "AUTOTARGET";} else {_unit disableAI "AUTOTARGET";};
        _unit setVariable ["A3C_unit_is_Remote_Firing", false, true];
        _unit setVariable ["A3C_REMOTE_HANDLE", [], true];
        _unit setVariable ["A3C_TANK_SHOT_TOKEN", nil, true];
    };
    // These objects belong to this token even when the gunner has a newer order.
    if ((_tank getVariable ["A3C_TANK_SHOT", []]) isEqualTo [_token, _unit]) then {
        _tank setVariable ["A3C_TANK_SHOT", [], true];
    };
    if (!(_remoteHandle isEqualTo []) && {(_tank getVariable ["A3C_REMOTE_HANDLE", []]) isEqualTo _remoteHandle}) then {
        _tank setVariable ["A3C_REMOTE_HANDLE", [], true];
    };
    _released = true;
};
if (_released) then {
    if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: cleanup completed on gunner owner=%2; reservation released", _token, clientOwner];};
    ["RELEASED", [_token]] call A3C_ai_shared_fnc_manageTankShot;
};

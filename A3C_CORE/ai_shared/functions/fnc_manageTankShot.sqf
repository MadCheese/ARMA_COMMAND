// A3C_ai_shared_fnc_manageTankShot -- server authority and independent watchdog.
// Entries are private to the server; existing public shot/remote-handle layouts stay intact.
params ["_event", "_data"];
if (!isServer) exitWith {_this remoteExecCall ["A3C_ai_shared_fnc_manageTankShot", 2];};
// All registry transitions are atomic, including server-local scheduled callers.
isNil {
    private _orders = missionNamespace getVariable ["A3C_TANK_SHOT_ORDERS", createHashMap];
    missionNamespace setVariable ["A3C_TANK_SHOT_ORDERS", _orders];
    private _debug = missionNamespace getVariable ["A3C_DEBUG", false];
    if (_event == "DISPATCH") exitWith {
        _data params ["_unit", "_targetPos", "_snapObject", "_context"];
        private _token = _context select 0;
        if (_token in _orders) exitWith {};
        _context = +_context;
        _context set [3, time + 100]; // A delayed delivery may not claim an expired order.
        private _entry = createHashMapFromArray [
            ["context", _context], ["unit", _unit], ["tank", vehicle _unit],
            ["payload", []], ["deadline", time + 100], ["finished", false],
            ["captured", false], ["released", false], ["installedClean", false]
        ];
        _orders set [_token, _entry];
        if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: dispatched commander=%2, shooter/group=%3, owner=%4", _token, _context select 1, _context select 2, owner _unit];};
        [[_unit, _targetPos, _snapObject, 0, _context], A3C_ai_shared_fnc_executeTankShot] remoteExec ["BIS_fnc_spawn", if (isNull _unit) then {2} else {_unit}];
        [_token] spawn {
            params ["_token"];
            private _entry = (missionNamespace getVariable ["A3C_TANK_SHOT_ORDERS", createHashMap]) get _token;
            waitUntil {
                sleep 1;
                if !(_entry get "finished") then {
                    private _unit = _entry get "unit";
                    private _payload = _entry get "payload";
                    // Recovery metadata can outlive a lost installing client's RPC.
                    private _replicated = _unit getVariable [format ["A3C_TANK_SHOT_RECOVERY_%1", _token], []];
                    if (count _replicated == 8 && {(_replicated select 2) == _token}
                        && {(_unit getVariable ["A3C_TANK_SHOT_TOKEN", ""]) == _token}
                        && {_payload isEqualTo [] || {(_replicated select 5) >= 0}
                            || {(_payload select 5) < 0 && {!isNull (_replicated select 4)}}}) then {
                        if (_payload isEqualTo []) then {_entry set ["deadline", time + 100];};
                        _payload = _replicated;
                        _entry set ["payload", _payload];
                        _entry set ["tank", _payload select 1];
                    };
                    private _reason = "";
                    if (!(_payload isEqualTo []) && {!(_entry get "captured")}) then {
                        private _tank = _entry get "tank";
                        _reason = switch (true) do {
                            case (isNull _unit || {!alive _unit} || {isNull _tank} || {!alive _tank}): {"DESTROYED"};
                            case (owner _unit != (_payload select 7)): {"LOCALITY_CHANGED"};
                            case (vehicle _unit != _tank || {_unit != gunner _tank}): {"CREW_CHANGED"};
                            // Tokens can briefly lag the CLAIM RPC; validity remains local.
                            default {""};
                        };
                    };
                    if (_reason == "" && {time >= (_entry get "deadline")}) then {
                        _reason = if (_payload isEqualTo []) then {"DISPATCH_TIMEOUT"} else {"EXECUTION_TIMEOUT"};
                    };
                    if (_reason != "") then {["FINISH", [_token, "FAILED", _reason, true]] call A3C_ai_shared_fnc_manageTankShot;};
                };
                _entry get "finished"
            };
            // Recovery is independent of both commander and installing-client lifetime.
            // A live owner must restore local AI before its token can be released safely.
            private _nextWarning = time + 30;
            private _retainUntil = time + 120;
            while {!(_entry get "released") || {!(_entry get "installedClean")} || {time < _retainUntil}} do {
                if (!(_entry get "released") || {!(_entry get "installedClean")}) then {
                    private _payload = _entry get "payload";
                    private _unit = _entry get "unit";
                    private _installer = _payload select 7;
                    if !(_entry get "installedClean") then {
                        // allPlayers includes headless clients. A disconnected
                        // installer's local event handlers no longer exist.
                        if (_installer != 2 && {owner _unit != _installer}
                            && {allPlayers findIf {owner _x == _installer} < 0}) then {
                            ["INSTALLED", [_token]] call A3C_ai_shared_fnc_manageTankShot;
                        } else {
                            ["INSTALL", _payload, true] remoteExecCall ["A3C_ai_shared_fnc_recoverTankShot", _installer];
                        };
                    };
                    if !(_entry get "released") then {
                        ["OWNER", _payload] remoteExecCall ["A3C_ai_shared_fnc_recoverTankShot", if (isNull _unit) then {2} else {_unit}];
                    };
                    if (time >= _nextWarning) then {
                        diag_log format ["[A3C] TANKSHOT %1: recovery pending; owner/installer cleanup has not been acknowledged", _token];
                        _nextWarning = time + 30;
                    };
                };
                sleep 2;
            };
            // Deduplicate late completion/claim RPCs, then bound retained state.
            (missionNamespace getVariable ["A3C_TANK_SHOT_ORDERS", createHashMap]) deleteAt _token;
        };
    };
    private _token = _data param [0, ""];
    if !(_token in _orders) exitWith {};
    private _entry = _orders get _token;
    switch (_event) do {
        case "CLAIM": {
            private _payload = _data select 1;
            private _previous = _entry get "payload";
            // Replicated metadata and RPC checkpoints can arrive at different
            // times. Never replace an installed-handler/proxy snapshot with an older one.
            if (!(_previous isEqualTo []) && {
                ((_previous select 5) >= 0 && {(_payload select 5) < 0})
                || {(_payload select 5) < 0 && {!isNull (_previous select 4)} && {isNull (_payload select 4)}}
            }) then {_payload = _previous;};
            if (_entry get "finished") exitWith {
                // The watchdog can finish while an owner's CLAIM is in transit.
                // Recover its late resources too, without reopening the result.
                _entry set ["payload", _payload];
                _entry set ["tank", _payload select 1];
                _entry set ["released", false];
                _entry set ["installedClean", false];
                private _target = _payload select 4;
                if (!isNull _target) then {
                    _target setVariable ["A3C_TANK_SHOT_CAPTURE_OPEN", false, true];
                    if (!(_entry get "captured") && {!(_target getVariable ["A3C_Remote_Projectile_Captured", false])}) then {deleteVehicle _target;};
                };
                ["INSTALL", _payload, true] remoteExecCall ["A3C_ai_shared_fnc_recoverTankShot", _payload select 7];
            };
            if ((_entry get "payload") isEqualTo []) then {_entry set ["deadline", time + 100];};
            _entry set ["payload", _payload];
            _entry set ["tank", _payload select 1];
            if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: claim/checkpoint owner=%2, proxy=%3, handler=%4", _token, _payload select 7, _payload select 4, _payload select 5];};
        };
        case "CAPTURED": {
            if !(_entry get "finished") then {
                _entry set ["captured", true];
                _entry set ["projectile", _data select 1];
                if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: confirmed firing receipt, projectile=%2", _token, _data select 1];};
            };
        };
        case "FINISH": {
            if (_entry get "finished") exitWith {};
            _data params ["_token", "_outcome", "_reason", ["_emergency", false]];
            if (_entry get "captured") then {_outcome = "FIRED"; _reason = "CONFIRMED_PROJECTILE";};
            if (_outcome == "FIRED") then {_entry set ["captured", true];};
            _entry set ["finished", true];
            _entry set ["outcome", _outcome];
            _entry set ["reason", _reason];
            private _payload = _entry get "payload";
            private _replicated = (_entry get "unit") getVariable [format ["A3C_TANK_SHOT_RECOVERY_%1", _token], []];
            if (count _replicated == 8 && {(_replicated select 2) == _token}
                && {_payload isEqualTo [] || {(_replicated select 5) >= 0}
                    || {(_payload select 5) < 0 && {!isNull (_replicated select 4)}}}) then {
                _payload = _replicated;
                _entry set ["payload", _payload];
                _entry set ["tank", _payload select 1];
            };
            if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: terminal outcome=%2, reason=%3; cleanup started, emergency=%4", _token, _outcome, _reason, _emergency];};
            if (_payload isEqualTo []) then {
                _entry set ["released", true]; // Rejected before claim: owns no AI/tank state.
                _entry set ["installedClean", true];
            } else {
                private _target = _payload select 4;
                if (!isNull _target) then {
                    _target setVariable ["A3C_TANK_SHOT_CAPTURE_OPEN", false, true];
                    if (!(_entry get "captured") && {!(_target getVariable ["A3C_Remote_Projectile_Captured", false])}) then {
                        deleteVehicle _target;
                    } else {
                        // Keep projectile cleanup separate, including installer disconnects.
                        [_token, _target, _entry getOrDefault ["projectile", _target getVariable ["A3C_TANK_SHOT_PROJECTILE", objNull]]] spawn {
                            params ["_token", "_target", "_projectile"];
                            // Replication may trail the Fired receipt. Do not delete a
                            // live-flight proxy just because its projectile is unknown.
                            if (isNull _projectile) exitWith {
                                if (missionNamespace getVariable ["A3C_DEBUG", false]) then {diag_log format ["[A3C] TANKSHOT %1: fired proxy=%2; server projectile unavailable; installer owns flight cleanup", _token, _target];};
                            };
                            waitUntil {sleep 0.1; isNull _projectile || {!alive _projectile}};
                            if (!isNull _target) then {deleteVehicle _target;};
                        };
                    };
                };
                ["INSTALL", _payload, _emergency] remoteExecCall ["A3C_ai_shared_fnc_recoverTankShot", _payload select 7];
                private _unit = _entry get "unit";
                ["OWNER", _payload] remoteExecCall ["A3C_ai_shared_fnc_recoverTankShot", if (isNull _unit) then {2} else {_unit}];
            };
            private _context = _entry get "context";
            [_context, _outcome, _reason, (_entry get "released") && {_entry get "installedClean"}] remoteExecCall ["A3C_ai_shared_fnc_reportTankShot", _context select 1];
        };
        case "INSTALLED": {
            if (_entry get "installedClean") exitWith {};
            _entry set ["installedClean", true];
            if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: installer capture cleanup acknowledged", _token];};
            if ((_entry get "finished") && {_entry get "released"}) then {
                private _context = _entry get "context";
                [_context, _entry get "outcome", _entry get "reason", true] remoteExecCall ["A3C_ai_shared_fnc_reportTankShot", _context select 1];
            };
        };
        case "RELEASED": {
            if !(_entry get "finished") exitWith {};
            if (_entry get "released") exitWith {};
            _entry set ["released", true];
            [_entry get "unit", _token, false] call A3C_ai_shared_fnc_setTankShotActive;
            private _context = _entry get "context";
            if (_entry get "installedClean") then {
                [_context, _entry get "outcome", _entry get "reason", true] remoteExecCall ["A3C_ai_shared_fnc_reportTankShot", _context select 1];
            };
            if (_debug) then {diag_log format ["[A3C] TANKSHOT %1: owner cleanup acknowledged; reservation released", _token];};
        };
    };

};

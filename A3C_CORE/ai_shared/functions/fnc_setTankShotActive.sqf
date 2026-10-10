// A3C_ai_shared_fnc_setTankShotActive
// Apply TANKSHOT list deltas on one authority; concurrent turret owners must not
// publish competing whole-list snapshots that resurrect a finished tank order.
params ["_unit", "_token", "_active"];
if (!isServer) exitWith {_this remoteExecCall ["A3C_ai_shared_fnc_setTankShotActive", 2];};
isNil {
    private _current = _unit getVariable ["A3C_TANK_SHOT_TOKEN", ""];
    if (_active) then {
        // Ignore an obsolete or not-yet-replicated claim. Per-object tokens and
        // the remote-firing flag, rather than this UI list, own shot validity.
        if (isNull _unit || {_current != _token}) exitWith {};
        A3C_REMFIRE_UNITS_ACTIVE pushBackUnique _unit;
    } else {
        if (_current != "" && {_current != _token}) exitWith {};
        A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
    };
    publicVariable "A3C_REMFIRE_UNITS_ACTIVE";
};

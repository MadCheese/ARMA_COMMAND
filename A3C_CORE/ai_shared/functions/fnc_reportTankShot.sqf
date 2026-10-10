// A3C_ai_shared_fnc_reportTankShot -- commander-local, one receipt per order.
params ["_context", "_outcome", "_reason", ["_released", true]];
_context params ["_token", "_commander", "_label"];
if (clientOwner != _commander) exitWith {};
private _receipts = missionNamespace getVariable ["A3C_TANK_SHOT_RESULTS", createHashMap];
if (_token in _receipts) exitWith {
    private _receipt = _receipts get _token;
    if (_released && {!(_receipt param [3, false])}) then {
        _receipt set [3, true];
        _receipts set [_token, _receipt];
        if (missionNamespace getVariable ["A3C_DEBUG", false]) then {diag_log format ["[A3C] TANKSHOT %1: cleanup receipt delivered to commander=%2", _token, _commander];};
    };
};
// Keep receipts beyond the UI and late-RPC windows, then prune on the next result.
{
    if (time - ((_receipts get _x) param [2, time]) > 360) then {_receipts deleteAt _x;};
} forEach keys _receipts;
_receipts set [_token, [_outcome, _reason, time, _released]];
missionNamespace setVariable ["A3C_TANK_SHOT_RESULTS", _receipts];
private _message = switch (_reason) do {
    case "HARD_OBSTRUCTION": {"hard obstruction detected on the firing line"};
    case "NO_SHOOTER": {"no eligible shooter"};
    case "BUSY": {"tank or gunner is busy"};
    case "UNAVAILABLE": {"gunner or turret is unavailable"};
    case "SUPPRESSING": {"gunner is suppressing; cancel suppression first"};
    case "NO_CANNON": {"no compatible cannon identified"};
    case "NO_AMMO": {"no usable cannon ammunition available"};
    case "AMMO_MAPPING": {"loaded ammunition could not be identified safely"};
    case "AMMO_CHANGED": {"cannon ammunition changed before firing"};
    case "AIM_TIMEOUT": {"turret could not aim within the allowed time"};
    case "AIM_LOST": {"turret lost its aim before firing"};
    case "RELOAD_TIMEOUT": {"magazine reload timed out; no ready shell"};
    case "NOT_READY": {"cannon readiness changed before firing"};
    case "NO_PROJECTILE": {"no projectile confirmed within the firing window"};
    case "CANCELLED": {"order cancelled"};
    case "DESTROYED": {"tank or gunner was destroyed"};
    case "CREW_CHANGED": {"gunner left the ordered turret"};
    case "LOCALITY_CHANGED": {"gunner or turret locality changed"};
    case "DISPATCH_TIMEOUT": {"order did not reach the gunner owner"};
    case "EXECUTION_TIMEOUT": {"execution stalled; emergency recovery started"};
    default {"unexpected execution failure; recovery started"};
};
if (_outcome != "FIRED") then {systemChat format ["A3C: %1: %2", _label, _message];};
if (missionNamespace getVariable ["A3C_DEBUG", false]) then {
    diag_log format ["[A3C] TANKSHOT %1: result delivered commander=%2, shooter/group=%3, outcome=%4, reason=%5", _token, _commander, _label, _outcome, _reason];
};

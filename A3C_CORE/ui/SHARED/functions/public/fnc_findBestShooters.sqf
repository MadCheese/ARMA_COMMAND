// A3C_ui_shared_fnc_findBestShooters
// Optional action/target/notification arguments preserve the two-argument API.
// Returns eligible units, best first. Unknown trajectories remain permissive.
params [
    ["_units", [], [[]]],
    ["_inputPosASL", [0, 0, 0], [[]], 3],
    ["_remoteAction", "", [""]],
    ["_snapObject", objNull, [objNull]],
    ["_notify", true, [true]],
    ["_selection", [], [[]]]
];
private _debug = missionNamespace getVariable ["A3C_DEBUG", false];
private _ranked = [];
{
    private _unit = _x;
    private _inputIndex = _forEachIndex;
    if (!isNull _unit && {alive _unit}) then {
        private _vehicle = objectParent _unit;
        private _action = _remoteAction;
        // Match orderRemoteLaunch's existing FIND precedence, without changing
        // its dispatch or which groups/capabilities supply the candidate list.
        if (_action == "FIND") then {
            _action = switch (true) do {
                case ([_unit] call A3C_main_fnc_unitHasUGL): {"UGLSHOT"};
                case ([_unit] call A3C_main_fnc_unitHasAT): {"ATSHOT"};
                case (_vehicle isKindOf "Tank" && {_unit == gunner _vehicle}
                    && {getNumber (configOf _vehicle >> "artilleryScanner") == 0}): {"TANKSHOT"};
                case (_unit == gunner _vehicle && {getArtilleryAmmo [_vehicle] isNotEqualTo []}): {"ARTY"};
                case ([_vehicle] call A3C_main_fnc_isStaticMissileLauncher): {"STATICSHOT"};
                default {"EXIT"};
            };
        };
        // Preserve the old artillery exception. AT/UGL/static missile paths and
        // unspecified actions have no proven straight trajectory in this stage.
        private _artillery = !isNull _vehicle && {getArtilleryAmmo [_vehicle] isNotEqualTo []};
        private _direct = _action in ["TANKSHOT", "DIRECT"] && {!_artillery};
        private _origin = if (isNull _vehicle) then {eyePos _unit} else {
            (getPosASL _vehicle) vectorAdd [0, 0, 1.8]
        };
        private _result = [_origin, _inputPosASL, _unit, _vehicle, _snapObject]
            call A3C_ai_shared_fnc_evaluateRemoteFireObstruction;
        _result params ["_status", "_soft", "_hard", "_uncertain", "_details"];
        private _rejected = _direct && {_hard > 0};
        // Optional output only: preserve eligibility and scoring exactly.
        _selection pushBack [_unit, _action, if (_rejected) then {"HARD_OBSTRUCTION"} else {"ELIGIBLE"}];
        private _reason = if (_rejected) then {"confirmed hard blocker on direct-fire ray"} else {
            if (_hard > 0) then {"hard straight-line blocker retained: arcing/unknown trajectory"} else {
                if (_uncertain > 0) then {"uncertain geometry retained permissively"} else {"eligible"}
            }
        };
        private _distance = if (_inputPosASL isEqualTypeArray [0, 0, 0]
            && {{finite _x} count _inputPosASL == 3}) then {_origin vectorDistance _inputPosASL} else {1e10};
        // Explicit original index makes otherwise equal scores stable, without
        // relying on an engine sort comparing object IDs or unit names.
        private _score = [if (_hard > 0) then {1} else {0}, ["CLEAR", "SOFT", "UNCERTAIN", "HARD"] find _status, _soft, _distance, _inputIndex];
        if (!_rejected) then {_ranked pushBack (_score + [_unit]);};
        if (_debug) then {
            diag_log format ["[A3C] remote-fire candidate=%1, action=%2 (requested=%3), originASL=%4, targetASL=%5, snap=%6, direct=%7, status=%8, counts=[soft,hard,uncertain] %9, score=%10, rejected=%11: %12", _unit, _action, _remoteAction, _origin, _inputPosASL, _snapObject, _direct, _status, [_soft, _hard, _uncertain], _score, _rejected, _reason];
            {diag_log format ["[A3C] remote-fire candidate=%1: surface [posASL,hit,parent,terrain,class,reason,object,config,model,hitModel,selections,bisurf]=%2", _unit, _x];} forEach _details;
        };
    } else {
        _selection pushBack [_unit, _remoteAction, "NO_SHOOTER"];
        if (_debug) then {diag_log format ["[A3C] remote-fire candidate=%1, action=%2: rejected invalid/dead unit", _unit, _remoteAction];};
    };
} forEach _units;
_ranked sort true;
private _eligible = _ranked apply {_x select 5};
if (_debug) then {diag_log format ["[A3C] remote-fire ranking action=%1: %2", _remoteAction, _ranked];};
if (_notify && {_eligible isEqualTo []}) then {systemChat "A3C: No shot on target";};
_eligible

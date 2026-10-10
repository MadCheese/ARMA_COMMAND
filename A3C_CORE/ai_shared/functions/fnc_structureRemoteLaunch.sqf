// A3C_ai_shared_fnc_structureRemoteLaunch

params [
    ["_units", [], [[]]],
    ["_remFireType", "", [""]]
];

if (_units isEqualTo []) exitWith {
    if (_remFireType == "TANKSHOT") then {
        [[format ["TANK:%1:%2:empty", clientOwner, diag_tickTime], clientOwner, "Selected tanks"], "FAILED", "NO_SHOOTER"] call A3C_ai_shared_fnc_reportTankShot;
    };
    [] call A3C_ui_radialMenu_fnc_structureRemoteLaunchUiResponse;
};

private _aimPos = ATLToASL A3C_UI_HUD_3D_TAG_ICON_POS;
private _snapObject = A3C_SNAP_OBJECT;
private _unitsByGroups = [];

// Evaluate single-unit orders through the same preliminary checks as groups.
{
    private _unit = _x;
    private _group = group _unit;

    private _index = _unitsByGroups findIf {
        (_x select 0) isEqualTo _group
    };

    if (_index isEqualTo -1) then {
        _unitsByGroups pushBack [_group, [_unit]];
    } else {
        ((_unitsByGroups select _index) select 1) pushBack _unit;
    };
} forEach _units;

private _shooters = [];
private _emptyGroups = 0;
private _tankOrders = [];
private _sequence = 0;
isNil {
    _sequence = 1 + (missionNamespace getVariable ["A3C_TANK_SHOT_SEQUENCE", 0]);
    missionNamespace setVariable ["A3C_TANK_SHOT_SEQUENCE", _sequence];
};
private _batchId = format ["TANK:%1:%2:%3", clientOwner, diag_tickTime, _sequence];
private _selectionFailures = 0;

{
    private _group = _x select 0;
    private _groupUnits = _x select 1;
    private _selection = [];
    private _groupLabel = groupId _group;
    if (_groupLabel == "") then {_groupLabel = format ["Selected tank group %1", _forEachIndex + 1];};
    private _context = [format ["%1:%2", _batchId, _forEachIndex], clientOwner, _groupLabel];
    private _unitsViewOnTarget = [_groupUnits, _aimPos, _remFireType, _snapObject, false, _selection] call A3C_ui_shared_fnc_findBestShooters;

    if !(_unitsViewOnTarget isEqualTo []) then {
        private _shooter = _unitsViewOnTarget select 0;
        _shooters pushBackUnique _shooter;
        private _selected = _selection select {(_x select 0) isEqualTo _shooter};
        if (((_selected param [0, []]) param [1, ""]) == "TANKSHOT") then {
            _context set [2, format ["%1 / %2", groupId _group, name _shooter]];
            _tankOrders pushBack [_shooter, _context];
        };
    } else {
        private _tankGroup = _remFireType == "TANKSHOT" || {_selection findIf {(_x select 1) == "TANKSHOT"} >= 0};
        if (_tankGroup) then {
            private _reason = if (_selection findIf {(_x select 2) == "HARD_OBSTRUCTION"} >= 0) then {"HARD_OBSTRUCTION"} else {"NO_SHOOTER"};
            [_context, "FAILED", _reason] call A3C_ai_shared_fnc_reportTankShot;
            _selectionFailures = _selectionFailures + 1;
            if (missionNamespace getVariable ["A3C_DEBUG", false]) then {diag_log format ["[A3C] TANKSHOT %1: selection rejected group=%2, reason=%3, candidates=%4", _context select 0, _group, _reason, _selection];};
        } else {_emptyGroups = _emptyGroups + 1;};
    };
    if (missionNamespace getVariable ["A3C_DEBUG", false]) then {
        diag_log format ["[A3C] remote-fire selected group=%1, action=%2, ranked=%3, shooter=%4", _group, _remFireType, _unitsViewOnTarget, _unitsViewOnTarget param [0, objNull]];
    };
} forEach _unitsByGroups;

// Tank failures identify each group once on the commanding client.
if (_shooters isEqualTo []) exitWith {
    if (_selectionFailures == 0 || {_emptyGroups > 0}) then {systemChat "A3C: No shot on target";};
    [] call A3C_ui_radialMenu_fnc_structureRemoteLaunchUiResponse;
};
if (_emptyGroups > 0) then {systemChat format ["A3C: No suitable shooter in %1 selected group(s)", _emptyGroups];};

private _otherShooters = [];
{
    private _unit = _x;
    private _tankIndex = _tankOrders findIf {(_x select 0) isEqualTo _unit};
    if (_tankIndex >= 0) then {
        private _context = (_tankOrders select _tankIndex) select 1;
        if (missionNamespace getVariable ["A3C_DEBUG", false]) then {diag_log format ["[A3C] TANKSHOT %1: selection accepted shooter/group=%2", _context select 0, _context select 2];};
        ["DISPATCH", [_unit, _aimPos, _snapObject, _context]] call A3C_ai_shared_fnc_manageTankShot;
    } else {
        _otherShooters pushBack _unit;
        private _launchArgs = [_unit, _aimPos, _remFireType];
        if (_remFireType in ["ATSHOT", "FIND"]) then {_launchArgs pushBack _snapObject;};
        [_launchArgs, A3C_ai_shared_fnc_orderRemoteLaunch] remoteExec ["BIS_fnc_spawn", _unit];
    };
} forEach _shooters;

// Up to 100 s to dispatch + 100 s from claim, with 20 s for result delivery.
// This does not alter the reload/aim/capture budgets of any firing mechanic.
private _uiDeadline = time + 220;
sleep 2;
waitUntil {
    sleep 0.1;
    private _receipts = missionNamespace getVariable ["A3C_TANK_SHOT_RESULTS", createHashMap];
    (_tankOrders findIf {!((_receipts getOrDefault [((_x select 1) select 0), []]) param [3, false])} < 0
        && {_otherShooters findIf {alive _x && {_x getVariable ["A3C_unit_is_Remote_Firing", false]}} < 0})
        || {time >= _uiDeadline}
};
if (time >= _uiDeadline) then {
    private _receipts = missionNamespace getVariable ["A3C_TANK_SHOT_RESULTS", createHashMap];
    {
        private _token = (_x select 1) select 0;
        if !((_receipts getOrDefault [_token, []]) param [3, false]) then {
            ["FINISH", [_token, "FAILED", "EXECUTION_TIMEOUT", true]] call A3C_ai_shared_fnc_manageTankShot;
            if (missionNamespace getVariable ["A3C_DEBUG", false]) then {diag_log format ["[A3C] TANKSHOT %1: UI wait expired; terminal result/recovery requested", _token];};
        };
    } forEach _tankOrders;
};
[] call A3C_ui_radialMenu_fnc_structureRemoteLaunchUiResponse;

#include "..\..\script_component.hpp"

params ["_unit", "_bPos", "_ATLpos", "_watchDir"];

if (isNull _unit) exitWith {};
if (isPlayer _unit) exitWith {};
if !(alive _unit) exitWith {};

private _ehm = if ((count _this) > 4) then {
    _this select 4
} else {
    0
};

private _dest = _ATLpos;
private _goCode = profileNamespace getVariable ["A3C_HUD_GOCODE_VAR", "NONE"];
private _condition = if (_goCode == "NONE") then {
    ["NONE", "NONE"]
} else {
    ["GOCODE", _goCode]
};

private _action = if (_ehm == 8) then {
    ["EHM", []]
} else {
    ["NONE", []]
};

private _mType = switch (_goCode) do {
    case "A": {"A3C_Marker_GoCode_A"};
    case "B": {"A3C_Marker_GoCode_B"};
    case "C": {"A3C_Marker_GoCode_C"};
    case "D": {"A3C_Marker_GoCode_D"};
    default {"mil_dot"};
};

private _currentUnitPos = switch (stance _unit) do {
    case "PRONE": {"DOWN"};
    case "CROUCH": {"MIDDLE"};
    case "STAND": {"UP"};
    default {"AUTO"};
};

private _hudStance1 = switch (A3C_HUD_STANCE_MODE_TRAVEL) do {
    case 0: {"DOWN"};
    case 1: {"MIDDLE"};
    case 2: {"UP"};
    case 3: {"AUTO"};
    case 4: {_currentUnitPos};
    default {_currentUnitPos};
};

private _hudStance2 = switch (A3C_HUD_STANCE_MODE_DESTINATION) do {
    case 0: {"DOWN"};
    case 1: {"MIDDLE"};
    case 2: {"UP"};
    case 3: {"AUTO"};
    case 4: {_hudStance1};
    default {_hudStance1};
};

_unit stop false;

A3C_TEMP_WP_ID_SUB = format ["A3C_Mark_P%1", A3C_MARKER_COUNT];
A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
A3C_MARKERS pushBack A3C_TEMP_WP_ID_SUB;

private _speed = profileNamespace getVariable ["A3C_HUD_SPEED_VAR", -1];

private _wpData = [
    [_dest, [_dest, 100, _watchDir] call BIS_fnc_relPos],       // Positions.
    [A3C_TEMP_WP_ID_SUB, A3C_TEMP_WP_ID_SUB],                   // Markers.
    _action,                                                    // WP action.
    _condition,                                                 // WP condition.
    [_hudStance1, _hudStance2],                                 // WP stances.
    [[0, false]],                                               // WP sync data.
    false,                                                      // isWPCompleted.
    0,                                                          // Combat mode.
    _speed,                                                     // WP speed.
    25,                                                         // WP flying height.
    -1,                                                         // WP loop value.
    -1.5                                                        // Radius for circle, not completion.
];

if (
    (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true])
    || {(count (_unit getVariable ["A3C_PLOT", []])) == 0}
) then {
    private _plot = [_wpData];
    _unit setVariable ["A3C_PLOT", _plot, true];

    [_unit, _unit getVariable ["A3C_PLOT", []]] spawn A3C_AI_Shared_executeUnitPlot;
} else {
    private _plot = _unit getVariable ["A3C_PLOT", []];
    _plot pushBack _wpData;
    _unit setVariable ["A3C_PLOT", _plot, true];
};

// Existing legacy post-plot EHM / direct movement logic remains disabled.
// The original function exited here unconditionally.
if (true) exitWith {};
#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_selectTeam

params ["_team"];

private _teamData = [
    ["RED",    "teamRed",    [1, 0, 0, 1],             [1, 0, 0, 0.2],             "#(argb,8,8,3)color(1,0,0,1)"],
    ["GREEN",  "teamGreen",  [0, 1, 0, 1],             [0, 1, 0, 0.2],             "#(argb,8,8,3)color(0,1,0,1)"],
    ["BLUE",   "teamBlue",   [0, 0, 1, 1],             [0, 0, 1, 0.2],             "#(argb,8,8,3)color(0,0,1,1)"],
    ["YELLOW", "teamYellow", [1, 1, 0, 1],             [1, 1, 0, 0.2],             "#(argb,8,8,3)color(1,1,0,1)"],
    ["MAIN",   "teamMain",   [1, 1, 1, 1],             [1, 1, 1, 0.2],             "#(argb,8,8,3)color(1,1,1,1)"],
    ["ALL",    "teamAll",    [0.53, 0.29, 0.69, 1],    [0.53, 0.29, 0.69, 0.2],    "#(argb,8,8,3)color(0.53,0.29,0.69,1)"]
];

{
    _x params ["", "_controlKey", "", "_inactiveColor"];

    private _control = [_controlKey] call FUNC(ctrl);

    if !(isNull _control) then {
        _control ctrlSetBackgroundColor _inactiveColor;
    };
} forEach _teamData;

private _selectedUnits = (units player - [player]) select {
    private _assignedTeam = if (player isEqualTo cameraOn) then {
        assignedTeam _x
    } else {
        _x getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
    };

    (_assignedTeam isEqualTo _team) || {_team isEqualTo "ALL"}
};

uiNamespace setVariable [
    "A3C_UI_CustomFormation_selectedUnits",
    _selectedUnits
];

private _teamIndex = _teamData findIf {
    (_x select 0) isEqualTo _team
};

if (_teamIndex < 0) exitWith {};

(_teamData select _teamIndex) params [
    "",
    "_selectedControlKey",
    "_activeColor",
    "",
    "_lineColor"
];

uiNamespace setVariable [
    "A3C_C_FORM_LineColor",
    _lineColor
];

private _selectedControl = [_selectedControlKey] call FUNC(ctrl);

if !(isNull _selectedControl) then {
    _selectedControl ctrlSetBackgroundColor _activeColor;
};
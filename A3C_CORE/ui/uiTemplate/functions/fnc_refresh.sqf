#include "..\script_component.hpp"

private _state = uiNamespace getVariable [QGVAR(state), createHashMapFromArray [
    ["primaryEnabled", false],
    ["secondaryEnabled", false]
]];

uiNamespace setVariable [QGVAR(state), _state];

private _header = ["header"] call FUNC(ctrl);
private _primary = ["primary"] call FUNC(ctrl);
private _secondary = ["secondary"] call FUNC(ctrl);
private _status = ["status"] call FUNC(ctrl);
private _groupChild = ["groupChildExample"] call FUNC(ctrl);

if !(isNull _header) then {
    _header ctrlSetText "TEMPLATE DIALOG";
};

if !(isNull _primary) then {
    _primary ctrlSetText (["PRIMARY OFF", "PRIMARY ON"] select (_state get "primaryEnabled"));
};

if !(isNull _secondary) then {
    _secondary ctrlSetText (["SECONDARY OFF", "SECONDARY ON"] select (_state get "secondaryEnabled"));
};

if !(isNull _status) then {
    _status ctrlSetText format [
        "Primary: %1 | Secondary: %2",
        ["OFF", "ON"] select (_state get "primaryEnabled"),
        ["OFF", "ON"] select (_state get "secondaryEnabled")
    ];
};

if !(isNull _groupChild) then {
    _groupChild ctrlSetText "GROUP BTN";
};
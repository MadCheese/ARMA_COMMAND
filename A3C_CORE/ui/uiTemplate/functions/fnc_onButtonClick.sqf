#include "..\script_component.hpp"

params ["_control"];

private _buttonActions = uiNamespace getVariable [QGVAR(buttonActions), createHashMap];
private _action = _buttonActions getOrDefault [ctrlIDC _control, ""];

if (_action isEqualTo "") exitWith {};

private _state = uiNamespace getVariable [QGVAR(state), createHashMapFromArray [
    ["primaryEnabled", false],
    ["secondaryEnabled", false]
]];

switch (_action) do {
    case "primary": {
        _state set ["primaryEnabled", !(_state get "primaryEnabled")];
    };

    case "secondary": {
        _state set ["secondaryEnabled", !(_state get "secondaryEnabled")];
    };

    case "groupChildExample": {
        _state set ["primaryEnabled", false];
        _state set ["secondaryEnabled", false];
    };
};

uiNamespace setVariable [QGVAR(state), _state];

[] call FUNC(refresh);
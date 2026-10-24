
#include "..\script_component.hpp"

// A3C_ui_mapOverlay_fnc_onUnload

params ["_display"];


//-- Remove the Delete-key handler from the native map display.
private _data = _display getVariable [
    "A3C_MapDeleteHandler",
    []
];

if (_data isNotEqualTo []) then {
    _data params ["_mainMapDisplay", "_ehID"];

    if (
        !isNull _mainMapDisplay
        && {_ehID >= 0}
    ) then {
        _mainMapDisplay displayRemoveEventHandler [
            "KeyDown",
            _ehID
        ];
    };
};


uiNamespace setVariable [QGVAR(display), displayNull];
uiNamespace setVariable [QGVAR(groups), nil];
uiNamespace setVariable [QGVAR(controls), nil];

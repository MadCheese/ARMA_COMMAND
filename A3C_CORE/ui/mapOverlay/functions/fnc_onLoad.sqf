
#include "..\script_component.hpp"

// A3C_ui_mapOverlay_fnc_onLoad

params ["_display"];

uiNamespace setVariable [QGVAR(display), _display];

[] call FUNC(cacheGroups);
[] call FUNC(cacheControls);
[] call FUNC(refresh);


//-- Register Delete-key handler on the native map display.
//-- Control 51 does not receive DIK_DELETE (211).
private _mainMapDisplay = findDisplay 12;

if (!isNull _mainMapDisplay) then {
    private _ehID = _mainMapDisplay displayAddEventHandler [
        "KeyDown",
        {
            if ((_this select 1) != 211) exitWith {
                false
            };

            _this call A3C_ui_mapOverlay_fnc_MAP_onDeleteKey;
        }
    ];

    _display setVariable [
        "A3C_MapDeleteHandler",
        [_mainMapDisplay, _ehID]
    ];
};

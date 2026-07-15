#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

if !(profileNamespace getVariable ["A3C_UI_squadPlacement_overlayIsOpen", false]) then {
    ("A3C_UI_squadPlacement_overlay" call BIS_fnc_rscLayer) cutRsc ["A3C_UI_squadPlacement_overlay", "PLAIN"];
};

// RscTitles cutRsc may create the overlay display during this frame.
// Refresh caches before resolving controls through FUNC(ctrl).
[] call FUNC(cacheControls);

private _travelImage = ["overlayTravelImage"] call FUNC(ctrl);
private _destinationImage = ["overlayDestinationImage"] call FUNC(ctrl);
private _formImage = ["overlayFormImage"] call FUNC(ctrl);
private _speedImage = ["overlaySpeedImage"] call FUNC(ctrl);
private _goCodeImage = ["overlayGoCodeImage"] call FUNC(ctrl);
private _background = ["overlayBackground"] call FUNC(ctrl);
private _wpModeImage = ["overlayWpModeImage"] call FUNC(ctrl);
private _hideImage = ["overlayHideImage"] call FUNC(ctrl);

private _wpModeButton = ["wpModeButton"] call FUNC(ctrl);
private _hideButton = ["hideButton"] call FUNC(ctrl);

if !(isNull _travelImage) then {
    _travelImage ctrlSetText A3C_HUD_STANCE_ICON_TRAVEL;
    _travelImage ctrlSetTextColor [1, 1, 1, 1];
};

if !(isNull _destinationImage) then {
    _destinationImage ctrlSetText A3C_HUD_STANCE_ICON_DESTINATION;
    _destinationImage ctrlSetTextColor [1, 1, 1, 1];
};

if !(isNull _formImage) then {
    _formImage ctrlSetText A3C_HUD_FORM_ICON;
};

if !(isNull _speedImage) then {
    _speedImage ctrlSetText A3C_HUD_SPEED_ICON;
};

if !(isNull _goCodeImage) then {
    _goCodeImage ctrlSetText A3C_HUD_GOCODE_ICON;
    _goCodeImage ctrlSetTextColor A3C_HUD_GOCODE_ICON_COLOR;
};

if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true]) then {
    if !(isNull _wpModeImage) then {
        _wpModeImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_OverWrite.paa";
    };

    if !(isNull _wpModeButton) then {
        _wpModeButton ctrlSetTooltip "MODE: Override Plans";
    };
} else {
    if !(isNull _wpModeImage) then {
        _wpModeImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_Add.paa";
    };

    if !(isNull _wpModeButton) then {
        _wpModeButton ctrlSetTooltip "MODE: Add To Plans";
    };
};

if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", true]) then {
    if !(isNull _hideImage) then {
        _hideImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_true.paa";
    };

    if !(isNull _hideButton) then {
        _hideButton ctrlSetTooltip "UI: Shown";
    };
} else {
    if !(isNull _hideImage) then {
        _hideImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_false.paa";
    };

    if !(isNull _hideButton) then {
        _hideButton ctrlSetTooltip "UI: Hidden";
    };
};

if (profileNamespace getVariable ["A3C_HUD_LAYOUT_CORNER", false]) then {
    {
        private _ctrl = _x select 0;

        if !(isNull _ctrl) then {
            private _ctrlPos = ctrlPosition _ctrl;

            _ctrlPos set [0, (_x select 1) select 0];
            _ctrlPos set [1, (_x select 1) select 1];

            if (_ctrl isEqualTo _background) then {
                _ctrlPos = [
                    0.585951 * safezoneW + safezoneX,
                    0.335032 * safezoneH + safezoneY,
                    0.412564 * safezoneW,
                    0.660103 * safezoneH
                ];
            };

            _ctrl ctrlSetPosition _ctrlPos;
            _ctrl ctrlCommit 0;
        };
    } forEach [
        [_travelImage, [0.752122 * safezoneW + safezoneX, 0.906921 * safezoneH + safezoneY]],
        [_destinationImage, [0.832343 * safezoneW + safezoneX, 0.906921 * safezoneH + safezoneY]],
        [_formImage, [0.867525 * safezoneW + safezoneX, 0.784845 * safezoneH + safezoneY]],
        [_speedImage, [0.792233 * safezoneW + safezoneX, 0.906921 * safezoneH + safezoneY]],
        [_goCodeImage, [0.946944 * safezoneW + safezoneX, 0.65397 * safezoneH + safezoneY]],
        [_background, [0.585951 * safezoneW + safezoneX, 0.335032 * safezoneH + safezoneY]],
        [_wpModeImage, [0.946944 * safezoneW + safezoneX, 0.719957 * safezoneH + safezoneY]],
        [_hideImage, [0.946944 * safezoneW + safezoneX, 0.587983 * safezoneH + safezoneY]]
    ];

    if !(isNull _background) then {
        _background ctrlSetText "A3C_CORE\ui\pictures\BG_HUD_Menu_Corner.paa";
    };
} else {
    if !(isNull _background) then {
        _background ctrlSetText "A3C_CORE\ui\pictures\BG_HUD_Menu.paa";
    };
};

["HUD_MENU"] call A3C_ui_shared_fnc_getBackgroundColor;
[1] call FUNC(goCodeButton);
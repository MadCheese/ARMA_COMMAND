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

// Apply matching geometry to the title images and any open interaction buttons.
[] call FUNC(applyLayout);

["HUD_MENU"] call A3C_ui_shared_fnc_getBackgroundColor;
[1] call FUNC(goCodeButton);
#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

private _toolTip = "";

if (profileNamespace getVariable ["A3C_HUD_SPEED_VAR", -1] == -1) then {
    A3C_HUD_SPEED_ICON = "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
    profileNamespace setVariable ["A3C_HUD_SPEED_VAR", 2];

    _toolTip = "PACE: LIMITED";
} else {
    A3C_HUD_SPEED_ICON = "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
    profileNamespace setVariable ["A3C_HUD_SPEED_VAR", -1];

    _toolTip = "PACE: FULL";
};

private _speedButton = ["speedButton"] call FUNC(ctrl);
if !(isNull _speedButton) then {
    _speedButton ctrlSetTooltip _toolTip;
};

private _speedImage = ["overlaySpeedImage"] call FUNC(ctrl);
if !(isNull _speedImage) then {
    _speedImage ctrlSetText A3C_HUD_SPEED_ICON;
};
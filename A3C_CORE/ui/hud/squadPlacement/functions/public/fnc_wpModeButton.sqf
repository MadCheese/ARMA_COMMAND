#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

private _wpModeIcon = "";
private _toolTip = "";

if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true]) then {
    profileNamespace setVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", false];

    _wpModeIcon = "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_Add.paa";
    _toolTip = "MODE: Add To Plans";
} else {
    profileNamespace setVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true];

    _wpModeIcon = "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_OverWrite.paa";
    _toolTip = "MODE: Override Plans";
};

private _wpModeImage = ["overlayWpModeImage"] call FUNC(ctrl);
if !(isNull _wpModeImage) then {
    _wpModeImage ctrlSetText _wpModeIcon;
};

private _wpModeButton = ["wpModeButton"] call FUNC(ctrl);
if !(isNull _wpModeButton) then {
    _wpModeButton ctrlSetTooltip _toolTip;
};

[1] call FUNC(goCodeButton);
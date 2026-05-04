#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

private _hideIcon = "";
private _toolTip = "";

if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", true]) then {
    profileNamespace setVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", false];

    _hideIcon = "A3C_CORE\ui\pictures\icon_menu_showUI_false.paa";
    _toolTip = "UI: Hidden";
} else {
    profileNamespace setVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", true];

    _hideIcon = "A3C_CORE\ui\pictures\icon_menu_showUI_true.paa";
    _toolTip = "UI: Shown";
};

private _hideImage = ["overlayHideImage"] call FUNC(ctrl);
if !(isNull _hideImage) then {
    _hideImage ctrlSetText _hideIcon;
};

private _hideButton = ["hideButton"] call FUNC(ctrl);
if !(isNull _hideButton) then {
    _hideButton ctrlSetTooltip _toolTip;
};
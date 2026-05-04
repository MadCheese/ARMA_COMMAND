#include "..\..\script_component.hpp"

if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true]) then {
    profileNamespace setVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", false];

    ((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 16) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_Add.paa";
    (findDisplay 100050 displayCtrl 11) ctrlSetTooltip "MODE: Add To Plans";
} else {
    profileNamespace setVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true];

    ((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 16) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_OverWrite.paa";
    (findDisplay 100050 displayCtrl 11) ctrlSetTooltip "MODE: Override Plans";
};

[1] call FUNC(goCodeButton);
if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", true]) then {
    profileNamespace setVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", false];

    ((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 17) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_false.paa";
    (findDisplay 100050 displayCtrl 13) ctrlSetTooltip "UI: Hidden";
} else {
    profileNamespace setVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", true];

    ((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 17) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_true.paa";
    (findDisplay 100050 displayCtrl 13) ctrlSetTooltip "UI: Shown";
};
if (profileNamespace getVariable ["A3C_HUD_SPEED_VAR", -1] == -1) then {
    A3C_HUD_SPEED_ICON = "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
    profileNamespace setVariable ["A3C_HUD_SPEED_VAR", 2];

    (findDisplay 100050 displayCtrl 15) ctrlSetTooltip "PACE: LIMITED";
} else {
    A3C_HUD_SPEED_ICON = "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
    profileNamespace setVariable ["A3C_HUD_SPEED_VAR", -1];

    (findDisplay 100050 displayCtrl 15) ctrlSetTooltip "PACE: FULL";
};

((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 13) ctrlSetText A3C_HUD_SPEED_ICON;
#include "..\..\script_component.hpp"

if !(profileNamespace getVariable ["A3C_UI_squadPlacement_overlayIsOpen", false]) then {
    ("A3C_UI_squadPlacement_overlay" call BIS_fnc_rscLayer) cutRsc ["A3C_UI_squadPlacement_overlay", "PLAIN"];
};

private _overlayDisplay = uiNamespace getVariable ["A3C_UI_squadPlacement_overlay", displayNull];

if (isNull _overlayDisplay) exitWith {};

(_overlayDisplay displayCtrl 10) ctrlSetText A3C_HUD_STANCE_ICON_TRAVEL;
(_overlayDisplay displayCtrl 10) ctrlSetTextColor [1, 1, 1, 1];

(_overlayDisplay displayCtrl 11) ctrlSetText A3C_HUD_STANCE_ICON_DESTINATION;
(_overlayDisplay displayCtrl 11) ctrlSetTextColor [1, 1, 1, 1];

(_overlayDisplay displayCtrl 12) ctrlSetText A3C_HUD_FORM_ICON;
(_overlayDisplay displayCtrl 13) ctrlSetText A3C_HUD_SPEED_ICON;

if (profileNamespace getVariable ["A3C_HUD_LAYOUT_CORNER", false]) then {
    {
        private _ctrl = _overlayDisplay displayCtrl (_x select 0);
        private _ctrlPos = ctrlPosition _ctrl;

        _ctrlPos set [0, (_x select 1) select 0];
        _ctrlPos set [1, (_x select 1) select 1];

        if ((_x select 0) == 15) then {
            _ctrlPos = [
                0.585951 * safezoneW + safezoneX,
                0.335032 * safezoneH + safezoneY,
                0.412564 * safezoneW,
                0.660103 * safezoneH
            ];
        };

        _ctrl ctrlSetPosition _ctrlPos;
        _ctrl ctrlCommit 0;
    } forEach [
        [10, [0.752122 * safezoneW + safezoneX, 0.906921 * safezoneH + safezoneY]],
        [11, [0.832343 * safezoneW + safezoneX, 0.906921 * safezoneH + safezoneY]],
        [12, [0.867525 * safezoneW + safezoneX, 0.784845 * safezoneH + safezoneY]],
        [13, [0.792233 * safezoneW + safezoneX, 0.906921 * safezoneH + safezoneY]],
        [14, [0.946944 * safezoneW + safezoneX, 0.65397 * safezoneH + safezoneY]],
        [15, [0.585951 * safezoneW + safezoneX, 0.335032 * safezoneH + safezoneY]],
        [16, [0.946944 * safezoneW + safezoneX, 0.719957 * safezoneH + safezoneY]],
        [17, [0.946944 * safezoneW + safezoneX, 0.587983 * safezoneH + safezoneY]]
    ];

    (_overlayDisplay displayCtrl 15) ctrlSetText "A3C_CORE\ui\pictures\BG_HUD_Menu_Corner.paa";
} else {
    (_overlayDisplay displayCtrl 15) ctrlSetText "A3C_CORE\ui\pictures\BG_HUD_Menu.paa";
};

if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true]) then {
    (_overlayDisplay displayCtrl 16) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_OverWrite.paa";
    (findDisplay 100050 displayCtrl 11) ctrlSetTooltip "MODE: Override Plans";
} else {
    (_overlayDisplay displayCtrl 16) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_Add.paa";
    (findDisplay 100050 displayCtrl 11) ctrlSetTooltip "MODE: Add To Plans";
};

if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", true]) then {
    (_overlayDisplay displayCtrl 17) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_true.paa";
    (findDisplay 100050 displayCtrl 13) ctrlSetTooltip "UI: Shown";
} else {
    (_overlayDisplay displayCtrl 17) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_false.paa";
    (findDisplay 100050 displayCtrl 13) ctrlSetTooltip "UI: Hidden";
};

["HUD_MENU"] call A3C_UI_Shared_GetBackgroundColor;
[1] call FUNC(goCodeButton);
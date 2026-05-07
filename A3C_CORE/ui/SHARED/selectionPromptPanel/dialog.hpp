#include "script_component.hpp"
#include "dialog_defines.hpp"
#include "..\..\SHARED\shared_ui_defines.hpp"

#define GRIDX(num) (num * (pixelGrid * pixelW * 2))
#define GRIDY(num) (num * (pixelGrid * pixelH * 2))

#define MAIN_WIDTH 40
#define MAIN_HEIGHT 40

//-- NOTE: WHILE THIS DIALOG IS ONLY FOR THE HUD-VARIANT, THE MAP OVERLAY CONTAINS A TWIN VARIANT!!

class HUD_SelectionPromptPanel
{
    idd = IDD_SELECTION_PROMPT_PANEL;
    movingEnable = true;

    onLoad = EXPAND_AND_QUOTE(_this call FUNC(onLoad));
    onUnload = EXPAND_AND_QUOTE(_this call FUNC(onUnload));

    onKeyDown = EXPAND_AND_QUOTE(_this call FUNC(onKeyDown));
    onKeyUp = EXPAND_AND_QUOTE(_this call FUNC(onKeyUp));

    class ControlsBackground
    {
    };

    class Controls
    {
        class HUD_SelectionPromptPanel_Parent: A3C_RscControlsGroup_NoScroll
        {
            idc = IDC_SHARED_UI_SelectionPromptPanel_Parent;

            x = 0.383108 * safezoneW + safezoneX;
            y = 0.378986 * safezoneH + safezoneY;
            w = 0.192528 * safezoneW;
            h = 0.143016 * safezoneH;

            class Controls
            {
                class HUD_SelectionPromptPanel_Description_BG: A3C_RscPicture
                {
                    idc = IDC_SHARED_UI_SelectionPromptPanel_Description_BG;

                    text = "#(argb,8,8,3)color(0,0.3,0.6,1)";
                    x = 1.8033e-007 * safezoneW;
                    y = -1.80325e-007 * safezoneH;
                    w = 0.192528 * safezoneW;
                    h = 0.0440051 * safezoneH;
                };

                class HUD_SelectionPromptPanel_Description_TXT: A3C_RscText
                {
                    idc = IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;

                    x = 2.45904e-007 * safezoneW;
                    y = -3.77043e-007 * safezoneH;
                    w = 0.192528 * safezoneW;
                    h = 0.0440051 * safezoneH;
                };

                class HUD_SelectionPromptPanel_ListBox: A3C_LISTBOX
                {
                    idc = IDC_SHARED_UI_SelectionPromptPanel_ListBox;

                    style = CT_LISTBOX;
                    x = 2.45904e-007 * safezoneW;
                    y = 0.0440052 * safezoneH;
                    w = 0.192528 * safezoneW;
                    h = 0.0990114 * safezoneH;

                    onLBSelChanged = EXPAND_AND_QUOTE(_this call FUNC(onLBSelChanged));
                };
            };
        };
    };
};
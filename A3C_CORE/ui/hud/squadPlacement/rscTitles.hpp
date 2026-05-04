#include "script_component.hpp"
#include "dialog_defines.hpp"

#define GRIDX(num) (num * (pixelGrid * pixelW * 2))
#define GRIDY(num) (num * (pixelGrid * pixelH * 2))

#define MAIN_WIDTH 40
#define MAIN_HEIGHT 40

class RscTitles
{
    class A3C_HUD_MENU_UI
    {
        idd = IDD_SQUAD_PLACEMENT_OVERLAY;
        duration = 1000000000000;
        fadeIn = 0;
        fadeOut = 0;
        name = "A3C_HUD_MENU_UI";

        onLoad = EXPAND_AND_QUOTE(_this call FUNC(onOverlayLoad));
        onUnload = EXPAND_AND_QUOTE(_this call FUNC(onOverlayUnload));
        onDestroy = EXPAND_AND_QUOTE(_this call FUNC(onOverlayUnload));

        class ControlsBackground
        {
            class A3C_UI_squadPlacement_overlayGroup: A3C_RscControlsGroup_NoScroll
            {
                idc = IDC_SQUAD_PLACEMENT_PARENT;

                x = 0.5 - (GRIDX(MAIN_WIDTH) / 2);
                y = ((safezoneY + safezoneH) * 0.97) - GRIDY(MAIN_HEIGHT);
                w = GRIDX(MAIN_WIDTH);
                h = GRIDY(MAIN_HEIGHT);

                class Controls
                {
                    class A3C_UI_squadPlacement_background: A3C_RscPicture
                    {
                        idc = IDC_SQUAD_PLACEMENT_OVERLAY_BG;

                        x = 0;
                        y = 0;
                        w = GRIDX(MAIN_WIDTH);
                        h = GRIDY(MAIN_HEIGHT);
                    };

                    class A3C_UI_squadPlacement_formImage: A3C_RscPicture
                    {
                        idc = IDC_SQUAD_PLACEMENT_OVERLAY_FORM_IMG;

                        x = GRIDX(20) - GRIDX(6);
                        y = GRIDY(28);
                        w = GRIDX(12);
                        h = GRIDY(12);

                        colorText[] = {1, 1, 1, 1};
                    };

                    class A3C_UI_squadPlacement_travelImage: A3C_RscPicture
                    {
                        idc = IDC_SQUAD_PLACEMENT_OVERLAY_TRAVEL_IMG;

                        x = GRIDX(1);
                        y = GRIDY(32);
                        w = GRIDX(4);
                        h = GRIDY(4);
                    };

                    class A3C_UI_squadPlacement_speedImage: A3C_RscPicture
                    {
                        idc = IDC_SQUAD_PLACEMENT_OVERLAY_SPEED_IMG;

                        x = GRIDX(5);
                        y = GRIDY(32);
                        w = GRIDX(4);
                        h = GRIDY(4);
                    };

                    class A3C_UI_squadPlacement_destinationImage: A3C_RscPicture
                    {
                        idc = IDC_SQUAD_PLACEMENT_OVERLAY_DESTINATION_IMG;

                        x = GRIDX(10);
                        y = GRIDY(32);
                        w = GRIDX(4);
                        h = GRIDY(4);
                    };

                    class A3C_UI_squadPlacement_goCodeImage: A3C_RscPicture
                    {
                        idc = IDC_SQUAD_PLACEMENT_OVERLAY_GOCODE_IMG;

                        x = GRIDX(26);
                        y = GRIDY(32);
                        w = GRIDX(4);
                        h = GRIDY(4);
                    };

                    class A3C_UI_squadPlacement_wpModeImage: A3C_RscPicture
                    {
                        idc = IDC_SQUAD_PLACEMENT_OVERLAY_WPMODE_IMG;

                        x = GRIDX(30);
                        y = GRIDY(32);
                        w = GRIDX(4);
                        h = GRIDY(4);
                    };

                    class A3C_UI_squadPlacement_hideImage: A3C_RscPicture
                    {
                        idc = IDC_SQUAD_PLACEMENT_OVERLAY_HIDE_IMG;

                        x = GRIDX(35);
                        y = GRIDY(32);
                        w = GRIDX(4);
                        h = GRIDY(4);

                        text = "A3C_CORE\ui\pictures\icon_menu_showUI_true.paa";
                    };
                };
            };
        };
    };
};
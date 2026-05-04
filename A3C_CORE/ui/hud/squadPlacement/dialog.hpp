#include "script_component.hpp"
#include "dialog_defines.hpp"

#define GRIDX(num) (num * (pixelGrid * pixelW * 2))
#define GRIDY(num) (num * (pixelGrid * pixelH * 2))

#define MAIN_WIDTH 40
#define MAIN_HEIGHT 40

class A3C_HUD_MENU
{
    idd = IDD_SQUAD_PLACEMENT_INTERACTION;
    movingEnable = false;

    onLoad = EXPAND_AND_QUOTE(_this call FUNC(onLoad));
    onUnload = EXPAND_AND_QUOTE(_this call FUNC(onUnload));

    onKeyDown = EXPAND_AND_QUOTE(_this call FUNC(onKeyDown));
    onKeyUp = EXPAND_AND_QUOTE(_this call FUNC(onKeyUp));

    class ControlsBackground
    {
    };

    class Controls
    {
        class SQUAD_PLACEMENT_PARENT: A3C_RscControlsGroup_NoScroll
        {
            idc = IDC_SQUAD_PLACEMENT_PARENT;

            x = 0.5 - (GRIDX(MAIN_WIDTH) / 2);
            y = ((safezoneY + safezoneH) * 0.97) - GRIDY(MAIN_HEIGHT);
            w = GRIDX(MAIN_WIDTH);
            h = GRIDY(MAIN_HEIGHT);

            class Controls
            {
                class SQUAD_PLACEMENT_FORM_BTN: A3C_RscButton_Invisible
                {
                    idc = IDC_SQUAD_PLACEMENT_FORM_BTN;

                    x = GRIDX(20) - GRIDX(6);
                    y = GRIDY(28);
                    w = GRIDX(12);
                    h = GRIDY(12);

                    tooltip = "Change Formation";
                    onMouseButtonDown = EXPAND_AND_QUOTE(_this call FUNC(onMouseButtonDown));
                    onMouseZChanged = EXPAND_AND_QUOTE(_this call FUNC(onMouseZChanged));
                };

                class SQUAD_PLACEMENT_TRAVEL_BTN: A3C_RscButton_Invisible
                {
                    idc = IDC_SQUAD_PLACEMENT_TRAVEL_BTN;

                    x = GRIDX(1);
                    y = GRIDY(32);
                    w = GRIDX(4);
                    h = GRIDY(4);

                    tooltip = "Change Stance: TRAVEL";
                    onMouseButtonDown = EXPAND_AND_QUOTE(_this call FUNC(onMouseButtonDown));
                    onMouseZChanged = EXPAND_AND_QUOTE(_this call FUNC(onMouseZChanged));
                };

                class SQUAD_PLACEMENT_SPEED_BTN: A3C_RscButton_Invisible
                {
                    idc = IDC_SQUAD_PLACEMENT_SPEED_BTN;

                    x = GRIDX(5);
                    y = GRIDY(32);
                    w = GRIDX(4);
                    h = GRIDY(4);

                    onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));
                };

                class SQUAD_PLACEMENT_DESTINATION_BTN: A3C_RscButton_Invisible
                {
                    idc = IDC_SQUAD_PLACEMENT_DESTINATION_BTN;

                    x = GRIDX(10);
                    y = GRIDY(32);
                    w = GRIDX(4);
                    h = GRIDY(4);

                    tooltip = "Change Stance: DESTINATION";
                    onMouseButtonDown = EXPAND_AND_QUOTE(_this call FUNC(onMouseButtonDown));
                    onMouseZChanged = EXPAND_AND_QUOTE(_this call FUNC(onMouseZChanged));
                };

                class SQUAD_PLACEMENT_GOCODE_BTN: A3C_RscButton_Invisible
                {
                    idc = IDC_SQUAD_PLACEMENT_GOCODE_BTN;

                    x = GRIDX(26);
                    y = GRIDY(32);
                    w = GRIDX(4);
                    h = GRIDY(4);

                    onMouseButtonDown = EXPAND_AND_QUOTE(_this call FUNC(onMouseButtonDown));
                    onMouseZChanged = EXPAND_AND_QUOTE(_this call FUNC(onMouseZChanged));
                };

                class SQUAD_PLACEMENT_WPMODE_BTN: A3C_RscButton_Invisible
                {
                    idc = IDC_SQUAD_PLACEMENT_WPMODE_BTN;

                    x = GRIDX(30);
                    y = GRIDY(32);
                    w = GRIDX(4);
                    h = GRIDY(4);

                    onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));
                };

                class SQUAD_PLACEMENT_HIDE_BTN: A3C_RscButton_Invisible
                {
                    idc = IDC_SQUAD_PLACEMENT_HIDE_BTN;

                    x = GRIDX(35);
                    y = GRIDY(32);
                    w = GRIDX(4);
                    h = GRIDY(4);

                    onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));
                };
            };
        };
    };
};


#include "dialog_defines.hpp"

class A3C_DSP_TemplateDialog
{
    idd = IDD_TEMPLATE_DIALOG;
    movingEnable = 1;
    onLoad = "_this call FUNC(onLoad)";
    onUnload = "_this call FUNC(onUnload)";

    class ControlsBackground
    {
        class bgMain: A3C_RscPicture
        {
            idc = -1;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 8 * GUI_GRID_H + GUI_GRID_Y;
            w = 20 * GUI_GRID_W;
            h = 14 * GUI_GRID_H;
            text = "#(argb,8,8,3)color(0,0,0,0.7)";
        };
    };

    class Controls
    {
        class txtHeader: A3C_RscText
        {
            idc = IDC_TEMPLATE_HEADER;
            text = "TEMPLATE DIALOG";
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 8.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class btnPrimary: A3C_RscButton_Function
        {
            idc = IDC_TEMPLATE_BTN_PRIMARY;
            text = "PRIMARY";
            tooltip = "Primary template action";
            onButtonClick = "_this call FUNC(onButtonClick)";
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 11 * GUI_GRID_H + GUI_GRID_Y;
            w = 6 * GUI_GRID_W;
            h = 1.2 * GUI_GRID_H;
        };

        class btnSecondary: A3C_RscButton_Function
        {
            idc = IDC_TEMPLATE_BTN_SECONDARY;
            text = "SECONDARY";
            tooltip = "Secondary template action";
            onButtonClick = "_this call FUNC(onButtonClick)";
            x = 18 * GUI_GRID_W + GUI_GRID_X;
            y = 11 * GUI_GRID_H + GUI_GRID_Y;
            w = 6 * GUI_GRID_W;
            h = 1.2 * GUI_GRID_H;
        };

        class txtStatus: A3C_RscText
        {
            idc = IDC_TEMPLATE_STATUS;
            text = "READY";
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 13 * GUI_GRID_W;
            h = 1.2 * GUI_GRID_H;
        };

        class groupMain: A3C_RscControlsGroup
        {
            idc = IDC_TEMPLATE_GROUP_MAIN;
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 15.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 12 * GUI_GRID_W;
            h = 4 * GUI_GRID_H;

            class Controls
            {
                class btnChildExample: A3C_RscButton_Function
                {
                    idc = IDC_TEMPLATE_GROUP_CHILD_EXAMPLE;
                    text = "GROUP BTN";
                    onButtonClick = "_this call FUNC(onButtonClick)";
                    x = 0;
                    y = 0;
                    w = 5 * GUI_GRID_W;
                    h = 1.2 * GUI_GRID_H;
                };
            };
        };
    };
};#include "dialog_defines.hpp"

class A3C_DSP_TemplateDialog
{
    idd = IDD_TEMPLATE_DIALOG;
    movingEnable = 1;
    onLoad = "_this call FUNC(onLoad)";
    onUnload = "_this call FUNC(onUnload)";

    class ControlsBackground
    {
        class bgMain: A3C_RscPicture
        {
            idc = -1;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 8 * GUI_GRID_H + GUI_GRID_Y;
            w = 20 * GUI_GRID_W;
            h = 14 * GUI_GRID_H;
            text = "#(argb,8,8,3)color(0,0,0,0.7)";
        };
    };

    class Controls
    {
        class txtHeader: A3C_RscText
        {
            idc = IDC_TEMPLATE_HEADER;
            text = "TEMPLATE DIALOG";
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 8.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class btnPrimary: A3C_RscButton_Function
        {
            idc = IDC_TEMPLATE_BTN_PRIMARY;
            text = "PRIMARY";
            tooltip = "Primary template action";
            onButtonClick = "_this call FUNC(onButtonClick)";
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 11 * GUI_GRID_H + GUI_GRID_Y;
            w = 6 * GUI_GRID_W;
            h = 1.2 * GUI_GRID_H;
        };

        class btnSecondary: A3C_RscButton_Function
        {
            idc = IDC_TEMPLATE_BTN_SECONDARY;
            text = "SECONDARY";
            tooltip = "Secondary template action";
            onButtonClick = "_this call FUNC(onButtonClick)";
            x = 18 * GUI_GRID_W + GUI_GRID_X;
            y = 11 * GUI_GRID_H + GUI_GRID_Y;
            w = 6 * GUI_GRID_W;
            h = 1.2 * GUI_GRID_H;
        };

        class txtStatus: A3C_RscText
        {
            idc = IDC_TEMPLATE_STATUS;
            text = "READY";
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 13 * GUI_GRID_W;
            h = 1.2 * GUI_GRID_H;
        };

        class groupMain: A3C_RscControlsGroup
        {
            idc = IDC_TEMPLATE_GROUP_MAIN;
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 15.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 12 * GUI_GRID_W;
            h = 4 * GUI_GRID_H;

            class Controls
            {
                class btnChildExample: A3C_RscButton_Function
                {
                    idc = IDC_TEMPLATE_GROUP_CHILD_EXAMPLE;
                    text = "GROUP BTN";
                    onButtonClick = "_this call FUNC(onButtonClick)";
                    x = 0;
                    y = 0;
                    w = 5 * GUI_GRID_W;
                    h = 1.2 * GUI_GRID_H;
                };
            };
        };
    };
};
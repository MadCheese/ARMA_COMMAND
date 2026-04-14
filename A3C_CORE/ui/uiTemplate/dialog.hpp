#include "script_component.hpp"
#include "dialog_defines.hpp"

class A3C_DSP_TemplateDialog
{
    idd = IDD_TEMPLATE_DIALOG;
    movingEnable = 1;
    onLoad = QUOTE(_this call FUNC(onLoad));
    onUnload = QUOTE(_this call FUNC(onUnload));

    class ControlsBackground
    {
        class bgMain: A3C_RscPicture
        {
            idc = -1;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 8 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 10 * GUI_GRID_H;
            text = "#(argb,8,8,3)color(0,0,0,0.7)";
        };
    };

    class Controls
    {
        class txtHeader: A3C_RscText
        {
            idc = -1;
            text = "TEMPLATE DIALOG";
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 8.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
        };

        class txtPrimary: A3C_RscText
        {
            idc = -1;
            text = "PRIMARY:";
            style = 0;
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 11 * GUI_GRID_H + GUI_GRID_Y;
            w = 8 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class btnPrimary: A3C_RscButton_Function
        {
            idc = IDC_TEMPLATE_BTN_PRIMARY;
            text = "";
            tooltip = "Primary action";
            onButtonClick = QUOTE(_this call FUNC(onButtonClick));
            sizeEx = 0.04;
            x = 19 * GUI_GRID_W + GUI_GRID_X;
            y = 11.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class txtSecondary: A3C_RscText
        {
            idc = -1;
            text = "SECONDARY:";
            style = 0;
            x = 11 * GUI_GRID_W + GUI_GRID_X;
            y = 14 * GUI_GRID_H + GUI_GRID_Y;
            w = 8 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class btnSecondary: A3C_RscButton_Function
        {
            idc = IDC_TEMPLATE_BTN_SECONDARY;
            text = "";
            tooltip = "Secondary action";
            onButtonClick = QUOTE(_this call FUNC(onButtonClick));
            sizeEx = 0.04;
            x = 19 * GUI_GRID_W + GUI_GRID_X;
            y = 14.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
    };
};
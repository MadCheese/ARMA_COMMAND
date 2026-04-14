#include "script_component.hpp"
#include "dialog_defines.hpp"

class A3C_DSP_SettingsMenu
{
    idd = IDD_SETTINGS_MENU;
    movingEnable = 1;
    onLoad = QUOTE(_this call FUNC(onLoad));
    onUnload = QUOTE(_this call FUNC(onUnload));

    class ControlsBackground
    {
        class bgMain: A3C_RscPicture
        {
            idc = -1;
            x = 13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 6.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 13 * GUI_GRID_W;
            h = 21.5 * GUI_GRID_H;
            text = "#(argb,8,8,3)color(0,0,0,0.7)";
        };
    };

    class Controls
    {
        class txtHeader: A3C_RscText
        {
            idc = -1;
            text = "A3C - GLOBAL SETTINGS:";
            x = 15.5 * GUI_GRID_W + GUI_GRID_X;
            y = 6.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
        };

        class txtSkill: A3C_RscText
        {
            idc = -1;
            text = "AI-SKILL RESET:";
            style = 0;
            x = 14 * GUI_GRID_W + GUI_GRID_X;
            y = 8.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class btnSkill: A3C_RscButton_Function
        {
            idc = IDC_SETTINGS_MENU_BTN_SKILL;
            text = "";
            tooltip = "BOOST AI-SKILL";
            onButtonClick = QUOTE(_this call FUNC(onButtonClick));
            sizeEx = 0.04;
            x = 23.5 * GUI_GRID_W + GUI_GRID_X;
            y = 9 * GUI_GRID_H + GUI_GRID_Y;
            w = 1.5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class txtNum: A3C_RscText
        {
            idc = -1;
            text = "NUM-CONTROLS:";
            style = 0;
            x = 14 * GUI_GRID_W + GUI_GRID_X;
            y = 11 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class btnNum: A3C_RscButton_Function
        {
            idc = IDC_SETTINGS_MENU_BTN_NUM;
            text = "";
            tooltip = "TOGGLE NUMPAD FUNCTIONS";
            onButtonClick = QUOTE(_this call FUNC(onButtonClick));
            sizeEx = 0.04;
            x = 23.5 * GUI_GRID_W + GUI_GRID_X;
            y = 11.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 1.5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class txtHudReset: A3C_RscText
        {
            idc = -1;
            text = "AUTO RESET HUD:";
            style = 0;
            x = 14 * GUI_GRID_W + GUI_GRID_X;
            y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class btnHudReset: A3C_RscButton_Function
        {
            idc = IDC_SETTINGS_MENU_BTN_HUD_RESET;
            text = "";
            tooltip = "Reset HUD-formation to line when opening";
            onButtonClick = QUOTE(_this call FUNC(onButtonClick));
            sizeEx = 0.04;
            x = 23.5 * GUI_GRID_W + GUI_GRID_X;
            y = 14 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class txtAiRail: A3C_RscText
        {
            idc = -1;
            text = "AI RAIL:";
            style = 0;
            x = 14 * GUI_GRID_W + GUI_GRID_X;
            y = 16 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class btnAiRail: A3C_RscButton_Function
        {
            idc = IDC_SETTINGS_MENU_BTN_AI_RAIL;
            text = "";
            tooltip = "Final 'railing' towards destination (experimental)";
            onButtonClick = QUOTE(_this call FUNC(onButtonClick));
            sizeEx = 0.04;
            x = 23.5 * GUI_GRID_W + GUI_GRID_X;
            y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class txtHudLayout: A3C_RscText
        {
            idc = -1;
            text = "HUD-CORNER-UI";
            style = 0;
            x = 14 * GUI_GRID_W + GUI_GRID_X;
            y = 18.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class btnHudLayout: A3C_RscButton_Function
        {
            idc = IDC_SETTINGS_MENU_BTN_HUD_LAYOUT;
            text = "";
            tooltip = "Select HUD layout";
            onButtonClick = QUOTE(_this call FUNC(onButtonClick));
            sizeEx = 0.04;
            x = 23.5 * GUI_GRID_W + GUI_GRID_X;
            y = 19 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class txtHudObjects: A3C_RscText
        {
            idc = -1;
            text = "USE UNIT-HUD";
            style = 0;
            x = 14 * GUI_GRID_W + GUI_GRID_X;
            y = 21 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class btnHudObjects: A3C_RscButton_Function
        {
            idc = IDC_SETTINGS_MENU_BTN_HUD_OBJECTS;
            text = "";
            tooltip = "Select HUD objects (OFF: indicators, ON: units)";
            onButtonClick = QUOTE(_this call FUNC(onButtonClick));
            sizeEx = 0.04;
            x = 23.5 * GUI_GRID_W + GUI_GRID_X;
            y = 21.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class txtHcResponse: A3C_RscText
        {
            idc = -1;
            text = "HC-CT-RESPONSE";
            style = 0;
            x = 14 * GUI_GRID_W + GUI_GRID_X;
            y = 23 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class btnHcResponse: A3C_RscButton_Function
        {
            idc = IDC_SETTINGS_MENU_BTN_HC_RESPONSE;
            text = "";
            tooltip = "HC-Group Menu Response (OFF: CONFIRM, ON: IMMEDIATE)";
            onButtonClick = QUOTE(_this call FUNC(onButtonClick));
            sizeEx = 0.04;
            x = 23.5 * GUI_GRID_W + GUI_GRID_X;
            y = 23.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
    };
};
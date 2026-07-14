#include "script_component.hpp"
#include "dialog_defines.hpp"

class HUD_Formation_Menu
{
    idd = IDD_CUSTOM_FORMATION;
    movingEnable = 0;

    onLoad = EXPAND_AND_QUOTE(_this call FUNC(onLoad));
    onUnload = EXPAND_AND_QUOTE(_this call FUNC(onUnload));

    class ControlsBackground
    {
        class Background: A3C_RscPicture
        {
            idc = -1;
            text = "#(argb,8,8,3)color(0,0,0,0.5)";
            x = safezoneX;
            y = safezoneY;
            w = safezoneW;
            h = safezoneH;
        };

        class MouseSurface: A3C_RscButton_Invisible
        {
            idc = IDC_CUSTOM_FORMATION_MOUSE_SURFACE;
            text = "";

            x = safezoneX;
            y = safezoneY;
            w = safezoneW;
            h = safezoneH;

            onMouseButtonDown = EXPAND_AND_QUOTE(_this call FUNC(onMouseButtonDown));
            onMouseButtonUp = EXPAND_AND_QUOTE(_this call FUNC(onMouseButtonUp));
            onMouseMoving = EXPAND_AND_QUOTE(_this call FUNC(onMouseMoving));
        };
    };

    class Controls
    {
        class TeamRedButton: A3C_UnitButtonColorable
        {
            idc = IDC_CUSTOM_FORMATION_TEAM_RED;
            text = "TEAM RED";
            colorText[] = {1,1,1,1};

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.378981 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.044007 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));

            size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
            sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
        };

        class TeamGreenButton: A3C_UnitButtonColorable
        {
            idc = IDC_CUSTOM_FORMATION_TEAM_GREEN;
            text = "TEAM GREEN";

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.433989 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.044007 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));

            size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
            sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
        };

        class TeamBlueButton: A3C_UnitButtonColorable
        {
            idc = IDC_CUSTOM_FORMATION_TEAM_BLUE;
            text = "TEAM BLUE";

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.488998 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.044007 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));

            size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
            sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
        };

        class TeamYellowButton: A3C_UnitButtonColorable
        {
            idc = IDC_CUSTOM_FORMATION_TEAM_YELLOW;
            text = "TEAM YELLOW";

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.544007 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.044007 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));

            size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
            sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
        };

        class TeamMainButton: A3C_UnitButtonColorable
        {
            idc = IDC_CUSTOM_FORMATION_TEAM_MAIN;
            text = "TEAM MAIN";

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.599016 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.044007 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));

            size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
            sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
        };

        class TeamAllButton: A3C_UnitButtonColorable
        {
            idc = IDC_CUSTOM_FORMATION_TEAM_ALL;
            text = "ALL UNITS";

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.654025 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.044007 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));

            size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
            sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
        };

        class ActivationImage: A3C_RscPicture
        {
            idc = IDC_CUSTOM_FORMATION_ACTIVATION_IMAGE;
            text = "A3C_CORE\ui\pictures\BG_CFM_Oval.paa";

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.235958 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.121019 * safezoneH;
        };

        class ActivationButton: A3C_UnitButtonColorable
        {
            idc = IDC_CUSTOM_FORMATION_ACTIVATION_BUTTON;
            text = "";

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.235958 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.121019 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));

            size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
            sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
        };

        class ClearButton: A3C_RscButton
        {
            idc = IDC_CUSTOM_FORMATION_CLEAR_BUTTON;
            text = "CLEAR DATA";

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.180949 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.044007 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));
        };

        class SaveButton: A3C_RscButton
        {
            idc = IDC_CUSTOM_FORMATION_SAVE_BUTTON;
            text = "SAVE";

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.709033 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.044007 * safezoneH;

            onMouseButtonDown = EXPAND_AND_QUOTE(_this call FUNC(onSaveMouseButtonDown));
        };

        class SavedFormationsListbox: A3C_LISTBOX
        {
            idc = IDC_CUSTOM_FORMATION_SAVED_LISTBOX;
            style = CT_LISTBOX;

            x = 0.883773 * safezoneW + safezoneX;
            y = 0.764042 * safezoneH + safezoneY;
            w = 0.0973751 * safezoneW;
            h = 0.176028 * safezoneH;

            onLBSelChanged = EXPAND_AND_QUOTE(_this call FUNC(onListboxSelectionChanged));
        };
    };
};

class HUD_Formation_Menu_Save
{
    idd = IDD_CUSTOM_FORMATION_SAVE;
    movingEnable = 0;

    class ControlsBackground
    {
    };

    class Controls
    {
        class NameEdit: A3C_CT_EDIT
        {
            idc = IDC_CUSTOM_FORMATION_SAVE_NAME_EDIT;
            text = "TEXT";

            x = 0.282338 * safezoneW + safezoneX;
            y = 0.389982 * safezoneH + safezoneY;
            w = 0.349405 * safezoneW;
            h = 0.0550088 * safezoneH;
        };

        class ConfirmButton: A3C_RscButton
        {
            idc = IDC_CUSTOM_FORMATION_SAVE_CONFIRM_BUTTON;
            text = "SAVE";

            x = 0.637471 * safezoneW + safezoneX;
            y = 0.389982 * safezoneH + safezoneY;
            w = 0.0400956 * safezoneW;
            h = 0.0550088 * safezoneH;
        };

        class CancelButton: A3C_RscButton
        {
            idc = IDC_CUSTOM_FORMATION_SAVE_CANCEL_BUTTON;
            text = "CANCEL";

            x = 0.683294 * safezoneW + safezoneX;
            y = 0.389982 * safezoneH + safezoneY;
            w = 0.0400956 * safezoneW;
            h = 0.0550088 * safezoneH;
        };
    };
};
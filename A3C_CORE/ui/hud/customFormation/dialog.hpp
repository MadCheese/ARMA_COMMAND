#include "script_component.hpp"
#include "dialog_defines.hpp"

class A3C_CustomFormation_Line: A3C_RscText
{
    idc = -1;
    type = 0;
    style = 176;

    text = "";

    colorText[] = {1,1,1,0.8};
    colorBackground[] = {0,0,0,0};

    shadow = 0;

    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

class A3C_CustomFormation_CheckBox
{
    idc = -1;
    type = 77;
    style = 0;

    deletable = 0;
    checked = 0;

    x = 0;
    y = 0;
    w = 0.025 * safezoneW;
    h = 0.04 * safezoneH;

    color[] = {1,1,1,0.8};
    colorFocused[] = {1,1,1,1};
    colorHover[] = {1,1,1,1};
    colorPressed[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};

    colorBackground[] = {0,0,0,0};
    colorBackgroundFocused[] = {0,0,0,0};
    colorBackgroundHover[] = {0,0,0,0};
    colorBackgroundPressed[] = {0,0,0,0};
    colorBackgroundDisabled[] = {0,0,0,0};

    textureChecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_checked.paa";

    textureUnchecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_unchecked.paa";

    textureFocusedChecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_checked.paa";

    textureFocusedUnchecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_unchecked.paa";

    textureHoverChecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_checked.paa";

    textureHoverUnchecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_unchecked.paa";

    texturePressedChecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_checked.paa";

    texturePressedUnchecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_unchecked.paa";

    textureDisabledChecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_checked.paa";

    textureDisabledUnchecked =
        "A3C_CORE\ui\pictures\icon_menu_checkBox_unchecked.paa";

    tooltipColorText[] = {1,1,1,1};
    tooltipColorBox[] = {1,1,1,1};
    tooltipColorShade[] = {0,0,0,0.8};

    soundEnter[] = {"",0.1,1};
    soundPush[] = {"",0.1,1};
    soundClick[] = {"",0.1,1};
    soundEscape[] = {"",0.1,1};
};

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
            w = 0.069 * safezoneW;
            h = 0.044007 * safezoneH;

            onMouseButtonDown = EXPAND_AND_QUOTE(_this call FUNC(onSaveMouseButtonDown));
        };

        class ManageSavedImage: A3C_RscPicture
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_IMAGE;
            text = "A3C_CORE\ui\pictures\icon_menu_Trash.paa";

            x = 0.956773 * safezoneW + safezoneX;
            y = 0.709033 * safezoneH + safezoneY;
            w = 0.0243751 * safezoneW;
            h = 0.044007 * safezoneH;

            colorText[] = {1,1,1,1};
        };

        class ManageSavedButton: A3C_RscButton_Invisible
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_BUTTON;
            text = "";
            tooltip = "Manage saved formations";

            x = 0.956773 * safezoneW + safezoneX;
            y = 0.709033 * safezoneH + safezoneY;
            w = 0.0243751 * safezoneW;
            h = 0.044007 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onButtonClick));
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

class HUD_Formation_Manage
{
    idd = IDD_CUSTOM_FORMATION_MANAGE;
    movingEnable = 0;

    onLoad = EXPAND_AND_QUOTE(_this call FUNC(manageOnLoad));
    onUnload = EXPAND_AND_QUOTE(_this call FUNC(manageOnUnload));

    class ControlsBackground
    {
        class ModalShade: A3C_RscPicture
        {
            idc = -1;
            text = "#(argb,8,8,3)color(0,0,0,0.65)";

            x = safezoneX;
            y = safezoneY;
            w = safezoneW;
            h = safezoneH;
        };

        class PanelBackground: A3C_RscPicture
        {
            idc = -1;
            text = "#(argb,8,8,3)color(0.05,0.05,0.05,0.98)";

            x = 0.25 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.7 * safezoneH;
        };

        class HeaderBackground: A3C_RscPicture
        {
            idc = -1;
            text = "#(argb,8,8,3)color(0.14,0.14,0.14,1)";

            x = 0.25 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.055 * safezoneH;
        };

        class ToolbarBackground: A3C_RscPicture
        {
            idc = -1;
            text = "#(argb,8,8,3)color(0.09,0.09,0.09,1)";

            x = 0.25 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.055 * safezoneH;
        };
    };

    class Controls
    {
        class HeaderTitle: A3C_RscText
        {
            idc = -1;
            text = "MANAGE SAVED FORMATIONS";

            x = 0.27 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.42 * safezoneW;
            h = 0.055 * safezoneH;

            colorText[] = {1,1,1,1};
        };

        class CloseButton: A3C_RscButton
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_CLOSE_BUTTON;
            text = "X";
            tooltip = "Close";

            x = 0.715 * safezoneW + safezoneX;
            y = 0.158 * safezoneH + safezoneY;
            w = 0.025 * safezoneW;
            h = 0.039 * safezoneH;

            colorBackground[] = {0.65,0.05,0.05,1};
            colorBackgroundActive[] = {0.9,0.05,0.05,1};

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onManageButtonClick));
        };

        class SelectAllCheckBox: A3C_CustomFormation_CheckBox
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_SELECT_ALL;
            tooltip = "Select or clear all formations";

            x = 0.27 * safezoneW + safezoneX;
            y = 0.216 * safezoneH + safezoneY;
            w = 0.022 * safezoneW;
            h = 0.033 * safezoneH;

            onCheckedChanged = EXPAND_AND_QUOTE(_this call FUNC(onManageCheckedChanged));
        };

        class SelectedCount: A3C_RscText
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_SELECTED_COUNT;
            text = "0 selected";

            x = 0.3 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.055 * safezoneH;
        };

        class TrashImage: A3C_RscPicture
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_TRASH_IMAGE;
            text = "A3C_CORE\ui\pictures\icon_menu_Trash.paa";

            x = 0.705 * safezoneW + safezoneX;
            y = 0.215 * safezoneH + safezoneY;
            w = 0.025 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class TrashButton: A3C_RscButton_Invisible
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_TRASH_BUTTON;
            text = "";
            tooltip = "Delete selected formations";

            x = 0.705 * safezoneW + safezoneX;
            y = 0.215 * safezoneH + safezoneY;
            w = 0.025 * safezoneW;
            h = 0.035 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onManageButtonClick));
        };

        class RowsGroup: A3C_RscControlsGroup
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_ROWS_GROUP;

            x = 0.27 * safezoneW + safezoneX;
            y = 0.275 * safezoneH + safezoneY;
            w = 0.46 * safezoneW;
            h = 0.55 * safezoneH;

            class Controls
            {
            };
        };

        class EmptyText: A3C_RscText
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_EMPTY_TEXT;
            text = "NO SAVED FORMATIONS";

            x = 0.27 * safezoneW + safezoneX;
            y = 0.49 * safezoneH + safezoneY;
            w = 0.46 * safezoneW;
            h = 0.05 * safezoneH;

            style = 2;
            colorText[] = {1,1,1,0.6};
        };

        class ConfirmText: A3C_RscText
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_CONFIRM_TEXT;
            text = "";

            x = 0.27 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.285 * safezoneW;
            h = 0.055 * safezoneH;
        };

        class ConfirmCancelButton: A3C_RscButton
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_CONFIRM_CANCEL;
            text = "CANCEL";

            x = 0.56 * safezoneW + safezoneX;
            y = 0.212 * safezoneH + safezoneY;
            w = 0.075 * safezoneW;
            h = 0.041 * safezoneH;

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onManageButtonClick));
        };

        class ConfirmDeleteButton: A3C_RscButton
        {
            idc = IDC_CUSTOM_FORMATION_MANAGE_CONFIRM_DELETE;
            text = "DELETE";

            x = 0.64 * safezoneW + safezoneX;
            y = 0.212 * safezoneH + safezoneY;
            w = 0.09 * safezoneW;
            h = 0.041 * safezoneH;

            colorBackground[] = {0.65,0.05,0.05,1};
            colorBackgroundActive[] = {0.9,0.05,0.05,1};

            onButtonClick = EXPAND_AND_QUOTE(_this call FUNC(onManageButtonClick));
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
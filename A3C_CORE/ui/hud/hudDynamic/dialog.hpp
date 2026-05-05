#include "script_component.hpp"
#include "dialog_defines.hpp"

#define GRIDX(num) (num * (pixelGrid * pixelW * 2))
#define GRIDY(num) (num * (pixelGrid * pixelH * 2))

// UI element sizes.
#define MAIN_WIDTH 110
#define MAIN_HEIGHT 60

// Dynamic HUD dialog host.
// Used for dynamic dialogs made with createDialog/createDisplay/ctrlCreate.
//
// Current usage:
// - ROE popup from radial.

class A3C_DSP_HUD_DYNAMIC
{
    idd = IDD_HUD_DYNAMIC;
    movingEnable = false;

    onLoad = EXPAND_AND_QUOTE(_this call FUNC(onLoad));
    onUnload = EXPAND_AND_QUOTE(_this call FUNC(onUnload));
    onKeyUp = EXPAND_AND_QUOTE(_this call FUNC(onKeyUp));

    class ControlsBackground
    {
        class MCSS_A3C_BHV_CBM_Background: A3C_RscButton_Invisible
        {
            idc = IDC_HUD_DYNAMIC_BACKGROUND;

            x = safezoneX;
            y = safezoneY;
            w = safezoneW;
            h = safezoneH;
        };
    };

    class Controls
    {
    };
};
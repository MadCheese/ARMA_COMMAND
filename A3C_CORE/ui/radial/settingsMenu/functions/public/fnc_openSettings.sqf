#include "..\..\dialog_defines.hpp"

[] call A3C_UI_RADIAL_CloseDisplay;
A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [(A3C_RadialMenu_KEY_ID select 0)];

with uiNamespace do {
    A3C_DG_SETTINGS = (findDisplay 46) createDisplay "A3C_DSP_SettingsMenu";
};


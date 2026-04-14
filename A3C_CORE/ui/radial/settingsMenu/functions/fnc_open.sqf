#include "..\dialog_defines.hpp"

[] call A3C_RADIAL_CloseDisplay;
A3C_DOWNKEYS = A3C_DOWNKEYS - [(A3C_RadialMenu_KEY_ID select 0)];

with uiNamespace do {
    A3C_DG_SETTINGS = (findDisplay 46) createDisplay "A3C_DSP_SettingsMenu";
};

[
    IDD_SETTINGS_MENU,
    "RADIAL",
    {true},
    {},
    {
        (findDisplay IDD_SETTINGS_MENU) closeDisplay 0;
        showCommandingMenu "";
        (findDisplay IDD_SETTINGS_MENU) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
    },
    true
] call A3C_UI_RADIAL_ADD_EH_MACROS;
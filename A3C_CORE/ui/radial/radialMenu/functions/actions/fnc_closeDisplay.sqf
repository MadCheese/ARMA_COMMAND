#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_closeDisplay

showHUD ([true] + (shownHUD select [1, 10]));

(findDisplay IDD_RADIAL_MENU) closeDisplay 0;
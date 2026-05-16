#include "..\..\dialog_defines.hpp"

private _display = findDisplay IDD_RADIAL_MENU;

if (
    !isNull _display &&
    { ctrlShown (_display displayCtrl IDC_RADIAL_BG_TOP) } &&
    { A3C_RADIALMODE in ["ACT", "HC ACTIONS"] }
) then {
    [false] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
};
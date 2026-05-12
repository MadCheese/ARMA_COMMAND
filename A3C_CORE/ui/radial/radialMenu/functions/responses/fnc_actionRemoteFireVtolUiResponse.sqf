#include "..\..\dialog_defines.hpp"


sleep 2;

if (
	!isNull findDisplay IDD_RADIAL_MENU
	&& {ctrlShown (findDisplay IDD_RADIAL_MENU displayctrl IDC_RADIAL_BG_TOP)}
	&& {A3C_RADIALMODE in ['ACT','HC ACTIONS']}
) then {
	[false] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
};

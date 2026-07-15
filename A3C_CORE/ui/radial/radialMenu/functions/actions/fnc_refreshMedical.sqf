#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_refreshMedical

if (A3C_LBR_1 == "MEDICAL") then {
	private _display = findDisplay IDD_RADIAL_MENU;

	if (ctrlShown (_display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_GO_BTN)) then {
		//-- Clear right extension listboxes.
		{
			lbClear _x;
		} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));

		["MEDICAL"] call A3C_ui_radialMenu_fnc_labelListbox;
	};
};
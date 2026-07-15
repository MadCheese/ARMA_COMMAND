#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_ctrlsQuickToggle

params ["_mode"];

private _hidden = false;

if (_mode == 0) then {
	_hidden = true;

	if (!A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED) then {
		A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED = true;
		A3C_UI_RADIAL_CTRLS_SHOWN = [];

		{
			if (ctrlShown _x) then {
				A3C_UI_RADIAL_CTRLS_SHOWN pushBackUnique _x;
				_x ctrlShow false;
			};
		} forEach (allControls (findDisplay IDD_RADIAL_MENU));
	};
} else {
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT)
		ctrlShow false;

	A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED = false;

	{
		_x ctrlShow true;
	} forEach A3C_UI_RADIAL_CTRLS_SHOWN;

	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX)
		ctrlShow false;

	A3C_UI_RADIAL_CTRLS_SHOWN = [];

	if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
		[] call A3C_UI_SHARED_createDashBoard;
	};
};

_hidden
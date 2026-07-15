#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_extensionLeftToggle

params ["_mode"];

private _display = findDisplay IDD_RADIAL_MENU;
private _extensionLeftGroup = _display displayCtrl IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP;

if (_mode == "OPEN") then {
	if (A3C_RD_BOOL_UNITS) then {
		if !(ctrlShown _extensionLeftGroup) then {
			playSound "ReadOutHideClick1";

			A3C_RD_BOOL_UNITS = false;

			{
				_x ctrlShow true;
			} forEach (["radial_extensionLeft"] call FUNC(ctrlGroup));

			(_display displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX) ctrlShow false;

			[
				IDD_RADIAL_MENU,
				if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {"INF"} else {"HC"}
			] call A3C_UI_MAP_Overlay_ResizeTeamColorsXWH;

			[0] call A3C_UI_MAP_RESIZE_TEAMCOLORS_Y;

			[
				IDD_RADIAL_MENU,
				IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP
			] execFSM "A3C_CORE\FSM\A3C_MON_RADIAL.fsm";
		};
	};
} else {
	if (ctrlShown _extensionLeftGroup) then {
		playSound "ReadOutHideClick1";

		{
			_x ctrlShow false;
		} forEach (["radial_extensionLeft"] call FUNC(ctrlGroup));

		A3C_RD_BOOL_UNITS = false;
	};
};
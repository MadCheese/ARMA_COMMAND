#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_reArm_lbChangeSourceContent

params ["_contentIndex", "_doubleClick"];

if (_contentIndex < 0) exitWith {};

if (_doubleClick && { (count A3C_RD_UNITS) == 1 }) then {
	private _contentListBox = findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX;

	private _listBoxText = _contentListBox lbText _contentIndex;
	private _item = if (_listBoxText == "Open Inventory") then {
		"INVENTORY"
	} else {
		A3C_REARM_CARGO select (_contentIndex - 1)
	};

	private _unit = A3C_RD_UNITS select 0;

	[_unit, A3C_TARGETVEH, _item] call A3C_ai_shared_fnc_reArm_plotAddItem;
};
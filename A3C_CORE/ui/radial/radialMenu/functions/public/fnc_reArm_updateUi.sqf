#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_reArm_updateUi

private _display = findDisplay IDD_RADIAL_MENU;
if (isNull _display) exitWith {};

private _sourcesListBox = _display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX;
if (isNull _sourcesListBox) exitWith {};

private _contentListBox = _display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX;
if (isNull _contentListBox) exitWith {};

if (ctrlShown _sourcesListBox && { A3C_LBR_1 == "REARM" }) then {
	private _selectedSourceIndex = lbCurSel _sourcesListBox;
	private _selectedContentIndex = lbCurSel _contentListBox;

	if (_selectedSourceIndex >= 0) then {
		[_selectedSourceIndex] call A3C_ui_radialMenu_fnc_reArm_lbChangeSource;
	};

	if (
		_selectedContentIndex >= 0 &&
		{ _selectedContentIndex < lbSize _contentListBox }
	) then {
		[_contentListBox, _selectedContentIndex] call A3C_ui_shared_fnc_lbSetCurSel;
	};
};
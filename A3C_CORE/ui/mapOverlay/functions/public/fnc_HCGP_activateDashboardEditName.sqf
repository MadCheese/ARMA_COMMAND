#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCGP_activateDashboardEditName

params ["_mode"];

private _display = findDisplay IDD_MAP_OVERLAY;

if (isNull _display) exitWith {};

private _textControl =
	_display displayCtrl IDC_SHARED_UI_DASHBOARD_GROUPNAME;

private _editControl =
	_display displayCtrl IDC_MAP_DASHBOARD_GROUPNAME_EDIT;

private _groupName = str parseText ctrlText _editControl;

if (_mode == "ON") then {
	_textControl ctrlSetTextColor [0, 0, 1, 0];

	_editControl ctrlSetText _groupName;
	_editControl ctrlSetTextColor [0, 1, 1, 0.5];

	A3C_GROUP_NAMING_ACTIVE = true;
} else {
	A3C_GROUP_NAMING_ACTIVE = nil;

	_textControl ctrlSetText _groupName;
	_textControl ctrlSetTextColor [1, 1, 1, 1];

	_editControl ctrlSetTextColor [1, 1, 1, 0];
};
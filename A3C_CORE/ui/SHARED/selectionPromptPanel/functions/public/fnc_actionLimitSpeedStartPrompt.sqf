#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"


//-- Note: This action does not have a action script - this script is the dispatcher, selectionPromptPanel's onLbSelChanged issues the action

A3C_SelectionPromptPanel_MODE = "SPEEDLIMIT";

private _displayId = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_RADIAL_MENU
};

private _isRadial = _displayId == IDD_RADIAL_MENU;

if (_isRadial) then {
	_displayId = IDD_SELECTION_PROMPT_PANEL;

	A3C_DISABLE_RADIAL = true;
	[] call A3C_ui_radialMenu_fnc_closeDisplay;

	with uiNamespace do {
		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
	};
} else {
	private _mapOverlayDisplay = findDisplay IDD_MAP_OVERLAY;

	{
		(_mapOverlayDisplay displayCtrl _x) ctrlShow false;
	} forEach [
		IDC_MAP_HCGP_Parent,
		IDC_SHARED_UI_DASHBOARD_PARENT
	];

	(findDisplay 12 displayCtrl 51) ctrlEnable true;
};

private _display = findDisplay _displayId;
private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;
private _text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;


_parent ctrlSetPosition [
	0.383108 * safezoneW + safezoneX,
	0.378986 * safezoneH + safezoneY
];
_parent ctrlCommit 0;
_parent ctrlShow true;

_text ctrlSetText "Select Max Speed";

private _speedOptions = [
	"FULL PACE",
	"JOGGING PACE",
	"COMBAT PACE",
	"WALKING PACE"
];

private _listHeightIncrease = (count _speedOptions) * (0.0440051 * safezoneH);

{
	private _ctrl = _x;
	private _ctrlPos = ctrlPosition _ctrl;

	_ctrlPos set [3, (_ctrlPos select 3) + _listHeightIncrease];

	_ctrl ctrlSetPosition _ctrlPos;
	_ctrl ctrlCommit 0;
} forEach [
	_parent,
	_listBox
];

lbClear _listBox;

{
	[_listBox, _x] call A3C_ui_shared_fnc_addLbEntry;
} forEach _speedOptions;
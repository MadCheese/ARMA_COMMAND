#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

private _group = if (!isNull findDisplay IDD_RADIAL_MENU) then {
	A3C_RD_UNITS select 0
} else {
	A3C_SELECTED_HC_GROUPS_SETTINGS select 0
};

private _displayId = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

if (_displayId == IDD_SELECTION_PROMPT_PANEL) then {
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

	private _mapDisplay = findDisplay 12;
	(_mapDisplay displayCtrl 51) ctrlEnable true;
};

private _display = findDisplay _displayId;
private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

A3C_SelectionPromptPanel_MODE = "flyInHeight";

lbClear _listBox;

_parent ctrlShow true;

_text ctrlSetText "Select Flying-Height";

private _heightArray = A3C_FlyinHeightArrayHeli;

if ((vehicle leader _group) isKindOf "PLANE") then {
	_heightArray = A3C_FlyinHeightArrayJet;
};

[_parent, _listBox, count _heightArray] call A3C_OBJECTSEL_RESIZE;

{
	[_listBox, _x] call A3C_addLbEntry;
} forEach _heightArray;
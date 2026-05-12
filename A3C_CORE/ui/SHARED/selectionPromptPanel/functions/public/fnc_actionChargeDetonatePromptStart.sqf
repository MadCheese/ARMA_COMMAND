#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

//-- Note: This action does not have a dispatcher. This fnc opens correct SelectionPromptPanel, SelectionPromptPanel's onLbSelChanged issues the action.

A3C_SelectionPromptPanel_MODE = "DETONATE_SELECTED_CHARGE_SHARED";

with uiNamespace do {
	A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
};

private _display = if (!isNull findDisplay IDD_MAP_OVERLAY) then {
	findDisplay IDD_MAP_OVERLAY
} else {
	findDisplay IDD_SELECTION_PROMPT_PANEL
};

if (isNull _display) exitWith {};

private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

if (isNull _parent || {isNull _text} || {isNull _listBox}) exitWith {};

_parent ctrlShow true;
_parent ctrlSetPosition [
	0.383108 * safezoneW + safezoneX,
	0.378986 * safezoneH + safezoneY
];
_parent ctrlCommit 0;

_text ctrlSetText "Detonate Charges";

[] call A3C_UI_selectionPromptPanel_fnc_actionChargeDetonatePromptRefresh;
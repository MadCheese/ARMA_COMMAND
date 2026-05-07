#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

A3C_SelectionPromptPanel_MODE = "DETONATE_SELECTED_CHARGE_SHARED";
with uiNamespace do {
	A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
};

private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_SELECTION_PROMPT_PANEL};
private _parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

_parent ctrlShow true;
_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
_parent ctrlCommit 0;
_text ctrlSetText "Detonate Charges";

[] call A3C_UI_selectionPromptPanel_fnc_chargePromptRefresh;

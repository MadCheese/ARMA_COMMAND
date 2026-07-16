#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\selectionPromptPanel\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCGP_actionMergeGroups

//-- #TODO: move this to ai_highCommand and create ui-response

disableSerialization;

params ["_groupArray"];

if (count _groupArray == 0) exitWith {};

A3C_SELECTED_HC_GROUPS_SETTINGS = +_groupArray;

private _displayId = if (
	!isNull findDisplay IDD_MAP_OVERLAY
) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

private _mapOverlayDisplay =
	findDisplay IDD_MAP_OVERLAY;

{
	(
		_mapOverlayDisplay displayCtrl _x
	) ctrlShow false;
} forEach [
	IDC_MAP_HCGP_Parent,
	IDC_SHARED_UI_DASHBOARD_PARENT
];

(
	findDisplay 12 displayCtrl 51
) ctrlEnable true;

if (count _groupArray <= 1) then {
	[
		_groupArray
	] spawn A3C_ui_mapOverlay_fnc_rejoinDisbandedToPlayerGroup;
} else {
	if (_displayId == IDD_SELECTION_PROMPT_PANEL) then {
		with uiNamespace do {
			A3C_HUD_OBS = (
				findDisplay 46
			) createDisplay "HUD_SelectionPromptPanel";
		};
	};

	private _display =
		findDisplay _displayId;

	private _parent =
		_display
			displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;

	private _descriptionText =
		_display
			displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;

	private _listBox =
		_display
			displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

	_parent ctrlShow true;

	_parent ctrlSetPosition [
		0.383108 * safeZoneW + safeZoneX,
		0.378986 * safeZoneH + safeZoneY
	];

	_parent ctrlCommit 0;

	_descriptionText ctrlSetText format [
		"Really join %1 groups to your squad?",
		count A3C_SELECTED_HC_GROUPS_SETTINGS
	];

	A3C_SelectionPromptPanel_MODE = "SECU_REJOIN";

	lbClear _listBox;

	{
		[
			_listBox,
			_x
		] call A3C_ui_shared_fnc_addLbEntry;
	} forEach [
		"Cancel",
		"Proceed"
	];
};
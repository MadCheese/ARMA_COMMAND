#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\selectionPromptPanel\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCGP_actionParaLoadAndDrop

//-- #TODO: move this to ai_highCommand and create ui-response(s)

disableSerialization;

params ["_call"];

private _displayId = if (
	!isNull findDisplay IDD_MAP_OVERLAY
) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

private _vehicle = if (isNull _call) then {
	vehicle leader (
		A3C_SELECTED_HC_GROUPS_SETTINGS select 0
	)
} else {
	_call
};

if ((getPosATL _vehicle select 2) > 1) then {
	// Vehicle is airborne.
	_vehicle setVariable [
		"A3C_ParadropActive",
		true,
		true
	];

	[
		false
	] call A3C_ui_shared_fnc_highCommand_actionsLabel;

	[
		[
			getPlayerUID player,
			_vehicle
		],
		A3C_ai_shared_fnc_paradropManage
	] remoteExec [
		"BIS_fnc_call",
		_vehicle
	];
} else {
	// Vehicle is on the ground.
	private _cargoObjects = [
		_vehicle
	] call A3C_main_fnc_getNearCargoLoadObjects;

	if (count _cargoObjects > 0) then {
		A3C_SelectionPromptPanel_MODE = "PARALOAD";

		if (!isNull findDisplay IDD_RADIAL_MENU) then {
			A3C_DISABLE_RADIAL = true;

			[] call A3C_ui_radialMenu_fnc_closeDisplay;

			with uiNamespace do {
				A3C_HUD_OBS = (
					findDisplay 46
				) createDisplay "HUD_SelectionPromptPanel";
			};
		} else {
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

		_descriptionText ctrlSetText
			"Select Object to load";

		ctrlSetFocus _listBox;
		lbClear _listBox;

		{
			private _cargoObject = _x;

			private _crewDescription = if (
				count crew _cargoObject == 0
			) then {
				"Empty"
			} else {
				groupId group (
					crew _cargoObject select 0
				)
			};

			private _listBoxText = format [
				"%1: %2 (%3m)",
				getText (
					configFile
						>> "CfgVehicles"
						>> typeOf _cargoObject
						>> "displayName"
				),
				_crewDescription,
				round (
					_vehicle distance _cargoObject
				)
			];

			[
				_listBox,
				_listBoxText
			] call A3C_ui_shared_fnc_addLbEntry;
		} forEach _cargoObjects;
	} else {
		systemChat "A3C: No loadable objects closeby";
	};
};
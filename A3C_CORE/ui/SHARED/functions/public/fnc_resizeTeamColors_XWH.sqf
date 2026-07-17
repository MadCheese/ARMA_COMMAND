#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_resizeTeamColors_XWH

/*
	Adjusts the horizontal position, width, and height of the shared
	team-color controls.

	The map-overlay controls are initially placed below the visible screen.
	A3C_ui_shared_fnc_resizeTeamColors_Y subsequently moves applicable
	controls to their visible Y position and hides unused controls.
*/
params [
	"_displayId",
	"_mode"
];

// High-command team-color controls are currently disabled.
if (_mode == "HC") exitWith {};

private _display = findDisplay _displayId;

if (isNull _display) exitWith {};

private _treeControl = _display displayCtrl IDC_SHARED_UI_TREE_SELECTOR;

if (isNull _treeControl) exitWith {};

private _isRadial = _displayId == IDD_RADIAL_MENU;

// Hardcoded dimensions matching the team-color controls in the dialogs.
private _controlX = if (_isRadial) then {
	0
} else {
	A3C_MAP_OVERLAY_GAMEUI_TREEX
};

private _controlHeight = 0.0110018 * safeZoneH;
private _totalWidth = (ctrlPosition _treeControl) select 2;
private _gapWidth = A3C_MAP_GAMEUI_PADDING_Y / 2;

private _referenceUnits = (units player) - [player];
private _teamColors = [];

{
	private _testedColor = _x;

	private _hasAssignedUnit = _referenceUnits findIf {
		private _assignedTeam = if (player == cameraOn) then {
			assignedTeam _x
		} else {
			_x getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
		};

		_assignedTeam == _testedColor
	} > -1;

	if (_hasAssignedUnit) then {
		_teamColors pushBack _testedColor;
	};
} forEach [
	"RED",
	"GREEN",
	"BLUE",
	"YELLOW",
	"MAIN"
];

if (_teamColors isEqualTo []) exitWith {};

// The purple pair represents the combined "ALL" team-color control.
if (count _teamColors > 1) then {
	_teamColors pushBack "PURPLE";
};

private _gapCount = (count _teamColors) - 1;

private _dynamicControlWidth = (
	_totalWidth - (_gapCount * _gapWidth)
) / count _teamColors;

{
	private _teamColor = _x;

	private _controlIds = switch (_teamColor) do {
		case "RED": {
			[
				IDC_SHARED_UI_TCBOX_RED_IMG,
				IDC_SHARED_UI_TCBOX_RED_BTN
			]
		};

		case "GREEN": {
			[
				IDC_SHARED_UI_TCBOX_GREEN_IMG,
				IDC_SHARED_UI_TCBOX_GREEN_BTN
			]
		};

		case "BLUE": {
			[
				IDC_SHARED_UI_TCBOX_BLUE_IMG,
				IDC_SHARED_UI_TCBOX_BLUE_BTN
			]
		};

		case "YELLOW": {
			[
				IDC_SHARED_UI_TCBOX_YELLOW_IMG,
				IDC_SHARED_UI_TCBOX_YELLOW_BTN
			]
		};

		case "MAIN": {
			[
				IDC_SHARED_UI_TCBOX_WHITE_IMG,
				IDC_SHARED_UI_TCBOX_WHITE_BTN
			]
		};

		case "PURPLE": {
			[
				IDC_SHARED_UI_TCBOX_PURPLE_IMG,
				IDC_SHARED_UI_TCBOX_PURPLE_BTN
			]
		};

		default {
			[]
		};
	};

	{
		private _control = _display displayCtrl _x;

		if (!isNull _control) then {
			private _controlY = if (_isRadial) then {
				(ctrlPosition _control) select 1
			} else {
				safeZoneY + safeZoneH
			};

			_control ctrlSetPosition [
				_controlX,
				_controlY,
				_dynamicControlWidth,
				_controlHeight
			];

			_control ctrlCommit 0;
		};
	} forEach _controlIds;

	_controlX = _controlX + _dynamicControlWidth + _gapWidth;
} forEach _teamColors;
#include "..\..\script_component.hpp"
#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_resizeTeamColors_Y

// Matches the team-color controls to the current tree position and shows only
// colors that are currently assigned within the player's group.

params ["_animTime"];

private _displayId = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_RADIAL_MENU
};

private _display = findDisplay _displayId;

if (isNull _display) exitWith {};

private _isRadial = _displayId == IDD_RADIAL_MENU;

// Hardcoded height matching the team-color controls defined in the dialogs.
private _controlHeight = 0.04 * safeZoneH;

private _controlY = if (_isRadial) then {
	private _backgroundControl = _display displayCtrl IDC_UI_SHARED_TEAMCOLOR_BG;
	(ctrlPosition _backgroundControl) select 1
} else {
	A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y
	- _controlHeight
	- (A3C_MAP_GAMEUI_PADDING_Y / 2)
};

private _referenceUnits = (units player) - [player];
private _assignedTeamColors = [];

{
	private _assignedTeam = if (player == cameraOn) then {
		assignedTeam _x
	} else {
		_x getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
	};

	_assignedTeamColors pushBackUnique _assignedTeam;
} forEach _referenceUnits;

private _teamColorControls = [
	_display,
	"shared_teamColorMacros"
] call FUNC(ctrlGroup);

if (_teamColorControls isEqualTo []) exitWith {};

private _teamColors = [
	"RED",
	"GREEN",
	"BLUE",
	"YELLOW",
	"MAIN",
	"ALL"
];

private _controlPairCount = (
	floor ((count _teamColorControls) / 2)
) min (count _teamColors);

private _showAllControl = count _assignedTeamColors > 1;

for "_pairIndex" from 0 to (_controlPairCount - 1) do {
	private _controlIndex = _pairIndex * 2;

	private _barControl = _teamColorControls select _controlIndex;
	private _buttonControl = _teamColorControls select (_controlIndex + 1);
	private _teamColor = _teamColors select _pairIndex;

	private _controlPosition = ctrlPosition _barControl;

	private _showControls =
		_teamColor in _assignedTeamColors
		|| {
			_teamColor == "ALL"
			&& {_showAllControl}
		};

	if (_showControls) then {
		_controlPosition set [1, _controlY];
		_controlPosition set [3, _controlHeight];

		_barControl ctrlSetText "#(argb,8,8,3)color(1,1,1,0.8)";

		private _textColor = switch (_teamColor) do {
			case "RED": {
				[A3C_UI_COLOR_RED, 1] call A3C_UI_fnc_setOpacity
			};

			case "GREEN": {
				[0, 1, 0, 1]
			};

			case "BLUE": {
				[A3C_UI_COLOR_BLUE, 1] call A3C_UI_fnc_setOpacity
			};

			case "YELLOW": {
				[A3C_UI_COLOR_YELLOW, 1] call A3C_UI_fnc_setOpacity
			};

			case "MAIN": {
				[1, 1, 1, 1]
			};

			case "ALL": {
				[0.5, 0.2, 0.6, 1]
			};
		};

		_barControl ctrlSetTextColor _textColor;
	};

	{
		_x ctrlSetPosition _controlPosition;
		_x ctrlCommit _animTime;
		_x ctrlShow _showControls;
	} forEach [
		_barControl,
		_buttonControl
	];
};
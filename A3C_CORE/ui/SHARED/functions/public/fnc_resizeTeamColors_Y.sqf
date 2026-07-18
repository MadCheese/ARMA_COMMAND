#include "..\..\script_component.hpp"
#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_resizeTeamColors_Y

/*
	Matches the shared team-color controls to the current tree position and
	shows only colors currently assigned within the player's group.

	The control array returned by ctrlGroup uses a fixed image/button pair
	order. Null controls must remain in that array so later pairs do not
	shift into incorrect indices.
*/
params [
	["_animTime", 0, [0]]
];

_animTime = _animTime max 0;

private _mapDisplay = findDisplay IDD_MAP_OVERLAY;
private _radialDisplay = findDisplay IDD_RADIAL_MENU;

/*
	Preserve map-overlay priority when both displays happen to exist.
*/
private _display = if (!isNull _mapDisplay) then {
	_mapDisplay
} else {
	_radialDisplay
};

if (isNull _display) exitWith {};

private _isRadial = _display isEqualTo _radialDisplay;
private _controlHeight = A3C_SHARED_UI_TEAMCOLOR_H;

private _controlY = if (_isRadial) then {
	private _backgroundControl =
		_display displayCtrl IDC_UI_SHARED_TEAMCOLOR_BG;

	if (isNull _backgroundControl) exitWith {
		-1
	};

	(ctrlPosition _backgroundControl) select 1
} else {
	A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y
	- _controlHeight
	- (A3C_MAP_GAMEUI_PADDING_Y / 2)
};

if (_controlY < 0) exitWith {};

private _referenceUnits = (units group player) - [player];
private _assignedTeamColors = [];

{
	private _assignedTeam = if (player == cameraOn) then {
		assignedTeam _x
	} else {
		_x getVariable [
			"A3C_ASSIGNEDTEAM",
			"MAIN"
		]
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
	floor (
		(count _teamColorControls) / 2
	)
) min count _teamColors;

private _showAllControl =
	count _assignedTeamColors > 1;

for "_pairIndex" from 0 to (_controlPairCount - 1) do {
	private _controlIndex = _pairIndex * 2;

	private _barControl =
		_teamColorControls select _controlIndex;

	private _buttonControl =
		_teamColorControls select (_controlIndex + 1);

	private _teamColor =
		_teamColors select _pairIndex;

	if (
		isNull _barControl
		|| {isNull _buttonControl}
	) then {
		diag_log format [
			"A3C_ui_shared_fnc_resizeTeamColors_Y: Missing controls for team-color pair %1",
			_teamColor
		];
	} else {
		private _controlPosition =
			ctrlPosition _barControl;

		private _showControls =
			_teamColor in _assignedTeamColors
			|| {
				_teamColor == "ALL"
				&& {_showAllControl}
			};

		if (_showControls) then {
			_controlPosition set [
				1,
				_controlY
			];

			_controlPosition set [
				3,
				_controlHeight
			];

			_barControl ctrlSetText (
				"#(argb,8,8,3)color(1,1,1,0.8)"
			);

			private _textColor = switch (_teamColor) do {
				case "RED": {
					[
						A3C_UI_COLOR_RED,
						1
					] call A3C_ui_shared_fnc_getColorArrayWithOpacity
				};

				case "GREEN": {
					[0, 1, 0, 1]
				};

				case "BLUE": {
					[
						A3C_UI_COLOR_BLUE,
						1
					] call A3C_ui_shared_fnc_getColorArrayWithOpacity
				};

				case "YELLOW": {
					[
						A3C_UI_COLOR_YELLOW,
						1
					] call A3C_ui_shared_fnc_getColorArrayWithOpacity
				};

				case "MAIN": {
					[1, 1, 1, 1]
				};

				case "ALL": {
					[0.5, 0.2, 0.6, 1]
				};

				default {
					[1, 1, 1, 1]
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
};
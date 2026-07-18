#include "..\..\script_component.hpp"
#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_resizeTeamColors_Y

/*
	Updates the shared team-color controls.

	Map overlay:
		Performs the complete layout operation:
		- visibility;
		- X position;
		- Y position;
		- width;
		- height.

	Radial menu:
		Preserves the existing Y-position and visibility behavior because
		the radial layout uses separate control layers.
*/
params [
	["_animTime", 0, [0]]
];

_animTime = _animTime max 0;

private _mapDisplay =
	findDisplay IDD_MAP_OVERLAY;

private _radialDisplay =
	findDisplay IDD_RADIAL_MENU;

/*
	Preserve map-overlay priority when both displays happen to exist.
*/
private _isMap =
	!isNull _mapDisplay;

private _isRadial =
	!_isMap
	&& {!isNull _radialDisplay};

if (!_isMap && {!_isRadial}) exitWith {};

private _display = if (_isMap) then {
	_mapDisplay
} else {
	_radialDisplay
};

private _controlHeight =
	A3C_SHARED_UI_TEAMCOLOR_H;

private _referenceUnits =
	(units group player) - [player];

private _assignedTeamColors = [];

{
	private _assignedTeam = if (
		player == cameraOn
	) then {
		assignedTeam _x
	} else {
		_x getVariable [
			"A3C_ASSIGNEDTEAM",
			"MAIN"
		]
	};

	_assignedTeamColors pushBackUnique _assignedTeam;
} forEach _referenceUnits;

private _showAllControl =
	count _assignedTeamColors > 1;

/*
	Map overlay uses one authoritative layout pass.

	Explicit image/button pairs are used instead of ctrlGroup so that a
	missing control cannot shift every subsequent team-color pair.
*/
if (_isMap) exitWith {
	private _treeControl =
		_display displayCtrl IDC_SHARED_UI_TREE_SELECTOR;

	if (isNull _treeControl) exitWith {};

	private _treePosition =
		ctrlPosition _treeControl;

	private _controlX =
		_treePosition select 0;

	private _totalWidth =
		_treePosition select 2;

	private _controlY =
		A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y
		- _controlHeight
		- (A3C_MAP_GAMEUI_PADDING_Y / 2);

	private _gapWidth =
		A3C_MAP_GAMEUI_PADDING_Y / 2;

	private _controlPairs = [
		[
			"RED",
			IDC_SHARED_UI_TCBOX_RED_IMG,
			IDC_SHARED_UI_TCBOX_RED_BTN,
			[
				A3C_UI_COLOR_RED,
				1
			] call A3C_ui_shared_fnc_getColorArrayWithOpacity
		],
		[
			"GREEN",
			IDC_SHARED_UI_TCBOX_GREEN_IMG,
			IDC_SHARED_UI_TCBOX_GREEN_BTN,
			[0, 1, 0, 1]
		],
		[
			"BLUE",
			IDC_SHARED_UI_TCBOX_BLUE_IMG,
			IDC_SHARED_UI_TCBOX_BLUE_BTN,
			[
				A3C_UI_COLOR_BLUE,
				1
			] call A3C_ui_shared_fnc_getColorArrayWithOpacity
		],
		[
			"YELLOW",
			IDC_SHARED_UI_TCBOX_YELLOW_IMG,
			IDC_SHARED_UI_TCBOX_YELLOW_BTN,
			[
				A3C_UI_COLOR_YELLOW,
				1
			] call A3C_ui_shared_fnc_getColorArrayWithOpacity
		],
		[
			"MAIN",
			IDC_SHARED_UI_TCBOX_WHITE_IMG,
			IDC_SHARED_UI_TCBOX_WHITE_BTN,
			[1, 1, 1, 1]
		],
		[
			"ALL",
			IDC_SHARED_UI_TCBOX_PURPLE_IMG,
			IDC_SHARED_UI_TCBOX_PURPLE_BTN,
			[0.5, 0.2, 0.6, 1]
		]
	];

	private _activePairCount = {
		private _teamColor =
			_x select 0;

		_teamColor in _assignedTeamColors
		|| {
			_teamColor == "ALL"
			&& {_showAllControl}
		}
	} count _controlPairs;

	private _gapCount =
		(_activePairCount - 1) max 0;

	private _dynamicControlWidth = if (
		_activePairCount > 0
	) then {
		(
			_totalWidth
			- (_gapCount * _gapWidth)
		) / _activePairCount
	} else {
		0
	};

	private _hiddenPosition = [
		_treePosition select 0,
		safeZoneY + safeZoneH,
		0,
		_controlHeight
	];

	{
		_x params [
			"_teamColor",
			"_barControlId",
			"_buttonControlId",
			"_textColor"
		];

		private _barControl =
			_display displayCtrl _barControlId;

		private _buttonControl =
			_display displayCtrl _buttonControlId;

		if (
			isNull _barControl
			|| {isNull _buttonControl}
		) then {
			diag_log format [
				"A3C_ui_shared_fnc_resizeTeamColors_Y: Missing map controls for team-color pair %1",
				_teamColor
			];
		} else {
			private _showControls =
				_teamColor in _assignedTeamColors
				|| {
					_teamColor == "ALL"
					&& {_showAllControl}
				};

			if (_showControls) then {
				private _controlPosition = [
					_controlX,
					_controlY,
					_dynamicControlWidth,
					_controlHeight
				];

				_barControl ctrlSetText (
					"#(argb,8,8,3)color(1,1,1,0.8)"
				);

				_barControl ctrlSetTextColor _textColor;

				{
					_x ctrlSetPosition _controlPosition;
					_x ctrlCommit _animTime;
					_x ctrlShow true;
				} forEach [
					_barControl,
					_buttonControl
				];

				_controlX =
					_controlX
					+ _dynamicControlWidth
					+ _gapWidth;
			} else {
				/*
					Hide and normalize unused controls so they cannot remain
					visible at a stale position during later tree rebuilds.
				*/
				{
					_x ctrlShow false;
					_x ctrlSetPosition _hiddenPosition;
					_x ctrlCommit 0;
				} forEach [
					_barControl,
					_buttonControl
				];
			};
		};
	} forEach _controlPairs;
};

/*
	Radial behavior remains unchanged.
*/
private _backgroundControl =
	_display displayCtrl IDC_UI_SHARED_TEAMCOLOR_BG;

if (isNull _backgroundControl) exitWith {};

private _controlY =
	(ctrlPosition _backgroundControl) select 1;

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

for "_pairIndex" from 0 to (_controlPairCount - 1) do {
	private _controlIndex =
		_pairIndex * 2;

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
			"A3C_ui_shared_fnc_resizeTeamColors_Y: Missing radial controls for team-color pair %1",
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
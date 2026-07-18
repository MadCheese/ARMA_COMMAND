#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_Tree_adjustTopRow

/*
	Repositions the team-color row above the shared tree control.

	For the map overlay, this also repositions the refresh, disband, and
	force-tracker controls above the team-color row.
*/
params [
	["_tree", controlNull, [controlNull]],
	["_animTime", 0, [0]]
];

private _mapDisplay = findDisplay IDD_MAP_OVERLAY;
private _radialDisplay = findDisplay IDD_RADIAL_MENU;

/*
	Preserve legacy display priority: the map overlay takes precedence when
	both displays exist.
*/
private _isMap = !isNull _mapDisplay;
private _isRadial = !_isMap && {!isNull _radialDisplay};

if (!_isMap && {!_isRadial}) exitWith {};

private _display = if (_isMap) then {
	_mapDisplay
} else {
	_radialDisplay
};

/*
	The legacy function ignored its supplied tree control and looked it up
	again. Retain a fallback lookup, but use the supplied control normally.
*/
if (isNull _tree) then {
	_tree = _display displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
};

if (isNull _tree) exitWith {};

_animTime = _animTime max 0;

private _treePosition = ctrlPosition _tree;
private _treeWidth = _treePosition select 2;

private _controlX = A3C_MAP_OVERLAY_GAMEUI_TREEX;

private _teamColorHeight = A3C_SHARED_UI_TEAMCOLOR_H;

/*
	Resize and reposition the individual team-color controls first.
*/
[
	_animTime
] call A3C_ui_shared_fnc_resizeTeamColors_Y;

private _controlY =
	A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y
	- _teamColorHeight
	- (A3C_MAP_GAMEUI_PADDING_Y / 2);

/*
	Resize the background and frame surrounding the team-color controls.
*/
{
	private _control = _display displayCtrl _x;

	if (!isNull _control) then {
		_control ctrlSetPosition [
			_controlX,
			A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y
				- _teamColorHeight
				- A3C_MAP_GAMEUI_PADDING_Y,
			_treeWidth,
			_teamColorHeight
				+ A3C_MAP_GAMEUI_PADDING_Y
		];

		_control ctrlCommit _animTime;
	};
} forEach [
	IDC_UI_SHARED_TEAMCOLOR_BG,
	IDC_SHARED_UI_TEAMCOLOR_FRAME
];

/*
	The radial menu does not use the map-overlay settings buttons.
*/
if (_isRadial) exitWith {};

/*
	Map-overlay-specific controls.
*/
private _additionalButtonGroups = [
	[
		IDC_MAP_TOP_REFRESH_IMG,
		IDC_MAP_TOP_REFRESH_BTN
	],
	[
		IDC_MAP_TOP_DISBAND_IMG,
		IDC_MAP_TOP_DISBAND_BTN
	],
	[
		IDC_MAP_TOP_TOGGLETRACKER_IMG,
		IDC_MAP_TOP_TOGGLETRACKER_BTN
	]
];

private _buttonImages = [
	[
		IDC_MAP_TOP_REFRESH_IMG,
		"A3C_CORE\ui\pictures\icon_menu_refresh.paa"
	],
	[
		IDC_MAP_TOP_DISBAND_IMG,
		"A3C_CORE\ui\pictures\icon_menu_hc_disband.paa"
	],
	[
		IDC_MAP_TOP_TOGGLETRACKER_IMG,
		"A3C_CORE\ui\pictures\icon_menu_toggleForceTracker.paa"
	]
];

{
	_x params [
		"_controlId",
		"_imagePath"
	];

	private _imageControl = _display displayCtrl _controlId;

	if (!isNull _imageControl) then {
		_imageControl ctrlSetText _imagePath;
	};
} forEach _buttonImages;

private _buttonHeight = A3C_MAP_GAMEUI_Upper_buttonH;

/*
	The controls are arranged from right to left above the tree.
*/
_controlX =
	(
		A3C_MAP_OVERLAY_GAMEUI_TREEX
		+ A3C_MAP_OVERLAY_GAMEUI_TREEW
	)
	- (3 * _buttonHeight);

_controlY =
	_controlY
	- _buttonHeight
	- (A3C_MAP_GAMEUI_PADDING_Y / 2);

private _extrasWidth = (_buttonHeight * 4) * 0.75;

/*
	Resize the background and frame surrounding the three map controls.
*/
{
	private _control = _display displayCtrl _x;

	if (!isNull _control) then {
		_control ctrlSetPosition [
			_controlX,
			_controlY,
			_extrasWidth,
			_buttonHeight
		];

		_control ctrlCommit _animTime;
	};
} forEach [
	IDC_MAP_TOP_EXTRAS_BACKGROUND,
	IDC_MAP_TOP_EXTRAS_FRAME
];

private _buttonWidth = _buttonHeight * 0.75;

{
	private _buttonX =
		_controlX
		+ (_buttonHeight * _forEachIndex);

	{
		private _control = _display displayCtrl _x;

		if (!isNull _control) then {
			_control ctrlSetPosition [
				_buttonX,
				_controlY,
				_buttonWidth,
				_buttonHeight
			];

			_control ctrlCommit _animTime;
		};
	} forEach _x;
} forEach _additionalButtonGroups;
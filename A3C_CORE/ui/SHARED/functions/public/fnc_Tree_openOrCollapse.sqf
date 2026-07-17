#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_Tree_openOrCollapse

/*
	Expands or collapses a shared UI tree node and resizes the tree control
	to fit the currently visible entries.

	_ctrlData:
		0: Tree control.
		1: Tree path to expand or collapse.

	_mode:
		"OPEN" or "COLLAPSE".

	_isInit:
		Retained for caller compatibility. The legacy function did not use
		this value internally.

	_animTime:
		Control-position animation duration.
*/
params [
	["_ctrlData", [], [[]]],
	["_mode", "COLLAPSE", [""]],
	["_isInit", false, [false]],
	["_animTime", 0, [0]]
];

_ctrlData params [
	["_tree", controlNull, [controlNull]],
	["_selectedParent", [], [[]]]
];

private _mapDisplay = findDisplay IDD_MAP_OVERLAY;
private _radialDisplay = findDisplay IDD_RADIAL_MENU;

/*
	Preserve the legacy display priority: map overlay takes precedence when
	both displays exist.
*/
private _isMap = !isNull _mapDisplay;
private _isRadial = !_isMap && {!isNull _radialDisplay};

if (!_isMap && {!_isRadial}) exitWith {};
if (isNull _tree) exitWith {};
if (_selectedParent isEqualTo []) exitWith {};

private _display = if (_isMap) then {
	_mapDisplay
} else {
	_radialDisplay
};

private _isMainParent = count _selectedParent == 1;

_mode = toUpper _mode;
_animTime = _animTime max 0;

/*
	Use the appropriate persistent open-tree array for the active UI
	context.
*/
private _openTreesVariable = if (_isRadial) then {
	private _commandLevel = missionNamespace getVariable [
		"A3C_CURRENT_COMMAND_LEVEL",
		"SQUAD"
	];

	if (_commandLevel == "SQUAD") then {
		"A3C_RADIAL_TREES_OPEN_SQ"
	} else {
		"A3C_RADIAL_TREES_OPEN_HC"
	}
} else {
	"A3C_UI_MAP_TREES_OPEN"
};

private _openTrees = +(
	missionNamespace getVariable [
		_openTreesVariable,
		[]
	]
);

playSound "ReadOutHideClick1";

if (_mode == "OPEN") then {
	_tree tvExpand _selectedParent;
	_openTrees pushBackUnique _selectedParent;
} else {
	/*
		Any value other than OPEN retains the legacy collapse behavior.
	*/
	_mode = "COLLAPSE";

	if (_isMainParent) then {
		/*
			Collapsing a root removes that root and all stored descendant
			paths from the persistent open-tree state.
		*/
		private _mainParentIndex = _selectedParent select 0;

		for "_index" from ((count _openTrees) - 1) to 0 step -1 do {
			private _treePath = _openTrees select _index;

			if (
				_treePath isEqualType []
				&& {_treePath isNotEqualTo []}
				&& {
					(_treePath select 0) isEqualTo _mainParentIndex
				}
			) then {
				_openTrees deleteAt _index;
			};
		};
	} else {
		private _openTreeIndex = _openTrees findIf {
			_x isEqualTo _selectedParent
		};

		if (_openTreeIndex >= 0) then {
			_openTrees deleteAt _openTreeIndex;
		};
	};

	_tree tvCollapse _selectedParent;
};

/*
	Write the updated state explicitly instead of depending on shared-array
	reference behavior.
*/
missionNamespace setVariable [
	_openTreesVariable,
	_openTrees
];

private _minimumHeight = if (_isMap) then {
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_H
} else {
	(safeZoneY + safeZoneH) * 0.2
};

private _maximumHeight = if (_isMap) then {
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y
	- A3C_MAP_GAMEUI_MENU_Y
	+ A3C_MAP_GAMEUI_Upper_buttonH
	+ A3C_MAP_GAMEUI_PADDING_Y
} else {
	(safeZoneY + safeZoneH)
	- (
		(
			A3C_GAMEUI_COMMANDBAR_H
			+ A3C_MAP_GAMEUI_PADDING_Y
		) * 2.5
	)
};

private _treePosition = ctrlPosition _tree;

_treePosition params [
	"_currentX",
	"_currentY",
	"_currentWidth",
	"_currentHeight"
];

private _collapsedPosition = if (_isMap) then {
	[
		A3C_MAP_OVERLAY_GAMEUI_TREEX,
		(safeZoneY + safeZoneH)
			- A3C_MAP_GAMEUI_PADDING_Y
			- _minimumHeight,
		A3C_MAP_OVERLAY_GAMEUI_TREEW,
		_minimumHeight
	]
} else {
	[
		_currentX,
		_currentY,
		_currentWidth,
		_minimumHeight
	]
};

/*
	Count all currently visible rows.

	Top-level entries are always visible. Open parent paths are counted once,
	and their immediate children are counted unless the child is itself an
	open parent that will be counted during its own iteration.
*/
private _shownEntryCount = _tree tvCount [];

{
	private _treePath = _x;

	if (
		_treePath isEqualType []
		&& {_treePath isNotEqualTo []}
	) then {
		if (count _treePath > 1) then {
			_shownEntryCount = _shownEntryCount + 1;
		};

		private _childCount = _tree tvCount _treePath;

		for "_childIndex" from 0 to (_childCount - 1) do {
			private _childPath = _treePath + [_childIndex];

			if !(_childPath in _openTrees) then {
				_shownEntryCount = _shownEntryCount + 1;
			};
		};
	};
} forEach _openTrees;

private _effectiveHeight =
	A3C_MAP_OVERLAY_GAMEUI_TREEROWHEIGHT_MAIN
	* _shownEntryCount;

_effectiveHeight =
	(_effectiveHeight min _maximumHeight)
	max _minimumHeight;

if (_isMap) then {
	A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y =
		(safeZoneY + safeZoneH)
		- A3C_MAP_GAMEUI_PADDING_Y
		- _effectiveHeight;

	_tree ctrlSetPosition [
		A3C_MAP_OVERLAY_GAMEUI_TREEX,
		A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y,
		_collapsedPosition select 2,
		_effectiveHeight
	];

	_tree ctrlCommit _animTime;

	[
		_tree,
		_animTime
	] call A3C_ui_shared_fnc_Tree_adjustTopRow;
} else {
	/*
		The radial tree expands downward. Its surrounding control group and
		background are resized and vertically recentered around the new
		total height.
	*/
	private _newTreePosition = +_collapsedPosition;

	_newTreePosition set [
		3,
		_effectiveHeight
	];

	_tree ctrlSetPosition _newTreePosition;
	_tree ctrlCommit _animTime;

	private _controlGroup = _display displayCtrl
		IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP;

	if (!isNull _controlGroup) then {
		private _controlGroupPosition = ctrlPosition _controlGroup;
		private _newControlGroupHeight =
			_currentY + _effectiveHeight;

		_controlGroupPosition set [
			1,
			0.5 - (_newControlGroupHeight / 2)
		];

		_controlGroupPosition set [
			3,
			_newControlGroupHeight
		];

		{
			private _control = _display displayCtrl _x;

			if (!isNull _control) then {
				_control ctrlSetPosition _controlGroupPosition;
				_control ctrlCommit _animTime;
			};
		} forEach [
			IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP,
			IDC_RADIAL_EXTENSIONLEFT_BG
		];
	};
};
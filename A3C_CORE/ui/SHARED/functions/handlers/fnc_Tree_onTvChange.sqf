#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_Tree_onTvChange

/*
	Handles selection changes in the shared squad/high-command tree.

	Squad tree values are one-based because A3C_GROUPUNITS includes the
	player at index zero while the tree excludes the player.

	High-command tree values are zero-based indices into the stable
	A3C_UI_SHARED_TREE_HC_AT_TICK snapshot.
*/
params [
	["_control", controlNull, [controlNull]],
	["_targetPath", [], [[]]]
];

if (isNull _control) exitWith {};
if (_targetPath isEqualTo []) exitWith {};

/*
	Root entries only expand or collapse the tree. They do not represent
	selectable units or groups.
*/
if (count _targetPath == 1) exitWith {};

private _mapDisplay = findDisplay IDD_MAP_OVERLAY;
private _radialDisplay = findDisplay IDD_RADIAL_MENU;

/*
	Preserve legacy display priority: map overlay takes precedence when
	both displays are present.
*/
private _isMap = !isNull _mapDisplay;
private _isRadial = !_isMap && {!isNull _radialDisplay};

if (!_isMap && {!_isRadial}) exitWith {};

private _downKeys = missionNamespace getVariable [
	"A3C_UI_DOWNKEYS",
	[]
];

private _shiftPressed = 42 in _downKeys;
private _ctrlPressed = 29 in _downKeys;

private _targetRootIndex = _targetPath param [
	0,
	-1
];

private _isSquadLevel = _targetRootIndex == 0;

if (_isRadial) then {
	_isSquadLevel =
		_isSquadLevel
		&& {
			(
				missionNamespace getVariable [
					"A3C_CURRENT_COMMAND_LEVEL",
					"SQUAD"
				]
			) == "SQUAD"
		};
};

/*
	HC category rows have paths such as [root, category] but no associated
	group value. Squad entries may also have two-part paths, so this guard
	applies only to the HC tree.
*/
if (!_isSquadLevel && {count _targetPath == 2}) exitWith {};

playSound "ReadOutHideClick1";

private _squadUnits = (
	profileNamespace getVariable [
		"A3C_GROUPUNITS",
		[]
	]
) - [player];

private _highCommandGroups = +(
	missionNamespace getVariable [
		"A3C_UI_SHARED_TREE_HC_AT_TICK",
		[]
	]
);

private _referenceArray = if (_isSquadLevel) then {
	_squadUnits
} else {
	_highCommandGroups
};

if (_referenceArray isEqualTo []) exitWith {};

private _targetValue = _control tvValue _targetPath;

/*
	Convert the stored tree value into an index in the applicable reference
	array.
*/
private _targetReferenceIndex = if (_isSquadLevel) then {
	_targetValue - 1
} else {
	_targetValue
};

if (
	_targetReferenceIndex < 0
	|| {_targetReferenceIndex >= count _referenceArray}
) exitWith {};

private _targetEntity =
	_referenceArray select _targetReferenceIndex;

private _sourcePath = tvCurSel _control;

/*
	Some tree-selection event paths can report no valid previous selection.
	In that case, treat the target as the selection origin.
*/
if (
	_sourcePath isEqualTo []
	|| {_sourcePath isEqualTo [-1]}
	|| {(_sourcePath param [0, -1]) < 0}
) then {
	_sourcePath = +_targetPath;
};

private _sourceRootIndex = _sourcePath param [
	0,
	-1
];

private _sourceParentPath = _sourcePath select [
	0,
	((count _sourcePath) - 1) max 0
];

private _targetParentPath = _targetPath select [
	0,
	((count _targetPath) - 1) max 0
];

/*
	Shift-range selection can only operate between sibling entries because
	the generated tree paths must share the same parent.

	CTRL selection remains capable of selecting HC groups from different
	vehicle categories.
*/
private _abortModifierSelection =
	_sourceRootIndex != _targetRootIndex
	|| {
		_shiftPressed
		&& {
			_sourceParentPath isNotEqualTo _targetParentPath
		}
	}
	|| {
		_isSquadLevel
		&& {
			(_shiftPressed || {_ctrlPressed})
			&& {
				count _sourcePath != count _targetPath
			}
		}
	};

private _fnc_clearSelection = {
	A3C_SELECTED_UNITS = [];
	A3C_SELECTED_HC_GROUPS_SETTINGS = [];
	A3C_RD_UNITS = [];

	if (_isRadial && {_isSquadLevel}) then {
		{
			player groupSelectUnit [
				_x,
				false
			];
		} forEach units player;
	};
};

if (_abortModifierSelection) then {
	_control tvSetCurSel [-1];
	_control tvSetCurSel _targetPath;

	_sourcePath = +_targetPath;

	call _fnc_clearSelection;
};

/*
	Switch the unit-function selection bar between infantry and aircraft
	pages when a squad tree entry is selected.
*/
if (_isSquadLevel) then {
	private _targetPageMode = if (
		vehicle _targetEntity isKindOf "AIR"
	) then {
		"AIR"
	} else {
		"INF"
	};

	private _sourceWasSquad =
		(_sourcePath param [0, -1]) == 0;

	private _currentMapMode = missionNamespace getVariable [
		"A3C_MAP_CommandMode",
		""
	];

	private _switchPage =
		!_sourceWasSquad
		|| {
			_targetPageMode != _currentMapMode
		};

	if (_switchPage) then {
		A3C_MAP_CommandMode = _targetPageMode;

		call _fnc_clearSelection;

		_control tvSetCurSel [-1];
		_control tvSetCurSel _targetPath;

		[
			_targetPageMode
		] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
	};
} else {
	/*
		Use the stable HC snapshot created during Tree_labelItems so group
		indices remain valid throughout this tree instance.
	*/
	_referenceArray = _highCommandGroups;
	A3C_MAP_CommandMode = "HC";
};

/*
	Build the set of stored tree values affected by this selection event.
*/
private _buttonValues = [];

if (_shiftPressed) then {
	private _sourceLeafIndex = _sourcePath select (
		(count _sourcePath) - 1
	);

	private _targetLeafIndex = _targetPath select (
		(count _targetPath) - 1
	);

	private _step = if (
		_sourceLeafIndex <= _targetLeafIndex
	) then {
		1
	} else {
		-1
	};

	private _parentPath = _sourcePath select [
		0,
		(count _sourcePath) - 1
	];

	for "_index" from _sourceLeafIndex to _targetLeafIndex step _step do {
		private _entryPath = _parentPath + [_index];
		private _entryValue = _control tvValue _entryPath;

		_buttonValues pushBackUnique _entryValue;
	};
} else {
	if (_ctrlPressed) then {
		_buttonValues pushBackUnique _targetValue;
	} else {
		_buttonValues = [_targetValue];

		call _fnc_clearSelection;
	};
};

/*
	Squad values are offset by one because the source array used to create
	the stored values includes the player, while _referenceArray does not.

	HC values directly match their snapshot indices.
*/
private _valueOffset = if (_isSquadLevel) then {
	1
} else {
	0
};

{
	private _entity = _x;
	private _entityTreeValue = _forEachIndex + _valueOffset;

	if (_entityTreeValue in _buttonValues) then {
		private _alreadySelected = if (_isSquadLevel) then {
			if (_isRadial) then {
				_entity in A3C_RD_UNITS
			} else {
				_entity in A3C_SELECTED_UNITS
			}
		} else {
			_entity in A3C_SELECTED_HC_GROUPS_SETTINGS
		};

		if (_ctrlPressed && {_alreadySelected}) then {
			if (_isSquadLevel) then {
				if (_isRadial) then {
					A3C_RD_UNITS =
						A3C_RD_UNITS - [_entity];

					player groupSelectUnit [
						_entity,
						false
					];
				} else {
					A3C_SELECTED_UNITS =
						A3C_SELECTED_UNITS - [_entity];
				};
			} else {
				A3C_SELECTED_HC_GROUPS_SETTINGS =
					A3C_SELECTED_HC_GROUPS_SETTINGS - [_entity];

				if (_isRadial) then {
					A3C_RD_UNITS =
						A3C_RD_UNITS - [_entity];
				} else {
					A3C_SELECTED_UNITS =
						A3C_SELECTED_UNITS - [_entity];
				};
			};

			_control tvSetCurSel [-1];
		} else {
			if (_isSquadLevel) then {
				if (_isRadial) then {
					A3C_RD_UNITS pushBackUnique _entity;

					player groupSelectUnit [
						_entity,
						true
					];
				} else {
					A3C_SELECTED_UNITS pushBackUnique _entity;
				};
			} else {
				A3C_SELECTED_HC_GROUPS_SETTINGS
					pushBackUnique _entity;

				if (_isRadial) then {
					A3C_RD_UNITS pushBackUnique _entity;
				} else {
					A3C_SELECTED_UNITS pushBackUnique _entity;
				};
			};
		};
	};
} forEach _referenceArray;

[] call A3C_ui_shared_fnc_refreshUnitSelectionUi;
// A3C_ui_shared_fnc_Tree_ctrlDelete

/*
	Deletes a tree entry and rewrites A3C_TREESEL_INDEX for every selectable
	entry whose tree path shifted as a result.

	For squad trees, vehicle drivers can have two paths:
		- the vehicle parent entry;
		- the driver's crew entry.

	For high-command trees, transported groups can be nested beneath their
	transporting group.
*/
params [
	["_tree", controlNull, [controlNull]],
	["_buttonPath", [], [[]]],
	["_mode", "", [""]]
];

if (isNull _tree) exitWith {};
if (_buttonPath isEqualTo []) exitWith {};

_mode = toUpper _mode;

private _referenceArray = switch (_mode) do {
	case "SQUAD": {
		+(
			profileNamespace getVariable [
				"A3C_GROUPUNITS",
				[]
			]
		)
	};

	case "HIGHCOMMAND": {
		+(
			missionNamespace getVariable [
				"A3C_UI_SHARED_TREE_HC_AT_TICK",
				[]
			]
		)
	};

	default {
		[]
	};
};

if (_referenceArray isEqualTo []) exitWith {
	_tree tvDelete _buttonPath;
};

private _buttonChildIndex = _buttonPath select (
	(count _buttonPath) - 1
);

private _parentPath = _buttonPath select [
	0,
	(count _buttonPath) - 1
];

/*
	Delete first. Every following sibling now occupies an index one lower
	than before.
*/
_tree tvDelete _buttonPath;

private _remainingSiblingCount = _tree tvCount _parentPath;

if (_buttonChildIndex >= _remainingSiblingCount) exitWith {};

/*
	Collect every entity and all of its rewritten paths before applying the
	variable updates.

	This automatically preserves both paths for squad vehicle drivers and
	also updates HC group parents that contain cargo-group children.
*/
private _rewrittenEntries = [];

private _fnc_registerPath = {
	params [
		["_treePath", [], [[]]]
	];

	private _treeValue = _tree tvValue _treePath;

	if (
		_treeValue >= 0
		&& {_treeValue < count _referenceArray}
	) then {
		private _entity = _referenceArray select _treeValue;

		private _entryIndex = _rewrittenEntries findIf {
			(_x select 0) isEqualTo _entity
		};

		if (_entryIndex < 0) then {
			_rewrittenEntries pushBack [
				_entity,
				[
					_treePath
				]
			];
		} else {
			(
				(_rewrittenEntries select _entryIndex)
				select 1
			) pushBackUnique _treePath;
		};
	};
};

/*
	Only siblings at and after the deleted index have shifted. Walk each of
	those sibling subtrees and collect all selectable descendant paths.
*/
for "_siblingIndex" from _buttonChildIndex to (_remainingSiblingCount - 1) do {
	private _siblingPath = _parentPath + [_siblingIndex];
	private _pendingPaths = [_siblingPath];

	while {_pendingPaths isNotEqualTo []} do {
		private _treePath = _pendingPaths deleteAt (
			(count _pendingPaths) - 1
		);

		[
			_treePath
		] call _fnc_registerPath;

		private _childCount = _tree tvCount _treePath;

		if (_childCount > 0) then {
			for "_childIndex" from 0 to (_childCount - 1) do {
				_pendingPaths pushBack (
					_treePath + [_childIndex]
				);
			};
		};
	};
};

/*
	Replace each affected entity's complete reverse-selection path list.
*/
{
	_x params [
		"_entity",
		"_treePaths"
	];

	private _supportedEntityType =
		(_entity isEqualType objNull)
		|| {
			_entity isEqualType grpNull
		};

	if (
		_supportedEntityType
		&& {!isNull _entity}
	) then {
		_entity setVariable [
			"A3C_TREESEL_INDEX",
			_treePaths
		];
	};
} forEach _rewrittenEntries;
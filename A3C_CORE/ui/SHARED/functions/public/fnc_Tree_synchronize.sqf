#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_Tree_synchronize

/*
	Synchronizes the shared squad/high-command tree with the current unit and
	group state.

	The function records both the source-data signature and the generated tree
	layout. While both remain unchanged, synchronization is a no-op. When a
	structural change is detected, the canonical Tree_labelItems builder
	rebuilds the complete tree once.
*/

params [
	["_initializeState", false, [false]]
];

private _mapDisplay = findDisplay IDD_MAP_OVERLAY;
private _radialDisplay = findDisplay IDD_RADIAL_MENU;

/*
	Preserve legacy display priority: map overlay first, radial menu second.
*/
private _isMap = !isNull _mapDisplay;
private _isRadial = !_isMap && {!isNull _radialDisplay};

if (!_isMap && {!_isRadial}) exitWith {
	false
};

private _display = if (_isMap) then {
	_mapDisplay
} else {
	_radialDisplay
};

private _displayId = if (_isMap) then {
	IDD_MAP_OVERLAY
} else {
	IDD_RADIAL_MENU
};

private _tree = _display displayCtrl IDC_SHARED_UI_TREE_SELECTOR;

if (isNull _tree) exitWith {
	false
};

private _currentHighCommandGroups = +(
	missionNamespace getVariable [
		"A3C_HC_allGroupsClient_Current",
		[]
	]
);

private _highCommandSnapshot = +(
	missionNamespace getVariable [
		"A3C_UI_SHARED_TREE_HC_AT_TICK",
		[]
	]
);

private _profileUnits = +(
	profileNamespace getVariable [
		"A3C_GROUPUNITS",
		[]
	]
);

/*
	The boarding workaround temporarily moves the player into another group.
	Keep the displayed squad root tied to the real player group throughout that
	operation.
*/
private _playerTreeGroup = missionNamespace getVariable [
	"A3C_BOARDING_PLAYER_GROUP",
	grpNull
];

if (isNull _playerTreeGroup) then {
	_playerTreeGroup = group player;
};

private _modes = if (_isRadial) then {
	private _commandLevel = missionNamespace getVariable [
		"A3C_CURRENT_COMMAND_LEVEL",
		"SQUAD"
	];

	if (_commandLevel == "SQUAD") then {
		["SQUAD"]
	} else {
		["HIGHCOMMAND"]
	}
} else {
	[
		"SQUAD",
		"HIGHCOMMAND"
	]
};

/*
	Remember the entity represented by the current tree selection. A complete
	rebuild changes tree paths, so the path itself cannot safely be restored.
	The entity's rebuilt reverse path is used instead.
*/
private _currentSelectionEntity = nil;
private _currentSelectionPathIndex = 0;
private _currentSelectionPath = tvCurSel _tree;

if (
	_currentSelectionPath isNotEqualTo []
	&& {_currentSelectionPath isNotEqualTo [-1]}
) then {
	private _selectionCandidates = (
		(_profileUnits - [player])
		+ _highCommandSnapshot
		+ _currentHighCommandGroups
	);

	{
		private _entity = _x;

		if (!isNull _entity) then {
			private _entityPaths = _entity getVariable [
				"A3C_TREESEL_INDEX",
				[]
			];

			private _matchingPathIndex = _entityPaths findIf {
				_x isEqualTo _currentSelectionPath
			};

			if (_matchingPathIndex >= 0) exitWith {
				_currentSelectionEntity = _entity;
				_currentSelectionPathIndex = _matchingPathIndex;
			};
		};
	} forEach _selectionCandidates;
};

/*
	Keep the visible-mode rule aligned with Tree_labelItems.
*/
if (
	count _currentHighCommandGroups < 2
	&& {"HIGHCOMMAND" in _modes}
) then {
	_modes = _modes - ["HIGHCOMMAND"];
};

private _fnc_getHighCommandCategory = {
	params [
		["_group", grpNull, [grpNull]]
	];

	if (isNull _group) exitWith {
		""
	};

	private _groupUnits = units _group;
	private _leader = leader _group;

	if (isNull _leader) exitWith {
		""
	};

	private _leaderVehicle = vehicle _leader;

	switch true do {
		case (unitIsUAV _leaderVehicle): {
			"AUTONOMOUS"
		};

		case (_leaderVehicle isKindOf "PLANE"): {
			"PLANES"
		};

		case (_leaderVehicle isKindOf "HELICOPTER"): {
			"HELICOPTERS"
		};

		case (_leaderVehicle isKindOf "TANK"): {
			"TANKS"
		};

		case (_leaderVehicle isKindOf "Wheeled_APC_F"): {
			"APCS"
		};

		case (
			_leaderVehicle isKindOf "CAR"
			&& {
				!(_leaderVehicle isKindOf "Wheeled_APC_F")
			}
		): {
			"CARS"
		};

		case (_leaderVehicle isKindOf "SHIP"): {
			"SHIPS"
		};

		case (
			_leaderVehicle isKindOf "STATICWEAPON"
			|| {
				_leaderVehicle isKindOf "MAN"
				&& {
					_groupUnits findIf {
						(vehicle _x) isKindOf "STATICWEAPON"
					} >= 0
				}
			}
		): {
			"STATIC WEAPONS"
		};

		case (_leaderVehicle isKindOf "MAN"): {
			"INFANTRY"
		};

		default {
			"UNKNOWN CLASS"
		};
	}
};

/*
	Return the host group when the supplied group is displayed as transported
	cargo. Static-weapon groups remain standalone.
*/
private _fnc_getCargoHost = {
	params [
		["_group", grpNull, [grpNull]]
	];

	if (isNull _group) exitWith {
		grpNull
	};

	private _groupUnits = units _group;
	private _leader = leader _group;

	if (isNull _leader) exitWith {
		grpNull
	};

	private _leaderVehicle = vehicle _leader;

	private _hasStaticWeapon = _groupUnits findIf {
		(vehicle _x) isKindOf "STATICWEAPON"
	} >= 0;

	if (
		(driver _leaderVehicle) in _groupUnits
		|| {_hasStaticWeapon}
	) exitWith {
		grpNull
	};

	group (driver _leaderVehicle)
};

/*
	Capture the current generated tree structure. This detects external tree
	deletions or stale layouts even when the source arrays did not change.
*/
private _fnc_captureTreeLayout = {
	private _layout = [];
	private _pendingPaths = [[]];

	while {_pendingPaths isNotEqualTo []} do {
		private _parentPath = _pendingPaths deleteAt 0;
		private _childCount = _tree tvCount _parentPath;

		for "_childIndex" from 0 to (_childCount - 1) do {
			private _childPath = _parentPath + [_childIndex];

			_layout pushBack [
				_childPath,
				_tree tvText _childPath,
				_tree tvValue _childPath,
				_tree tvCount _childPath
			];

			_pendingPaths pushBack _childPath;
		};
	};

	_layout
};

private _squadSignature = [];

if ("SQUAD" in _modes) then {
	{
		private _unit = _x;

		if (isNull _unit) then {
			_squadSignature pushBack [
				objNull,
				false,
				objNull,
				[]
			];
		} else {
			_squadSignature pushBack [
				_unit,
				alive _unit,
				objectParent _unit,
				assignedVehicleRole _unit
			];
		};
	} forEach (_profileUnits - [player]);
};

private _highCommandSignature = [];

if ("HIGHCOMMAND" in _modes) then {
	{
		private _group = _x;

		if (isNull _group) then {
			_highCommandSignature pushBack [
				grpNull,
				"",
				objNull,
				[],
				0,
				"",
				grpNull
			];
		} else {
			private _groupUnits = units _group;
			private _leader = leader _group;
			private _leaderVehicle = if (isNull _leader) then {
				objNull
			} else {
				vehicle _leader
			};

			private _aliveUnitCount = {
				alive _x
			} count _groupUnits;

			_highCommandSignature pushBack [
				_group,
				groupID _group,
				_leaderVehicle,
				_groupUnits,
				_aliveUnitCount,
				[
					_group
				] call _fnc_getHighCommandCategory,
				[
					_group
				] call _fnc_getCargoHost
			];
		};
	} forEach _currentHighCommandGroups;
};

private _dataSignature = [
	_modes,
	_squadSignature,
	_highCommandSignature
];

private _layoutSignature = call _fnc_captureTreeLayout;

private _stateVariable = format [
	"A3C_ui_shared_treeSynchronizationState_%1",
	_displayId
];

private _previousState = uiNamespace getVariable [
	_stateVariable,
	[
		controlNull,
		[],
		[]
	]
];

_previousState params [
	["_previousTree", controlNull, [controlNull]],
	["_previousDataSignature", [], [[]]],
	["_previousLayoutSignature", [], [[]]]
];

private _rootLayoutValid =
	(_tree tvCount []) == count _modes;

if (
	_rootLayoutValid
	&& {"SQUAD" in _modes}
) then {
	private _squadRootIndex = _modes find "SQUAD";

	_rootLayoutValid =
		(_tree tvText [_squadRootIndex])
		== toUpper (groupID _playerTreeGroup);
};

if (
	_rootLayoutValid
	&& {"HIGHCOMMAND" in _modes}
) then {
	private _highCommandRootIndex =
		_modes find "HIGHCOMMAND";

	_rootLayoutValid =
		(_tree tvText [_highCommandRootIndex])
		== "HIGH COMMAND";
};

/*
	Tree_labelItems calls this mode immediately after constructing a tree. Store
	the exact source and layout signatures at that moment so the first periodic
	synchronization check does not rebuild an unchanged tree. Because the
	baseline is recorded immediately, changes occurring before the first FSM
	tick are still detected normally.
*/
if (_initializeState) exitWith {
	if (_rootLayoutValid) then {
		uiNamespace setVariable [
			_stateVariable,
			[
				_tree,
				_dataSignature,
				_layoutSignature
			]
		];
	};

	false
};

private _treeIsSynchronized =
	_rootLayoutValid
	&& {_previousTree isEqualTo _tree}
	&& {
		_previousDataSignature
		isEqualTo _dataSignature
	}
	&& {
		_previousLayoutSignature
		isEqualTo _layoutSignature
	};

if (_treeIsSynchronized) exitWith {
	false
};

/*
	Clear all reverse-selection paths before rebuilding. This prevents removed
	units or groups from retaining paths into an earlier tree instance.
*/
{
	if (!isNull _x) then {
		_x setVariable [
			"A3C_TREESEL_INDEX",
			[]
		];
	};
} forEach (_profileUnits - [player]);

{
	if (!isNull _x) then {
		_x setVariable [
			"A3C_TREESEL_INDEX",
			[]
		];
	};
} forEach (
	_highCommandSnapshot
	+ _currentHighCommandGroups
);

[
	_displayId
] call A3C_ui_shared_fnc_Tree_labelItems;

/*
	Tree_labelItems intentionally mirrors the source group array. Preserve the
	legacy synchronizer behavior by removing groups that no longer contain any
	living units after the canonical rebuild.
*/
if ("HIGHCOMMAND" in _modes) then {
	{
		private _group = _x;

		if (
			!isNull _group
			&& {
				(units _group) findIf {
					alive _x
				} < 0
			}
		) then {
			private _groupPaths = _group getVariable [
				"A3C_TREESEL_INDEX",
				[]
			];

			if (_groupPaths isNotEqualTo []) then {
				private _groupPath = _groupPaths select 0;
				private _categoryPath = if (count _groupPath == 3) then {
					_groupPath select [
						0,
						2
					]
				} else {
					[]
				};

				_group setVariable [
					"A3C_TREESEL_INDEX",
					[]
				];

				[
					_tree,
					_groupPath,
					"HIGHCOMMAND"
				] call A3C_ui_shared_fnc_Tree_ctrlDelete;

				if (
					_categoryPath isNotEqualTo []
					&& {
						(_tree tvCount _categoryPath) == 0
					}
				) then {
					[
						_tree,
						_categoryPath,
						"HIGHCOMMAND"
					] call A3C_ui_shared_fnc_Tree_ctrlDelete;
				};
			};
		};
	} forEach _currentHighCommandGroups;
};

/*
	Restore the visible current selection after a genuine structural rebuild.
	Multi-selection remains stored in the existing selection arrays; CT_TREE
	can display only one current path.
*/
if (!isNil "_currentSelectionEntity") then {
	if (!isNull _currentSelectionEntity) then {
		private _rebuiltSelectionPaths =
			_currentSelectionEntity getVariable [
				"A3C_TREESEL_INDEX",
				[]
			];

		if (_rebuiltSelectionPaths isNotEqualTo []) then {
			private _rebuiltPathIndex =
				_currentSelectionPathIndex min
				((count _rebuiltSelectionPaths) - 1);

			_tree tvSetCurSel (
				_rebuiltSelectionPaths select _rebuiltPathIndex
			);
		};
	};
};

/*
	Store the layout generated by the canonical builder, rather than the stale
	layout captured before the rebuild.
*/
uiNamespace setVariable [
	_stateVariable,
	[
		_tree,
		_dataSignature,
		call _fnc_captureTreeLayout
	]
];

true

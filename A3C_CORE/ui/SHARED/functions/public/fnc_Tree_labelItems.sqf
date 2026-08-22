#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_Tree_labelItems

/*
	Rebuilds the shared squad/high-command selection tree for the active
	map-overlay or radial-menu display.
*/
params [
	["_displayId", -1, [0]]
];

private _display = findDisplay _displayId;

if (isNull _display) exitWith {};

private _isMap = _displayId == IDD_MAP_OVERLAY;
private _isRadial = _displayId == IDD_RADIAL_MENU;

if (!_isMap && {!_isRadial}) exitWith {};

private _tree = _display displayCtrl IDC_SHARED_UI_TREE_SELECTOR;

if (isNull _tree) exitWith {};

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

/*
	Keep a stable HC-group snapshot for this complete tree rebuild. The same
	array is used by Tree_addItem when assigning HC tree values.
*/
private _highCommandGroups = +(
	missionNamespace getVariable [
		"A3C_HC_allGroupsClient_Current",
		[]
	]
);

A3C_UI_SHARED_TREE_HC_AT_TICK = +_highCommandGroups;

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
	The legacy UI suppresses the HC tree when fewer than two HC groups are
	available.
*/
if (
	count A3C_UI_SHARED_TREE_HC_AT_TICK < 2
	&& {"HIGHCOMMAND" in _modes}
) then {
	_modes = _modes - ["HIGHCOMMAND"];
};

tvClear _tree;

/*
	Squad tree.
*/
if ("SQUAD" in _modes) then {
	private _unitArray = +(
		profileNamespace getVariable [
			"A3C_GROUPUNITS",
			[]
		]
	);

	private _vehicleEntries = [];
	private _soldiers = [];

	{
		private _unit = _x;
		private _vehicle = objectParent _unit;

		if (!isNull _vehicle) then {
			private _vehicleEntryIndex = _vehicleEntries findIf {
				(_x select 0) isEqualTo _vehicle
			};

			if (_vehicleEntryIndex >= 0) then {
				private _vehicleEntry =
					_vehicleEntries select _vehicleEntryIndex;

				(_vehicleEntry select 1) pushBack _unit;
			} else {
				_vehicleEntries pushBack [
					_vehicle,
					[
						_unit
					]
				];
			};
		} else {
			_soldiers pushBack _unit;
		};
	} forEach (_unitArray - [player]);

	private _squadRootIndex = _tree tvAdd [
		[],
		toUpper (groupID _playerTreeGroup)
	];

	if (_vehicleEntries isNotEqualTo []) then {
		/*
			Sort squad vehicles by the existing class priority, armor, and
			weapon count.
		*/
		_vehicleEntries = [
			_vehicleEntries,
			[],
			{
				private _vehicle = _x select 0;

				private _armor = getNumber (
					configFile
					>> "CfgVehicles"
					>> typeOf _vehicle
					>> "armor"
				);

				private _score = 0;

				{
					if (_vehicle isKindOf _x) exitWith {
						_score = 7000 - (1000 * _forEachIndex);
						_score = _score
							+ _armor
							+ ((count weapons _vehicle) * 100);
					};
				} forEach [
					"PLANE",
					"HELICOPTER",
					"TANK",
					"CAR",
					"SHIP",
					"STATICWEAPON"
				];

				_score
			},
			"DESCEND"
		] call BIS_fnc_sortBy;

		{
			_x params [
				"_vehicle",
				"_crewUnits"
			];

			[
				_tree,
				"SQUAD_VEH",
				[
					_vehicle,
					_crewUnits
				],
				_squadRootIndex,
				_forEachIndex
			] call A3C_ui_shared_fnc_Tree_addItem;
		} forEach _vehicleEntries;
	};

	if (_soldiers isNotEqualTo []) then {
		private _vehicleCount = count _vehicleEntries;

		{
			[
				_tree,
				"SQUAD_INF",
				[
					_x
				],
				_squadRootIndex,
				_vehicleCount + _forEachIndex
			] call A3C_ui_shared_fnc_Tree_addItem;
		} forEach _soldiers;
	};
};

/*
	High-command tree.
*/
if ("HIGHCOMMAND" in _modes) then {
	private _highCommandRootIndex = _tree tvAdd [
		[],
		"HIGH COMMAND"
	];

	private _planeGroups = _highCommandGroups select {
		private _groupUnits = units _x;
		private _leaderVehicle = vehicle leader _x;

		(driver _leaderVehicle) in _groupUnits
		&& {_leaderVehicle isKindOf "PLANE"}
	};

	private _helicopterGroups = _highCommandGroups select {
		private _groupUnits = units _x;
		private _leaderVehicle = vehicle leader _x;

		(driver _leaderVehicle) in _groupUnits
		&& {_leaderVehicle isKindOf "HELICOPTER"}
	};

	private _tankGroups = _highCommandGroups select {
		private _groupUnits = units _x;
		private _leaderVehicle = vehicle leader _x;

		(driver _leaderVehicle) in _groupUnits
		&& {_leaderVehicle isKindOf "TANK"}
	};

	private _wheeledApcGroups = _highCommandGroups select {
		private _groupUnits = units _x;
		private _leaderVehicle = vehicle leader _x;

		(driver _leaderVehicle) in _groupUnits
		&& {_leaderVehicle isKindOf "Wheeled_APC_F"}
	};

	private _carGroups = (
		_highCommandGroups select {
			private _groupUnits = units _x;
			private _leaderVehicle = vehicle leader _x;

			(driver _leaderVehicle) in _groupUnits
			&& {_leaderVehicle isKindOf "CAR"}
		}
	) - _wheeledApcGroups;

	private _shipGroups = _highCommandGroups select {
		private _groupUnits = units _x;
		private _leaderVehicle = vehicle leader _x;

		(driver _leaderVehicle) in _groupUnits
		&& {_leaderVehicle isKindOf "SHIP"}
	};

	private _staticGroups = _highCommandGroups select {
		(units _x) findIf {
			(vehicle _x) isKindOf "STATICWEAPON"
		} >= 0
	};

	private _infantryGroups = (
		_highCommandGroups select {
			(vehicle leader _x) isKindOf "MAN"
		}
	) - _staticGroups;

	/*
		The legacy autonomous category contains only UAV planes,
		helicopters, and car-class vehicles.
	*/
	private _planeUavGroups = _planeGroups select {
		unitIsUAV (vehicle leader _x)
	};

	_planeGroups = _planeGroups - _planeUavGroups;

	private _helicopterUavGroups = _helicopterGroups select {
		unitIsUAV (vehicle leader _x)
	};

	_helicopterGroups =
		_helicopterGroups - _helicopterUavGroups;

	private _carUavGroups = _carGroups select {
		unitIsUAV (vehicle leader _x)
	};

	_carGroups = _carGroups - _carUavGroups;

	private _categories = [
		[
			"PLANES",
			_planeGroups,
			false
		],
		[
			"HELICOPTERS",
			_helicopterGroups,
			false
		],
		[
			"TANKS",
			_tankGroups,
			false
		],
		[
			"APCS",
			_wheeledApcGroups,
			false
		],
		[
			"CARS",
			_carGroups,
			false
		],
		[
			"SHIPS",
			_shipGroups,
			false
		],
		[
			"STATIC WEAPONS",
			_staticGroups,
			false
		],
		[
			"INFANTRY",
			_infantryGroups,
			true
		],
		[
			"AUTONOMOUS",
			_planeUavGroups
				+ _helicopterUavGroups
				+ _carUavGroups,
			false
		]
	];

	{
		_x params [
			"_categoryName",
			"_categoryGroups",
			"_isInfantryCategory"
		];

		if (_categoryGroups isNotEqualTo []) then {
			/*
				Sort groups using the original vehicle-power calculation.
			*/
			_categoryGroups = [
				_categoryGroups,
				[],
				{
					private _group = _x;
					private _leaderVehicle = vehicle leader _group;
					private _leaderVehicleType = typeOf _leaderVehicle;

					private _armor = getNumber (
						configFile
						>> "CfgVehicles"
						>> _leaderVehicleType
						>> "armor"
					);

					private _weaponCount =
						count weapons _leaderVehicle;

					private _hasExternalCargo =
						(crew _leaderVehicle) findIf {
							group _x != _group
						} >= 0;

					private _cargoFactor = if (_hasExternalCargo) then {
						1000
					} else {
						0
					};

					private _score = _armor;

					{
						if (_x > 0) then {
							_score = _score * _x;
						};
					} forEach [
						_weaponCount,
						_cargoFactor
					];

					_score * sizeOf _leaderVehicleType
				},
				"DESCEND"
			] call BIS_fnc_sortBy;

			private _categoryIndex = _tree tvAdd [
				[
					_highCommandRootIndex
				],
				_categoryName
			];

			{
				private _group = _x;
				private _groupUnits = units _group;
				private _leaderVehicle = vehicle leader _group;

				private _groupIndex = _tree tvAdd [
					[
						_highCommandRootIndex,
						_categoryIndex
					],
					toUpper (groupID _group)
				];

				private _groupPath = [
					_highCommandRootIndex,
					_categoryIndex,
					_groupIndex
				];

				private _cargoGroups = [];

				{
					private _unit = _x;
					private _vehicle = objectParent _unit;

					if (
						!isNull _vehicle
						&& {_unit == driver _vehicle}
					) then {
						{
							private _crewUnit = _x;
							private _crewGroup = group _crewUnit;

							if (
								!(_crewUnit in _groupUnits)
								&& {_crewUnit == leader _crewGroup}
							) then {
								_cargoGroups pushBackUnique _crewGroup;
							};
						} forEach crew _vehicle;
					};
				} forEach _groupUnits;

				private _groupPicture = if (_isInfantryCategory) then {
					"A3C_CORE\ui\pictures\icon_menu_Stance_Stand.paa"
				} else {
					getText (
						configFile
						>> "CfgVehicles"
						>> typeOf _leaderVehicle
						>> "picture"
					)
				};

				_tree tvSetPicture [
					_groupPath,
					_groupPicture
				];

				_tree tvSetValue [
					_groupPath,
					[
						_group,
						A3C_UI_SHARED_TREE_HC_AT_TICK
					] call MCSS_fnc_getArrayIndex
				];

				_group setVariable [
					"A3C_TREESEL_INDEX",
					[
						_groupPath
					]
				];

				{
					[
						_tree,
						"HC_CARGO",
						[
							_x,
							_groupIndex
						],
						_highCommandRootIndex,
						_categoryIndex
					] call A3C_ui_shared_fnc_Tree_addItem;
				} forEach _cargoGroups;
			} forEach _categoryGroups;
		};
	} forEach _categories;
};

/*
	Restore the expanded/collapsed tree state appropriate for the active
	display and command level.
*/
private _openTrees = if (_isMap) then {
	+(
		missionNamespace getVariable [
			"A3C_UI_MAP_TREES_OPEN",
			[]
		]
	)
} else {
	private _commandLevel = missionNamespace getVariable [
		"A3C_CURRENT_COMMAND_LEVEL",
		"SQUAD"
	];

	if (_commandLevel == "SQUAD") then {
		+(
			missionNamespace getVariable [
				"A3C_RADIAL_TREES_OPEN_SQ",
				[]
			]
		)
	} else {
		+(
			missionNamespace getVariable [
				"A3C_RADIAL_TREES_OPEN_HC",
				[]
			]
		)
	}
};

if (_openTrees isNotEqualTo []) then {
	[
		_tree,
		_openTrees
	] spawn {
		params [
			"_tree",
			"_openTrees"
		];

		{
			private _operation = [
				[
					_tree,
					_x
				],
				"OPEN",
				_forEachIndex == 0,
				0
			] spawn A3C_ui_shared_fnc_Tree_openOrCollapse;

			waitUntil {
				scriptDone _operation
			};
		} forEach _openTrees;
	};
} else {
	/*
		Avoid passing an invalid [0] path when the tree contains no roots.
	*/
	if ((_tree tvCount []) > 0) then {
		[
			[
				_tree,
				[0]
			],
			"COLLAPSE",
			true,
			0
		] spawn A3C_ui_shared_fnc_Tree_openOrCollapse;
	};
};

/*
	Register this freshly generated tree as the synchronization baseline now,
	not on the first delayed FSM check. This prevents a redundant rebuild while
	still allowing any later join, removal, death, or structural change to be
	detected from the next signature comparison.
*/
[
	true
] call A3C_ui_shared_fnc_Tree_synchronize;

_tree

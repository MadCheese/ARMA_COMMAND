#include "..\..\shared_ui_defines.hpp"

// A3C_ui_shared_fnc_Tree_addItem

/*
	Adds an item to the shared squad/high-command tree.

	Modes:
		SQUAD_INF
			Adds an infantry unit directly beneath a squad root.

		SQUAD_VEH
			Adds a vehicle and then its crew as child entries.

		SQUAD_CREW
			Adds a crew member beneath a vehicle entry.

		HC_CARGO
			Adds a transported high-command group beneath a cargo branch.

		HC_CLASS
			Reserved; currently performs no operation.
*/
params [
	["_tree", controlNull, [controlNull]],
	["_mode", "", [""]],
	["_data", [], [[]]],
	["_mainTreeIndex", -1, [0]],
	["_parentIndex", -1, [0]]
];

if (isNull _tree) exitWith {};

private _unitArray = +(
	profileNamespace getVariable [
		"A3C_GROUPUNITS",
		[]
	]
);

private _fnc_getButtonColor = {
	params [
		["_unit", objNull, [objNull]]
	];

	private _assignedTeam = if (player == cameraOn) then {
		assignedTeam _unit
	} else {
		_unit getVariable [
			"A3C_ASSIGNEDTEAM",
			"MAIN"
		]
	};

	switch (_assignedTeam) do {
		case "RED": {
			[
				A3C_UI_COLOR_RED,
				1
			] call A3C_UI_fnc_setOpacity
		};

		case "GREEN": {
			[0, 1, 0, 1]
		};

		case "BLUE": {
			[
				A3C_UI_COLOR_BLUE,
				1
			] call A3C_UI_fnc_setOpacity
		};

		case "YELLOW": {
			[
				A3C_UI_COLOR_YELLOW,
				1
			] call A3C_UI_fnc_setOpacity
		};

		default {
			[1, 1, 1, 1]
		};
	}
};

switch (_mode) do {
	case "SQUAD_INF": {
		_data params [
			["_unit", objNull, [objNull]]
		];

		if (isNull _unit) exitWith {};

		private _displayName = if (alive _unit) then {
			[_unit] call MCSS_fnc_getUnitNameString
		} else {
			"N/A"
		};

		/*
			Use the index returned by tvAdd instead of assuming that the
			caller-provided parent index still matches the tree state.
		*/
		private _itemIndex = _tree tvAdd [
			[_mainTreeIndex],
			_displayName
		];

		private _treePath = [
			_mainTreeIndex,
			_itemIndex
		];

		private _secondaryWeapon = secondaryWeapon _unit;

		private _weapon = if (
			_secondaryWeapon isKindOf [
				"Launcher",
				configFile >> "CfgWeapons"
			]
		) then {
			_secondaryWeapon
		} else {
			primaryWeapon _unit
		};

		private _weaponPicture = getText (
			configFile
			>> "CfgWeapons"
			>> _weapon
			>> "picture"
		);

		_tree tvSetPicture [
			_treePath,
			_weaponPicture
		];

		private _hasMedikit = (items _unit) findIf {
			[
				_x
			] call A3C_main_fnc_getBaseWeapon == "Medikit"
		} >= 0;

		if (_hasMedikit) then {
			_tree tvSetPictureRight [
				_treePath,
				"A3C_CORE\ui\pictures\icon_menu_Medical.paa"
			];

			_tree tvSetPictureRightColor [
				_treePath,
				[1, 1, 1, 0.7]
			];
		} else {
			private _hasToolkit = (items _unit) findIf {
				[
					_x
				] call A3C_main_fnc_getBaseWeapon == "ToolKit"
			} >= 0;

			if (_hasToolkit) then {
				_tree tvSetPictureRight [
					_treePath,
					"A3C_CORE\ui\pictures\icon_menu_action_repair_noBG.paa"
				];

				_tree tvSetPictureRightColor [
					_treePath,
					[1, 1, 1, 0.7]
				];
			};
		};

		_unit setVariable [
			"A3C_TREESEL_INDEX",
			[
				_treePath
			]
		];

		_tree tvSetValue [
			_treePath,
			[
				_unit,
				_unitArray
			] call MCSS_fnc_getArrayIndex
		];

		_tree tvSetColor [
			_treePath,
			[
				_unit
			] call _fnc_getButtonColor
		];
	};

	case "SQUAD_VEH": {
		_data params [
			["_vehicle", objNull, [objNull]],
			["_crewUnits", [], [[]]]
		];

		if (isNull _vehicle) exitWith {};

		private _vehicleType = typeOf _vehicle;
		private _vehicleConfig = configFile >> "CfgVehicles" >> _vehicleType;

		private _vehicleIndex = _tree tvAdd [
			[_mainTreeIndex],
			getText (
				_vehicleConfig
				>> "displayName"
			)
		];

		private _vehiclePath = [
			_mainTreeIndex,
			_vehicleIndex
		];

		_tree tvSetPicture [
			_vehiclePath,
			getText (
				_vehicleConfig
				>> "picture"
			)
		];

		private _driver = driver _vehicle;

		if (_driver in (_unitArray - [player])) then {
			/*
				The legacy function wrote this value to [0, _parentIndex].
				That hard-coded root index was incorrect for trees whose
				squad root was not zero.
			*/
			_tree tvSetValue [
				_vehiclePath,
				[
					_driver,
					_unitArray
				] call MCSS_fnc_getArrayIndex
			];
		};

		private _vehicleCrew = crew _vehicle;

		private _sortedCrew = [
			_crewUnits,
			[],
			{
				[
					_x,
					_vehicleCrew
				] call MCSS_fnc_getArrayIndex
			},
			"ASCEND"
		] call BIS_fnc_sortBy;

		{
			[
				_tree,
				"SQUAD_CREW",
				[
					_x
				],
				_mainTreeIndex,
				_vehicleIndex
			] call A3C_ui_shared_fnc_Tree_addItem;
		} forEach _sortedCrew;
	};

	case "SQUAD_CREW": {
		_data params [
			["_unit", objNull, [objNull]]
		];

		if (isNull _unit) exitWith {};

		private _vehicle = vehicle _unit;

		private _displayName = if (alive _unit) then {
			[_unit] call MCSS_fnc_getUnitNameString
		} else {
			"N/A"
		};

		private _crewIndex = _tree tvAdd [
			[
				_mainTreeIndex,
				_parentIndex
			],
			_displayName
		];

		private _treePath = [
			_mainTreeIndex,
			_parentIndex,
			_crewIndex
		];

		_unit setVariable [
			"A3C_TREESEL_INDEX",
			[
				_treePath
			]
		];

		_tree tvSetColor [
			_treePath,
			[
				_unit
			] call _fnc_getButtonColor
		];

		private _assignedRole = assignedVehicleRole _unit;
		private _assignedRoleType = toLower (
			_assignedRole param [
				0,
				""
			]
		);

		private _rolePicture = switch true do {
			case (_unit == driver _vehicle): {
				"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_driver_ca.paa"
			};

			case (_unit == gunner _vehicle): {
				"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa"
			};

			case (
				_unit == commander _vehicle
				|| {
					_unit call MCSS_fnc_isUnitCopilot
				}
			): {
				"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_commander_ca.paa"
			};

			case (_assignedRoleType == "turret"): {
				"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa"
			};

			default {
				"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa"
			};
		};

		_tree tvSetPicture [
			_treePath,
			_rolePicture
		];

		_tree tvSetValue [
			_treePath,
			[
				_unit,
				_unitArray
			] call MCSS_fnc_getArrayIndex
		];
	};

	case "HC_CLASS": {
		/*
			Reserved for a future high-command classification entry.
		*/
	};

	case "HC_CARGO": {
		_data params [
			["_cargoGroup", grpNull, [grpNull]],
			["_cargoParentIndex", -1, [0]]
		];

		if (isNull _cargoGroup) exitWith {};

		private _cargoParentPath = [
			_mainTreeIndex,
			_parentIndex,
			_cargoParentIndex
		];

		private _cargoGroupIndex = _tree tvAdd [
			_cargoParentPath,
			toUpper (groupID _cargoGroup)
		];

		private _cargoGroupPath =
			_cargoParentPath + [_cargoGroupIndex];

		_tree tvSetPicture [
			_cargoGroupPath,
			"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa"
		];

		_tree tvSetValue [
			_cargoGroupPath,
			[
				_cargoGroup,
				A3C_UI_SHARED_TREE_HC_AT_TICK
			] call MCSS_fnc_getArrayIndex
		];

		_cargoGroup setVariable [
			"A3C_TREESEL_INDEX",
			[
				_cargoGroupPath
			]
		];
	};
};
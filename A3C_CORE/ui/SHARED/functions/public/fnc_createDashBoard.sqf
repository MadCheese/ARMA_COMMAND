#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"



/*
	A3C_ui_shared_fnc_createDashBoard

	Displays the dashboard immediately, then calculates the expensive group
	statistics in a scheduled worker.

	A request ID prevents a stale worker from updating the dashboard after
	the selected group or active display has changed.
*/

private _displayId = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_RADIAL_MENU
};

private _display = findDisplay _displayId;

if (isNull _display) exitWith {};

private _requestId = (
	uiNamespace getVariable [
		"A3C_ui_shared_dashboardRequestId",
		0
	]
) + 1;

uiNamespace setVariable [
	"A3C_ui_shared_dashboardRequestId",
	_requestId
];

//-- Delete dynamically created controls from the previous dashboard build.
private _existingExtraControls = missionNamespace getVariable [
	"A3C_ui_shared_fnc_createDashBoard_ExtraControls",
	[]
];

{
	if (!isNull _x) then {
		ctrlDelete _x;
	};
} forEach _existingExtraControls;

A3C_ui_shared_fnc_createDashBoard_ExtraControls = [];

private _parentControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT;

if (isNull _parentControl) exitWith {};

private _selectedGroups = +A3C_SELECTED_HC_GROUPS_SETTINGS;

if (count _selectedGroups != 1) exitWith {
	_parentControl ctrlShow false;
};

private _group = _selectedGroups select 0;
private _groupUnits = units _group;

if (_groupUnits isEqualTo []) exitWith {
	_parentControl ctrlShow false;
};

private _backgroundControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_BG;
private _rosterControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_PG_ROSTER_STRUCTURED;
private _groupNameControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_GROUPNAME;
private _groupIconControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_GROUPICON;
private _unitSizeControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_TXT_UNITSIZE;
private _locationControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_TXT_LOCATION;
private _taskControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_TXT_TASK;
private _healthTextControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_PG_HEALTH_TXT;
private _healthProgressControl = _display displayCtrl IDC_SHARED_UI_DASHBOARD_PG_HEALTH_BAR;

private _groupNameEditControl = controlNull;

if (_displayId == IDD_MAP_OVERLAY) then {
	_groupNameEditControl = _display displayCtrl IDC_MAP_DASHBOARD_GROUPNAME_EDIT;

	if (!isNull _groupNameEditControl) then {
		// Hide the edit control while retaining its editable value.
		_groupNameEditControl ctrlSetTextColor [1, 1, 1, 0];
	};
};

private _resolutionScale = (getResolution select 5) max 0.001;
private _textRowHeight = 0.021 / _resolutionScale;
private _progressRowStep = 1.5 * _textRowHeight;

/*
	Reset the static dashboard controls before displaying the lightweight
	initial state.
*/
private _parentPosition = ctrlPosition _parentControl;

_parentPosition set [
	1,
	0.414993 * safeZoneH + safeZoneY
];

_parentPosition set [
	2,
	0.240009 * safeZoneW
];

_parentPosition set [
	3,
	0.289024 * safeZoneH + _progressRowStep
];

if (_displayId == IDD_MAP_OVERLAY) then {
	private _groupPanelControl = _display displayCtrl IDC_MAP_HCGP_Parent;

	if (!isNull _groupPanelControl) then {
		private _groupPanelPosition = ctrlPosition _groupPanelControl;

		_parentPosition set [
			0,
			(_groupPanelPosition select 0) - (_parentPosition select 2)
		];

		_parentPosition set [
			1,
			_groupPanelPosition select 1
		];
	};
};

_parentControl ctrlSetPosition _parentPosition;
_parentControl ctrlCommit 0;

if (!isNull _backgroundControl) then {
	_backgroundControl ctrlSetPosition [
		4.9593e-007 * safeZoneW,
		0,
		0.240009 * safeZoneW,
		0.221018 * safeZoneH + _progressRowStep
	];

	_backgroundControl ctrlCommit 0;

	private _backgroundColor = if (
		_displayId == IDD_RADIAL_MENU
		&& {sunOrMoon < 1}
	) then {
		[0, 0.5, 0.8, 0.6]
	} else {
		[0, 0, 0, 0.6]
	};

	_backgroundControl ctrlSetTextColor _backgroundColor;
};

if (!isNull _rosterControl) then {
	_rosterControl ctrlSetPosition [
		0.104004 * safeZoneW,
		0.136011 * safeZoneH,
		0.136005 * safeZoneW,
		0.085007 * safeZoneH + _progressRowStep
	];

	_rosterControl ctrlCommit 0;
	_rosterControl ctrlSetBackgroundColor [0, 0, 0, 0.2];
};

private _groupLeader = leader _group;
private _leaderVehicle = vehicle _groupLeader;
private _isCargoGroup = !(driver _leaderVehicle in _groupUnits);

private _groupIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\SI_stand_ca.paa";

if (!isNull objectParent _groupLeader) then {
	_groupIcon = if (_isCargoGroup) then {
		"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa"
	} else {
		getText (
			configFile
			>> "CfgVehicles"
			>> typeOf _leaderVehicle
			>> "picture"
		)
	};
};

private _groupId = groupID _group;

if (!isNull _groupNameControl) then {
	_groupNameControl ctrlSetText _groupId;
};

if (!isNull _groupNameEditControl) then {
	_groupNameEditControl ctrlSetText _groupId;
};

if (!isNull _groupIconControl) then {
	_groupIconControl ctrlSetText _groupIcon;
};

if (!isNull _unitSizeControl) then {
	_unitSizeControl ctrlSetText format [
		"Unitsize: %1",
		count _groupUnits
	];
};

if (!isNull _locationControl) then {
	_locationControl ctrlSetText "Location: Calculating...";
};

if (!isNull _taskControl) then {
	_taskControl ctrlSetText "Current Task: Calculating...";
};

if (!isNull _rosterControl) then {
	_rosterControl ctrlSetStructuredText parseText (
		"<t size='.7' align='left'>CALCULATING...</t>"
	);
};

if (!isNull _healthTextControl) then {
	_healthTextControl ctrlSetTextColor [1, 1, 1, 1];
};

if (!isNull _healthProgressControl) then {
	_healthProgressControl progressSetPosition 0;
	_healthProgressControl ctrlSetTextColor [1, 0, 0, 0.6];
};

_parentControl ctrlShow true;

/*
	The heavy pass is scheduled so the dashboard shell can render before
	inventory and configuration analysis begins.
*/
[
	_display,
	_displayId,
	_group,
	_requestId,
	_parentControl,
	_backgroundControl,
	_rosterControl,
	_locationControl,
	_taskControl,
	_healthTextControl,
	_healthProgressControl
] spawn {
	disableSerialization;

	params [
		"_display",
		"_displayId",
		"_group",
		"_requestId",
		"_parentControl",
		"_backgroundControl",
		"_rosterControl",
		"_locationControl",
		"_taskControl",
		"_healthTextControl",
		"_healthProgressControl"
	];

	private _fnc_requestIsCurrent = {
		if (isNull _display) exitWith {
			false
		};

		if (
			(
				uiNamespace getVariable [
					"A3C_ui_shared_dashboardRequestId",
					-1
				]
			) != _requestId
		) exitWith {
			false
		};

		private _currentSelection = A3C_SELECTED_HC_GROUPS_SETTINGS;

		count _currentSelection == 1
		&& {
			(_currentSelection select 0) isEqualTo _group
		}
	};

	if !(call _fnc_requestIsCurrent) exitWith {};

	private _groupUnits = units _group;

	if (_groupUnits isEqualTo []) exitWith {};

	private _groupLeader = leader _group;
	private _leaderVehicle = vehicle _groupLeader;
	private _isCargoGroup = !(driver _leaderVehicle in _groupUnits);

	private _cfgVehicles = configFile >> "CfgVehicles";
	private _cfgWeapons = configFile >> "CfgWeapons";
	private _cfgMagazines = configFile >> "CfgMagazines";

	/*
		The default loadout cache avoids repeatedly parsing identical
		CfgVehicles loadouts whenever the dashboard is opened.
	*/
	private _defaultLoadoutCache = uiNamespace getVariable [
		"A3C_ui_shared_dashboardDefaultLoadoutCache",
		createHashMap
	];

	private _throwableCache = uiNamespace getVariable [
		"A3C_ui_shared_dashboardThrowableCache",
		createHashMap
	];

	private _fnc_isThrowable = {
		params ["_magazineClass"];

		private _cachedResult = _throwableCache getOrDefault [
			_magazineClass,
			-1
		];

		if (_cachedResult isEqualType true) exitWith {
			_cachedResult
		};

		private _isThrowable = _magazineClass call BIS_fnc_isThrowable;

		_throwableCache set [
			_magazineClass,
			_isThrowable
		];

		_isThrowable
	};

	/*
		Returns aggregated default magazine counts for a unit class:

		[
			[magazineClass, count],
			...
		]

		The old function reconstructed this data for every unit on every
		dashboard refresh.
	*/
	private _fnc_getDefaultMagazineCounts = {
		params ["_unitType"];

		private _cachedLoadout = _defaultLoadoutCache getOrDefault [
			_unitType,
			""
		];

		if (_cachedLoadout isEqualType []) exitWith {
			_cachedLoadout
		};

		private _loadout = getUnitLoadout (
			_cfgVehicles >> _unitType
		);

		private _magazineCounts = createHashMap;
		private _magazineOrder = [];

		private _fnc_addMagazine = {
			params [
				"_magazineClass",
				"_magazineCount"
			];

			if (
				_magazineClass == ""
				|| {_magazineCount <= 0}
			) exitWith {};

			private _existingCount = _magazineCounts getOrDefault [
				_magazineClass,
				-1
			];

			if (_existingCount < 0) then {
				_existingCount = 0;
				_magazineOrder pushBack _magazineClass;
			};

			_magazineCounts set [
				_magazineClass,
				_existingCount + _magazineCount
			];
		};

		for "_weaponIndex" from 0 to 2 do {
			private _weaponData = _loadout param [
				_weaponIndex,
				[]
			];

			if (
				_weaponData isEqualType []
				&& {count _weaponData > 4}
			) then {
				private _magazineData = _weaponData param [
					4,
					[]
				];

				if (
					_magazineData isEqualType []
					&& {count _magazineData > 0}
				) then {
					[
						_magazineData param [0, ""],
						1
					] call _fnc_addMagazine;
				};
			};
		};

		for "_containerIndex" from 3 to 5 do {
			private _containerData = _loadout param [
				_containerIndex,
				[]
			];

			if (
				_containerData isEqualType []
				&& {count _containerData > 1}
			) then {
				private _containerContents = _containerData param [
					1,
					[]
				];

				{
					if (
						_x isEqualType []
						&& {count _x > 1}
					) then {
						private _itemClass = _x param [
							0,
							""
						];

						if (
							_itemClass != ""
							&& {
								isClass (
									_cfgMagazines >> _itemClass
								)
							}
						) then {
							[
								_itemClass,
								_x param [1, 0]
							] call _fnc_addMagazine;
						};
					};
				} forEach _containerContents;
			};
		};

		private _result = _magazineOrder apply {
			[
				_x,
				_magazineCounts get _x
			]
		};

		_defaultLoadoutCache set [
			_unitType,
			_result
		];

		_result
	};

	/*
		Location and current-task text.
	*/
	private _locationText = "UNKNOWN LOCATION";

	private _locations = nearestLocations [
		position _leaderVehicle,
		[
			"NameLocal",
			"NameCity",
			"NameMarine",
			"NameVillage",
			"StrongpointArea",
			"NameCityCapital"
		],
		5000
	];

	private _locationIndex = _locations findIf {
		!("000" in text _x)
	};

	if (_locationIndex >= 0) then {
		_locationText = format [
			"Location: Near %1 at %2",
			text (_locations select _locationIndex),
			mapGridPosition position _leaderVehicle
		];
	};

	private _currentWaypointIndex = currentWaypoint _group;
	private _currentWaypoint = [
		_group,
		_currentWaypointIndex
	];

	private _actionScript = waypointScript _currentWaypoint;

	if (_actionScript == "") then {
		_actionScript = (
			waypointStatements _currentWaypoint
		) select 1;
	};

	private _actionScriptLower = toLower _actionScript;
	private _currentTask = "Idle";

	switch true do {
		case ("transport unload" in _actionScriptLower): {
			_currentTask = "Deliver Troops";
		};

		case (
			!_isCargoGroup
			&& {
				crew _leaderVehicle findIf {
					group _x != _group
				} >= 0
			}
		): {
			_currentTask = "Transporting units";
		};

		case _isCargoGroup: {
			_currentTask = "In Transport";
		};

		case ("landing" in _actionScriptLower): {
			_currentTask = "Landing Aircraft";
		};

		case ("rappel" in _actionScriptLower): {
			_currentTask = "Rappeling Cargo";
		};

		case ("repair" in _actionScriptLower): {
			_currentTask = "Repairing Vehicles";
		};

		case ("assemble" in _actionScriptLower): {
			_currentTask = "Assembling Static Weapon";
		};

		case ("cas-strike" in _actionScriptLower): {
			_currentTask = "Preparing CAS-Strike";
		};

		case ("sling load hook" in _actionScriptLower): {
			_currentTask = "Preparing Sling-Load Hook";
		};

		case ("sling load unhook" in _actionScriptLower): {
			_currentTask = "Preparing Sling-Load Unhook";
		};

		case ("paradrop" in _actionScriptLower): {
			_currentTask = "Preparing Paradrop";
		};

		case ("plantexplosive" in _actionScriptLower): {
			_currentTask = "Planting Explosives";
		};

		case ("clearbuilding" in _actionScriptLower): {
			_currentTask = "Clearing Building";
		};

		case ("assemble_uav" in _actionScriptLower): {
			_currentTask = "Setting Up UAV";
		};

		case ("overwatch" in _actionScriptLower): {
			_currentTask = "En Route For Overwatch";
		};

		default {
			if (waypointType _currentWaypoint == "MOVE") then {
				_currentTask = "Moving";
			};
		};
	};

	private _freezeData = _leaderVehicle getVariable [
		"A3C_Freeze_helicopter",
		[false, 0]
	];

	if (_freezeData param [0, false]) then {
		_currentTask = "Providing Overwatch";
	};

	private _currentTaskText = format [
		"Current Task: %1",
		_currentTask
	];

	/*
		Aggregate infantry statistics without constructing and repeatedly
		filtering large temporary magazine arrays.
	*/
	private _vehicles = [];

	private _manDamageSum = 0;
	private _manDamageCount = 0;

	private _staminaSum = 0;
	private _staminaCount = 0;

	private _primaryValueSum = 0;
	private _primaryValueCount = 0;

	private _secondaryValueSum = 0;
	private _secondaryValueCount = 0;

	private _throwableValueSum = 0;
	private _throwableValueCount = 0;

	private _hasVehicleOccupants = false;
	private _hasFootOrCargoUnits = false;
	private _hasGroupDriver = false;
	private _hasLauncher = false;

	{
		private _unit = _x;
		private _parentVehicle = objectParent _unit;
		private _isInVehicle = !isNull _parentVehicle;

		if (_isInVehicle) then {
			_hasVehicleOccupants = true;

			if (_unit == driver _parentVehicle) then {
				_hasGroupDriver = true;
			};
		};

		private _assignedRole = assignedVehicleRole _unit;

		private _isCargo = (
			_isInVehicle
			&& {
				_assignedRole isNotEqualTo []
				&& {
					toLower (
						_assignedRole select 0
					) == "cargo"
				}
			}
		);

		if (!_isInVehicle || {_isCargo}) then {
			_hasFootOrCargoUnits = true;

			_manDamageSum = _manDamageSum + damage _unit;
			_manDamageCount = _manDamageCount + 1;

			_staminaSum = _staminaSum + (
				1 - getFatigue _unit
			);

			_staminaCount = _staminaCount + 1;

			private _launcherClass = secondaryWeapon _unit;

			private _launcherAllowedMagazines = if (
				_launcherClass == ""
			) then {
				[]
			} else {
				getArray (
					_cfgWeapons
					>> _launcherClass
					>> "magazines"
				)
			};

			if (
				_launcherClass != ""
				&& {
					_launcherClass isKindOf [
						"Launcher",
						_cfgWeapons
					]
				}
			) then {
				_hasLauncher = true;
			};

			private _expectedPrimary = 0;
			private _expectedSecondary = 0;
			private _expectedThrowables = 0;

			{
				_x params [
					"_magazineClass",
					"_magazineCount"
				];

				if (
					[_magazineClass] call _fnc_isThrowable
				) then {
					_expectedThrowables =
						_expectedThrowables
						+ _magazineCount;
				} else {
					if (
						_magazineClass
						in _launcherAllowedMagazines
					) then {
						_expectedSecondary =
							_expectedSecondary
							+ _magazineCount;
					} else {
						_expectedPrimary =
							_expectedPrimary
							+ _magazineCount;
					};
				};
			} forEach (
				[typeOf _unit]
				call _fnc_getDefaultMagazineCounts
			);

			private _currentPrimary = 0;
			private _currentSecondary = 0;
			private _currentThrowables = 0;

			private _currentMagazines = (
				magazines _unit
			) + (
				primaryWeaponMagazine _unit
			) + (
				secondaryWeaponMagazine _unit
			) + (
				handgunMagazine _unit
			);

			{
				private _magazineClass = _x;

				if (
					[_magazineClass] call _fnc_isThrowable
				) then {
					_currentThrowables =
						_currentThrowables + 1;
				} else {
					if (
						_magazineClass
						in _launcherAllowedMagazines
					) then {
						_currentSecondary =
							_currentSecondary + 1;
					} else {
						_currentPrimary =
							_currentPrimary + 1;
					};
				};
			} forEach _currentMagazines;

			if (_expectedPrimary > 0) then {
				_primaryValueSum = _primaryValueSum + (
					(
						_currentPrimary
						/ _expectedPrimary
					) min 1
				);

				_primaryValueCount =
					_primaryValueCount + 1;
			};

			if (_expectedSecondary > 0) then {
				_secondaryValueSum =
					_secondaryValueSum + (
						(
							_currentSecondary
							/ _expectedSecondary
						) min 1
					);

				_secondaryValueCount =
					_secondaryValueCount + 1;
			};

			if (_expectedThrowables > 0) then {
				_throwableValueSum =
					_throwableValueSum + (
						(
							_currentThrowables
							/ _expectedThrowables
						) min 1
					);

				_throwableValueCount =
					_throwableValueCount + 1;
			};
		} else {
			_vehicles pushBackUnique _parentVehicle;
		};
	} forEach _groupUnits;

	/*
		Vehicle statistics.

		The legacy function scanned CfgVehicles magazines and turret
		configuration, but the resulting default-magazine arrays were never
		used in any final calculation. Those scans are removed.
	*/
	private _vehicleDamageSum = 0;
	private _vehicleDamageCount = 0;

	private _fuelSum = 0;
	private _fuelCount = 0;

	private _vehicleAmmoValueSum = 0;
	private _vehicleAmmoValueCount = 0;

	private _vehiclePylonValueSum = 0;
	private _vehiclePylonValueCount = 0;

	private _hasArmedVehicle = false;
	private _hasPylonVehicle = false;

	{
		private _vehicle = _x;

		_vehicleDamageSum =
			_vehicleDamageSum + damage _vehicle;

		_vehicleDamageCount =
			_vehicleDamageCount + 1;

		_fuelSum = _fuelSum + fuel _vehicle;
		_fuelCount = _fuelCount + 1;

		if (!_hasArmedVehicle) then {
			_hasArmedVehicle = (
				weapons _vehicle
			) findIf {
				private _weaponName = toLower _x;

				!("horn" in _weaponName)
				&& {!("smoke" in _weaponName)}
				&& {!("laser" in _weaponName)}
			} >= 0;
		};

		private _remainingPylonMagazines = +(
			getPylonMagazines _vehicle
		);

		if (_remainingPylonMagazines isNotEqualTo []) then {
			_hasPylonVehicle = true;
		};

		private _generalMagazineSum = 0;
		private _generalMagazineCount = 0;

		private _pylonMagazineSum = 0;
		private _pylonMagazineCount = 0;

		{
			private _magazineClass = _x param [
				0,
				""
			];

			private _ammoCount = _x param [
				1,
				0
			];

			if (
				_magazineClass != ""
				&& {
					!("laser" in toLower _magazineClass)
				}
			) then {
				private _fullMagazineCount = getNumber (
					_cfgMagazines
					>> _magazineClass
					>> "count"
				);

				private _percentage = if (
					_ammoCount > 0
					&& {_fullMagazineCount > 0}
				) then {
					_ammoCount / _fullMagazineCount
				} else {
					0
				};

				private _pylonIndex =
					_remainingPylonMagazines
					find _magazineClass;

				if (_pylonIndex >= 0) then {
					_remainingPylonMagazines deleteAt _pylonIndex;

					_pylonMagazineSum =
						_pylonMagazineSum
						+ _percentage;

					_pylonMagazineCount =
						_pylonMagazineCount + 1;
				} else {
					_generalMagazineSum =
						_generalMagazineSum
						+ _percentage;

					_generalMagazineCount =
						_generalMagazineCount + 1;
				};
			};
		} forEach magazinesAmmoFull _vehicle;

		private _vehicleAmmoValue = if (
			_generalMagazineCount > 0
		) then {
			_generalMagazineSum
			/ _generalMagazineCount
		} else {
			0
		};

		private _vehiclePylonValue = if (
			_pylonMagazineCount > 0
		) then {
			_pylonMagazineSum
			/ _pylonMagazineCount
		} else {
			0
		};

		_vehicleAmmoValueSum =
			_vehicleAmmoValueSum
			+ _vehicleAmmoValue;

		_vehicleAmmoValueCount =
			_vehicleAmmoValueCount + 1;

		_vehiclePylonValueSum =
			_vehiclePylonValueSum
			+ _vehiclePylonValue;

		_vehiclePylonValueCount =
			_vehiclePylonValueCount + 1;
	} forEach _vehicles;

	private _fnc_averageCut = {
		params [
			"_sum",
			"_count",
			["_default", 0]
		];

		if (_count <= 0) exitWith {
			_default
		};

		[
			_sum / _count,
			1
		] call BIS_fnc_cutDecimals
	};

	private _groupHealthMan = 1 - (
		[
			_manDamageSum,
			_manDamageCount,
			0
		] call _fnc_averageCut
	);

	private _groupHealthVehicle = 1 - (
		[
			_vehicleDamageSum,
			_vehicleDamageCount,
			0
		] call _fnc_averageCut
	);

	private _groupPrimaryAmmo = [
		_primaryValueSum,
		_primaryValueCount,
		0
	] call _fnc_averageCut;

	private _groupSecondaryAmmo = [
		_secondaryValueSum,
		_secondaryValueCount,
		0
	] call _fnc_averageCut;

	private _groupThrowables = [
		_throwableValueSum,
		_throwableValueCount,
		0
	] call _fnc_averageCut;

	private _groupVehicleAmmo = [
		_vehicleAmmoValueSum,
		_vehicleAmmoValueCount,
		0
	] call _fnc_averageCut;

	private _groupVehiclePylons = [
		_vehiclePylonValueSum,
		_vehiclePylonValueCount,
		0
	] call _fnc_averageCut;

	private _groupFuel = [
		_fuelSum,
		_fuelCount,
		0
	] call _fnc_averageCut;

	/*
		The legacy function summed stamina without dividing by the number of
		units. That could produce progress values greater than 1.
	*/
	private _groupStamina = [
		_staminaSum,
		_staminaCount,
		0
	] call _fnc_averageCut;

	private _progressEntries = [];

	if (_vehicles isNotEqualTo []) then {
		_progressEntries pushBack [
			"Health (Vehicles)",
			_groupHealthVehicle
		];

		if (_hasArmedVehicle) then {
			_progressEntries pushBack [
				"Ammo (Vehicles)",
				_groupVehicleAmmo
			];

			if (_hasPylonVehicle) then {
				_progressEntries pushBack [
					"Pylons",
					_groupVehiclePylons
				];
			};
		};
	};

	if (_hasFootOrCargoUnits) then {
		_progressEntries pushBack [
			"Mags  (Soldiers)",
			_groupPrimaryAmmo
		];

		_progressEntries pushBack [
			"Throwables",
			_groupThrowables
		];

		if (_hasLauncher) then {
			_progressEntries pushBack [
				"Launchers",
				_groupSecondaryAmmo
			];
		};

		_progressEntries pushBack [
			"Stamina",
			_groupStamina
		];
	};

	if (_hasGroupDriver) then {
		_progressEntries pushBack [
			"Fuel",
			_groupFuel
		];
	};

	private _hasMedic = (
		[
			_groupUnits
		] call A3C_ai_shared_fnc_medical_findMedics
	) isNotEqualTo [];

	private _hasRepairUnit = _groupUnits findIf {
		[_x] call A3C_main_fnc_canRepair
	} >= 0;

	/*
		Count classes with hash maps instead of nested linear searches.
		The first-encounter order is retained.
	*/
	private _fnc_countTypes = {
		params ["_objects"];

		private _typeCounts = createHashMap;
		private _typeOrder = [];

		{
			private _objectType = typeOf _x;

			private _currentCount = _typeCounts getOrDefault [
				_objectType,
				-1
			];

			if (_currentCount < 0) then {
				_currentCount = 0;
				_typeOrder pushBack _objectType;
			};

			_typeCounts set [
				_objectType,
				_currentCount + 1
			];
		} forEach _objects;

		[
			_typeOrder,
			_typeCounts
		]
	};

	private _vehicleTypeData = [
		_vehicles
	] call _fnc_countTypes;

	private _unitTypeData = [
		_groupUnits
	] call _fnc_countTypes;

	_vehicleTypeData params [
		"_vehicleTypeOrder",
		"_vehicleTypeCounts"
	];

	_unitTypeData params [
		"_unitTypeOrder",
		"_unitTypeCounts"
	];

	private _structuredParts = [];

	if (_vehicleTypeOrder isNotEqualTo []) then {
		_structuredParts pushBack (
			"<t size='.7' align='left'>VEHICLES: </t>"
		);

		{
			private _vehicleClass = _x;

			_structuredParts pushBack format [
				"<br/> <img align='left' image='%1'/> <t size='.6' align='left'>%2 (%3x) </t>",
				getText (
					_cfgVehicles
					>> _vehicleClass
					>> "picture"
				),
				getText (
					_cfgVehicles
					>> _vehicleClass
					>> "displayName"
				),
				_vehicleTypeCounts get _vehicleClass
			];
		} forEach _vehicleTypeOrder;

		_structuredParts pushBack "<br/>";
	};

	_structuredParts pushBack (
		"<t size='.7' align='left'>UNITS: </t><br/>"
	);

	private _unitTypeCount = count _unitTypeOrder;

	{
		private _unitClass = _x;

		private _unitText = format [
			"<t size='.6' align='left'>%1 (%2x)</t>",
			getText (
				_cfgVehicles
				>> _unitClass
				>> "displayName"
			),
			_unitTypeCounts get _unitClass
		];

		if (_forEachIndex < (_unitTypeCount - 1)) then {
			_unitText = _unitText + (
				"<t size='.6' align='left'>, </t>"
			);
		};

		if ((_forEachIndex + 1) mod 2 == 0) then {
			_unitText = _unitText + "<br/>";
		};

		_structuredParts pushBack _unitText;
	} forEach _unitTypeOrder;

	private _structuredText = parseText (
		_structuredParts joinString ""
	);

	uiNamespace setVariable [
		"A3C_ui_shared_dashboardDefaultLoadoutCache",
		_defaultLoadoutCache
	];

	uiNamespace setVariable [
		"A3C_ui_shared_dashboardThrowableCache",
		_throwableCache
	];

	if !(call _fnc_requestIsCurrent) exitWith {};

	/*
		Apply the calculated values.
	*/
	if (!isNull _locationControl) then {
		_locationControl ctrlSetText _locationText;
	};

	if (!isNull _taskControl) then {
		_taskControl ctrlSetText _currentTaskText;
	};

	if (!isNull _rosterControl) then {
		_rosterControl ctrlSetStructuredText _structuredText;
	};

	private _fnc_getProgressColor = {
		params ["_progress"];

		switch true do {
			case (_progress <= 0.3): {
				[
					A3C_UI_COLOR_RED,
					0.6
				] call A3C_ui_shared_fnc_getColorArrayWithOpacity
			};

			case (_progress < 0.7): {
				[
					A3C_UI_COLOR_YELLOW,
					0.6
				] call A3C_ui_shared_fnc_getColorArrayWithOpacity
			};

			default {
				[0, 1, 0, 0.6]
			};
		}
	};

	if (!isNull _healthTextControl) then {
		_healthTextControl ctrlSetTextColor (
			if (_groupHealthMan == 0) then {
				[1, 0, 0, 1]
			} else {
				[1, 1, 1, 1]
			}
		);
	};

	if (!isNull _healthProgressControl) then {
		_healthProgressControl progressSetPosition _groupHealthMan;

		_healthProgressControl ctrlSetTextColor (
			[_groupHealthMan]
				call _fnc_getProgressColor
		);
	};

	/*
		Resize the static dashboard only once, based on the final number of
		dynamic progress rows.
	*/
	private _resolutionScale = (
		getResolution select 5
	) max 0.001;

	private _textRowHeight = 0.021 / _resolutionScale;
	private _progressRowStep = 1.5 * _textRowHeight;

	private _extraRowCount = (
		(count _progressEntries) - 3
	) max 0;

	private _parentPosition = ctrlPosition _parentControl;

	_parentPosition set [
		1,
		(
			0.414993 * safeZoneH
			+ safeZoneY
		) - (
			if (_displayId == IDD_RADIAL_MENU) then {
				_extraRowCount
				* 0.75
				* _textRowHeight
			} else {
				0
			}
		)
	];

	_parentPosition set [
		2,
		0.240009 * safeZoneW
	];

	_parentPosition set [
		3,
		0.289024 * safeZoneH
		+ _progressRowStep
		+ (
			_extraRowCount
			* _progressRowStep
		)
	];

	if (_displayId == IDD_MAP_OVERLAY) then {
		private _groupPanelControl = _display displayCtrl IDC_MAP_HCGP_Parent;

		if (!isNull _groupPanelControl) then {
			private _groupPanelPosition = ctrlPosition _groupPanelControl;

			_parentPosition set [
				0,
				(_groupPanelPosition select 0)
				- (_parentPosition select 2)
			];

			_parentPosition set [
				1,
				_groupPanelPosition select 1
			];
		};
	};

	_parentControl ctrlSetPosition _parentPosition;
	_parentControl ctrlCommit 0;

	if (!isNull _backgroundControl) then {
		_backgroundControl ctrlSetPosition [
			4.9593e-007 * safeZoneW,
			0,
			0.240009 * safeZoneW,
			0.221018 * safeZoneH
			+ _progressRowStep
			+ (
				_extraRowCount
				* _progressRowStep
			)
		];

		_backgroundControl ctrlCommit 0;
	};

	if (!isNull _rosterControl) then {
		_rosterControl ctrlSetPosition [
			0.104004 * safeZoneW,
			0.136011 * safeZoneH,
			0.136005 * safeZoneW,
			0.085007 * safeZoneH
			+ _progressRowStep
			+ (
				_extraRowCount
				* _progressRowStep
			)
		];

		_rosterControl ctrlCommit 0;
	};

	private _newExtraControls = [];
	private _progressIndex = 1;

	{
		_x params [
			"_description",
			"_progress"
		];

		private _progressPosition = [
			(0.00800027 - 0.002) * safeZoneW,
			0.136011 * safeZoneH
			+ (
				_progressIndex
				* _progressRowStep
			),
			0.0800031 * safeZoneW,
			0.0085007 * safeZoneH
		];

		private _textPosition = [
			-3.81485e-008 * safeZoneW,
			(_progressPosition select 1)
			- _textRowHeight,
			0.0800031 * safeZoneW,
			_textRowHeight
		];

		private _progressBackground = _display ctrlCreate [
			"RscPicture",
			-1,
			_parentControl
		];

		_progressBackground ctrlSetPosition _progressPosition;
		_progressBackground ctrlSetText (
			"#(argb,8,8,3)color(0.5,0.5,0.5,0.5)"
		);

		private _progressControl = _display ctrlCreate [
			"RscProgress",
			-1,
			_parentControl
		];

		_progressControl ctrlSetPosition _progressPosition;
		_progressControl progressSetPosition _progress;

		_progressControl ctrlSetTextColor (
			[_progress] call _fnc_getProgressColor
		);

		private _progressText = _display ctrlCreate [
			"A3C_RscText_GroupDashboard",
			-1,
			_parentControl
		];

		_progressText ctrlSetText _description;
		_progressText ctrlSetPosition _textPosition;

		if (_progress == 0) then {
			_progressText ctrlSetTextColor [1, 0, 0, 1];
		};

		{
			_x ctrlCommit 0;
		} forEach [
			_progressBackground,
			_progressControl,
			_progressText
		];

		_newExtraControls append [
			_progressBackground,
			_progressControl,
			_progressText
		];

		_progressIndex = _progressIndex + 1;
	} forEach _progressEntries;

	/*
		Support icons are included in the same cleanup collection. The old
		function recreated them without adding them to ExtraControls.
	*/
	private _supportPosition = [
		0.150315 * safeZoneW,
		3.09064e-006 * safeZoneH,
		0.0159271 * safeZoneW,
		0.0340016 * safeZoneH
	];

	if (_hasMedic) then {
		private _medicIcon = _display ctrlCreate [
			"RscPicture",
			-1,
			_parentControl
		];

		_medicIcon ctrlSetPosition _supportPosition;
		_medicIcon ctrlSetText (
			"A3C_CORE\ui\pictures\icon_menu_Medical.paa"
		);

		_medicIcon ctrlSetTextColor [1, 1, 1, 0.6];

		_medicIcon ctrlSetTooltipColorBox [
			1,
			1,
			1,
			0.3
		];

		_medicIcon ctrlSetTooltipColorShade [
			1,
			1,
			1,
			0.3
		];

		_medicIcon ctrlSetTooltip (
			"Units in this group are capable of healing"
		);

		_medicIcon ctrlCommit 0;

		_newExtraControls pushBack _medicIcon;
	};

	if (_hasRepairUnit) then {
		if (_hasMedic) then {
			_supportPosition set [
				1,
				3.09064e-006 * safeZoneH
				+ 0.0340016 * safeZoneH
			];
		};

		private _repairIcon = _display ctrlCreate [
			"RscPicture",
			-1,
			_parentControl
		];

		_repairIcon ctrlSetPosition _supportPosition;

		_repairIcon ctrlSetText (
			"A3C_UI\menu\icon_menu_action_repair.paa"
		);

		_repairIcon ctrlSetTextColor [1, 1, 1, 0.6];

		_repairIcon ctrlSetTooltip (
			"Units in this group are capable of repairing"
		);

		_repairIcon ctrlSetTooltipColorBox [
			1,
			1,
			1,
			0.3
		];

		_repairIcon ctrlSetTooltipColorShade [
			1,
			1,
			1,
			0.3
		];

		_repairIcon ctrlCommit 0;

		_newExtraControls pushBack _repairIcon;
	};

	/*
		If the selection changed during control creation, delete the controls
		produced by this stale request.
	*/
	if !(call _fnc_requestIsCurrent) exitWith {
		{
			if (!isNull _x) then {
				ctrlDelete _x;
			};
		} forEach _newExtraControls;
	};

	A3C_ui_shared_fnc_createDashBoard_ExtraControls =
		_newExtraControls;

	_parentControl ctrlShow true;
};
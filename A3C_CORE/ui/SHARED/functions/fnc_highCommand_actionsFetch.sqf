#include "..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_highCommand_actionsFetch

/*
	Collects and prioritizes the high-command actions available for the
	current group selection.

	The function also prepares the global unit/group arrays consumed later
	by individual action handlers.
*/
params [
	["_displayId", -1, [0]]
];

private _isRadial = _displayId == IDD_RADIAL_MENU;
private _isMap = _displayId == IDD_MAP_OVERLAY;

if (!_isRadial && {!_isMap}) exitWith {
	[]
};

private _selectedGroups = +A3C_SELECTED_HC_GROUPS_SETTINGS;
private _cfgVehicles = configFile >> "CfgVehicles";
private _cfgWeapons = configFile >> "CfgWeapons";
private _cfgMagazines = configFile >> "CfgMagazines";
private _cfgAmmo = configFile >> "CfgAmmo";

/*
	Reset action-specific execution data. These arrays are populated while
	the available actions are evaluated and are consumed when an action is
	later executed.
*/
A3C_REMFIRE_MAGTYPES = [];

A3C_HC_engineOffUnits = [];
A3C_HC_IROnUnits = [];
A3C_HC_IROffUnits = [];
A3C_HC_IR_Laser_On_Units = [];
A3C_HC_IR_Laser_Off_Units = [];
A3C_HC_LightsOnUnits = [];
A3C_HC_LightsOffUnits = [];

A3C_REMFIRE_TankShot_Units = [];
A3C_REMFIRE_UGLShot_Units = [];
A3C_REMFIRE_ATShot_Units = [];
A3C_REMFIRE_StaticShot_Units = [];

A3C_HC_DetoShot_Units = [];
A3C_HC_NearStatics = [];
A3C_STATIC_PACKS = [];

if (_selectedGroups isEqualTo []) exitWith {
	[]
};

private _actions = [];

if !(A3C_GROUP_CONVOYS isEqualTo []) then {
	_actions pushBack "CONVOY HALT";
};

if ([player, "Laserbatteries"] call BIS_fnc_hasItem) then {
	private _droneSearchName = if (
		isClass (_cfgVehicles >> "mavic_3_BLU")
	) then {
		"mavic"
	} else {
		"mavik"
	};

	private _nearObjects = player nearObjects 2;
	private _isDroneNear = _nearObjects findIf {
		_droneSearchName in toLower (typeOf _x)
	} >= 0;

	if (_isDroneNear) then {
		_actions pushBack "CHARGE_MAVIC";
	};
};

private _allSelectedGroupVehicles = [];
private _selectionContainsGroupWithoutDrivenVehicle = false;

{
	private _groupDrivenVehicles = [
		_x
	] call A3C_main_fnc_getGroupDrivenVehicles;

	if (_groupDrivenVehicles isEqualTo []) then {
		_selectionContainsGroupWithoutDrivenVehicle = true;
	};

	{
		_allSelectedGroupVehicles pushBackUnique _x;
	} forEach _groupDrivenVehicles;
} forEach _selectedGroups;

if (count _selectedGroups == 1) then {
	private _group = _selectedGroups select 0;
	private _groupUnits = units _group;
	private _groupLeader = leader _group;
	private _leaderVehicle = vehicle _groupLeader;
	private _leaderVehicleType = typeOf _leaderVehicle;

	if (
		_isRadial
		&& {
			_leaderVehicleType in [
				"B_T_VTOL_01_armed_F",
				"B_T_VTOL_01_armed_fixed_F"
			]
		}
	) then {
		_actions pushBack "VTOL_CANNON";
		_actions pushBack "VTOL_GATLING";

		if (
			_leaderVehicleType == "B_T_VTOL_01_armed_fixed_F"
		) then {
			_actions pushBack "VTOL_AUTOCANNON";
		};
	};

	private _plowVehicleIndex = _allSelectedGroupVehicles findIf {
		isClass (
			configOf _x
			>> "AnimationSources"
			>> "moveplow"
		)
	};

	if (_plowVehicleIndex >= 0) then {
		private _plowVehicle =
			_allSelectedGroupVehicles select _plowVehicleIndex;

		private _plowPhase =
			_plowVehicle animationSourcePhase "moveplow";

		if (_plowPhase == 0) then {
			_actions pushBack "PLOW_DEPLOY";
		} else {
			if (_plowPhase == 1) then {
				_actions pushBack "PLOW_RAISE";
			};
		};
	};

	private _hasAvailableLineCharge = _allSelectedGroupVehicles findIf {
		private _vehicle = _x;
		private _vehicleType = typeOf _vehicle;

		_vehicleType in [
			"B_APC_Tracked_01_CRV_F_Fixed",
			"B_T_APC_Tracked_01_CRV_F_Fixed"
		]
		&& {
			(
				_vehicle getVariable [
					"MCSS_MCLC_MAGCOUNT",
					4
				]
			) > 0
		}
		&& {
			!(
				_vehicle getVariable [
					"MCSS_MCLC_RELOADING",
					false
				]
			)
		}
	} >= 0;

	if (_hasAvailableLineCharge) then {
		_actions pushBack "LINE_CHARGE";
	};

	private _isInfantryOnly = _groupUnits findIf {
		!isNull objectParent _x
	} < 0;

	private _convoyGroupMatches = A3C_CONVOYGROUPS select {
		(_x param [0, grpNull]) isEqualTo _group
	};

	private _isConvoyGroup = count _convoyGroupMatches == 1;

	if (_isConvoyGroup) then {
		_actions pushBack "CONVOY_REJOIN";
	};

	if (isMultiplayer && {!isServer}) then {
		_actions pushBack "OWNERSHIP";
	};

	if (
		_group getVariable [
			"A3C_MEDICS_ACTIVE",
			[]
		] isEqualTo []
	) then {
		private _healersAvailable = [
			_groupUnits
		] call A3C_ai_shared_fnc_medical_findMedics;

		private _patients = [
			_group
		] call A3C_ai_shared_fnc_medical_findPatients;

		if (
			_healersAvailable isNotEqualTo []
			&& {_patients isNotEqualTo []}
		) then {
			_actions pushBack "HEAL";
		};
	};

	if (
		_isInfantryOnly
		&& {
			[_group] call A3C_ai_highCommand_fnc_reArmRequest
		}
	) then {
		_actions pushBack "RE-ARM";
	};

	if (!_isConvoyGroup && {_isMap}) then {
		_actions pushBack "JOIN GROUP";
	};

	if (
		_leaderVehicle isKindOf "CAR"
		|| {_leaderVehicle isKindOf "TANK"}
	) then {
		_actions pushBack "SPEEDLIMIT";
	};

	if (A3C_ALLOW_HCrEFRESH) then {
		_actions pushBackUnique "REFRESH_HC_GROUP";
	};

	if (
		_isRadial
		&& {
			"ArmaFPV_Data" in configSourceAddonList (
				_cfgVehicles >> _leaderVehicleType
			)
		}
	) then {
		private _currentWaypoint = [
			_group,
			currentWaypoint _group
		];

		if !(
			"uav_fpv" in toLower (waypointScript _currentWaypoint)
		) then {
			_actions pushBackUnique "UAV_FPV";
		};
	};

	if (_leaderVehicle isKindOf "AIR") then {
		private _isRotor = getNumber (
			_cfgVehicles
			>> _leaderVehicleType
			>> "landingSpeed"
		) < 10;

		private _leaderVehicleCrew = crew _leaderVehicle;
		private _vehicleCargo = getVehicleCargo _leaderVehicle;
		private _isAirborne = (
			getPosATL _leaderVehicle select 2
		) > 1;

		private _paradropActive = _leaderVehicle getVariable [
			"A3C_ParadropActive",
			false
		];

		private _hasAssignedCargo = _leaderVehicleCrew findIf {
			(
				assignedVehicleRole _x
			) param [0, ""] == "cargo"
		} >= 0;

		if (_isAirborne && {!_paradropActive}) then {
			if (
				_hasAssignedCargo
				|| {_vehicleCargo isNotEqualTo []}
			) then {
				_actions pushBackUnique "PARADROP";

				if (A3C_IsRappel && {_isRotor}) then {
					private _hasExternalCargoGroup = _leaderVehicleCrew findIf {
						group _x != _group
					} >= 0;

					if (
						isPlayer _groupLeader
						|| {_hasExternalCargoGroup}
					) then {
						_actions pushBackUnique "RAPPEL";
					};
				};
			};
		} else {
			private _nearCargoLoadObjects = [
				_leaderVehicle
			] call A3C_main_fnc_getNearCargoLoadObjects;

			if (
				_nearCargoLoadObjects isNotEqualTo []
				|| {_vehicleCargo isNotEqualTo []}
			) then {
				_actions pushBackUnique "PARALOAD";
			};

			

			if ((getPosATL _leaderVehicle) select 2 < 1) then {
				private _vehicleCargo = getVehicleCargo _leaderVehicle;
				if (_vehicleCargo isNotEqualTo []) then {
					_actions pushBackUnique "UNLOADVEHICLECARGO";
				};
			};

			



			if (
				_isRadial
				&& {A3C_israppel}
				&& {_isRotor}
				&& {_hasAssignedCargo}
			) then {
				_actions pushBackUnique "RAPPEL";
			};
		};

		if (
			!_isRotor
			&& {_leaderVehicle isKindOf "PLANE"}
		) then {
			private _casModes = [
				_leaderVehicleType
			] call A3C_main_fnc_getCASmodes;

			if (_casModes isNotEqualTo [] && {_isRadial}) then {
				_actions pushBackUnique "CAS-STRIKE";
			};
		};
	} else {
		if (
			(
				_leaderVehicle isKindOf "TANK"
				|| {_leaderVehicle isKindOf "CAR"}
			)
			&& {canMove _leaderVehicle}
		) then {
			_actions pushBackUnique "VEHICLE-REMOTE";
		};

		if (_isRadial) then {
			if (
				_groupUnits findIf {
					[_x] call A3C_main_fnc_canRepair
				} >= 0
			) then {
				_actions pushBackUnique "REPAIR";
			};

			private _testedUnits = _groupUnits select {
				isNull objectParent _x
			};

			if (count _groupUnits > 1) then {
				A3C_STATIC_PACKS = [
					_testedUnits,
					"PLANNING"
				] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;

				if (A3C_STATIC_PACKS isNotEqualTo []) then {
					_actions pushBackUnique "STATIC_ASSEMBLE_HC";
				};
			};

			private _allExplosiveTypes = [];

			{
				_allExplosiveTypes append (
					[_x] call A3C_ai_shared_fnc_getExplosiveUnitMagazines
				);
			} forEach _testedUnits;

			A3C_REMFIRE_MAGTYPES =
				_allExplosiveTypes arrayIntersect _allExplosiveTypes;

			A3C_HC_DetoShot_Units = [
				_groupUnits
			] call A3C_ai_shared_fnc_getUnitsWithExplosives;
		};
	};

	/*
		Actions available only to AI-controlled groups.
	*/
	if (!isPlayer _groupLeader) then {
		if !(_leaderVehicle isKindOf "AIR") then {
			if (count _groupUnits > 1) then {
				private _hasCrewedStaticWeapon = _groupUnits findIf {
					private _vehicle = vehicle _x;

					_x == gunner _vehicle
					&& {_vehicle isKindOf "StaticWeapon"}
					&& {typeOf _vehicle != "A3C_Supression_Target_F"}
				} >= 0;

				if (_hasCrewedStaticWeapon) then {
					_actions pushBackUnique "STATIC_DISASSEMBLE_HC";
				} else {
					A3C_HC_NearStatics = (
						position _groupLeader
					) nearObjects [
						"StaticWeapon",
						50
					];

					A3C_HC_NearStatics = A3C_HC_NearStatics select {
						(crew _x) isEqualTo []
						&& {typeOf _x != "A3C_Supression_Target_F"}
						&& {
							[
								_groupUnits,
								_x,
								true
							] call A3C_ai_highCommand_fnc_canSelectionPickUpStatic
						}
					};

					if (A3C_HC_NearStatics isNotEqualTo []) then {
						_actions pushBackUnique "STATIC_DISASSEMBLE_HC";
					};
				};
			};
		} else {
			_actions pushBackUnique "FLYINGHEIGHT";
		};
	};

	private _hasAirborneAircraft = _selectedGroups findIf {
		private _vehicle = vehicle leader _x;

		_vehicle isKindOf "AIR"
		&& {
			(getPosATL _vehicle select 2) > 2
		}
	} >= 0;

	private _hasShip = _selectedGroups findIf {
		(vehicle (leader _x)) isKindOf "SHIP"
	} >= 0;

	if (!_hasAirborneAircraft && {!_hasShip}) then {
		_actions pushBackUnique "UNSTUCK";
	};
};

if (
	_allSelectedGroupVehicles isNotEqualTo []
	&& {sunOrMoon < 1}
	&& {
		_allSelectedGroupVehicles findIf {
			_x isKindOf "AIR"
		} < 0
	}
) then {
	if (
		_allSelectedGroupVehicles findIf {
			_x getVariable [
				"A3C_VehicleLights",
				0
			] == 1
		} >= 0
	) then {
		_actions pushBackUnique "VEHICLE_LIGHTS_ON";
	} else {
		_actions pushBackUnique "VEHICLE_LIGHTS_OFF";
	};
};

_actions pushBackUnique "DELETEGROUP";

if (
	_selectedGroups findIf {
		unitIsUAV (vehicle (leader _x))
	} < 0
) then {
	_actions pushBack "VEHICLE";
};

private _fnc_canReboardGroup = {
	params ["_group"];

	private _groupUnits = units _group;
	private _hasAssignedUnit = _groupUnits findIf {
		!isNull (assignedVehicle _x)
	} >= 0;

	if (_hasAssignedUnit) exitWith {
		false
	};

	private _assignedGroupVehicle = _group getVariable [
		"A3C_AssignedGroupVehicle",
		objNull
	];

	!isNull _assignedGroupVehicle
	&& {alive _assignedGroupVehicle}
};

{
	if ([_x] call _fnc_canReboardGroup) then {
		_actions pushBackUnique "VEHICLE_REBOARD";
	};

	if ([_x] call A3C_ai_highCommand_fnc_getArtilleryCapacity) then {
		_actions pushBackUnique "ARTY";
	};

	if (
		"VEHICLE_REBOARD" in _actions
		&& {"ARTY" in _actions}
	) exitWith {};
} forEach _selectedGroups;

private _vehicleSmokeAvailable = false;

{
	private _groupDrivers = units _x select {
		private _parentVehicle = objectParent _x;

		!isNull _parentVehicle
		&& {_x == driver _parentVehicle}
	};

	private _groupVehicles = _groupDrivers apply {
		objectParent _x
	};

	{
		if (
			[_x, 0] call A3C_ai_shared_fnc_fireCounterMeasures
		) exitWith {
			_vehicleSmokeAvailable = true;
		};
	} forEach _groupVehicles;

	if (_vehicleSmokeAvailable) exitWith {};
} forEach _selectedGroups;

if (_vehicleSmokeAvailable) then {
	_actions pushBack "VEHICLESMOKE";
};

private _suppressionCondition =
	count _selectedGroups <= 5
	&& {
		_selectedGroups findIf {
			(units _x) findIf {
				private _vehicle = vehicle _x;

				_x == gunner _vehicle
				&& {getArtilleryAmmo [_vehicle] isEqualTo []}
				&& {!(_vehicle isKindOf "PLANE")}
			} >= 0
		} >= 0
	};

if (
	_isRadial
	&& {
		_selectedGroups findIf {
			private _leaderVehicle = vehicle leader _x;

			_leaderVehicle isKindOf "AIR"
			&& {
				!(
					_leaderVehicle getVariable [
						"A3C_ParadropActive",
						false
					]
				)
			}
		} >= 0
	}
) then {
	_actions pushBackUnique "LANDING_PRECISION";
};

if (_suppressionCondition) then {
	_actions pushBackUnique "SUPPRESSION";

	private _hasSuppressingUnits = _selectedGroups findIf {
		(units _x) findIf {
			_x in A3C_SUPPRESSION_UNITS_AI
		} >= 0
	} >= 0;

	if (_hasSuppressingUnits) then {
		_actions pushBackUnique "SUPPRESSION_STOP";
	};
};

if (_isRadial) then {
	private _highCommandUnits = (
		units group player
	) - [player];

	{
		{
			_highCommandUnits pushBackUnique _x;
		} forEach units _x;
	} forEach A3C_HC_allGroupsClient_Current;

	if (
		_highCommandUnits findIf {
			_x getVariable [
				"A3C_UNIT_EXPLOSIVES",
				[]
			] isNotEqualTo []
		} >= 0
	) then {
		_actions pushBackUnique "ORDER_DETO";
	};
};

private _selectionContainsConvoyGroup = A3C_CONVOYGROUPS findIf {
	(_x param [0, grpNull]) in _selectedGroups
} >= 0;

if (!_selectionContainsConvoyGroup) then {
	_actions pushBack "JOINPLAYER";

	if (count _selectedGroups > 1) then {
		private _selectionContainsAircraft = _selectedGroups findIf {
			(units _x) findIf {
				vehicle _x isKindOf "AIR" //-- exclude Aircraft-group presence
			} >= 0
		} >= 0;

		if (
			!_selectionContainsAircraft
			&& {!_selectionContainsGroupWithoutDrivenVehicle}
		) then {
			_actions pushBack "CONVOY_CREATE";
		};
	};
};

/*
	The original action-count gate is preserved. It limits the expensive
	attachment, remote-fire, strobe, and engine-state analysis.
*/
if (count _actions < 13) then {
	private _supportedEngineOffFactions = [
		"BLU_F",
		"BLU_T",
		"BLU_W",
		"IND_F",
		"OPF_F",
		"OPF_T",
		"OPF_V",
		"rhs_faction_us"
	];

	private _irMarkerMagazineCache = createHashMap;
	private _weaponSoundCache = createHashMap;

	private _fnc_magazineHasNvgMarker = {
		params ["_magazineClass"];

		private _cached = _irMarkerMagazineCache getOrDefault [
			_magazineClass,
			-1
		];

		if (_cached isEqualType true) exitWith {
			_cached
		};

		private _ammoClass = getText (
			_cfgMagazines
			>> _magazineClass
			>> "ammo"
		);

		private _hasMarker = (
			"true" configClasses (
				_cfgAmmo
				>> _ammoClass
				>> "NVGMarkers"
			)
		) isNotEqualTo [];

		_irMarkerMagazineCache set [
			_magazineClass,
			_hasMarker
		];

		_hasMarker
	};

	private _fnc_getWeaponSound = {
		params ["_weaponClass"];

		private _cached = _weaponSoundCache getOrDefault [
			_weaponClass,
			-1
		];

		if (_cached isEqualType "") exitWith {
			_cached
		};

		private _weaponSound = toLower (getText (
			_cfgWeapons
			>> _weaponClass
			>> "nameSound"
		));

		_weaponSoundCache set [
			_weaponClass,
			_weaponSound
		];

		_weaponSound
	};

	{
		private _group = _x;
		private _groupUnits = units _group;
		private _addGroupToIrStrobe = true;
		private _addGroupToEngineOff = false;

		{
			private _unit = _x;
			private _vehicle = vehicle _unit;

			if (
				_unit getVariable [
					"A3C_STROBE",
					[]
				] isNotEqualTo []
			) then {
				_addGroupToIrStrobe = false;
			};

			private _unitFaction = faction _unit;
			private _supportsEngineOff = _supportedEngineOffFactions findIf {
				[_x, _unitFaction] call BIS_fnc_inString
			} >= 0;

			if (
				_supportsEngineOff
				&& {!isNull objectParent _unit}
				&& {speed _vehicle < 0.1}
				&& {speed _vehicle > -0.1}
				&& {_unit == driver _vehicle}
				&& {isEngineOn _vehicle}
				&& {
					!(
						_vehicle isKindOf "AIR"
						&& {
							(getPosATL _vehicle select 2) > 2
						}
					)
				}
			) then {
				_addGroupToEngineOff = true;
			};
		} forEach _groupUnits;

		if (_addGroupToIrStrobe) then {
			private _hasIrMarkerMagazine = _groupUnits findIf {
				private _unit = _x;

				(magazines _unit) findIf {
					[_x] call _fnc_magazineHasNvgMarker
				} >= 0
			} >= 0;

			if (_hasIrMarkerMagazine) then {
				A3C_HC_IROnUnits pushBackUnique _group;
			};
		} else {
			A3C_HC_IROffUnits pushBackUnique _group;
		};

		if (_addGroupToEngineOff) then {
			A3C_HC_engineOffUnits pushBackUnique _group;
		};

		private _groupHasPointer = _groupUnits findIf {
			[_x, "LASER"] call A3C_main_fnc_hasWeaponItem
		} >= 0;

		if (_groupHasPointer) then {
			private _groupLaserIsOn = _groupUnits findIf {
				_x isIRLaserOn currentWeapon _x
			} >= 0;

			if (_groupLaserIsOn) then {
				A3C_HC_IR_Laser_Off_Units pushBackUnique _group;
			} else {
				A3C_HC_IR_Laser_On_Units pushBackUnique _group;
			};
		};

		private _groupHasFlashlight = _groupUnits findIf {
			[_x, "FLASHLIGHT"] call A3C_main_fnc_hasWeaponItem
		} >= 0;

		if (_groupHasFlashlight) then {
			private _groupFlashlightIsOn = _groupUnits findIf {
				_x isFlashlightOn currentWeapon _x
			} >= 0;

			if (_groupFlashlightIsOn) then {
				A3C_HC_LightsOffUnits pushBackUnique _group;
			} else {
				A3C_HC_LightsOnUnits pushBackUnique _group;
			};
		};

		if (_isRadial) then {
			{
				private _unit = _x;
				private _vehicle = vehicle _unit;

				if (_unit == gunner _vehicle) then {
					if (isNull objectParent _unit) then {
						if ([_unit] call A3C_main_fnc_unitHasAT) then {
							A3C_REMFIRE_ATShot_Units pushBackUnique _unit;
						};

						if ([_unit] call A3C_main_fnc_unitHasUGL) then {
							A3C_REMFIRE_UGLShot_Units pushBackUnique _unit;
						};
					} else {
						if (
							[_vehicle] call A3C_main_fnc_isStaticMissileLauncher
						) then {
							A3C_REMFIRE_StaticShot_Units pushBackUnique _unit;
						} else {
							if (
								(getArtilleryAmmo [_vehicle]) isEqualTo []
								&& {_vehicle isKindOf "LAND"}
							) then {
								private _isCannonVehicle = false;
								private _isMissileVehicle = false;

								{
									private _weaponSound = [
										_x
									] call _fnc_getWeaponSound;

									if ("cannon" in _weaponSound) then {
										_isCannonVehicle = true;
									} else {
										if (
											"missile" in _weaponSound
											|| {"rocket" in _weaponSound}
										) exitWith {
											_isMissileVehicle = true;
										};
									};
								} forEach (weapons _vehicle);

								if (_isCannonVehicle) then {
									A3C_REMFIRE_TankShot_Units pushBackUnique _unit;
								} else {
									if (_isMissileVehicle) then {
										A3C_REMFIRE_StaticShot_Units pushBackUnique _unit;
									};
								};
							};
						};
					};
				};
			} forEach _groupUnits;
		};
	} forEach _selectedGroups;

	if (A3C_HC_DetoShot_Units isNotEqualTo []) then {
		_actions pushBackUnique "PLACE_CHARGE_HC";
	};

	if (A3C_REMFIRE_TankShot_Units isNotEqualTo []) then {
		_actions pushBackUnique "TANKSHOT";
	};

	if (A3C_REMFIRE_StaticShot_Units isNotEqualTo []) then {
		_actions pushBackUnique "STATICSHOT";
	};

	if (A3C_REMFIRE_ATShot_Units isNotEqualTo []) then {
		_actions pushBackUnique "ATSHOT";
	};

	if (A3C_REMFIRE_UGLShot_Units isNotEqualTo []) then {
		_actions pushBackUnique "UGLSHOT";
	};

	if (A3C_HC_engineOffUnits isNotEqualTo []) then {
		_actions pushBackUnique "ENGINE_OFF";
	};

	A3C_HC_IROnUnits = A3C_HC_IROnUnits - A3C_HC_IROffUnits;

	if (A3C_HC_IROffUnits isNotEqualTo []) then {
		_actions pushBackUnique "IR_OFF";
		A3C_HC_IROnUnits = [];
	};

	if (A3C_HC_IROnUnits isNotEqualTo []) then {
		_actions pushBackUnique "IR_ON";
	};

	if (A3C_HC_IR_Laser_Off_Units isNotEqualTo []) then {
		_actions pushBackUnique "IR_POINTER_OFF";
		A3C_HC_IR_Laser_On_Units = [];
	};

	if (A3C_HC_IR_Laser_On_Units isNotEqualTo []) then {
		_actions pushBackUnique "IR_POINTER_ON";
	};

	if (A3C_HC_LightsOffUnits isNotEqualTo []) then {
		_actions pushBackUnique "FLASHLIGHT_OFF";
		A3C_HC_LightsOnUnits = [];
	};

	if (A3C_HC_LightsOnUnits isNotEqualTo []) then {
		_actions pushBackUnique "FLASHLIGHT_ON";
	};
};

private _actionPriority = [
	"UAV_FPV",
	"CONVOY HALT",
	"CHARGE_MAVIC",
	"VEHICLE",
	"VEHICLE_REBOARD",
	"VEHICLE-REMOTE",
	"SUPPRESSION",
	"SUPPRESSION_STOP",
	"CAS-STRIKE",
	"LANDING_PRECISION",
	"PARADROP",
	"RAPPEL",
	"PARALOAD",
	"UNLOADVEHICLECARGO",
	"FLYINGHEIGHT",
	"REPAIR",
	"ATSHOT",
	"UGLSHOT",
	"STATICSHOT",
	"ARTY",
	"PLOW_DEPLOY",
	"PLOW_RAISE",
	"LINE_CHARGE",
	"TANKSHOT",
	"VTOL_CANNON",
	"VTOL_GATLING",
	"VTOL_AUTOCANNON",
	"VEHICLESMOKE",
	"PLACE_CHARGE_HC",
	"ORDER_DETO",
	"STATIC_ASSEMBLE_HC",
	"STATIC_DISASSEMBLE_HC",
	"IR_OFF",
	"IR_ON",
	"IR_POINTER_OFF",
	"IR_POINTER_ON",
	"FLASHLIGHT_OFF",
	"FLASHLIGHT_ON",
	"ENGINE_OFF",
	"VEHICLE_LIGHTS_ON",
	"VEHICLE_LIGHTS_OFF",
	"SPEEDLIMIT",
	"CONVOY_REJOIN",
	"CONVOY_CREATE",
	"HEAL",
	"RE-ARM",
	// "JOINPLAYER", //-- currently not used but kept around
	"JOIN GROUP",
	"UNSTUCK",
	"REFRESH_HC_GROUP",
	"OWNERSHIP",
	"DELETEGROUP"
];

private _sortedActions = _actionPriority select {
	_x in _actions
};

if (
	_selectedGroups findIf {
		isPlayer leader _x
	} >= 0
) then {
	[] spawn {
		hint "A3C: Player Group(s) detected. No actions allowed.";
		sleep 2;
		hintSilent "";
	};

	_sortedActions = [];
};

_sortedActions

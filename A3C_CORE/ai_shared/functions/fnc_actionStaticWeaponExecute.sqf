//-- Action to assemble or disassemble static weapons.
//-- Used by HC actions, waypoint actions, squad actions, and squad waypoint actions.

// A3C_ai_shared_fnc_actionStaticWeaponExecute

params ["_units", "_staticData", "_weaponPos", "_weaponDir"];

private _action = _staticData select 0;

private _fnc_playStaticWeaponWorkAnimation = {
	params ["_unit", "_finishedMove"];

	[_unit, _finishedMove] spawn {
		params ["_unit", "_finishedMove"];

		[_unit, "ainvpknlmstpslaywrfldnon_medic"] remoteExec ["playMove", _unit];

		sleep 7;

		if (animationState _unit == "ainvpknlmstpslaywrfldnon_medic") then {
			[_unit, _finishedMove] remoteExec ["playMove", _unit];
		};
	};
};

private _fnc_addBackpackWithMagazineState = {
	params ["_unit", "_backpackClass", "_backpackMagazineState"];

	[
		[_unit, _backpackClass, _backpackMagazineState],
		{
			params ["_unit", "_backpackClass", "_backpackMagazineState"];

			_unit addBackpack _backpackClass;

			if ((backpack _unit) == _backpackClass) then {
				(unitBackpack _unit) setVariable [
					"A3C_STATIC_MAGAZINE_STATE",
					_backpackMagazineState,
					true
				];
			};
		}
	] remoteExec ["bis_fnc_call", _unit];
};

private _aceCSWStoreDistance = 10;

private _fnc_getACECSWCarryMappings = {
	params ["_static"];

	if (isNull _static) exitWith {[]};

	private _vehicleMags = [];
	private _turretPaths = [[-1]] + ([typeOf _static, true] call BIS_fnc_allTurrets);

	{
		private _turretPath = _x;

		{
			_vehicleMags append ([_x, true] call CBA_fnc_compatibleMagazines);
		} forEach (_static weaponsTurret _turretPath);

	} forEach _turretPaths;

	_vehicleMags = _vehicleMags arrayIntersect _vehicleMags;

	private _mappings = [];

	{
		private _groupCfg = _x;

		private _groupMembers = (
			configProperties [
				_groupCfg,
				"isNumber _x && {getNumber _x > 0}",
				true
			]
		) apply {
			configName _x
		};

		private _matches = _groupMembers arrayIntersect _vehicleMags;

		if (_matches isNotEqualTo []) then {
			_mappings pushBack [
				configName _groupCfg,
				_matches
			];
		};

	} forEach (
		"true" configClasses (
			configFile >> "ACE_CSW_Groups"
		)
	);

	_mappings
};

private _fnc_getACECSWStoreClass = {
	switch (
		missionNamespace getVariable [
			"ace_csw_handleExtraMagazinesType",
			-1
		]
	) do {
		case 0: {
			"GroundWeaponHolder"
		};

		case 1: {
			"ace_csw_ammo_holder"
		};

		default {
			""
		};
	};
};

private _fnc_isEffectiveACECSW = {
	params ["_static"];

	if (isNull _static) exitWith {false};

	private _aceCfg = configOf _static >> "ACE_CSW";

	if (
		!isClass _aceCfg
		|| {getNumber (_aceCfg >> "enabled") != 1}
	) exitWith {
		false
	};

	private _modeIndex = _static getVariable [
		"ace_csw_assemblyMode",
		3
	];

	private _defaultMode = missionNamespace getVariable [
		"ace_csw_defaultAssemblyMode",
		false
	];

	[
		false,
		true,
		true,
		_defaultMode
	] param [
		_modeIndex,
		false
	]
};

private _fnc_findACECSWStore = {
	params ["_static"];

	if (isNull _static) exitWith {objNull};

	if !(
		missionNamespace getVariable [
			"ace_csw_handleExtraMagazines",
			false
		]
	) exitWith {
		objNull
	};

	private _storeClass = call _fnc_getACECSWStoreClass;

	if (_storeClass == "") exitWith {
		objNull
	};

	private _fnc_validStore = {
		params ["_store"];

		!isNull _store
		&& {_store isKindOf _storeClass}
		&& {_store distance _static <= _aceCSWStoreDistance}
	};

	private _cachedStore = _static getVariable [
		"ace_csw_container",
		objNull
	];

	if ([_cachedStore] call _fnc_validStore) exitWith {
		_cachedStore
	};

	private _bestStore = objNull;
	private _bestDistance = 1e10;

	{
		private _candidateStore = _x getVariable [
			"ace_csw_container",
			objNull
		];

		if (
			[_candidateStore] call _fnc_validStore
			&& {_candidateStore distance _static < _bestDistance}
		) then {
			_bestStore = _candidateStore;
			_bestDistance = _candidateStore distance _static;
		};

	} forEach (
		nearestObjects [
			_static,
			["StaticWeapon"],
			_aceCSWStoreDistance
		]
	);

	if (!isNull _bestStore) exitWith {
		_bestStore
	};

	private _stores = nearestObjects [
		_static,
		[_storeClass],
		_aceCSWStoreDistance
	];

	{
		if (
			_x getVariable [
				"A3C_ACE_CSW_STORE",
				false
			]
		) then {
			private _distance = _x distance _static;

			if (_distance < _bestDistance) then {
				_bestStore = _x;
				_bestDistance = _distance;
			};
		};

	} forEach _stores;

	if (!isNull _bestStore) exitWith {
		_bestStore
	};

	private _carryMagazineClasses = (
		[
			_static
		] call _fnc_getACECSWCarryMappings
	) apply {
		_x select 0
	};

	_carryMagazineClasses =
		_carryMagazineClasses arrayIntersect _carryMagazineClasses;

	{
		private _cargoClasses = (
			getMagazineCargo _x
		) select 0;

		if (
			(
				_cargoClasses arrayIntersect _carryMagazineClasses
			) isNotEqualTo []
		) then {
			private _distance = _x distance _static;

			if (_distance < _bestDistance) then {
				_bestStore = _x;
				_bestDistance = _distance;
			};
		};

	} forEach _stores;

	_bestStore
};

private _fnc_createACECSWStore = {
	params ["_static"];

	private _storeClass = call _fnc_getACECSWStoreClass;

	if (_storeClass == "") exitWith {
		objNull
	};

	private _storePos = _static getPos [
		1.5,
		(getDir _static) + 180
	];

	_storePos set [2, 0];

	private _store = _storeClass createVehicle _storePos;

	_store setPosATL _storePos;

	_store setVariable [
		"A3C_ACE_CSW_STORE",
		true,
		true
	];

	_store
};

private _fnc_mergeMagazineCounts = {
	params [
		"_array",
		"_magazineClass",
		"_count"
	];

	if (_count <= 0) exitWith {
		_array
	};

	private _index = _array findIf {
		(_x select 0) == _magazineClass
	};

	if (_index == -1) then {
		_array pushBack [
			_magazineClass,
			_count
		];
	} else {
		private _data = _array select _index;

		_data set [
			1,
			(_data select 1) + _count
		];
	};

	_array
};

private _fnc_countACECSWStoreUsers = {
	params [
		"_store",
		"_carryMagazine"
	];

	if (isNull _store) exitWith {
		1
	};

	private _count = 0;

	private _nearStatics = nearestObjects [
		_store,
		["StaticWeapon"],
		_aceCSWStoreDistance
	];

	{
		private _candidate = _x;

		if ([_candidate] call _fnc_isEffectiveACECSW) then {
			private _candidateStore = [
				_candidate
			] call _fnc_findACECSWStore;

			if (_candidateStore isEqualTo _store) then {
				private _candidateCarryMags = (
					[
						_candidate
					] call _fnc_getACECSWCarryMappings
				) apply {
					_x select 0
				};

				if (_carryMagazine in _candidateCarryMags) then {
					_count = _count + 1;
				};
			};
		};

	} forEach _nearStatics;

	_count max 1
};

private _fnc_collectACECSWGroupAmmo = {
	params [
		"_static",
		"_group"
	];

	if (
		isNull _static
		|| {isNull _group}
		|| {
			!(
				missionNamespace getVariable [
					"ace_csw_handleExtraMagazines",
					false
				]
			)
		}
	) exitWith {
		objNull
	};

	private _carryMagazineClasses = (
		[
			_static
		] call _fnc_getACECSWCarryMappings
	) apply {
		_x select 0
	};

	_carryMagazineClasses =
		_carryMagazineClasses arrayIntersect _carryMagazineClasses;

	if (_carryMagazineClasses isEqualTo []) exitWith {
		objNull
	};

	private _transferPlan = [];

	{
		private _unit = _x;

		if (
			alive _unit
			&& {!isPlayer _unit}
		) then {
			{
				private _container = _x;

				if (!isNull _container) then {
					private _containerMagazines = magazinesAmmoCargo _container;

					{
						private _carryMagazine = _x;

						private _matchingMagazines = _containerMagazines select {
							(_x select 0) == _carryMagazine
						};

						if (_matchingMagazines isNotEqualTo []) then {
							private _fullAmmoCount = getNumber (
								configFile
								>> "CfgMagazines"
								>> _carryMagazine
								>> "count"
							);

							if (
								_fullAmmoCount > 0
								&& {
									{
										(_x select 1) != _fullAmmoCount
									} count _matchingMagazines == 0
								}
							) then {
								_transferPlan pushBack [
									_container,
									_carryMagazine,
									count _matchingMagazines
								];
							};
						};

					} forEach _carryMagazineClasses;
				};

			} forEach [
				uniformContainer _unit,
				vestContainer _unit,
				backpackContainer _unit
			];
		};

	} forEach units _group;

	if (_transferPlan isEqualTo []) exitWith {
		objNull
	};

	private _store = [
		_static
	] call _fnc_findACECSWStore;

	if (isNull _store) then {
		_store = [
			_static
		] call _fnc_createACECSWStore;
	};

	if (isNull _store) exitWith {
		objNull
	};

	{
		_x params [
			"_container",
			"_magazineClass",
			"_plannedCount"
		];

		private _beforeCount = {
			(_x select 0) == _magazineClass
		} count magazinesAmmoCargo _container;

		private _amountToRemove = _plannedCount min _beforeCount;

		if (_amountToRemove > 0) then {
			_container addMagazineCargoGlobal [
				_magazineClass,
				-_amountToRemove
			];

			private _afterCount = {
				(_x select 0) == _magazineClass
			} count magazinesAmmoCargo _container;

			private _removedCount = (
				_beforeCount - _afterCount
			) max 0;

			if (_removedCount > 0) then {
				_store addMagazineCargoGlobal [
					_magazineClass,
					_removedCount
				];
			};
		};

	} forEach _transferPlan;

	_static setVariable [
		"ace_csw_container",
		_store,
		true
	];

	_store
};

if (_action == "ASSEMBLE") then {
	private _requestedStaticClass = _staticData select 1;

	{
		[[_x], A3C_ai_shared_fnc_unitGetOut] remoteExec ["bis_fnc_call", _x];
	} forEach _units;

	[_units, "EXECUTING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;

	{
		_x params [
			"_assemblyUnits",
			"_staticClassToCreate",
			["_assemblyProvider", "LEGACY"],
			["_assemblyComponents", []]
		];

		/*
			Legacy vanilla/SOG/IFA behavior requires two array entries.

			ACE CSW uses unique physical workers, so a unit carrying the weapon
			in its primary slot and the mount in its secondary slot requires
			only one worker.
		*/
		private _requiredWorkerCount = if (_assemblyProvider == "ACE_CSW") then {
			count _assemblyUnits
		} else {
			2
		};

		private _canAssemble = (
			_staticClassToCreate == _requestedStaticClass
			&& {_requiredWorkerCount > 0}
			&& {
				{alive _x} count _assemblyUnits == _requiredWorkerCount
			}
		);

		if (_canAssemble) exitWith {
			//-- IFA statics use weapon parts instead of backpacks.
			private _ifaAssemblyWeaponParts = getArray (
				configFile >> "CfgVehicles" >> _requestedStaticClass >> "assembleInfo" >> "LIB_dissasembleTo"
			);

			if (count _ifaAssemblyWeaponParts > 0) then {
				private _tripodWeaponClass = getText (
					configFile >> "CfgVehicles" >> (_ifaAssemblyWeaponParts select 1) >> "LIB_Equipped_Tripod_Name"
				);

				_ifaAssemblyWeaponParts set [1, _tripodWeaponClass];
			};

			private _removedBackpacks = [];
			private _removedBackpackMagazineStates = [];
			private _storedStaticMagazineState = [];
			private _storedACETransportReserve = [];
			private _hasStoredStaticMagazineState = false;
			private _removeGunnerMagazines = false;
			private _aceMagazineStateOwner = objNull;

			private _usesACECSW = _assemblyProvider == "ACE_CSW";

			private _usesIFAWeaponParts = (
				!_usesACECSW
				&& {count _ifaAssemblyWeaponParts > 0}
			);

			//-- ACE CSW components are CfgWeapons items rather than static backpacks.
			if (_usesACECSW) then {
				private _aceWeaponComponentIndex = _assemblyComponents findIf {
					(_x param [3, ""]) == "WEAPON"
				};

				private _aceMountComponentIndex = _assemblyComponents findIf {
					(_x param [3, ""]) == "MOUNT"
				};

				if (
					_aceWeaponComponentIndex >= 0
					&& {_aceMountComponentIndex >= 0}
				) then {
					private _aceWeaponComponent = (
						_assemblyComponents select _aceWeaponComponentIndex
					);

					private _aceMountComponent = (
						_assemblyComponents select _aceMountComponentIndex
					);

					private _aceWeaponUnit = _aceWeaponComponent param [
						0,
						objNull
					];

					private _acePackedWeaponClass = _aceWeaponComponent param [
						1,
						""
					];

					private _acePackedMountClass = _aceMountComponent param [
						1,
						""
					];

					if (
						!isNull _aceWeaponUnit
						&& {_acePackedWeaponClass != ""}
						&& {_acePackedMountClass != ""}
					) then {
						private _aceMagazineStateSources = [];

						/*
							The hidden ACE ammunition state belongs conceptually to the
							packed CSW components, not to a particular deployed vehicle class.

							ACE may canonicalize faction, camouflage, or other deployed
							variants when the same weapon + mount components are reassembled.

							Check all participating workers and their backpacks so that
							rearranging the weapon/mount between the workers does not lose
							the stored ammunition state.
						*/
						{
							private _aceWorkerBackpack = unitBackpack _x;

							if (!isNull _aceWorkerBackpack) then {
								_aceMagazineStateSources pushBackUnique _aceWorkerBackpack;
							};

							_aceMagazineStateSources pushBackUnique _x;

						} forEach _assemblyUnits;

						{
							private _aceStoredMagazineState = _x getVariable [
								"A3C_ACE_CSW_MAGAZINE_STATE",
								[]
							];

							if (count _aceStoredMagazineState >= 3) then {
								private _storedStaticClass =
									_aceStoredMagazineState select 0;

								private _storedPackedWeaponClass =
									_aceStoredMagazineState select 1;

								private _storedACEcfg =
									configFile
									>> "CfgVehicles"
									>> _storedStaticClass
									>> "ACE_CSW";

								private _storedMountVehicleClass =
									getText (
										_storedACEcfg
										>> "disassembleTurret"
									);

								private _storedPackedMountClass = if (
									_storedMountVehicleClass != ""
								) then {
									getText (
										configFile
										>> "CfgVehicles"
										>> _storedMountVehicleClass
										>> "ACE_CSW"
										>> "disassembleTo"
									)
								} else {
									""
								};

								if (
									_storedPackedWeaponClass
										== _acePackedWeaponClass
									&& {
										_storedPackedMountClass
											== _acePackedMountClass
									}
								) exitWith {
									_hasStoredStaticMagazineState = true;

									_storedStaticMagazineState = +(
										_aceStoredMagazineState select 2
									);

									_storedACETransportReserve = +(
										_aceStoredMagazineState param [
											3,
											[]
										]
									);

									_aceMagazineStateOwner = _x;
								};
							};

						} forEach _aceMagazineStateSources;
					};
				};
				{
					_x params [
						"_componentUnit",
						"_componentClass",
						"_componentSlot",
						"_componentRole"
					];

					if (
						!isNull _componentUnit
						&& {_componentClass != ""}
					) then {
						[
							_componentUnit,
							_componentClass
						] remoteExec [
							"removeWeapon",
							_componentUnit
						];
					};
				} forEach _assemblyComponents;
			};

			{
				private _unit = _x;

				if (!_usesACECSW) then {
					if (_usesIFAWeaponParts) then {
						private _weaponPartClass = _ifaAssemblyWeaponParts select _forEachIndex;

						if (primaryWeapon (_assemblyUnits select 0) == _weaponPartClass) then {
							_removeGunnerMagazines = true;
						};

						[_unit, _weaponPartClass] remoteExec ["removeWeapon", _unit];
					} else {
						private _backpackObject = unitBackpack _unit;

						private _backpackMagazineState = if (isNull _backpackObject) then {
							[]
						} else {
							_backpackObject getVariable [
								"A3C_STATIC_MAGAZINE_STATE",
								[]
							]
						};

						_removedBackpacks pushBack (backpack _unit);
						_removedBackpackMagazineStates pushBack _backpackMagazineState;

						if (
							!_hasStoredStaticMagazineState
							&& {count _backpackMagazineState == 2}
							&& {(_backpackMagazineState select 0) == _staticClassToCreate}
						) then {
							_hasStoredStaticMagazineState = true;
							_storedStaticMagazineState = _backpackMagazineState select 1;
						};

						[_unit] remoteExec ["removeBackpack", _unit];
					};
				};

				[_unit, "amovpknlmstpslowwrfldnon"] call _fnc_playStaticWeaponWorkAnimation;
				[_unit, position _unit] remoteExec ["doMove", _unit];

			} forEach _assemblyUnits;

			sleep 2;

			while {true} do {
				//-- Abort: restore removed equipment if one of the builders dies before completion.
				if (
					{alive _x} count _assemblyUnits != _requiredWorkerCount
				) exitWith {
					if (_usesACECSW) then {
						{
							_x params [
								"_componentUnit",
								"_componentClass",
								"_componentSlot",
								"_componentRole"
							];

							if (
								!isNull _componentUnit
								&& {_componentClass != ""}
							) then {
								[
									_componentUnit,
									_componentClass
								] remoteExec [
									"addWeapon",
									_componentUnit
								];
							};
						} forEach _assemblyComponents;
					} else {
						if (_usesIFAWeaponParts) then {
							{
								if (_forEachIndex < count _ifaAssemblyWeaponParts) then {
									private _weaponPartClass = _ifaAssemblyWeaponParts select _forEachIndex;

									if (_weaponPartClass != "") then {
										[_x, _weaponPartClass] remoteExec ["addWeapon", _x];
									};
								};
							} forEach _assemblyUnits;
						} else {
							{
								if (_forEachIndex < count _removedBackpacks) then {
									private _backpackClass = _removedBackpacks select _forEachIndex;

									if (_backpackClass != "") then {
										private _backpackMagazineState = _removedBackpackMagazineStates param [
											_forEachIndex,
											[]
										];

										if (_backpackMagazineState isEqualTo []) then {
											[_x, _backpackClass] remoteExec ["addBackpack", _x];
										} else {
											[
												_x,
												_backpackClass,
												_backpackMagazineState
											] call _fnc_addBackpackWithMagazineState;
										};
									};
								};
							} forEach _assemblyUnits;
						};
					};
				};

				//-- Assembly completed once all workers have left the work animation.
				if ({animationState _x == "ainvpknlmstpslaywrfldnon_medic"} count _assemblyUnits == 0) exitWith {
					if (_usesIFAWeaponParts && {_removeGunnerMagazines}) then {
						private _gunner = _assemblyUnits select 0;
						private _primaryMagazineTypes = getArray (
							configFile >> "CfgWeapons" >> (_ifaAssemblyWeaponParts select 0) >> "magazines"
						);

						{
							if (_x in _primaryMagazineTypes) then {
								[_gunner, _x] remoteExec ["removeMagazine", _gunner];
							};
						} forEach magazines _gunner;
					};

					_weaponPos set [2, 0];

					private _terrainVectors = [_weaponPos, _weaponDir] call MCSS_fnc_getTerrainTilt;
					private _createdStatic = _staticClassToCreate createVehicle _weaponPos;

					/*
						ACE CSWs assembled by A3C must use assembly mode 2.

						This tells ACE that the weapon was created as the result of assembly,
						so any default ammunition supplied by createVehicle is removed without
						being turned into free external CSW ammunition.
					*/
					if (_usesACECSW) then {
						_createdStatic setVariable [
							"ace_csw_assemblyMode",
							2,
							true
						];
					};

					/*
						Legacy backpack-based statics restore their saved ammunition immediately.

						ACE CSWs are left empty here. Their legitimate saved ammunition is restored
						only after ACE has initialized the newly-created static.
					*/
					if (_usesACECSW) then {
						_createdStatic removeAllMagazinesTurret [];
					} else {
						if (_hasStoredStaticMagazineState) then {
							_createdStatic removeAllMagazinesTurret [];

							{
								_x params [
									"_magazineClass",
									"_turretPath",
									"_ammoCount"
								];

								_createdStatic addMagazineTurret [
									_magazineClass,
									_turretPath,
									_ammoCount
								];

							} forEach _storedStaticMagazineState;
						};
					};

					[_createdStatic, ATLToASL _weaponPos] remoteExec ["setPosASL", _createdStatic];
					[_createdStatic, _terrainVectors] remoteExec ["setVectorDirAndUp", _createdStatic];

					sleep 0.1;

					//-- Final surface alignment; this may partially override setVectorDirAndUp.
					_createdStatic setVectorUp (surfaceNormal _weaponPos);

					private _centerMass = getCenterOfMass _createdStatic;

					_createdStatic enableSimulationGlobal false;

					sleep 1.5;

					_createdStatic enableSimulationGlobal true;

					/*
						ACE initializes new static weapons after simulation becomes available.

						Mode 2 makes ACE discard the createVehicle ammunition first. Afterwards,
						restore only the exact ammunition that A3C preserved during disassembly.

						ACE fixed-firing-pin weapons can fire immediately when a magazine is
						loaded. Temporarily suppress ACE autofire while A3C restores state, then
						restore ACE's resolved autofire state.
					*/
					private _aceAutofireRestoreState = false;
					private _aceAutofireSuppressed = false;

					if (_usesACECSW) then {
						sleep 0.2;

						if (_hasStoredStaticMagazineState) then {
							_aceAutofireRestoreState = _createdStatic getVariable [
								"ace_csw_autofire",
								false
							];

							_aceAutofireSuppressed = _aceAutofireRestoreState;

							if (_aceAutofireSuppressed) then {
								_createdStatic setVariable [
									"ace_csw_autofire",
									false,
									true
								];
							};

							_createdStatic removeAllMagazinesTurret [];

							{
								_x params [
									"_magazineClass",
									"_turretPath",
									"_ammoCount"
								];

								_createdStatic addMagazineTurret [
									_magazineClass,
									_turretPath,
									_ammoCount
								];

							} forEach _storedStaticMagazineState;
						};
					};

					private _aceSaveExtraMagazines = missionNamespace getVariable [
						"ace_csw_handleExtraMagazines",
						false
					];

					private _aceTransportReserveRestored = (
						_storedACETransportReserve isEqualTo []
						|| {!_aceSaveExtraMagazines}
					);

					if (
						_usesACECSW
						&& {_storedACETransportReserve isNotEqualTo []}
						&& {_aceSaveExtraMagazines}
					) then {
						private _aceStore = [
							_createdStatic
						] call _fnc_findACECSWStore;

						if (isNull _aceStore) then {
							_aceStore = [
								_createdStatic
							] call _fnc_createACECSWStore;
						};

						if (!isNull _aceStore) then {
							{
								_x params [
									"_magazineClass",
									"_magazineCount"
								];

								if (_magazineCount > 0) then {
									_aceStore addMagazineCargoGlobal [
										_magazineClass,
										_magazineCount
									];
								};

							} forEach _storedACETransportReserve;

							_createdStatic setVariable [
								"ace_csw_container",
								_aceStore,
								true
							];

							_aceTransportReserveRestored = true;
						};
					};

					if (
						_usesACECSW
						&& {
							missionNamespace getVariable [
								"ace_csw_handleExtraMagazines",
								false
							]
						}
					) then {
						[
							_createdStatic,
							group (_assemblyUnits select 0)
						] call _fnc_collectACECSWGroupAmmo;
					};

					//-- Stored ACE ammunition has now been restored successfully.
					if (
						_usesACECSW
						&& {!isNull _aceMagazineStateOwner}
						&& {_aceTransportReserveRestored}
					) then {
						_aceMagazineStateOwner setVariable [
							"A3C_ACE_CSW_MAGAZINE_STATE",
							nil,
							true
						];
					};

					private _gunner = _assemblyUnits select 0;

					[_gunner, _createdStatic] remoteExec ["assignAsGunner", _gunner];
					[_gunner, ["getInGunner", _createdStatic]] remoteExec ["action", _gunner];

					if (_aceAutofireSuppressed) then {
						private _aceAmmoLoadTime = getNumber (
							configOf _createdStatic
							>> "ACE_CSW"
							>> "ammoLoadTime"
						);

						[
							_createdStatic,
							_aceAutofireRestoreState,
							_aceAmmoLoadTime
						] spawn {
							params [
								"_createdStatic",
								"_aceAutofireRestoreState",
								"_aceAmmoLoadTime"
							];

							waitUntil {
								sleep 0.05;

								!alive _createdStatic
								|| {!isNull gunner _createdStatic}
							};

							if (!alive _createdStatic) exitWith {};

							sleep ((_aceAmmoLoadTime max 0) + 0.5);

							if (alive _createdStatic) then {
								_createdStatic setVariable [
									"ace_csw_autofire",
									_aceAutofireRestoreState,
									true
								];
							};
						};
					};

					if (count _assemblyUnits > 1) then {
						private _assistant = _assemblyUnits select 1;
						private _assistantAngleOffset = floor random 31;

						if (floor random 2 == 0) then {
							_assistantAngleOffset = _assistantAngleOffset * -1;
						};

						private _assistantPos = _weaponPos getPos [
							(random 4) max 1,
							(getDir _createdStatic) + 180 + _assistantAngleOffset
						];

						[_assistant, _assistantPos] call A3C_ai_shared_fnc_doMove;
						[
							_assistant,
							_weaponPos getPos [50, getDir _createdStatic]
						] remoteExec ["lookAt", _assistant];
					};

					//-- Some static weapons slide/tilt after creation. This tries small center-of-mass offsets until stable.
					private _needsCorrection = false;

					{
						private _massArrayIndex = _x;

						{
							_x params ["_startOffset", "_endOffset"];

							for "_offset" from _startOffset to _endOffset step 0.1 do {
								private _centerMassTest = +_centerMass;

								_centerMassTest set [
									_massArrayIndex,
									(_centerMassTest select _massArrayIndex) + _offset
								];

								_createdStatic setCenterOfMass _centerMassTest;
								_createdStatic setVectorUp (surfaceNormal _weaponPos);

								[_createdStatic, ATLToASL _weaponPos] remoteExec ["setPosASL", _createdStatic];

								_needsCorrection = false;

								sleep 0.2;

								private _timer = time;

								while {time - _timer < 5} do {
									if ({abs _x > 0.3} count velocity _createdStatic > 0) exitWith {
										_needsCorrection = true;
									};

									sleep 0.1;
								};

								if !(_needsCorrection) exitWith {};
							};

							if !(_needsCorrection) exitWith {};
						} forEach [[0, 0.3], [-0.3, -0.1]];

						if !(_needsCorrection) exitWith {};
					} forEach [0, 1, 2];
				};

				sleep 0.2;
			};

			{
				(group _x) setVariable ["A3C_ASSEMBLING", nil, true];
			} forEach _assemblyUnits;
		};
	} forEach A3C_STATIC_PACKS;
} else {
	private _staticWeapon = _staticData select 1;

	private _disassemblyData = [
		_units,
		[],
		_staticData,
		_weaponPos,
		_weaponDir,
		30
	] call A3C_ai_shared_fnc_staticWeaponPrepareDisassembly;

	_disassemblyData params [
		"_disassemblyUnits",
		"_requiredUnitCount",
		"_needsMoreUnits",
		"_ifaDisassemblyItems",
		"_staticMagazineCount",
		["_disassemblyProvider", "LEGACY"],
		["_disassemblyProviderData", []]
	];

	if (_needsMoreUnits) exitWith {
		systemChat format [
			"A3C: Current selection (%1) is not suitable to pick up this weapon",
			group (_units select 0)
		];
	};

	if (count _disassemblyUnits != _requiredUnitCount) exitWith {};

	private _staticWeaponType = typeOf _staticWeapon;
	private _staticWeaponCfg = configOf _staticWeapon;

	private _usesACECSW = _disassemblyProvider == "ACE_CSW";

	private _aceWeaponClass = "";
	private _aceMountClass = "";
	private _aceWeaponSlot = "";
	private _aceMountVehicleClass = "";
	private _aceDisassembleFunc = "";

	if (_usesACECSW) then {
		_aceWeaponClass = _disassemblyProviderData param [0, ""];
		_aceMountClass = _disassemblyProviderData param [1, ""];
		_aceWeaponSlot = _disassemblyProviderData param [2, ""];

		_aceMountVehicleClass = getText (
			_staticWeaponCfg
				>> "ACE_CSW"
				>> "disassembleTurret"
		);

		_aceDisassembleFunc = getText (
			_staticWeaponCfg
				>> "ACE_CSW"
				>> "disassembleFunc"
		);
	};


	//-- Standard statics disassemble into backpacks.
	private _disassemblyBackpacks = getArray (
		_staticWeaponCfg >> "assembleInfo" >> "dissasembleTo"
	);

	// _test = str [
	// 	"ACE EXEC DEBUG",
	// 	_usesACECSW,
	// 	_disassemblyProvider,
	// 	_disassemblyProviderData,
	// 	_aceWeaponClass,
	// 	_aceMountClass,
	// 	_aceWeaponSlot,
	// 	_disassemblyUnits apply {
	// 		[
	// 			_x,
	// 			primaryWeapon _x,
	// 			secondaryWeapon _x
	// 		]
	// 	}
	// ];
	// systemchat str _test;
	// copyToClipboard str _test;

	

	//-- Store magazine state only on the primary weapon backpack, never on the pod.
	private _weaponBackpackIndex = _disassemblyBackpacks findIf {
		getNumber (
			configFile
			>> "CfgVehicles"
			>> _x
			>> "assembleInfo"
			>> "primary"
		) == 1
	};

	//-- IFA statics disassemble into weapons. The second config item maps to the equipped tripod weapon.
	private _ifaPodWeaponClass = if (count _ifaDisassemblyItems > 1) then {
		getText (
			configFile >> "CfgVehicles" >> (_ifaDisassemblyItems select 1) >> "LIB_Equipped_Tripod_Name"
		)
	} else {
		""
	};

	{
		[_x, "amovpercmstpslowwrfldnon"] call _fnc_playStaticWeaponWorkAnimation;
	} forEach _disassemblyUnits;

	sleep 2;

	while {true} do {
		if ({alive _x} count _disassemblyUnits != _requiredUnitCount) exitWith {};

		if ({animationState _x == "ainvpknlmstpslaywrfldnon_medic"} count _disassemblyUnits == 0) exitWith {

			private _staticMagazineState = magazinesAllTurrets _staticWeapon;

			private _aceTransportReserve = [];

			if (
				_usesACECSW
				&& {
					missionNamespace getVariable [
						"ace_csw_handleExtraMagazines",
						false
					]
				}
			) then {
				private _aceStore = [
					_staticWeapon
				] call _fnc_findACECSWStore;

				if (!isNull _aceStore) then {
					private _carryMagazineClasses = (
						[
							_staticWeapon
						] call _fnc_getACECSWCarryMappings
					) apply {
						_x select 0
					};

					_carryMagazineClasses =
						_carryMagazineClasses arrayIntersect _carryMagazineClasses;

					(getMagazineCargo _aceStore) params [
						"_storeMagazineClasses",
						"_storeMagazineCounts"
					];

					{
						private _carryMagazine = _x;
						private _storeIndex = _storeMagazineClasses find _carryMagazine;

						if (_storeIndex >= 0) then {
							private _storeAmount = _storeMagazineCounts param [
								_storeIndex,
								0
							];

							if (_storeAmount > 0) then {
								private _userCount = [
									_aceStore,
									_carryMagazine
								] call _fnc_countACECSWStoreUsers;

								private _share = floor (
									_storeAmount / (_userCount max 1)
								);

								if (_share > 0) then {
									_aceStore addMagazineCargoGlobal [
										_carryMagazine,
										-_share
									];

									_aceTransportReserve = [
										_aceTransportReserve,
										_carryMagazine,
										_share
									] call _fnc_mergeMagazineCounts;
								};
							};
						};

					} forEach _carryMagazineClasses;

					private _storeIsEmpty = (
						((getMagazineCargo _aceStore) select 0) isEqualTo []
						&& {((getWeaponCargo _aceStore) select 0) isEqualTo []}
						&& {((getItemCargo _aceStore) select 0) isEqualTo []}
						&& {((getBackpackCargo _aceStore) select 0) isEqualTo []}
					);

					if (_storeIsEmpty) then {
						private _hasOtherStoreUser = (
							nearestObjects [
								_aceStore,
								["StaticWeapon"],
								_aceCSWStoreDistance
							]
						) findIf {
							private _candidate = _x;

							_candidate != _staticWeapon
							&& {
								[_candidate] call _fnc_isEffectiveACECSW
							}
							&& {
								(
									[_candidate] call _fnc_findACECSWStore
								) isEqualTo _aceStore
							}
						} >= 0;

						if (!_hasOtherStoreUser) then {
							deleteVehicle _aceStore;
						};
					};
				};
			};

			/*
				ACE optionally defines a callback for disassembly.

				ACE calls it with:
					[tripod, staticWeapon]

				A3C ultimately packs the tripod directly onto a worker, so create
				the configured deployed tripod only for the duration of the callback.
			*/
			private _aceCallbackTripod = objNull;

			if (
				_usesACECSW
				&& {_aceDisassembleFunc != ""}
				&& {_aceMountVehicleClass != ""}
			) then {
				_aceCallbackTripod = _aceMountVehicleClass createVehicle [0,0,0];

				_aceCallbackTripod setVectorDirAndUp [
					vectorDir _staticWeapon,
					vectorUp _staticWeapon
				];

				_aceCallbackTripod setPosASL (getPosASL _staticWeapon);

				private _aceDisassembleCode = missionNamespace getVariable [
					_aceDisassembleFunc,
					{}
				];

				if (_aceDisassembleCode isEqualType {}) then {
					[
						_aceCallbackTripod,
						_staticWeapon
					] call _aceDisassembleCode;
				};
			};

			deleteVehicle _staticWeapon;

			if (!isNull _aceCallbackTripod) then {
				deleteVehicle _aceCallbackTripod;
			};


			if (_usesACECSW) then {
				private _aceWeaponUnit = _disassemblyUnits select 0;

				private _aceMountUnit = if (count _disassemblyUnits == 1) then {
					_aceWeaponUnit
				} else {
					_disassemblyUnits select 1
				};

				//-- Store exact loaded-ammunition state with the packed ACE weapon.
				private _aceMagazineStateOwner = unitBackpack _aceWeaponUnit;

				//-- Clear a possible old unit fallback when a backpack is available now.
				if (!isNull _aceMagazineStateOwner) then {
					_aceWeaponUnit setVariable [
						"A3C_ACE_CSW_MAGAZINE_STATE",
						nil,
						true
					];
				} else {
					_aceMagazineStateOwner = _aceWeaponUnit;
				};

				_aceMagazineStateOwner setVariable [
					"A3C_ACE_CSW_MAGAZINE_STATE",
					[
						_staticWeaponType,
						_aceWeaponClass,
						+_staticMagazineState,
						+_aceTransportReserve
					],
					true
				];

				private _pickupPos = (
					_aceWeaponUnit modelToWorld (
						_aceWeaponUnit selectionPosition "weapon"
					)
				);

				private _hasPrimaryWeaponToPreserve = (
					_aceWeaponSlot == "PRIMARY"
					&& {primaryWeapon _aceWeaponUnit != ""}
				);

				private _needsWeaponHolder = _hasPrimaryWeaponToPreserve;

				private _weaponHolder = if (_needsWeaponHolder) then {
					"GroundWeaponHolder" createVehicle _pickupPos
				} else {
					objNull
				};


				//-- Preserve an existing rifle before giving this unit a primary-slot CSW.
				if (_hasPrimaryWeaponToPreserve) then {
					private _oldPrimaryWeapon = [
						primaryWeapon _aceWeaponUnit
					] call A3C_main_fnc_getBaseWeapon;

					private _oldPrimaryMagazines = [
						currentMagazine _aceWeaponUnit
					];

					private _oldPrimaryItems = primaryWeaponItems _aceWeaponUnit;

					private _oldPrimaryMagazineTypes = getArray (
						configFile
							>> "CfgWeapons"
							>> _oldPrimaryWeapon
							>> "magazines"
					);

					{
						if (_x in _oldPrimaryMagazineTypes) then {
							_oldPrimaryMagazines pushBack _x;

							[
								_aceWeaponUnit,
								_x
							] remoteExec [
								"removeMagazine",
								_aceWeaponUnit
							];
						};
					} forEach magazines _aceWeaponUnit;

					_weaponHolder addWeaponCargoGlobal [
						_oldPrimaryWeapon,
						1
					];

					{
						if (_x != "") then {
							_weaponHolder addMagazineCargoGlobal [
								_x,
								1
							];
						};
					} forEach _oldPrimaryMagazines;

					{
						_weaponHolder addItemCargoGlobal [
							_x,
							1
						];
					} forEach _oldPrimaryItems;

					[
						_aceWeaponUnit,
						_oldPrimaryWeapon
					] remoteExec [
						"removeWeapon",
						_aceWeaponUnit
					];
				};


				//-- Give the carried CSW weapon to its selected worker.
				if (_aceWeaponClass != "") then {
					_aceWeaponUnit addWeaponGlobal _aceWeaponClass;

					if (_aceWeaponSlot == "PRIMARY") then {
						[
							_aceWeaponUnit,
							_aceWeaponClass
						] remoteExec [
							"selectWeapon",
							_aceWeaponUnit
						];
					};
				};


				//-- Give the carried tripod/mount to its selected worker.
				if (_aceMountClass != "") then {
					_aceMountUnit addWeaponGlobal _aceMountClass;
				};

			} else {
				if (count _disassemblyBackpacks > 0) then {
					{
						if (_forEachIndex < count _disassemblyBackpacks) then {
							private _backpackClass = _disassemblyBackpacks select _forEachIndex;

							if (_backpackClass != "") then {
								if (_forEachIndex == _weaponBackpackIndex) then {
									private _backpackMagazineState = [
										_staticWeaponType,
										_staticMagazineState
									];

									[
										_x,
										_backpackClass,
										_backpackMagazineState
									] call _fnc_addBackpackWithMagazineState;
								} else {
									[_x, _backpackClass] remoteExec ["addBackpack", _x];
								};
							};
						};
					} forEach _disassemblyUnits;
				};

				if (count _ifaDisassemblyItems > 0) then {
					private _pickupPos = (
						(_disassemblyUnits select 0) modelToWorld (
							(_disassemblyUnits select 0) selectionPosition "weapon"
						)
					);

					private _weaponHolder = "GroundWeaponHolder" createVehicle _pickupPos;
					private _turretAssigned = false;
					private _ifaTurretWeaponClass = _ifaDisassemblyItems select 0;
					private _ifaTurretIsRifle = _ifaTurretWeaponClass isKindOf ["Rifle", configFile >> "CfgWeapons"];

					//-- Assign turret first. If needed, preserve the unit's replaced primary weapon in a ground holder.
					{
						private _unit = _x;

						if (!_turretAssigned) then {
							if (_ifaTurretIsRifle) then {
								if (primaryWeapon _unit != "") then {
									private _oldPrimaryWeapon = [primaryWeapon _unit] call A3C_main_fnc_getBaseWeapon;
									private _oldPrimaryMagazines = [currentMagazine _unit];
									private _oldPrimaryItems = primaryWeaponItems _unit;
									private _oldPrimaryMagazineTypes = getArray (
										configFile >> "CfgWeapons" >> _oldPrimaryWeapon >> "magazines"
									);

									{
										if (_x in _oldPrimaryMagazineTypes) then {
											_oldPrimaryMagazines pushBack _x;
											[_unit, _x] remoteExec ["removeMagazine", _unit];
										};
									} forEach magazines _unit;

									_weaponHolder addWeaponCargoGlobal [_oldPrimaryWeapon, 1];

									{
										_weaponHolder addMagazineCargoGlobal [_x, 1];
									} forEach _oldPrimaryMagazines;

									{
										_weaponHolder addItemCargoGlobal [_x, 1];
									} forEach _oldPrimaryItems;

									[_unit, _oldPrimaryWeapon] remoteExec ["removeWeapon", _unit];
								};

								_turretAssigned = true;
							} else {
								if ([_unit] call A3C_main_fnc_canUnitCarryIFAstatic) then {
									_turretAssigned = true;
								};
							};

							if (_turretAssigned) then {
								[_unit, _ifaTurretWeaponClass] remoteExec ["addWeapon", _unit];
								[_unit, _ifaTurretWeaponClass] remoteExec ["selectWeapon", _unit];

								if (_ifaTurretIsRifle) then {
									private _newMagazineTypes = getArray (
										configFile >> "CfgWeapons" >> _ifaTurretWeaponClass >> "magazines"
									);

									if (count _newMagazineTypes > 0 && {_staticMagazineCount > 0}) then {
										private _newMagazineType = _newMagazineTypes select 0;

										for "_i" from 1 to _staticMagazineCount do {
											[_unit, _newMagazineType] remoteExec ["addMagazine", _unit];
										};
									};
								};
							};
						};
					} forEach _disassemblyUnits;

					//-- Assign pod/tripod second. If needed, preserve replaced secondary weapon in the ground holder.
					{
						private _unit = _x;

						if !(_forEachIndex == 0 && {count _disassemblyUnits > 1}) then {
							if ([_unit] call A3C_main_fnc_canUnitCarryIFAstatic) exitWith {
								if (secondaryWeapon _unit != "") then {
									private _oldSecondaryWeapon = [secondaryWeapon _unit] call A3C_main_fnc_getBaseWeapon;
									private _oldSecondaryMagazines = secondaryWeaponMagazine _unit;
									private _oldSecondaryItems = secondaryWeaponItems _unit;
									private _oldSecondaryMagazineTypes = getArray (
										configFile >> "CfgWeapons" >> _oldSecondaryWeapon >> "magazines"
									);

									{
										if (_x in _oldSecondaryMagazineTypes) then {
											_oldSecondaryMagazines pushBack _x;
											[_unit, _x] remoteExec ["removeMagazine", _unit];
										};
									} forEach magazines _unit;

									_weaponHolder addWeaponCargoGlobal [_oldSecondaryWeapon, 1];

									{
										_weaponHolder addMagazineCargoGlobal [_x, 1];
									} forEach _oldSecondaryMagazines;

									{
										_weaponHolder addItemCargoGlobal [_x, 1];
									} forEach _oldSecondaryItems;

									[_unit, _oldSecondaryWeapon] remoteExec ["removeWeapon", _unit];
								};

								if (_ifaPodWeaponClass != "") then {
									[_unit, _ifaPodWeaponClass] remoteExec ["addWeapon", _unit];
								};
							};
						};
					} forEach _disassemblyUnits;

					if (count weaponCargo _weaponHolder == 0) then {
						deleteVehicle _weaponHolder;
					};
				};
			};
		};
		sleep 0.2;
	};
};
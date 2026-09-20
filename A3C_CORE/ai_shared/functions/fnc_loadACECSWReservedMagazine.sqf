// A3C_ai_shared_fnc_loadACECSWReservedMagazine

params [
	["_vehicle", objNull, [objNull]],
	["_orderId", "", [""]],
	["_carryMag", "", [""]],
	["_reservedSources", [], [[]]]
];

if (
	isNull _vehicle
	|| {_orderId == ""}
	|| {_carryMag == ""}
) exitWith {
	false
};

private _gunner =
	gunner _vehicle;

if (
	isNull _gunner
	|| {!alive _gunner}
) exitWith {
	false
};

private _turretPath =
	[_gunner]
		call ace_common_fnc_getTurretIndex;

if (
	[
		_vehicle,
		_turretPath,
		_carryMag
	] call A3C_main_fnc_getACECSWLoadedMagazineData
	select 0
	!= ""
) exitWith {
	true
};


private _changeVehicleReservation = {
	params [
		"_vehicle",
		"_variable",
		"_orderId",
		"_carryMag",
		"_change"
	];

	private _reservations =
		_vehicle getVariable [
			_variable,
			[]
		];

	private _index =
		_reservations findIf {
			(_x select 0) == _orderId
			&& {
				(_x select 1)
					== _carryMag
			}
		};

	if (_change > 0) then {
		if (_index < 0) then {
			_reservations pushBack [
				_orderId,
				_carryMag,
				_change
			];
		} else {
			private _entry =
				_reservations select _index;

			_entry set [
				2,
				(
					_entry select 2
				) + _change
			];
		};
	} else {
		if (_index >= 0) then {
			private _entry =
				_reservations select _index;

			private _newAmount =
				(
					_entry select 2
				) + _change;

			if (_newAmount <= 0) then {
				_reservations deleteAt
					_index;
			} else {
				_entry set [
					2,
					_newAmount
				];
			};
		};
	};

	_vehicle setVariable [
		_variable,
		if (
			_reservations
				isEqualTo []
		) then {
			nil
		} else {
			_reservations
		},
		true
	];
};


private _changeSourceReservation = {
	params [
		"_source",
		"_vehicle",
		"_orderId",
		"_carryMag",
		"_change"
	];

	private _reservations =
		_source getVariable [
			"A3C_ARTY_CSW_SOURCE_RESERVATIONS",
			[]
		];

	private _index =
		_reservations findIf {
			(_x select 0) == _orderId
			&& {
				(_x select 1)
					isEqualTo _vehicle
			}
			&& {
				(_x select 2)
					== _carryMag
			}
		};

	if (_index < 0) exitWith {
		false
	};

	private _entry =
		_reservations select _index;

	private _newAmount =
		(
			_entry select 3
		) + _change;

	if (_newAmount <= 0) then {
		_reservations deleteAt _index;
	} else {
		_entry set [
			3,
			_newAmount
		];
	};

	_source setVariable [
		"A3C_ARTY_CSW_SOURCE_RESERVATIONS",
		if (
			_reservations
				isEqualTo []
		) then {
			nil
		} else {
			_reservations
		},
		true
	];

	true
};


private _snapshot = [
	[_vehicle],
	[]
] call A3C_main_fnc_getACECSWArtillerySnapshot;

private _familyIndex =
	_snapshot findIf {
		(_x select 0)
			== _carryMag
	};

if (_familyIndex < 0) exitWith {
	false
};

private _physicalSources =
	(_snapshot select _familyIndex)
		select 6;

private _source = objNull;
private _bestAmmoToSend = -1;
private _ammoUsed = 0;

{
	private _candidate =
		_x param [
			0,
			objNull
		];

	if (!isNull _candidate) then {
		private _isReservedSource =
			_reservedSources findIf {
				(_x select 0)
					isEqualTo _candidate
			} >= 0;

		if (_isReservedSource) then {
			private _physicalIndex =
				_physicalSources findIf {
					(_x select 0)
						isEqualTo _candidate
					&& {
						(_x select 1) > 0
					}
					&& {
						_vehicle in (
							_x select 2
						)
					}
				};

			if (_physicalIndex >= 0) then {
				private _reservations =
					_candidate getVariable [
						"A3C_ARTY_CSW_SOURCE_RESERVATIONS",
						[]
					];

				private _reservationIndex =
					_reservations findIf {
						(_x select 0)
							== _orderId
						&& {
							(_x select 1)
								isEqualTo _vehicle
						}
						&& {
							(_x select 2)
								== _carryMag
						}
						&& {
							(_x select 3) > 0
						}
					};

				if (_reservationIndex >= 0) then {
					private _loadInfo = [
						_vehicle,
						_turretPath,
						_carryMag,
						_candidate
					] call ace_csw_fnc_reload_canLoadMagazine;

					_loadInfo params [
						"_canLoad",
						"_loadedMag",
						"_neededAmmo",
						"_isBeltLinking"
					];

					if (
						_canLoad
						&& {_neededAmmo > 0}
					) then {
						private _candidateAmmo = -1;

						private _sourceMags =
							if (
								_candidate
									isKindOf "CAManBase"
							) then {
								magazinesAmmo
									_candidate
							} else {
								magazinesAmmoCargo
									_candidate
							};

						{
							_x params [
								"_mag",
								"_ammo"
							];

							if (
								_mag == _carryMag
							) then {
								if (
									_candidateAmmo == -1
									|| {
										_ammo >
											_candidateAmmo
										&& {
											_ammo <=
												_neededAmmo
										}
									}
								) then {
									_candidateAmmo =
										_ammo;
								};
							};

						} forEach _sourceMags;

						if (_candidateAmmo > 0) then {
							private _candidateUsed =
								_neededAmmo min
									_candidateAmmo;

							private _reservationAmount =
								(
									_reservations select
										_reservationIndex
								) select 3;

							if (
								_reservationAmount
									>= _candidateUsed
							) exitWith {
								_source =
									_candidate;

								_bestAmmoToSend =
									_candidateAmmo;

								_ammoUsed =
									_candidateUsed;
							};
						};
					};
				};
			};
		};
	};

	if (!isNull _source) exitWith {};

} forEach _reservedSources;

if (
	isNull _source
	|| {_bestAmmoToSend <= 0}
	|| {_ammoUsed <= 0}
) exitWith {
	false
};


private _sourceAmmoBefore = 0;

{
	_x params [
		"_mag",
		"_ammo"
	];

	if (_mag == _carryMag) then {
		_sourceAmmoBefore =
			_sourceAmmoBefore + _ammo;
	};

} forEach (
	if (
		_source isKindOf "CAManBase"
	) then {
		magazinesAmmo _source
	} else {
		magazinesAmmoCargo _source
	}
);


[
	_source,
	_carryMag,
	_bestAmmoToSend
] call ace_common_fnc_removeSpecificMagazine;


private _sourceAmmoAfter = 0;

{
	_x params [
		"_mag",
		"_ammo"
	];

	if (_mag == _carryMag) then {
		_sourceAmmoAfter =
			_sourceAmmoAfter + _ammo;
	};

} forEach (
	if (
		_source isKindOf "CAManBase"
	) then {
		magazinesAmmo _source
	} else {
		magazinesAmmoCargo _source
	}
);

if (
	_sourceAmmoAfter
		>= _sourceAmmoBefore
) exitWith {
	false
};


[
	_source,
	_vehicle,
	_orderId,
	_carryMag,
	-_ammoUsed
] call _changeSourceReservation;

[
	_vehicle,
	"A3C_ARTY_CSW_TRANSIT_RESERVATIONS",
	_orderId,
	_carryMag,
	_ammoUsed
] call _changeVehicleReservation;


private _timeToLoad = 1;

private _loadTimeCfg =
	configOf _vehicle
	>> "ACE_CSW"
	>> "ammoLoadTime";

if (!isNull _loadTimeCfg) then {
	_timeToLoad =
		getNumber _loadTimeCfg;
};

sleep _timeToLoad;

if (
	!alive _vehicle
	|| {isNull gunner _vehicle}
	|| {!alive gunner _vehicle}
) exitWith {
	[
		"ace_csw_returnAmmo",
		[
			_source,
			_carryMag,
			_bestAmmoToSend
		],
		_source
	] call CBA_fnc_targetEvent;

	[
		_vehicle,
		"A3C_ARTY_CSW_TRANSIT_RESERVATIONS",
		_orderId,
		_carryMag,
		-_ammoUsed
	] call _changeVehicleReservation;

	false
};


[
	"ace_csw_addTurretMag",
	[
		_vehicle,
		_turretPath,
		_source,
		_carryMag,
		_bestAmmoToSend
	]
] call CBA_fnc_globalEvent;


private _timeout =
	time + 10;

waitUntil {
	sleep 0.05;

	(
		[
			_vehicle,
			_turretPath,
			_carryMag
		] call A3C_main_fnc_getACECSWLoadedMagazineData
		select 0
	) != ""
	|| {
		time > _timeout
	}
};


private _loaded = (
	[
		_vehicle,
		_turretPath,
		_carryMag
	] call A3C_main_fnc_getACECSWLoadedMagazineData
	select 0
) != "";

[
	_vehicle,
	"A3C_ARTY_CSW_TRANSIT_RESERVATIONS",
	_orderId,
	_carryMag,
	-_ammoUsed
] call _changeVehicleReservation;

if (_loaded) then {
	[
		_vehicle,
		"A3C_ARTY_CSW_LOADED_RESERVATIONS",
		_orderId,
		_carryMag,
		_ammoUsed
	] call _changeVehicleReservation;
};

_loaded
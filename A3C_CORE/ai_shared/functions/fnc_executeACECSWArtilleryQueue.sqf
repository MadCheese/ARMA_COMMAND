// A3C_ai_shared_fnc_executeACECSWArtilleryQueue

params [
	["_vehicle", objNull, [objNull]]
];

if (isNull _vehicle) exitWith {};

if (!local _vehicle) exitWith {
	[
		[_vehicle],
		{
			_this spawn
				A3C_ai_shared_fnc_executeACECSWArtilleryQueue;
		}
	] remoteExec [
		"BIS_fnc_call",
		_vehicle
	];
};

if (
	_vehicle getVariable [
		"A3C_ARTY_CSW_WORKER_ACTIVE",
		false
	]
) exitWith {};

_vehicle setVariable [
	"A3C_ARTY_CSW_WORKER_ACTIVE",
	true,
	true
];

private _workerToken = (
	_vehicle getVariable [
		"A3C_ARTY_CSW_WORKER_TOKEN",
		0
	]
) + 1;

_vehicle setVariable [
	"A3C_ARTY_CSW_WORKER_TOKEN",
	_workerToken,
	true
];


private _originalAutofireNil =
	isNil {
		_vehicle getVariable
			"ace_csw_autofire"
	};

private _originalAutofire =
	_vehicle getVariable [
		"ace_csw_autofire",
		false
	];

_vehicle setVariable [
	"ace_csw_autofire",
	false,
	true
];

private _reloadObservationTime = 1.5;

private _ammoLoadTimeCfg =
	configOf _vehicle
	>> "ACE_CSW"
	>> "ammoLoadTime";

if (!isNull _ammoLoadTimeCfg) then {
	_reloadObservationTime = (
		(getNumber _ammoLoadTimeCfg) + 0.5
	) max 1;
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


private _getLoadedReservation = {
	params [
		"_vehicle",
		"_orderId",
		"_carryMag"
	];

	private _index = (
		_vehicle getVariable [
			"A3C_ARTY_CSW_LOADED_RESERVATIONS",
			[]
		]
	) findIf {
		(_x select 0) == _orderId
		&& {
			(_x select 1)
				== _carryMag
		}
	};

	if (_index < 0) exitWith {
		0
	};

	(
		_vehicle getVariable [
			"A3C_ARTY_CSW_LOADED_RESERVATIONS",
			[]
		]
		select _index
	) select 2
};


private _getSourceReservation = {
	params [
		"_source",
		"_vehicle",
		"_orderId",
		"_carryMag"
	];

	if (isNull _source) exitWith {
		0
	};

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
		0
	};

	(
		_reservations select _index
	) select 3
};


private _changeSourceReservation = {
	params [
		"_source",
		"_vehicle",
		"_orderId",
		"_carryMag",
		"_change"
	];

	if (isNull _source) exitWith {
		false
	};

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


private _getSourceAmmo = {
	params [
		"_source",
		"_carryMag"
	];

	if (isNull _source) exitWith {
		0
	};

	private _amount = 0;

	private _mags =
		if (
			_source isKindOf "CAManBase"
		) then {
			magazinesAmmo _source
		} else {
			magazinesAmmoCargo
				_source
		};

	{
		_x params [
			"_mag",
			"_ammo"
		];

		if (_mag == _carryMag) then {
			_amount =
				_amount + _ammo;
		};

	} forEach _mags;

	_amount
};


private _captureReloadSources = {
	params [
		"_vehicle"
	];

	private _result = [];

	private _snapshot = [
		[_vehicle],
		[]
	] call A3C_main_fnc_getACECSWArtillerySnapshot;

	{
		private _carryMag =
			_x select 0;

		{
			private _source =
				_x select 0;

			private _amount =
				_x select 1;

			private _index =
				_result findIf {
					(_x select 0)
						isEqualTo _source
					&& {
						(_x select 1)
							== _carryMag
					}
				};

			if (_index < 0) then {
				_result pushBack [
					_source,
					_carryMag,
					_amount
				];
			};

		} forEach (
			_x select 6
		);

	} forEach _snapshot;

	_result
};


private _findConsumedReload = {
	params [
		"_sourceState"
	];

	private _result = [];

	{
		_x params [
			"_source",
			"_carryMag",
			"_before"
		];

		private _after = [
			_source,
			_carryMag
		] call _getSourceAmmo;

		if (_after < _before) exitWith {
			_result = [
				_source,
				_carryMag,
				_before - _after
			];
		};

	} forEach _sourceState;

	_result
};


private _unloadLoadedMagazine = {
	params [
		"_vehicle",
		"_turretPath",
		"_loadedData",
		"_returnTo"
	];

	_loadedData params [
		"_vehicleMag",
		"_carryMag",
		"_ammo"
	];

	if (
		_vehicleMag == ""
		|| {_carryMag == ""}
	) exitWith {
		true
	};

	[
		"ace_csw_removeTurretMag",
		[
			_vehicle,
			_turretPath,
			_carryMag,
			_vehicleMag,
			_returnTo
		]
	] call CBA_fnc_globalEvent;

	private _timeout =
		time + 5;

	waitUntil {
		sleep 0.05;

		(
			[
				_vehicle,
				_turretPath,
				_carryMag
			] call A3C_main_fnc_getACECSWLoadedMagazineData
			select 0
		) == ""
		|| {
			time > _timeout
		}
	};

	(
		[
			_vehicle,
			_turretPath,
			_carryMag
		] call A3C_main_fnc_getACECSWLoadedMagazineData
		select 0
	) == ""
};


private _firedCounter =
	_vehicle getVariable [
		"A3C_ARTY_CSW_FIRED_COUNTER",
		0
	];

private _firedEH =
	_vehicle addEventHandler [
		"Fired",
		{
			params [
				"_vehicle"
			];

			_vehicle setVariable [
				"A3C_ARTY_CSW_FIRED_COUNTER",
				(
					_vehicle getVariable [
						"A3C_ARTY_CSW_FIRED_COUNTER",
						0
					]
				) + 1
			];
		}
	];


private _completionOwners = [];

private _keepRunning = true;

while {_keepRunning} do {
	private _orders =
		_vehicle getVariable [
			"A3C_ARTY_CSW_ORDERS",
			[]
		];

	private _orderIndex =
		_orders findIf {
			(_x param [3, 0]) > 0
		};

	if (_orderIndex < 0) then {
		sleep 0.1;

		_orders =
			_vehicle getVariable [
				"A3C_ARTY_CSW_ORDERS",
				[]
			];

		_orderIndex =
			_orders findIf {
				(_x param [3, 0]) > 0
			};

		if (_orderIndex < 0) then {
			_keepRunning = false;
		};
	};

	if (_keepRunning) then {
		private _order =
			_orders select _orderIndex;

		_order params [
			"_orderId",
			"_targetPos",
			"_carryMag",
			"_shellCount",
			["_reservedSources", []],
			["_requestOwner", 0]
		];

		if (_requestOwner > 0) then {
			_completionOwners pushBackUnique _requestOwner;
		};

		private _gunner =
			gunner _vehicle;

		private _failed = (
			!local _vehicle
			|| {!alive _vehicle}
			|| {isNull _gunner}
			|| {!alive _gunner}
		);

		private _turretPath =
			if (_failed) then {
				[]
			} else {
				[_gunner]
					call ace_common_fnc_getTurretIndex
			};

		private _spread =
			if (_shellCount > 7) then {
				random 50
			} else {
				1
			};

		private _shotNumber = 0;

		while {
			!_failed
			&& {
				private _currentOrders =
					_vehicle getVariable [
						"A3C_ARTY_CSW_ORDERS",
						[]
					];

				private _currentIndex =
					_currentOrders findIf {
						(_x select 0)
							== _orderId
						&& {
							(_x select 2)
								== _carryMag
						}
					};

				_currentIndex >= 0
				&& {
					(
						_currentOrders
							select _currentIndex
					) select 3 > 0
				}
			}
		} do {
			_gunner =
				gunner _vehicle;

			if (
				!local _vehicle
				|| {!alive _vehicle}
				|| {isNull _gunner}
				|| {!alive _gunner}
			) then {
				_failed = true;
			};

			if (!_failed) then {
				_turretPath =
					[_gunner]
						call ace_common_fnc_getTurretIndex;

				private _requestedLoaded = [
					_vehicle,
					_turretPath,
					_carryMag
				] call A3C_main_fnc_getACECSWLoadedMagazineData;

				if (
					(_requestedLoaded select 0)
						!= ""
				) then {
					private _ownLoadedReservation = [
						_vehicle,
						_orderId,
						_carryMag
					] call _getLoadedReservation;

					if (
						_ownLoadedReservation <= 0
					) then {
						private _allLoadedReservations =
							_vehicle getVariable [
								"A3C_ARTY_CSW_LOADED_RESERVATIONS",
								[]
							];

						private _reservedLoadedTotal = 0;

						{
							if (
								(_x select 1)
									== _carryMag
							) then {
								_reservedLoadedTotal =
									_reservedLoadedTotal
									+ (_x select 2);
							};

						} forEach _allLoadedReservations;

						if (
							(_requestedLoaded select 2)
								> _reservedLoadedTotal
						) then {
							private _converted = false;

							{
								private _source =
									_x param [
										0,
										objNull
									];

								if (
									!isNull _source
									&& {
										[
											_source,
											_vehicle,
											_orderId,
											_carryMag
										] call _getSourceReservation
										> 0
									}
								) exitWith {
									[
										_source,
										_vehicle,
										_orderId,
										_carryMag,
										-1
									] call _changeSourceReservation;

									[
										_vehicle,
										"A3C_ARTY_CSW_LOADED_RESERVATIONS",
										_orderId,
										_carryMag,
										1
									] call _changeVehicleReservation;

									_converted = true;
								};

							} forEach _reservedSources;

							if (!_converted) then {
								_failed = true;
							};
						} else {
							_failed = true;
						};
					};

				} else {
					private _currentLoaded = [
						_vehicle,
						_turretPath,
						""
					] call A3C_main_fnc_getACECSWLoadedMagazineData;

					if (
						(_currentLoaded select 0)
							!= ""
					) then {
						private _currentCarry =
							_currentLoaded select 1;

						private _reservedCurrent = 0;

						{
							if (
								(_x select 1)
									== _currentCarry
							) then {
								_reservedCurrent =
									_reservedCurrent
									+ (_x select 2);
							};

						} forEach (
							_vehicle getVariable [
								"A3C_ARTY_CSW_LOADED_RESERVATIONS",
								[]
							]
						);

						if (_reservedCurrent > 0) then {
							_failed = true;
						} else {
							if !(
								[
									_vehicle,
									_turretPath,
									_currentLoaded,
									_vehicle
								] call _unloadLoadedMagazine
							) then {
								_failed = true;
							};
						};
					};

					if (!_failed) then {
						if !(
							[
								_vehicle,
								_orderId,
								_carryMag,
								_reservedSources
							] call A3C_ai_shared_fnc_loadACECSWReservedMagazine
						) then {
							_failed = true;
						};
					};
				};
			};


			if (!_failed) then {
				private _vehicleMagData = [
					_vehicle,
					_turretPath,
					_carryMag
				] call A3C_main_fnc_getACECSWLoadedMagazineData;

				private _vehicleMag =
					_vehicleMagData select 0;

				if (
					_vehicleMag == ""
					|| {
						!(
							_targetPos inRangeOfArtillery [
								[_vehicle],
								_vehicleMag
							]
						)
					}
				) then {
					_failed = true;
				} else {
					private _sourceState =
						[_vehicle]
							call _captureReloadSources;

					private _shotPos =
						_targetPos getPos [
							_spread,
							random 360
						];

					_gunner lookAt _shotPos;

					private _eta =
						_vehicle getArtilleryETA [
							_shotPos,
							_vehicleMag
						];

					private _expectedCounter =
						_firedCounter + 1;

					_vehicle commandArtilleryFire [
						_shotPos,
						_vehicleMag,
						1
					];

					private _fireTimeout =
						time + 15;

					waitUntil {
						sleep 0.05;

						(
							_vehicle getVariable [
								"A3C_ARTY_CSW_FIRED_COUNTER",
								0
							]
						) >= _expectedCounter
						|| {
							time > _fireTimeout
						}
					};

					if (
						(
							_vehicle getVariable [
								"A3C_ARTY_CSW_FIRED_COUNTER",
								0
							]
						) < _expectedCounter
					) then {
						_failed = true;
					} else {
						_firedCounter =
							_expectedCounter;

						_shotNumber =
							_shotNumber + 1;

						[
							_vehicle,
							"A3C_ARTY_CSW_LOADED_RESERVATIONS",
							_orderId,
							_carryMag,
							-1
						] call _changeVehicleReservation;


						private _currentOrders =
							_vehicle getVariable [
								"A3C_ARTY_CSW_ORDERS",
								[]
							];

						private _currentIndex =
							_currentOrders findIf {
								(_x select 0)
									== _orderId
								&& {
									(_x select 2)
										== _carryMag
								}
							};

						private _remaining =
							0;

						if (_currentIndex >= 0) then {
							private _currentOrder =
								_currentOrders select
									_currentIndex;

							_remaining =
								(
									(_currentOrder select 3)
										- 1
								) max 0;

							_currentOrder set [
								3,
								_remaining
							];

							_vehicle setVariable [
								"A3C_ARTY_CSW_ORDERS",
								_currentOrders,
								true
							];
						};


						if (_shotNumber == 1) then {
							private _commsOperator =
								gunner _vehicle;

							[
								_eta max 0,
								_commsOperator,
								_requestOwner
							] spawn {
								params [
									"_eta",
									"_commsOperator",
									"_requestOwner"
								];

								sleep (
									(_eta - 7)
										max 0
								);

								if (!isNull _commsOperator) then {
									if (_requestOwner > 0) then {
										[
											[
												_commsOperator,
												"SentRequestAccomplishedSGArty"
											],
											{
												params [
													"_commsOperator",
													"_radioMessage"
												];

												if (!isNull _commsOperator) then {
													_commsOperator customRadio [
														A3C_CUSTOMRADIO_ID,
														_radioMessage
													];
												};
											}
										] remoteExec [
											"BIS_fnc_call",
											_requestOwner
										];
									} else {
										_commsOperator customRadio [
											A3C_CUSTOMRADIO_ID,
											"SentRequestAccomplishedSGArty"
										];
									};
								};
							};
						};


						private _consumed = [];

						private _consumeDetectTimeout =
							time + _reloadObservationTime;

						waitUntil {
							sleep 0.05;

							_consumed = [
								_sourceState
							] call _findConsumedReload;

							_consumed isNotEqualTo []
							|| {
								time > _consumeDetectTimeout
							}
						};


						if (_remaining > 0) then {
							private _acceptedAutoReload =
								false;

							if (
								_consumed
									isNotEqualTo []
							) then {
								_consumed params [
									"_consumedSource",
									"_consumedCarry",
									"_consumedAmount"
								];

								if (
									_consumedCarry
										== _carryMag
									&& {
										[
											_consumedSource,
											_vehicle,
											_orderId,
											_carryMag
										] call _getSourceReservation
										> 0
									}
								) then {
									[
										_consumedSource,
										_vehicle,
										_orderId,
										_carryMag,
										-1
									] call _changeSourceReservation;

									[
										_vehicle,
										"A3C_ARTY_CSW_TRANSIT_RESERVATIONS",
										_orderId,
										_carryMag,
										1
									] call _changeVehicleReservation;

									private _reloadTimeout =
										time + 15;

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
											time >
												_reloadTimeout
										}
									};

									if (
										(
											[
												_vehicle,
												_turretPath,
												_carryMag
											] call A3C_main_fnc_getACECSWLoadedMagazineData
											select 0
										) != ""
									) then {
										[
											_vehicle,
											"A3C_ARTY_CSW_TRANSIT_RESERVATIONS",
											_orderId,
											_carryMag,
											-1
										] call _changeVehicleReservation;

										[
											_vehicle,
											"A3C_ARTY_CSW_LOADED_RESERVATIONS",
											_orderId,
											_carryMag,
											1
										] call _changeVehicleReservation;

										_acceptedAutoReload =
											true;
									} else {
										_failed = true;
									};
								};

								if (
									!_failed
									&& {
										!_acceptedAutoReload
									}
								) then {
									private _reloadTimeout =
										time + 15;

									waitUntil {
										sleep 0.05;

										(
											[
												_vehicle,
												_turretPath,
												_consumedCarry
											] call A3C_main_fnc_getACECSWLoadedMagazineData
											select 0
										) != ""
										|| {
											time >
												_reloadTimeout
										}
									};

									private _foreignLoaded = [
										_vehicle,
										_turretPath,
										_consumedCarry
									] call A3C_main_fnc_getACECSWLoadedMagazineData;

									if (
										(_foreignLoaded select 0)
											!= ""
									) then {
										if !(
											[
												_vehicle,
												_turretPath,
												_foreignLoaded,
												_consumedSource
											] call _unloadLoadedMagazine
										) then {
											_failed = true;
										};
									};
								};
							};


							if (
								!_failed
								&& {
									!_acceptedAutoReload
								}
							) then {
								if !(
									[
										_vehicle,
										_orderId,
										_carryMag,
										_reservedSources
									] call A3C_ai_shared_fnc_loadACECSWReservedMagazine
								) then {
									_failed = true;
								};
							};

						} else {
							private _allOrders =
								_vehicle getVariable [
									"A3C_ARTY_CSW_ORDERS",
									[]
								];

							private _hasLaterOrder =
								_allOrders findIf {
									(_x select 3) > 0
									&& {
										!(
											(_x select 0)
												== _orderId
											&& {
												(_x select 2)
													== _carryMag
											}
										)
									}
								} >= 0;

							if (
								_consumed
									isNotEqualTo []
							) then {
								_consumed params [
									"_consumedSource",
									"_consumedCarry",
									"_consumedAmount"
								];

								private _reloadTimeout =
									time + 15;

								waitUntil {
									sleep 0.05;

									(
										[
											_vehicle,
											_turretPath,
											_consumedCarry
										] call A3C_main_fnc_getACECSWLoadedMagazineData
										select 0
									) != ""
									|| {
										time >
											_reloadTimeout
									}
								};

								private _finalLoaded = [
									_vehicle,
									_turretPath,
									_consumedCarry
								] call A3C_main_fnc_getACECSWLoadedMagazineData;

								if (
									(_finalLoaded select 0)
										!= ""
								) then {
									private _physicalAfter = [
										_consumedSource,
										_consumedCarry
									] call _getSourceAmmo;

									private _reservedAfter =
										0;

									{
										if (
											(_x select 2)
												== _consumedCarry
										) then {
											_reservedAfter =
												_reservedAfter
												+ (_x select 3);
										};

									} forEach (
										_consumedSource getVariable [
											"A3C_ARTY_CSW_SOURCE_RESERVATIONS",
											[]
										]
									);

									private _mustReturn =
										_hasLaterOrder
										|| {
											_reservedAfter
												> _physicalAfter
										};

									if (_mustReturn) then {
										if !(
											[
												_vehicle,
												_turretPath,
												_finalLoaded,
												_consumedSource
											] call _unloadLoadedMagazine
										) then {
											_failed = true;
										};
									};
								};
							};

							[
								_vehicle,
								_orderId,
								_carryMag
							] call A3C_ai_shared_fnc_releaseACECSWArtilleryOrder;
						};
					};
				};
			};
		};


		if (_failed) then {
			[
				_vehicle,
				_orderId,
				_carryMag
			] call A3C_ai_shared_fnc_releaseACECSWArtilleryOrder;

			if (_requestOwner > 0) then {
				[
					"A3C: Artillery order cancelled - weapon, range or ammunition state changed"
				] remoteExec [
					"systemChat",
					_requestOwner
				];
			};
		};
	};
};


_vehicle removeEventHandler [
	"Fired",
	_firedEH
];

_vehicle setVariable [
	"A3C_ARTY_CSW_FIRED_COUNTER",
	nil
];


if (_originalAutofireNil) then {
	_vehicle setVariable [
		"ace_csw_autofire",
		nil,
		true
	];
} else {
	_vehicle setVariable [
		"ace_csw_autofire",
		_originalAutofire,
		true
	];
};


_vehicle setVariable [
	"A3C_ARTY_CSW_WORKER_ACTIVE",
	false,
	true
];


private _pendingOrders = (
	_vehicle getVariable [
		"A3C_ARTY_CSW_ORDERS",
		[]
	]
) findIf {
	(_x param [3, 0]) > 0
} >= 0;


if (_pendingOrders) exitWith {
	[_vehicle] spawn
		A3C_ai_shared_fnc_executeACECSWArtilleryQueue;
};


if (
	alive _vehicle
	&& {!isNull gunner _vehicle}
) then {
	private _commsOperator =
		gunner _vehicle;

	[
		_vehicle,
		_commsOperator,
		_workerToken,
		+_completionOwners
	] spawn {
		params [
			"_vehicle",
			"_commsOperator",
			"_workerToken",
			"_completionOwners"
		];

		sleep (
			1 + random 2
		);

		private _sameWorkerGeneration = (
			_vehicle getVariable [
				"A3C_ARTY_CSW_WORKER_TOKEN",
				-1
			]
		) == _workerToken;

		private _workerActive =
			_vehicle getVariable [
				"A3C_ARTY_CSW_WORKER_ACTIVE",
				false
			];

		private _ordersPending = (
			_vehicle getVariable [
				"A3C_ARTY_CSW_ORDERS",
				[]
			]
		) findIf {
			(_x param [3, 0]) > 0
		} >= 0;

		if (
			_sameWorkerGeneration
			&& {!_workerActive}
			&& {!_ordersPending}
			&& {!isNull _commsOperator}
		) then {
			if (_completionOwners isEqualTo []) then {
				_commsOperator customRadio [
					A3C_CUSTOMRADIO_ID,
					"SentARTYRoundsComplete"
				];
			} else {
				{
					private _requestOwner = _x;

					[
						[
							_commsOperator,
							"SentARTYRoundsComplete"
						],
						{
							params [
								"_commsOperator",
								"_radioMessage"
							];

							if (!isNull _commsOperator) then {
								_commsOperator customRadio [
									A3C_CUSTOMRADIO_ID,
									_radioMessage
								];
							};
						}
					] remoteExec [
						"BIS_fnc_call",
						_requestOwner
					];

				} forEach _completionOwners;
			};
		};
	};
};
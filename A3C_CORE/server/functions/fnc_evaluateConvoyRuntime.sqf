// A3C_server_fnc_evaluateConvoyRuntime

/*
 * Evaluates longitudinal convoy control decisions without applying
 * any vehicle, AI or speed commands.
 *
 * The calculation uses road-route progress, physical vehicle length,
 * speed-dependent time headway and relative closing speed.
 *
 * Returns:
 *
 * [
 *     [
 *         _vehicle,
 *         _group,
 *         _trackingMode,
 *         _controlMode,
 *         _routeProgress,
 *         _centreGap,
 *         _bumperGap,
 *         _desiredGap,
 *         _currentSpeedKmh,
 *         _speedAheadKmh,
 *         _recommendedSpeedKmh, // -1 means no speed command
 *         _timeToCollision,
 *         _modelAcceleration,
 *         _convoyCruiseSpeedKmh,
 *         _freeSpeedTargetKmh,
 *         _gapReferenceValid,
 *         _gapReferenceMode,
 *         _gapReferenceReason
 *     ],
 *     ...
 * ]
 */

params [
	["_runtimeID", "", [""]]
];

if (
	!isServer
	|| {_runtimeID == ""}
	|| {isNil "A3C_CONVOY_RUNTIME_STATES"}
) exitWith {
	[]
};

private _projectionResults = [
	_runtimeID,
	false
] call A3C_server_fnc_updateConvoyRuntimeProjections;

private _runtimeState =
	A3C_CONVOY_RUNTIME_STATES getOrDefault [
		_runtimeID,
		createHashMap
	];

if (
	count _runtimeState == 0
	|| {_projectionResults isEqualTo []}
) exitWith {
	[]
};

private _vehicleStates =
	_runtimeState getOrDefault [
		"vehicleStates",
		[]
	];

private _runtimeRoute =
	_runtimeState getOrDefault [
		"route",
		[]
	];

private _masterRouteAvailable =
	_runtimeRoute isEqualType []
	&& {
		count _runtimeRoute == 4
	}
	&& {
		!((_runtimeRoute select 0) isEqualTo [])
	};

private _gapResolutionAllowed =
	_runtimeState getOrDefault [
		"gapResolutionAllowed",
		_masterRouteAvailable
	];

/*
 * Model parameters.
 *
 * Speeds inside the model use metres per second. Returned and stored
 * recommended speeds use kilometres per hour for limitSpeed.
 */
private _minimumGap = 8;
private _timeHeadway = 1.8;
private _maximumAcceleration = 1.2;
private _comfortableDeceleration = 2;
private _emergencyDeceleration = 5;
private _evaluationInterval = 1;
private _convoyFastSpeedFraction = 0.8;
private _followerCatchUpMultiplier = 1.25;

/*
 * A recently confirmed gap may be conservatively extrapolated while
 * route references are being reacquired.
 */
private _lastGapFallbackDuration = 3;

/*
 * If no usable longitudinal gap remains, the follower must not be
 * allowed to travel faster than its predecessor.
 */
private _uncertainReferenceSpeedMargin = 2;

private _getVehicleLength = {
	params [
		"_vehicle",
		"_vehicleState"
	];

	private _storedLength =
		_vehicleState getOrDefault [
			"vehicleLength",
			-1
		];

	if (_storedLength > 0) exitWith {
		_storedLength
	};

	private _vehicleLength = 4;

	if (!isNull _vehicle) then {
		private _boundingBox =
			boundingBoxReal _vehicle;

		if (count _boundingBox >= 2) then {
			private _minimumBounds =
				_boundingBox select 0;

			private _maximumBounds =
				_boundingBox select 1;

			if (
				count _minimumBounds >= 2
				&& {count _maximumBounds >= 2}
			) then {
				_vehicleLength =
					2 max abs (
						(_maximumBounds select 1)
							- (_minimumBounds select 1)
					);
			};
		};
	};

	_vehicleState set [
		"vehicleLength",
		_vehicleLength
	];

	_vehicleLength
};

private _getVehicleSpeedProfile = {
	params [
		"_vehicle",
		"_vehicleState"
	];

	private _normalSpeedMs =
		_vehicleState getOrDefault [
			"normalSpeedMs",
			-1
		];

	private _fastSpeedMs =
		_vehicleState getOrDefault [
			"fastSpeedMs",
			-1
		];

	if (
		_normalSpeedMs > 0
		&& {_fastSpeedMs > 0}
	) exitWith {
		[
			_normalSpeedMs,
			_fastSpeedMs
		]
	};

	if (isNull _vehicle) exitWith {
		[
			1,
			1
		]
	};

	private _configMaximumSpeedMs =
		(
			getNumber (
				configOf _vehicle
					>> "maxSpeed"
			)
		) / 3.6;

	_normalSpeedMs =
		_vehicle getSpeed "NORMAL";

	_fastSpeedMs =
		_vehicle getSpeed "FAST";

	if (_normalSpeedMs <= 0) then {
		_normalSpeedMs =
			if (_configMaximumSpeedMs > 0) then {
				_configMaximumSpeedMs * 0.6
			} else {
				1
			};
	};

	if (_fastSpeedMs <= 0) then {
		_fastSpeedMs =
			if (_configMaximumSpeedMs > 0) then {
				_configMaximumSpeedMs
			} else {
				_normalSpeedMs
			};
	};

	_normalSpeedMs =
		1 max _normalSpeedMs;

	_fastSpeedMs =
		_normalSpeedMs max _fastSpeedMs;

	_vehicleState set [
		"normalSpeedMs",
		_normalSpeedMs
	];

	_vehicleState set [
		"fastSpeedMs",
		_fastSpeedMs
	];

	[
		_normalSpeedMs,
		_fastSpeedMs
	]
};

private _leaderNormalSpeedMs = -1;
private _slowestFastSpeedMs = -1;

{
	private _vehicleState =
		_x;

	private _vehicle =
		_vehicleState getOrDefault [
			"vehicle",
			objNull
		];

	private _trackingMode =
		_vehicleState getOrDefault [
			"mode",
			"INITIALIZING"
		];

	if (
		!isNull _vehicle
		&& {alive _vehicle}
		&& {
			!(
				_trackingMode in [
					"INOPERABLE",
					"RETIRED"
				]
			)
		}
	) then {
		private _speedProfile = [
			_vehicle,
			_vehicleState
		] call _getVehicleSpeedProfile;

		_speedProfile params [
			"_normalSpeedMs",
			"_fastSpeedMs"
		];

		if (_leaderNormalSpeedMs < 0) then {
			_leaderNormalSpeedMs =
				_normalSpeedMs;
		};

		_slowestFastSpeedMs =
			if (_slowestFastSpeedMs < 0) then {
				_fastSpeedMs
			} else {
				_slowestFastSpeedMs
					min _fastSpeedMs
			};
	};
} forEach _vehicleStates;

private _convoyCruiseSpeedMs =
	if (
		_leaderNormalSpeedMs <= 0
		|| {_slowestFastSpeedMs <= 0}
	) then {
		1
	} else {
		1 max (
			_leaderNormalSpeedMs
				min (
					_slowestFastSpeedMs
						* _convoyFastSpeedFraction
				)
		)
	};

private _firstActiveIndex =
	_vehicleStates findIf {
		private _vehicleState = _x;

		private _vehicle =
			_vehicleState getOrDefault [
				"vehicle",
				objNull
			];

		!isNull _vehicle
		&& {alive _vehicle}
		&& {
			!(
				_vehicleState getOrDefault [
					"retired",
					false
				]
			)
		}
	};

private _evaluations = [];

{
	private _vehicleState = _x;

	private _vehicle =
		_vehicleState getOrDefault [
			"vehicle",
			objNull
		];

	private _group =
		_vehicleState getOrDefault [
			"group",
			grpNull
		];

	private _trackingMode =
		_vehicleState getOrDefault [
			"mode",
			"INITIALIZING"
		];

	private _retired =
		_vehicleState getOrDefault [
			"retired",
			false
		];

	private _routeProgress =
		_vehicleState getOrDefault [
			"routeProgress",
			-1
		];

	private _centreGap =
		_vehicleState getOrDefault [
			"gapToVehicleAhead",
			-1
		];

	private _gapReferenceValid =
		_vehicleState getOrDefault [
			"gapReferenceValid",
			false
		];

	private _gapReferenceMode =
		_vehicleState getOrDefault [
			"gapReferenceMode",
			"NONE"
		];

	private _gapReferenceReason =
		_vehicleState getOrDefault [
			"gapReferenceReason",
			"NOT_EVALUATED"
		];

	private _vehicleLength = [
		_vehicle,
		_vehicleState
	] call _getVehicleLength;

	private _currentSpeedKmh =
		if (isNull _vehicle) then {
			0
		} else {
			0 max speed _vehicle
		};

	private _currentSpeedMs =
		_currentSpeedKmh / 3.6;

	private _vehicleSpeedProfile = [
		_vehicle,
		_vehicleState
	] call _getVehicleSpeedProfile;

	_vehicleSpeedProfile params [
		"_normalSpeedMs",
		"_fastSpeedMs"
	];

	private _isLeader =
		_firstActiveIndex >= 0
		&& {
			_forEachIndex
				== _firstActiveIndex
		};

	private _freeSpeedMs =
		if (_isLeader) then {
			_convoyCruiseSpeedMs
		} else {
			_fastSpeedMs min (
				_convoyCruiseSpeedMs
					* _followerCatchUpMultiplier
			)
		};

	_freeSpeedMs =
		1 max _freeSpeedMs;

	private _speedAheadKmh = -1;
	private _bumperGap = -1;
	private _desiredGap = -1;
	private _timeToCollision = -1;
	private _modelAcceleration = 0;
	private _recommendedSpeedKmh = -1;
	private _controlMode = "INITIALIZING";

	private _vehicleOperational =
		!_retired
		&& {!isNull _vehicle}
		&& {alive _vehicle}
		&& {
			_trackingMode
				isNotEqualTo "INOPERABLE"
		};

	if (!_gapResolutionAllowed) then {
		_controlMode =
			"NO_ROUTE";
	} else {
		if (!_vehicleOperational) then {
			_controlMode =
				_trackingMode;
		} else {
			if (
				_trackingMode
					== "WAITING_FOR_DRIVER"
			) then {
				_controlMode =
					"WAITING_FOR_DRIVER";
			} else {
				if (_isLeader) then {
					_controlMode =
						"LEADER";

					_recommendedSpeedKmh =
						_freeSpeedMs * 3.6;
				} else {
					private _vehicleAheadStateIndex =
						_vehicleState getOrDefault [
							"vehicleAheadStateIndex",
							-1
						];

					private _vehicleAheadState =
						if (
							_vehicleAheadStateIndex >= 0
							&& {
								_vehicleAheadStateIndex
									< count _vehicleStates
							}
						) then {
							_vehicleStates select
								_vehicleAheadStateIndex
						} else {
							createHashMap
						};

					private _vehicleAhead =
						_vehicleAheadState getOrDefault [
							"vehicle",
							objNull
						];

					private _storedVehicleAhead =
						_vehicleState getOrDefault [
							"vehicleAhead",
							objNull
						];

					private _predecessorIdentityValid =
						_vehicleAheadStateIndex >= 0
						&& {
							_vehicleAheadStateIndex
								< count _vehicleStates
						}
						&& {
							!isNull _vehicleAhead
						}
						&& {
							_vehicleAhead
								isEqualTo _storedVehicleAhead
						};

					private _vehicleAheadAvailable =
						_predecessorIdentityValid
						&& {alive _vehicleAhead};

					if (_vehicleAheadAvailable) then {
						_speedAheadKmh =
							0 max speed _vehicleAhead;
					};

					private _referenceUsable =
						_gapReferenceValid
						&& {
							_vehicleAheadAvailable
						};

					private _usingLastValidGap =
						false;

					/*
					 * A very short reference interruption uses the
					 * last confirmed gap, reduced by the distance
					 * the follower could have closed since then.
					 *
					 * The estimate never assumes that the gap grew.
					 */
					if (
						!_referenceUsable
						&& {_vehicleAheadAvailable}
					) then {
						private _lastValidGap =
							_vehicleState getOrDefault [
								"lastValidGapToVehicleAhead",
								-1
							];

						private _lastValidGapTime =
							_vehicleState getOrDefault [
								"lastValidGapTime",
								-1
							];

						private _lastGapAge =
							if (_lastValidGapTime >= 0) then {
								serverTime
									- _lastValidGapTime
							} else {
								-1
							};

						if (
							_lastValidGapTime >= 0
							&& {_lastGapAge >= 0}
							&& {
								_lastGapAge
									<= _lastGapFallbackDuration
							}
						) then {
							private _closingSpeedMs =
								0 max (
									_currentSpeedMs
										- (
											_speedAheadKmh
												/ 3.6
										)
								);

							_centreGap =
								_lastValidGap
									- (
										_closingSpeedMs
											* _lastGapAge
									);

							_referenceUsable = true;
							_usingLastValidGap = true;
						};
					};

					if (_referenceUsable) then {
						private _speedAheadMs =
							_speedAheadKmh / 3.6;

						private _vehicleAheadLength = [
							_vehicleAhead,
							_vehicleAheadState
						] call _getVehicleLength;

						_bumperGap =
							_centreGap
								- (
									(
										_vehicleLength
											+ _vehicleAheadLength
									) / 2
								);

						private _relativeSpeedMs =
							_currentSpeedMs
								- _speedAheadMs;

						if (
							_relativeSpeedMs > 0
							&& {_bumperGap > 0}
						) then {
							_timeToCollision =
								_bumperGap
									/ _relativeSpeedMs;
						};

						private _closingGapComponent =
							(
								_currentSpeedMs
									* _relativeSpeedMs
							)
							/ (
								2
								* sqrt (
									_maximumAcceleration
										* _comfortableDeceleration
								)
							);

						_desiredGap =
							_minimumGap
								+ (
									0 max (
										(
											_currentSpeedMs
												* _timeHeadway
										)
										+ _closingGapComponent
									)
								);

						private _safeBumperGap =
							0.5 max _bumperGap;

						private _freeSpeedRatio =
							_currentSpeedMs
								/ _freeSpeedMs;

						private _interactionRatio =
							_desiredGap
								/ _safeBumperGap;

						_modelAcceleration =
							_maximumAcceleration
								* (
									1
									- (_freeSpeedRatio ^ 4)
									- (_interactionRatio ^ 2)
								);

						_modelAcceleration =
							(-_emergencyDeceleration) max (
								_maximumAcceleration min
									_modelAcceleration
							);

						private _recommendedSpeedMs =
							0 max (
								_currentSpeedMs
									+ (
										_modelAcceleration
											* _evaluationInterval
									)
							);

						if (
							_currentSpeedMs
								<= _freeSpeedMs
						) then {
							_recommendedSpeedMs =
								_recommendedSpeedMs min
									_freeSpeedMs;
						};

						_recommendedSpeedKmh =
							_recommendedSpeedMs * 3.6;

						if (
							_centreGap < -2
							|| {_bumperGap <= 1}
							|| {
								_timeToCollision >= 0
								&& {
									_timeToCollision < 1.5
								}
							}
						) then {
							_controlMode =
								"STOPPED";

							_recommendedSpeedKmh =
								0.001;
						} else {
							if (
								_modelAcceleration
									< -0.75
							) then {
								_controlMode =
									"BRAKE";
							} else {
								if (
									_usingLastValidGap
								) then {
									_controlMode =
										"REFERENCE_FALLBACK";
								} else {
									if (
										_bumperGap
											> (
												_desiredGap
													* 1.35
											)
										&& {
											_recommendedSpeedKmh
												> (
													_currentSpeedKmh
														+ 1
												)
										}
									) then {
										_controlMode =
											"CATCHUP";
									} else {
										_controlMode =
											"NORMAL";
									};
								};
							};
						};
					} else {
						/*
						 * Losing the predecessor reference must not
						 * remove all control and grant permission to
						 * overtake.
						 *
						 * If the predecessor still exists, the
						 * follower is capped slightly below its predecessor's speed.
						 * If the predecessor itself
						 * is unavailable, the safe response is a
						 * temporary hold until convoy membership is
						 * resolved.
						 */
						if (_vehicleAheadAvailable) then {
							_controlMode =
								"REFERENCE_UNCERTAIN";

							_recommendedSpeedKmh =
								0.001 max (
									_speedAheadKmh
										- _uncertainReferenceSpeedMargin
								);
						} else {
							_controlMode =
								"REFERENCE_LOST";

							_recommendedSpeedKmh =
								0.001;
						};
					};
				};
			};
		};
	};

	_vehicleState set [
		"controlMode",
		_controlMode
	];

	_vehicleState set [
		"centreGapToVehicleAhead",
		_centreGap
	];

	_vehicleState set [
		"bumperGapToVehicleAhead",
		_bumperGap
	];

	_vehicleState set [
		"desiredGap",
		_desiredGap
	];

	_vehicleState set [
		"speedAhead",
		_speedAheadKmh
	];

	_vehicleState set [
		"recommendedSpeed",
		_recommendedSpeedKmh
	];

	_vehicleState set [
		"timeToCollision",
		_timeToCollision
	];

	_vehicleState set [
		"modelAcceleration",
		_modelAcceleration
	];

	_vehicleState set [
		"freeSpeedTarget",
		_freeSpeedMs * 3.6
	];

	_vehicleState set [
		"lastEvaluationTime",
		serverTime
	];

	_evaluations pushBack [
		_vehicle,
		_group,
		_trackingMode,
		_controlMode,
		_routeProgress,
		_centreGap,
		_bumperGap,
		_desiredGap,
		_currentSpeedKmh,
		_speedAheadKmh,
		_recommendedSpeedKmh,
		_timeToCollision,
		_modelAcceleration,
		_convoyCruiseSpeedMs * 3.6,
		_freeSpeedMs * 3.6,
		_gapReferenceValid,
		_gapReferenceMode,
		_gapReferenceReason
	];
} forEach _vehicleStates;

_runtimeState set [
	"convoyCruiseSpeed",
	_convoyCruiseSpeedMs * 3.6
];

_runtimeState set [
	"vehicleStates",
	_vehicleStates
];

_runtimeState set [
	"lastEvaluationTime",
	serverTime
];

_runtimeState set [
	"status",
	"SHADOW_READY"
];

_runtimeState set [
	"updatedAt",
	serverTime
];

A3C_CONVOY_RUNTIME_STATES set [
	_runtimeID,
	_runtimeState
];

_evaluations
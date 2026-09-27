// A3C_server_fnc_updateConvoyRuntimeProjections

/*
 * Updates every registered vehicle's position along the convoy's
 * cached road route.
 *
 * No movement, AI or speed commands are issued.
 *
 * Returns:
 *
 * [
 *     [
 *         _vehicle,
 *         _group,
 *         _routeProgress,
 *         _segmentIndex,
 *         _distanceFromRoute,
 *         _gapToVehicleAhead,
 *         _mode,
 *         _usedFullRouteSearch,
 *         _gapReferenceValid,
 *         _gapReferenceMode,
 *         _gapReferenceReason,
 *         _masterRouteGap
 *     ],
 *     ...
 * ]
 */

params [
	["_runtimeID", "", [""]],
	["_forceRouteRebuild", false, [true]]
];

if (
	!isServer
	|| {_runtimeID == ""}
	|| {isNil "A3C_CONVOY_RUNTIME_STATES"}
) exitWith {
	[]
};

private _roadRoute = [
	_runtimeID,
	_forceRouteRebuild
] call A3C_server_fnc_updateConvoyRuntimeRoute;

/*
 * The route updater can replace values in the runtime state, so fetch
 * the authoritative state after calling it.
 */
private _runtimeState =
	A3C_CONVOY_RUNTIME_STATES getOrDefault [
		_runtimeID,
		createHashMap
	];

if (count _runtimeState == 0) exitWith {
	[]
};

private _vehicleStates =
	_runtimeState getOrDefault [
		"vehicleStates",
		[]
	];

private _routeGeneration =
	_runtimeState getOrDefault [
		"routeGeneration",
		0
	];

private _routeCoordinateGeneration =
	_runtimeState getOrDefault [
		"routeCoordinateGeneration",
		0
	];

private _currentTime =
	serverTime;

private _projectionResults = [];

private _runtimeStatus =
	_runtimeState getOrDefault [
		"status",
		""
	];

private _destinationPosition =
	_runtimeState getOrDefault [
		"destinationPosition",
		[]
	];

private _routeAvailable =
	_roadRoute isEqualType []
	&& {
		count _roadRoute == 4
	}
	&& {
		!((_roadRoute select 0) isEqualTo [])
	};

/*
 * These states mean that a valid destination still exists but
 * the shared master route is temporarily unavailable.
 *
 * Pair control may continue through the common-anchor resolver.
 */
private _temporaryRouteFailure =
	!_routeAvailable
	&& {
		count _destinationPosition >= 2
	}
	&& {
		_runtimeStatus in [
			"NO_ROUTE",
			"ROUTE_RETRY_PENDING"
		]
	};

private _gapResolutionAllowed =
	_routeAvailable
	|| {_temporaryRouteFailure};



/*
 * First pass: independently project every vehicle.
 */
{
	private _vehicleState =
		_x;

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

	private _retired =
		_vehicleState getOrDefault [
			"retired",
			false
		];

	private _mode = "TRACKED";
	private _routeProgress = -1;
	private _segmentIndex = -1;
	private _distanceFromRoute = -1;
	private _projectedPosition = [];
	private _segmentFraction = -1;
	private _usedFullRouteSearch = false;
	private _projectionValid = false;
	private _projectionReason =
		"NOT_EVALUATED";

	if (_retired) then {
		_mode = "RETIRED";
		_projectionReason =
			"RETIRED";
	} else {
		if (
			isNull _vehicle
			|| {!alive _vehicle}
		) then {
			_mode = "INOPERABLE";
			_projectionReason =
				"VEHICLE_INOPERABLE";
		} else {
			if (!_routeAvailable) then {
				_mode = "NO_ROUTE";
				_projectionValid = false;

				_projectionReason =
					if (_temporaryRouteFailure) then {
						"TEMPORARY_MASTER_ROUTE_FAILURE"
					} else {
						_runtimeStatus
					};
			} else {
				private _storedRouteCoordinateGeneration =
					_vehicleState getOrDefault [
					"routeCoordinateGeneration",
					-1
				];

				private _sameRouteCoordinate =
					_storedRouteCoordinateGeneration
						== _routeCoordinateGeneration;

				private _previousSegmentIndex =
					if (_sameRouteCoordinate) then {
						_vehicleState getOrDefault [
							"segmentIndex",
							-1
						]
					} else {
						-1
					};

				private _expectedProgress =
					if (_sameRouteCoordinate) then {
						_vehicleState getOrDefault [
							"routeProgress",
							-1
						]
					} else {
						-1
					};

				private _nextFullRouteSearchTime =
					_vehicleState getOrDefault [
						"nextFullRouteSearchTime",
						0
					];

				private _allowFullRouteSearch =
					!_sameRouteCoordinate
					|| {
						_currentTime
							>= _nextFullRouteSearchTime
					};

				private _projection = [
					getPosASL _vehicle,
					_roadRoute,
					_previousSegmentIndex,
					_expectedProgress,
					3,
					8,
					40,
					2,
					_allowFullRouteSearch
				] call A3C_main_fnc_projectPositionOntoRoadRoute;

				if (_projection isEqualTo []) then {
					_mode = "NO_PROJECTION";
					_projectionReason =
						"NO_PROJECTION";
				} else {
					_projection params [
						"_projectionProgress",
						"_projectionSegmentIndex",
						"_projectionDistance",
						"_projectionPosition",
						"_projectionFraction",
						"_projectionUsedFullSearch"
					];

					_routeProgress =
						_projectionProgress;

					_segmentIndex =
						_projectionSegmentIndex;

					_distanceFromRoute =
						_projectionDistance;

					_projectedPosition =
						_projectionPosition;

					_segmentFraction =
						_projectionFraction;

					_usedFullRouteSearch =
						_projectionUsedFullSearch;

					if (_usedFullRouteSearch) then {
						_vehicleState set [
							"nextFullRouteSearchTime",
							_currentTime + 5
						];
					};

					if (_distanceFromRoute > 40) then {
						_mode = "OFF_ROUTE";
						_projectionValid = false;
						_projectionReason =
							"DISTANT_MASTER_ROUTE";
					} else {
						_projectionValid = true;
						_projectionReason =
							"PROJECTED";
					};

					private _livingCrew =
						(crew _vehicle) select {
							alive _x
						};

					private _driver =
						driver _vehicle;

					if (
						_livingCrew isEqualTo []
						|| {!canMove _vehicle}
					) then {
						_mode = "INOPERABLE";
					} else {
						if (
							isNull _driver
							|| {!alive _driver}
						) then {
							_mode =
								"WAITING_FOR_DRIVER";

							if (
								_vehicleState getOrDefault [
									"driverMissingSince",
									-1
								] < 0
							) then {
								_vehicleState set [
									"driverMissingSince",
									_currentTime
								];
							};
						} else {
							_vehicleState set [
								"driverMissingSince",
								-1
							];
						};
					};
				};
			};
		};
	};

	_vehicleState set [
		"mode",
		_mode
	];

	_vehicleState set [
		"projectionValid",
		_projectionValid
	];

	_vehicleState set [
		"projectionReason",
		_projectionReason
	];

	_vehicleState set [
		"routeGeneration",
		_routeGeneration
	];

	_vehicleState set [
		"routeCoordinateGeneration",
		_routeCoordinateGeneration
	];

	_vehicleState set [
		"routeProgress",
		_routeProgress
	];

	_vehicleState set [
		"segmentIndex",
		_segmentIndex
	];

	_vehicleState set [
		"distanceFromRoute",
		_distanceFromRoute
	];

	_vehicleState set [
		"projectedPosition",
		_projectedPosition
	];

	_vehicleState set [
		"segmentFraction",
		_segmentFraction
	];

	_vehicleState set [
		"usedFullRouteSearch",
		_usedFullRouteSearch
	];

	_vehicleState set [
		"lastProjectionTime",
		_currentTime
	];

	_vehicleState set [
		"currentSpeed",
		if (isNull _vehicle) then {
			0
		} else {
			speed _vehicle
		}
	];
} forEach _vehicleStates;

/*
 * Second pass: resolve each living vehicle against the nearest
 * preceding living, non-retired vehicle in permanent convoy order.
 *
 * Dead, deleted and retired entries remain in the frozen runtime
 * array, but they must not interrupt the active predecessor chain.
 *
 * The common master-route coordinate is preferred. When that
 * coordinate is unavailable or untrustworthy, both vehicles are
 * compared against the same downstream destination.
 */
private _routeOrderValid =
	_gapResolutionAllowed;

private _previousReferenceStateIndex = -1;

{
	private _vehicleState =
		_x;

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

	private _retired =
		_vehicleState getOrDefault [
			"retired",
			false
		];

	private _referenceEligible =
		!_retired
		&& {!isNull _vehicle}
		&& {alive _vehicle};

	private _gapToVehicleAhead = -1;
	private _masterRouteGap = -1;
	private _commonAnchorGap = -1;
	private _gapReferenceValid = false;
	private _gapReferenceMode = "NONE";
	private _gapReferenceReason =
		"NOT_EVALUATED";
	private _gapReferenceAnchor = [];
	private _distanceToGapReference = -1;
	private _distanceAheadToGapReference = -1;

	if (!_referenceEligible) then {
		_gapReferenceReason =
			if (_retired) then {
				"RETIRED"
			} else {
				"CURRENT_VEHICLE_INOPERABLE"
			};

		_vehicleState set [
			"vehicleAheadStateIndex",
			-1
		];

		_vehicleState set [
			"vehicleAhead",
			objNull
		];

		_vehicleState set [
			"vehicleAheadGroup",
			grpNull
		];

		_vehicleState set [
			"lastValidGapToVehicleAhead",
			-1
		];

		_vehicleState set [
			"lastValidGapTime",
			-1
		];

		_vehicleState set [
			"gapReferenceMissingSince",
			-1
		];

		_vehicleState set [
			"pairRouteCache",
			createHashMap
		];
	} else {
		if (_previousReferenceStateIndex < 0) then {
			/*
			 * This is the first living vehicle in the frozen order.
			 * Earlier dead or retired entries do not prevent it from
			 * becoming the active convoy leader.
			 */
			_gapReferenceMode =
				"LEADER";

			_gapReferenceReason =
				"NO_PREDECESSOR";

			_vehicleState set [
				"vehicleAheadStateIndex",
				-1
			];

			_vehicleState set [
				"vehicleAhead",
				objNull
			];

			_vehicleState set [
				"vehicleAheadGroup",
				grpNull
			];

			_vehicleState set [
				"lastValidGapToVehicleAhead",
				-1
			];

			_vehicleState set [
				"lastValidGapTime",
				-1
			];

			_vehicleState set [
				"gapReferenceMissingSince",
				-1
			];

			_vehicleState set [
				"pairRouteCache",
				createHashMap
			];
		} else {
			private _vehicleAheadState =
				_vehicleStates select
					_previousReferenceStateIndex;

			private _vehicleAhead =
				_vehicleAheadState getOrDefault [
					"vehicle",
					objNull
				];

			private _vehicleAheadGroup =
				_vehicleAheadState getOrDefault [
					"group",
					grpNull
				];

			private _storedVehicleAheadStateIndex =
				_vehicleState getOrDefault [
					"vehicleAheadStateIndex",
					-1
				];

			private _storedVehicleAhead =
				_vehicleState getOrDefault [
					"vehicleAhead",
					objNull
				];

			private _predecessorChanged =
				_storedVehicleAheadStateIndex
					!= _previousReferenceStateIndex
				|| {
					!(
						_storedVehicleAhead
							isEqualTo _vehicleAhead
					)
				};

			_vehicleState set [
				"vehicleAheadStateIndex",
				_previousReferenceStateIndex
			];

			_vehicleState set [
				"vehicleAhead",
				_vehicleAhead
			];

			_vehicleState set [
				"vehicleAheadGroup",
				_vehicleAheadGroup
			];

			/*
			 * A cached gap or cached pair route belongs to one exact
			 * predecessor/follower pair. It cannot survive a change
			 * of predecessor.
			 */
			if (_predecessorChanged) then {
				_vehicleState set [
					"lastValidGapToVehicleAhead",
					-1
				];

				_vehicleState set [
					"lastValidGapTime",
					-1
				];

				_vehicleState set [
					"gapReferenceMissingSince",
					-1
				];

				_vehicleState set [
					"pairRouteCache",
					createHashMap
				];
			};

			if (_gapResolutionAllowed) then {
				private _gapResult = [
					_runtimeID,
					_vehicleAheadState,
					_vehicleState
				] call A3C_server_fnc_resolveConvoyPairGap;

				_gapReferenceValid =
					_gapResult getOrDefault [
						"valid",
						false
					];

				_gapReferenceMode =
					_gapResult getOrDefault [
						"mode",
						"NONE"
					];

				_gapReferenceReason =
					_gapResult getOrDefault [
						"reason",
						"UNRESOLVED"
					];

				_gapToVehicleAhead =
					_gapResult getOrDefault [
						"centreGap",
						-1
					];

				_masterRouteGap =
					_gapResult getOrDefault [
						"masterRouteGap",
						-1
					];

				_commonAnchorGap =
					_gapResult getOrDefault [
						"commonAnchorGap",
						-1
					];

				_gapReferenceAnchor =
					+(
						_gapResult getOrDefault [
							"anchorPosition",
							[]
						]
					);

				_distanceToGapReference =
					_gapResult getOrDefault [
						"distanceCurrentToAnchor",
						-1
					];

				_distanceAheadToGapReference =
					_gapResult getOrDefault [
						"distanceAheadToAnchor",
						-1
					];

				private _resolvedPairRouteCache =
					_gapResult getOrDefault [
						"pairRouteCache",
						createHashMap
					];

				/*
				 * MASTER_ROUTE results intentionally return no
				 * replacement cache. Preserve a previous common-route
				 * cache until its own validation rejects it.
				 */
				if (
					count _resolvedPairRouteCache > 0
				) then {
					_vehicleState set [
						"pairRouteCache",
						_resolvedPairRouteCache
					];
				};

				if (_gapReferenceValid) then {
					_vehicleState set [
						"lastValidGapToVehicleAhead",
						_gapToVehicleAhead
					];

					_vehicleState set [
						"lastValidGapTime",
						_currentTime
					];

					_vehicleState set [
						"gapReferenceMissingSince",
						-1
					];

					if (_gapToVehicleAhead < -2) then {
						_routeOrderValid = false;
					};
				} else {
					_gapToVehicleAhead = -1;
					_routeOrderValid = false;

					if (
						_vehicleState getOrDefault [
							"gapReferenceMissingSince",
							-1
						] < 0
					) then {
						_vehicleState set [
							"gapReferenceMissingSince",
							_currentTime
						];
					};
				};
			} else {
				/*
				 * There is no usable destination. This is a genuine
				 * terminal/unavailable route state rather than a
				 * temporary master-route failure.
				 */
				_gapReferenceReason =
					if (_runtimeStatus == "") then {
						"GAP_RESOLUTION_UNAVAILABLE"
					} else {
						_runtimeStatus
					};

				_vehicleState set [
					"lastValidGapToVehicleAhead",
					-1
				];

				_vehicleState set [
					"lastValidGapTime",
					-1
				];

				_vehicleState set [
					"gapReferenceMissingSince",
					-1
				];

				_vehicleState set [
					"pairRouteCache",
					createHashMap
				];

				_routeOrderValid = false;
			};
		};

		/*
		 * Only living, non-retired vehicles advance the predecessor
		 * chain. An alive but immobilized or driverless vehicle
		 * remains a physical convoy predecessor.
		 */
		_previousReferenceStateIndex =
			_forEachIndex;
	};

	_vehicleState set [
		"gapToVehicleAhead",
		_gapToVehicleAhead
	];

	_vehicleState set [
		"masterRouteGapToVehicleAhead",
		_masterRouteGap
	];

	_vehicleState set [
		"commonAnchorGapToVehicleAhead",
		_commonAnchorGap
	];

	_vehicleState set [
		"gapReferenceValid",
		_gapReferenceValid
	];

	_vehicleState set [
		"gapReferenceMode",
		_gapReferenceMode
	];

	_vehicleState set [
		"gapReferenceReason",
		_gapReferenceReason
	];

	_vehicleState set [
		"gapReferenceAnchor",
		_gapReferenceAnchor
	];

	_vehicleState set [
		"distanceToGapReference",
		_distanceToGapReference
	];

	_vehicleState set [
		"distanceAheadToGapReference",
		_distanceAheadToGapReference
	];

	_vehicleState set [
		"gapReferenceUpdatedAt",
		_currentTime
	];

	_projectionResults pushBack [
		_vehicle,
		_group,
		_vehicleState getOrDefault [
			"routeProgress",
			-1
		],
		_vehicleState getOrDefault [
			"segmentIndex",
			-1
		],
		_vehicleState getOrDefault [
			"distanceFromRoute",
			-1
		],
		_gapToVehicleAhead,
		_vehicleState getOrDefault [
			"mode",
			""
		],
		_vehicleState getOrDefault [
			"usedFullRouteSearch",
			false
		],
		_gapReferenceValid,
		_gapReferenceMode,
		_gapReferenceReason,
		_masterRouteGap
	];
} forEach _vehicleStates;

_runtimeState set [
	"vehicleStates",
	_vehicleStates
];

_runtimeState set [
	"routeOrderValid",
	_routeOrderValid
];

_runtimeState set [
	"gapResolutionAllowed",
	_gapResolutionAllowed
];

_runtimeState set [
	"temporaryRouteFailure",
	_temporaryRouteFailure
];

_runtimeState set [
	"gapResolutionUpdatedAt",
	_currentTime
];

_runtimeState set [
	"projectionUpdatedAt",
	_currentTime
];

_runtimeState set [
	"updatedAt",
	_currentTime
];

A3C_CONVOY_RUNTIME_STATES set [
	_runtimeID,
	_runtimeState
];

if (
	missionNamespace getVariable [
		"A3C_DEBUG_CONVOY_SHADOW",
		false
	]
) then {
	diag_log format [
		"[A3C CONVOY SHADOW] Runtime: %1 | Route generation: %2 | Order valid: %3 | Vehicles: %4",
		_runtimeID,
		_routeGeneration,
		_routeOrderValid,
		count _projectionResults
	];

	{
		diag_log format [
			"[A3C CONVOY SHADOW] Order: %1 | Vehicle: %2 | Group: %3 | Progress: %4 | Segment: %5 | Route distance: %6 | Resolved gap: %7 | Mode: %8 | Full search: %9 | Gap valid: %10 | Gap mode: %11 | Gap reason: %12 | Master gap: %13",
			_forEachIndex,
			_x select 0,
			_x select 1,
			_x select 2,
			_x select 3,
			_x select 4,
			_x select 5,
			_x select 6,
			_x select 7,
			_x select 8,
			_x select 9,
			_x select 10,
			_x select 11
		];
	} forEach _projectionResults;
};

_projectionResults
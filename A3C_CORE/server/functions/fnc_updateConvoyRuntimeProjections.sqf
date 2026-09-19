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
 *         _usedFullRouteSearch
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

/*
 * A missing route is a valid runtime condition. Record it without
 * discarding the permanent vehicle order.
 */
if (_roadRoute isEqualTo []) exitWith {
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

		private _retired =
			_vehicleState getOrDefault [
				"retired",
				false
			];

		private _mode =
			if (_retired) then {
				"RETIRED"
			} else {
				"NO_ROUTE"
			};

		_vehicleState set [
			"mode",
			_mode
		];

		_vehicleState set [
			"routeProgress",
			-1
		];

		_vehicleState set [
			"segmentIndex",
			-1
		];

		_vehicleState set [
			"distanceFromRoute",
			-1
		];

		_vehicleState set [
			"projectedPosition",
			[]
		];

		_vehicleState set [
			"segmentFraction",
			-1
		];

		_vehicleState set [
			"gapToVehicleAhead",
			-1
		];

		_vehicleState set [
			"usedFullRouteSearch",
			false
		];

		_vehicleState set [
			"nextFullRouteSearchTime",
			0
		];

		_projectionResults pushBack [
			_vehicle,
			_group,
			-1,
			-1,
			-1,
			-1,
			_mode,
			false
		];
	} forEach _vehicleStates;

	_runtimeState set [
		"vehicleStates",
		_vehicleStates
	];

	_runtimeState set [
		"routeOrderValid",
		false
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

	_projectionResults
};

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

	if (_retired) then {
		_mode = "RETIRED";
	} else {
		if (
			isNull _vehicle
			|| {!alive _vehicle}
		) then {
			_mode = "INOPERABLE";
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

	_vehicleState set [
		"mode",
		_mode
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
 * Second pass: calculate longitudinal distance to the immediately
 * preceding vehicle in the permanent convoy order.
 */
private _routeOrderValid = true;

{
	private _vehicleState =
		_x;

	private _gapToVehicleAhead = -1;

	if (_forEachIndex > 0) then {
		private _vehicleAheadState =
			_vehicleStates select (
				_forEachIndex - 1
			);
		private _modeAhead =
			_vehicleAheadState getOrDefault [
				"mode",
				""
			];

		private _currentMode =
			_vehicleState getOrDefault [
				"mode",
				""
			];

		private _progressAhead =
			_vehicleAheadState getOrDefault [
				"routeProgress",
				-1
			];

		private _currentProgress =
			_vehicleState getOrDefault [
				"routeProgress",
				-1
			];

		if (
			_modeAhead == "TRACKED"
			&& {_currentMode == "TRACKED"}
			&& {_progressAhead >= 0}
			&& {_currentProgress >= 0}
		) then {
			_gapToVehicleAhead =
				_progressAhead
					- _currentProgress;

			/*
			 * A small tolerance avoids declaring an order violation
			 * when vehicles are effectively side by side.
			 */
			if (_gapToVehicleAhead < -2) then {
				_routeOrderValid = false;
			};
		};
	};

	_vehicleState set [
		"gapToVehicleAhead",
		_gapToVehicleAhead
	];

	_projectionResults pushBack [
		_vehicleState getOrDefault [
			"vehicle",
			objNull
		],
		_vehicleState getOrDefault [
			"group",
			grpNull
		],
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
		]
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
			"[A3C CONVOY SHADOW] Order: %1 | Vehicle: %2 | Group: %3 | Progress: %4 | Segment: %5 | Route distance: %6 | Gap: %7 | Mode: %8 | Full search: %9",
			_forEachIndex,
			_x select 0,
			_x select 1,
			_x select 2,
			_x select 3,
			_x select 4,
			_x select 5,
			_x select 6,
			_x select 7
		];
	} forEach _projectionResults;
};

_projectionResults
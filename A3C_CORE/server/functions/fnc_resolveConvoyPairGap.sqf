// A3C_server_fnc_resolveConvoyPairGap

/*
 * Resolves the longitudinal centre gap between two immediately
 * adjacent vehicles in the permanent convoy order.
 *
 * The shared master-route coordinate is preferred while both
 * projections are trustworthy.
 *
 * If either vehicle has diverged from the master route, or the
 * shared coordinate reports a possible order inversion, both
 * vehicles are compared against the same downstream destination.
 *
 * Returns:
 *
 * createHashMapFromArray [
 *     ["valid", BOOL],
 *     ["mode", STRING],
 *     ["reason", STRING],
 *     ["centreGap", NUMBER],
 *     ["masterRouteGap", NUMBER],
 *     ["commonAnchorGap", NUMBER],
 *     ["distanceCurrentToAnchor", NUMBER],
 *     ["distanceAheadToAnchor", NUMBER],
 *     ["anchorPosition", ARRAY],
 *     ["usedCachedRoutes", BOOL],
 *     ["pairRouteCache", HASHMAP]
 * ]
 *
 * Positive centre gap:
 *     preceding vehicle is ahead.
 *
 * Negative centre gap:
 *     following vehicle is longitudinally ahead.
 *
 * No vehicle, AI or speed commands are issued.
 */

params [
	["_runtimeID", "", [""]],
	["_vehicleAheadState", createHashMap, [createHashMap]],
	["_vehicleState", createHashMap, [createHashMap]]
];

private _result =
	createHashMapFromArray [
		["valid", false],
		["mode", "NONE"],
		["reason", "NOT_EVALUATED"],
		["centreGap", -1],
		["masterRouteGap", -1],
		["commonAnchorGap", -1],
		["distanceCurrentToAnchor", -1],
		["distanceAheadToAnchor", -1],
		["anchorPosition", []],
		["usedCachedRoutes", false],
		["pairRouteCache", createHashMap]
	];

if (
	!isServer
	|| {_runtimeID == ""}
	|| {isNil "A3C_CONVOY_RUNTIME_STATES"}
) exitWith {
	_result set [
		"reason",
		"INVALID_RUNTIME"
	];

	_result
};

private _runtimeState =
	A3C_CONVOY_RUNTIME_STATES getOrDefault [
		_runtimeID,
		createHashMap
	];

if (count _runtimeState == 0) exitWith {
	_result set [
		"reason",
		"RUNTIME_NOT_FOUND"
	];

	_result
};

private _vehicleAhead =
	_vehicleAheadState getOrDefault [
		"vehicle",
		objNull
	];

private _vehicle =
	_vehicleState getOrDefault [
		"vehicle",
		objNull
	];

if (
	isNull _vehicleAhead
	|| {isNull _vehicle}
	|| {!alive _vehicleAhead}
	|| {!alive _vehicle}
) exitWith {
	_result set [
		"reason",
		"PAIR_INOPERABLE"
	];

	_result
};

private _routeCoordinateGeneration =
	_runtimeState getOrDefault [
		"routeCoordinateGeneration",
		-1
	];

private _aheadCoordinateGeneration =
	_vehicleAheadState getOrDefault [
		"routeCoordinateGeneration",
		-2
	];

private _currentCoordinateGeneration =
	_vehicleState getOrDefault [
		"routeCoordinateGeneration",
		-3
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

private _masterRouteGap =
	if (
		_progressAhead >= 0
		&& {_currentProgress >= 0}
	) then {
		_progressAhead
			- _currentProgress
	} else {
		-1
	};

_result set [
	"masterRouteGap",
	_masterRouteGap
];

private _projectionAheadValid =
	_vehicleAheadState getOrDefault [
		"projectionValid",
		false
	];

private _projectionCurrentValid =
	_vehicleState getOrDefault [
		"projectionValid",
		false
	];

private _distanceAheadFromMasterRoute =
	_vehicleAheadState getOrDefault [
		"distanceFromRoute",
		-1
	];

private _distanceCurrentFromMasterRoute =
	_vehicleState getOrDefault [
		"distanceFromRoute",
		-1
	];

/*
 * A projection can still technically exist while a vehicle is
 * travelling along another nearby road. Only close projections are
 * trusted as the primary longitudinal reference.
 */
private _maximumTrustedMasterRouteDistance = 12;

private _sameCoordinateSystem =
	_routeCoordinateGeneration >= 0
	&& {
		_aheadCoordinateGeneration
			== _routeCoordinateGeneration
	}
	&& {
		_currentCoordinateGeneration
			== _routeCoordinateGeneration
	};

private _masterRouteReferenceValid =
	_projectionAheadValid
	&& {_projectionCurrentValid}
	&& {_sameCoordinateSystem}
	&& {_masterRouteGap >= -2}
	&& {
		_distanceAheadFromMasterRoute >= 0
	}
	&& {
		_distanceCurrentFromMasterRoute >= 0
	}
	&& {
		_distanceAheadFromMasterRoute
			<= _maximumTrustedMasterRouteDistance
	}
	&& {
		_distanceCurrentFromMasterRoute
			<= _maximumTrustedMasterRouteDistance
	};

if (_masterRouteReferenceValid) exitWith {
	_result set [
		"valid",
		true
	];

	_result set [
		"mode",
		"MASTER_ROUTE"
	];

	_result set [
		"reason",
		"MASTER_ROUTE_TRUSTED"
	];

	_result set [
		"centreGap",
		_masterRouteGap
	];

	_result
};

/*
 * Both vehicles must now be compared against exactly the same
 * downstream reference.
 *
 * destinationPosition is the active waypoint of the leading convoy
 * group and therefore remains common to every adjacent pair.
 */
private _anchorPosition =
	_runtimeState getOrDefault [
		"destinationPosition",
		[]
	];

_result set [
	"anchorPosition",
	+_anchorPosition
];

if (count _anchorPosition < 2) exitWith {
	_result set [
		"mode",
		"COMMON_ANCHOR"
	];

	_result set [
		"reason",
		"NO_COMMON_ANCHOR"
	];

	_result
};

private _currentTime =
	serverTime;

private _pairRouteCache =
	_vehicleState getOrDefault [
		"pairRouteCache",
		createHashMap
	];

if !(
	_pairRouteCache isEqualType
		createHashMap
) then {
	_pairRouteCache =
		createHashMap;
};

_result set [
	"pairRouteCache",
	_pairRouteCache
];

/*
 * Returns remaining road distance from a vehicle position to the
 * shared anchor using one cached compiled route.
 *
 * Result:
 *
 * [
 *     _valid,
 *     _remainingDistance,
 *     _distanceFromCachedRoute
 * ]
 */
private _getRemainingDistance = {
	params [
		"_position",
		"_route",
		"_anchor"
	];

	if (
		!(_route isEqualType [])
		|| {count _route != 4}
	) exitWith {
		[
			false,
			-1,
			-1
		]
	};

	private _roadPositions =
		_route select 1;

	if (_roadPositions isEqualTo []) exitWith {
		[
			false,
			-1,
			-1
		]
	};

	/*
	 * A route containing one road object has no segment onto which
	 * the generic projection function can project. Direct distance
	 * to the common anchor is sufficient for this very short case.
	 */
	if (count _roadPositions == 1) exitWith {
		[
			true,
			_position distance2D _anchor,
			_position distance2D (
				_roadPositions select 0
			)
		]
	};

	private _projection = [
		_position,
		_route,
		-1,
		-1,
		0,
		0,
		30,
		0,
		true
	] call A3C_main_fnc_projectPositionOntoRoadRoute;

	if (_projection isEqualTo []) exitWith {
		[
			false,
			-1,
			-1
		]
	};

	private _routeProgress =
		_projection select 0;

	private _distanceFromRoute =
		_projection select 2;

	if (_distanceFromRoute > 30) exitWith {
		[
			false,
			-1,
			_distanceFromRoute
		]
	};

	private _routeDistance =
		_route select 3;

	private _lastRoadPosition =
		_roadPositions select (
			(count _roadPositions) - 1
		);

	private _endConnectorDistance =
		_lastRoadPosition
			distance2D _anchor;

	private _remainingDistance =
		_distanceFromRoute
			+ (
				0 max (
					_routeDistance
						- _routeProgress
				)
			)
			+ _endConnectorDistance;

	[
		true,
		_remainingDistance,
		_distanceFromRoute
	]
};

private _cachedAheadVehicle =
	_pairRouteCache getOrDefault [
		"aheadVehicle",
		objNull
	];

private _cachedCurrentVehicle =
	_pairRouteCache getOrDefault [
		"currentVehicle",
		objNull
	];

private _cachedAnchor =
	_pairRouteCache getOrDefault [
		"anchorPosition",
		[]
	];

private _cachedCoordinateGeneration =
	_pairRouteCache getOrDefault [
		"routeCoordinateGeneration",
		-1
	];

private _cachedBuiltAt =
	_pairRouteCache getOrDefault [
		"builtAt",
		-1
	];

private _cachedValid =
	_pairRouteCache getOrDefault [
		"valid",
		false
	];

private _cacheMatchesPair =
	_cachedAheadVehicle
		isEqualTo _vehicleAhead
	&& {
		_cachedCurrentVehicle
			isEqualTo _vehicle
	};

private _cacheMatchesAnchor =
	count _cachedAnchor >= 2
	&& {
		_cachedAnchor
			distance2D _anchorPosition
				<= 2
	};

private _cacheMatchesCoordinate =
	_cachedCoordinateGeneration
		== _routeCoordinateGeneration;

/*
 * The route geometry may remain reusable for several controller
 * evaluations. Projection distance below will invalidate it sooner
 * if either vehicle takes another branch.
 */
private _cacheFresh =
	_cachedBuiltAt >= 0
	&& {
		_currentTime - _cachedBuiltAt
			<= 15
	};

private _canUseCachedRoutes =
	_cachedValid
	&& {_cacheMatchesPair}
	&& {_cacheMatchesAnchor}
	&& {_cacheMatchesCoordinate}
	&& {_cacheFresh};

private _aheadRoute = [];
private _currentRoute = [];
private _remainingAheadResult = [];
private _remainingCurrentResult = [];
private _usedCachedRoutes = false;
private _routeResolutionFailure = "";

if (_canUseCachedRoutes) then {
	_aheadRoute =
		_pairRouteCache getOrDefault [
			"aheadRoute",
			[]
		];

	_currentRoute =
		_pairRouteCache getOrDefault [
			"currentRoute",
			[]
		];

	_remainingAheadResult = [
		getPosATL _vehicleAhead,
		_aheadRoute,
		_anchorPosition
	] call _getRemainingDistance;

	_remainingCurrentResult = [
		getPosATL _vehicle,
		_currentRoute,
		_anchorPosition
	] call _getRemainingDistance;

	if (
		(_remainingAheadResult select 0)
		&& {
			_remainingCurrentResult select 0
		}
	) then {
		_usedCachedRoutes = true;
	} else {
		/*
		 * A vehicle has departed its cached path. Rebuild both pair
		 * routes against one current-time snapshot.
		 */
		_aheadRoute = [];
		_currentRoute = [];
		_remainingAheadResult = [];
		_remainingCurrentResult = [];
	};
};

if (!_usedCachedRoutes) then {
	private _failureCacheMatches =
		!_cachedValid
		&& {_cacheMatchesPair}
		&& {_cacheMatchesAnchor}
		&& {_cacheMatchesCoordinate};

	private _retryAfter =
		_pairRouteCache getOrDefault [
			"retryAfter",
			0
		];

	if (
		_failureCacheMatches
		&& {_currentTime < _retryAfter}
	) then {
		_routeResolutionFailure =
			"CACHED_ROUTE_FAILURE";
	} else {
		_aheadRoute = [
			getPosATL _vehicleAhead,
			_anchorPosition,
			1000,
			50,
			18
		] call A3C_main_fnc_buildRoadRoute;

		_currentRoute = [
			getPosATL _vehicle,
			_anchorPosition,
			1000,
			50,
			18
		] call A3C_main_fnc_buildRoadRoute;

		if (
			_aheadRoute isEqualTo []
			|| {_currentRoute isEqualTo []}
		) then {
			_pairRouteCache =
				createHashMapFromArray [
					["valid", false],
					["aheadVehicle", _vehicleAhead],
					["currentVehicle", _vehicle],
					[
						"anchorPosition",
						+_anchorPosition
					],
					[
						"routeCoordinateGeneration",
						_routeCoordinateGeneration
					],
					["builtAt", _currentTime],
					["retryAfter", _currentTime + 3],
					["aheadRoute", []],
					["currentRoute", []]
				];

			_result set [
				"pairRouteCache",
				_pairRouteCache
			];

			_routeResolutionFailure =
				"COMMON_ROUTE_BUILD_FAILED";
		} else {
			_pairRouteCache =
				createHashMapFromArray [
					["valid", true],
					["aheadVehicle", _vehicleAhead],
					["currentVehicle", _vehicle],
					[
						"anchorPosition",
						+_anchorPosition
					],
					[
						"routeCoordinateGeneration",
						_routeCoordinateGeneration
					],
					["builtAt", _currentTime],
					["retryAfter", 0],
					["aheadRoute", _aheadRoute],
					["currentRoute", _currentRoute]
				];

			_result set [
				"pairRouteCache",
				_pairRouteCache
			];

			_remainingAheadResult = [
				getPosATL _vehicleAhead,
				_aheadRoute,
				_anchorPosition
			] call _getRemainingDistance;

			_remainingCurrentResult = [
				getPosATL _vehicle,
				_currentRoute,
				_anchorPosition
			] call _getRemainingDistance;
		};
	};
};

if (_routeResolutionFailure != "") exitWith {
	_result set [
		"mode",
		"COMMON_ANCHOR"
	];

	_result set [
		"reason",
		_routeResolutionFailure
	];

	_result set [
		"usedCachedRoutes",
		false
	];

	_result
};

if (
	_remainingAheadResult isEqualTo []
	|| {_remainingCurrentResult isEqualTo []}
	|| {!(_remainingAheadResult select 0)}
	|| {!(_remainingCurrentResult select 0)}
) exitWith {
	_result set [
		"mode",
		"COMMON_ANCHOR"
	];

	_result set [
		"reason",
		"COMMON_ROUTE_PROJECTION_FAILED"
	];

	_result set [
		"usedCachedRoutes",
		_usedCachedRoutes
	];

	_result
};

private _distanceAheadToAnchor =
	_remainingAheadResult select 1;

private _distanceCurrentToAnchor =
	_remainingCurrentResult select 1;

/*
 * Both distances terminate at exactly the same downstream anchor.
 *
 * The follower is correctly behind when its remaining distance is
 * greater than the preceding vehicle's remaining distance.
 */
private _commonAnchorGap =
	_distanceCurrentToAnchor
		- _distanceAheadToAnchor;

_result set [
	"valid",
	true
];

_result set [
	"mode",
	"COMMON_ANCHOR"
];

_result set [
	"reason",
	if (_masterRouteGap < -2) then {
		"MASTER_ORDER_REJECTED"
	} else {
		"MASTER_PROJECTION_UNTRUSTED"
	}
];

_result set [
	"centreGap",
	_commonAnchorGap
];

_result set [
	"commonAnchorGap",
	_commonAnchorGap
];

_result set [
	"distanceCurrentToAnchor",
	_distanceCurrentToAnchor
];

_result set [
	"distanceAheadToAnchor",
	_distanceAheadToAnchor
];

_result set [
	"usedCachedRoutes",
	_usedCachedRoutes
];

_result
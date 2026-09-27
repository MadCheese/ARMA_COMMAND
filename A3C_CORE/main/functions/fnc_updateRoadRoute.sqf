// A3C_main_fnc_updateRoadRoute

/*
 * Updates a cached forward road route during a continuous drag.
 *
 * Route direction:
 *
 *     reference position -> dragged position
 *
 * _routeState:
 *
 * [
 *     _travelRoute,
 *     _lastAttemptedTargetRoad
 * ]
 *
 * Returns an updated _routeState.
 */

params [
	"_referencePosition",
	"_targetPosition",
	["_routeState", []],
	["_maximumInitialExpandedRoads", 750],
	["_maximumBridgeExpandedRoads", 64],
	["_roadSearchRadius", 50],
	["_debugState", createHashMap]
];

private _collectRoadDebug =
	missionNamespace getVariable [
		"A3C_DEBUG_CONVOY_ROADS",
		false
	]
	&& {
		_debugState isEqualType createHashMap
	}
	&& {
		_debugState getOrDefault [
			"enabled",
			false
		]
	};

private _debugUpdateStartedAt =
	diag_tickTime;

private _targetResolution = "NONE";
private _targetCandidatePositions = [];

private _currentRoute = [];

private _lastAttemptedTargetRoad =
	objNull;

private _routeToPositions = {
	params ["_route"];

	if !(_route isEqualType []) exitWith {
		[]
	};

	if (count _route != 4) exitWith {
		[]
	};

	+(_route select 1)
};

/*
 * Returns the configured vehicle-road neighbours.
 *
 * Normal connections remain untouched. The extended connection query
 * supplements missing junction links, while pedestrian roads and
 * trails discovered only by that extended query are excluded.
 */
private _getConfiguredRoadConnections = {
	params ["_road"];

	if (isNull _road) exitWith {
		[]
	};

	private _connectedRoads =
		+(roadsConnectedTo _road);

	private _extendedRoads =
		roadsConnectedTo [
			_road,
			true
		];

	{
		private _candidateRoad =
			_x;

		if (
			!isNull _candidateRoad
			&& {
				!(_candidateRoad isEqualTo _road)
			}
			&& {
				!(_candidateRoad in _connectedRoads)
			}
		) then {
			private _roadInfo =
				getRoadInfo _candidateRoad;

			private _mapType =
				toUpper (
					_roadInfo param [
						0,
						""
					]
				);

			private _isPedestrian =
				_roadInfo param [
					2,
					false
				];

			if (
				!_isPedestrian
				&& {_mapType != "TRAIL"}
			) then {
				_connectedRoads pushBack
					_candidateRoad;
			};
		};
	} forEach _extendedRoads;

	_connectedRoads
};

private _recordUpdateDebug = {
	params [
		"_branch",
		"_resultCode",
		["_targetRoad", objNull],
		["_resultRoute", []],
		["_lastCachedRoad", objNull]
	];

	if (!_collectRoadDebug) exitWith {};

	private _targetRoadPosition =
		if (isNull _targetRoad) then {
			[]
		} else {
			position _targetRoad
		};

	private _targetConnections =
		if (isNull _targetRoad) then {
			[]
		} else {
			([_targetRoad] call _getConfiguredRoadConnections) apply {
				[
					position _targetRoad,
					position _x
				]
			}
		};

	private _lastCachedRoadPosition =
		if (isNull _lastCachedRoad) then {
			[]
		} else {
			position _lastCachedRoad
		};

	private _lastAttemptedRoadPosition =
		if (
			isNull _lastAttemptedTargetRoad
		) then {
			[]
		} else {
			position _lastAttemptedTargetRoad
		};

	/*
	 * A cached drag update frequently avoids
	 * A3C_main_fnc_buildRoadRoute entirely. Capture graph context
	 * from the final section of the resulting route so the current
	 * cursor area remains diagnosable.
	 *
	 * The context is deliberately limited because this function may
	 * run repeatedly while the mouse is moving.
	 */
	private _resultRoadObjects = [];

	if (
		_resultRoute isEqualType []
		&& {count _resultRoute == 4}
	) then {
		_resultRoadObjects =
			+(_resultRoute select 0);
	};

	private _resultRouteNodeCount =
		count _resultRoadObjects;

	private _contextRoadObjects =
		+_resultRoadObjects;

	private _maximumContextNodes = 24;

	if (
		count _contextRoadObjects
			> _maximumContextNodes
	) then {
		_contextRoadObjects =
			_contextRoadObjects select [
				(count _contextRoadObjects)
					- _maximumContextNodes,
				_maximumContextNodes
			];
	};

	private _resultContextNodePositions = [];
	private _resultContextOutgoingEdges = [];
	private _resultContextIncomingOnlyEdges = [];
	private _resultContextEndpointCandidateEdges = [];

	{
		private _contextRoad =
			_x;

		if (!isNull _contextRoad) then {
			private _contextRoadPosition =
				position _contextRoad;

			_resultContextNodePositions pushBack
				_contextRoadPosition;

			private _outgoingRoads = [
				_contextRoad
			] call _getConfiguredRoadConnections;

			{
				if (!isNull _x) then {
					_resultContextOutgoingEdges
						pushBackUnique [
							_contextRoadPosition,
							position _x
						];
				};
			} forEach _outgoingRoads;

			private _nearbyRoads =
				_contextRoadPosition nearRoads 30;

			{
				private _candidateRoad =
					_x;

				if (
					!isNull _candidateRoad
					&& {
						!(_candidateRoad
							isEqualTo _contextRoad)
					}
				) then {
					private _candidatePosition =
						position _candidateRoad;

					/*
					 * Connection exists only from the nearby road
					 * toward the context road.
					 */
					if (
						!(_candidateRoad in _outgoingRoads)
						&& {
							_contextRoad in (
								[
									_candidateRoad
								] call _getConfiguredRoadConnections
							)
						}
					) then {
						_resultContextIncomingOnlyEdges
							pushBackUnique [
								_candidatePosition,
								_contextRoadPosition
							];
					};

					/*
					 * Display physically adjacent unconnected roads
					 * which would qualify for endpoint inference.
					 */
					if (
						count _outgoingRoads <= 1
						&& {
							!(_candidateRoad
								in _outgoingRoads)
						}
						&& {
							_contextRoadPosition
								distance2D
							_candidatePosition
								<= 18
						}
						&& {
							abs (
								(
									_contextRoadPosition
										select 2
								)
								- (
									_candidatePosition
										select 2
								)
							) <= 2
						}
					) then {
						_resultContextEndpointCandidateEdges
							pushBackUnique [
								_contextRoadPosition,
								_candidatePosition
							];
					};
				};
			} forEach _nearbyRoads;
		};
	} forEach _contextRoadObjects;

	private _resultDistance =
		if (
			_resultRoute isEqualType []
			&& {count _resultRoute == 4}
		) then {
			_resultRoute select 3
		} else {
			-1
		};

	private _directDistance =
		_referencePosition distance2D
			_targetPosition;

	private _routeDistanceRatio =
		if (
			_directDistance > 0.1
			&& {_resultDistance >= 0}
		) then {
			_resultDistance
				/ _directDistance
		} else {
			-1
		};

	_debugState set [
		"routeUpdate",
		createHashMapFromArray [
			["branch", _branch],
			["result", _resultCode],
			[
				"referencePosition",
				+_referencePosition
			],
			[
				"targetPosition",
				+_targetPosition
			],
			[
				"targetIsOnRoad",
				isOnRoad _targetPosition
			],
			[
				"targetResolution",
				_targetResolution
			],
			[
				"targetCandidates",
				+_targetCandidatePositions
			],
			[
				"targetRoadPosition",
				_targetRoadPosition
			],
			[
				"targetConnections",
				_targetConnections
			],
			[
				"lastCachedRoadPosition",
				_lastCachedRoadPosition
			],
			[
				"lastAttemptedTargetRoadPosition",
				_lastAttemptedRoadPosition
			],
			[
				"previousRoute",
				[_currentRoute]
					call _routeToPositions
			],
			[
				"resultRoute",
				[_resultRoute]
					call _routeToPositions
			],
			[
				"resultContextNodePositions",
				+_resultContextNodePositions
			],
			[
				"resultContextOutgoingEdges",
				+_resultContextOutgoingEdges
			],
			[
				"resultContextIncomingOnlyEdges",
				+_resultContextIncomingOnlyEdges
			],
			[
				"resultContextEndpointCandidateEdges",
				+_resultContextEndpointCandidateEdges
			],
			[
				"resultRouteNodeCount",
				_resultRouteNodeCount
			],
			[
				"resultContextNodeCount",
				count _contextRoadObjects
			],
			[
				"directDistance",
				_directDistance
			],
			[
				"routeDistanceRatio",
				_routeDistanceRatio
			],
			[
				"resultDistance",
				_resultDistance
			],
			[
				"calculationTime",
				diag_tickTime
					- _debugUpdateStartedAt
			]
		]
	];
};

private _targetRoad =
	roadAt _targetPosition;

if (!isNull _targetRoad) then {
	_targetResolution =
		"ROAD_AT";

	_targetCandidatePositions = [
		position _targetRoad
	];
} else {
	private _nearRoads =
		_targetPosition nearRoads 20;

	if !(_nearRoads isEqualTo []) then {
		_nearRoads = [
			_nearRoads,
			[],
			{
				_x distance2D _targetPosition
			},
			"ASCEND"
		] call BIS_fnc_sortBy;

		_targetCandidatePositions =
			_nearRoads apply {
				position _x
			};

		_targetRoad =
			_nearRoads select 0;

		_targetResolution =
			"NEAR_ROADS";
	};
};

if (isNull _targetRoad) exitWith {
	_targetResolution =
		"NOT_FOUND";

	[
		"TARGET_RESOLUTION",
		"TARGET_ROAD_MISSING",
		objNull,
		[]
	] call _recordUpdateDebug;

	[
		[],
		objNull
	]
};

if (count _routeState == 2) then {
	_currentRoute =
		_routeState select 0;

	_lastAttemptedTargetRoad =
		_routeState select 1;
};

/*
 * Avoid repeatedly rebuilding a route that already failed while the
 * cursor remains on the same road object.
 */
if (
	_currentRoute isEqualTo []
	&& {
		_lastAttemptedTargetRoad
			isEqualTo _targetRoad
	}
) exitWith {
	[
		"REPEATED_FAILED_TARGET",
		"ROUTE_UPDATE_SKIPPED",
		_targetRoad,
		[]
	] call _recordUpdateDebug;

	[
		[],
		_targetRoad
	]
};

private _currentRoadObjects = [];

if (count _currentRoute == 4) then {
	_currentRoadObjects =
		+(_currentRoute select 0);
};

/*
 * Filled when the cached route can be reused, shortened or extended.
 * Keeping this result outside nested scopes avoids exitWith scope
 * ambiguity.
 */
private _resolvedState = [];

if !(_currentRoadObjects isEqualTo []) then {
	private _lastRoad =
		_currentRoadObjects select (
			(count _currentRoadObjects) - 1
		);

	/*
	 * Cursor remains on the same road.
	 */
	if (_targetRoad isEqualTo _lastRoad) then {
		_resolvedState = [
			_currentRoute,
			_targetRoad
		];

		[
			"SAME_ROAD",
			"ROUTE_UPDATE_SUCCESS",
			_targetRoad,
			_currentRoute,
			_lastRoad
		] call _recordUpdateDebug;
	};

	/*
	 * Cursor moved backwards onto an earlier road in the cached route.
	 */
	if (_resolvedState isEqualTo []) then {
		private _existingRoadIndex =
			_currentRoadObjects find
				_targetRoad;

		if (_existingRoadIndex >= 0) then {
			_currentRoadObjects resize (
				_existingRoadIndex + 1
			);

			private _updatedRoute = [
				_currentRoadObjects
			] call A3C_main_fnc_compileRoadRoute;

			_resolvedState = [
				_updatedRoute,
				_targetRoad
			];

			[
				"TRUNCATED_CACHED_ROUTE",
				"ROUTE_UPDATE_SUCCESS",
				_targetRoad,
				_updatedRoute,
				_lastRoad
			] call _recordUpdateDebug;
		};
	};

	/*
	 * Cursor moved onto a directly connected road. Test both
	 * directions because road connection data is not always
	 * symmetrical.
	 */
	if (_resolvedState isEqualTo []) then {
		private _isDirectlyConnected =
			_targetRoad in (
				[
					_lastRoad
				] call _getConfiguredRoadConnections
			)
			|| {
				_lastRoad in (
					[
						_targetRoad
					] call _getConfiguredRoadConnections
				)
			};

		if (_isDirectlyConnected) then {
			_currentRoadObjects pushBack
				_targetRoad;

			private _updatedRoute = [
				_currentRoadObjects
			] call A3C_main_fnc_compileRoadRoute;

			_resolvedState = [
				_updatedRoute,
				_targetRoad
			];

			[
				"DIRECT_EXTENSION",
				"ROUTE_UPDATE_SUCCESS",
				_targetRoad,
				_updatedRoute,
				_lastRoad
			] call _recordUpdateDebug;
		};
	};

	/*
	 * The mouse may have skipped several road objects between events.
	 * Try a small bounded bridge search before rebuilding the entire
	 * route from the immutable reference.
	 */
	if (_resolvedState isEqualTo []) then {
		private _bridgeRoute = [
			position _lastRoad,
			_targetPosition,
			_maximumBridgeExpandedRoads,
			20,
			18,
			"BRIDGE_EXTENSION",
			_debugState
		] call A3C_main_fnc_buildRoadRoute;

		if !(_bridgeRoute isEqualTo []) then {
			private _bridgeRoadObjects =
				+(_bridgeRoute select 0);

			private _bridgeStartsCorrectly =
				!(_bridgeRoadObjects isEqualTo [])
				&& {
					(_bridgeRoadObjects select 0)
						isEqualTo _lastRoad
				};

			private _bridgeEndsCorrectly =
				_bridgeStartsCorrectly
				&& {
					(
						_bridgeRoadObjects select (
							(count _bridgeRoadObjects)
								- 1
						)
					) isEqualTo _targetRoad
				};

			if (_bridgeEndsCorrectly) then {
				/*
				 * The first bridge road is already the final cached
				 * road.
				 */
				_bridgeRoadObjects deleteAt 0;

				_currentRoadObjects append
					_bridgeRoadObjects;

				private _updatedRoute = [
					_currentRoadObjects
				] call A3C_main_fnc_compileRoadRoute;

				_resolvedState = [
					_updatedRoute,
					_targetRoad
				];

				[
					"BRIDGE_EXTENSION",
					"ROUTE_UPDATE_SUCCESS",
					_targetRoad,
					_updatedRoute,
					_lastRoad
				] call _recordUpdateDebug;
			};
		};
	};
};

if !(_resolvedState isEqualTo []) exitWith {
	_resolvedState
};

/*
 * No usable cached continuation exists. Perform one bounded route
 * build from the immutable reference.
 */
private _newRoute = [
	_referencePosition,
	_targetPosition,
	_maximumInitialExpandedRoads,
	_roadSearchRadius,
	18,
	"FULL_REBUILD",
	_debugState
] call A3C_main_fnc_buildRoadRoute;

private _fullRebuildResult =
	if (_newRoute isEqualTo []) then {
		"ROUTE_UPDATE_FAILED"
	} else {
		"ROUTE_UPDATE_SUCCESS"
	};

[
	"FULL_REBUILD",
	_fullRebuildResult,
	_targetRoad,
	_newRoute
] call _recordUpdateDebug;

[
	_newRoute,
	_targetRoad
]
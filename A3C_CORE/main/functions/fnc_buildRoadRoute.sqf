// A3C_main_fnc_buildRoadRoute

/*
 * Builds a shortest connected-road route from _startPosition to
 * _endPosition.
 *
 * The function performs pathfinding only. It does not place waypoints
 * and does not reverse the resulting route.
 *
 * Returns:
 *
 * [
 *     _roadObjects,
 *     _roadPositions,
 *     _cumulativeDistances,
 *     _totalDistance
 * ]
 *
 * Returns [] if:
 *
 * - no suitable start or target road exists;
 * - no connected route can be found;
 * - the search exceeds _maxExpandedRoads.
 */

params [
	"_startPosition",
	"_endPosition",
	["_maxExpandedRoads", 2000],
	["_roadSearchRadius", 50],
	["_maximumInferredRoadGap", 18],
	["_debugBuildMode", "FULL"],
	["_debugState", createHashMap]
];

private _collectRoadDebug =
	missionNamespace getVariable [
		"A3C_DEBUG_CONVOY_ROADS",
		false
	]
	&& {
		_debugState getOrDefault [
			"enabled",
			false
		]
	};

private _debugBuildStartedAt =
	diag_tickTime;

private _debugSearchDirection = "";

private _debugInferredEdges = [];

private _routeToPositions = {
	params ["_route"];

	if (_route isEqualTo []) exitWith {
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

private _recordBuildDebug = {
	params [
		"_resultCode",
		["_startRoad", objNull],
		["_targetRoad", objNull],
		["_forwardRoute", []],
		["_reverseRoute", []],
		["_selectedRoute", []],
		["_selectedSource", "NONE"]
	];

	if (!_collectRoadDebug) exitWith {};

	private _startRoadPosition =
		if (isNull _startRoad) then {
			[]
		} else {
			position _startRoad
		};

	private _targetRoadPosition =
		if (isNull _targetRoad) then {
			[]
		} else {
			position _targetRoad
		};

	private _startConnections =
		if (isNull _startRoad) then {
			[]
		} else {
			([_startRoad] call _getConfiguredRoadConnections) apply {
				[
					position _startRoad,
					position _x
				]
			}
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

	/*
	* Capture the road graph surrounding the selected path while the
	* route is being calculated. The map drawing handler must only
	* consume this prepared data.
	*
	* Edge types:
	*
	* - outgoing: reported by roadsConnectedTo from the selected road;
	* - incoming-only: another nearby road reports a connection to the
	*   selected road, but the selected road does not report it back;
	* - endpoint candidate: physically nearby but unconnected road that
	*   the inferred-connection mechanic could potentially select.
	*/
	private _selectedOutgoingEdges = [];
	private _selectedIncomingOnlyEdges = [];
	private _selectedEndpointCandidateEdges = [];
	private _selectedNodePositions = [];

	private _selectedRoadObjects = [];

	if (
		_selectedRoute isEqualType []
		&& {count _selectedRoute == 4}
	) then {
		_selectedRoadObjects =
			+(_selectedRoute select 0);
	};

	{
		private _selectedRoad =
			_x;

		if (!isNull _selectedRoad) then {
			private _selectedRoadPosition =
				position _selectedRoad;

			_selectedNodePositions pushBack
				_selectedRoadPosition;

			private _outgoingRoads = [
				_selectedRoad
			] call _getConfiguredRoadConnections;

			{
				if (!isNull _x) then {
					_selectedOutgoingEdges pushBackUnique [
						_selectedRoadPosition,
						position _x
					];
				};
			} forEach _outgoingRoads;

			private _nearbyRoads =
				_selectedRoadPosition nearRoads
					(30 max _maximumInferredRoadGap);

			/*
			* Find connections that exist only in the opposite direction.
			*/
			{
				private _candidateRoad =
					_x;

				if (
					!isNull _candidateRoad
					&& {
						!(_candidateRoad isEqualTo _selectedRoad)
					}
					&& {
						!(_candidateRoad in _outgoingRoads)
					}
					&& {
						_selectedRoad in (
							[
								_candidateRoad
							] call _getConfiguredRoadConnections
						)
					}
				) then {
					_selectedIncomingOnlyEdges pushBackUnique [
						position _candidateRoad,
						_selectedRoadPosition
					];
				};
			} forEach _nearbyRoads;

			/*
			* Mirror the current inferred-edge eligibility closely enough
			* to show every road that competed with the ultimately chosen
			* inferred road.
			*/
			if (
				count _outgoingRoads <= 1
				&& {_maximumInferredRoadGap > 0}
			) then {
				{
					private _candidateRoad =
						_x;

					private _candidatePosition =
						position _candidateRoad;

					if (
						!isNull _candidateRoad
						&& {
							!(_candidateRoad isEqualTo _selectedRoad)
						}
						&& {
							!(_candidateRoad in _outgoingRoads)
						}
						&& {
							abs (
								(_selectedRoadPosition select 2)
									- (_candidatePosition select 2)
							) <= 2
						}
					) then {
						_selectedEndpointCandidateEdges
							pushBackUnique [
								_selectedRoadPosition,
								_candidatePosition
							];
					};
				} forEach (
					_selectedRoadPosition nearRoads
						_maximumInferredRoadGap
				);
			};
		};
	} forEach _selectedRoadObjects;

	private _directDistance =
		_startPosition distance2D
			_endPosition;

	private _selectedDistance =
		if (_selectedRoute isEqualTo []) then {
			-1
		} else {
			_selectedRoute select 3
		};

	private _routeDistanceRatio =
		if (
			_directDistance > 0.1
			&& {_selectedDistance >= 0}
		) then {
			_selectedDistance
				/ _directDistance
		} else {
			-1
		};

	private _routeBuilds =
		+(
			_debugState getOrDefault [
				"routeBuilds",
				[]
			]
		);

	_routeBuilds pushBack (
		createHashMapFromArray [
			["buildMode", _debugBuildMode],
			["result", _resultCode],
			["startPosition", +_startPosition],
			["targetPosition", +_endPosition],
			["startRoadPosition", _startRoadPosition],
			["targetRoadPosition", _targetRoadPosition],
			["startConnections", _startConnections],
			["targetConnections", _targetConnections],
			[
				"forwardRoute",
				[_forwardRoute] call _routeToPositions
			],
			[
				"reverseRoute",
				[_reverseRoute] call _routeToPositions
			],
			[
				"selectedRoute",
				[_selectedRoute] call _routeToPositions
			],
			["selectedSource", _selectedSource],
			[
				"selectedDistance",
				if (_selectedRoute isEqualTo []) then {
					-1
				} else {
					_selectedRoute select 3
				}
			],
			["inferredEdges", +_debugInferredEdges],
			[
				"selectedNodePositions",
				+_selectedNodePositions
			],
			[
				"selectedOutgoingEdges",
				+_selectedOutgoingEdges
			],
			[
				"selectedIncomingOnlyEdges",
				+_selectedIncomingOnlyEdges
			],
			[
				"selectedEndpointCandidateEdges",
				+_selectedEndpointCandidateEdges
			],
			["directDistance", _directDistance],
			["routeDistanceRatio", _routeDistanceRatio],
			[
				"selectedNodeCount",
				count _selectedRoadObjects
			],
			[
				"forwardNodeCount",
				if (_forwardRoute isEqualTo []) then {
					0
				} else {
					count (_forwardRoute select 0)
				}
			],
			[
				"reverseNodeCount",
				if (_reverseRoute isEqualTo []) then {
					0
				} else {
					count (_reverseRoute select 0)
				}
			],
			[
				"inferredEdgeCount",
				count _debugInferredEdges
			],
			[
				"calculationTime",
				diag_tickTime - _debugBuildStartedAt
			]
		]
	);

	_debugState set [
		"routeBuilds",
		_routeBuilds
	];
};

if (
	count _startPosition < 2
	|| {count _endPosition < 2}
	|| {_maxExpandedRoads < 1}
) exitWith {
	[
		"INVALID_INPUT"
	] call _recordBuildDebug;

	[]
};

/*
 * Resolves the road containing a horizontal map position.
 *
 * Waypoint positions may deliberately carry a large Z value, such
 * as 1000, after waypoint-bundle placement or dragging. Road lookup
 * must therefore operate on normalized terrain-level coordinates.
 *
 * If the position is not directly on a road, the nearest road inside
 * _roadSearchRadius is used instead.
 */
private _resolveRoad = {
	params [
		"_position",
		"_searchRadius"
	];

	private _roadLookupPosition = [
		_position select 0,
		_position select 1,
		0
	];

	private _road =
		roadAt _roadLookupPosition;

	if (!isNull _road) exitWith {
		_road
	};

	private _nearRoads =
		_roadLookupPosition nearRoads
			_searchRadius;

	if (_nearRoads isEqualTo []) exitWith {
		objNull
	};

	_nearRoads = [
		_nearRoads,
		[],
		{
			_x distance2D
				_roadLookupPosition
		},
		"ASCEND"
	] call BIS_fnc_sortBy;

	_nearRoads select 0
};

/*
 * Returns the normal graph neighbours of a road.
 *
 * When the road is a graph endpoint, the nearest physically adjacent
 * but unconnected road may be added as an inferred neighbour. This
 * repairs small terrain-config gaps where different road types meet.
 */
private _getRoadNeighbours = {
	params [
		"_road",
		"_maximumGap"
	];

	private _connectedRoads = [
		_road
	] call _getConfiguredRoadConnections;
	/*
	 * Only graph endpoints may initiate an inferred connection.
	 * This prevents ordinary road segments from connecting to nearby
	 * parallel roads or unrelated crossings.
	 */
	if (
		count _connectedRoads > 1
		|| {_maximumGap <= 0}
	) exitWith {
		_connectedRoads
	};

	private _roadPosition =
		position _road;

	private _bridgeCandidates =
		_roadPosition nearRoads _maximumGap;

	_bridgeCandidates =
		_bridgeCandidates select {
			private _candidateRoad =
				_x;

			private _candidatePosition =
				position _candidateRoad;

			!isNull _candidateRoad
			&& {
				!(_candidateRoad isEqualTo _road)
			}
			&& {
				!(_candidateRoad in _connectedRoads)
			}
			&& {
				abs (
					(_roadPosition select 2)
						- (_candidatePosition select 2)
				) <= 2
			}
		};

	if (_bridgeCandidates isEqualTo []) exitWith {
		_connectedRoads
	};

	_bridgeCandidates = [
		_bridgeCandidates,
		[],
		{
			_x distance2D _road
		},
		"ASCEND"
	] call BIS_fnc_sortBy;

	private _inferredRoad =
		_bridgeCandidates select 0;

	_connectedRoads pushBackUnique
		_inferredRoad;
	
	if (_collectRoadDebug) then {
		_debugInferredEdges pushBackUnique [
			_debugSearchDirection,
			_roadPosition,
			position _inferredRoad,
			_road distance2D _inferredRoad
		];
	};

	if (
		missionNamespace getVariable [
			"A3C_DEBUG_ROAD_ROUTE",
			false
		]
	) then {
		diag_log format [
			"[A3C ROAD BRIDGE] Endpoint: %1 at %2 | Inferred road: %3 at %4 | Gap: %5 | Endpoint connections: %6 | Candidate connections: %7",
			_road,
			_roadPosition,
			_inferredRoad,
			position _inferredRoad,
			_road distance2D _inferredRoad,
			count (
				[
					_road
				] call _getConfiguredRoadConnections
			),
			count (
				[
					_inferredRoad
				] call _getConfiguredRoadConnections
			)
		];
	};

	_connectedRoads
};



/*
 * Performs bounded A* between two already resolved road objects.
 *
 * Returns an ordered array beginning at _startRoad and ending at
 * _targetRoad, or [] on failure.
 */


private _findRoadPath = {
	params [
		"_startRoad",
		"_targetRoad",
		"_maximumExpandedRoads"
	];

	if (
		isNull _startRoad
		|| {isNull _targetRoad}
	) exitWith {
		[]
	};

	if (_startRoad isEqualTo _targetRoad) exitWith {
		[
			_startRoad
		]
	};

	/*
	 * Every index identifies the same road in each parallel array.
	 */
	private _knownRoads = [
		_startRoad
	];

	private _gCosts = [
		0
	];

	private _fCosts = [
		_startRoad distance2D _targetRoad
	];

	private _cameFromIndices = [
		-1
	];

	private _closed = [
		false
	];

	/*
	 * Contains indices into _knownRoads.
	 */
	private _openIndices = [
		0
	];

	private _foundIndex = -1;
	private _expandedRoads = 0;

	while {
		!(_openIndices isEqualTo [])
		&& {
			_expandedRoads
				< _maximumExpandedRoads
		}
	} do {
		/*
		 * Select the open road with the lowest estimated total cost.
		 *
		 * If costs are equal, prefer the road with the larger
		 * accumulated cost. This usually means it is farther along
		 * the route and closer to the target.
		 */
		private _bestOpenOffset = 0;

		private _currentIndex =
			_openIndices select 0;

		private _bestFCost =
			_fCosts select _currentIndex;

		private _bestGCost =
			_gCosts select _currentIndex;

		if (count _openIndices > 1) then {
			for "_i" from 1 to ((count _openIndices) - 1) do {
				private _candidateIndex =
					_openIndices select _i;

				private _candidateFCost =
					_fCosts select _candidateIndex;

				private _candidateGCost =
					_gCosts select _candidateIndex;

				if (
					_candidateFCost < _bestFCost
					|| {
						_candidateFCost
							isEqualTo _bestFCost
						&& {
							_candidateGCost
								> _bestGCost
						}
					}
				) then {
					_bestOpenOffset = _i;
					_currentIndex = _candidateIndex;
					_bestFCost = _candidateFCost;
					_bestGCost = _candidateGCost;
				};
			};
		};

		_openIndices deleteAt
			_bestOpenOffset;

		private _currentRoad =
			_knownRoads select _currentIndex;

		if (
			_currentRoad
				isEqualTo _targetRoad
		) exitWith {
			_foundIndex = _currentIndex;
		};

		_closed set [
			_currentIndex,
			true
		];

		_expandedRoads =
			_expandedRoads + 1;

		private _connectedRoads = [
			_currentRoad,
			_maximumInferredRoadGap
		] call _getRoadNeighbours;

		{
			private _connectedRoad = _x;

			if (!isNull _connectedRoad) then {
				private _connectedRoadIndex =
					_knownRoads find _connectedRoad;

				/*
				 * Register the road the first time it is encountered.
				 */
				if (_connectedRoadIndex < 0) then {
					_connectedRoadIndex =
						_knownRoads pushBack
							_connectedRoad;

					_gCosts pushBack 1e30;
					_fCosts pushBack 1e30;
					_cameFromIndices pushBack -1;
					_closed pushBack false;
				};

				if !(
					_closed select
						_connectedRoadIndex
				) then {
					private _segmentCost =
						_currentRoad
							distance2D
						_connectedRoad;

					private _tentativeGCost =
						(_gCosts select _currentIndex)
							+ _segmentCost;

					if (
						_tentativeGCost
							< (
								_gCosts select
									_connectedRoadIndex
							)
					) then {
						_cameFromIndices set [
							_connectedRoadIndex,
							_currentIndex
						];

						_gCosts set [
							_connectedRoadIndex,
							_tentativeGCost
						];

						private _estimatedRemainingCost =
							_connectedRoad
								distance2D
							_targetRoad;

						_fCosts set [
							_connectedRoadIndex,
							_tentativeGCost
								+ _estimatedRemainingCost
						];

						if !(
							_connectedRoadIndex
								in _openIndices
						) then {
							_openIndices pushBack
								_connectedRoadIndex;
						};
					};
				};
			};
		} forEach _connectedRoads;
	};

	if (_foundIndex < 0) exitWith {
		[]
	};

	/*
	 * Reconstruct the route by following the parent indices from
	 * the target back to the start.
	 */
	private _roadPath = [];
	private _pathIndex = _foundIndex;

	while {
		_pathIndex >= 0
	} do {
		_roadPath pushBack (
			_knownRoads select _pathIndex
		);

		_pathIndex =
			_cameFromIndices select _pathIndex;
	};

	reverse _roadPath;

	_roadPath
};

private _startRoad = [
	_startPosition,
	_roadSearchRadius
] call _resolveRoad;

private _targetRoad = [
	_endPosition,
	_roadSearchRadius
] call _resolveRoad;

if (
	isNull _startRoad
	|| {isNull _targetRoad}
) exitWith {
	[
		"ROAD_RESOLUTION_FAILED",
		_startRoad,
		_targetRoad
	] call _recordBuildDebug;

	[]
};


/*
 * Search the graph in both directions.
 *
 * Road connections can be asymmetric. A physically short connection
 * may therefore be discoverable only by searching from the target
 * road back toward the start road.
 */
_debugSearchDirection = "FORWARD";
private _forwardRoadPath = [
	_startRoad,
	_targetRoad,
	_maxExpandedRoads
] call _findRoadPath;


_debugSearchDirection = "REVERSE";
private _reverseRoadPath = [
	_targetRoad,
	_startRoad,
	_maxExpandedRoads
] call _findRoadPath;

/*
 * Convert the reverse-search result back into the requested travel
 * direction:
 *
 *     start road -> target road
 */
if !(_reverseRoadPath isEqualTo []) then {
	reverse _reverseRoadPath;
};

private _forwardRoute = [];

if !(_forwardRoadPath isEqualTo []) then {
	_forwardRoute = [
		_forwardRoadPath
	] call A3C_main_fnc_compileRoadRoute;
};

private _reverseRoute = [];

if !(_reverseRoadPath isEqualTo []) then {
	_reverseRoute = [
		_reverseRoadPath
	] call A3C_main_fnc_compileRoadRoute;
};

/*
 * Optional route diagnostics.
 */
if (
	missionNamespace getVariable [
		"A3C_DEBUG_ROAD_ROUTE",
		false
	]
) then {
	private _forwardDistance =
		if (_forwardRoute isEqualTo []) then {
			-1
		} else {
			_forwardRoute select 3
		};

	private _reverseDistance =
		if (_reverseRoute isEqualTo []) then {
			-1
		} else {
			_reverseRoute select 3
		};

	diag_log format [
		"[A3C ROAD ROUTE] Direct: %1 | Forward nodes: %2, distance: %3 | Reverse-derived nodes: %4, distance: %5",
		_startPosition distance2D _endPosition,
		count _forwardRoadPath,
		_forwardDistance,
		count _reverseRoadPath,
		_reverseDistance
	];
};

/*
 * Prefer the physically shorter successful route.
 */
private _selectedRoute = [];
private _selectedSource = "NONE";

if (_forwardRoute isEqualTo []) then {
	if !(_reverseRoute isEqualTo []) then {
		_selectedRoute =
			_reverseRoute;

		_selectedSource =
			"REVERSE_DERIVED";
	};
} else {
	if (_reverseRoute isEqualTo []) then {
		_selectedRoute =
			_forwardRoute;

		_selectedSource =
			"FORWARD";
	} else {
		if (
			(_forwardRoute select 3)
				<= (_reverseRoute select 3)
		) then {
			_selectedRoute =
				_forwardRoute;

			_selectedSource =
				"FORWARD";
		} else {
			_selectedRoute =
				_reverseRoute;

			_selectedSource =
				"REVERSE_DERIVED";
		};
	};
};

private _resultCode =
	if (_selectedRoute isEqualTo []) then {
		"ROUTE_BUILD_FAILED"
	} else {
		"ROUTE_BUILD_SUCCESS"
	};

[
	_resultCode,
	_startRoad,
	_targetRoad,
	_forwardRoute,
	_reverseRoute,
	_selectedRoute,
	_selectedSource
] call _recordBuildDebug;

_selectedRoute
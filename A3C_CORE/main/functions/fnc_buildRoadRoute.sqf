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
	["_maximumInferredRoadGap", 18]
];

if (
	count _startPosition < 2
	|| {count _endPosition < 2}
	|| {_maxExpandedRoads < 1}
) exitWith {
	[]
};

/*
 * Resolves the road containing a position.
 *
 * If the position is not directly on a road, the nearest road inside
 * _roadSearchRadius is used instead.
 */
private _resolveRoad = {
	params [
		"_position",
		"_searchRadius"
	];

	private _road =
		roadAt _position;

	if (!isNull _road) exitWith {
		_road
	};

	private _nearRoads =
		_position nearRoads _searchRadius;

	if (_nearRoads isEqualTo []) exitWith {
		objNull
	};

	_nearRoads = [
		_nearRoads,
		[],
		{
			_x distance2D _position
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

	private _connectedRoads =
		roadsConnectedTo _road;

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
			count roadsConnectedTo _road,
			count roadsConnectedTo _inferredRoad
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
	[]
};

/*
 * Search the graph in both directions.
 *
 * Road connections can be asymmetric. A physically short connection
 * may therefore be discoverable only by searching from the target
 * road back toward the start road.
 */
private _forwardRoadPath = [
	_startRoad,
	_targetRoad,
	_maxExpandedRoads
] call _findRoadPath;

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
private _selectedRoute =
	if (_forwardRoute isEqualTo []) then {
		_reverseRoute
	} else {
		if (_reverseRoute isEqualTo []) then {
			_forwardRoute
		} else {
			if (
				(_forwardRoute select 3)
					<= (_reverseRoute select 3)
			) then {
				_forwardRoute
			} else {
				_reverseRoute
			}
		}
	};

_selectedRoute
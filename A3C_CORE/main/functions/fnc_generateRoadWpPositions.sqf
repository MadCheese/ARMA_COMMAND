// A3C_main_fnc_generateRoadWpPositions

/*
 * Generates ordered waypoint positions along the road route that a
 * vehicle would use when travelling from _refPosStart to _pos.
 *
 * _travelRoute is always stored in vehicle-travel direction:
 *
 *     reference position -> leading waypoint
 *
 * A copied road-object array is reversed for waypoint distribution.
 *
 * Waypoint slots are sampled at exact cumulative distances along the
 * compiled route. They are not restricted to road-object centres.
 */

params [
	"_pos",
	"_orderedGroups",
	"_refPosStart",
	["_travelRoute", objNull],
	["_debugState", createHashMap],
	["_debugBuildMode", "FULL"]
];

/*
 * Existing four-argument callers supply an array, including [] when
 * a cached route attempt failed. objNull allows a caller to pass a
 * debug state while still requesting an internal route build.
 */
private _travelRouteWasSupplied =
	_travelRoute isEqualType [];

private _collectRoadDebug =
	missionNamespace getVariable [
		"A3C_DEBUG_CONVOY_ROADS",
		false
	]
	&& {
		_debugState isEqualType
			createHashMap
	}
	&& {
		_debugState getOrDefault [
			"enabled",
			false
		]
	};

private _debugDistributionStartedAt =
	diag_tickTime;

private _debugSlotRequirements = [];
private _debugExtensionAttempted = false;
private _debugExtensionSucceeded = false;
private _debugExtensionExpandedRoads = 0;
private _debugExtensionRoadPositions = [];

private _extractRoutePositions = {
	params ["_route"];

	if !(_route isEqualType []) exitWith {
		[]
	};

	if (count _route != 4) exitWith {
		[]
	};

	+(_route select 1)
};

private _recordDistributionDebug = {
	params [
		"_resultCode",
		["_generatedPositions", []],
		["_distributionRoute", []],
		["_requiredDistance", -1],
		["_failedSlot", -1]
	];

		private _availableDistance =
			if (
				_distributionRoute isEqualType []
				&& {
					count _distributionRoute == 4
				}
			) then {
				_distributionRoute select 3
			} else {
				-1
			};

		/*
		* This compact result is operational state, not debug output.
		* Drag finalization and waypoint creation must be able to validate
		* the calculation even when road debugging is disabled.
		*/
		if (
			_debugState isEqualType
				createHashMap
		) then {
			private _valid =
				_resultCode
					== "ROAD_DISTRIBUTION_SUCCESS"
				&& {
					count _generatedPositions
						== count _orderedGroups
				};

			_debugState set [
				"distributionResult",
				createHashMapFromArray [
					["valid", _valid],
					["result", _resultCode],
					[
						"generatedPositionCount",
						count _generatedPositions
					],
					[
						"expectedPositionCount",
						count _orderedGroups
					],
					["requiredDistance", _requiredDistance],
					["availableDistance", _availableDistance],
					["failedSlot", _failedSlot],
					[
						"extensionAttempted",
						_debugExtensionAttempted
					],
					[
						"extensionSucceeded",
						_debugExtensionSucceeded
					],
					[
						"extensionExpandedRoads",
						_debugExtensionExpandedRoads
					]
				]
			];
		};

		if (!_collectRoadDebug) exitWith {};

		private _category =
			if (
				_resultCode
					== "ROAD_DISTRIBUTION_SUCCESS"
			) then {
				"ROAD_ALIGNMENT_SUCCESS"
			} else {
				"ALIGNMENT_FAILURE"
			};

	_debugState set [
		"distribution",
		createHashMapFromArray [
			["category", _category],
			["result", _resultCode],
			["buildMode", _debugBuildMode],
			[
				"travelRouteSupplied",
				_travelRouteWasSupplied
			],
			["targetPosition", +_pos],
			["referencePosition", +_refPosStart],
			["targetIsOnRoad", isOnRoad _pos],
			["groupCount", count _orderedGroups],
			[
				"groupIDs",
				_orderedGroups apply {
					groupID _x
				}
			],
			[
				"travelRoute",
				[_travelRoute]
					call _extractRoutePositions
			],
			[
				"distributionRoute",
				[_distributionRoute]
					call _extractRoutePositions
			],
			[
				"generatedPositions",
				+_generatedPositions
			],
			[
				"slotRequirements",
				+_debugSlotRequirements
			],
			["requiredDistance", _requiredDistance],
			["availableDistance", _availableDistance],
			["failedSlot", _failedSlot],
			[
				"extensionAttempted",
				_debugExtensionAttempted
			],
			[
				"extensionSucceeded",
				_debugExtensionSucceeded
			],
			[
				"extensionExpandedRoads",
				_debugExtensionExpandedRoads
			],
			[
				"extensionRoadPositions",
				+_debugExtensionRoadPositions
			],
			[
				"calculationTime",
				diag_tickTime
					- _debugDistributionStartedAt
			]
		]
	];
};

if (_orderedGroups isEqualTo []) exitWith {
	[
		"NO_GROUPS"
	] call _recordDistributionDebug;

	[]
};

/*
 * Build a route only when the caller omitted the route argument.
 * An explicitly supplied [] represents a cached route failure and
 * must not trigger another search.
*/
if (!_travelRouteWasSupplied) then {
	_travelRoute = [
		_refPosStart,
		_pos,
		2000,
		50,
		18,
		_debugBuildMode,
		_debugState
	] call A3C_main_fnc_buildRoadRoute;
};

if (
	!(_travelRoute isEqualType [])
	|| {_travelRoute isEqualTo []}
	|| {count _travelRoute != 4}
) exitWith {
	[
		"ROUTE_INVALID"
	] call _recordDistributionDebug;

	[]
};

/*
 * Copy before reversing. Reversing the array contained inside the
 * cached route would corrupt its forward travel direction.
*/
private _distributionRoadObjects =
	+(_travelRoute select 0);

if (_distributionRoadObjects isEqualTo []) exitWith {
	[
		"ROUTE_ROAD_OBJECTS_EMPTY"
	] call _recordDistributionDebug;

	[]
};

reverse _distributionRoadObjects;

/*
 * Calculate the complete spacing requirement before deciding whether
 * the existing approach route contains enough road.
 */
private _requiredSlotDistances = [];
private _requiredTotalDistance = 0;

if (count _orderedGroups > 1) then {
	for "_slotIndex" from 1 to ((count _orderedGroups) - 1) do {
		private _currentGroup =
			_orderedGroups select
				_slotIndex;

		private _currentSpacing =
			30 max sizeOf typeOf
				vehicle leader _currentGroup;

		_requiredTotalDistance =
			_requiredTotalDistance
				+ _currentSpacing;

		_requiredSlotDistances pushBack
			_requiredTotalDistance;

		_debugSlotRequirements pushBack [
			_slotIndex,
			_currentSpacing,
			_requiredTotalDistance
		];
	};
};

private _distributionRoute = [
	_distributionRoadObjects
] call A3C_main_fnc_compileRoadRoute;

if (_distributionRoute isEqualTo []) exitWith {
	[
		"ROUTE_COMPILE_FAILED"
	] call _recordDistributionDebug;

	[]
};

/*
 * Returns all known graph neighbours of a road.
 *
 * Besides normal outgoing connections, nearby reverse-only
 * connections are included because Arma road connection data can be
 * asymmetric. At graph endpoints, one small inferred connection may
 * repair a terrain-config gap between physically adjacent roads.
 */
private _getExtensionNeighbours = {
	params [
		"_road"
	];

	private _roadPosition =
		position _road;

	private _neighbours =
		+(roadsConnectedTo _road);

	{
		private _candidateRoad =
			_x;

		if (
			!isNull _candidateRoad
			&& {
				!(_candidateRoad isEqualTo _road)
			}
			&& {
				_road in (
					roadsConnectedTo _candidateRoad
				)
			}
		) then {
			_neighbours pushBackUnique
				_candidateRoad;
		};
	} forEach (
		_roadPosition nearRoads 30
	);

	/*
	 * Only an apparent endpoint may infer a missing physical
	 * connection. This avoids connecting ordinary parallel roads or
	 * unrelated crossings.
	 */
	if (count _neighbours <= 1) then {
		private _bridgeCandidates =
			(_roadPosition nearRoads 18) select {
				private _candidateRoad =
					_x;

				private _candidatePosition =
					position _candidateRoad;

				!isNull _candidateRoad
				&& {
					!(_candidateRoad isEqualTo _road)
				}
				&& {
					!(_candidateRoad in _neighbours)
				}
				&& {
					abs (
						(_roadPosition select 2)
							- (_candidatePosition select 2)
					) <= 2
				}
			};

		if !(_bridgeCandidates isEqualTo []) then {
			_bridgeCandidates = [
				_bridgeCandidates,
				[],
				{
					_x distance2D _road
				},
				"ASCEND"
			] call BIS_fnc_sortBy;

			_neighbours pushBackUnique (
				_bridgeCandidates select 0
			);
		};
	};

	_neighbours
};

private _availableDistance =
	_distributionRoute select 3;

/*
 * If the route from the rear reference to the destination is shorter
 * than the complete formation, continue through the road graph beyond
 * that reference.
 *
 * Search state:
 *
 * [
 *     road path including the existing final road,
 *     extension distance,
 *     first turn,
 *     accumulated turn,
 *     outgoing heading
 * ]
 */
if (
	_availableDistance + 0.01
		< _requiredTotalDistance
) then {
	_debugExtensionAttempted = true;

	private _missingDistance =
		_requiredTotalDistance
			- _availableDistance;

	private _extensionStartRoad =
		_distributionRoadObjects select (
			(count _distributionRoadObjects) - 1
		);

	private _initialHeading = -1;

	if (count _distributionRoadObjects > 1) then {
		private _roadTowardDestination =
			_distributionRoadObjects select (
				(count _distributionRoadObjects) - 2
			);

		_initialHeading =
			_roadTowardDestination getDir
				_extensionStartRoad;
	} else {
		if (
			_pos distance2D _refPosStart
				> 1
		) then {
			_initialHeading =
				_pos getDir _refPosStart;
		};
	};

	private _openStates = [
		[
			[_extensionStartRoad],
			0,
			0,
			0,
			_initialHeading
		]
	];

	private _selectedExtensionState = [];
	private _maximumExpandedRoads = 256;

	private _getStateScore = {
		params [
			"_state"
		];

		(_state select 2) * 1000
			+ (_state select 3)
			+ ((_state select 1) * 0.001)
	};

	while {
		!(_openStates isEqualTo [])
		&& {
			_debugExtensionExpandedRoads
				< _maximumExpandedRoads
		}
	} do {
		private _bestStateOffset = 0;

		private _bestState =
			_openStates select 0;

		private _bestStateScore =
			[_bestState] call
				_getStateScore;

		if (count _openStates > 1) then {
			for "_stateIndex" from 1 to ((count _openStates) - 1) do {
				private _candidateState =
					_openStates select
						_stateIndex;

				private _candidateScore =
					[_candidateState] call
						_getStateScore;

				if (
					_candidateScore
						< _bestStateScore
				) then {
					_bestStateOffset =
						_stateIndex;

					_bestState =
						_candidateState;

					_bestStateScore =
						_candidateScore;
				};
			};
		};

		private _state =
			_openStates deleteAt
				_bestStateOffset;

		_state params [
			"_statePath",
			"_stateDistance",
			"_stateFirstTurn",
			"_stateTurnTotal",
			"_stateHeading"
		];

		if (
			_stateDistance + 0.01
				>= _missingDistance
		) exitWith {
			_selectedExtensionState =
				_state;
		};

		_debugExtensionExpandedRoads =
			_debugExtensionExpandedRoads + 1;

		private _currentRoad =
			_statePath select (
				(count _statePath) - 1
			);

		private _neighbours = [
			_currentRoad
		] call _getExtensionNeighbours;

		{
			private _candidateRoad =
				_x;

			if (
				!isNull _candidateRoad
				&& {
					!(_candidateRoad in _distributionRoadObjects)
				}
				&& {
					!(_candidateRoad in _statePath)
				}
			) then {
				private _segmentDistance =
					_currentRoad distance2D
						_candidateRoad;

				if (_segmentDistance > 0.1) then {
					private _candidateHeading =
						_currentRoad getDir
							_candidateRoad;

					private _turnDifference =
						if (_stateHeading < 0) then {
							0
						} else {
							abs (
								(
									(
										_candidateHeading
											- _stateHeading
											+ 540
									) % 360
								) - 180
							)
						};

					private _candidateFirstTurn =
						if (
							count _statePath == 1
						) then {
							_turnDifference
						} else {
							_stateFirstTurn
						};

					private _candidatePath =
						+_statePath;

					_candidatePath pushBack
						_candidateRoad;

					_openStates pushBack [
						_candidatePath,
						_stateDistance
							+ _segmentDistance,
						_candidateFirstTurn,
						_stateTurnTotal
							+ _turnDifference,
						_candidateHeading
					];
				};
			};
		} forEach _neighbours;
	};

	if !(
		_selectedExtensionState
			isEqualTo []
	) then {
		private _extensionRoadObjects =
			+(
				_selectedExtensionState
					select 0
			);

		/*
		 * The first extension road is already the last road in the
		 * existing distribution route.
		 */
		_extensionRoadObjects deleteAt 0;

		_distributionRoadObjects append
			_extensionRoadObjects;

		_debugExtensionRoadPositions =
			_extensionRoadObjects apply {
				position _x
			};

		_distributionRoute = [
			_distributionRoadObjects
		] call A3C_main_fnc_compileRoadRoute;

		_debugExtensionSucceeded =
			!(_distributionRoute isEqualTo []);
	};
};

if (_distributionRoute isEqualTo []) exitWith {
	[
		"ROUTE_COMPILE_FAILED"
	] call _recordDistributionDebug;

	[]
};

_distributionRoute params [
	"_unusedRoadObjects",
	"_roadPositions",
	"_cumulativeDistances",
	"_totalDistance"
];

if (_roadPositions isEqualTo []) exitWith {
	[
		"ROUTE_POSITIONS_EMPTY",
		[],
		_distributionRoute
	] call _recordDistributionDebug;

	[]
};

/*
 * Returns the exact position at a cumulative distance along the
 * reversed distribution route.
 */
private _sampleRoutePosition = {
	params [
		"_distance"
	];

	if (_distance <= 0) exitWith {
		+(_roadPositions select 0)
	};

	private _lastPositionIndex =
		(count _roadPositions) - 1;

	if (_distance >= _totalDistance) exitWith {
		+(
			_roadPositions select
				_lastPositionIndex
		)
	};

	private _upperIndex =
		_cumulativeDistances findIf {
			_x >= _distance
		};

	if (_upperIndex <= 0) exitWith {
		+(_roadPositions select 0)
	};

	private _lowerIndex =
		_upperIndex - 1;

	private _lowerDistance =
		_cumulativeDistances select
			_lowerIndex;

	private _upperDistance =
		_cumulativeDistances select
			_upperIndex;

	private _segmentDistance =
		_upperDistance
			- _lowerDistance;

	if (_segmentDistance <= 0) exitWith {
		+(
			_roadPositions select
				_upperIndex
		)
	};

	private _segmentFraction =
		(
			_distance
				- _lowerDistance
		)
		/ _segmentDistance;

	private _lowerPosition =
		_roadPositions select
			_lowerIndex;

	private _upperPosition =
		_roadPositions select
			_upperIndex;

	[
		(_lowerPosition select 0)
			+ (
				(
					(_upperPosition select 0)
						- (_lowerPosition select 0)
				)
				* _segmentFraction
			),
		(_lowerPosition select 1)
			+ (
				(
					(_upperPosition select 1)
						- (_lowerPosition select 1)
				)
				* _segmentFraction
			),
		(_lowerPosition select 2)
			+ (
				(
					(_upperPosition select 2)
						- (_lowerPosition select 2)
				)
				* _segmentFraction
			)
	]
};

/*
 * The leading waypoint remains exactly under the user's click or
 * drag position. The resolved road route is used only to distribute
 * the trailing convoy waypoints behind it.
 */
private _positions = [
	+_pos
];

private _lastRequiredDistance =
	_requiredTotalDistance;

private _failedSlot = -1;

if (count _orderedGroups > 1) then {
	for "_slotIndex" from 1 to ((count _orderedGroups) - 1) do {
		private _requiredDistance =
			_requiredSlotDistances select (
				_slotIndex - 1
			);

		if (
			_requiredDistance
				> (_totalDistance + 0.01)
		) exitWith {
			_failedSlot =
				_slotIndex;

			_positions = [];
		};

		_positions pushBack (
			[
				_requiredDistance
			] call _sampleRoutePosition
		);
	};
};

if (_positions isEqualTo []) then {
	[
		"ROAD_CORRIDOR_INSUFFICIENT",
		[],
		_distributionRoute,
		_lastRequiredDistance,
		_failedSlot
	] call _recordDistributionDebug;
} else {
	[
		"ROAD_DISTRIBUTION_SUCCESS",
		_positions,
		_distributionRoute,
		_lastRequiredDistance,
		-1
	] call _recordDistributionDebug;
};

_positions
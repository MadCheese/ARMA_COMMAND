// A3C_main_fnc_generateWpWedgePositions

params [
	"_pos",
	"_refGroups",
	"_amount",
	"_dir",
	"_spacing"
];

/*
 * Reset the synchronous result before doing any work so callers can
 * never accidentally read the result of an earlier invocation.
 *
 * This state is local to the executing machine and is not broadcast.
 */
missionNamespace setVariable [
	"A3C_CONVOY_WP_POSITION_RESULT_LOCAL",
	createHashMapFromArray [
		["valid", false],
		["result", "NOT_EVALUATED"],
		["roadAlignmentAttempted", false],
		["usedWedge", false],
		["targetIsOnRoad", isOnRoad _pos],
		["generatedPositionCount", 0],
		["expectedPositionCount", _amount]
	]
];

private _positions = [
	_pos
];

private _useWedge = true;
private _roadAlignmentAttempted = false;
private _referencePosition = [];
private _referenceSource = "";
private _referenceGroupID = "";

private _debugEnabled =
	missionNamespace getVariable [
		"A3C_DEBUG_CONVOY_ROADS",
		false
	];

private _debugState =
	createHashMap;

private _debugAttemptID = -1;


if (_debugEnabled) then {
	A3C_CONVOY_ROAD_DEBUG_ATTEMPT_COUNTER =
		(
			missionNamespace getVariable [
				"A3C_CONVOY_ROAD_DEBUG_ATTEMPT_COUNTER",
				0
			]
		) + 1;

	_debugAttemptID =
		A3C_CONVOY_ROAD_DEBUG_ATTEMPT_COUNTER;

	A3C_CONVOY_ROAD_DEBUG_LATEST_ISSUED =
		_debugAttemptID;

	_debugState = createHashMapFromArray [
		["enabled", true],
		["attemptID", _debugAttemptID],
		["operation", "CREATE"],
		["issuedAt", diag_tickTime],
		["targetPosition", +_pos],
		["targetIsOnRoad", isOnRoad _pos],
		["referenceGroupCount", count _refGroups],
		[
			"referenceGroupIDs",
			_refGroups apply {
				groupID _x
			}
		],
		["routeBuilds", []]
	];
};

if (
	isOnRoad _pos
	&& {!(_refGroups isEqualTo [])}
) then {
	_useWedge = false;
	_roadAlignmentAttempted = true;

	/*
	 * _refGroups is already supplied in permanent convoy order.
	 * Do not reorder it according to current physical distance.
	 */
	private _orderedRefGroups =
		+_refGroups;

	/*
	 * The rear-most group establishes the beginning of the placement
	 * corridor.
	 *
	 * For a future bundle, its final existing waypoint represents
	 * the rear of the convoy's planned approach. If no active
	 * waypoint remains, the rear vehicle's current position is used.
	 *
	 * This prevents a short movement of the leading waypoint from
	 * incorrectly limiting the road distance available for the
	 * complete convoy bundle.
	 */
	private _refGroup =
		_orderedRefGroups select (
			(count _orderedRefGroups) - 1
		);

	_referenceGroupID =
		groupID _refGroup;

	private _refWaypoints =
		waypoints _refGroup;

	private _isGroupOnFinalWP =
		currentWaypoint _refGroup
			>= count _refWaypoints;

	private _refPosStart =
		if (
			_isGroupOnFinalWP
			|| {_refWaypoints isEqualTo []}
		) then {
			_referenceSource =
				"REAR_GROUP_VEHICLE";

			position vehicle leader _refGroup
		} else {
			private _lastWaypoint =
				_refWaypoints select (
					(count _refWaypoints) - 1
				);

			_referenceSource =
				"REAR_GROUP_FINAL_WAYPOINT";

			waypointPosition [
				_refGroup,
				_lastWaypoint select 1
			]
		};

	_referencePosition =
		+_refPosStart;

	private _roadPositions = [
		_pos,
		_orderedRefGroups,
		_refPosStart,
		objNull,
		_debugState,
		"CREATE_FULL"
	] call A3C_main_fnc_generateRoadWpPositions;

	if (_roadPositions isEqualTo []) then {
		/*
		 * This was an eligible road operation. Failure must remain a
		 * road-alignment failure; it must not silently become an
		 * open-terrain wedge.
		 *
		 * The calling command will later reject the complete
		 * waypoint operation and report the specific reason.
		 */
		_positions = [];
	} else {
		_positions =
			_roadPositions;
	};
};

/*
 * Wedge distribution is used only when road alignment was never
 * attempted, such as a normal open-terrain destination.
 */
if (_useWedge) then {
	_positions = [
		_pos
	];

	private _currentSpacing =
		_spacing;

	/*
	 * _positions already contains the leading position. Generate
	 * only the remaining _amount - 1 positions.
	 */
	if (_amount > 1) then {
		for "_i" from 0 to (_amount - 2) do {
			private _stepAngle =
				if ((_i % 2) == 0) then {
					(_dir + 180) + 45
				} else {
					(_dir + 180) - 45
				};

			if (
				_i != 0
				&& {(_i % 2) == 0}
			) then {
				_currentSpacing =
					_currentSpacing + _spacing;
			};

			_positions pushBack (
				[
					_pos,
					_currentSpacing,
					_stepAngle
				] call BIS_fnc_relPos
			);
		};
	};
};

/*
 * Publish a compact operational result independently of road
 * debugging. The calling convoy command reads this synchronously
 * before creating any waypoints.
 */
private _generatedPositionCount =
	count _positions;

private _positionCountValid =
	_generatedPositionCount
		== _amount;

private _creationValid = false;
private _creationResultCode =
	"WAYPOINT_DISTRIBUTION_FAILED";

if (_roadAlignmentAttempted) then {
	private _distributionResult =
		_debugState getOrDefault [
			"distributionResult",
			createHashMap
		];

	private _distributionValid =
		_distributionResult getOrDefault [
			"valid",
			false
		];

	if (
		_distributionValid
		&& {_positionCountValid}
	) then {
		_creationValid = true;
		_creationResultCode =
			"ROAD_DISTRIBUTION_SUCCESS";
	} else {
		_creationResultCode =
			_distributionResult getOrDefault [
				"result",
				"ROAD_ALIGNMENT_FAILED"
			];

		if (
			_creationResultCode
				== "ROAD_DISTRIBUTION_SUCCESS"
		) then {
			_creationResultCode =
				"ROAD_POSITION_COUNT_MISMATCH";
		};
	};
} else {
	if (
		isOnRoad _pos
		&& {_refGroups isEqualTo []}
	) then {
		_creationResultCode =
			"NO_REFERENCE_GROUPS";
	} else {
		if (_positionCountValid) then {
			_creationValid = true;
			_creationResultCode =
				"WEDGE_SUCCESS";
		} else {
			_creationResultCode =
				"WEDGE_POSITION_COUNT_MISMATCH";
		};
	};
};

private _creationResult =
	createHashMapFromArray [
		["valid", _creationValid],
		["result", _creationResultCode],
		[
			"roadAlignmentAttempted",
			_roadAlignmentAttempted
		],
		[
			"usedWedge",
			_useWedge
				&& {!_roadAlignmentAttempted}
		],
		["targetIsOnRoad", isOnRoad _pos],
		[
			"generatedPositionCount",
			_generatedPositionCount
		],
		["expectedPositionCount", _amount],
		["targetPosition", +_pos],
		[
			"referencePosition",
			+_referencePosition
		],
		["referenceSource", _referenceSource],
		["referenceGroupID", _referenceGroupID]
	];

missionNamespace setVariable [
	"A3C_CONVOY_WP_POSITION_RESULT_LOCAL",
	_creationResult
];


if (_debugEnabled) then {
	private _operationResult =
		_creationResult getOrDefault [
			"result",
			"WAYPOINT_DISTRIBUTION_FAILED"
		];

	private _operationValid =
		_creationResult getOrDefault [
			"valid",
			false
		];

	private _operationCategory =
		if (_operationValid) then {
			if (_roadAlignmentAttempted) then {
				"ROAD_ALIGNMENT_SUCCESS"
			} else {
				"WEDGE_DISTRIBUTION"
			}
		} else {
			if (_roadAlignmentAttempted) then {
				"ALIGNMENT_FAILURE"
			} else {
				if (isOnRoad _pos) then {
					"ROAD_GATE_FAILED"
				} else {
					"WEDGE_FAILURE"
				}
			}
		};

	_debugState set [
		"operationResult",
		createHashMapFromArray [
			["category", _operationCategory],
			["result", _operationResult],
			[
				"roadAlignmentAttempted",
				_roadAlignmentAttempted
			],
			[
				"usedWedge",
				_creationResult getOrDefault [
					"usedWedge",
					false
				]
			],
			["valid", _operationValid],
			[
				"generatedPositionCount",
				_generatedPositionCount
			],
			["expectedPositionCount", _amount],
			[
				"referencePosition",
				+_referencePosition
			],
			[
				"referenceSource",
				_referenceSource
			],
			[
				"referenceGroupID",
				_referenceGroupID
			],
			[
				"finalPositions",
				+_positions
			],
			["completedAt", diag_tickTime]
		]
	];

	A3C_CONVOY_ROAD_DEBUG_LATEST_ROUTE_COMMIT =
		_debugAttemptID;

	A3C_CONVOY_ROAD_DEBUG_DRAW =
		_debugState;
};

_positions
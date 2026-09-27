// A3C_ui_mapOverlay_fnc_onDragMapHCWP

// Adjusts the position of an HC waypoint while it is being dragged.

params [
	"_waypoint",
	"_data",
	["_dragSnapshot", [], [[]]]
];

_waypoint params [
	"_group",
	"_wpi"
];

if (A3C_BOOL_DISABLEMAPCTRL) exitWith {};

disableSerialization;

private _mapControl =
	findDisplay 12 displayCtrl 51;

private _dragPos =
	_mapControl posScreenToWorld [
		_data select 1,
		_data select 2
	];

private _debugEnabled =
	missionNamespace getVariable [
		"A3C_DEBUG_CONVOY_ROADS",
		false
	];

private _debugState =
	createHashMap;

private _debugAttemptID = -1;
private _debugCategory = "NOT_APPLICABLE";
private _debugResultCode = "UNCLASSIFIED";
private _debugFallbackReason = "";
private _debugRoadAlignmentAttempted = false;
private _debugRoadGatePassed = false;
private _debugRoadStateValid = false;
private _debugUsedSnapshot = false;
private _debugRouteCommitMade = false;
private _debugWaypointCommitMade = false;
private _debugStaleRouteCommit = false;
private _debugStaleWaypointCommit = false;
private _debugReferencePosition = [];
private _debugReferenceSource = "";
private _debugReferenceGroupID = "";
private _debugReferenceWaypointIndex = -1;
private _debugSnapshotEntries = [];
private _debugCalculatedRoadPositions = [];

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
		["operation", "DRAG"],
		["issuedAt", diag_tickTime],
		["targetPosition", +_dragPos],
		["targetIsOnRoad", isOnRoad _dragPos],
		["draggedWaypoint", str _waypoint],
		["draggedGroup", groupID _group],
		["draggedWaypointIndex", _wpi],
		["routeBuilds", []]
	];
};

private _debugMarkRouteCommit = {
	if (!_debugEnabled) exitWith {};

	_debugRouteCommitMade = true;

	_debugStaleRouteCommit =
		_debugAttemptID
			< (
				missionNamespace getVariable [
					"A3C_CONVOY_ROAD_DEBUG_LATEST_ISSUED",
					_debugAttemptID
				]
			);

	A3C_CONVOY_ROAD_DEBUG_LATEST_ROUTE_COMMIT =
		_debugAttemptID;
};

private _debugMarkWaypointCommit = {
	if (!_debugEnabled) exitWith {};

	_debugWaypointCommitMade = true;

	_debugStaleWaypointCommit =
		_debugAttemptID
			< (
				missionNamespace getVariable [
					"A3C_CONVOY_ROAD_DEBUG_LATEST_ISSUED",
					_debugAttemptID
				]
			);

	A3C_CONVOY_ROAD_DEBUG_LATEST_WAYPOINT_COMMIT =
		_debugAttemptID;
};

private _debugPublish = {
	if (!_debugEnabled) exitWith {};

	private _snapshotFallbackPositions = [];

	if !(_debugSnapshotEntries isEqualTo []) then {
		_snapshotFallbackPositions =
			_debugSnapshotEntries apply {
				_x params [
					"_snapshotWaypoint",
					"_relativeOffset"
				];

				if (
					_snapshotWaypoint
						isEqualTo _waypoint
				) then {
					+_dragPos
				} else {
					[
						(_dragPos select 0)
							+ (_relativeOffset select 0),
						(_dragPos select 1)
							+ (_relativeOffset select 1),
						1000
					]
				}
			};
	};

	private _finalWaypointPositions =
		if (_debugSnapshotEntries isEqualTo []) then {
			[
				waypointPosition _waypoint
			]
		} else {
			_debugSnapshotEntries apply {
				waypointPosition (_x select 0)
			}
		};

	_debugState set [
		"operationResult",
		createHashMapFromArray [
			["category", _debugCategory],
			["result", _debugResultCode],
			[
				"fallbackReason",
				_debugFallbackReason
			],
			[
				"roadAlignmentAttempted",
				_debugRoadAlignmentAttempted
			],
			[
				"roadGatePassed",
				_debugRoadGatePassed
			],
			[
				"roadStateValid",
				_debugRoadStateValid
			],
			[
				"usedSnapshotFallback",
				_debugUsedSnapshot
			],
			[
				"referencePosition",
				+_debugReferencePosition
			],
			[
				"referenceSource",
				_debugReferenceSource
			],
			[
				"referenceGroupID",
				_debugReferenceGroupID
			],
			[
				"referenceWaypointIndex",
				_debugReferenceWaypointIndex
			],
			[
				"calculatedRoadPositions",
				+_debugCalculatedRoadPositions
			],
			[
				"snapshotFallbackPositions",
				_snapshotFallbackPositions
			],
			[
				"finalWaypointPositions",
				_finalWaypointPositions
			],
			[
				"routeCommitMade",
				_debugRouteCommitMade
			],
			[
				"waypointCommitMade",
				_debugWaypointCommitMade
			],
			[
				"staleRouteCommit",
				_debugStaleRouteCommit
			],
			[
				"staleWaypointCommit",
				_debugStaleWaypointCommit
			],
			[
				"latestIssuedAttempt",
				missionNamespace getVariable [
					"A3C_CONVOY_ROAD_DEBUG_LATEST_ISSUED",
					-1
				]
			],
			[
				"latestRouteCommit",
				missionNamespace getVariable [
					"A3C_CONVOY_ROAD_DEBUG_LATEST_ROUTE_COMMIT",
					-1
				]
			],
			[
				"latestWaypointCommit",
				missionNamespace getVariable [
					"A3C_CONVOY_ROAD_DEBUG_LATEST_WAYPOINT_COMMIT",
					-1
				]
			],
			["completedAt", diag_tickTime]
		]
	];

	A3C_CONVOY_ROAD_DEBUG_DRAW =
		_debugState;

	if (
		_debugStaleRouteCommit
		|| {_debugStaleWaypointCommit}
	) then {
		private _logSignature = [
			_debugAttemptID,
			_debugStaleRouteCommit,
			_debugStaleWaypointCommit,
			_debugResultCode
		];

		if !(
			_logSignature isEqualTo (
				missionNamespace getVariable [
					"A3C_CONVOY_ROAD_DEBUG_LAST_LOG_SIGNATURE",
					[]
				]
			)
		) then {
			A3C_CONVOY_ROAD_DEBUG_LAST_LOG_SIGNATURE =
				+_logSignature;

			diag_log format [
				"[A3C CONVOY ROAD DEBUG] Stale commit observed | Attempt: %1 | Latest issued: %2 | Route stale: %3 | Waypoint stale: %4 | Result: %5",
				_debugAttemptID,
				A3C_CONVOY_ROAD_DEBUG_LATEST_ISSUED,
				_debugStaleRouteCommit,
				_debugStaleWaypointCommit,
				_debugResultCode
			];
		};
	};
};

private _hasBundleSnapshot =
	count _dragSnapshot == 3
	&& {
		(_dragSnapshot select 0)
			isEqualTo _waypoint
	};

if !(_waypoint in A3C_Selection_MultiWaypoint) then {
	call _debugMarkRouteCommit;

	A3C_HC_WP_DRAG_ROAD_STATE = [];

	call _debugMarkWaypointCommit;

	_waypoint setWaypointPosition [
		_dragPos,
		0
	];

	_debugResultCode =
		"SINGLE_WAYPOINT_DRAG";
} else {
	if (_hasBundleSnapshot) then {
		private _bundleIndex =
			_dragSnapshot select 1;

		private _snapshotEntries =
			_dragSnapshot select 2;

		_debugSnapshotEntries =
			+_snapshotEntries;

		_debugState set [
			"bundleIndex",
			_bundleIndex
		];

		_debugState set [
			"snapshotCount",
			count _snapshotEntries
		];

		/*
		 * Restores the immutable relative-position snapshot captured
		 * on mouse-down.
		 */
		private _fnc_applySnapshot = {
			_debugUsedSnapshot = true;

			call _debugMarkWaypointCommit;

			_waypoint setWaypointPosition [
				_dragPos,
				0
			];

			{
				_x params [
					"_snapshotWaypoint",
					"_relativeOffset"
				];

				if !(
					_snapshotWaypoint
						isEqualTo _waypoint
				) then {
					private _newWaypointPos = [
						(_dragPos select 0)
							+ (_relativeOffset select 0),
						(_dragPos select 1)
							+ (_relativeOffset select 1),
						1000
					];

					_snapshotWaypoint setWaypointPosition [
						_newWaypointPos,
						-1
					];
				};
			} forEach _snapshotEntries;
		};

		private _snapshotContainsEntries =
			!(_snapshotEntries isEqualTo []);

		private _isLeadingBundleWaypoint =
			_bundleIndex == 0;

		private _snapshotLeaderMatches =
			_snapshotContainsEntries
			&& {
				(
					(_snapshotEntries select 0)
						select 0
				) isEqualTo _waypoint
			};

		private _targetIsOnRoad =
			isOnRoad _dragPos;

		/*
		 * Road distribution is available only when:
		 *
		 * - the snapshot contains waypoints;
		 * - the dragged waypoint is the first still-relevant waypoint
		 *   in the permanent bundle order;
		 * - the dragged position is on a road.
		 */
		private _useRoadDistribution =
			_snapshotContainsEntries
			&& {_isLeadingBundleWaypoint}
			&& {_snapshotLeaderMatches}
			&& {_targetIsOnRoad};

		_debugRoadGatePassed =
			_useRoadDistribution;

		_debugRoadAlignmentAttempted =
			_useRoadDistribution;

		_debugState set [
			"roadGate",
			createHashMapFromArray [
				[
					"snapshotContainsEntries",
					_snapshotContainsEntries
				],
				[
					"isLeadingBundleWaypoint",
					_isLeadingBundleWaypoint
				],
				[
					"snapshotLeaderMatches",
					_snapshotLeaderMatches
				],
				[
					"targetIsOnRoad",
					_targetIsOnRoad
				]
			]
		];

		if (_useRoadDistribution) then {
			/*
			* Establish the immutable approach reference once when
			* road mode begins.
			*
			* The reference belongs to the rear-most waypoint in the
			* permanent bundle order, not the dragged leading waypoint.
			*
			* For the rear group's current waypoint, its vehicle position
			* is used. For a future waypoint, the waypoint immediately
			* preceding that rear waypoint is used.
			*
			* State structure:
			*
			* [
			*     _refPosStart,
			*     _routeState,
			*     _referenceSource,
			*     _referenceGroupID,
			*     _referenceWaypointIndex
			* ]
			*/
			if (
				A3C_HC_WP_DRAG_ROAD_STATE
					isEqualTo []
			) then {
				private _rearSnapshotEntry =
					_snapshotEntries select (
						(count _snapshotEntries) - 1
					);

				private _rearWaypoint =
					_rearSnapshotEntry select 0;

				_rearWaypoint params [
					"_rearGroup",
					"_rearWpi"
				];

				private _rearCurrentWaypoint =
					currentWaypoint _rearGroup;

				private _hasValidReference =
					_rearWpi >= _rearCurrentWaypoint;

				private _refPosStart =
					position vehicle leader _rearGroup;

				private _referenceSource =
					"REAR_GROUP_VEHICLE";

				/*
				* A future rear waypoint approaches from that group's
				* immediately preceding waypoint.
				*/
				if (
					_hasValidReference
					&& {
						_rearWpi > _rearCurrentWaypoint
					}
				) then {
					private _previousRearWaypoint = [
						_rearGroup,
						_rearWpi - 1
					];

					if (
						_previousRearWaypoint
							in waypoints _rearGroup
					) then {
						_refPosStart =
							waypointPosition
								_previousRearWaypoint;

						_referenceSource =
							"REAR_GROUP_PREVIOUS_WAYPOINT";
					} else {
						_hasValidReference =
							false;
					};
				};

				_debugState set [
					"referenceSelection",
					createHashMapFromArray [
						[
							"valid",
							_hasValidReference
						],
						[
							"source",
							_referenceSource
						],
						[
							"groupID",
							groupID _rearGroup
						],
						[
							"waypointIndex",
							_rearWpi
						],
						[
							"position",
							+_refPosStart
						]
					]
				];

				_debugReferencePosition =
					+_refPosStart;

				_debugReferenceSource =
					_referenceSource;

				_debugReferenceGroupID =
					groupID _rearGroup;

				_debugReferenceWaypointIndex =
					_rearWpi;

				if (_hasValidReference) then {
					call _debugMarkRouteCommit;

					A3C_HC_WP_DRAG_ROAD_STATE = [
						+_refPosStart,
						[],
						_referenceSource,
						groupID _rearGroup,
						_rearWpi
					];
				};
			};

			/*
			 * Capture the complete state once. Never perform separate
			 * reads from the mutable global state during one drag
			 * update.
			 */
			private _capturedRoadState =
				+A3C_HC_WP_DRAG_ROAD_STATE;

			private _hasValidCapturedRoadState =
				count _capturedRoadState >= 2
				&& {
					(_capturedRoadState select 0)
						isEqualType []
				}
				&& {
					count (
						_capturedRoadState select 0
					) >= 2
				}
				&& {
					(_capturedRoadState select 1)
						isEqualType []
				};

			_debugRoadStateValid =
				_hasValidCapturedRoadState;

			if (_hasValidCapturedRoadState) then {
				_capturedRoadState params [
					"_refPosStart",
					"_routeState"
				];

				_debugReferencePosition =
					+_refPosStart;

				_debugReferenceSource =
					_capturedRoadState param [
						2,
						""
					];

				_debugReferenceGroupID =
					_capturedRoadState param [
						3,
						""
					];

				_debugReferenceWaypointIndex =
					_capturedRoadState param [
						4,
						-1
					];

				private _updatedRouteState = [
					_refPosStart,
					_dragPos,
					_routeState,
					750,
					64,
					50,
					_debugState
				] call A3C_main_fnc_updateRoadRoute;

				call _debugMarkRouteCommit;

				A3C_HC_WP_DRAG_ROAD_STATE set [
					1,
					_updatedRouteState
				];

				private _travelRoute =
					_updatedRouteState select 0;

				private _orderedGroups =
					_snapshotEntries apply {
						private _snapshotWaypoint =
							_x select 0;

						_snapshotWaypoint select 0
					};

				private _roadPositions = [];

				/*
				 * An empty route represents a cached route failure.
				 * Do not call the position generator, because doing so
				 * could otherwise initiate another complete search.
				 */
				if !(_travelRoute isEqualTo []) then {
					_roadPositions = [
						_dragPos,
						_orderedGroups,
						_refPosStart,
						_travelRoute,
						_debugState,
						"DRAG_CACHED"
					] call A3C_main_fnc_generateRoadWpPositions;
				};

				_debugCalculatedRoadPositions =
					+_roadPositions;

				if (
					count _roadPositions
						== count _snapshotEntries
				) then {
					call _debugMarkWaypointCommit;

					{
						_x params [
							"_snapshotWaypoint"
						];

						private _roadWaypointPos =
							+(
								_roadPositions
									select _forEachIndex
							);

						if (
							_snapshotWaypoint
								isEqualTo _waypoint
						) then {
							_snapshotWaypoint setWaypointPosition [
								_roadWaypointPos,
								0
							];
						} else {
							_roadWaypointPos set [
								2,
								1000
							];

							_snapshotWaypoint setWaypointPosition [
								_roadWaypointPos,
								-1
							];
						};
					} forEach _snapshotEntries;

					_debugCategory =
						"ROAD_ALIGNMENT_SUCCESS";

					_debugResultCode =
						"ROAD_DISTRIBUTION_SUCCESS";
				} else {
					_debugCategory =
						"ALIGNMENT_FAILURE";

					if (_travelRoute isEqualTo []) then {
						_debugResultCode =
							"ROUTE_INVALID";
					} else {
						/*
						* distributionResult is operational state and
						* therefore exists independently of road-debug
						* visualization.
						*/
						private _distributionResult =
							_debugState getOrDefault [
								"distributionResult",
								createHashMap
							];

						_debugResultCode =
							_distributionResult getOrDefault [
								"result",
								"POSITION_COUNT_MISMATCH"
							];
					};

					/*
					* A transient road-calculation failure must not replace the
					* road-aligned bundle with the translated unsnapped formation.
					* No waypoint is written, leaving the most recent valid preview
					* unchanged.
					*/
					_debugFallbackReason =
						"LAST_COMMITTED_PREVIEW_RETAINED";
				};
			} else {
				_debugCategory =
					"ALIGNMENT_FAILURE";

				_debugResultCode =
					"REFERENCE_INVALID";

				/*
				* Preserve the last valid bundle position. Final rejection and
				* user feedback will be handled on mouse-up.
				*/
				_debugFallbackReason =
					"LAST_COMMITTED_PREVIEW_RETAINED";
			};
		} else {
			/*
			 * Leaving road mode invalidates the cached cursor-road
			 * history. The original mouse-down formation is restored.
			 */
			call _debugMarkRouteCommit;

			A3C_HC_WP_DRAG_ROAD_STATE = [];

			_debugCategory =
				"ROAD_GATE_FAILED";

			_debugResultCode =
				"ROAD_GATE_FAILED";

			_debugFallbackReason =
				if (!_snapshotContainsEntries) then {
					"SNAPSHOT_EMPTY"
				} else {
					if (!_isLeadingBundleWaypoint) then {
						"NOT_LEADING_BUNDLE_WAYPOINT"
					} else {
						if (!_snapshotLeaderMatches) then {
							"SNAPSHOT_LEADER_MISMATCH"
						} else {
							"TARGET_NOT_ON_ROAD"
						}
					}
				};

			call _fnc_applySnapshot;
		};
	} else {
		call _debugMarkRouteCommit;

		A3C_HC_WP_DRAG_ROAD_STATE = [];

		// Regular multiple-waypoint drag.
		private _childWaypoints =
			A3C_Selection_MultiWaypoint - [
				_waypoint
			];

		private _parentWaypointPos =
			waypointPosition _waypoint;

		private _waypointRelPosMap =
			_childWaypoints apply {
				private _childWaypointPos =
					waypointPosition _x;

				[
					_parentWaypointPos
						distance2D _childWaypointPos,
					_parentWaypointPos
						getDir _childWaypointPos
				]
			};

		call _debugMarkWaypointCommit;

		_waypoint setWaypointPosition [
			_dragPos,
			0
		];

		{
			private _waypointRelPosMapEntry =
				_waypointRelPosMap
					select _forEachIndex;

			private _newWaypointPos =
				_dragPos getPos [
					_waypointRelPosMapEntry select 0,
					_waypointRelPosMapEntry select 1
				];

			_newWaypointPos set [
				2,
				1000
			];

			_x setWaypointPosition [
				_newWaypointPos,
				-1
			];
		} forEach _childWaypoints;

		_debugResultCode =
			"NO_BUNDLE_SNAPSHOT";
	};
};

/*
 * Publish the latest drag result independently of debug mode.
 *
 * Only a road alignment that was actually attempted and failed is
 * invalid. Ordinary dragging, off-road bundle dragging and regular
 * multiple-waypoint dragging remain valid operations.
 */
private _dragResultValid =
	!_debugRoadAlignmentAttempted
	|| {
		_debugCategory
			== "ROAD_ALIGNMENT_SUCCESS"
	};

private _operationalResultCode =
	if (
		!_debugRoadAlignmentAttempted
		&& {
			_debugCategory
				== "ROAD_GATE_FAILED"
		}
		&& {
			_debugFallbackReason != ""
		}
	) then {
		_debugFallbackReason
	} else {
		_debugResultCode
	};

private _dragResult =
	missionNamespace getVariable [
		"A3C_HC_WP_DRAG_RESULT",
		createHashMap
	];

if !(
	_dragResult isEqualType
		createHashMap
) then {
	_dragResult =
		createHashMap;
};

_dragResult set [
	"bundleDrag",
	_dragResult getOrDefault [
		"bundleDrag",
		_hasBundleSnapshot
	]
];

_dragResult set [
	"roadAlignmentAttempted",
	_debugRoadAlignmentAttempted
];

_dragResult set [
	"valid",
	_dragResultValid
];

_dragResult set [
	"category",
	_debugCategory
];

_dragResult set [
	"result",
	_operationalResultCode
];

_dragResult set [
	"fallbackReason",
	_debugFallbackReason
];

_dragResult set [
	"targetPosition",
	+_dragPos
];

_dragResult set [
	"updatedAt",
	diag_tickTime
];

A3C_HC_WP_DRAG_RESULT =
	_dragResult;

call _debugPublish;
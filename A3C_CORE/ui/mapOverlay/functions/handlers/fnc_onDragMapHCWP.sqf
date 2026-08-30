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

private _hasBundleSnapshot =
	count _dragSnapshot == 3
	&& {
		(_dragSnapshot select 0)
			isEqualTo _waypoint
	};

if !(_waypoint in A3C_Selection_MultiWaypoint) then {
	A3C_HC_WP_DRAG_ROAD_STATE = [];

	_waypoint setWaypointPosition [
		_dragPos,
		0
	];
} else {
	if (_hasBundleSnapshot) then {
		private _bundleIndex =
			_dragSnapshot select 1;

		private _snapshotEntries =
			_dragSnapshot select 2;

		/*
		 * Restores the immutable relative-position snapshot captured
		 * on mouse-down.
		 */
		private _fnc_applySnapshot = {
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

		/*
		 * Road distribution is available only when:
		 *
		 * - the snapshot contains waypoints;
		 * - the dragged waypoint is the first still-relevant waypoint
		 *   in the permanent bundle order;
		 * - the dragged position is on a road.
		 */
		private _useRoadDistribution =
			!(_snapshotEntries isEqualTo [])
			&& {
				_bundleIndex == 0
			}
			&& {
				(
					(_snapshotEntries select 0)
						select 0
				) isEqualTo _waypoint
			}
			&& {
				isOnRoad _dragPos
			};

		if (_useRoadDistribution) then {
			/*
			 * Establish the immutable approach reference once when
			 * road mode begins.
			 *
			 * State structure:
			 *
			 * [
			 *     _refPosStart,
			 *     _routeState
			 * ]
			 */
			if (
				A3C_HC_WP_DRAG_ROAD_STATE
					isEqualTo []
			) then {
				private _currentWaypoint =
					currentWaypoint _group;

				private _hasValidReference =
					_wpi >= _currentWaypoint;

				private _refPosStart =
					position vehicle leader _group;

				/*
				 * For a future waypoint, its preceding waypoint is
				 * the approach reference. For the current waypoint,
				 * the leading vehicle position is used.
				 */
				if (
					_hasValidReference
					&& {
						_wpi > _currentWaypoint
					}
				) then {
					private _previousWaypoint = [
						_group,
						_wpi - 1
					];

					if (
						_previousWaypoint
							in waypoints _group
					) then {
						_refPosStart =
							waypointPosition
								_previousWaypoint;
					} else {
						_hasValidReference =
							false;
					};
				};

				if (_hasValidReference) then {
					A3C_HC_WP_DRAG_ROAD_STATE = [
						+_refPosStart,
						[]
					];
				};
			};

			/*
			* Capture the complete state once. Never perform separate reads from
			* the mutable global state during one drag update.
			*/
			private _capturedRoadState =
				+A3C_HC_WP_DRAG_ROAD_STATE;

			private _hasValidCapturedRoadState =
				count _capturedRoadState == 2
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

			if (_hasValidCapturedRoadState) then {
				_capturedRoadState params [
					"_refPosStart",
					"_routeState"
				];

				private _updatedRouteState = [
					_refPosStart,
					_dragPos,
					_routeState
				] call A3C_main_fnc_updateRoadRoute;

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
						_travelRoute
					] call A3C_main_fnc_generateRoadWpPositions;
				};

				if (
					count _roadPositions
						== count _snapshotEntries
				) then {
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
				} else {
					call _fnc_applySnapshot;
				};
			} else {
				call _fnc_applySnapshot;
			};
		} else {
			/*
			 * Leaving road mode invalidates the cached cursor-road
			 * history. The original mouse-down formation is restored.
			 */
			A3C_HC_WP_DRAG_ROAD_STATE = [];

			call _fnc_applySnapshot;
		};
	} else {
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
	};
};
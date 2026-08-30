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
	["_roadSearchRadius", 50]
];

private _targetRoad =
	roadAt _targetPosition;

if (isNull _targetRoad) then {
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

		_targetRoad =
			_nearRoads select 0;
	};
};

if (isNull _targetRoad) exitWith {
	[
		[],
		objNull
	]
};

private _currentRoute = [];
private _lastAttemptedTargetRoad =
	objNull;

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
	};

	/*
	 * Cursor moved backwards onto an earlier road in the cached route.
	 */
	if (_resolvedState isEqualTo []) then {
		private _existingRoadIndex =
			_currentRoadObjects find _targetRoad;

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
				roadsConnectedTo _lastRoad
			)
			|| {
				_lastRoad in (
					roadsConnectedTo _targetRoad
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
			20
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
							(count _bridgeRoadObjects) - 1
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
			};
		};
	};
};

if !(_resolvedState isEqualTo []) exitWith {
	_resolvedState
};

/*
 * No usable cached continuation exists. Perform one bounded route
 * build from the immutable drag reference.
 */
private _newRoute = [
	_referencePosition,
	_targetPosition,
	_maximumInitialExpandedRoads,
	_roadSearchRadius
] call A3C_main_fnc_buildRoadRoute;

[
	_newRoute,
	_targetRoad
]
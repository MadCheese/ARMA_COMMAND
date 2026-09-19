// A3C_main_fnc_projectPositionOntoRoadRoute

/*
 * Projects a position onto a compiled road route.
 *
 * The route must use the format returned by
 * A3C_main_fnc_compileRoadRoute:
 *
 * [
 *     _roadObjects,
 *     _roadPositions,
 *     _cumulativeDistances,
 *     _totalDistance
 * ]
 *
 * _previousSegmentIndex and _expectedProgress provide continuity.
 * With a valid segment hint, only a small local part of the route is
 * searched first. The complete route is searched only when initial
 * acquisition is required or the local result is too far away.
 * _allowFullRouteSearch lets a caller impose a reacquisition
 * cooldown so an off-route vehicle cannot trigger a full scan on
 * every controller update.
 *
 * When similarly close route segments overlap or run in parallel,
 * the candidate nearest _expectedProgress is preferred. This avoids
 * jumping to another part of a hairpin or crossing route.
 *
 * Returns:
 *
 * [
 *     _routeProgress,
 *     _segmentIndex,
 *     _distanceFromRoute,
 *     _projectedPosition,
 *     _segmentFraction,
 *     _usedFullRouteSearch
 * ]
 *
 * Returns [] when the input or route is invalid, or when the route
 * contains no segment with measurable 2D length.
 */

params [
	["_position", [], [[]]],
	["_roadRoute", [], [[]]],
	["_previousSegmentIndex", -1, [0]],
	["_expectedProgress", -1, [0]],
	["_backwardSearchSegments", 3, [0]],
	["_forwardSearchSegments", 8, [0]],
	["_reacquireDistance", 40, [0]],
	["_continuityDistanceTolerance", 2, [0]],
	["_allowFullRouteSearch", true, [true]]
];

if (
	count _position < 2
	|| {count _roadRoute != 4}
) exitWith {
	[]
};

private _roadPositions =
	_roadRoute select 1;

private _cumulativeDistances =
	_roadRoute select 2;

if (
	count _roadPositions < 2
	|| {
		count _cumulativeDistances
			!= count _roadPositions
	}
) exitWith {
	[]
};

private _segmentCount =
	(count _roadPositions) - 1;

_previousSegmentIndex =
	floor _previousSegmentIndex;

_backwardSearchSegments =
	floor (0 max _backwardSearchSegments);

_forwardSearchSegments =
	floor (0 max _forwardSearchSegments);

_reacquireDistance =
	0 max _reacquireDistance;

_continuityDistanceTolerance =
	0 max _continuityDistanceTolerance;

private _positionX =
	_position select 0;

private _positionY =
	_position select 1;

/*
 * Finds the best projection inside an inclusive segment range.
 */
private _findBestProjection = {
	params [
		"_firstSegmentIndex",
		"_lastSegmentIndex"
	];

	private _bestProjection = [];
	private _bestDistance = 1e30;
	private _bestContinuityDifference = 1e30;

	for "_segmentIndex" from _firstSegmentIndex to _lastSegmentIndex do {
		private _segmentStart =
			_roadPositions select _segmentIndex;

		private _segmentEnd =
			_roadPositions select (_segmentIndex + 1);

		private _segmentDeltaX =
			(_segmentEnd select 0)
				- (_segmentStart select 0);

		private _segmentDeltaY =
			(_segmentEnd select 1)
				- (_segmentStart select 1);

		private _segmentLengthSquared =
			(_segmentDeltaX * _segmentDeltaX)
				+ (_segmentDeltaY * _segmentDeltaY);

		/*
		 * Ignore duplicate road positions. They carry no usable
		 * longitudinal information.
		 */
		private _segmentLength =
			(_cumulativeDistances select (_segmentIndex + 1))
				- (_cumulativeDistances select _segmentIndex);

		if (
			_segmentLengthSquared > 0.0001
			&& {_segmentLength > 0.01}
		) then {
			private _segmentFraction =
				(
					(
						(_positionX - (_segmentStart select 0))
							* _segmentDeltaX
					)
					+ (
						(_positionY - (_segmentStart select 1))
							* _segmentDeltaY
					)
				) / _segmentLengthSquared;

			_segmentFraction =
				0 max (1 min _segmentFraction);

			private _projectedX =
				(_segmentStart select 0)
					+ (_segmentDeltaX * _segmentFraction);

			private _projectedY =
				(_segmentStart select 1)
					+ (_segmentDeltaY * _segmentFraction);

			private _startZ =
				if (count _segmentStart > 2) then {
					_segmentStart select 2
				} else {
					0
				};

			private _endZ =
				if (count _segmentEnd > 2) then {
					_segmentEnd select 2
				} else {
					_startZ
				};

			private _projectedZ =
				_startZ
					+ (
						(_endZ - _startZ)
							* _segmentFraction
					);

			private _distanceDeltaX =
				_positionX - _projectedX;

			private _distanceDeltaY =
				_positionY - _projectedY;

			private _distanceFromRoute =
				sqrt (
					(_distanceDeltaX * _distanceDeltaX)
						+ (_distanceDeltaY * _distanceDeltaY)
				);

			private _routeProgress =
				(_cumulativeDistances select _segmentIndex)
					+ (_segmentLength * _segmentFraction);

			private _continuityDifference =
				if (_expectedProgress >= 0) then {
					abs (
						_routeProgress
							- _expectedProgress
					)
				} else {
					if (_previousSegmentIndex >= 0) then {
						abs (
							_segmentIndex
								- _previousSegmentIndex
						)
					} else {
						_segmentIndex
					}
				};

			private _replaceBest =
				_bestProjection isEqualTo []
				|| {
					_distanceFromRoute
						< (
							_bestDistance
								- _continuityDistanceTolerance
						)
				};

			/*
			 * If candidates are similarly close in world space,
			 * prefer continuity along the route.
			 */
			if (
				!_replaceBest
				&& {
					abs (
						_distanceFromRoute
							- _bestDistance
					) <= _continuityDistanceTolerance
				}
			) then {
				_replaceBest =
					_continuityDifference
						< _bestContinuityDifference
					|| {
						_continuityDifference
							isEqualTo
						_bestContinuityDifference
						&& {
							_distanceFromRoute
								< _bestDistance
						}
					};
			};

			if (_replaceBest) then {
				_bestDistance =
					_distanceFromRoute;

				_bestContinuityDifference =
					_continuityDifference;

				_bestProjection = [
					_routeProgress,
					_segmentIndex,
					_distanceFromRoute,
					[
						_projectedX,
						_projectedY,
						_projectedZ
					],
					_segmentFraction
				];
			};
		};
	};

	_bestProjection
};

private _hasValidSegmentHint =
	_previousSegmentIndex >= 0
	&& {
		_previousSegmentIndex
			< _segmentCount
	};

private _projection = [];
private _usedFullRouteSearch = false;

if (_hasValidSegmentHint) then {
	private _firstLocalSegment =
		0 max (
			_previousSegmentIndex
				- _backwardSearchSegments
		);

	private _lastLocalSegment =
		(_segmentCount - 1) min (
			_previousSegmentIndex
				+ _forwardSearchSegments
		);

	_projection = [
		_firstLocalSegment,
		_lastLocalSegment
	] call _findBestProjection;
};

/*
 * Initial acquisition, an invalid hint, or a distant local result
 * requires a complete route scan.
 */
private _requiresFullRouteSearch =
	_projection isEqualTo []
	|| {
		(_projection select 2)
			> _reacquireDistance
	};

if (
	_requiresFullRouteSearch
	&& {_allowFullRouteSearch}
) then {
	_projection = [
		0,
		_segmentCount - 1
	] call _findBestProjection;

	_usedFullRouteSearch = true;
};

if (_projection isEqualTo []) exitWith {
	[]
};

_projection pushBack
	_usedFullRouteSearch;

_projection

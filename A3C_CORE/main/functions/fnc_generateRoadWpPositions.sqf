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
 */

params [
	"_pos",
	"_orderedGroups",
	"_refPosStart",
	["_travelRoute", []]
];

private _travelRouteWasSupplied = count _this > 3;

if (_orderedGroups isEqualTo []) exitWith {
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
		_pos
	] call A3C_main_fnc_buildRoadRoute;
};

if (
	_travelRoute isEqualTo []
	|| {count _travelRoute != 4}
) exitWith {
	[]
};

/*
 * Copy before reversing. Reversing the array contained inside the
 * cached route would corrupt its forward travel direction.
 */
private _distributionRoadObjects =
	+(_travelRoute select 0);

if (_distributionRoadObjects isEqualTo []) exitWith {
	[]
};

reverse _distributionRoadObjects;

private _distributionRoute = [
	_distributionRoadObjects
] call A3C_main_fnc_compileRoadRoute;

if (_distributionRoute isEqualTo []) exitWith {
	[]
};

_distributionRoute params [
	"_unusedRoadObjects",
	"_roadPositions",
	"_cumulativeDistances",
	"_unusedTotalDistance"
];

private _positions = [
	_roadPositions select 0
];

private _lastAssignedDistance = 0;
private _roadPositionIndex = 1;

if (count _orderedGroups > 1) then {
	for "_slotIndex" from 1 to ((count _orderedGroups) - 1) do {
		private _currentGroup =
			_orderedGroups select _slotIndex;

		private _currentSpacing =
			30 max sizeOf typeOf vehicle leader _currentGroup;

		private _requiredDistance =
			_lastAssignedDistance
				+ _currentSpacing;

		while {
			_roadPositionIndex
				< count _roadPositions
			&& {
				(_cumulativeDistances select _roadPositionIndex)
					<= _requiredDistance
			}
		} do {
			_roadPositionIndex =
				_roadPositionIndex + 1;
		};

		if (
			_roadPositionIndex
				>= count _roadPositions
		) exitWith {
			_positions = [];
		};

		_positions pushBack (
			_roadPositions select _roadPositionIndex
		);

		_lastAssignedDistance =
			_cumulativeDistances select _roadPositionIndex;

		_roadPositionIndex =
			_roadPositionIndex + 1;
	};
};

_positions
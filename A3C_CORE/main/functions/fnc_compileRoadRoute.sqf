// A3C_main_fnc_compileRoadRoute

/*
 * Creates reusable route data from an ordered road-object array.
 */

params [
	"_roadObjects"
];

if (_roadObjects isEqualTo []) exitWith {
	[]
};

private _roadPositions =
	_roadObjects apply {
		position _x
	};

private _cumulativeDistances = [
	0
];

private _totalDistance = 0;

if (count _roadPositions > 1) then {
	for "_i" from 1 to ((count _roadPositions) - 1) do {
		private _segmentDistance =
			(_roadPositions select (_i - 1))
				distance2D
			(_roadPositions select _i);

		_totalDistance =
			_totalDistance + _segmentDistance;

		_cumulativeDistances pushBack
			_totalDistance;
	};
};

[
	_roadObjects,
	_roadPositions,
	_cumulativeDistances,
	_totalDistance
]
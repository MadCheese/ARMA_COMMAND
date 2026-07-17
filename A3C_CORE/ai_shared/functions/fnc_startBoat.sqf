// A3C_ai_shared_fnc_startBoat

params ["_boat"];

// Position and orient the boat only where the boat is local.


if (!local _boat) exitWith {
	[
		[_boat],
		A3C_ai_shared_fnc_startBoat
	] remoteExec [
		"bis_fnc_call",
		_boat
	];
};

private _startPosition = getPosATL _boat;
private _suitablePositions = [];
private _waterFound = false;
private _waterDepth = 0;

for "_searchDistance" from 10 to 100 step 5 do {
	for "_searchDirection" from 0 to 360 step 5 do {
		private _testPosition = _startPosition getPos [
			_searchDistance,
			_searchDirection
		];

		if (surfaceIsWater _testPosition) then {
			_waterDepth = (
				ASLToATL (
					(_testPosition select [0, 2]) + [0]
				)
			) select 2;

			if (_waterDepth >= 2) then {
				_waterFound = true;

				_suitablePositions pushBack [
					_searchDirection,
					_testPosition
				];
			};
		};
	};

	if (_waterFound) exitWith {};
};

private _directionSum = 0;

{
	_directionSum = _directionSum + (_x select 0);
} forEach _suitablePositions;

private _averageDirection = if (
	{
		_x == 0
	} count [
		_directionSum,
		count _suitablePositions
	] > 0
) then {
	_directionSum / count _suitablePositions
} else {
	0
};

_suitablePositions = [
	_suitablePositions,
	[],
	{
		abs (_averageDirection - (_x select 0))
	},
	"ASCEND"
] call BIS_fnc_sortBy;

private _selectedPositionData = _suitablePositions select 0;

_selectedPositionData params [
	"_selectedDirection",
	"_selectedPosition"
];

_selectedPosition set [2, 0];

private _deepWaterPositionFound = false;

for "_distanceFromShore" from 1 to round (_boat distance _selectedPosition) do {
	if (_deepWaterPositionFound) exitWith {};

	private _testPosition = _startPosition getPos [
		_distanceFromShore,
		_selectedDirection
	];

	if (surfaceIsWater _testPosition) then {
		_testPosition set [2, 0];

		_waterDepth = (ASLToATL _testPosition) select 2;

		if (_waterDepth >= 2) then {
			// Obstruction checking may be added here later.
			_selectedPosition = _testPosition;
			_deepWaterPositionFound = true;
		};
	};
};

// Apply direction before position to avoid setDir-after-position anomalies.
// A zero ASL height places the boat on the water surface.
_boat setDir _selectedDirection;
_boat setPosASL _selectedPosition;
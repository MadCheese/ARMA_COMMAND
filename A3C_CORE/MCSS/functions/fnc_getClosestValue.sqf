// MCSS_fnc_getClosestValue

params ["_targetValue", "_candidateValues"];

private _closestValue = _candidateValues select 0;
private _smallestDifference = 1e39;

{
	private _difference = abs (_targetValue - _x);

	if (_difference < _smallestDifference) then {
		_smallestDifference = _difference;
		_closestValue = _x;
	};
} forEach _candidateValues;

_closestValue
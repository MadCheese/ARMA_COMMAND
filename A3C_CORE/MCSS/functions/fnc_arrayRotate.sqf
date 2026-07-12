// MCSS_fnc_arrayRotate
// Rotate array left or right.
// NOTE: Current implementation removes all values equal to the shifted value.

params ["_data", "_mode"];

private _shiftValue = _data select 0;
private _shiftedData = [];

switch (_mode) do {
	case "LEFT": {
		_data = _data - [_shiftValue];
		_data pushBack _shiftValue;
	};
	case "RIGHT": {
		_shiftValue = _data select ((count _data) - 1);

		_data = _data - [_shiftValue];

		_shiftedData pushBack _shiftValue;

		{
			_shiftedData pushBack _x;
		} forEach _data;

		_data = _shiftedData;
	};
};

_data
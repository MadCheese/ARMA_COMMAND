// MCSS_fnc_reverseArray

// Reverse the order of an array.
// NOTE: The current implementation removes all entries equal to the selected entry on each pass.

private _inputArray = _this;
private _reversedArray = [];

while { (count _inputArray) > 0 } do {
	private _lastIndex = (count _inputArray) - 1;
	private _entry = _inputArray select _lastIndex;

	_reversedArray set [count _reversedArray, _entry];

	_inputArray = _inputArray - [_entry];
};

_reversedArray
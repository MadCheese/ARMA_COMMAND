// MCSS_fnc_arrayShuffle
// Return a randomly shuffled copy of an array.

private _inputArray = +_this;

private _sourceArray = +_inputArray;
private _shuffledArray = [];

while { (count _sourceArray) > 0 } do {
	private _randomIndex = floor random (count _sourceArray);

	_shuffledArray pushBack (_sourceArray deleteAt _randomIndex);
};

_shuffledArray
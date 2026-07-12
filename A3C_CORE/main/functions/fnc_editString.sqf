// A3C_main_fnc_editString
// Replaces one or more search strings with a substitution string.
// If _limit is true, each search string is replaced up to _numLimit times.
// If _limit is false, replacements continue until no match remains.

params [
	["_string", "", [""]],
	["_toFind", [], ["", []]],
	["_substitution", "", [""]],
	["_numLimit", 10, [1]],
	["_limit", true, [true]]
];

private _searchStrings = if (_toFind isEqualType []) then {
	_toFind
} else {
	[_toFind]
};

{
	private _searchString = _x;

	if (_searchString isEqualType "" && { !(_searchString isEqualTo "") }) then {
		private _searchLength = count _searchString;
		private _replaceCount = 0;
		private _matchIndex = _string find _searchString;

		while {
			_matchIndex != -1 &&
			{ !_limit || { _replaceCount < _numLimit } }
		} do {
			private _before = _string select [0, _matchIndex];
			private _afterStart = _matchIndex + _searchLength;
			private _after = _string select [_afterStart, (count _string) - _afterStart];

			_string = _before + _substitution + _after;
			_replaceCount = _replaceCount + 1;

			_matchIndex = _string find _searchString;
		};
	};
} forEach _searchStrings;

_string
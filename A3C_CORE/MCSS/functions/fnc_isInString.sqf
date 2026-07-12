// MCSS_fnc_isInString
// Checks if a string is included in another string.

params ["_searchedString", "_sourceString"];

private _searchedChars = _searchedString splitString "";
private _sourceChars = _sourceString splitString "";

private _found = false;

if ((count _searchedChars) > (count _sourceChars)) exitWith {
	_found
};

{
	private _exitSearch = false;

	if (_x == (_searchedChars select 0)) then {
		for "_charOffset" from 1 to ((count _searchedChars) min ((count _sourceChars) - _forEachIndex)) do {
			if !((_searchedChars select _charOffset) == (_sourceChars select (_forEachIndex + _charOffset))) exitWith {
				_found = false;
			};

			if (_charOffset == (count _searchedChars)) then {
				_exitSearch = true;
				_found = true;
			};
		};
	};

	if (_exitSearch) exitWith {};
} forEach _sourceChars;

_found
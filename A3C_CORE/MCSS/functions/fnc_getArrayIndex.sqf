// MCSS_fnc_getArrayIndex
// Get the index of an array entry.

params ["_needle", "_haystack"];

private _index = -1;

{
	if (_x isEqualTo _needle) exitWith {
		_index = _forEachIndex;
	};
} forEach _haystack;

_index
// MCSS_fnc_getMainRotorSelections

params ["_vehicle"];

private _selections = selectionNames _vehicle;
private _filteredSelections = [];
private _excludedFragments = ["static", "blur", "damage", "bend"];

{
	private _selectionName = toLower _x;
	private _hasExcludedFragment = ({ _x in _selectionName } count _excludedFragments) > 0;

	if !("\" in _selectionName) then {
		if ("rotor" in _selectionName) then {
			if ("main" in _selectionName) then {
				if (!_hasExcludedFragment) then {
					_filteredSelections pushBack _selectionName;
				};
			};
		};
	};

	if ("vrtule" in _selectionName) then {
		if ("velka" in _selectionName) then {
			if (!_hasExcludedFragment) then {
				_filteredSelections pushBack _selectionName;
			};
		};
	};
} forEach _selections;

_filteredSelections
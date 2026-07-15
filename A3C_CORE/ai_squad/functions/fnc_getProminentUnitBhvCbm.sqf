// A3C_ai_squad_fnc_getProminentUnitBhvCbm

params ["_units", "_mode"];

private _referenceValues = if (_mode == "BEHAVIOUR") then {
	["CARELESS", "SAFE", "AWARE", "COMBAT", "STEALTH"]
} else {
	["BLUE", "GREEN", "WHITE", "YELLOW", "RED"]
};

private _valueCounts = [];

{
	private _value = _x;

	private _count = if (_mode == "BEHAVIOUR") then {
		{ behaviour _x == _value } count _units
	} else {
		{ combatMode _x == _value } count _units
	};

	_valueCounts pushBack [_value, _count];
} forEach _referenceValues;

_valueCounts = [
	_valueCounts,
	[],
	{ _x select 1 },
	"DESCEND"
] call BIS_fnc_sortBy;

(_valueCounts select 0) select 0
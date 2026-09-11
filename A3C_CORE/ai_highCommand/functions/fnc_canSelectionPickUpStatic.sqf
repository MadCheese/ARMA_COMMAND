// A3C_ai_highCommand_fnc_canSelectionPickUpStatic

params [
	["_units", [], [[]]],
	["_weapon", objNull, [objNull]],
	["_distanceRelevant", true, [true]]
];

if (isNull _weapon) exitWith {
	false
};

/*
	Some callers already perform their own broader distance filtering.

	If distance is relevant here, retain the existing 30 m suitability
	requirement. Otherwise let the caller's existing filtering decide.
*/
private _maxDistance = if (_distanceRelevant) then {
	30
} else {
	1e10
};

private _disassemblyData = [
	_units,
	[],
	["DISASSEMBLE", _weapon],
	[],
	0,
	_maxDistance
] call A3C_ai_shared_fnc_staticWeaponPrepareDisassembly;

_disassemblyData params [
	"_selectedUnits",
	"_requiredUnitCount",
	"_needsMoreUnits"
];

(
	!_needsMoreUnits
	&& {count _selectedUnits == _requiredUnitCount}
)
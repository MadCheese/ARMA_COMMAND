// A3C_main_fnc_getUnitIndex

// Saves/returns the unit's index number within the stored player group unit array.
// Used for keybind/UI button assignment because units group player is not reliable enough here.

params ["_unit"];

private _teamMembers = profileNamespace getVariable ["A3C_GROUPUNITS", []];
private _unitIndex = _teamMembers find _unit;

if (_unitIndex == -1) exitWith {
	3
};

_unitIndex + 1
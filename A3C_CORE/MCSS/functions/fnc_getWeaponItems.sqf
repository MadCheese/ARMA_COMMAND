// MCSS_fnc_getWeaponItems

// Gets a unit's carried or attached weapon items compatible with a specific weapon slot.
//
// _mode 0: check items carried in the unit's inventory
// _mode 1: check items attached to the specified weapon
//
// _weapon defaults to the unit's primary weapon.
//
// Returns item classnames from the selected source that are compatible with _slot.

params [
	["_unit", objNull, [objNull]],
	["_slot", "", [""]],
	["_mode", 0, [0]],
	["_weapon", "", [""]]
];

if (isNull _unit) exitWith {
	[]
};

if !(_mode in [0, 1]) exitWith {
	[]
};

if (_weapon isEqualTo "") then {
	_weapon = primaryWeapon _unit;
};

if (_weapon isEqualTo "") exitWith {
	[]
};

private _itemsToCheck = if (_mode == 0) then {
	items _unit
} else {
	_unit weaponAccessories _weapon
};

private _compatibleItems = compatibleItems [_weapon, _slot];
private _weaponItems = [];

{
	if (_x in _compatibleItems) then {
		_weaponItems pushBackUnique _x;
	};
} forEach _itemsToCheck;

_weaponItems
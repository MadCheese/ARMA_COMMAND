// MCSS_fnc_getWeaponItems
// Gets a unit's carried/attached weapon items compatible with a specific weapon slot.
//
// _mode 0: check inventory items
// _mode 1: check currently attached primary weapon items
//
// Returns item classnames compatible with _slot.

params [
	"_unit",
	"_slot",
	["_mode", 0],
	["_primaryWeapon", ""]
];

if (_primaryWeapon isEqualTo "") then {
	_primaryWeapon = primaryWeapon _unit;
};

if (_primaryWeapon isEqualTo "") exitWith {
	[]
};

private _itemsToCheck = if (_mode == 0) then {
	items _unit
} else {
	primaryWeaponItems _unit
};



private _compatibleItemsConfig = configFile >> "CfgWeapons" >> _primaryWeapon >> "WeaponSlotsInfo" >> _slot >> "compatibleItems";
private _compatibleItemsArray = getArray _compatibleItemsConfig;
private _hasCompatibleItemsClass = isClass _compatibleItemsConfig;

private _weaponItems = [];

{
	if (
		_x in _compatibleItemsArray ||
		{ _hasCompatibleItemsClass && { isClass (_compatibleItemsConfig >> _x) } }
	) then {
		_weaponItems pushBackUnique _x;
	};
} forEach _itemsToCheck;

_weaponItems
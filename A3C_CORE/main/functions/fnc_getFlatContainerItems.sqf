// A3C_main_fnc_getFlatContainerItems

params ["_container"];

private _items = [];

if (_container isKindOf "Man") then {
	_items = +(itemsWithMagazines _container);

	private _backpack = backpack _container;
	if !(_backpack isEqualTo "") then {
		_items pushBack _backpack;
	};

	private _headgear = headgear _container;
	if !(_headgear isEqualTo "") then {
		_items pushBack _headgear;
	};

	private _goggles = goggles _container;
	if !(_goggles isEqualTo "") then {
		_items pushBack _goggles;
	};
} else {
	_items =
		(weaponCargo _container) +
		(magazineCargo _container) +
		(itemCargo _container) +
		(backpackCargo _container);
};

_items
// A3C_main_fnc_getItemContainer

params [
	"_item",
	"_fallbackContainer",
	"_containers",
	["_containerContentMap", []]
];

if (_item == "INVENTORY") exitWith {
	_fallbackContainer
};

if (_containerContentMap isEqualTo []) then {
	_containerContentMap = _containers apply {
		[_x] call A3C_main_fnc_getFlatContainerItems
	};
};

private _containerIndex = _containerContentMap findIf {
	_item in _x
};

if (_containerIndex == -1) exitWith {
	_fallbackContainer
};

_containers select _containerIndex

// A3C_main_fnc_getGroupDrivers

params ["_group"];


private _groupDrivers = (units _group) select {
	private _vehicle = objectParent _x;
	!isNull _vehicle
	&& {_x == driver _vehicle}
};

_groupDrivers
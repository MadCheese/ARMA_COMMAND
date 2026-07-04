// A3C_main_fnc_getGroupDrivenVehicles

params ["_group"];


private _groupDrivers = [_group] call A3C_main_fnc_getGroupDrivers;

private _groupVehicles = _groupDrivers apply {objectParent _x};

_groupVehicles



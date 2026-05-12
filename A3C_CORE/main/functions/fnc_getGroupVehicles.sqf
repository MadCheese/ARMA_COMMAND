params ["_group"];


private _groupDrivers = (units _group) select {
	private _vehicle = objectParent _x;
	!isNull _vehicle
	&& {_x == driver _vehicle}
};

private _groupVehicles = _groupDrivers apply {objectParent _x};

_groupVehicles

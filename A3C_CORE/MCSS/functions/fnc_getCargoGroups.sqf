// MCSS_fnc_getCargoGroups

params ["_group"];

private _driverUnits = (units _group) select {
	private _vehicle = objectParent _x;

	!isNull _vehicle && {
		_x == driver _vehicle
	}
};

private _cargoGroups = [];

{
	private _vehicle = objectParent _x;

	{
		private _crewGroup = group _x;

		if (_crewGroup != _group) then {
			_cargoGroups pushBackUnique _crewGroup;
		};
	} forEach crew _vehicle;
} forEach _driverUnits;

_cargoGroups
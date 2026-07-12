// A3C_main_fnc_getGroupOperatedVehicles
// Returns vehicles/statics actively operated by group units.
// Operator means driver, gunner, or commander.
// Cargo passengers do not count.

params ["_group"];

private _operatedVehicles = [];

{
	private _vehicle = objectParent _x;

	if (
		!isNull _vehicle &&
		{
			_x == driver _vehicle 
			|| { _x == gunner _vehicle } 
			|| { _x == commander _vehicle }
		}
	) then {
		_operatedVehicles pushBackUnique _vehicle;
	};
} forEach units _group;

_operatedVehicles
// A3C_main_fnc_isCargoGroupEjectable

params ["_group", "_referenceUnit"];

private _isEjectable = false;

private _referenceVehicle = vehicle _referenceUnit;

{
	private _unit = _x;
	private _unitVehicle = vehicle _unit;

	// Do not evaluate units mounted in a different vehicle.
	if (
		_unitVehicle == _referenceVehicle
		&& {
			[
				_unit,
				_unitVehicle
			] call A3C_main_fnc_isCargoUnitEjectable
		}
	) then {
		_isEjectable = true;
	};
} forEach units _group;

// Override for non-player or pilot groups:
// an armed, non-copilot turret occupant prevents group ejection.
{
	private _unit = _x;
	private _unitVehicle = vehicle _unit;

	if (_unitVehicle == _referenceVehicle) then {
		private _assignedRole = assignedVehicleRole _unit;

		if ((_assignedRole select 0) isEqualTo "turret") then {
			private _turretPath = _assignedRole select 1;

			if (
				!(_unit call MCSS_fnc_isUnitCopilot)
				&& {
					count (
						_unitVehicle weaponsTurret _turretPath
					) > 0
				}
			) then {
				_isEjectable = false;
			};
		};
	};
} forEach units _group;

_isEjectable
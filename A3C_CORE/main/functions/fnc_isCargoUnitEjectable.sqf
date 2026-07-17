// A3C_main_fnc_isCargoUnitEjectable

// Shared by player-squad and high-command boarding logic.
params ["_unit", "_vehicle"];

private _assignedRole = assignedVehicleRole _unit;

if (_assignedRole isEqualTo []) exitWith {
	false
};

switch (_assignedRole select 0) do {
	case "cargo": {
		true
	};

	case "turret": {
		private _turretPath = _assignedRole select 1;

		count (_vehicle weaponsTurret _turretPath) == 0
		|| {
			_unit call MCSS_fnc_isUnitCopilot
			&& {_vehicle isKindOf "HELICOPTER"}
		}
	};

	default {
		false
	};
};
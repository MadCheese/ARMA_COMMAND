// A3C_ai_highCommand_fnc_restoreUnitRole

// -- Make sure that disbanded AI units stay in their vehicle after being disbanded.

params ["_unit"];

private _vehicle = vehicle _unit;

if (!isTouchingGround _vehicle) exitWith {};
if (isPlayer _unit) exitWith {};
if (isNull objectParent _unit) exitWith {};

private _assignedRole = assignedVehicleRole _unit;
if (_assignedRole isEqualTo []) exitWith {};

_assignedRole params ["_role", ["_turretPath", []]];

switch (toLower _role) do {
	case "driver": {
		_unit assignAsDriver _vehicle;
		_unit moveInDriver _vehicle;

		[_unit, _vehicle] spawn {
			params ["_unit", "_vehicle"];

			private _endTime = time + 5;

			while {time <= _endTime} do {
				_unit moveInDriver _vehicle;
				sleep 0.1;
			};
		};
	};

	case "gunner": {
		_unit assignAsGunner _vehicle;
		_unit moveInGunner _vehicle;
	};

	case "cargo": {
		private _cargoIndex = _vehicle getCargoIndex _unit;

		_unit assignAsCargoIndex [_vehicle, _cargoIndex];
		_unit moveInCargo [_vehicle, _cargoIndex];
	};

	case "turret": {
		_unit assignAsTurret [_vehicle, _turretPath];
		_unit moveInTurret [_vehicle, _turretPath];
	};
};

[_unit] allowGetIn true;
[_unit] orderGetIn true;

sleep 5;

_vehicle setVehicleLock "UNLOCKED";
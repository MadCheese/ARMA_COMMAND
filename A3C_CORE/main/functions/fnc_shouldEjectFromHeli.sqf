// A3C_main_fnc_shouldEjectFromHeli

//-- determine if a unit should be discharged from heli
params ["_unit"];

private _shouldEject = false;
private _unitVehicle = vehicle _unit;
private _assignedVehicleRole = assignedVehicleRole _unit;

private _isPilotUnit = (getText (configFile >> "CfgVehicles" >> typeOf _unit >> "nameSound")) == "veh_infantry_pilot_s";

if !(_isPilotUnit) then {
	if (count _assignedVehicleRole == 0) then {
		_shouldEject = true;
	} else {
		private _roleType = _assignedVehicleRole select 0;

		if (_roleType == "Cargo") then {
			_shouldEject = true;
		};

		if (_roleType == "Turret") then {
			private _turretPath = _assignedVehicleRole select 1;

			if (count (_unitVehicle weaponsTurret _turretPath) == 0) then {
				_shouldEject = true;
			};
		};
	};
};

//-- HC killer override - experimental. Forces AI groups out regardless of roles
private _unitGroup = group _unit;

if (!isPlayer (leader _unitGroup)) then {
	if !((group (driver _unitVehicle)) == _unitGroup) then {
		if ({
			private _groupUnitRole = assignedVehicleRole _x;
			count _groupUnitRole > 0 && {(_groupUnitRole select 0) == "Cargo"}
		} count units _unitGroup > 0) then {
			_shouldEject = true;
		};
	};
};

_shouldEject
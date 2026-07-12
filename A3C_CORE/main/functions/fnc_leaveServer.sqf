// A3C_main_fnc_leaveServer

{
	{
		_x spawn {
			params ["_unit"];

			private _vehicle = vehicle _unit;

			_vehicle setDamage 1;

			sleep 10;

			deleteVehicle _unit;

			if (!isNull _vehicle) then {
				deleteVehicle _vehicle;
			};
		};
	} forEach units _x;
} forEach A3C_HC_DISBANDED;
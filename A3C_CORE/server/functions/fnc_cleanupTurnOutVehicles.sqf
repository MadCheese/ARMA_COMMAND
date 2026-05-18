// A3C_server_fnc_cleanupTurnOutVehicles

if (!isServer) exitWith {};
if (isNil "A3C_TurnOutEH_Vehicles") exitWith {};

[] call A3C_server_fnc_pruneTurnOutVehicleRegistry;

private _handledVehicles_Turnout = +A3C_TurnOutEH_Vehicles;

{
	private _vehicle = _x;

	if (isNull _vehicle) then {
		// already pruned above
	} else {
		private _ehId = _vehicle getVariable ["A3C_TurnOutEH", -1];

		if (_ehId < 0) then {
			[_vehicle] call A3C_server_fnc_unregisterTurnOutVehicle;
		} else {
			private _driver = driver _vehicle;

			if (isNull _driver) then {
				[_vehicle] remoteExecCall ["A3C_server_fnc_removeEventhandlerTurnout", _vehicle];
			} else {
				private _group = group _driver;

				if (isNull _group) then {
					[_vehicle] remoteExecCall ["A3C_server_fnc_removeEventhandlerTurnout", _vehicle];
				} else {
					private _managedVehicles = _group getVariable ["A3C_ManagedTurnoutVehicles", []];
					_managedVehicles = _managedVehicles select {!isNull _x};

					if !(_vehicle in _managedVehicles) then {
						[_vehicle] remoteExecCall ["A3C_server_fnc_removeEventhandlerTurnout", _vehicle];
					};
				};
			};
		};
	};
} forEach _handledVehicles_Turnout;

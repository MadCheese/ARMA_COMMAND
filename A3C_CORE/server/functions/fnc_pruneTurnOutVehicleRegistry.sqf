// A3C_server_fnc_pruneTurnOutVehicleRegistry
if (!isServer) exitWith {};
if (isNil "A3C_TurnOutEH_Vehicles") exitWith {};

A3C_TurnOutEH_Vehicles = A3C_TurnOutEH_Vehicles select {!isNull _x};

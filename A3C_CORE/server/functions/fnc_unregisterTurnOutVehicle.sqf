// A3C_server_fnc_unregisterTurnOutVehicle

params ["_vehicle"];

if (!isServer) exitWith {};
if (isNil "A3C_TurnOutEH_Vehicles") exitWith {};
if (isNull _vehicle) exitWith {};

A3C_TurnOutEH_Vehicles = A3C_TurnOutEH_Vehicles select {
	!isNull _x && {_x != _vehicle}
};

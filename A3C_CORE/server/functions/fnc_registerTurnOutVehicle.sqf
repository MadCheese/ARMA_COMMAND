// A3C_server_fnc_registerTurnOutVehicle

params ["_vehicle"];

if (!isServer) exitWith {};
if (isNull _vehicle) exitWith {};

if (isNil "A3C_TurnOutEH_Vehicles") then {
	A3C_TurnOutEH_Vehicles = [];
};

if !(_vehicle in A3C_TurnOutEH_Vehicles) then {
	A3C_TurnOutEH_Vehicles pushBack _vehicle;
};

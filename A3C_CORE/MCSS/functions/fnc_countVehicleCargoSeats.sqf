// MCSS_fnc_countVehicleCargoSeats

params ["_vehicle"];

private _vehicleType = typeOf _vehicle;

private _allCrewCount = [_vehicleType, true] call BIS_fnc_crewCount;
private _allTurretCount = [_vehicleType, false] call BIS_fnc_crewCount;

_allCrewCount - _allTurretCount
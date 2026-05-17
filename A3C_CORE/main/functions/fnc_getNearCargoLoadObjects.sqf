// A3C_main_fnc_getNearCargoLoadObjects

params ["_vehicle"];

private _cargoLoadObjects = [];
private _cfgVehicles = configFile >> "CfgVehicles";

private _nearCargoCandidates = nearestObjects [
	position _vehicle,
	["CAR","TANK","SHIP","ReammoBox","HELICOPTER","PLANE"],
	100
];

{
	private _nearObject = _x;

	if (isClass (_cfgVehicles >> typeOf _nearObject)) then {
		if ((_vehicle canVehicleCargo _nearObject) select 0) then {
			_cargoLoadObjects pushBack _nearObject;
		};
	};
} forEach _nearCargoCandidates;

_cargoLoadObjects
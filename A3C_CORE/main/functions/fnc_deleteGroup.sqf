// A3C_main_fnc_deleteGroup

params ["_group"];

if (isNull _group) exitWith {};

private _groupUnits = units _group;
private _groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;

{
	deleteVehicle _x;
} forEach (_groupUnits + _groupVehicles);

deleteGroup _group;
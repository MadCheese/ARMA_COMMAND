// A3C_main_fnc_isArmedVehicle

params ["_vehicle"];

if (isNull _vehicle) exitWith {
	false
};

(allTurrets [_vehicle, true]) findIf {
	(count (_vehicle weaponsTurret _x)) > 0
} >= 0
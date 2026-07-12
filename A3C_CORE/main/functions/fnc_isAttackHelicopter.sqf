// A3C_main_fnc_isAttackHelicopter

params ["_vehicle"];

if (isNull _vehicle) exitWith {
	false
};

if !(_vehicle isKindOf "Helicopter") exitWith {
	false
};

(allTurrets [_vehicle, false]) findIf {
	(count (_vehicle weaponsTurret _x)) > 1
} >= 0
// A3C_main_fnc_canRepair

params ["_entity"];

if (isNull _entity) exitWith {
	false
};

private _parentVehicle = objectParent _entity;

// Infantry repair capability: unit is on foot and has a toolkit.
if (isNull _parentVehicle && { _entity isKindOf "Man" }) exitWith {
	(items _entity findIf {
		([_x] call A3C_main_fnc_getBaseWeapon) == "ToolKit"
	}) >= 0
};

private _vehicle = if (isNull _parentVehicle) then {
	_entity
} else {
	_parentVehicle
};

// Vehicle repair capability:
// - driver of repair vehicle
// - or the checked entity itself is not a man, e.g. repair vehicle object passed directly
if (
	_entity == driver _vehicle ||
	{ !(_entity isKindOf "Man") }
) exitWith {
	getNumber (
		configFile >> "CfgVehicles" >> typeOf _vehicle >> "transportRepair"
	) > 1000
};

false
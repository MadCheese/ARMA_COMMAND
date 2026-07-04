// A3C_main_fnc_canHoverAircraft

//-- #TODO: this might be better done with _cfgVehicles >> _aircraftType >> "landingSpeed" < 10 ?!

params ["_veh"];

private _class = if (_veh isEqualType objNull) then {
	typeOf _veh
} else {
	_veh
};

private _cfg = configFile >> "CfgVehicles" >> _class;

if !(isClass _cfg) exitWith { false };


// For VTOL planes / Harrier-like aircraft this avoids any isKindOf calls. Other planes (like Harrier) not relevant enough yet
if (getNumber (_cfg >> "vtol") > 0) exitWith { true };

// Only now check class inheritance.
// This catches helicopters, which generally do not use the plane vtol config value.
_class isKindOf ["Helicopter", configFile >> "CfgVehicles"]
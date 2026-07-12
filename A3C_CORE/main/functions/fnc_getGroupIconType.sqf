// A3C_main_fnc_getGroupIconType

params ["_group"];

private _defaultRoot = "\a3\ui_f\data\GUI\Cfg\Hints\icon_text\";
private _customRoot = "\a3c_ui\markers\";

private _leader = leader _group;
private _groupUnits = units _group;

if (
	isPlayer _leader &&
	{
		((assignedItems _leader) findIf {
			"A3C_Terminal" in _x
		}) >= 0
	}
) exitWith {
	_defaultRoot + "b_hq_ca.paa"
};

private _drivenVehicles = [];
private _operatedVehicles = [];

{
	private _unit = _x;
	private _vehicle = objectParent _unit;

	if (!isNull _vehicle) then {
		private _isDriver = _unit == driver _vehicle;

		if (
			_isDriver ||
			{ _unit == gunner _vehicle } ||
			{ _unit == commander _vehicle }
		) then {
			_operatedVehicles pushBackUnique _vehicle;
		};

		if (_isDriver) then {
			_drivenVehicles pushBackUnique _vehicle;
		};
	};
} forEach _groupUnits;

// Artillery has highest vehicle/platform priority.
// Uses operated vehicles so static mortars/artillery are included.
if !((getArtilleryAmmo _operatedVehicles) isEqualTo []) exitWith {
	_defaultRoot + "b_artillery_ca.paa"
};

// UAV has priority over plane/helicopter/tank/static/car.
if ((_operatedVehicles findIf { unitIsUAV _x }) >= 0) exitWith {
	_defaultRoot + "b_UAV_ca.paa"
};

// From here down, driven vehicles define mobility/combat type.
if ((_drivenVehicles findIf { _x isKindOf "Plane" }) >= 0) exitWith {
	_defaultRoot + "b_plane_ca.paa"
};

if ((_drivenVehicles findIf { _x isKindOf "Helicopter" }) >= 0) exitWith {
	_defaultRoot + "b_air_ca.paa"
};

if ((_drivenVehicles findIf { _x isKindOf "Tank" }) >= 0) exitWith {
	_defaultRoot + "b_armor_ca.paa"
};

// Static weapons are operated, not driven.
if ((_operatedVehicles findIf { _x isKindOf "StaticWeapon" }) >= 0) exitWith {
	_customRoot + "icon_map_b_static_ca.paa"
};

if ((_drivenVehicles findIf { _x isKindOf "Car" }) >= 0) exitWith {
	private _root = _defaultRoot;
	private _serviceRank = 0;
	private _hasArmedVehicle = false;

	// Service priority:
	// 4: repair
	// 3: ammo
	// 2: fuel
	// 1: medical
	{
		private _vehicleConfig = configFile >> "CfgVehicles" >> typeOf _x;

		if (getNumber (_vehicleConfig >> "transportRepair") > 1000) exitWith {
			_serviceRank = 4;
		};

		if (_serviceRank < 3 && { getNumber (_vehicleConfig >> "transportAmmo") > 1000 }) then {
			_serviceRank = 3;
		};

		if (_serviceRank < 2 && { getNumber (_vehicleConfig >> "transportFuel") > 1000 }) then {
			_serviceRank = 2;
		};

		if (_serviceRank < 1 && { getNumber (_vehicleConfig >> "attendant") == 1 }) then {
			_serviceRank = 1;
		};

		if (_serviceRank == 0 && { !_hasArmedVehicle }) then {
			if ((weapons _x findIf { !("horn" in toLower _x) }) >= 0) then {
				_hasArmedVehicle = true;
			};
		};
	} forEach _drivenVehicles;

	private _iconType = switch (_serviceRank) do {
		case 4: {
			_root = _customRoot;
			"icon_map_b_rePair_ca.paa"
		};

		case 3: {
			_root = _customRoot;
			"icon_map_b_reArm_ca.paa"
		};

		case 2: {
			_root = _customRoot;
			"icon_map_b_reFuel_ca.paa"
		};

		case 1: {
			_root = _customRoot;
			"icon_map_b_medical_ca"
		};

		default {
			if (_hasArmedVehicle) then {
				"b_motor_inf_ca.paa"
			} else {
				_root = _customRoot;
				"icon_map_b_transport_ca.paa"
			}
		};
	};

	_root + _iconType
};

_defaultRoot + "b_inf_ca.paa"
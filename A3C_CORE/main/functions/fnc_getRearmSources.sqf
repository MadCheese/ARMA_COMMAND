// A3C_main_fnc_getRearmSources

// Find possible sources to rearm from.

params [
	"_unit",
	"_primaryMode",
	"_secondaryMode",
	"_backpackMode",
	"_magazines"
];

if (isPlayer _unit) exitWith {[]};

// Find vehicle containers.
private _vehicleSources = nearestObjects [
	_unit,
	["Car", "Helicopter", "Ship", "Tank", "ReammoBox_F"],
	100
];

private _sources = _vehicleSources select {
	private _content =
		(weaponCargo _x) +
		(magazineCargo _x) +
		(itemCargo _x) +
		(backpackCargo _x);

	!(_content isEqualTo [])
};

// Find corpses and loose weapon holders.
// Single-unit rearm only.
if ((count A3C_RD_UNITS) == 1) then {
	private _looseWeaponHolders = (nearestObjects [_unit, A3C_WeaponHolderClasses, 100]) select {
		// Exclude corpse weapon holders; corpse handling below is responsible for those.
		isNull (getCorpse _x)
	};

	private _corpses = (nearestObjects [_unit, ["Man"], 100]) select {
		!alive _x &&
		{
			isNull objectParent _x &&
			{
				private _backpackItems = if (backpack _x == "") then {
					[]
				} else {
					[backpack _x]
				};

				!((weapons _x) + (magazines _x) + _backpackItems isEqualTo [])
			}
		}
	};

	_sources = _sources + _looseWeaponHolders + _corpses;
};

switch (_primaryMode) do {
	case "PRI_RESUPPLY": {
	};

	case "PRI_REARM": {
		// Primary weapon rearm requires primary weapons to be present.
		if (_secondaryMode == "SEC_NONE") then {
			_sources = _sources select {
				private _source = _x;

				private _sourceWeapons = if (_source isKindOf "Man") then {
					private _weapons = +(weapons _source);

					{
						_weapons append (weaponCargo _x);
					} forEach (getCorpseWeaponHolders _source);

					_weapons
				} else {
					weaponCargo _source
				};

				_sourceWeapons findIf {
					getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 1
				} != -1
			};
		};
	};
};

// Preserved original behavior: this switch used the primary-mode variable.
switch (_primaryMode) do {
	case "SEC_RESUPPLY": {
	};

	case "SEC_REARM": {
		if (_primaryMode == "PRI_NONE") then {
			_sources = _sources select {
				private _source = _x;

				private _sourceWeapons = if (_source isKindOf "Man") then {
					weapons _source
				} else {
					weaponCargo _source
				};

				_sourceWeapons findIf {
					getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 4
				} > -1
			};
		};
	};
};

_sources
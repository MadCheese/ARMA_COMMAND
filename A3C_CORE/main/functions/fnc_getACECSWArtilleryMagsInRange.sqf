// A3C_main_fnc_getACECSWArtilleryMagsInRange

params [
	["_vehicle", objNull, [objNull]],
	["_turretPath", [], [[]]],
	["_vehicleMags", [], [[]]],
	["_targetPos", [], [[]]]
];

if (
	isNull _vehicle
	|| {_vehicleMags isEqualTo []}
) exitWith {
	[]
};

if (_targetPos isEqualTo []) exitWith {
	+_vehicleMags
};

private _loadedArtilleryMags = getArtilleryAmmo [_vehicle];

private _loadedFamilyMags = _vehicleMags select {
	_x in _loadedArtilleryMags
};

/*
	If this family is physically loaded, Arma can provide the authoritative
	range result. Do not replace a real negative result with the config fallback.
*/
if (_loadedFamilyMags isNotEqualTo []) exitWith {
	_loadedFamilyMags select {
		_targetPos inRangeOfArtillery [
			[_vehicle],
			_x
		]
	}
};


/*
	Arma cannot evaluate inRangeOfArtillery/getArtilleryETA for a magazine
	that is not physically loaded.

	For an externally reloadable ACE CSW family, use the configured artillery
	fire-mode range envelopes as a preflight test. The executor must perform
	the real engine range check after physically loading the requested family.
*/
private _distance = _vehicle distance2D _targetPos;
private _nominallyInRange = false;

{
	private _weapon = _x;
	private _compatibleMags = compatibleMagazines _weapon;

	if (
		_vehicleMags findIf {
			_x in _compatibleMags
		} >= 0
	) then {
		private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;

		{
			private _modeCfg = _weaponCfg >> _x;

			private _minRange = getNumber (
				_modeCfg >> "minRange"
			);

			private _maxRange = getNumber (
				_modeCfg >> "maxRange"
			);

			if (
				_maxRange > 0
				&& {_distance >= _minRange}
				&& {_distance <= _maxRange}
			) exitWith {
				_nominallyInRange = true;
			};

		} forEach getArray (
			_weaponCfg >> "modes"
		);
	};

	if (_nominallyInRange) exitWith {};

} forEach (
	_vehicle weaponsTurret _turretPath
);

if (_nominallyInRange) then {
	+_vehicleMags
} else {
	[]
}
// A3C_main_fnc_getReArmModes
// Determines what the unit needs to rearm.

params ["_unit"];

if (vehicle _unit != _unit) exitWith {[]};
if (isPlayer _unit) exitWith {[]};

private _primaryMode = "PRI_NONE";
private _secondaryMode = "SEC_NONE";
private _backpackMode = false;

private _primaryWeapon = primaryWeapon _unit;
private _secondaryWeapon = secondaryWeapon _unit;

private _primaryMagazines = getArray (
	configFile >> "CfgWeapons" >> _primaryWeapon >> "magazines"
);

private _secondaryMagazines = getArray (
	configFile >> "CfgWeapons" >> _secondaryWeapon >> "magazines"
);

private _unitMagazines = magazines _unit;

private _primaryMagazineCount = {
	_x in _primaryMagazines
} count _unitMagazines;

private _secondaryMagazineCount = {
	_x in _secondaryMagazines
} count _unitMagazines;

if (_primaryWeapon isEqualTo "") then {
	_primaryMode = "PRI_REARM";
} else {
	if (_primaryMagazineCount > 0) then {
		if (_primaryMagazineCount < 5) then {
			_primaryMode = "PRI_RESUPPLY";
		} else {
			if !(_secondaryWeapon isEqualTo "") then {
				if (_secondaryMagazineCount == 0) then {
					_primaryMode = "PRI_RESUPPLY";
				};
			};
		};
	} else {
		_primaryMode = "PRI_REARM";
	};
};

if !(_secondaryWeapon isEqualTo "") then {
	if (({ _x in _secondaryMagazines } count _unitMagazines) == 0) then {
		{
			private _weaponClass = _x select 0;

			if (getNumber (configFile >> "CfgWeapons" >> _weaponClass >> "Type") == 4) then {
				if ((count (_x select 4)) == 0) then {
					_secondaryMode = "SEC_RESUPPLY";
				};
			};
		} forEach (weaponsItems _unit);

		// Detect unusable launcher.
		if ("used" in ([_secondaryWeapon, "_"] call BIS_fnc_splitString)) then {
			_secondaryMode = "SEC_REARM";
		};
	};
} else {
	if (player == leader group _unit) then {
		private _defaultWeapons = getArray (
			configFile >> "CfgVehicles" >> typeOf _unit >> "weapons"
		);

		if (({
			getNumber (configFile >> "CfgWeapons" >> _x >> "Type") == 1
		} count _defaultWeapons) > 0) then {
			_secondaryMode = "SEC_REARM";
		};
	};
};

if (_primaryMode == "PRI_REARM") then {
	if !(_primaryWeapon isEqualTo "") then {
		_primaryMode = "PRI_RESUPPLY";
	};
};

if (backpack _unit isEqualTo "") then {
	_backpackMode = true;
};

[_primaryMode, _secondaryMode, _backpackMode]
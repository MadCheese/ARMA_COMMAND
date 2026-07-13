// A3C_main_fnc_getRearmSourceQuality
// Determines the quality of a rearm source depending on what the unit needs.

params [
	"_unit",
	"_source",
	["_primaryMode", ""],
	["_secondaryMode", ""],
	["_backpackMode", false]
];

private _quality = 0;

private _sourceMagazines = if (_source isKindOf "Man") then {
	magazines _source
} else {
	magazineCargo _source
};

private _sourceWeapons = if (_source isKindOf "Man") then {
	[primaryWeapon _source]
} else {
	weaponCargo _source
};

private _sourceItems = if (_source isKindOf "Man") then {
	[items _source]
} else {
	itemCargo _source
};

private _sourceBackpacks = if (_source isKindOf "Man") then {
	[backpack _source]
} else {
	backpackCargo _source
};

if (_unit isEqualType "") exitWith {
	{
		_quality = _quality + 10;
	} forEach _sourceMagazines;

	{
		_quality = _quality + 5;
	} forEach _sourceWeapons;

	{
		_quality = _quality + 1;
	} forEach _sourceItems;

	{
		_quality = _quality + 1;
	} forEach _sourceBackpacks;

	_quality
};

if (isPlayer _unit) exitWith {
	0
};

if (_backpackMode) then {
	if ((count _sourceBackpacks) > 0) then {
		_quality = _quality + 1;
	};
};

private _hasPrimaryRearm = false;
private _hasSecondaryResupply = false;

if (_primaryMode == "PRI_REARM") then {
	{
		private _sourceWeapon = _x;

		if (getNumber (configFile >> "CfgWeapons" >> _sourceWeapon >> "Type") == 1) then {
			private _compatibleMagazines = getArray (
				configFile >> "CfgWeapons" >> _sourceWeapon >> "magazines"
			);

			if (({ _x in _compatibleMagazines } count _sourceMagazines) > 2) then {
				_hasPrimaryRearm = true;
			};
		};
	} forEach _sourceWeapons;

	if (_hasPrimaryRearm) then {
		_quality = _quality + 10;
	};
};

if (_primaryMode == "PRI_RESUPPLY") then {
	private _primaryWeaponMagazines = getArray (
		configFile >> "CfgWeapons" >> primaryWeapon _unit >> "magazines"
	);

	if (({ _x in _primaryWeaponMagazines } count _sourceMagazines) > 2) then {
		_quality = _quality + 10;
	};
};

if (_secondaryMode == "SEC_REARM") then {
	if (({ getNumber (configFile >> "CfgWeapons" >> _x >> "Type") == 4 } count _sourceWeapons) > 0) then {
		_quality = _quality + 10;
	};

	private _primaryWeaponMagazines = getArray (
		configFile >> "CfgWeapons" >> primaryWeapon _unit >> "magazines"
	);

	if (({ _x in _primaryWeaponMagazines } count _sourceMagazines) > 2) then {
		_quality = _quality + 10;
	};
};

if (_secondaryMode == "SEC_RESUPPLY") then {
	{
		private _sourceWeapon = _x;

		if (getNumber (configFile >> "CfgWeapons" >> _sourceWeapon >> "Type") == 4) then {
			private _compatibleMagazines = getArray (
				configFile >> "CfgWeapons" >> _sourceWeapon >> "magazines"
			);

			if (({ _x in _compatibleMagazines } count _sourceMagazines) > 0) then {
				_hasSecondaryResupply = true;
			};
		};
	} forEach _sourceWeapons;

	if (_hasSecondaryResupply) then {
		_quality = _quality + 10;
	};
};

_quality
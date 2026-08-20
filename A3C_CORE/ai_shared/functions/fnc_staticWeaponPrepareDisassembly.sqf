// A3C_ai_shared_fnc_staticWeaponPrepareDisassembly

params [
	["_candidateUnits", [], [[]]],
	["_selectedUnits", [], [[]]],
	["_staticData", [], [[]]],
	["_weaponPos", [], [[]]],
	["_weaponDir", 0, [0]],
	["_maxDistance", 30, [0]]
];

private _staticWeapon = _staticData select 1;

private _disassemblyBackpacks = getArray (
	configFile >> "CfgVehicles" >> typeOf _staticWeapon >> "assembleInfo" >> "dissasembleTo"
);

private _ifaDisassemblyItems = getArray (
	configFile >> "CfgVehicles" >> typeOf _staticWeapon >> "assembleInfo" >> "LIB_dissasembleTo"
);

private _staticMagazineCount = if (count _ifaDisassemblyItems > 0) then {
	count magazines _staticWeapon
} else {
	0
};

private _requiredUnitCount = 2;

/*
	Unit selection is delegated.

	Selector return contract:
		[_unitA, _unitB] or []

	The selector handles:
		- max distance
		- current weapon crew ownership
		- IFA vs backpack disassembly method
		- suitability scoring
*/
_selectedUnits = [
	_candidateUnits,
	_staticWeapon,
	_maxDistance
] call A3C_ai_shared_fnc_selectStaticWeaponDisassemblyUnits;

private _needsMoreUnits = count _selectedUnits < _requiredUnitCount;

/*
	Keep old return shape for compatibility:

	[
		_busyUnits,
		_unitsRequired,
		_isUnitsRequired,
		_IFA_items,
		_staticMagazinesCount
	]
*/
[
	_selectedUnits,
	_requiredUnitCount,
	_needsMoreUnits,
	_ifaDisassemblyItems,
	_staticMagazineCount
]

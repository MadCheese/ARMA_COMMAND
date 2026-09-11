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
private _staticWeaponType = typeOf _staticWeapon;
private _staticWeaponCfg = configOf _staticWeapon;


//-- IFA disassembly data
private _ifaDisassemblyItems = getArray (
	_staticWeaponCfg >> "assembleInfo" >> "LIB_dissasembleTo"
);

private _staticMagazineCount = if (count _ifaDisassemblyItems > 0) then {
	count magazines _staticWeapon
} else {
	0
};


//-- ACE CSW disassembly data
private _aceCSWcfg = _staticWeaponCfg >> "ACE_CSW";

private _aceWeaponClass = "";
private _aceMountVehicleClass = "";
private _aceMountClass = "";
private _aceWeaponSlot = "";

if (
	isClass _aceCSWcfg
	&& {getNumber (_aceCSWcfg >> "enabled") == 1}
) then {
	_aceWeaponClass = getText (
		_aceCSWcfg >> "disassembleWeapon"
	);

	_aceMountVehicleClass = getText (
		_aceCSWcfg >> "disassembleTurret"
	);

	if (_aceMountVehicleClass != "") then {
		_aceMountClass = getText (
			configFile
				>> "CfgVehicles"
				>> _aceMountVehicleClass
				>> "ACE_CSW"
				>> "disassembleTo"
		);
	};

	if (_aceWeaponClass != "") then {
		private _aceWeaponType = getNumber (
			configFile
				>> "CfgWeapons"
				>> _aceWeaponClass
				>> "type"
		);

		_aceWeaponSlot = if (_aceWeaponType == 1) then {
			"PRIMARY"
		} else {
			"SECONDARY"
		};
	};
};


/*
	Provider priority:

	ACE_CSW:
		Use the published ACE CSW relationship when the static provides
		a complete weapon + mount disassembly definition.

	IFA:
		Keep the legacy LIB path for statics without complete ACE data.

	VANILLA:
		Keep existing backpack behavior as the default.
*/
private _disassemblyProvider = switch (true) do {
	case (
		_aceWeaponClass != ""
		&& {_aceMountClass != ""}
		&& {_aceWeaponSlot != ""}
	) : {
		"ACE_CSW"
	};

	case (count _ifaDisassemblyItems > 0) : {
		"IFA"
	};

	default {
		"VANILLA"
	};
};


private _disassemblyProviderData = if (
	_disassemblyProvider == "ACE_CSW"
) then {
	[
		_aceWeaponClass,
		_aceMountClass,
		_aceWeaponSlot
	]
} else {
	[]
};





/*
	Unit selection is delegated.

	The selector handles:
	- max distance
	- current weapon crew ownership
	- provider-specific component roles
	- suitability scoring
	- ACE one-worker vs two-worker arrangement
*/
_selectedUnits = [
	_candidateUnits,
	_staticWeapon,
	_maxDistance,
	_disassemblyProvider,
	_disassemblyProviderData
] call A3C_ai_shared_fnc_selectStaticWeaponDisassemblyUnits;


/*
	Legacy vanilla/SOG/IFA statics continue to require two workers.

	ACE SECONDARY-slot weapons also require two workers.

	For ACE PRIMARY-slot weapons, the selector decides whether the optimal
	arrangement uses one worker for both components or separate weapon and
	mount carriers.
*/
private _requiredUnitCount = if (
	_disassemblyProvider == "ACE_CSW"
	&& {_aceWeaponSlot == "PRIMARY"}
) then {
	(count _selectedUnits) max 1
} else {
	2
};

private _needsMoreUnits = count _selectedUnits < _requiredUnitCount;


/*
	Keep the existing first five return fields unchanged.

	Additional fields:
	5: disassembly provider
	6: provider-specific disassembly data
*/
[
	_selectedUnits,
	_requiredUnitCount,
	_needsMoreUnits,
	_ifaDisassemblyItems,
	_staticMagazineCount,
	_disassemblyProvider,
	_disassemblyProviderData
]
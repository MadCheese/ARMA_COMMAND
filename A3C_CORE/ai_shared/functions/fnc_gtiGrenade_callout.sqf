// A3C_ai_shared_fnc_gtiGrenade_callout

params [
	"_unit",
	["_muzzle", A3C_GREN_MUZZLE]
];

A3C_GRENPHR = "A3C_FireInTheHole";

private _chat = "Fire In The Hole";

if !(_muzzle isEqualTo "") then {
	private _ammoType = getText (
		configFile >> "CfgMagazines" >> _muzzle >> "ammo"
	);

	private _explosive = getNumber (
		configFile >> "CfgAmmo" >> _ammoType >> "explosive"
	);

	if (_explosive > 0) then {
		A3C_GRENPHR = "A3C_ThrowingFrag";
		_chat = "Throwing Frag";
	} else {
		private _aiAmmoUsageFlags = getNumber (
			configFile >> "CfgAmmo" >> _ammoType >> "aiAmmoUsageFlags"
		);

		if (_aiAmmoUsageFlags == 6) then {
			A3C_GRENPHR = "A3C_ThrowingSmoke";
			_chat = "Throwing Smoke";
		};
	};
};


_unit groupChat _chat;
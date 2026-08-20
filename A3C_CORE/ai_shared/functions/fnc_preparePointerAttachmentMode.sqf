// A3C_ai_shared_fnc_preparePointerAttachmentMode
// Local helper.
// Returns true if the unit's current handheld weapon already has,
// or can be switched to, an attachment supporting the requested mode.

params [
	["_unit", objNull, [objNull]],
	["_type", "", [""]]
];

if (isNull _unit) exitWith {
	false
};

_type = toUpper _type;

if !(_type in ["LASER", "FLASHLIGHT"]) exitWith {
	false
};

private _weapon = currentWeapon _unit;

if (_weapon isEqualTo "") exitWith {
	false
};

private _weaponSlot = switch (true) do {
	case (_weapon isEqualTo primaryWeapon _unit): {
		"PRIMARY"
	};

	case (_weapon isEqualTo handgunWeapon _unit): {
		"HANDGUN"
	};

	case (_weapon isEqualTo secondaryWeapon _unit): {
		"SECONDARY"
	};

	default {
		""
	};
};

// Ignore binoculars, Throw, Put, vehicle weapons and other unsupported weapons.
if (_weaponSlot isEqualTo "") exitWith {
	false
};

private _attachment = (_unit weaponAccessories _weapon) param [1, ""];

if (_attachment isEqualTo "") exitWith {
	false
};

private _cfg = configFile >> "CfgWeapons" >> _attachment;

private _hasWantedMode = switch (_type) do {
	case "LASER": {
		getNumber (_cfg >> "ItemInfo" >> "Pointer" >> "irDistance") != 0
	};

	case "FLASHLIGHT": {
		getNumber (_cfg >> "ItemInfo" >> "FlashLight" >> "intensity") != 0
	};
};

if (_hasWantedMode) exitWith {
	true
};

// Switches the attachment on the captured weapon slot and verifies success.
private _fnc_switchAttachment = {
	params [
		"_unit",
		"_weapon",
		"_weaponSlot",
		"_switchAttachment"
	];

	if (_switchAttachment isEqualTo "") exitWith {
		false
	};

	switch (_weaponSlot) do {
		case "PRIMARY": {
			_unit addPrimaryWeaponItem _switchAttachment;
		};

		case "HANDGUN": {
			_unit addHandgunItem _switchAttachment;
		};

		case "SECONDARY": {
			_unit addSecondaryWeaponItem _switchAttachment;
		};
	};

	((_unit weaponAccessories _weapon) param [1, ""]) isEqualTo _switchAttachment
};

// RHS combo attachments.
private _rhsText = toLower getText (_cfg >> "rhs_acc_combo_text");

if (_type == "LASER" && {"laser" in _rhsText}) exitWith {
	[
		_unit,
		_weapon,
		_weaponSlot,
		getText (_cfg >> "rhs_acc_combo")
	] call _fnc_switchAttachment
};

if (_type == "FLASHLIGHT" && {"light" in _rhsText}) exitWith {
	[
		_unit,
		_weapon,
		_weaponSlot,
		getText (_cfg >> "rhs_acc_combo")
	] call _fnc_switchAttachment
};

// MRT / SMA style switchable attachments.
private _mrtText = toLower getText (_cfg >> "MRT_switchItemHintText");

if (_type == "LASER" && {"light" in _mrtText}) exitWith {
	[
		_unit,
		_weapon,
		_weaponSlot,
		getText (_cfg >> "MRT_SwitchItemNextClass")
	] call _fnc_switchAttachment
};

if (_type == "FLASHLIGHT" && {"laser" in _mrtText}) exitWith {
	[
		_unit,
		_weapon,
		_weaponSlot,
		getText (_cfg >> "MRT_SwitchItemNextClass")
	] call _fnc_switchAttachment
};

false
// A3C_ai_squad_fnc_preparePointerAttachmentMode
// Returns true if the unit already has, or can be switched to, the requested mode.

params [
	["_unit", objNull, [objNull]],
	["_type", "", [""]]
];

if (isNull _unit) exitWith {false};
if !(_type in ["LASER", "FLASHLIGHT"]) exitWith {false};

private _slotItems = [_unit, "PointerSlot", 1] call MCSS_fnc_getWeaponItems;
if (count _slotItems == 0) exitWith {false};

private _attachment = _unit weaponAccessories currentMuzzle _unit param [1, ""];
if (_attachment == "") exitWith {false};

private _cfg = configFile >> "CfgWeapons" >> _attachment;

private _hasWantedMode = switch (_type) do {
	case "LASER": {
		getNumber (_cfg >> "ItemInfo" >> "Pointer" >> "irDistance") != 0
	};

	case "FLASHLIGHT": {
		getNumber (_cfg >> "ItemInfo" >> "FlashLight" >> "intensity") != 0
	};
};

if (_hasWantedMode) exitWith {true};

private _rhsText = toLower getText (_cfg >> "rhs_acc_combo_text");

if (_type == "LASER" && {"laser" in _rhsText}) exitWith {
	private _switchAttachment = getText (_cfg >> "rhs_acc_combo");

	if (_switchAttachment != "") then {
		_unit addPrimaryWeaponItem _switchAttachment;
		true
	} else {
		false
	};
};

if (_type == "FLASHLIGHT" && {"light" in _rhsText}) exitWith {
	private _switchAttachment = getText (_cfg >> "rhs_acc_combo");

	if (_switchAttachment != "") then {
		_unit addPrimaryWeaponItem _switchAttachment;
		true
	} else {
		false
	};
};

private _mrtText = toLower getText (_cfg >> "MRT_switchItemHintText");

if (_type == "LASER" && {"light" in _mrtText}) exitWith {
	private _switchAttachment = getText (_cfg >> "MRT_SwitchItemNextClass");

	if (_switchAttachment != "") then {
		_unit addPrimaryWeaponItem _switchAttachment;
		true
	} else {
		false
	};
};

if (_type == "FLASHLIGHT" && {"laser" in _mrtText}) exitWith {
	private _switchAttachment = getText (_cfg >> "MRT_SwitchItemNextClass");

	if (_switchAttachment != "") then {
		_unit addPrimaryWeaponItem _switchAttachment;
		true
	} else {
		false
	};
};

false
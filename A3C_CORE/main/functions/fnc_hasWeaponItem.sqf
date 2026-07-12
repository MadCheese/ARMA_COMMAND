// A3C_main_fnc_hasWeaponItem

params ["_unit", "_itemType"];

if (isNull _unit) exitWith {
	false
};

private _currentMuzzle = currentMuzzle _unit;
private _weaponAccessories = _unit weaponAccessories _currentMuzzle;

switch (toUpper _itemType) do {
	case "SILENCER": {
		!((_weaponAccessories param [0, ""]) isEqualTo "")
	};

	case "FLASHLIGHT": {
		private _itemName = _weaponAccessories param [1, ""];

		if (_itemName isEqualTo "") exitWith {
			false
		};

		private _itemConfig = configFile >> "CfgWeapons" >> _itemName;

		if (getNumber (_itemConfig >> "ItemInfo" >> "FlashLight" >> "intensity") != 0) exitWith {
			true
		};

		private _rhsText = toLower getText (_itemConfig >> "rhs_acc_combo_text");

		if ("light" in _rhsText) exitWith {
			true
		};

		private _smaText = toLower getText (_itemConfig >> "MRT_switchItemHintText");

		// For combo attachments, the hint text may describe the alternate switch state.
		"laser" in _smaText
	};

	case "LASER": {
		private _itemName = _weaponAccessories param [1, ""];

		if (_itemName isEqualTo "") exitWith {
			false
		};

		private _itemConfig = configFile >> "CfgWeapons" >> _itemName;

		if (getNumber (_itemConfig >> "ItemInfo" >> "Pointer" >> "irDistance") != 0) exitWith {
			true
		};

		private _rhsText = toLower getText (_itemConfig >> "rhs_acc_combo_text");

		if ("laser" in _rhsText) exitWith {
			true
		};

		private _smaText = toLower getText (_itemConfig >> "MRT_switchItemHintText");

		// Preserved from original:
		// For combo attachments, the hint text may describe the alternate switch state.
		"light" in _smaText
	};

	default {
		false
	};
}
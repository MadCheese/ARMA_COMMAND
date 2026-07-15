// A3C_ai_shared_fnc_gtiGrenade_setGrenadeData

#include "..\..\ui\radial\radialMenu\dialog_defines.hpp"
#include "..\..\ui\mapOverlay\dialog_defines.hpp"

params [
	"_mode",
	["_doChange", true]
];

private _units = if (!isNull (findDisplay IDD_RADIAL_MENU)) then {
	A3C_RD_UNITS
} else {
	A3C_SELECTED_UNITS
};

A3C_AI_GREN_ARRAY = [];

{
	private _unit = _x;

	{
		if (_x call BIS_fnc_isThrowable) then {
			A3C_AI_GREN_ARRAY pushBackUnique _x;
		};
	} forEach magazines _unit;
} forEach _units;

// Re-arrange to keep combat grenades first.
// Chem / IR / strobe grenades are moved to the end.
private _secondaryGrenades = [];

{
	private _magazine = _x;

	if (({ [_x, _magazine] call MCSS_fnc_isInString } count ["chem", "_ir", "Strobe"]) > 0) then {
		_secondaryGrenades pushBackUnique _magazine;
		A3C_AI_GREN_ARRAY = A3C_AI_GREN_ARRAY - [_magazine];
	};
} forEach +A3C_AI_GREN_ARRAY;

{
	A3C_AI_GREN_ARRAY pushBackUnique _x;
} forEach _secondaryGrenades;

switch (_mode) do {
	case 0: {
		// Select first throwable.
		if ((count A3C_AI_GREN_ARRAY) > 0) then {
			A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select 0;
		} else {
			A3C_GREN_MUZZLE = "";
		};
	};

	case 1: {
		// Called from WP-action button.
		if ((count A3C_AI_GREN_ARRAY) > 0) then {
			if (A3C_GREN_MUZZLE == (A3C_AI_GREN_ARRAY select ((count A3C_AI_GREN_ARRAY) - 1))) then {
				// If current muzzle is the last in grenade array, select first entry.
				A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select 0;
			} else {
				// If current muzzle is not the last in grenade array, select next entry.
				private _grenadeIndex = A3C_AI_GREN_ARRAY find A3C_GREN_MUZZLE;
				A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select (_grenadeIndex + 1);
			};
		} else {
			A3C_GREN_MUZZLE = "";
		};
	};

	case 2: {
		// Define and assign non-existent variable.
		if (isNil "A3C_GREN_MUZZLE") then {
			A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select 0;
		};
	};

	case 3: {
		if (A3C_GREN_MUZZLE == (A3C_AI_GREN_ARRAY select ((count A3C_AI_GREN_ARRAY) - 1))) then {
			A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select 0;
		} else {
			private _grenadeIndex = A3C_AI_GREN_ARRAY find A3C_GREN_MUZZLE;
			A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select (_grenadeIndex + 1);
		};
	};
};

if (!isNull (findDisplay IDD_RADIAL_MENU)) then {
	[A3C_GREN_MUZZLE, 0, _doChange] call A3C_ui_radialMenu_fnc_squad_labelOuterRingGrenades;
} else {
	(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_WPACTION_IMG) ctrlSetTextColor [1, 1, 1, 1];

	[A3C_GREN_MUZZLE, 1, _doChange] call A3C_ui_radialMenu_fnc_squad_labelOuterRingGrenades;
};

if ((A3C_TEMP_ACTION select 0) == "GRENADE") then {
	A3C_TEMP_ACTION = ["GRENADE", A3C_GREN_MUZZLE];
};
#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onCancelButton

// Reverts and deletes orders and data created during the planning stage.
private _mode = if (count _this > 0) then {
	_this select 0
} else {
	0
};

if (currentWeapon player != A3C_WeaponCurr) then {
	player selectWeapon A3C_WeaponCurr;
};

if (_mode == 0) then {
	[IDD_MAP_OVERLAY] call A3C_ui_mapOverlay_fnc_CloseMapOverlay;
};
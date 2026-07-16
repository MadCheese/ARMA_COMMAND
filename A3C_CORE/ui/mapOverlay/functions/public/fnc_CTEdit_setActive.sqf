#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_CTEdit_setActive

// Fires when the player starts or stops using a CT Edit UI control.
params [
	"_controlType",
	"_mode"
];

private _display = findDisplay IDD_MAP_OVERLAY;

if (isNull _display) exitWith {}; // Only the map variant has CT Edit.

private _mapControl =
	findDisplay 12 displayCtrl 51;

if (_mode == "ON") then {
	A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE = true;
	A3C_BOOL_CT_SPACING = true;
	A3C_BOOL_DISABLEMAPCTRL = true;

	_mapControl ctrlEnable false;
} else {
	A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE = false;
	A3C_BOOL_CT_SPACING = false;
	A3C_BOOL_DISABLEMAPCTRL = false;

	_mapControl ctrlEnable true;

	switch (_controlType) do {
		case "TIMEOUT": {
			if ((A3C_TEMP_CONDITION select 0) == "TIMEOUT") then {
				A3C_TIMEOUT_VAL = parseNumber (
					ctrlText (
						_display displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP
					)
				);
			};
		};

		case "SPACING": {
			private _spacing = parseNumber (
				ctrlText (
					_display displayCtrl IDC_MAP_UFSB_SPACING
				)
			);

			switch (A3C_MAP_CommandMode) do {
				case "INF": {
					A3C_SPACING_INF = _spacing max 2;
				};

				case "AIR": {
					A3C_SPACING_AIR = _spacing max 30;
				};
			};
		};

		case "GROUPNAME": {

		};
	};
};
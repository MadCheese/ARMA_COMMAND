#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_refreshControlBar

params ["_mode"];

if (_mode == "HC") exitWith {};

private _display = findDisplay IDD_MAP_OVERLAY;
private _formationImage = _display displayCtrl IDC_MAP_UFSB_WPFORMATION_IMG;

if (count A3C_SELECTED_UNITS > 1) then {
	if (A3C_FORMMODE_TEMP == 0) then {
		A3C_FORMMODE_TEMP = 1;

		_formationImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa";
	};
} else {
	_formationImage ctrlSetText
		"A3C_CORE\ui\pictures\icon_menu_formDir_None.paa";

	A3C_FORMMODE_TEMP = 0;

	if (A3C_LAST_SUBSET_ACTION == "SQ_FORMATION") then {
		{
			_x ctrlShow false;
		} forEach (
			["map_ufsb_subSet_parentMacros"] call FUNC(ctrlGroup)
		);
	};
};

private _holdColor = [1, 1, 1, 0.2];
private _continueColor = [1, 1, 1, 0.2];

if (
	{
		!(_x getVariable ["A3C_HOLD", false])
	} count A3C_SELECTED_UNITS > 0
) then {
	_holdColor = [1, 1, 1, 1];
};

if (
	{
		_x getVariable ["A3C_HOLD", false]
	} count A3C_SELECTED_UNITS > 0
) then {
	_continueColor = [1, 1, 1, 1];
};

(_display displayCtrl IDC_MAP_UFSB_HOLD_IMG)
	ctrlSetTextColor _holdColor;

(_display displayCtrl IDC_MAP_UFSB_CONTINUE_IMG)
	ctrlSetTextColor _continueColor;

private _cancelColor = [1, 1, 1, 0.2];

if (
	{
		private _unit = _x;

		{
			count (_unit getVariable [_x, []]) > 0
		} count [
			"A3C_PLOT",
			"A3C_PLOT_TEMP"
		] > 0
	} count A3C_SELECTED_UNITS > 0
) then {
	_cancelColor = [1, 1, 1, 1];
};

(_display displayCtrl IDC_MAP_UFSB_CANCEL_IMG)
	ctrlSetTextColor _cancelColor;

[] spawn {
	sleep 0.5;

	private _spacing = if (A3C_MAP_CommandMode == "AIR") then {
		A3C_SPACING_AIR
	} else {
		A3C_SPACING_INF max 2
	};

	private _spacingText = if (_spacing < 10) then {
		"0" + str _spacing
	} else {
		str _spacing
	};

private _display = findDisplay IDD_MAP_OVERLAY;

	(_display displayCtrl IDC_MAP_UFSB_SPACING)
		ctrlSetText _spacingText;
};
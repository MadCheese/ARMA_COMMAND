#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_refreshUnitSelectionUi

/*
	Refreshes selection-dependent controls and actions for the active
	map-overlay or radial-menu context.
*/

private _mapDisplay = findDisplay IDD_MAP_OVERLAY;
private _radialDisplay = findDisplay IDD_RADIAL_MENU;

private _isMap = !isNull _mapDisplay;
private _isRadial = !_isMap && {!isNull _radialDisplay};

if (!_isMap && {!_isRadial}) exitWith {};

private _commandMode = if (_isRadial) then {
	A3C_CURRENT_COMMAND_LEVEL
} else {
	if (A3C_MAP_CommandMode == "HC") then {
		"HIGHCOMMAND"
	} else {
		"SQUAD"
	}
};

/*
	Remove entries of the wrong data type from the shared selection array.

	Squad selection contains objects.
	High-command selection contains groups.
*/
A3C_SELECTED_UNITS = if (_commandMode == "SQUAD") then {
	A3C_SELECTED_UNITS select {
		_x isEqualType objNull
	}
} else {
	A3C_SELECTED_UNITS select {
		_x isEqualType grpNull
	}
};

if (_isRadial) exitWith {
	private _previousRadialHover = A3C_RADIAL_HOVER;
	private _radialModeLower = toLower A3C_RADIALMODE;
	private _isActionMode = "act" in _radialModeLower;

	/*
		Several radial refresh functions alter their behavior according to
		A3C_RADIAL_HOVER. Temporarily force the refresh path, then restore the
		real hover state.
	*/
	A3C_RADIAL_HOVER = true;

	if (_commandMode == "SQUAD") then {
		if (_isActionMode) then {
			BV_ACT = 0;

			[
				"ACTIONS",
				-1
			] call A3C_ui_radialMenu_fnc_buttonActionInnerRing;
		};

		/*
			Rebuild medical data when the medical controls are currently
			open.
		*/
		if (BV_MEDICAL == 1) then {
			[
				"MEDICAL"
			] call A3C_ui_radialMenu_fnc_labelListbox;
		};

		/*
			Recalculate rearm options when the rearm page is open.
		*/
		if (A3C_LBR_1 == "REARM") then {
			A3C_ReArm_options = [];

			[] call A3C_ui_radialMenu_fnc_reArm_openUi;
		};

		if (A3C_RADIALMODE == "VEHS") then {
			[
				A3C_RD_UNITS
			] call A3C_ui_radialMenu_fnc_squad_findVehicles;
		};

		[] call A3C_ui_radialMenu_fnc_buttonReInit;
	} else {
		/*
			Radial high-command selection.
		*/
		if (_isActionMode) then {
			[
				"ROE",
				-1,
				false,
				true
			] call A3C_ui_radialMenu_fnc_buttonActionInnerRing;
		};

		[] call A3C_ui_shared_fnc_createDashBoard;
	};

	A3C_RADIAL_HOVER = _previousRadialHover;
};

/*
	Map-overlay selection refresh.
*/
if (_commandMode == "SQUAD") then {
	private _toggleMode = "COLLAPSE";

	if (A3C_SELECTED_UNITS isNotEqualTo []) then {
		_toggleMode = "OPEN";

		private _selectedUnit = A3C_SELECTED_UNITS select 0;

		private _controlBarMode = if (
			vehicle _selectedUnit isKindOf "AIR"
		) then {
			"AIR"
		} else {
			"INF"
		};

		[
			_controlBarMode
		] call A3C_ui_mapOverlay_fnc_UFSB_refreshControlBar;
	};

	[
		_toggleMode,
		0.1
	] call A3C_ui_mapOverlay_fnc_UFSB_onToggleBar;
} else {
	/*
		Map high-command selection does not use the squad unit-function
		selection bar.
	*/
	[
		"COLLAPSE",
		0.1
	] call A3C_ui_mapOverlay_fnc_UFSB_onToggleBar;
};
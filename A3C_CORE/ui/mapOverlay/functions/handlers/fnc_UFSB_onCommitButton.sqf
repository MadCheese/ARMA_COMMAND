#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onCommitButton

// Assigns all orders created during the planning stage.
params ["_mode"];

private _addressedUnits = if (_mode == "ALL") then {
	A3C_ORDER_UNITS
} else {
	A3C_SELECTED_UNITS
};

A3C_DIAG_ACTIVE = false;

A3C_ui_mapOverlay_fnc_UFSB_onUndoButton_MODE = 0; // 0 means undo WP, 1 means undo SYNC.

// A3C_USERACTION contains input data for undo.
// Passed as [_inputIndex, _inputType, _syncWPindex].
// _inputType: 0 == waypoint entry, 1 == sync entry.
A3C_USERACTION = [];
A3C_USERACTION_ID = 0;

private _display = findDisplay IDD_MAP_OVERLAY;

(
	_display displayCtrl IDC_MAP_UFSB_UNDO_BTN
) ctrlShow false;

(
	_display displayCtrl IDC_MAP_UFSB_UNDO_IMG
) ctrlSetTextColor [1, 1, 1, 0.2];

{
	private _unit = _x;
	private _plotTemp =
		_unit getVariable ["A3C_PLOT_TEMP", []];

	if !(isPlayer _unit) then {
		if (
			count (
				_unit getVariable ["A3C_PLOT", []]
			) == 0
		) then {
			_unit setVariable [
				"A3C_PLOT",
				(
					(_unit getVariable "A3C_PLOT")
						+ _plotTemp
				),
				true
			];

			private _script = [
				_unit,
				_unit getVariable ["A3C_PLOT", []]
			] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot;
		} else {
			_unit setVariable [
				"A3C_PLOT",
				(
					(_unit getVariable "A3C_PLOT")
						+ _plotTemp
				),
				true
			];
		};

		_unit setVariable [
			"A3C_PLOT_TEMP",
			[],
			true
		];
	};
} forEach _addressedUnits;
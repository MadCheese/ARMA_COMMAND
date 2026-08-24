#include "..\..\ui\mapOverlay\dialog_defines.hpp"


// A3C_ai_shared_fnc_cancelUnitPlot

// Abort existing orders.
//
// To continue with a new plot after calling this function, wait until:
// waitUntil { _unit getVariable ["A3C_PLOT", []] isEqualTo [] };

if (A3C_MAP_CommandMode == "HC") exitWith {};

params ["_selectedUnits", "_shift", "_ctrl"];

if (!_shift && { !_ctrl }) exitWith {
	{
		_x setVariable ["A3C_PLOT_TEMP", [], true];
	} forEach _selectedUnits;

	A3C_USERACTION = [];
	A3C_USERACTION_ID = 0;
	A3C_WAYPOINTS_TEMP = [];

	private _display = findDisplay IDD_MAP_OVERLAY;

	(_display displayCtrl IDC_MAP_UFSB_UNDO_BTN) ctrlShow false;
	(_display displayCtrl IDC_MAP_UFSB_UNDO_IMG) ctrlSetTextColor [1, 1, 1, 0.2];

	[A3C_MAP_CommandMode] call A3C_ui_mapOverlay_fnc_UFSB_refreshControlBar;
};

if (_shift) then {
	{
		private _unit = _x;

		_unit setVariable ["A3C_PLOT_TEMP", [], true];

		A3C_USERACTION = [];
		A3C_USERACTION_ID = 0;
		A3C_WAYPOINTS_TEMP = [];

		private _display = findDisplay IDD_MAP_OVERLAY;

		(_display displayCtrl IDC_MAP_UFSB_UNDO_BTN) ctrlShow false;
		(_display displayCtrl IDC_MAP_UFSB_UNDO_IMG) ctrlSetTextColor [1, 1, 1, 0.2];

		[_unit, position _unit] call A3C_ai_shared_fnc_doMove;

		[_unit] spawn {
			params ["_unit"];

			private _unitPlot = _unit getVariable ["A3C_PLOT", []];

			if ((count _unitPlot) > 0) then {
				_unit setVariable ["A3C_ABORT_Data", [true, false], true];

				waitUntil {
					count (_unit getVariable ["A3C_PLOT", []]) == 0
				};
			};

			// Reset abort variable after clearing.
			_unit setVariable ["A3C_ABORT_Data", [false, false], true];
			_unit setVariable ["A3C_PLOT_TEMP", [], true];

			{
				_unit enableAI _x;
			} forEach ["MOVE", "TARGET", "AUTOTARGET", "FSM", "AUTOCOMBAT"];

			[
				vehicle _unit,
				"UNLOCKED"
			] remoteExec ["setVehicleLock", vehicle _unit];

			_unit forceSpeed -1;

			if (
				!isNull objectParent _unit
				&& {_unit == driver vehicle _unit}
			) then {
				(vehicle _unit) limitSpeed false;
			};
		};
	} forEach _selectedUnits;
};

if (_ctrl) then {
	{
		private _unit = _x;
		private _plotData = _unit getVariable "A3C_PLOT";

		{
			private _waypointData = _x;

			if (
				_forEachIndex ==
				((_unit getVariable "A3C_CURRENTWAYPOINT_INDEX") - 1)
			) then {
				if !([
					_plotData,
					_forEachIndex
				] call A3C_ui_mapOverlay_fnc_isWaypointLoop) then {
					{
						deleteMarkerLocal _x;
					} forEach (_waypointData select 1);
				};
			};
		} forEach _plotData;

		// Causes the unit to skip its current waypoint.
		_unit setVariable ["A3C_ABORT_Data", [false, true], true];
	} forEach _selectedUnits;
};

[] spawn {
	sleep 0.5;

	[A3C_MAP_CommandMode] call A3C_ui_mapOverlay_fnc_UFSB_refreshControlBar;
};
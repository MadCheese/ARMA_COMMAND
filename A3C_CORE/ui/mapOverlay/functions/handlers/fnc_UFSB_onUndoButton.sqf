#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onUndoButton

private _display = findDisplay IDD_MAP_OVERLAY;

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
];

private _waypoint = A3C_WAYPOINTS_TEMP select (
	(count A3C_WAYPOINTS_TEMP) - 1
);

private _undoData = A3C_USERACTION select (
	(count A3C_USERACTION) - 1
);

if ((_undoData select 1) == 0) then {
	// Undo waypoint.
	{
		private _unit = _x;
		private _unitPolygons =
			_unit getVariable ["A3C_UNIT_POLYS", []];

		{
			private _polygon = _x;

			if (
				(_waypoint select 1)
					== ((_polygon select 0) select 1)
			) then {
				[
					_unit,
					_polygon
				] call A3C_ai_shared_fnc_polygonAreaRemove;

				_unitPolygons = _unitPolygons - [_polygon];
			}; //~~ exitWith??
		} forEach _unitPolygons;

		_unit setVariable [
			"A3C_UNIT_POLYS",
			_unitPolygons,
			true
		];

		private _plotTemp =
			_unit getVariable "A3C_PLOT_TEMP";

		_unit setVariable [
			"A3C_PLOT_TEMP",
			_plotTemp - [
				_plotTemp select (
					(count _plotTemp) - 1
				)
			],
			true
		];
	} forEach (
		_waypoint select 0
	);

	if ((_waypoint select 3) == 4) then {
		if (count A3C_WAYPOINTS_TEMP > 1) then {
			private _previousWaypoint =
				A3C_WAYPOINTS_TEMP select (
					(count A3C_WAYPOINTS_TEMP) - 2
				);

			private _previousUnits =
				_previousWaypoint select 0;

			if ((_previousWaypoint select 3) == 4) then {
				A3C_SPLIT_UNITS = [
					A3C_SPLIT_UNITS select (
						(count A3C_SPLIT_UNITS) - 1
					)
				] + (
					A3C_SPLIT_UNITS - [
						A3C_SPLIT_UNITS select (
							(count A3C_SPLIT_UNITS) - 1
						)
					]
				);
			};
		};
	};

	A3C_WAYPOINTS_TEMP =
	A3C_WAYPOINTS_TEMP - [_waypoint];
} else {
	// Undo loop.
	{
		private _selectedLeader = _x;
		private _plotTemp =
			_selectedLeader getVariable "A3C_PLOT_TEMP";

		{
			_x set [10, -1];
		} forEach _plotTemp;

		A3C_WAYPOINTS_TEMP =
			A3C_WAYPOINTS_TEMP - [_waypoint];

		_selectedLeader setVariable [
			"A3C_PLOT_TEMP",
			_plotTemp,
			true
		];
	} forEach (
		_waypoint select 0
	);
};

A3C_USERACTION = A3C_USERACTION - [_undoData];
A3C_USERACTION_ID = A3C_USERACTION_ID - 1;

private _undoButton =
	_display displayCtrl IDC_MAP_UFSB_UNDO_BTN;

private _undoImage =
	_display displayCtrl IDC_MAP_UFSB_UNDO_IMG;

if (count A3C_WAYPOINTS_TEMP > 0) then {
	_undoButton ctrlShow true;
	_undoImage ctrlSetTextColor [1, 1, 1, 1];
} else {
	_undoButton ctrlShow false;
	_undoImage ctrlSetTextColor [1, 1, 1, 0.2];
};

[] remoteExec [
	"A3C_ui_shared_fnc_toggleGocodeCtrls",
	0
];
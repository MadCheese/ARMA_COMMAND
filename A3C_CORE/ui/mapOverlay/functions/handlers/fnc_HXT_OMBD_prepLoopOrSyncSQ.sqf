// A3C_ui_mapOverlay_fnc_HXT_OMBD_prepLoopOrSyncSQ

/*
 * MouseButtonDown on marker.
 *
 * If a loop can be created, this prepares display event handlers
 * and creates the drag-line state for MouseDrag arrow handling.
 */

params [
	"_screenX",
	"_screenY"
];

disableSerialization;

private _units = [];
private _waypointIds = [];

A3C_LOOPSYNC_START = [
	"",
	[
		0,
		0,
		0
	]
];

private _mapControl =
	findDisplay 12 displayCtrl 51;

private _squadWaypoints = [
	"SQ_WP_DOT",
	_screenX,
	_screenY
] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos;

private _waypointPosition = [
	0,
	0,
	0
];

if (count _squadWaypoints > 0) then {
	private _squadWaypoint =
		_squadWaypoints select 0;

	_waypointPosition =
		_squadWaypoint select 2;

	_waypointIds =
		_squadWaypoint select 3;
};

if (count _waypointIds > 0) then {
	// We are in business.
	{
		private _unit = _x;

		{
			private _plotVarName = _x;

			private _plotData =
				_unit getVariable _plotVarName;

			{
				private _waypointData = _x;

				_waypointData params [
					"_wpPositions",
					"_wpMarkers",
					"_wpAction",
					"_wpCondition",
					"_wpStances",
					"_wpSyncData",
					"_wpCompleted",
					"_wpCombatMode",
					"_wpSpeed",
					"_wpFlyInHeight",
					"_wpLoopValue",
					"_wpRadius"
				];

				if (
					(_wpMarkers select 0)
						== (_waypointIds select 0)
					&& {
						_wpMarkers select 1 != ""
					}
				) then {
					{
						private _syncItem = _x;

						if !((_syncItem select 0) == 0) then {
							{
								private _otherUnit = _x;

								{
									private _otherPlotVarName = _x;

									private _otherPlotData =
										_otherUnit getVariable _otherPlotVarName;

									{
										private _otherWaypointData = _x;

										private _otherSyncData =
											_otherWaypointData select 5;

										{
											private _otherSyncItem = _x;

											if (
												(_otherSyncItem select 0)
													== (_syncItem select 0)
											) then {
												_otherSyncData =
													_otherSyncData
													- [_otherSyncItem];
											};
										} forEach _otherSyncData;

										_otherWaypointData set [
											5,
											_otherSyncData
										];
									} forEach _otherPlotData;

									_otherUnit setVariable [
										_otherPlotVarName,
										_otherPlotData,
										true
									];
								} forEach [
									"A3C_PLOT",
									"A3C_PLOT_TEMP"
								];
							} forEach (
								units player
								- [
									player,
									_unit
								]
							);
						};
					} forEach _wpSyncData;

					_waypointData set [
						5,
						[
							[
								0,
								false
							]
						]
					];

					_unit setVariable [
						_plotVarName,
						_plotData,
						true
					];
				};
			} forEach _plotData;
		} forEach [
			"A3C_PLOT",
			"A3C_PLOT_TEMP"
		];
	} forEach (
		units player - [
			player
		]
	);

	A3C_BOOL_MOUSEMOVING = true;
	A3C_BOOL_MAP_MU = true;

	A3C_MMCode = {
		_this spawn A3C_ui_mapOverlay_fnc_onDragMapStandard;
	};

	// Step 1.
	{
		private _unit = _x;

		if (
			{
				(_waypointIds select 0)
					in (_x select 1)
			} count (
				(_unit getVariable "A3C_PLOT_TEMP")
				+ (_unit getVariable "A3C_PLOT")
			) > 0
		) then {
			_units pushBack _unit;
		};
	} forEach (
		(
			profileNamespace getVariable "A3C_GROUPUNITS"
		) - [
			player
		]
	);

	if (
		{
			(
				{
					(_waypointIds select 0)
						in (_x select 1)
				} count (
					_x getVariable "A3C_PLOT_TEMP"
				)
			) > 0
			&& {
				count (
					_x getVariable "A3C_PLOT"
				) > 0
			}
		} count _units > 0
	) then {
		[] spawn {
			hint "This feature is not compatible with extending sessions. Press 'COMMIT' first!";

			sleep 3;

			hintSilent "";
		};
	} else {
		{
			[
				_x
			] call A3C_ui_mapOverlay_fnc_resetUnitLoopState;
		} forEach _units;

		A3C_BOOL_LOOPING = true;

		A3C_LOOPSYNC_START = [
			_waypointIds select 0,
			_waypointPosition
		];

		if !(A3C_BOOL_DRAGLINE) then {
			A3C_BOOL_DRAGLINE = true;
			A3C_CONNECTING_MODE = "LOOP";
		};
	};
} else {
	// Create drag field.
	A3C_MapSel_Field_Root =
		_mapControl posScreenToWorld [
			A3C_MAP_X,
			A3C_MAP_Y
		];

	A3C_MapSel_Field_DEST =
		_mapControl posScreenToWorld [
			A3C_MAP_X,
			A3C_MAP_Y
		];

	// Signal the draw function to draw the field.
	A3C_MapSel_Field_Active = true;
};
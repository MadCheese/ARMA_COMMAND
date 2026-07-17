#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_setorderWIP

/*
 * Creates temporary planning data in two phases:
 *
 * 0: Mouse button down — process the formation leader.
 * 1: Mouse button up   — process the remaining selected units.
 */
params [
	"_mode",
	["_fetchedUnit", objNull]
];

private _display = findDisplay IDD_MAP_OVERLAY;

private _timeoutControl =
	_display displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP;

private _spacingControl =
	_display displayCtrl IDC_MAP_UFSB_SPACING;

private _formDir = 0;
private _units = [];
private _spread = 0;
private _distance = 0;
private _wpSyncData = [[0, false]];

A3C_TEMP_WP_ID_SUB = "";
A3C_SNAP_MAP_BOOL = true;

// Part 1: determine whether the leader or remaining units are processed.
switch (_mode) do {
	case 0: {
		if (A3C_FORMMODE_TEMP in [4, 5]) then {
			A3C_SNAP_MAP_BOOL = false;
		} else {
			_units = [
				A3C_SELECTED_UNITS select 0
			];

			if (
				(A3C_TEMP_ACTION select 0) in [
					"GRENADE",
					"SUPPRESSION"
				]
			) then {
				A3C_SNAP_MAP_BOOL = false;
			};

			if (A3C_TAB_BUILDING_BOOL) then {
				A3C_SNAP_MAP_BOOL = false;
			};
		};

		A3C_CLICKPOS_ROOT = A3C_CLICKPOS_1;
	};

	case 1: {
		if (A3C_FORMMODE_TEMP in [0, 1, 2, 3, 4]) then {
			A3C_CLICKPOS_2 = [
				A3C_CLICKPOS_ROOT,
				100,
				[
					A3C_CLICKPOS_ROOT,
					A3C_CLICKPOS_2
				] call BIS_fnc_dirTo
			] call BIS_fnc_relPos;

			A3C_CLICKPOS_2 set [2, 10];
		};

		switch (A3C_FORMMODE_TEMP) do {
			case 1: {
				_formDir = (
					[
						A3C_CLICKPOS_1,
						A3C_CLICKPOS_2
					] call BIS_fnc_dirTo
				) + 180;
			};

			case 2: {
				_formDir = (
					[
						A3C_CLICKPOS_1,
						A3C_CLICKPOS_2
					] call BIS_fnc_dirTo
				) + 90;
			};

			case 3: {
				_formDir = (
					[
						A3C_CLICKPOS_1,
						A3C_CLICKPOS_2
					] call BIS_fnc_dirTo
				) - 90;
			};

			case 5: {
				_spread = 360 / count A3C_SELECTED_UNITS;

				_distance =
					A3C_CLICKPOS_1 distance2D A3C_CLICKPOS_2;
			};
		};

		_formDir = [
			_formDir
		] call MCSS_fnc_correctDir;

		if (A3C_FORMMODE_TEMP == 4) then {
			if (
				A3C_SPLIT_UNITS
					isEqualTo A3C_SELECTED_UNITS
			) then {
				A3C_SYNC_INDEX = A3C_SYNC_INDEX + 1;
			};

			_wpSyncData = [
				[
					A3C_SYNC_INDEX,
					false
				]
			];

			A3C_WAYPOINTS_TEMP = A3C_WAYPOINTS_TEMP + [
				[
					[
						A3C_SPLIT_UNITS select 0
					],
					A3C_TEMP_WP_ID_MAIN,
					A3C_TEMP_WP_ID_SUB,
					A3C_FORMMODE_TEMP
				]
			];
		} else {
			_units = if (A3C_FORMMODE_TEMP == 5) then {
				A3C_SELECTED_UNITS
			} else {
				A3C_SELECTED_UNITS - [
					A3C_SELECTED_UNITS select 0
				]
			};

			A3C_WAYPOINTS_TEMP = A3C_WAYPOINTS_TEMP + [
				[
					A3C_SELECTED_UNITS,
					A3C_TEMP_WP_ID_MAIN,
					A3C_TEMP_WP_ID_SUB,
					A3C_FORMMODE_TEMP
				]
			];
		};
	};
};

if ((A3C_TEMP_CONDITION select 0) == "TIMEOUT") then {
	private _timeoutValue =
		parseNumber ctrlText _timeoutControl;

	A3C_TEMP_CONDITION set [
		1,
		_timeoutValue
	];

	A3C_TIMEOUT_VAL = _timeoutValue;
};

// Part 2: assign planning data to the selected units.
{
	private _unit = _x;
	private _createSecondaryMarker = true;

	A3C_TEMP_WP_ID_SUB = "";

	private _effectivePosition = [];
	private _snapPositions = [];
	private _unitArrayIndex = _forEachIndex;

	if !(A3C_FORMMODE_TEMP in [4, 5]) then {
		if (_unit != (A3C_SELECTED_UNITS select 0)) then {
			// Any formation except split and circle modifies positions.
			if (A3C_TAB_BUILDING_BOOL) then {
				// Assign matching building positions.
				A3C_CLICKPOS_1 = A3C_TAB_BUILDING buildingPos (
					[
						_unit,
						A3C_SELECTED_UNITS
					] call MCSS_fnc_getArrayIndex
				);
			} else {
				// Move along the formation line.
				A3C_CLICKPOS_1 = [
					A3C_CLICKPOS_1,
					A3C_DIAG_SPACING,
					_formDir
				] call BIS_fnc_relPos;

				if (A3C_SNAP_MAP_BOOL) then {
					// Search for snap positions on both sides.
					{
						private _clickPosition = +A3C_CLICKPOS_1;

						// Copy the position so the formation line remains intact.
						_clickPosition set [2, 0.3];
						_clickPosition = ATLToASL _clickPosition;

						private _referencePosition = [
							_clickPosition,
							15,
							_formDir + _x
						] call BIS_fnc_relPos;

						private _intersections = lineIntersectsSurfaces [
							_clickPosition,
							_referencePosition,
							objNull,
							objNull,
							true,
							1,
							"GEOM",
							"FIRE"
						];

						if (count _intersections > 0) then {
							private _collider =
								(_intersections select 0) select 2;

							if (!isNil "_collider") then {
								if (
									getNumber (
										configFile
											>> "CfgVehicles"
											>> typeOf _collider
											>> "armor"
									) >= 200
								) then {
									private _snapData = [
										(_intersections select 0) select 0,
										_collider
									] call A3C_UI_squadPlacement_fnc_snapFormation;

									(_snapData select 0) set [2, 0];

									//~~ #unused_prms set [2,[(_prms select 2) + 180] call MCSS_fnc_correctDir];
									_snapPositions pushBack (
										_snapData select 0
									);
								};
							};
						};

						if (_forEachIndex == 1) then {
							if (count _snapPositions > 0) then {
								_snapPositions = [
									_snapPositions,
									[],
									{
										_x distance2D A3C_CLICKPOS_1
									},
									"ASCEND"
								] call BIS_fnc_sortBy;

								_effectivePosition =
									_snapPositions select 0;
							};
						};
					} forEach [90, -90];
				};
			};
		};
	} else {
		// Split and circle modes do not use the normal formation offsets.
		A3C_CLICKPOS_1 = [
			A3C_CLICKPOS_ROOT,
			_distance,
			_spread * _forEachIndex
		] call BIS_fnc_relPos;

		A3C_CLICKPOS_2 = [
			A3C_CLICKPOS_1,
			100,
			_spread * _forEachIndex
		] call BIS_fnc_relPos;
	};

	if (count _effectivePosition == 0) then {
		_effectivePosition = A3C_CLICKPOS_1;
	};

	if (A3C_FORMMODE_TEMP in [1, 2, 3, 5]) then {
		if (A3C_CLICKPOS_1 isEqualTo A3C_CLICKPOS_ROOT) then {
			_createSecondaryMarker = false;
		};

		if (_createSecondaryMarker) then {
			A3C_TEMP_WP_ID_SUB = format [
				"A3C_Mark_P%1",
				A3C_MARKER_COUNT
			];

			A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;

			(
				A3C_WAYPOINTS_TEMP select (
					(count A3C_WAYPOINTS_TEMP) - 1
				)
			) pushBack A3C_TEMP_WP_ID_SUB;
		};
	};

	private _effectiveLookPosition = if (
		A3C_FORMMODE_TEMP == 1
	) then {
		_effectivePosition getPos [
			100,
			(
				_effectivePosition getDir A3C_CLICKPOS_2
			) + (
				180
					* (
						(_unitArrayIndex + 1)
							/ count A3C_SELECTED_UNITS
					)
			)
		]
	} else {
		+A3C_CLICKPOS_2
	};

	private _action = +A3C_TEMP_ACTION;
	private _plotTemp = _unit getVariable "A3C_PLOT_TEMP";

	_unit setVariable [
		"A3C_PLOT_TEMP",
		_plotTemp + [
			[
				[
					_effectivePosition,
					_effectiveLookPosition
				],
				[
					A3C_TEMP_WP_ID_MAIN,
					A3C_TEMP_WP_ID_SUB
				],
				_action,
				A3C_TEMP_CONDITION,
				[
					A3C_STANCE1_TEMP,
					A3C_STANCE2_TEMP
				],
				_wpSyncData,
				false,
				A3C_CMODE_TEMP,
				A3C_WP_SPEED_TEMP,
				A3C_HELIHEIGHT,
				-1,
				0
			]
		],
		true
	];

	if !(_unit in A3C_ORDER_UNITS) then {
		A3C_ORDER_UNITS = A3C_ORDER_UNITS + [_unit];
	};

	// This update intentionally remains inside the unit loop. The first
	// processed unit therefore uses the previously stored spacing value.
	A3C_DIAG_SPACING =
		parseNumber ctrlText _spacingControl;
} forEach _units;

// Replace the leader's final action/look-direction data after ButtonUp.
if (_mode == 1) then {
	if ((A3C_TEMP_ACTION select 0) == "STATIC") then {
		_units = [
			A3C_SELECTED_UNITS select 0
		];

		{
			private _switchData =
				_x getVariable "A3C_PLOT_TEMP";

			if (count _switchData > 0) then {
				(
					_switchData select (
						(count _switchData) - 1
					)
				) set [
					2,
					A3C_TEMP_ACTION
				];
			};
		} forEach _units;
	};

	if (A3C_FORMMODE_TEMP in [0, 1, 2, 3]) then {
		_units = [
			A3C_SELECTED_UNITS select 0
		];

		{
			private _switchData =
				_x getVariable ["A3C_PLOT_TEMP", []];

			if (count _switchData > 0) then {
				(
					(
						_switchData select (
							(count _switchData) - 1
						)
					) select 0
				) set [
					1,
					A3C_CLICKPOS_2
				];

				_x setVariable [
					"A3C_PLOT_TEMP",
					_switchData,
					true
				];
			};
		} forEach _units;
	};

	if (A3C_FORMMODE_TEMP == 4) then {
		_units = [
			A3C_SPLIT_UNITS select 0
		];

		{
			private _switchData =
				_x getVariable ["A3C_PLOT_TEMP", []];

			(
				(
					_switchData select (
						(count _switchData) - 1
					)
				) select 0
			) set [
				1,
				A3C_CLICKPOS_2
			];

			(
				_switchData select (
					(count _switchData) - 1
				)
			) set [
				5,
				_wpSyncData
			];

			_x setVariable [
				"A3C_PLOT_TEMP",
				_switchData,
				true
			];
		} forEach _units;
	};

	[
		A3C_MAP_CommandMode
	] call A3C_ui_mapOverlay_fnc_UFSB_RefreshControlBar;
} else {
	[] remoteExec [
		"A3C_ui_shared_fnc_toggleGocodeCtrls",
		0
	];
};
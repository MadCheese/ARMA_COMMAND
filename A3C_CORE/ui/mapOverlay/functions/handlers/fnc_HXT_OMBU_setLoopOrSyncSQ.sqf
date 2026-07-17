// A3C_ui_mapOverlay_fnc_HXT_OMBU_setLoopOrSyncSQ

/*
 * MouseButtonUp after loop/sync drag preparation.
 *
 * #NOTE: Seems to be used for sync.
 */

A3C_BOOL_LOOPING = false;
A3C_BOOL_MAP_MU = false;
A3C_BOOL_MOUSEMOVING = false;

params [
	"_mapControl",
	"_button",
	"_screenX",
	"_screenY"
];

// Exit if RMB was used to enable map-drag.
if (_button == 1) exitWith {};

private _units = [];
private _checkVar = "A3C_PLOT_TEMP";
private _dragMode = "LOOP";

private _unitArray =
	(
		profileNamespace getVariable "A3C_GROUPUNITS"
	) - [
		player
	];

disableSerialization;

private _mapControlBase =
	findDisplay 12 displayCtrl 51;

private _marker = "";

A3C_BOOL_DRAGLINE = false;

private _waypointIds = [];

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

private _exit = true;

if (count _waypointIds > 0) then {
	_marker = _waypointIds select 0;

	if !((A3C_LOOPSYNC_START select 0) == _marker) then {
		_exit = false;
	};
};

if (_exit) exitWith {};

// Determine which plot variable the start waypoint belongs to.
// Destination must be in the same plot variable.
{
	private _unit = _x;

	if (
		{
			(A3C_LOOPSYNC_START select 0)
				in (_x select 1)
		} count (
			_unit getVariable "A3C_PLOT_TEMP"
		) > 0
	) then {
		_units pushBack _unit;
	};

	if (
		{
			(A3C_LOOPSYNC_START select 0)
				in (_x select 1)
		} count (
			_unit getVariable "A3C_PLOT"
		) > 0
	) then {
		_units pushBack _unit;
		_checkVar = "A3C_PLOT";
	};

	if (
		{
			_marker in (_x select 1)
		} count (
			_unit getVariable _checkVar
		) == 0
	) then {
		_units = _units - [
			_unit
		];
	};
} forEach _unitArray;

// No loop found. Check for sync.
if (count _units == 0) then {
	_dragMode = "SYNC";

	private _syncCreated = false;

	{
		private _unit = _x;

		{
			private _plotVarName = _x;

			private _plotData =
				_unit getVariable _plotVarName;

			{
				private _waypointData = _x;
				private _waypointIndex = _forEachIndex;

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

				if ((A3C_LOOPSYNC_START select 0) in _wpMarkers) then {
					_units pushBackUnique _unit;

					if (((_wpSyncData select 0) select 0) == 0) then {
						_waypointData set [
							5,
							[
								[
									A3C_SYNC_INDEX,
									false
								]
							]
						];
					} else {
						(_waypointData select 5) pushBackUnique [
							A3C_SYNC_INDEX,
							false
						];
					};

					_syncCreated = true;
				};

				if (_marker in _wpMarkers) then {
					_units pushBackUnique _unit;

					if (((_wpSyncData select 0) select 0) == 0) then {
						_waypointData set [
							5,
							[
								[
									A3C_SYNC_INDEX,
									false
								]
							]
						];
					} else {
						(_waypointData select 5) pushBackUnique [
							A3C_SYNC_INDEX,
							false
						];
					};

					_syncCreated = true;

					if (_waypointIndex == 1) then {
						_checkVar = "A3C_PLOT";
					};
				};
			} forEach _plotData;

			_unit setVariable [
				_plotVarName,
				_plotData,
				true
			];
		} forEach [
			"A3C_PLOT_TEMP",
			"A3C_PLOT"
		];
	} forEach _unitArray;

	if (_syncCreated) then {
		A3C_SYNC_INDEX = A3C_SYNC_INDEX + 1;
	};
};

// Still no units: exit.
if (count _units == 0) exitWith {
	A3C_LOOPSYNC_START = [
		"",
		[
			0,
			0,
			0
		]
	];

	A3C_DRAGPOS = [];
};

if (_dragMode == "LOOP") then {
	private _wrongDir = false;

	{
		private _unit = _x;
		private _plotData =
			_unit getVariable _checkVar;

		private _markerIndex = -1;

		{
			_x params [
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
					== (A3C_LOOPSYNC_START select 0)
			) then {
				_markerIndex = _forEachIndex;
			};

			if ((_wpMarkers select 0) == _marker) then {
				if (_markerIndex != -1) then {
					_wrongDir = true;
				};
			};
		} forEach _plotData;
	} forEach _units;

	if (!_wrongDir) then {
		{
			private _unit = _x;
			private _plotData =
				_unit getVariable _checkVar;

			private _loopToIndex = 0;

			{
				_x params [
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

				switch (true) do {
					case ((_wpMarkers select 0) == _marker): {
						// loopDest, the earlier waypoint.
						_x set [
							10,
							-2
						];

						_loopToIndex = _forEachIndex;
					};

					case (
						(_wpMarkers select 0)
							== (A3C_LOOPSYNC_START select 0)
					): {
						// loopStart, the later waypoint.
						_x set [
							10,
							_loopToIndex
						];
					};

					default {
						// Reset loop value for all other waypoints.
						_x set [
							10,
							-1
						];
					};
				};
			} forEach _plotData;

			_unit setVariable [
				_checkVar,
				_plotData,
				true
			];
		} forEach _units;
	} else {
		[] spawn {
			hint "Are you looping in the wrong direction?";

			sleep 2;

			hint "";
		};
	};
};

A3C_WAYPOINTS_TEMP pushBack [
	_units,
	"",
	"",
	"",
	1
];

A3C_USERACTION pushBack [
	0,
	1,
	1
];

A3C_USERACTION_ID =
	A3C_USERACTION_ID + 1;

A3C_LOOPSYNC_START = [
	"",
	[
		0,
		0,
		0
	]
];

A3C_DRAGPOS = [];

A3C_CLICKPOS_1 = [
	0,
	0,
	0
];

A3C_CLICKPOS_2 = [
	0,
	0,
	0
];

A3C_TEMP_WP_ID_MAIN = "";
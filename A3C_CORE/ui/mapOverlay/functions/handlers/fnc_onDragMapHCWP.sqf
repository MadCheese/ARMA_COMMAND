// A3C_ui_mapOverlay_fnc_onDragMapHCWP

/*
 * Adjusts the position of an HC waypoint while it is being dragged.
 */

params [
	"_waypoint",
	"_data"
];

_waypoint params [
	"_group",
	"_wpi"
];

if (A3C_BOOL_DISABLEMAPCTRL) exitWith {};

disableSerialization;

private _mapControl =
	findDisplay 12 displayCtrl 51;

private _dragPos =
	_mapControl posScreenToWorld [
		_data select 1,
		_data select 2
	];

if !(_waypoint in A3C_Selection_MultiWaypoint) then {
	// Single waypoint drag.
	_waypoint setWaypointPosition [
		_dragPos,
		0
	];
} else {
	// Multiple waypoint drag.
	private _childWaypoints =
		A3C_Selection_MultiWaypoint - [
			_waypoint
		];

	private _parentWaypointPos =
		waypointPosition _waypoint;

	private _waypointRelPosMap = _childWaypoints apply {
		private _childWaypointPos =
			waypointPosition _x;

		[
			_parentWaypointPos distance2D _childWaypointPos,
			_parentWaypointPos getDir _childWaypointPos
		]
	};

	_waypoint setWaypointPosition [
		_dragPos,
		0
	];

	{
		private _waypointRelPosMapEntry =
			_waypointRelPosMap select _forEachIndex;

		private _newWaypointPos =
			_dragPos getPos [
				_waypointRelPosMapEntry select 0,
				_waypointRelPosMapEntry select 1
			];

		_newWaypointPos set [
			2,
			1000
		];

		// _newWaypointPos set [2, 0];
		// _newWaypointPos set = ATLtoASL _newWaypointPos;

		_x setWaypointPosition [
			_newWaypointPos,
			-1
		]; // Force exact placement with negative radius.
	} forEach _childWaypoints;
};
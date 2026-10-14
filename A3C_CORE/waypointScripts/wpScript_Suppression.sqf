// The engine supplies the first three parameters; custom arguments follow.
params [
	"_group",
	"_pos",
	"_target",
	"_callerUID",
	"_preCondition",
	"_postCondition",
	"_waypointIndex",
	"_markerName"
];

if (
	isNull _group
	|| {[_callerUID, _group] call A3C_ai_highCommand_fnc_isWpScriptBlocked}
) exitWith {
	true
};

// Resolve our waypoint by its unique marker argument, since route edits can
// shift indices while this script is waiting. Never remove another waypoint.
private _getWaypointIndex = {
	private _markerToken = format ["'%1'", _markerName];
	private _matchingWaypoints = (waypoints _group) select {
		_markerToken in waypointScript _x
	};
	if (_matchingWaypoints isEqualTo []) exitWith {-1};
	(_matchingWaypoints select 0) select 1
};

private _isCurrent = {
	private _index = call _getWaypointIndex;
	!isNull _group
	&& {!([_callerUID, _group] call A3C_ai_highCommand_fnc_isWpScriptBlocked)}
	&& {_index >= 0}
	&& {currentWaypoint _group == _index}
};

if !(call _isCurrent) exitWith {true};

// Replace the previous route destination once, without stopping followers
// from reaching formation. The local movement helper executes synchronously.
_waypointIndex = call _getWaypointIndex;
[_group, _waypointIndex] call A3C_ai_highCommand_fnc_moveGroupToPosition;

private _goCodeActivationVariableName = [
	_postCondition select 1,
	side _group
] call A3C_main_fnc_getGoCodeActivationVariableName;

private _polygonReady = {
	private _index = call _getWaypointIndex;
	private _polygons = _group getVariable ["A3C_UNIT_POLYS", []];
	(
		_polygons findIf {
			private _metadata = _x param [0, []];
			(_metadata param [1, ""]) == _markerName
			&& {(_metadata param [2, -1]) == _index}
		}
	) >= 0
};

waitUntil {
	sleep 0.1;
	!(call _isCurrent) || {call _polygonReady}
};

if !(call _isCurrent) exitWith {
	true
};

_waypointIndex = call _getWaypointIndex;
[
	units _group,
	["A3C_HC_POLY", 0],
	"SUPPRESSION",
	false,
	_waypointIndex
] call A3C_ai_shared_fnc_polygonAreaActionOn;

sleep 1;

waitUntil {
	sleep 0.1;
	private _activePolygonActionUnits = {
		alive _x
		&& {_x getVariable ["A3C_POLY_ACTION_ACTIVE", false]}
	} count units _group;

	missionNamespace getVariable [_goCodeActivationVariableName, false]
	|| {_activePolygonActionUnits == 0}
	|| {!(call _isCurrent)}
};

if (
	!isNull _group
	&& {[_callerUID, _group] call A3C_ai_highCommand_fnc_findExecutingMachine}
) then {
	private _activePolygon = _group getVariable ["A3C_POLY_ACTIVE", []];
	private _activeMetadata = _activePolygon param [0, []];
	if ((_activeMetadata param [1, ""]) == _markerName) then {
		// A replaced invocation must not cancel the group's newer suppression.
		[units _group, "SUPPRESSION"] call A3C_ai_shared_fnc_polygonAreaActionOff;
	};

	if (call _isCurrent) then {
		// Let SCRIPTED completion advance to the interrupted waypoint first.
		// Deleting the current waypoint here and then returning can advance twice.
		[_group, _callerUID, _markerName, _getWaypointIndex] spawn {
			params ["_group", "_callerUID", "_markerName", "_getWaypointIndex"];

			waitUntil {
				sleep 0.1;
				private _index = call _getWaypointIndex;
				isNull _group
				|| {!([_callerUID, _group] call A3C_ai_highCommand_fnc_findExecutingMachine)}
				|| {_index < 0}
				|| {currentWaypoint _group != _index}
			};

			if (
				isNull _group
				|| {!([_callerUID, _group] call A3C_ai_highCommand_fnc_findExecutingMachine)}
			) exitWith {};

			private _index = call _getWaypointIndex;
			if (_index < 0 || {currentWaypoint _group <= _index}) exitWith {};

			// Remove only the completed temporary waypoint. No idle-group movement.
			[_group, _index, false] call A3C_ai_highCommand_fnc_removeWaypoint;

			private _resumeWaypoint = [_group, currentWaypoint _group];
			if (
				_resumeWaypoint in waypoints _group
				&& {waypointType _resumeWaypoint != "SCRIPTED"}
			) then {
				// Restore the route destination that the halt order replaced.
				// A following SCRIPTED waypoint owns its own movement instead.
				_resumeWaypoint call A3C_ai_highCommand_fnc_moveGroupToPosition;
			};
		};
	};
};

[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls", 0];
true;

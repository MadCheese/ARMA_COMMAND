// A3C_ai_highCommand_fnc_removeWaypoint

params ["_group", "_wpIndex"];

// ~~ polys will need to have their ID's adjusted.

private _activeWaypointIndex = currentWaypoint _group;
private _isCurrentWaypoint = _wpIndex == _activeWaypointIndex;

// -- step 1: adjust poly indexes. Needs to happen BEFORE waypoint deletion.
private _polys = _group getVariable ["A3C_UNIT_POLYS", []];

if (_isCurrentWaypoint) then {
	// -- exit possible clearing operations
	{
		_x setVariable ["A3C_CLEARING", false, true];
	} forEach units _group;
};

private _adjustedPolys = [];

{
	private _poly = _x;
	private _polyData = _poly select 0;
	private _polyWaypointIndex = _polyData select 2;

	if (_polyWaypointIndex != _wpIndex) then {
		if (_polyWaypointIndex > _wpIndex) then {
			_polyData set [2, _polyWaypointIndex - 1];
		};

		_adjustedPolys pushBack _poly;
	};
} forEach _polys;

_group setVariable ["A3C_UNIT_POLYS", _adjustedPolys, true];

// -- adjust waypoint action scripts
{
	private _waypointIndex = _x select 1;

	// adjust postAction poly waypoints
	if (_waypointIndex > _wpIndex) then {
		private _waypointToAdjust = waypoints _group select _waypointIndex;
		private _actionScript = waypointStatements _waypointToAdjust select 1;

		if ({[_x, _actionScript] call BIS_fnc_inString} count ["suppression", "ambush", "LANDING", "CAS-STRIKE", "RAPPEL"] > 0) then {
			_actionScript = _actionScript splitString ";"; // -- action script is broken down from string to array

			{
				private _scriptLine = _x;

				if ({[_x, _scriptLine] call BIS_fnc_inString} count ["SUPPRESSION", "AMBUSH", "LANDING", "CAS-STRIKE", "RAPPEL"] > 0) exitWith {
					private _scriptLineParts = _scriptLine splitString "]"; // -- convert string to array
					private _subString = _scriptLineParts select 2;
					private _subStringArray = _subString splitString ",";
					private _id = parseNumber (_subStringArray select 1) - 1; // -- remove 1 for wpi/poly sync

					if (!isNil "_id") then {
						// ~~ ALERT! this is just coz u don't know what is happening after synced wp
						_subStringArray set [1, str _id];

						_subString = "," + (_subStringArray joinString ",");
						_scriptLineParts set [2, _subString];

						_scriptLine = (_scriptLineParts joinString "]") + "]"; // -- re-convert poly-scriptline array to string
						_actionScript set [_forEachIndex, _scriptLine];
					};
				};
			} forEach _actionScript;

			_actionScript = _actionScript joinString ";"; // -- re-convert scriptlines array to string


		};
	};
} forEach waypoints _group;

// -- step 2: remove waypoint

private _isLastWaypoint = {
	_x select 1 > _wpIndex
} count waypoints _group == 0;

A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_group, _wpIndex];
publicVariable "A3C_BLACKLIST_WAYPOINT_EDIT";

deleteWaypoint [_group, _wpIndex];

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;

if (_isCurrentWaypoint) then {
    private _movePos = if (_isLastWaypoint) then {
  	  position _leaderVehicle getPos [10, getDir _leaderVehicle]
    } else {
  	  waypointPosition [_group, currentWaypoint _group]
    };

    [_group, _movePos] call A3C_ai_highCommand_fnc_moveGroupToPosition;
};

// -- refresh gocodes, since deleted waypoint may have been the only one with gocode attached
[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls", 0];
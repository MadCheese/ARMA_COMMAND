// A3C_ai_shared_fnc_reArm_plotAddItem

params ["_unit", "_rearmSource", "_requestedItem"];

private _sourcePosATL = getPosATL _rearmSource;
private _plotData = _unit getVariable "A3C_PLOT";

private _cancelCurrentPlot = true;
private _addWaypoint = true;

{
	private _waypointData = _x;
	private _waypointAction = _waypointData select 2;

	if ((_waypointAction select 0) == "REARM") then {
		private _rearmActionData = _waypointAction select 1;

		if ((count _rearmActionData) > 0) then {
			// Do not cancel if unit already has a REARM action with data.
			_cancelCurrentPlot = false;

			private _existingSource = _rearmActionData select 0;

			if (_existingSource == _rearmSource) then {
				// Do not add waypoint if source is already planned.
				// Just add item to existing item array.
				private _existingItemArray = (((_waypointData select 2) select 1) select 1) select 0;

				if (_requestedItem == "INVENTORY") then {
					_existingItemArray pushBackUnique _requestedItem;
				} else {
					_existingItemArray pushBack _requestedItem;
				};

				_addWaypoint = false;
				_unit setVariable ["A3C_PLOT", _plotData, true];
			};
		};
	};
} forEach _plotData;

private _newWaypointData = [];

if (_cancelCurrentPlot || { _addWaypoint }) then {
	A3C_TEMP_WP_ID_SUB = format ["A3C_Mark_P%1", A3C_MARKER_COUNT];
	A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;

	A3C_MARKERS pushBack A3C_TEMP_WP_ID_SUB;

	_newWaypointData = [
		[_sourcePosATL, _sourcePosATL],                               // Positions
		[A3C_TEMP_WP_ID_SUB, A3C_TEMP_WP_ID_SUB],                     // Markers
		["REARM", [_rearmSource, [[_requestedItem], "", "", false]]], // WP action
		["NONE", "NONE"],                                             // WP condition
		["UP", "UP"],                                                 // WP stances
		[[0, false]],                                                  // WP sync data
		false,                                                         // isWPCompleted
		0,                                                             // combat mode
		-1,                                                            // WP speed
		25,                                                            // WP flying height
		-1,                                                            // WP loop value
		-1.5                                                           // Radius
	];
};

if (_cancelCurrentPlot) then {
	if ((count _plotData) > 0) then {
		[[_unit], true, false] call A3C_AI_Shared_cancelUnitPlot;
	};

	waitUntil {
		(count (_unit getVariable "A3C_PLOT")) == 0
	};

	sleep 0.5;

	[_unit] call A3C_ai_shared_fnc_setDestination;

	_unit setVariable ["A3C_PLOT", [_newWaypointData], true];

	[
		_unit,
		_unit getVariable "A3C_PLOT"
	] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot;

	[_unit] spawn {
		params ["_unit"];

		waitUntil {
			sleep 1;
			(count (_unit getVariable "A3C_PLOT")) == 0
		};

		[_unit] call A3C_ai_squad_fnc_actionResumeDestination;
	};
} else {
	if (_addWaypoint) then {
		_plotData pushBack _newWaypointData;
		_unit setVariable ["A3C_PLOT", _plotData, true];
	};
};
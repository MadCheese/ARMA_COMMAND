// A3C_ui_mapOverlay_fnc_squad_findLastWaypointWithoutPolygon

// Finds the last waypoint before the supplied index that is not a grenade or suppression waypoint.
params ["_unit", "_variableSelector", "_index"];

private _data = if (_variableSelector == 0) then {
	_unit getVariable "A3C_PLOT_TEMP"
} else {
	_unit getVariable "A3C_PLOT"
};

private _result = position _unit;
private _doExit = false;

for "_i" from _index to 0 step -1 do {
	if (_i > 0) then {
		private _entry = _data select (_i - 1);
		private _waypointType = (_entry select 2) select 0;

		if !(_waypointType in ["GRENADE", "SUPPRESSION"]) then {
			_result = (_entry select 0) select 0;
			_doExit = true;
		};
	} else {
		_result = position _unit;
	};

	if (_doExit) exitWith {};
};

_result
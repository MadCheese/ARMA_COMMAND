// A3C_ai_squad_fnc_willSlingLoadAtWaypoint

//-- determines if the vehicle will have a loaded sling object for this waypoint
//-- currently only wp index of -1 is passed, meaning all waypoints are checked
params ["_unit","_wpIndex","_mode"];

private _vehicle = vehicle _unit;
private _isLoaded = !isNull (getSlingLoad _vehicle);

private _currentWpIndex = if (_mode == "SQ") then {
	_unit getVariable "A3C_CURRENTWAYPOINT_INDEX"
} else {
	currentWaypoint (group _unit)
};

private _exit = false;

{
	private _plot = _x;

	{
		_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];

		if ((_wpAction select 0) == "SLINGLOAD") then {
			_isLoaded = !_isLoaded;
		};

		//-- wpIndex == -1: all wp's
		if (!(_wpIndex == -1)) then {
			if (_forEachIndex >= _currentWpIndex) then {
				_exit = true;
			};
		};

		if (_exit) exitWith {};
	} forEach _plot;

	if (_exit) exitWith {};
} forEach [
	_unit getVariable "A3C_PLOT",
	_unit getVariable "A3C_PLOT_TEMP"
];

_isLoaded
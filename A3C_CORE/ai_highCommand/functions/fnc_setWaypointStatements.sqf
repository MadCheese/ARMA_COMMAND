// A3C_ai_highCommand_fnc_setWaypointStatements

params [
	"_waypoint",
	"_timeout",
	"_stance1",
	"_stance2",
	"_speed",
	"_landingType",
	"_isLoop"
];

private _group = _waypoint select 0;
private _index = (_waypoint select 1) select 1;
_waypoint = [_group, _index];

_waypoint setWaypointType "MOVE";
_waypoint setWaypointTimeout [_timeout, _timeout, _timeout];

private _waypointSpeed = if (_speed isEqualType 0) then {
	if (_speed == -1) then {
		"NORMAL"
	} else {
		"LIMITED"
	}
} else {
	"UNCHANGED"
};

private _playerUID = getPlayerUID player;

private _statements = if (_isLoop) then {
	""
} else {
	"[(group this)] call A3C_ai_highCommand_fnc_completeWaypoint;"
};



private _waypointScript = "";

switch (_landingType) do {
	case "DROPOFF": {
		_waypoint setWaypointType "MOVE";

		_statements = _statements + format [
			"
				['%1', this, [['TIMEOUT', 50], 'COMBATLANDING'], 'LINE', currentWaypoint (group this)] call A3C_ai_highCommand_fnc_insertActionWaypoint;
			",
			_playerUID
		];
	};

	case "RAPPEL": {
		_waypoint setWaypointType "MOVE";
	};

	case "PICKUP": {
		_waypoint setWaypointType "MOVE";

		_statements = _statements + format [
			"
				['%1', this, [['TIMEOUT', 50], 'COMBATLANDING'], 'LINE', currentWaypoint (group this)] call A3C_ai_highCommand_fnc_insertActionWaypoint;
			",
			_playerUID
		];
	};

	case "LANDFINAL": {
		_waypoint setWaypointType "MOVE";

		_statements = _statements + format [
			"
				['%1', this, [['TIMEOUT', 50], 'FULL LANDING'], 'LINE', currentWaypoint (group this)] call A3C_ai_highCommand_fnc_insertActionWaypoint;
			",
			_playerUID
		];
	};

	case "CLEARBUILDING": {
		_waypoint setWaypointType "SCRIPTED";

		_waypointScript = format [
			"A3C_CORE\waypointScripts\wpScript_CLEARBUILDING.sqf ['%1',['ARRIVAL','']]",
			_playerUID
		];
	};
};

_waypoint setWaypointScript _waypointScript;

private _currentWaypointStatements = waypointStatements _waypoint;
_currentWaypointStatements params ["_currentCondition", "_currentStatements"];

_waypoint setWaypointStatements [_currentCondition, _currentStatements + _statements];
_waypoint setWaypointSpeed _waypointSpeed;

[_waypoint, "UNCHANGED"] remoteExec ["setWaypointBehaviour", 2]; // -- behaviour for wp has to be executed on server
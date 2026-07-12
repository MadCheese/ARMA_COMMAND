// A3C_ai_shared_fnc_unitRouteIsBrokenFrom
// Checks if a unit has broken away from its route waypoint.
// Meaning: unit has received/entered a movement state that no longer matches the planned waypoint.

params [
	"_unit",
	"_origDest",
	"_data",
	"_cycle",
	["_mode", 0] // Currently unused. 0: before arrival | 1: after arrival / condition checks
];

if (isNull _unit) exitWith {
	true
};

if (_unit getVariable ["A3C_CLEARING", false]) exitWith {
	false
};

private _group = group _unit;

if (!isPlayer (leader _group)) exitWith {
	false
};

if (A3C_BOOL_MOVINGMARKER) exitWith {
	false
};

private "_movePos";

if (_cycle < count _data) then {
	private _cycleData = _data select _cycle;

	if (_cycleData isEqualType [] && { !(_cycleData isEqualTo []) }) then {
		private _moveData = _cycleData select 0;

		if (_moveData isEqualType [] && { !(_moveData isEqualTo []) }) then {
			_movePos = _moveData select 0;
		};
	};
};

if (isNil "_movePos") exitWith {
	true
};

private _vehicle = vehicle _unit;
private _precision = getNumber (
	configFile >> "CfgVehicles" >> typeOf _vehicle >> "precision"
);

private _expectedDestination = expectedDestination _unit;

if (_expectedDestination isEqualTo []) exitWith {
	false
};

_expectedDestination params ["_unitDestination", "_orderType"];

private _orderTypeLower = toLower _orderType;
private _effectiveCommander = effectiveCommander _vehicle;

private _commanderDestination = if (_unit == _effectiveCommander) then {
	_unitDestination
} else {
	private _commanderExpectedDestination = expectedDestination _effectiveCommander;

	if (_commanderExpectedDestination isEqualTo []) then {
		[0, 0, 0]
	} else {
		_commanderExpectedDestination select 0
	}
};

private _isBroken = false;
private _debugReason = "";

// Unit is in formation instead of following the planned route.
if (_orderTypeLower in ["donotplanformation", "formation planned"]) then {
	_isBroken = true;
	_debugReason = "Formation";
};

// Passenger/crew unit follows a non-player AI commander that appears to be in formation.
if (!_isBroken && { _unit != _effectiveCommander }) then {
	if (!isPlayer _effectiveCommander) then {
		if (_commanderDestination distance2D [0, 0, 0] == 0) then {
			_isBroken = true;
			_debugReason = "Commander Snitch Formation";
		};
	};
};

// Unit has a normal planned destination, but it no longer matches the route waypoint.
if (!_isBroken && { _orderTypeLower in ["leader planned", "vehicle planned"] }) then {
	if (_unitDestination distance2D [0, 0, 0] > 0) then {
		if (_unitDestination distance2D _movePos > _precision) then {
			if (_unitDestination distance2D (getPosASL _vehicle) > _precision) then {
				_isBroken = true;
				_debugReason = "destination change post arrival";
			};
		};
	};
};

if (_isBroken && { A3C_DEBUG }) then {
	private _diagMessage = [
		"WAYPOINT DATA",
		lineBreak,
		format ["unit: %1", name _unit],
		lineBreak,
		format ["reason: %1", _debugReason],
		lineBreak,
		format ["position: %1", getPosATL _unit],
		lineBreak,
		format ["orig dest: %1", _origDest],
		lineBreak,
		format ["movePos: %1", _movePos],
		lineBreak,
		format ["current dest: %1", _unitDestination],
		lineBreak,
		format ["distance destination|movePos: %1", _unitDestination distance _movePos],
		lineBreak,
		format ["distance between destinations: %1", _unitDestination distance _origDest],
		lineBreak,
		format ["distance between destination / unit: %1", _unitDestination distance getPosATL _unit],
		lineBreak,
		format ["current destination mode: %1", _orderType],
		lineBreak,
		format ["current command type: %1", currentCommand _unit]
	];

	hint composeText _diagMessage;
};

_isBroken
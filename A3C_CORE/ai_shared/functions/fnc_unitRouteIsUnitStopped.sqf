// A3C_ai_shared_fnc_unitRouteIsUnitStopped
// Checks if a player-led unit route should be considered stopped.

params ["_unit", "_wpPos", "_mode"];

if (isNull _unit) exitWith {
	false
};

private _group = group _unit;

if (!isPlayer (leader _group)) exitWith {
	false
};

if (A3C_BOOL_MOVINGMARKER) exitWith {
	false
};

if !(currentCommand _unit == "STOP") exitWith {
	false
};

private _vehicle = vehicle _unit;
private _effectiveCommander = effectiveCommander _vehicle;
private _unitExpectedDestination = expectedDestination _unit;
private _unitExpectedPos = _unitExpectedDestination select 0;
private _unitExpectedMode = _unitExpectedDestination select 1;

private _isStopped = false;

if (_mode == 0) then {
	// Mode 0: used before unit arrives at waypoint.

	if (_effectiveCommander != _unit) then {
		if (_effectiveCommander == player) then {
			if !(_unitExpectedPos isEqualTo _wpPos) then {
				_isStopped = true;
			};
		} else {
			private _commanderExpectedMode = (expectedDestination _effectiveCommander) select 1;

			if !(_commanderExpectedMode in ["LEADER PLANNED", "VEHICLE PLANNED"]) then {
				_isStopped = true;
			};
		};
	} else {
		if !(_unitExpectedMode in ["LEADER PLANNED", "VEHICLE PLANNED"]) then {
			_isStopped = true;
		};
	};
} else {
	// Mode 1: used after unit arrives at waypoint.

	if !(_unitExpectedMode == "LEADER PLANNED") then {
		if (_effectiveCommander != _unit) then {
			private _commanderExpectedDestination = expectedDestination _effectiveCommander;
			private _commanderExpectedPos = _commanderExpectedDestination select 0;
			private _commanderExpectedMode = _commanderExpectedDestination select 1;

			if !(_commanderExpectedMode == "LEADER PLANNED") then {
				if (
					_commanderExpectedPos distance2D (position (vehicle _effectiveCommander)) <= 10 ||
					{ _commanderExpectedPos distance2D [0, 0, 0] <= 10 }
				) then {
					_isStopped = true;
				};
			};
		} else {
			if (
				_unitExpectedPos distance2D (position _vehicle) <= 10 ||
				{ _unitExpectedPos distance2D [0, 0, 0] <= 10 }
			) then {
				_isStopped = true;
			};
		};
	};
};

if (_isStopped && { A3C_DEBUG }) then {
	systemChat "stop true";
};

_isStopped
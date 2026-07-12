// A3C_ai_shared_fnc_unitRouteIsWpAborted
// Checks if a unit route waypoint should be aborted.

params ["_unit"];

if (isNull _unit) exitWith {
	true
};

if !(alive _unit) exitWith {
	true
};

private _group = group _unit;

// AI-led groups are not managed by this player-command abort logic.
if (!isPlayer (leader _group)) exitWith {
	false
};

private _abortData = _unit getVariable ["A3C_ABORT_Data", [false, false]];

if ((_abortData findIf { _x }) >= 0) exitWith {
	if (A3C_DEBUG) then {
		player commandChat format [
			"aborted, variable: %1 (%2)",
			name _unit,
			_abortData
		];
	};

	true
};

// HC groups abort anything that is not the player's group
// and no longer belongs to the player's current HC group list.
private _abort = false;

if (_group != group player) then {
	if !(_group in A3C_HC_allGroupsClient_Current) then {
		_abort = true;
	};
};

if (_abort && { A3C_DEBUG }) then {
	systemChat "aborted true";
};

_abort
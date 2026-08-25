// A3C_main_fnc_isEngineMovementComplete

// -- Engine movement completion depends on the vehicle's effective commander.
//
// -- AI effectiveCommander:
// -- unitReady is used. A3C testing confirmed that it reliably reports when
// -- normal scripted movement has finished, while moveToCompleted can remain
// -- false even after successful movement UNLESS used in a fsm (eg doMove.fsm)
//
// -- Player effectiveCommander:
// -- moveToCompleted is used instead. A3C testing confirmed that unitReady
// -- remains true in this case and therefore cannot be used to determine
// -- movement completion, while moveToCompleted behaves correctly. Reason unknown but tested.
//
// -- These rules are based on A3C movement testing and intentionally override
// -- the assumption that either command can be used universally.

params ["_unit"];

private _vehicle = vehicle _unit;

private _isEngineMovementComplete = if (!isPlayer (effectiveCommander _vehicle)) then {
	unitReady _unit
} else {
	moveToCompleted _unit
};

_isEngineMovementComplete
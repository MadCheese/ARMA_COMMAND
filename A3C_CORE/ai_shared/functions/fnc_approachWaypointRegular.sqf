// A3C_ai_shared_fnc_approachWaypointRegular

params ["_group", "_movePos"];

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;
private _effectiveCommander = effectiveCommander _leaderVehicle;

if !(_effectiveCommander in units _group) exitWith {};

private _drivers = (units _group - [_leader]) select {
	_x == driver vehicle _x
};

{
	_x enableAI "MOVE";
	_x enableAI "PATH";
	_x enableAI "ANIM";
} forEach units _group;

_drivers doFollow _leader;

private _destination =
	(expectedDestination _effectiveCommander) select 0;

if (
	_destination distance2D _movePos == 0 &&
	{speed _leaderVehicle > 1}
) exitWith {};

[
	_effectiveCommander,
	_movePos
] call A3C_ai_shared_fnc_doMove;
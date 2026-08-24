// A3C_ai_shared_fnc_approachWaypointRegular

params ["_group", "_movePos"];

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;
private _effectiveCommander = effectiveCommander _leaderVehicle;

{
	_x enableAI "MOVE";
	_x enableAI "PATH";
	_x enableAI "ANIM";
} forEach units _group;

private _destination = (expectedDestination _effectiveCommander) select 0;

if (
	_destination distance2D _movePos == 0 &&
	{speed _leaderVehicle > 1}
) exitWith {};

[_group, _movePos] call A3C_ai_highCommand_fnc_moveGroupToPosition;
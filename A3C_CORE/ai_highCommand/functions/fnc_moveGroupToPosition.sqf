// A3C_ai_highCommand_fnc_moveGroupToPosition

/*
	Make a group move towards a position (typically waypoint position).
	Can take in a waypoint [_group, _waypointIndex],
	or a group + position [_group, _position].
*/

private _input = _this;

//-- Ensure the base input is an array with exactly 2 elements
if (
	!(_input isEqualType [])
	|| {count _input != 2}
) exitWith {};

_input params ["_group", "_secondaryArgument"];

private _secondaryArgIsNumber = _secondaryArgument isEqualType 0;


//-- Validate the specific conditions for each argument
if (
	!(_group isEqualType grpNull)                  //-- First arg must be a group
	|| {isNull _group}                             //-- Group must exist
	|| {
		!_secondaryArgIsNumber                     //-- If it's NOT a number...
		&& {
			!(_secondaryArgument isEqualType [])   //-- AND it's NOT an array...
			|| {count _secondaryArgument != 3}     //-- OR it is an array but doesn't have 3 elements
		}
	}
) exitWith {};


//-- Fetch move position
private _movePos = if (_secondaryArgIsNumber) then {
	waypointPosition _input;
} else {
	_secondaryArgument
};

//-- Invalid position: issuing this order would send the group to world origin.
if (_movePos distance2D [0, 0, 0] < 0.1) exitWith {};

private _leader = leader _group;

//-- An empty group has no valid locality target for the remote execution.
if (isNull _leader) exitWith {};

//-- Guard: This function is only intended for AI-led groups.
if (isPlayer _leader) exitWith {};

private _leaderVehicle = objectParent _leader;

//-- If the leader is mounted, the vehicle must be driven by an AI member
//-- of this group. Do not move a group whose leader is being transported
//-- in another group's or a player's vehicle.
if (
	!isNull _leaderVehicle
	&& {
		private _leaderVehicleDriver = driver _leaderVehicle;

		isNull _leaderVehicleDriver
		|| {isPlayer _leaderVehicleDriver}
		|| {!(_leaderVehicleDriver in units _group)}
	}
) exitWith {};



//-- Issue orders where the group leader is local
[
	[_leader, _group, _movePos],
	{
		params ["_leader", "_group", "_movePos"];

		//-- NOTE: _groupDrivers includes foot soldiers
		private _groupDrivers = (units _group) select {_x == driver vehicle _x};
		private _groupVehicles = (_groupDrivers select {!isNull (objectParent _x)}) apply { objectParent _x };

		//-- Step 1: Vehicle movement security
		{
			_x engineOn true;
			_x limitSpeed false;

			if (_x isKindOf "HELICOPTER") then {
				_x land "NONE";
				private _altitude = _x getVariable ["A3C_FLYINHEIGHT", 75];
				_x flyInHeight _altitude;
			};
		} forEach _groupVehicles;

		//-- Step 2: Movement orders

		private _leaderVehicle = vehicle _leader;
		private _leaderVehicleDriver = driver _leaderVehicle;

		//-- Revalidate vehicle control where the movement is actually executed.
		if (
			!isNull objectParent _leader
			&& {
				isNull _leaderVehicleDriver
				|| {isPlayer _leaderVehicleDriver}
				|| {!(_leaderVehicleDriver in units _group)}
			}
		) exitWith {};

		//-- 2.1: Individual leader / leader-vehicle driver order
		if (!isNil "A3C_ai_shared_fnc_doMove") then {
			[_leaderVehicleDriver, _movePos] call A3C_ai_shared_fnc_doMove;
		};

		//-- 2.2 Group-level movement order
		_group move _movePos;

		//-- 2.3 Grunts follow leader
		{
			_x doFollow _leader;
		} forEach (_groupDrivers - [_leader, _leaderVehicleDriver]);
	}
] remoteExec ["BIS_fnc_call", _leader];
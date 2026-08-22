// A3C_ai_shared_fnc_doMove

// -- Issues a movement order for an on-foot unit, vehicle driver, or AI-led group.
// -- Uses doMove for ordinary individual AI movement.
// -- Uses commandMove plus moveTo when the player is the vehicle's effective commander.
// -- Uses a group move order for AI-led groups, preserving High Command group movement.
// -- Called by A3C_ai_shared_fnc_actionExecuteUnitPlot and other movement routines.

params ["_unit", "_destination"];

if (
	isNil '_unit'
	|| {isNull _unit}
	|| {isNil '_destination'}
) exitWith {};

// -- Invalid position: issuing this order would send the unit to world origin.
if (_destination distance2D [0, 0, 0] < 0.1) exitWith {};

private _group = group _unit;
private _leader = leader _group;
private _parentVehicle = objectParent _unit;
private _isOnFoot = isNull _parentVehicle;
private _vehicle = vehicle _unit;
private _driver = driver _vehicle;
private _effectiveCommander = effectiveCommander _vehicle;

// -- A driver may ignore movement orders while the vehicle's effective
// -- commander belongs to another group. Transfer vehicle command to the
// -- driver before issuing the order.
if (
	!_isOnFoot
	&& {!isNull _driver}
	&& {!(_effectiveCommander in units group _driver)}
) then {
	_vehicle setEffectiveCommander _driver;
	_effectiveCommander = effectiveCommander _vehicle;
};

// -- AI-led groups use a group-level movement order. This preserves the
// -- existing High Command behavior; individual doMove orders are not stacked
// -- on top of the group order.
if (!isPlayer _leader) exitWith {
	private _groupDrivers = (units _group) select {
		private _driverVehicle = objectParent _x;

		!isNull _driverVehicle
		&& {_x isEqualTo driver _driverVehicle}
		&& {!isPlayer _x}
	};

	private _groupVehicles = _groupDrivers apply { objectParent _x };

	{
		[_x, true] remoteExec ["engineOn", _x];

		if (_x isKindOf "HELICOPTER") then {
			private _altitude = _x getVariable ["A3C_FLYINHEIGHT", 75];

			_x land "NONE";
			[_x, _altitude] remoteExec ["flyInHeight", _x];
		};
	} forEach _groupVehicles;

	// -- The move command must execute where the AI-led group is local.
	[
		[_group, _destination],
		{
			params ["_group", "_destination"];

			_group move _destination;
		}
	] remoteExec ["BIS_fnc_call", _leader];

	_unit
};

if (isDedicated) exitWith {};
if (_leader isNotEqualTo player) exitWith {};

// -- From here onward, movement is exclusively for an AI unit in the
// -- player's group. Mounted cargo units must not move the vehicle.
if (
	!_isOnFoot
	&& {!(_unit in [_driver, _effectiveCommander])}
) exitWith {};

// -- Defensive initialization for callers that inspect expectedDestination.
// -- This does not issue the actual movement order.
if (expectedDestination _unit isEqualTo []) then {
	_unit setDestination [position _unit, "DoNotPlan", true];
};

_unit enableAI "MOVE";
_unit forceSpeed -1;

if (
	!_isOnFoot
	&& {player in _vehicle}
	&& {_effectiveCommander isNotEqualTo player}
) then {
	// -- Prevent the player from being ejected as a consequence of issuing a
	// -- movement order. The engine switches command back after the player exits.
	_vehicle setEffectiveCommander player;
	_effectiveCommander = effectiveCommander _vehicle;
};

if (
	!_isOnFoot
	&& {_effectiveCommander isEqualTo player}
) then {
	// -- An AI driver controlled by the player did not reliably obey doMove.
	// -- The tested commandMove + moveTo combination worked for both ground
	// -- vehicles and helicopters.
	_driver commandMove _destination;
	_driver moveTo _destination;
} else {
	// -- Default individual AI movement command.
	_unit doMove _destination;
};

_unit

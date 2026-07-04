// A3C_ai_shared_fnc_doMove

// -- Function to make unit move to position.
// -- Issues both doMove and moveTo orders.
// -- Issues commandMove order when player is effectiveCommander of vehicle.
// -- This function is for a single movement and is called by A3C_ai_shared_fnc_actionExecuteUnitPlot and various other routines that require movement.

params ["_unit", "_destination"];



if (_destination distance2D [0,0,0] < 0.1) exitWith {}; // -- invalid position, would make unit go to [0,0,0]

private _group = group _unit;
private _leader = leader _group;
private _vehicle = vehicle _unit;
private _driver = driver _vehicle;
private _effectiveCommander = effectiveCommander _vehicle;

private _commanderNotInDriverGroup = !(_effectiveCommander in units _driver);

// -- if effectiveCommander is not in driver's group, we should transfer command, otherwise driver will not listVehicleSensors
if (_commanderNotInDriverGroup) then {
	_vehicle setEffectiveCommander _driver;
	_effectiveCommander = effectiveCommander _vehicle;
};

if (!isPlayer _leader) exitWith {

	private _groupDrivers = (units _group) select {
		private _vehicle = objectParent _x;
		!isNull _vehicle
		&& {_x == driver _vehicle}
		&& {!isPlayer _x}
	};
	private _groupVehicles = _groupDrivers apply {objectParent _x};
	{
		[_x, true] remoteExec ["engineOn", _x];
		if (_x isKindOf "HELICOPTER") then {
			private _altitude = _x getVariable ["A3C_FLYINHEIGHT", 75];
			_x land "NONE";
			[_x, _altitude] remoteExec ["flyInHeight", _x];
		};
	} foreach _groupVehicles;

	// -- group is AI-commanded. Remotely execute movement command where the effective commander is local.
	[
		[_group, _effectiveCommander, _destination],
		{
			params ["_group", "_effectiveCommander", "_destination"];

			_group move _destination;
			_effectiveCommander doMove _destination;
			_effectiveCommander moveTo _destination;
			_effectiveCommander setDestination [_destination, "LEADER PLANNED", false];
		}
	] remoteExec ["BIS_fnc_call", _effectiveCommander];
};

if (isDedicated) exitWith {};

if (_leader != player) exitWith {};

// -- rest of function is exclusively about player group

if (isNil "_unit") exitWith {};

if (!isNull objectParent _unit && {!(_unit in [_driver, _effectiveCommander])}) exitWith {}; // -- unit is not driver or commander - do not move!

if (expectedDestination _unit isEqualTo []) then {
	_unit setDestination [position _unit, "DoNotPlan", true];
};

_unit enableAI "MOVE";
_unit forceSpeed -1;

if (_effectiveCommander == player) then {
	_unit commandMove _destination;
	_unit moveTo _destination;
} else {
	[_unit, _effectiveCommander, _destination] spawn {
		params ["_unit", "_effectiveCommander", "_destination"];

		_unit doFSM ["A3C_CORE\fsm\doMove.fsm", _destination, [player, _unit]];

		private _expectedDestination = expectedDestination _unit;
		_expectedDestination params ["_expectedDestinationPos", "_expectedDestinationType", "_expectedDestinationForced"];

		_unit setDestination [_destination, _expectedDestinationType, _expectedDestinationForced];

		if !(_effectiveCommander == _unit) then {
			if (group _unit == group player) then {
				private _commanderVehiclePosition = position vehicle _effectiveCommander;

				_effectiveCommander doMove _commanderVehiclePosition;
				_effectiveCommander moveTo _commanderVehiclePosition;

				sleep 0.2;

				_effectiveCommander moveTo _destination;
				_effectiveCommander setDestination [_destination, "LEADER PLANNED", true];
			} else {
				_effectiveCommander doMove _destination;
				_effectiveCommander moveTo _destination;
			};
		};
	};
};

_unit
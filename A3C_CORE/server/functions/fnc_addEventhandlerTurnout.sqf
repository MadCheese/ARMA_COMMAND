// A3C_server_fnc_addEventhandlerTurnout

params ["_vehicle"];

if (isNull _vehicle) exitWith {};

// This function should execute only where the vehicle is local
if !(local _vehicle) exitWith {};

// Guard on the machine where the vehicle is local / EH will exist
private _existingEH = _vehicle getVariable ["A3C_TurnOutEH", -1];
if (_existingEH >= 0) exitWith {
	[_vehicle] remoteExecCall ["A3C_server_fnc_registerTurnOutVehicle", 2];
};

// systemChat format ["%1 (%2) had eventhandler added", _vehicle, groupID (group driver _vehicle)];

private _ehId = _vehicle addEventHandler ["TurnOut", {
	params ["_vehicle", "_unit", "_turret"];
	{
		_x action ["TurnIn", _vehicle];
	} forEach (crew _vehicle);
}];

_vehicle setVariable ["A3C_TurnOutEH", _ehId];
_vehicle setVariable ["A3C_TurnOutEH_Owner", owner _vehicle];

[_vehicle] remoteExecCall ["A3C_server_fnc_registerTurnOutVehicle", 2];


// A3C_server_fnc_removeEventhandlerTurnout

params ["_vehicle"];

if (isNull _vehicle) exitWith {};

// This function should execute only where the vehicle is local
if !(local _vehicle) exitWith {};

private _ehId = _vehicle getVariable ["A3C_TurnOutEH", -1];
private _ehOwner = _vehicle getVariable ["A3C_TurnOutEH_Owner", -1];
private _currentOwner = owner _vehicle;

if (_ehId >= 0) then {
	// systemChat format ["%1 (%2) had eventhandler removed", _vehicle, groupID (group driver _vehicle)];

	if (_ehOwner == _currentOwner) then {
		_vehicle removeEventHandler ["TurnOut", _ehId];
	} else {
		_vehicle removeAllEventHandlers "TurnOut";
	};

	_vehicle setVariable ["A3C_TurnOutEH", nil];
	_vehicle setVariable ["A3C_TurnOutEH_Owner", nil];
};

[_vehicle] remoteExecCall ["A3C_server_fnc_unregisterTurnOutVehicle", 2];


// A3C_main_fnc_getAllGroupsClient
// Gets all HC groups: real, disbanded, and custom HC groups.


//-- 1: Check if player has any tablet
private _inventoryItems = (items player) + (assignedItems player);

private _terminalIndex = _inventoryItems findIf {
	["A3C_Terminal", _x] call BIS_fnc_inString
};

private _hasA3CTerminal = _terminalIndex >= 0;
private _a3cTerminal = "";
private _a3cTerminalSide = sideUnknown;

private _defaultGroups = A3C_HC_DISBANDED select {local _x};

//-- no terminal - only self-disbanded groups are available to player.
if !(_hasA3CTerminal) exitWith {
	_defaultGroups
};

_a3cTerminal = _inventoryItems select _terminalIndex;



_a3cTerminalSide = switch (true) do {
	case ("B_" in _a3cTerminal) : {WEST};
	case ("O_" in _a3cTerminal) : {EAST};
	case ("I_" in _a3cTerminal) : {resistance};
	default {side player} //-- for NO UAV variant
};



private _playerSide = side group player;

//-- player is carrying wrong tablet: No units fetched 
//-- TODO: Either add map hint or decide to allow controlling enemy forces. Latter would require enemy side player in lobby
if (_playerSide != _a3cTerminalSide) exitWith {
	_defaultGroups
};

private _hcArray = A3C_HC_DISBANDED + (A3C_MON_SERVER_checkGroups - A3C_HC_DISBANDED);

_hcArray = _hcArray select {
	side _x == _a3cTerminalSide
	&& {!(_x getVariable ["A3C_HC_BLACKLIST", false])}
	&& {((units _x) findIf { alive _x }) >= 0}
	&& {!(captive leader _x)}
};

// Bug workaround for side UAVs that may appear as civilian.
// Example: CROCUS.

private _civilianUAVsCaptive = allUnitsUAV select {
	captive _x &&
	{
		side _x == civilian &&
		{
			private _uavOwner = (UAVControl _x) select 0;
			private _isAvailable = isNull _uavOwner || { _uavOwner == player };

			_isAvailable &&
			{
				private _uavSideNumber = getNumber (
					configFile >> "CfgVehicles" >> typeOf _x >> "side"
				);

				private _uavSide = [_uavSideNumber] call MCSS_fnc_getSideName;

				_playerSide == _uavSide
			}
		}
	}
};

{
	_x setCaptive false;
} forEach _civilianUAVsCaptive;

//-- If A3C is not running on server, we can only allow local groups (aka disbanded or ZEUS etc)
//-- Reason: HC code would be called on server where functions are not defined. 
//-- Reason for design: If A3C is not running on server, it's likely not intended for players to command all HC groups.
if !(A3C_IsA3CServer) then {
	_hcArray = _hcArray select {local _x};
};

_hcArray
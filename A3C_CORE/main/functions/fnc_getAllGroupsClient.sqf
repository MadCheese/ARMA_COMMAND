// A3C_main_fnc_getAllGroupsClient
// Gets all HC groups: real, disbanded, and custom HC groups.

private _hcArray = A3C_HC_DISBANDED + ((hcAllGroups player) - A3C_HC_DISBANDED);

private _hasA3CTerminal = (((items player) + (assignedItems player)) findIf {
	["A3C_Terminal", _x] call BIS_fnc_inString
}) >= 0;

if (_hasA3CTerminal) then {
	_hcArray = A3C_MON_SERVER_checkGroups;
};

_hcArray = _hcArray select {
	!(_x getVariable ["A3C_HC_BLACKLIST", false]) &&
	{
		((units _x) findIf { alive _x }) >= 0 &&
		{
			!(captive leader _x)
		}
	}
};

if (side player != civilian) then {
	// Only show civilian units if player is civilian.
	// Civilian usage of A3C is not really developed.
	_hcArray = _hcArray select {
		side _x != civilian
	};
} else {
	// Civilian player can see civilian and resistance groups, but not animals.
	_hcArray = _hcArray select {
		!(side _x in [east, west]) &&
		{ !(leader _x isKindOf "Animal") }
	};
};

// Bug workaround for side UAVs that may appear as civilian.
// Example: CROCUS.
private _playerSide = side player;

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
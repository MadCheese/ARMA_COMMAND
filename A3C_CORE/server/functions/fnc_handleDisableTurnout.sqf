
// A3C_server_fnc_handleDisableTurnout

//-- Vehicle turnout handler stuff 


if (!isServer) exitWith {};

if (isNil "A3C_TurnOutEH_Vehicles") then {
	A3C_TurnOutEH_Vehicles = [];
};

{
	private _group = _x;

	if !(isNull _group) then {
		[_group] call A3C_server_fnc_handleDisableTurnout_Group;
	};
} forEach (A3C_MON_SERVER_checkGroups select {!(isPlayer leader _x)});

[] call A3C_server_fnc_cleanupTurnOutVehicles;
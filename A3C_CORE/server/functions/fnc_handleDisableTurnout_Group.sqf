

// A3C_server_fnc_handleDisableTurnout_Group
params ["_group"];

if (isNull _group) exitWith {};

private _activeBehaviours = ["AWARE", "COMBAT", "STEALTH"];

private _leader = leader _group;
if (isNull _leader) exitWith {};

private _behaviour = behaviour _leader;

// Vehicles currently driven by members of this group
private _currentVehicles =
	(units _group)
	select {
		private _veh = objectParent _x;
		!isNull _veh && {_x isEqualTo driver _veh}
	}
	apply { objectParent _x };

_currentVehicles = _currentVehicles arrayIntersect _currentVehicles;

// Keep only vehicles relevant for turnout suppression
_currentVehicles = _currentVehicles select {
	private _className = typeOf _x;
	["Tank", "Wheeled_APC_F"] findIf {_className isKindOf _x} > -1
};

// Vehicles this group is currently managing
private _managedVehicles = _group getVariable ["A3C_ManagedTurnoutVehicles", []];
_managedVehicles = _managedVehicles select {!isNull _x};

if (_behaviour in _activeBehaviours) then {
	// Newly used vehicles: add EH
	private _toAdd = _currentVehicles - _managedVehicles;

	// No longer used vehicles: remove EH
	private _toRemove = _managedVehicles - _currentVehicles;

	{
		[_x] remoteExecCall ["A3C_server_fnc_addEventhandlerTurnout", _x];
	} forEach _toAdd;

	{
		[_x] remoteExecCall ["A3C_server_fnc_removeEventhandlerTurnout", _x];
	} forEach _toRemove;

	_group setVariable ["A3C_ManagedTurnoutVehicles", _currentVehicles];
} else {
	{
		[_x] remoteExecCall ["A3C_server_fnc_removeEventhandlerTurnout", _x];
	} forEach _managedVehicles;

	_group setVariable ["A3C_ManagedTurnoutVehicles", []];
};


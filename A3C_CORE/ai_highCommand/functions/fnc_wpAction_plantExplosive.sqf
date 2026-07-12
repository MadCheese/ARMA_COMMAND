// A3C_AI_HighCommand_fnc_wpAction_plantExplosive

params ["_group", "_magType"];

if (!local _group) exitWith {};

private _currentWaypoint = currentWaypoint _group;
private _waypoint = [_group, _currentWaypoint];
private _groupUnits = units _group;

private _attachToObject = waypointAttachedVehicle _waypoint;



// Some waypoint-attached references may be stored as missionNamespace variable names.
if (_attachToObject isEqualType "") then {
	_attachToObject = missionNamespace getVariable [_attachToObject, objNull];
};



if (
	isNull _attachToObject ||
	{ !alive _attachToObject } ||
	{ _attachToObject in _groupUnits }
) then {
	_attachToObject = objNull;
};

private _detoUnits = [_groupUnits] call A3C_ai_shared_fnc_getUnitsWithExplosives;

if (_detoUnits isEqualTo []) exitWith {};



[
	_detoUnits select 0,
	waypointPosition _waypoint,
	[_attachToObject, _magType]
] spawn A3C_AI_Shared_fnc_wpActionPlantExplosive;
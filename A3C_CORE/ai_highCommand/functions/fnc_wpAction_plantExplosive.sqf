// A3C_AI_HighCommand_fnc_wpAction_plantExplosive

params [
	"_group",
	"_waypointIndex",
	"_magType"
];

if (!local _group) exitWith {};

private _waypointCount = count waypoints _group;

if (
	_waypointIndex < 0 ||
	{_waypointIndex >= _waypointCount}
) exitWith {
	if (A3C_DEBUG) then {
		systemChat format [
			"plant action: invalid waypoint | requested %1 | current %2 | count %3",
			_waypointIndex,
			currentWaypoint _group,
			_waypointCount
		];
	};
};

private _waypoint = [
	_group,
	_waypointIndex
];

private _groupUnits = units _group;

/*
	Capture all waypoint data now, before any other activation
	statement has an opportunity to alter the waypoint list.
*/
private _targetPos = waypointPosition _waypoint;
private _attachToObject = waypointAttachedVehicle _waypoint;

// Some waypoint-attached references may be stored as
// missionNamespace variable names.
if (_attachToObject isEqualType "") then {
	_attachToObject = missionNamespace getVariable [
		_attachToObject,
		objNull
	];
};

if (
	isNull _attachToObject ||
	{!alive _attachToObject} ||
	{_attachToObject in _groupUnits}
) then {
	_attachToObject = objNull;
};

private _detoUnits = [
	_groupUnits
] call A3C_ai_shared_fnc_getUnitsWithExplosives;

if (_detoUnits isEqualTo []) exitWith {
	if (A3C_DEBUG) then {
		systemChat "plant action: no unit with explosives";
	};
};

private _plantUnit = _detoUnits select 0;

if (A3C_DEBUG) then {
	systemChat format [
		"plant action started | requested WP %1 | current WP %2 | WP count %3 | unit %4",
		_waypointIndex,
		currentWaypoint _group,
		count waypoints _group,
		_plantUnit
	];
};



[
	_plantUnit,
	_targetPos,
	[
		_attachToObject,
		_magType
	]
] spawn A3C_AI_Shared_fnc_wpActionPlantExplosive;


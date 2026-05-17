// A3C_ai_highCommand_fnc_getSlingMode

params ["_group"];

private _slingMode = "HOOK";
private _isDetected = false;

private _currentWaypointIndex = currentWaypoint _group;
private _groupWaypoints = waypoints _group;

{
	if ((_x select 1) >= _currentWaypointIndex) then {
		private _waypointType = waypointType _x;

		if (_waypointType == "HOOK") then {
			_slingMode = "UNHOOK";
			_isDetected = true;
		};

		if (_waypointType == "UNHOOK") then {
			_slingMode = "HOOK";
			_isDetected = true;
		};
	};
} forEach _groupWaypoints;

if (
	!_isDetected &&
	{_slingMode == "HOOK"} &&
	{
		{
			_x == driver vehicle _x &&
			{!isNull (getSlingLoad vehicle _x)}
		} count units _group > 0
	}
) then {
	_slingMode = "UNHOOK";
};

_slingMode
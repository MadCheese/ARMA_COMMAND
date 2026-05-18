// A3C_ai_highCommand_fnc_CASpreventAction

params ["_group","_wpIndex","_wpPosition"];

private _leaderVehicle = vehicle (leader _group);

//-- default: leader _leaderVehicle's position
private _posReference = position (_leaderVehicle);

private _activeWaypoints = (waypoints _group) select {_x select 1 >= currentWaypoint _group};


if ( currentWaypoint _group < _wpIndex ) then {
	//-- attempted CAS waypoint is not current waypoint
	private _lastWpIndex = -1;
	{

		if (_x select 1 == _wpIndex) exitWith {
			//-- test the waypointPosition of the prior waypoint before attempted CAS waypoint
			_lastWpIndex = _wpIndex -1; 
			_posReference = waypointPosition [_group, _lastWpIndex];
		};
	} foreach _activeWaypoints;
};

(_posReference distance2D _wpPosition) < 3000


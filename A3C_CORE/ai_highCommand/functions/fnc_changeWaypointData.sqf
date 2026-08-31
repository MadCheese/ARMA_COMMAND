// A3C_ai_highCommand_fnc_changeWaypointData
params ["_group","_waypointIndex","_dataType","_dataReplace"];



private _statements = ["",""];

switch (_dataType) do {
	case ("POSITION") : {
		[_group,_waypointIndex] setWaypointPosition [_dataReplace,0];
	};
	case ("CONDITION") : {
		_statements = waypointStatements [_group,_waypointIndex];
		_statements set [0,_dataReplace];
		[_group,_waypointIndex] setWaypointStatements _statements;
	};
	case ("ACTIONSCRIPT") : {
		_statements = waypointStatements [_group,_waypointIndex];
		_statements set [1,_dataReplace];
		[_group,_waypointIndex] setWaypointStatements _statements;
	};
};			

// A3C_main_fnc_storeTeamColors

{
	private _assignedTeam = assignedTeam _x;
	
	if (_assignedTeam == "") then {_assignedTeam = "MAIN"};

	_x setVariable ["A3C_ASSIGNEDTEAM",_assignedTeam];

} foreach ((units player) - [player]);



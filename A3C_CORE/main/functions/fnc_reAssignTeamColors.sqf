// A3C_main_fnc_reAssignTeamColors

{
	private _colorVar = _x getVariable ["A3C_ASSIGNEDTEAM","NONE"];
	if (_colorVar != "NONE") then {
		_x assignTeam _colorVar;
	};
} foreach ((units player) - [player]);

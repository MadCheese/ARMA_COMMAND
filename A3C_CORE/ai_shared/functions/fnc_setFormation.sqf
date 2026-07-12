// A3C_ai_shared_fnc_setFormation
// Changes group formation according to input. Used by radial formation section.

params ["_formation"];

private _groups = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
	[group player]
} else {
	A3C_RD_UNITS
};

{
	if (!isNull _x) then {
		_x setFormation _formation;
	};
} forEach _groups;

showCommandingMenu "";
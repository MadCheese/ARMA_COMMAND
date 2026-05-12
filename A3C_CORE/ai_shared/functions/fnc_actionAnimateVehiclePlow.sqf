params ["_group", "_mode"];

private _groupVehicles = [_group] call A3C_main_fnc_getGroupVehicles;
private _phase = [1, 0] select (_mode != 0);

{
	if (isClass (configOf _x >> "AnimationSources" >> "movePlow")) then {
		_x animateSource ["movePlow", _phase];
	};
} forEach _groupVehicles;
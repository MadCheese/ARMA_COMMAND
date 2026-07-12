// MCSS_fnc_getObjectVarnames

params ["_object"];

private _names = [];

{
	if ((missionNamespace getVariable [_x, objNull]) isEqualTo _object) then {
		_names pushBack _x;
	};
} forEach allVariables missionNamespace;

_names
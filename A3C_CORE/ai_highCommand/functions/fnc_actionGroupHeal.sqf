params ["_group"];

private _medics = [units _group] call A3C_FINDMEDICS;
private _patients = [_group] call A3C_FINDPATIENTS;

_group setVariable ["A3C_MEDICS", _medics];
_group setVariable ["A3C_MEDICS_LB", _medics];
_group setVariable ["A3C_PATIENTS_LB", _patients];

if (_patients isNotEqualTo [] && {_medics isNotEqualTo []}) then {
	[[_group, 1], A3C_MEDICAL_START] remoteExec ["BIS_fnc_spawn", leader _group];
};
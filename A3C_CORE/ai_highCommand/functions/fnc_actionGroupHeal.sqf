// A3C_ai_highCommand_fnc_actionGroupHeal

params [
	["_group", grpNull, [grpNull]]
];

if (isNull _group) exitWith {};

private _medics = [
	units _group
] call A3C_ai_shared_fnc_medical_findMedics;

private _patients = [
	_group
] call A3C_ai_shared_fnc_medical_findPatients;

_group setVariable [
	"A3C_MEDICS",
	_medics
];

_group setVariable [
	"A3C_MEDICS_LB",
	_medics
];

_group setVariable [
	"A3C_PATIENTS_LB",
	_patients
];

if (
	_patients isNotEqualTo []
	&& {_medics isNotEqualTo []}
) then {
	[
		_group,
		1
	] spawn A3C_ai_shared_fnc_medical_giveHealingOrder;
};
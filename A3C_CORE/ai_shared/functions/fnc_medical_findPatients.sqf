// A3C_ai_shared_fnc_medical_findPatients

params ["_group"];

private _patients = [];

{
	private _referenceUnit = _x;
	private _otherGroupUnits = (units _group) - [_referenceUnit];

	{
		private _patientCandidate = _x;

		if (
			((side _patientCandidate) getFriend (side _referenceUnit)) > 0.6
			&& {[_patientCandidate] call A3C_ai_shared_fnc_medical_isUnitHurt}
		) then {
			_patients pushBackUnique _patientCandidate;
		};
	} forEach _otherGroupUnits;
} forEach units _group;

_group setVariable ["A3C_PATIENTS", _patients];

_patients
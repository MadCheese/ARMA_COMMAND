// A3C_ai_shared_fnc_medical_startAutoHeal

if (isDedicated) exitWith {};

private _selectedAutoHealers = [A3C_RD_UNITS];

while {profileNamespace getVariable "A3C_AUTOMEDIC"} do {
	private _medics = _selectedAutoHealers call A3C_ai_shared_fnc_medical_findMedics;

	(group player) setVariable [
		"A3C_MEDICS",
		_medics
	];

	private _patients = [
		group player
	] call A3C_ai_shared_fnc_medical_findPatients;

	(group player) setVariable [
		"A3C_MEDICS_LB",
		_medics
	];

	(group player) setVariable [
		"A3C_PATIENTS_LB",
		_patients
	];

	if (
		count _patients > 0
		&& {
			count (
				(group player) getVariable [
					"A3C_MEDICS_LB",
					[]
				]
			) > 0
		}
	) then {
		[
			group player,
			1
		] spawn A3C_ai_shared_fnc_medical_giveHealingOrder;

		sleep 2;

		while {true} do {
			if (
				count (
					(group player) getVariable [
						"A3C_PATIENTS_DESIGNATED",
						[]
					]
				) == 0
				&& {
					count (
						(group player) getVariable [
							"A3C_PATIENTS_ASSIGNED",
							[]
						]
					) == 0
				}
			) exitWith {};

			sleep 1;
		};
	};

	sleep 3;
};
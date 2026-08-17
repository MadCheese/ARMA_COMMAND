#include "..\..\ui\radial\radialMenu\dialog_defines.hpp"

// A3C_ai_shared_fnc_medical_giveHealingOrder

// Exit on machines that do not run A3C.
if !(isClass (configFile >> "CfgPatches" >> "A3C_OBJECTS")) exitWith {};

// _mode: 0 = dialog, 1 = script
params ["_group", "_mode"];

private _selectedMedics = _group getVariable ["A3C_MEDICS_LB", []];

if (count _selectedMedics == 0) exitWith {
	systemChat "A3C: Medic selection empty";
};

private _selectedPatients = _group getVariable ["A3C_PATIENTS_LB", []];

if (count _selectedPatients == 0) exitWith {
	systemChat "A3C: No units selected for treatment";
};

_selectedPatients = _selectedPatients - (
	(_group getVariable ["A3C_PATIENTS_DESIGNATED", []])
	+ (_group getVariable ["A3C_PATIENTS_ASSIGNED", []])
);

_group setVariable ["A3C_PATIENTS_LB", _selectedPatients];

if (count _selectedPatients == 0) exitWith {
	systemChat "A3C: Selected Patients are already scheduled for treatment";
};

player groupRadio "SentCmdHealSomeone";

private _healMode = if (
	count (_group getVariable ["A3C_PATIENTS", []]) > 1
) then {
	1
} else {
	0
};

// Update designated treatment targets.
private _designatedPatients = _group getVariable [
	"A3C_PATIENTS_DESIGNATED",
	[]
];

if (
	count (
		(_group getVariable ["A3C_MEDICS_ACTIVE", []])
		+ (_group getVariable ["A3C_MEDICS_LB", []])
	) > 0
) then {
	{
		private _patient = _x;

		if !(
			_patient in (
				_group getVariable ["A3C_PATIENTS_ASSIGNED", []]
			)
		) then {
			_designatedPatients pushBackUnique _patient;
		};
	} forEach _selectedPatients;
};

{
	private _medic = _x;

	if (currentCommand _medic isEqualTo "STOP") then {
		private _wasDesignatedPatient = _medic in _designatedPatients;

		if (_wasDesignatedPatient) then {
			_designatedPatients = _designatedPatients - [_medic];
		};

		private _groupMedics = (group _medic) getVariable [
			"A3C_MEDICS_LB",
			[]
		];

		_groupMedics = _groupMedics - [_medic];

		private _replacementMedic = [
			_medic
		] call A3C_ai_shared_fnc_replaceUnit;

		_groupMedics pushBackUnique _replacementMedic;

		(group _replacementMedic) setVariable [
			"A3C_MEDICS_LB",
			_groupMedics
		];

		if (_wasDesignatedPatient) then {
			_designatedPatients pushBackUnique _replacementMedic;
		};

		sleep 0.1;
	};
} forEach _selectedMedics;

// Refresh the selected medics after replacing stopped units.
_selectedMedics = _group getVariable ["A3C_MEDICS_LB", []];

// Place medics who are also patients first so they select themselves.
_selectedMedics = [
	_selectedMedics,
	[],
	{
		if (_x in _designatedPatients) then {
			1
		} else {
			0
		}
	},
	"DESCEND"
] call BIS_fnc_sortBy;

_group setVariable ["A3C_MEDICS_LB", _selectedMedics];

{
	private _medic = _x;

	if (count _designatedPatients == 0) exitWith {
		private _activeMedics = _group getVariable [
			"A3C_MEDICS_ACTIVE",
			[]
		];

		_activeMedics = _activeMedics - [_medic];

		_group setVariable [
			"A3C_MEDICS_ACTIVE",
			_activeMedics
		];
	};

	_designatedPatients = [
		_designatedPatients,
		[],
		{
			_x distance2D _medic
		},
		"ASCEND"
	] call BIS_fnc_sortBy;

	private _patient = if (_medic in _designatedPatients) then {
		_medic
	} else {
		_designatedPatients select 0
	};

	// The patient is now assigned to this medic.
	_designatedPatients = _designatedPatients - [_patient];

	[
		_medic,
		_patient,
		_healMode,
		expectedDestination _medic,
		_forEachIndex
	] spawn {
		params [
			"_healer",
			"_patient",
			"_healMode",
			"_expectedDestination",
			"_index"
		];

		[_healer] call A3C_ai_shared_fnc_setDestination;

		sleep (1 * _index);

		private _activeMedics = (group _healer) getVariable [
			"A3C_MEDICS_ACTIVE",
			[]
		];

		_activeMedics pushBackUnique _healer;

		(group _healer) setVariable [
			"A3C_MEDICS_ACTIVE",
			_activeMedics
		];

		private _designatedPatients = (group _healer) getVariable [
			"A3C_PATIENTS_DESIGNATED",
			[]
		];

		_designatedPatients = _designatedPatients - [_patient];

		(group _healer) setVariable [
			"A3C_PATIENTS_DESIGNATED",
			_designatedPatients
		];

		if (_healMode == 1) then {
			// Heal all designated patients.
			while {alive _healer} do {
				private _healScript = [
					_healer,
					_patient
				] spawn A3C_ai_shared_fnc_medical_actionHealUnit;

				sleep 0.1;

				if (group _healer == group player) then {
					// Update UI before treatment.
					[] call A3C_ui_radialMenu_fnc_refreshMedical;
				};

				waitUntil {
					scriptDone _healScript
				};

				if (group _healer == group player) then {
					// Update UI after treatment.
					[] call A3C_ui_radialMenu_fnc_refreshMedical;
				};

				if (
					currentCommand _healer isEqualTo "STOP"
					&& {
						!(
							((expectedDestination _healer) select 1)
							isEqualTo "LEADER PLANNED"
						)
					}
				) exitWith {};

				_designatedPatients = (group _healer) getVariable [
					"A3C_PATIENTS_DESIGNATED",
					[]
				];

				private _hasMedicalSupplies = if (A3C_IsAce3) then {
					(
						[
							"@bandage",
							"@iv",
							"tourniquet",
							"splint",
							"morphine",
							"epinephrine"
						] findIf {
							(
								[
									_healer,
									_x
								] call ace_medical_ai_fnc_itemCheck
							) param [0, false]
						}
					) != -1
				} else {
					(
						{
							private _itemName = _x;

							(
								{
									[
										_x,
										_itemName
									] call MCSS_fnc_isInString
								} count [
									"Medi",
									"FirstAid",
									"FAK"
								]
							) > 0
						} count items _healer
					) > 0
				};

				if (!_hasMedicalSupplies) exitWith {
					if (
						count _designatedPatients > 0
						&& {
							count (
								(group _healer) getVariable [
									"A3C_MEDICS_ACTIVE",
									[]
								]
							) == 1
						}
					) then {
						_healer groupChat format [
							"I am out of supplies, can not attend to %1 units",
							count (
								(group _healer) getVariable [
									"A3C_PATIENTS_DESIGNATED",
									[]
								]
							)
						];

						_designatedPatients = [];
					};
				};

				if (count _designatedPatients == 0) exitWith {};

				if (
					{
						_x distance2D _healer < 80
					} count _designatedPatients == 0
				) exitWith {};

				_designatedPatients = [
					_designatedPatients,
					[],
					{
						_x distance2D _healer
					},
					"ASCEND"
				] call BIS_fnc_sortBy;

				_patient = _designatedPatients select 0;
				_designatedPatients = _designatedPatients - [_patient];

				(group _healer) setVariable [
					"A3C_PATIENTS_DESIGNATED",
					_designatedPatients
				];
			};
		} else {
			private _healScript = [
				_healer,
				_patient
			] spawn A3C_ai_shared_fnc_medical_actionHealUnit;

			sleep 0.1;

			if (group _healer == group player) then {
				// Update UI before treatment.
				[] call A3C_ui_radialMenu_fnc_refreshMedical;
			};

			waitUntil {
				scriptDone _healScript
			};

			if (group _healer == group player) then {
				// Update UI after treatment.
				[] call A3C_ui_radialMenu_fnc_refreshMedical;
			};
		};

		[_healer] call A3C_ai_squad_fnc_actionResumeDestination;

		// The last active unit has cancelled; reset the active medic list.
		if (
			count _designatedPatients > 0
			&& {
				(
					(group _healer) getVariable [
						"A3C_MEDICS_ACTIVE",
						[]
					]
				) isEqualTo [_healer]
			}
		) then {
			(group _healer) setVariable [
				"A3C_MEDICS_ACTIVE",
				[]
			];
		};

		private _remainingActiveMedics = (group _healer) getVariable [
			"A3C_MEDICS_ACTIVE",
			[]
		];

		_remainingActiveMedics = _remainingActiveMedics - [_healer];

		(group _healer) setVariable [
			"A3C_MEDICS_ACTIVE",
			_remainingActiveMedics
		];

		// Update the radial medical interface when it is currently open.
		if (
			!isDedicated
			&& {!isNil "A3C_LBR_1"}
			&& {A3C_LBR_1 isEqualTo "MEDICAL"}
		) then {
			if (
				ctrlShown (
					(findDisplay IDD_RADIAL_MENU)
					displayCtrl IDC_RADIAL_EXTENSIONRIGHT_GO_BTN
				)
			) then {
				[] spawn {
					sleep 0.5;
					[] call A3C_ui_radialMenu_fnc_refreshMedical;
				};
			};
		};
	};

	_group setVariable [
		"A3C_PATIENTS_DESIGNATED",
		_designatedPatients
	];

	sleep 0.2;
} forEach _selectedMedics;
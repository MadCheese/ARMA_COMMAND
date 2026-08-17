// A3C_ai_shared_fnc_medical_applyHealing

params ["_healer","_patient"];



if (A3C_IsAce3) exitWith {
	if (
		isNull _healer
		|| {isNull _patient}
		|| {!alive _healer}
		|| {!alive _patient}
	) exitWith {};

	/*
		Remove the patient from another ACE medic's queue if currently
		assigned elsewhere.
	*/
	private _assignedMedic = _patient getVariable [
		"ace_medical_ai_assignedMedic",
		objNull
	];

	if (
		!isNull _assignedMedic
		&& {_assignedMedic != _healer}
	) then {
		private _assignedQueue = _assignedMedic getVariable [
			"ace_medical_ai_healQueue",
			[]
		];

		_assignedMedic setVariable [
			"ace_medical_ai_healQueue",
			_assignedQueue - [_patient]
		];
	};

	_patient setVariable [
		"ace_medical_ai_assignedMedic",
		_healer
	];

	/*
		Put this patient first. ACE will successively perform every
		treatment possible with the healer's training and supplies.
	*/
	private _healQueue = _healer getVariable [
		"ace_medical_ai_healQueue",
		[]
	];

	_healQueue = _healQueue - [_patient];
	_healQueue insert [0, [_patient]];

	_healer setVariable [
		"ace_medical_ai_healQueue",
		_healQueue
	];

	waitUntil {
		sleep 0.25;

		private _healingAborted = _patient getVariable [
			"A3C_AbortHealing",
			false
		];

		private _healerUnconscious = [
			_healer
		] call A3C_ai_shared_fnc_medical_isUnitUnconscious;

		if (
			alive _healer
			&& {alive _patient}
			&& {!_healingAborted}
			&& {!_healerUnconscious}
		) then {
			/*
				Drive the ACE routine ourselves so commanded treatment also
				works when automatic ACE Medical AI is disabled.
			*/
			_healer call ace_medical_ai_fnc_healUnit;
		};

		!alive _healer
		|| {!alive _patient}
		|| {_healingAborted}
		|| {_healerUnconscious}
		|| {
			!(_patient in (
				_healer getVariable [
					"ace_medical_ai_healQueue",
					[]
				]
			))
			&& {
				(
					(
						_healer getVariable [
							"ace_medical_ai_currentTreatment",
							[]
						]
					) param [1, objNull]
				) != _patient
			}
		}
	};

	/*
		Clean up if A3C aborted the action or either unit became unable
		to continue before ACE removed the queue entry itself.
	*/
	private _remainingQueue = _healer getVariable [
		"ace_medical_ai_healQueue",
		[]
	];

	_healer setVariable [
		"ace_medical_ai_healQueue",
		_remainingQueue - [_patient]
	];

	private _currentTreatment = _healer getVariable [
		"ace_medical_ai_currentTreatment",
		[]
	];

	if (
		(_currentTreatment param [1, objNull])
		isEqualTo _patient
	) then {
		_healer setVariable [
			"ace_medical_ai_currentTreatment",
			nil
		];
	};

	_healer forceSpeed -1;
	_patient forceSpeed -1;
};



_patient setUnconscious false;
_patient setDamage 0;



if (
	!(isNil "AIS_System_fnc_ReviveAI")
	&& {[_patient] call A3C_ai_shared_fnc_medical_isUnitUnconscious}
) then {
	[_healer, _patient] spawn AIS_System_fnc_ReviveAI;
};

_patient setVariable ["ais_unconscious", false, true];
_patient setVariable ["ais_stabilized", true, true];
_patient setVariable ["ais_fireDamage", 0];
_patient setVariable ["tcb_ais_agony", false, true];
_patient setVariable ["unit_is_unconscious", false, true];

_patient setVariable ["vn_revive_bleeding", false, true];
_patient setVariable ["vn_revive_incapacitated", false, true];

if !(isNil "f_wound_extraFAK") then {
	_patient setVariable ["f_wound_down", false];
	_patient setVariable ["f_wound_bleeding", false];

	// Other clients do not require this framework-internal blood value.
	_patient setVariable ["f_wound_blood", 100];

	_patient setVariable ["f_wound_dragging", nil];
};

if !(isNil "BTC_REVIVE_TIME_MIN") then {
	_patient setVariable ["r3_unitIsDown", 0, true];
	_patient setVariable ["r3_unitIsStabi", 0, true];
	_patient setVariable ["r3_unitPrivateMedic", objNull, true];
	_patient setVariable ["r3_unitGetRevive", 0, true];
};

if !(isNil "TFFG_fnc_ReviveSuccess") then {
	_patient setVariable ["TFFG_Incapacitated", false, true];
	_patient setVariable ["TFFG_Incapacitated_Dam", false, true];
	_patient setVariable [
		"TFFG_Incapacitated_CanBeDragged",
		false,
		true
	];
};

//-- ANTISTASI healing
if (!isNil "A3A_fnc_actionRevive") then {
	[
		_patient,
		_healer
	] remoteExec [
		"A3A_fnc_actionRevive",
		_healer,
		false
	];
};


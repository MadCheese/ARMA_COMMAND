// A3C_ai_shared_fnc_medical_applyHealing

params ["_patient"];

_patient setDamage 0;

if (
	!(isNil "AIS_System_fnc_ReviveAI")
	&& {[_patient] call A3C_ai_shared_fnc_medical_isUnitUnconscious}
) then {
	[_unit, _patient] spawn AIS_System_fnc_ReviveAI;
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

if (A3C_IsAce3) then {
	[objNull, _patient] call ace_medical_treatment_fnc_fullHeal;
} else {
	_patient setUnconscious false;
};
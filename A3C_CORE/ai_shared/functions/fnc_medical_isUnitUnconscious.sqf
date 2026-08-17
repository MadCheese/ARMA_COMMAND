// A3C_ai_shared_fnc_medical_isUnitUnconscious

params ["_unit"];

//-- ACE exit
if (A3C_IsAce3) exitWith {
	_unit getVariable ["ACE_isUnconscious", false]
};

(lifeState _unit) in ["UNCONSCIOUS", "INCAPACITATED"]
// || {
// 	A3C_IsAce3
// 	&& {
// 		_unit getVariable ["ACE_isUnconscious", false]
// 	}
// }
|| {_unit getVariable ["ais_unconscious", false]}
|| {_unit getVariable ["unit_is_unconscious", false]}
|| {_unit getVariable ["tcb_ais_agony", false]}
|| {
	!(isNil "f_wound_extraFAK")
	&& {
		_unit getVariable ["f_wound_down", false]
	}
}
|| {_unit getVariable ["vn_revive_bleeding", false]}
|| {_unit getVariable ["vn_revive_incapacitated", false]}
|| {
	!(isNil "BTC_REVIVE_TIME_MIN")
	&& {
		(_unit getVariable ["r3_unitIsDown", 0]) > 0
	}
}
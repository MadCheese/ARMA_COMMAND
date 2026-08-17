// A3C_ai_shared_fnc_medical_isUnitHurt

params ["_unit"];

if (A3C_IsAce3) exitWith {
	//-- return ace status
	_unit call ace_medical_ai_fnc_isInjured
};

(_unit isKindOf "MAN")
&& {!(_unit isKindOf "ANIMAL")}
&& {isNull objectParent _unit}
&& {
	(_unit getVariable ["vn_revive_bleeding", false])
	|| {(lifeState _unit) isEqualTo "INJURED"}
	|| {isBleeding _unit}
	|| {!canMove _unit}
	|| {
		!(isNil "f_wound_extraFAK")
		&& {
			(_unit getVariable ["f_wound_bleeding", false])
			|| {_unit getVariable ["f_wound_down", false]}
		}
	}
	|| {
		!(isNil "BTC_REVIVE_TIME_MIN")
		&& {(_unit getVariable ["r3_unitIsDown", 0]) > 0}
	}
	|| {[_unit] call A3C_ai_shared_fnc_medical_isUnitUnconscious}
	// || {
	// 	A3C_IsAce3
	// 	&& {
	// 		{
	// 			_unit getVariable [_x, false]
	// 		} count [
	// 			"ACE_MEDICAL_isBleeding",
	// 			"ACE_MEDICAL_hasPain",
	// 			"ACE_isUnconscious"
	// 		] > 0
	// 	}
	// }
	// || {
	// 	A3C_IsAce3
	// 	&& {
	// 		{
	// 			(_unit getVariable [_x, 0]) > 0
	// 		} count [
	// 			"ACE_MEDICAL_pain",
	// 			"ACE_MEDICAL_hasLostBlood"
	// 		] > 0
	// 	}
	// }
	|| {
		{
			_unit getHitPointDamage _x > 0.2
		} count A3C_HUMAN_HITPOINTS > 0
	}
}
// A3C_main_fnc_shouldMaxHCSkill

/*
	Backward compatibility:

	If the new policy has not been defined but a mission explicitly defines
	the old A3C_isHCSkillMaxed boolean, use that value.
*/
if (
	isNil {
		missionNamespace getVariable "A3C_HCSkillPolicy"
	}
	&& {
		!isNil {
			missionNamespace getVariable "A3C_isHCSkillMaxed"
		}
	}
) exitWith {
	private _legacyValue = missionNamespace getVariable [
		"A3C_isHCSkillMaxed",
		false
	];

	_legacyValue isEqualType true
	&& {
		_legacyValue
	}
};

private _policy = missionNamespace getVariable [
	"A3C_HCSkillPolicy",
	"DEFAULT"
];

if !(_policy isEqualType "") exitWith {
	false
};

switch (toUpper _policy) do {
	case "FORCE_ON": {
		true
	};

	case "FORCE_OFF": {
		false
	};

	case "DEFAULT": {
		if (isServer) then {
			profileNamespace getVariable [
				"A3C_SKILL_VAR",
				false
			]
		} else {
			false
		}
	};

	default {
		false
	};
};
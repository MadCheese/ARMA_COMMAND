// A3C_main_fnc_shouldMaxPlayerGroupSkill

private _policy = missionNamespace getVariable [
	"A3C_PlayerGroupSkillPolicy",
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
		profileNamespace getVariable [
			"A3C_SKILL_VAR",
			false
		]
	};

	default {
		false
	};
};
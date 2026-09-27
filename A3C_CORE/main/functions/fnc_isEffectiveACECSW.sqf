// A3C_main_fnc_isEffectiveACECSW

params [
	["_vehicle", objNull, [objNull]]
];

if (
	isNull _vehicle
	|| {
		!(missionNamespace getVariable [
			"A3C_IsAce3",
			false
		])
	}
) exitWith {
	false
};

private _aceCfg =
	configOf _vehicle
	>> "ACE_CSW";

if (
	!isClass _aceCfg
	|| {
		getNumber (
			_aceCfg
			>> "enabled"
		) != 1
	}
) exitWith {
	false
};

private _modeIndex =
	_vehicle getVariable [
		"ace_csw_assemblyMode",
		3
	];

private _defaultMode =
	missionNamespace getVariable [
		"ace_csw_defaultAssemblyMode",
		false
	];

[
	false,
	true,
	true,
	_defaultMode
] param [
	_modeIndex,
	false
]
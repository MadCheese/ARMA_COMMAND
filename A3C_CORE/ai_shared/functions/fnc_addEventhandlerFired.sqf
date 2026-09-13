// A3C_ai_shared_fnc_addEventhandlerFired

params [
	["_vehicle", objNull, [objNull]],
	["_target", objNull, [objNull]],
	["_gunner", objNull, [objNull]],
	["_weapon", "", [""]],
	["_cycleToken", "", [""]]
];

if (isNull _vehicle) exitWith {
	-1
};

if (!local _vehicle) exitWith {
	-1
};

/*
	Suppression has its own event-handler state.

	A3C_REMOTE_HANDLE belongs to the remote-fire system and must not be
	overwritten or removed by suppression.
*/
private _existingHandlerData =
	_vehicle getVariable [
		"A3C_SUPPRESSION_FIRED_EH",
		[]
	];

if !(_existingHandlerData isEqualTo []) then {
	private _existingHandlerId =
		_existingHandlerData param [
			0,
			-1,
			[0]
		];

	if (_existingHandlerId >= 0) then {
		_vehicle removeEventHandler [
			"Fired",
			_existingHandlerId
		];
	};
};

private _handlerId = _vehicle addEventHandler [
	"Fired",
	{
		params [
			"_vehicle",
			"_weapon",
			"_muzzle",
			"_mode",
			"_ammo",
			"_magazine",
			"_projectile",
			"_gunner"
		];

		private _handlerData =
			_vehicle getVariable [
				"A3C_SUPPRESSION_FIRED_EH",
				[]
			];

		if (_handlerData isEqualTo []) exitWith {};

		private _target =
			_handlerData param [
				1,
				objNull,
				[objNull]
			];

		private _expectedGunner =
			_handlerData param [
				2,
				objNull,
				[objNull]
			];

		private _expectedWeapon =
			_handlerData param [
				3,
				"",
				[""]
			];

		if (
			isNull _target
			|| {isNull _projectile}
		) exitWith {};

		/*
			Do not hijack projectiles fired by another occupant or weapon.
			Empty values preserve compatibility with the current caller.
		*/
		if (
			!isNull _expectedGunner
			&& {_gunner != _expectedGunner}
		) exitWith {};

		if (
			_expectedWeapon != ""
			&& {
				_weapon != _expectedWeapon
				&& {_muzzle != _expectedWeapon}
			}
		) exitWith {};

		/*
			Pass a snapshot of this handler's data. A later suppression
			cycle must not redirect this projectile to its newer target.
		*/
		(
			_this + [
				+_handlerData
			]
		) spawn A3C_ai_shared_fnc_guideProjectileBullet;
	}
];

_vehicle setVariable [
	"A3C_SUPPRESSION_FIRED_EH",
	[
		_handlerId,
		_target,
		_gunner,
		_weapon,
		_cycleToken
	],
	false
];

_handlerId
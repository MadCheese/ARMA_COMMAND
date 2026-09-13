// A3C_ai_shared_fnc_guideProjectileBullet

params [
	["_vehicle", objNull, [objNull]],
	["_weapon", "", [""]],
	["_muzzle", "", [""]],
	["_mode", "", [""]],
	["_ammo", "", [""]],
	["_magazine", "", [""]],
	["_projectile", objNull, [objNull]],
	["_gunner", objNull, [objNull]],
	["_handlerData", [], [[]]]
];

if (
	isNull _vehicle
	|| {isNull _projectile}
) exitWith {};

/*
	Compatibility fallback for callers that do not yet pass a snapshot.
*/
if (_handlerData isEqualTo []) then {
	_handlerData =
		_vehicle getVariable [
			"A3C_SUPPRESSION_FIRED_EH",
			[]
		];
};

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

if (isNull _target) exitWith {};

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

private _velocityMagnitude =
	vectorMagnitude velocity _projectile;

if (_velocityMagnitude <= 0) exitWith {};

private _projectilePositionASL =
	getPosASL _projectile;

private _direction =
	(getPosASL _target) vectorDiff
	_projectilePositionASL;

private _distance =
	vectorMagnitude _direction;

if (_distance <= 0) exitWith {};

private _guidedVelocity =
	_direction vectorMultiply (
		_velocityMagnitude / _distance
	);

private _vectorDirection =
	vectorDir _projectile;

private _vectorUp =
	vectorUp _projectile;

deleteVehicle _projectile;

//-- Delay so the replacement projectile does not damage its launcher.
sleep 0.001;

private _newProjectile =
	_ammo createVehicle (
		(_projectilePositionASL select [0, 2])
			+ [100]
	);

_newProjectile setPosASL _projectilePositionASL;

_newProjectile setVectorDirAndUp [
	_vectorDirection,
	_vectorUp
];

while {alive _newProjectile} do {
	_newProjectile setVelocity _guidedVelocity;
	sleep 0.01;
};
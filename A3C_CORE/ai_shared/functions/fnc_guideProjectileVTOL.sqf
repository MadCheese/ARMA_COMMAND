// A3C_ai_shared_fnc_guideProjectileVTOL

params [
    ["_unit", objNull, [objNull]],
    ["_projectile", objNull, [objNull]],
    ["_lock", 0, [0]],
    ["_target", objNull, [objNull]]
];

if (isNull _projectile) exitWith {};
if !(local _projectile) exitWith {};
if (isNull _target) exitWith {};

private _speed = speed _projectile;
if (_speed <= 0) exitWith {};

private _dir = (getPosASL _target) vectorDiff (getPosASL _projectile);
private _distance = vectorMagnitude _dir;

if (_distance <= 0) exitWith {};

_projectile setDir (_projectile getDir _target);
_projectile setVelocity (_dir vectorMultiply (_speed / _distance));
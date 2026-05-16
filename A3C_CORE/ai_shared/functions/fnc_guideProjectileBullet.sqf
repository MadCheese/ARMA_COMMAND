// A3C_ai_shared_fnc_guideProjectileBullet

params [
    ["_veh", objNull, [objNull]],
    ["_weapon", "", [""]],
    ["_muzzle", "", [""]],
    ["_mode", "", [""]],
    ["_ammo", "", [""]],
    ["_magazine", "", [""]],
    ["_projectile", objNull, [objNull]],
    ["_gunner", objNull, [objNull]]
];

if (isNull _veh) exitWith {};
if (isNull _projectile) exitWith {};

private _remoteHandle = _veh getVariable ["A3C_REMOTE_HANDLE", []];
if (_remoteHandle isEqualTo []) exitWith {};

private _target = _remoteHandle param [1, objNull, [objNull]];
if (isNull _target) exitWith {};

private _vectorDir = vectorDir _projectile;
private _vectorUp = vectorUp _projectile;
private _posASL = getPosASL _projectile;

private _speed = (speed _projectile) / 3.6;
if (_speed <= 0) exitWith {};

private _dir = (getPosASL _target) vectorDiff (getPosASL _veh);
private _distance = vectorMagnitude _dir;
if (_distance <= 0) exitWith {};

private _velocity = _dir vectorMultiply (_speed / _distance);

deleteVehicle _projectile;

/*
    Delay so the replacement bullet does not damage the turret/launcher.
*/
sleep 0.001;

private _newProjectile = _ammo createVehicle ((_posASL select [0, 2]) + [100]);
_newProjectile setPosASL _posASL;
_newProjectile setVectorDirAndUp [_vectorDir, _vectorUp];

while { alive _newProjectile } do {
    _newProjectile setVelocity _velocity;
    sleep 0.01;
};
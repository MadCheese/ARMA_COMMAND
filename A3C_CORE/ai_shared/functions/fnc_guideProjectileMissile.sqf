// A3C_ai_shared_fnc_guideProjectileMissile

params [
    ["_unit", objNull, [objNull]],
    ["_missile", objNull, [objNull]],
    ["_lock", 0, [0]],
    ["_target", objNull, [objNull]],
    ["_target1", objNull, [objNull]]
];

if (isNull _missile) exitWith {};
if !(local _missile) exitWith {};
if (isNull _target) exitWith {};

private _ammo = typeOf _missile;
private _posASL = getPosASL _missile;
private _vectorDir = vectorDir _missile;
private _vectorUp = vectorUp _missile;

private _isInf = (_unit isEqualTo driver vehicle _unit);

/*
    Preserved from original logic:
    - infantry-fired replacement uses config maxSpeed * 3.6
    - vehicle-fired replacement uses current missile speed
*/
private _missileSpeed = if (_isInf) then {
    (getNumber (configFile >> "CfgAmmo" >> _ammo >> "maxSpeed")) * 3.6
} else {
    speed _missile
};

if (_missileSpeed <= 0) exitWith {};

deleteVehicle _missile;

/*
    Delay so replacement projectile does not instantly collide with / damage the launcher.
*/
sleep 0.001;

private _newProjectile = _ammo createVehicle ((_posASL select [0, 2]) + [100]);
_newProjectile setPosASL _posASL;
_newProjectile setVectorDirAndUp [_vectorDir, _vectorUp];

_unit setVariable ["A3C_Replacement_Projectile", _newProjectile, true];

private _targetPosASL = getPosASL _target;
private _startTime = time;
private _velocity = [0, 0, 0];

while { alive _newProjectile } do {
    if (_lock > 0) then {
        if (isNull _target) exitWith {};
        _targetPosASL = getPosASL _target;
    };

    private _dir = _targetPosASL vectorDiff getPosASL _newProjectile;
    private _distance = vectorMagnitude _dir;

    if (_distance > 0) then {
        _velocity = _dir vectorMultiply (_missileSpeed / _distance);

        if (!_isInf) then {
            private _tilt = [_newProjectile, position _target] call MCSS_fnc_TiltTowardsPos;
            _tilt params ["_vDir", "_vUp"];

            _newProjectile setVectorDirAndUp [_vDir, _vUp];
        };

        _newProjectile setVelocity _velocity;
    };

    if (!_isInf && { speed _newProjectile < 1 }) exitWith {
        _newProjectile setDamage 1;
    };

    if (((time - _startTime) > 10) || { _newProjectile distance2D _targetPosASL < 5 }) exitWith {
        /*
            Final nudge towards target - prevents the infamous missile dance.
            Important: original version had no sleep here, which can create a hot loop.
        */
        private _nudgeEnd = time + 2;

        while {
            alive _newProjectile &&
            { time < _nudgeEnd }
        } do {
            _newProjectile setVelocity _velocity;
            sleep 0.01;
        };
    };

    sleep 0.01;
};

{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach [_newProjectile, _target, _target1];
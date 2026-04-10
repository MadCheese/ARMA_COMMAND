A3C_ExactoVTOL = {
    params["_unit", "_missile", "_lock", "_target"];

if !(local _missile)
    exitWith{};

_missile setDir(_missile getDir _target);

private
_ammo = typeOf _missile;
private
_vectorDir = vectorDir _missile;
private
_vectorUp = vectorUp _missile;
private
_posi = getPosASL _missile;

// copytoclipboard str _ammo;
// ammo = "B_20mm_Tracer_Red_VTOL_01_fixed";

//-- default: use missile max speed

_missilespeed = speed _missile; // / 2;

private
_targetPosASL = (getPosASL _target);

private
_tickTime = time;

while
{
    alive _missile
}
do
{
    if (_lock > 0)
        then
        {
            //-- update target position for locked ammo
            _targetPosASL = (getPosASL _target);
        };
    _vd = _targetPosASL vectorDiff(getPosASL _missile);
    _vd params["_dX", "_dY", "_dZ"];
    _d = sqrt(_dx * _dx + _dy * _dy + _dz * _dz);
    _vx = 0;
    _vy = 0;
    _vz = 0;
    if ((_d * _missilespeed) > 0)
        then
        {
            _vx = _dx / _d * _missilespeed;
            _vy = _dy / _d * _missilespeed;
            _vz = _dz / _d * _missilespeed;
        };
    _velNew = [ _vX, _vY, _vZ ];

    // 	_tilt_to = [_missile,position _target] call MCSS_fnc_TiltTowardsPos;
    // 	_tilt_to params ["_vDi","_vUp"];
    // 	_missile setVectorDirAndUp [_vDi,_vUp];

    _timePassed = (time - _tickTime);
    _missile setVelocity _velNew;
    if (speed _missile < 30)
        exitWith
        {
            // "EXIT NOINF 1" remoteExec ["systemChat", 0];
            _missile setDamage 1;
            // systemchat str _timePassed;
        };

    if ('20mm' in(toLower _ammo) && {_missile distance _target < 100})
        exitWith{};
    if (true)
        exitWith{};
};
}
;

A3C_REMOTE_BLACKFISH = {
    /*
        INFO:

        _weaponID - possible values: "GATLING", "CANNON", "AUTOCANNON"

        TURRETS:
        - Main Gunner: [1] >> Gatling and Big Cannon
        - Secondary Gunner: [2] >> Small Cannon //-- BROKEN IN ARMA3!

        FIXED VERSION BY TARO HAS REMOVED THE AUTOCANNON
    */

    params["_vehicle", "_targetPosASL", "_weaponID", "_targetVehicle"];

if !(_weaponID in["GATLING", "CANNON"])
    exitWith
    { //, "AUTOCANNON"
        "INCORRECT WEAPON TYPE" spawn MCSS_fnc_ShortHint;
    };

if !(typeOf _vehicle in["B_T_VTOL_01_armed_F", "B_T_VTOL_01_armed_fixed_F"])
    exitWith
    {
        "SELECTED VEHICLE IS NOT A ARMED BLACKFISH" spawn MCSS_fnc_ShortHint;
    };

// {
// 	_x disableAI "AUTOTARGET";
// } foreach (crew _vehicle);

private
_group = group(driver _vehicle);
private
_wpType = waypointType[_group, currentWaypoint _group];

if (_wpType != "LOITER")
    exitWith
    {
        "VEHICLE IS NOT ON A LOITER WAYPOINT" spawn MCSS_fnc_ShortHint;
    };

private
_unitTurret = [1]; // if (_weaponID in ["GATLING", "CANNON"]) then {[1]} else {[2]};
private
_unit = _vehicle turretUnit[1]; //_unitTurret;

if (isNull _unit || {!alive _unit})
    exitWith
    {
        "GUNSHIP HAS NO GUNNER! TEE HEE IT'S JUST A SHIP." spawn MCSS_fnc_ShortHint;
    };
// private _backupUnit = if (_unitTurret isEqualTo [1]) then {_vehicle turretUnit [2]} else {_vehicle turretUnit [1]};

// systemchat str (_unit == (crew _vehicle) select 2);

private
_targetType = switch (side player) do
{
case (WEST):
{
    "CBA_O_InvisibleTargetAir"
};
case (EAST):
{
    "CBA_B_InvisibleTargetAir"
};
};

// _targetType = "O_Soldier_F";
// _weaponID = "GATLING";

private
_target = _targetType createVehicleLocal[0, 0, 0];
_target setposASL _targetPosASL;
_unit reveal[_target, 4];

if (!isNull _targetVehicle)
    then
    {
        _target attachTo[_targetVehicle, [ 0, 0, 0 ]];
    };

private
_weapon = switch (_weaponID) do
{
case ("GATLING"):
{
    "gatling_20mm_VTOL_01"
};
case ("CANNON"):
{
    "cannon_105mm_VTOL_01"
};
case ("AUTOCANNON"):
{
    "autocannon_40mm_VTOL_01"
};
};

_vehicle selectWeaponTurret[_weapon, _unitTurret];

sleep 1; //-- give time to switch weapon, not sure if needed
if (a3c_debug)
    then
    {
        systemchat format["selected weapon: %1", _weapon];
        systemchat format["current weapon turret: %1", _vehicle currentWeaponTurret _unitTurret];
    };

_fnc_isAimed = {
    params["_vehicle", "_target", "_weapon"];

hintsilent str _this;
_vehicle aimedAtTarget[_target, _weapon] > 0.4
}
;

_unit commandTarget _target;
_unit doTarget _target;
_unit lookAt(position _target);
_unit lookAt _target;

private
_doFire = false;
private
_timer = time;

private
_modes = (getArray(configFile >> "CfgWeapons" >> _weapon >> "modes"));
// systemchat str _modes;
private
_mode = _modes select 0;

_mode = "close";

while
{
    alive _vehicle
}
do
{

private
    _aimed = [ _vehicle, _target, _weapon ] call _fnc_isAimed;

    if ((time - _timer) > 2 || {_aimed})
        exitWith
        {
            if ((time - _timer) < 2)
                then
                {
                    _doFire = true;
                };
        };
    sleep 0.1;
};

if (_doFire)
    then
    {

    private
        _handler = _vehicle addEventhandler
            ["FIRED",
             {
                 params["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
                 // params ["_unit","_missile","_lock","_target","_target1"];
                 _var = _vehicle getvariable "A3C_REMOTE_HANDLE";
                 _var params["_handle", "_target", "_target1", "_snapObject", "_behaviour"];
                 [ _vehicle, _projectile, 0, _target, objNull ] spawn A3C_ExactoVTOL;
             }];
        _vehicle setvariable["A3C_REMOTE_HANDLE", [ _handler, _target, _target, objNull, "" ], true];

    private
        _shellAmount = switch (_weaponID) do
        {
        case ("CANNON"):
        {
            1
        };
        case ("AUTOCANNON"):
        {
            10
        };
        case ("GATLING"):
        {
            20
        };
            default {1};
        };

        if (a3c_debug)
            then
            {
                systemchat format["FIRING: %1, %2 Shells", _weapon, _shellAmount];
            };
        systemchat str[_weapon, _mode];
        for
            "_i" from 1 to _shellAmount do
            {

                _unit forceWeaponFire[_weapon, _mode];
                sleep 0.05;
            private
                _relPosASL = [ _targetPosASL, random 20, random 360 ] call BIS_fnc_RelPos;
                _target setPosASL _relPosASL;
            };
        _vehicle removeEventhandler
            ["FIRED",
             _handler];
    }
else
{
    "VEHICLE COULD NOT FIRE - TRY AGAIN" spawn MCSS_fnc_ShortHint;
};
{
    _x enableAI "AUTOTARGET";
}
foreach (crew _vehicle)
    ;
deletevehicle _target;
}
;

A3C_UI_RADIAL_fnc_RemFire_VTOL_EH1 = {
    systemchat 'oi';
}
;

//
//((crew fish) select 3) forceWeaponFire ["autocannon_40mm_VTOL_01", "close"]

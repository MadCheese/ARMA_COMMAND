// A3C_ai_shared_fnc_orderRemoteLaunch

params ["_unit", "_targetPos", "_weaponGroup"];

if (!isDedicated && { !alive player }) exitWith {};
if (isNull _unit || { !alive _unit }) exitWith {};

if (_unit in A3C_REMFIRE_UNITS_ACTIVE) exitWith {};

if (_unit in (A3C_SUPPRESSION_UNITS_SQ + A3C_SUPPRESSION_UNITS_AI)) exitWith {
    systemChat format [
        "%1 is busy suppressing. Cancel suppression to order remote shots",
        name _unit
    ];
};

private _cfgWeapons = configFile >> "CfgWeapons";
private _cfgAmmo = configFile >> "CfgAmmo";
private _cfgVehicles = configFile >> "CfgVehicles";

private _vehicle = vehicle _unit;

private _primWeap = primaryWeapon _unit;
private _secWeap = secondaryWeapon _unit;
private _primMuzzles = getArray (_cfgWeapons >> _primWeap >> "muzzles");

private _muzzle = "";
private _velo = [0, 0, 0];
private _refPos = [0, 0, 0];

if (_weaponGroup == "FIND") then {
    _weaponGroup = switch (true) do {
        case ([_unit] call A3C_main_fnc_unitHasUGL): {
            "UGLSHOT"
        };
        case ([_unit] call A3C_main_fnc_unitHasAT): {
            "ATSHOT"
        };
        case ((_vehicle isKindOf "TANK") && { _unit == gunner _vehicle }): {
            "TANKSHOT"
        };
        case ((count (getArtilleryAmmo [_vehicle])) > 0): {
            "ARTY"
        };
        case ([_vehicle] call A3C_main_fnc_isStaticMissileLauncher): {
            "STATICSHOT"
        };
        default {
            "EXIT"
        };
    };
};

A3C_REMFIRE_UNITS_ACTIVE pushBackUnique _unit;
publicVariable "A3C_REMFIRE_UNITS_ACTIVE";

A3C_HC_FOCUS_ARTY_POS = ASLToATL _targetPos;

//-- exits after adding unit to active list.

if (_weaponGroup == "EXIT") exitWith {};

_unit setVariable ["A3C_unit_is_Remote_Firing", true, true];

private _dir = _unit getDir _targetPos;
_refPos = _unit getRelPos [((_unit distance _targetPos) - 10), _dir];

private _delete = true;
private _snapObjectStored = A3C_SNAP_OBJECT;

// Function to make sure EH is added on correct machine.
private _addEHFunc = {
    params ["_object", "_func", "_target", "_target1", "_snapObject"];

    if !(local _object) exitWith {};
    if (isNil "_func") exitWith {};

    private _handle = _object addEventHandler [
        "Fired",
        compile format [
            "
                _this spawn %1;
            ",
            _func
        ]
    ];

    _object setVariable [
        "A3C_REMOTE_HANDLE",
        [_handle, _target, _target1, _snapObject, behaviour _object],
        true
    ];
};

// Default: clear remote handle variable.
// Scripts later use this to determine when it is safe to shoot.
{
    _x setVariable ["A3C_REMOTE_HANDLE", [], true];
} forEach [_unit, _vehicle];

_unit disableAI "AUTOTARGET";

switch (_weaponGroup) do {
    case "STATICSHOT": {
        private _staticVehicle = vehicle _unit;

        if ((count magazines _staticVehicle) > 0) then {
            private _lT = switch (true) do {
                case ((side _unit) getFriend WEST < 0.6): {
                    "LaserTargetW"
                };
                case ((side _unit) getFriend EAST < 0.6): {
                    "LaserTargetE"
                };
                default {
                    "LaserTargetC"
                };
            };

            _targetPos set [2, (_targetPos select 2) + 0.5];

            private _target = "A3C_Supression_Target_F" createVehicle _targetPos;
            private _target1 = _lT createVehicleLocal _targetPos;

            [_unit, _target] remoteExec ["doTarget", _unit];
            [_unit, _target] remoteExec ["doWatch", _unit];

            if (_snapObjectStored isKindOf "HOUSE") then {
                _snapObjectStored = objNull;
            };

            private _list = if (!isNull _snapObjectStored) then {
                [_snapObjectStored]
            } else {
                (ASLToATL _targetPos) nearEntities [
                    ["Car", "Motorcycle", "Tank", "Man", "AIR"],
                    10
                ]
            };

            if ((count _list) > 0) then {
                private _h = 0;

                {
                    _x attachTo [(_list select 0), [0, 0, _h]];
                } forEach [_target, _target1];
            } else {
                {
                    _x setPosASL _targetPos;
                    _x enableSimulation false;
                } forEach [_target, _target1];
            };

            private _handlerFunc = {
                params ["_unit"];

                private _ammoType = _this select 4;
                private _missile = _this select 6;
                private _var = _unit getVariable ["A3C_REMOTE_HANDLE", []];

                if (_var isEqualTo []) exitWith {};

                _var params ["_handle", "_target", "_target1", "_snapObject", "_behaviour"];

                if (isNull _missile) then {
                    _missile = nearestObject [position _unit, _ammoType];
                };

                _unit removeEventHandler ["Fired", _handle];
                _unit setVariable ["A3C_unit_is_Remote_Firing", false, true];

                private _lock = getNumber (configFile >> "CfgAmmo" >> (_this select 4) >> "weaponLockSystem");

                private _weaponType = if (_unit isKindOf "STATICWEAPON") then {
                    (getArray (configFile >> "CfgVehicles" >> typeOf _unit >> "Turrets" >> "MainTurret" >> "weapons")) select 0
                } else {
                    (weapons _unit) select 0
                };

                private _reloadTime = getNumber (
                    configFile >> "CfgWeapons" >> _weaponType >> "magazineReloadTime"
                );

                [gunner _unit, _reloadTime] spawn {
                    params ["_gunner", "_reloadTime"];

                    private _timer = time;

                    while { alive _gunner } do {
                        if (time > _timer + _reloadTime) exitWith {};
                        sleep 1;
                    };

                    A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_gunner];
                    publicVariable "A3C_REMFIRE_UNITS_ACTIVE";
                };

                sleep 0.001;

                [_unit, _missile, _lock, _target, _target1] spawn A3C_ai_shared_fnc_guideProjectileMissile;
            };

            while { alive _unit } do {
                _unit doWatch _target;

                if ([position _target, vehicle _unit, 10] call MCSS_fnc_lineOfSightVehicle) exitWith {};

                sleep 1;
            };

            [_staticVehicle, _handlerFunc, _target, _target1, _snapObjectStored] call _addEHFunc;

            sleep 2;

            if (!isNull _unit && { alive _unit }) then {
                waitUntil {
                    count (_staticVehicle getVariable ["A3C_REMOTE_HANDLE", []]) > 0
                };

                _staticVehicle fireAtTarget [objNull];
            } else {
                private _var = _staticVehicle getVariable ["A3C_REMOTE_HANDLE", []];

                if !(_var isEqualTo []) then {
                    _staticVehicle removeEventHandler ["Fired", _var select 0];
                };
            };
        } else {
            systemChat "A3C: Static weapon is out of ammo!";
        };
    };

    case "ARTY": {
        A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
        publicVariable "A3C_REMFIRE_UNITS_ACTIVE";

        with uiNamespace do {
            A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
        };

        ["ARTY"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;
    };

    case "TANKSHOT": {
        private _tankTarget = "A3C_Supression_Target_F" createVehicle (ASLToATL _targetPos);

        _targetPos set [2, (_targetPos select 2) - 0.5];
        _tankTarget setPosASL _targetPos;

        if ({ _snapObjectStored isKindOf _x } count ["TANK", "CAR"] > 0) then {
            [_tankTarget, _snapObjectStored] remoteExec ["disableCollisionWith", _tankTarget];
            [_snapObjectStored, _tankTarget] remoteExec ["disableCollisionWith", _snapObjectStored];

            _tankTarget attachTo [_snapObjectStored, [0, 0, 0]];
        };

        _tankTarget enableSimulation false;

        private _tank = vehicle _unit;

        [_unit, _tankTarget] remoteExec ["lookAt", _unit];
        [_unit, _tankTarget] remoteExec ["doTarget", _unit];

        private _counter = 0;

        while { alive _tank } do {
            if (_tank aimedAtTarget [_tankTarget] == 1) exitWith {
                sleep 3;
            };

            if ([getPosATL _tankTarget, _unit] call MCSS_fnc_lineOfSightVehicle) exitWith {
                sleep 3;
            };

            if (_counter >= 100) exitWith {};

            sleep 0.1;
            _counter = _counter + 1;
        };

        if (_counter < 100) then {
            private _handlerFunc = {
                private _tank = _this select 0;
                private _ammo = _this select 4;
                private _projectile = _this select 6;
                private _effect = getText (configFile >> "CfgAmmo" >> _ammo >> "ExplosionEffects");
                private _var = _tank getVariable ["A3C_REMOTE_HANDLE", []];

                if (_var isEqualTo []) exitWith {};

                _var params ["_handle", "_target", "_newMag", "_snapObject", "_behaviour"];

                _tank removeEventHandler ["Fired", _handle];
                (gunner _tank) setVariable ["A3C_unit_is_Remote_Firing", false, true];

                private _magType = _ammo;

                if (_newMag != "") then {
                    if (
                        !(_effect == "ExplosionEffects") &&
                        { { _snapObject isKindOf _x } count ["TANK", "CAR"] == 0 }
                    ) then {
                        _magType = _newMag;
                    };
                };

                private _guideFnc = {
                    params ["_projectile", "_magType", "_target"];

                    if (!local _projectile) exitWith {};

                    private _vectorDir = vectorDir _projectile;
                    private _vectorUp = vectorUp _projectile;
                    private _posi = getPosASL _projectile;
                    private _vel = velocity _projectile;

                    deleteVehicle _projectile;

                    private _newProjectile = _magType createVehicle _posi;
                    _newProjectile setVectorDirAndUp [_vectorDir, _vectorUp];
                    _newProjectile setPosASL _posi;
                    _newProjectile setVelocity _vel;

                    private _length = sqrt (
                        (_vel select 0) * (_vel select 0) +
                        (_vel select 1) * (_vel select 1) +
                        (_vel select 2) * (_vel select 2)
                    );

                    while { alive _newProjectile && alive _target } do {
                        private _tPos = getPosATL _target;
                        private _dir = (getPosATL _newProjectile) vectorFromTo _tPos;
                        private _vel = [
                            (_dir select 0) * _length,
                            (_dir select 1) * _length,
                            (_dir select 2) * _length
                        ];

                        _newProjectile setVelocity _vel;

                        sleep 0.1;
                    };

                    deleteVehicle _target;
                };

                [_tank, _projectile, 0, _target, _target] spawn A3C_ai_shared_fnc_guideProjectileMissile;

                // Preserved from original:
                // [[_projectile, _magType, _target], _guideFnc] remoteExec ["BIS_fnc_spawn", 0];
            };

            [
                _tank,
                _handlerFunc,
                _tankTarget,
                _tank call A3C_main_fnc_getTankAmmoHE,
                _snapObjectStored
            ] call _addEHFunc;

            waitUntil {
                count (_tank getVariable ["A3C_REMOTE_HANDLE", []]) > 0
            };

            [_tank, ["UseWeapon", _tank, _unit, 0]] remoteExec ["action", _tank];

            sleep (2 + random 2);
        };

        sleep 1;

        if (_delete) then {
            deleteVehicle _tankTarget;
        };

        [_unit, objNull] remoteExec ["lookAt", _unit];

        A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
        publicVariable "A3C_REMFIRE_UNITS_ACTIVE";
    };

    case "ATSHOT": {
        private _lT = switch (true) do {
            case ((side _unit) getFriend WEST < 0.6): {
                "LaserTargetW"
            };
            case ((side _unit) getFriend EAST < 0.6): {
                "LaserTargetE"
            };
            default {
                "LaserTargetC"
            };
        };

        private _target = "A3C_Invisible_Man_F" createVehicleLocal [0, 0, 0];
        private _target1 = _lT createVehicle _targetPos;

        _target enableSimulation false;
        _target setPosASL _targetPos;

        if (_snapObjectStored isKindOf "HOUSE") then {
            _snapObjectStored = objNull;
        };

        private _list = if (!isNull _snapObjectStored) then {
            [_snapObjectStored]
        } else {
            (ASLToATL _targetPos) nearEntities [
                ["Car", "Motorcycle", "Tank", "Man", "AIR"],
                10
            ]
        };

        _unit doTarget _target;
        _unit lookAt _target;
        _unit reveal [_target, 4];

        sleep 1;

        if ((count _list) > 0) then {
            private _h = 0;

            {
                _x attachTo [(_list select 0), [0, 0, _h]];
            } forEach [_target, _target1];
        } else {
            {
                _x setPosASL _targetPos;
                _x enableSimulation false;
            } forEach [_target, _target1];
        };

        [_unit] call A3C_ai_shared_fnc_setDestination;

        private _unitPos = position vehicle _unit;

        _unit doMove _unitPos;
        _unit moveTo _unitPos;

        {
            _unit disableAI _x;
        } forEach ["MOVE", "PATH"];

        sleep 2;

        private _setDir = (_unit modelToWorld (_unit selectionPosition "lefthand")) getDir _targetPos;
        _unit setDir _setDir;

        private _wm = (getArray (_cfgWeapons >> secondaryWeapon _unit >> "modes")) select 0;

        if (_wm == "this") then {
            _wm = secondaryWeapon _unit;
        };

        _unit forceWeaponFire [secondaryWeapon _unit, _wm];

        sleep 2;

        _unit disableAI "ANIM";
        _unit doTarget _target;
        _unit setVariable ["A3C_PAUSE_PLAN", true, true];

        private _handlerFunc = {
            params ["_unit"];

            private _missile = _this select 6;
            private _var = _unit getVariable ["A3C_REMOTE_HANDLE", []];

            if (_var isEqualTo []) exitWith {};

            _var params ["_handle", "_target", "_target1", "_snapObject", "_behaviour"];

            _unit removeEventHandler ["Fired", _handle];
            _unit setVariable ["A3C_unit_is_Remote_Firing", false, true];

            private _lock = getNumber (
                configFile >> "CfgAmmo" >> (_this select 4) >> "weaponLockSystem"
            );

            A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
            publicVariable "A3C_REMFIRE_UNITS_ACTIVE";

            [_unit] call A3C_ai_squad_fnc_actionResumeDestination;

            [_unit, _missile, _lock] spawn {
                params ["_unit", "_missile", "_lock"];

                if (_lock > 0) then {
                    private _hitHandle = _unit addEventHandler [
                        "HandleDamage",
                        {
                            private _unit = _this select 0;
                            private _damage = _this select 2;

                            if ((damage _unit) + _damage >= 0.9) then {
                                [_unit] spawn {
                                    params ["_unit"];

                                    sleep 1;
                                    _unit setDamage 1;
                                };

                                _damage = 0;
                            };

                            _damage
                        }
                    ];

                    _unit setVariable ["A3C_Hit_Handler", _hitHandle, true];
                    _unit setVariable ["A3C_Hit_Value", damage _unit, true];

                    private _launcherAmmo = getArray (
                        configFile >> "CfgWeapons" >> secondaryWeapon _unit >> "magazines"
                    );

                    waitUntil {
                        !isNull (_unit getVariable ["A3C_Replacement_Projectile", objNull])
                    };

                    private _newMissile = _unit getVariable ["A3C_Replacement_Projectile", objNull];

                    waitUntil {
                        !alive _newMissile
                    };

                    _unit removeEventHandler ["HandleDamage", _hitHandle];
                };

                {
                    _unit enableAI _x;
                } forEach ["MOVE", "PATH", "ANIM"];

                _unit setVariable ["A3C_Replacement_Projectile", objNull, true];
            };

            [_unit, _missile, _lock, _target, _target1] spawn A3C_ai_shared_fnc_guideProjectileMissile;
        };

        [_unit, _handlerFunc, _target, _target1, _snapObjectStored] call _addEHFunc;

        sleep 2;

        waitUntil {
            count (_unit getVariable ["A3C_REMOTE_HANDLE", []]) > 0
        };

        private _vari = _unit getVariable ["A3C_REMOTE_HANDLE", []];
        _vari params ["_handle", "_targett", "_target1", "_snapObject", "_behaviour"];

        _unit forceWeaponFire [secondaryWeapon _unit, _wm];
    };

    case "UGLSHOT": {
        private _target = objNull;

        if ((count _primMuzzles) > 1) then {
            _muzzle = _primMuzzles select 1;
            _target = "A3C_Supression_Target_F" createVehicle [0, 0, 0];

            sleep 1;

            _target setPosASL _targetPos;
            _unit reveal [_target, 4];
            _unit doTarget _target;
            _unit doWatch _target;
            _unit lookAt _target;

            sleep 2;

            for "_i" from 0 to 80 do {
                _unit doTarget _target;

                if !(alive _unit) exitWith {};

                if ([_unit, _target] call MCSS_fnc_lineOfFire) exitWith {
                    _unit setVariable ["A3C_PAUSE_PLAN", true, true];

                    _unit setDir (_unit getDir getPosASL _target);

                    _refPos = ASLToATL _targetPos;

                    if ((_refPos select 2) > 2) then {
                        _refPos = [_refPos, 15, _dir] call BIS_fnc_RelPos;
                    };

                    _velo = [_unit, _refPos, 300, 1] call A3C_ai_shared_fnc_gtiGrenade_getLaunchVelocity;
                    _unit setVariable ["A3C_GRENADE_VEL", _velo, true];

                    private _handlerFunc = {
                        private _shooter = _this select 0;
                        private _projectile = _this select 6;
                        private _var = _shooter getVariable ["A3C_REMOTE_HANDLE", []];

                        if (_var isEqualTo []) exitWith {};

                        _var params ["_handle", "_target", "_target1", "_snapObject", "_behaviour"];

                        A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_shooter];
                        publicVariable "A3C_REMFIRE_UNITS_ACTIVE";

                        _shooter setVariable ["A3C_PAUSE_PLAN", false, true];

                        private _vel = _shooter getVariable ["A3C_GRENADE_VEL", velocity _projectile];

                        if (
                            (_this select 2) ==
                            ((getArray (configFile >> "CfgWeapons" >> primaryWeapon _shooter >> "muzzles")) select 1)
                        ) then {
                            _projectile setVelocity _vel;
                        };

                        _shooter removeEventHandler ["Fired", _handle];
                        _shooter setVariable ["A3C_unit_is_Remote_Firing", false, true];
                        _shooter enableAI "ANIM";

                        sleep 1;

                        [_shooter, ["BEHAVIOUR", _behaviour]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
                    };

                    [_unit, _handlerFunc, objNull, objNull, _snapObjectStored] call _addEHFunc;

                    waitUntil {
                        count (_unit getVariable ["A3C_REMOTE_HANDLE", []]) > 0
                    };

                    [_unit, ["BEHAVIOUR", "COMBAT"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;

                    sleep 1;

                    _unit forceWeaponFire [_muzzle, "Single"];
                };

                sleep 0.1;
            };

            hintSilent "";

            deleteVehicle _target;

            _unit doTarget objNull;
            _unit doWatch objNull;
            _unit lookAt objNull;
        };
    };
};

if (_weaponGroup in ["UGLSHOT", "ATSHOT"]) then {
    // Security: if unit does not fire within 10 sec.
    for "_i" from 1 to 10 do {
        sleep 1;

        if !(_unit in A3C_REMFIRE_UNITS_ACTIVE) exitWith {};

        if (_i == 10) exitWith {
            private _var = _unit getVariable ["A3C_REMOTE_HANDLE", []];

            if !(_var isEqualTo []) then {
                _unit removeEventHandler ["Fired", _var select 0];
            };

            _unit setVariable ["A3C_unit_is_Remote_Firing", false, true];

            {
                _unit enableAI _x;
            } forEach ["MOVE", "PATH", "ANIM"];

            _unit setVariable ["A3C_PAUSE_PLAN", false, true];
            _unit setVariable ["A3C_unit_is_Remote_Firing", false, true];

            A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
            publicVariable "A3C_REMFIRE_UNITS_ACTIVE";
        };
    };
};

_unit enableAI "AUTOTARGET";
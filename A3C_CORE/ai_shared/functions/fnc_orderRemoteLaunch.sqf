// A3C_ai_shared_fnc_orderRemoteLaunch

params ["_unit", "_targetPos", "_weaponGroup", ["_snapObject", A3C_SNAP_OBJECT, [objNull]]];

if (!isDedicated && { !alive player }) exitWith {};
if (isNull _unit || { !alive _unit }) exitWith {};

if (_unit in A3C_REMFIRE_UNITS_ACTIVE) exitWith {};
// The replicated list can lag after migration; the unit's token also reserves recovery.
if !((_unit getVariable ["A3C_AT_SHOT", []]) isEqualTo []) exitWith {};

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
        case (
            (_vehicle isKindOf "TANK")
            && {_unit == gunner _vehicle}
            && {
                getNumber (
                    (configOf _vehicle)
                    >> "artilleryScanner"
                ) == 0
            }
        ): {
            "TANKSHOT"
        };
        case (
            _unit == gunner _vehicle
            && {(getArtilleryAmmo [_vehicle]) isNotEqualTo []}
        ): {
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

// The normal caller already dispatches to the owner. Handle a stale locality
// decision before changing any AT state or sampling local AI feature ownership.
if (_weaponGroup == "ATSHOT" && {!local _unit}) exitWith {
    [[_unit, _targetPos, _weaponGroup, _snapObject], A3C_ai_shared_fnc_orderRemoteLaunch] remoteExec ["BIS_fnc_spawn", _unit];
};

A3C_REMFIRE_UNITS_ACTIVE pushBackUnique _unit;
publicVariable "A3C_REMFIRE_UNITS_ACTIVE";

A3C_HC_FOCUS_ARTY_POS = ASLToATL _targetPos;

//-- exits after adding unit to active list.

if (_weaponGroup == "EXIT") exitWith {};

_unit setVariable ["A3C_unit_is_Remote_Firing", true, true];

private _dir = _unit getDir _targetPos;
_refPos = _unit getRelPos [((_unit distance _targetPos) - 10), _dir];

private _snapObjectStored = if (_weaponGroup == "ATSHOT") then {_snapObject} else {A3C_SNAP_OBJECT};

// ATSHOT owns its restoration; other branches retain their existing cleanup.
private _atAIState = [];
if (_weaponGroup == "ATSHOT") then {
    _atAIState = ["MOVE", "PATH", "ANIM", "AUTOTARGET"] apply {_unit checkAIFeature _x};
};

// Function to make sure EH is added on correct machine.
private _addEHFunc = {
    params ["_object", "_func", "_target", "_target1", "_snapObject", ["_scheduled", true]];

    if !(local _object) exitWith {};
    if (isNil "_func") exitWith {};

    private _handle = _object addEventHandler [
        "Fired",
        compile format [
            "
                _this %2 %1;
            ",
            _func,
            if (_scheduled) then {"spawn"} else {"call"}
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

                private _missile = _this select 6;
                private _var = _unit getVariable ["A3C_REMOTE_HANDLE", []];

                if (_var isEqualTo []) exitWith {};

                _var params ["_handle", "_target", "_target1", "_snapObject", "_behaviour"];

                _unit removeEventHandler ["Fired", _handle];
                _unit setVariable ["A3C_unit_is_Remote_Firing", false, true];

                [_missile, _target, "MISSILE"] call A3C_ai_shared_fnc_guideProjectileMissile;

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

                [_missile, _target, _target1] spawn {
                    params ["_missile", "_target", "_target1"];
                    waitUntil {sleep 0.01; isNull _missile || {!alive _missile}};
                    {if (!isNull _x) then {deleteVehicle _x;};} forEach [_target, _target1];
                };
            };

            while { alive _unit } do {
                _unit doWatch _target;

                if ([position _target, vehicle _unit, 10] call MCSS_fnc_lineOfSightVehicle) exitWith {};

                sleep 1;
            };

            [_staticVehicle, _handlerFunc, _target, _target1, _snapObjectStored, false] call _addEHFunc;

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
                private _projectile = _this select 6;
                private _var = _tank getVariable ["A3C_REMOTE_HANDLE", []];

                if (_var isEqualTo []) exitWith {};

                _var params ["_handle", "_target", "_target1", "_snapObject", "_behaviour"];

                _tank removeEventHandler ["Fired", _handle];
                (gunner _tank) setVariable ["A3C_unit_is_Remote_Firing", false, true];
                _target setVariable ["A3C_Remote_Projectile_Captured", !isNull _projectile];

                [_projectile, _target, "DIRECT"] call A3C_ai_shared_fnc_guideProjectileMissile;
                [_projectile, _target] spawn {
                    params ["_projectile", "_target"];
                    waitUntil {sleep 0.01; isNull _projectile || {!alive _projectile}};
                    if (!isNull _target) then {deleteVehicle _target;};
                };
            };

            [
                _tank,
                _handlerFunc,
                _tankTarget,
                objNull,
                _snapObjectStored,
                false
            ] call _addEHFunc;

            private _handlerDeadline = time + 10;
            waitUntil {
                count (_tank getVariable ["A3C_REMOTE_HANDLE", []]) > 0
                || {!alive _tank}
                || {time >= _handlerDeadline}
            };

            if (count (_tank getVariable ["A3C_REMOTE_HANDLE", []]) > 0 && {alive _tank}) then {
                [_tank, ["UseWeapon", _tank, _unit, 0]] remoteExec ["action", _tank];
            };

            sleep (2 + random 2);
        };

        sleep 1;

        // Close the capture window before cleaning an unfired shot's proxy.
        private _tankHandle = _tank getVariable ["A3C_REMOTE_HANDLE", []];
        if !(_tankHandle isEqualTo []) then {
            _tank removeEventHandler ["Fired", _tankHandle select 0];
        };
        if !(_tankTarget getVariable ["A3C_Remote_Projectile_Captured", false]) then {
            deleteVehicle _tankTarget;
        };

        [_unit, objNull] remoteExec ["lookAt", _unit];

        A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
        publicVariable "A3C_REMFIRE_UNITS_ACTIVE";
    };

    case "ATSHOT": {
        private _originalStance = stance _unit;
        private _originalUnitPos = unitPos _unit;
        private _originalPause = _unit getVariable ["A3C_PAUSE_PLAN", false];
        private _launcher = secondaryWeapon _unit;
        private _token = format ["%1:%2:%3", clientOwner, diag_tickTime, _unit];
        private _firedKey = format ["A3C_AT_SHOT_FIRED_%1", _token];
        // Separate context leaves the public five-element A3C_REMOTE_HANDLE intact.
        // Reserve the unit until recovery finishes, not just until Fired arrives.
        _unit setVariable ["A3C_AT_SHOT", [_token, _launcher, false, false], true];
        private _destinationSaved = false;
        private _savedDestination = [];
        private _stanceChanged = false;
        private _targetingChanged = false;
        private _atHandle = -1;
        private _atRemoteHandle = [];
        private _aceTarget = objNull;
        private _aceTargetChanged = false;
        private _aceTargetDefined = false;
        private _aceTargetPrevious = objNull;
        private _valid = {
            !isNull _unit && {alive _unit} && {local _unit}
            && {((_unit getVariable ["A3C_AT_SHOT", []]) param [0, ""]) == _token}
            && {_unit getVariable ["A3C_unit_is_Remote_Firing", false]}
            && {_unit in A3C_REMFIRE_UNITS_ACTIVE}
            && {secondaryWeapon _unit == _launcher}
            && {!isNull _target}
        };

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
        _target setVariable ["A3C_AT_SHOT_TOKEN", _token];

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

        // All preparation failures return to the single restoration path below.
        private _prepare = {
            if !(call _valid) exitWith {};
            if (_launcher == "" || {!(_atAIState select 2)}) exitWith {};
            if (_unit ammo _launcher <= 0) exitWith {};

            private _crouchReady = _originalStance != "PRONE";
            if (_originalStance == "PRONE") then {
                // Direct prone shouldering caused standing/prone transitions and failed
                // shots in testing. Finish an actual crouched idle before shouldering.
                _stanceChanged = true;
                _unit setUnitPos "MIDDLE";
                private _deadline = time + 10;
                private _stableSince = -1;
                waitUntil {
                    sleep 0.1;
                    private _anim = toLower animationState _unit;
                    private _idle = stance _unit == "CROUCH"
                        && {((_anim find "aidlpknl") == 0 || {(_anim find "amovpknlmstp") == 0})}
                        && {(_anim find "_amov") < 0} && {(_anim find "_end") < 0};
                    if (_idle) then {
                        if (_stableSince < 0) then {_stableSince = time;};
                    } else {_stableSince = -1;};
                    !(call _valid) || {time >= _deadline}
                        || {_stableSince >= 0 && {time - _stableSince >= 0.3}}
                };
                _crouchReady = (call _valid) && {_stableSince >= 0} && {time - _stableSince >= 0.3};
            };
            if (!_crouchReady) exitWith {};

            _targetingChanged = true;
            _unit doTarget _target;
            _unit lookAt _target;
            _unit reveal [_target, 4];

            sleep 1;

            if ((count _list) > 0) then {
                {
                    if (!isNull _x) then {_x attachTo [(_list select 0), [0, 0, 0]];};
                } forEach [_target, _target1];
            } else {
                {
                    if (!isNull _x) then {
                        _x setPosASL _targetPos;
                        _x enableSimulation false;
                    };
                } forEach [_target, _target1];
            };

            if !(call _valid) exitWith {};
            _savedDestination = [_unit] call A3C_ai_shared_fnc_setDestination;
            _destinationSaved = count _savedDestination > 1;

            private _unitPos = position vehicle _unit;

            _unit doMove _unitPos;
            _unit moveTo _unitPos;

            {
                _unit disableAI _x;
            } forEach ["MOVE", "PATH"];

            sleep 2;

            if !(call _valid) exitWith {};
            private _spawnBehaviour = scriptNull;
            private _rotationHandle = -1;
            private _rotationKey = format ["A3C_AT_ROTATION_%1", _token];
            isNil {
                if !(call _valid) exitWith {};
                // Stop on the installing machine before the shared rotation helper
                // can forward itself and outlive this order on a different owner.
                _spawnBehaviour = [_unit,_targetPos] spawn A3C_ai_shared_fnc_rotateVehicleTowardsPos;
                _unit setVariable [_rotationKey, _spawnBehaviour];
                _rotationHandle = _unit addEventHandler ["Local", compile format [
                    "if !(_this select 1) then {private _worker = (_this select 0) getVariable [%1, scriptNull]; if (!scriptDone _worker) then {terminate _worker;};};",
                    str _rotationKey
                ]];
            };
            private _rotationDeadline = time + 11;
            waitUntil {sleep 0.1; scriptDone _spawnBehaviour || {!(call _valid)} || {time >= _rotationDeadline}};
            if (!scriptDone _spawnBehaviour) then {terminate _spawnBehaviour;};
            if (_rotationHandle >= 0) then {_unit removeEventHandler ["Local", _rotationHandle];};
            _unit setVariable [_rotationKey, nil];
            // The helper already owns its rotation tolerance and timeout. Its
            // completion was sufficient in the validated sequence.
            if (!(call _valid) || {stance _unit == "PRONE"}) exitWith {};

            // Explicitly shoulder without consuming ammo or producing a projectile.
            _unit playAction "SecondaryWeapon";
            // Retain the tested 2 seconds. Freezing at final AnimDone failed in tests.
            sleep 2;
            if !(call _valid) exitWith {};
            // Without this hold the AI tends to put the launcher away again.
            _unit disableAI "ANIM";
            _unit doTarget _target;
            _unit setVariable ["A3C_PAUSE_PLAN", true, true];

            private _handlerFunc = {
                params ["_unit", "_weapon"];

                private _missile = _this select 6;
                private _var = _unit getVariable ["A3C_REMOTE_HANDLE", []];
                private _context = _unit getVariable ["A3C_AT_SHOT", []];

                if (count _context != 4 || {count _var != 5}) exitWith {};
                // Ignore rifle fire, premature events and duplicate launcher events.
                if (_weapon != (_context select 1) || {!(_context select 2)} || {_context select 3}) exitWith {};

                _var params ["_handle", "_target", "_target1"];

                if (!local _unit || {_handle != _thisEventHandler}
                    || {(_target getVariable ["A3C_AT_SHOT_TOKEN", ""]) != (_context select 0)}) exitWith {};
                _unit removeEventHandler ["Fired", _thisEventHandler];
                // Local, token-specific evidence survives proxy deletion and a
                // later order replacing the public context before cleanup runs.
                _unit setVariable [format ["A3C_AT_SHOT_FIRED_%1", _context select 0], true];
                _context set [3, true];
                _unit setVariable ["A3C_AT_SHOT", _context, true];
                _unit setVariable ["A3C_unit_is_Remote_Firing", false, true];

                private _lock = getNumber (
                    configFile >> "CfgAmmo" >> (_this select 4) >> "weaponLockSystem"
                );

                // The local proxy is already token-checked above. Compiled handlers
                // cannot capture preparation's private variables. Freeze the owner
                // before firing; never start A3C steering during an ACE flight.
                if !(_target getVariable ["A3C_AT_SHOT_ACE_GUIDANCE", false]) then {
                    private _nativeAccepted = false;
                    // Gate on loaded ACE, not its AI setting or the medical-only
                    // A3C_IsAce3 flag. All ACE-loaded guidance paths stay unchanged.
                    private _aceLoaded = isClass (configFile >> "CfgPatches" >> "ace_main")
                        || {isClass (configFile >> "CfgPatches" >> "ace_missileguidance")}
                        || {!isNil "ace_missileguidance_fnc_onFired"};
                    if (!_aceLoaded) then {
                        private _realTarget = attachedTo _target;
                        private _snapObject = _var select 3;
                        private _ammo = _this select 4;
                        private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
                        private _sensors = _ammoCfg >> "Components" >> "SensorsManagerComponent" >> "Components";
                        // Require configured object guidance, not just MissileBase
                        // ancestry, weaponLockSystem or manualControl. Sensor config
                        // can supersede legacy irLock; laser/manual-only ammo falls back.
                        private _objectSensor = (configProperties [_sensors, "isClass _x", true]) findIf {
                            getText (_x >> "componentType") in [
                                "IRSensorComponent", "VisualSensorComponent",
                                "ActiveRadarSensorComponent", "PassiveRadarSensorComponent"
                            ]
                        };
                        private _objectGuidance = if (isClass _sensors) then {
                            _objectSensor >= 0
                        } else {getNumber (_ammoCfg >> "irLock") == 1};
                        private _nativeEligible = !isNull _missile && {alive _missile} && {local _missile}
                            && {isClass _ammoCfg && {typeOf _missile == _ammo}}
                            && {toLower getText (_ammoCfg >> "simulation") == "shotmissile"}
                            && {getNumber (_ammoCfg >> "maneuvrability") > 0}
                            && {_objectGuidance}
                            && {!isNull _snapObject && {_realTarget isEqualTo _snapObject}}
                            && {!isNull _realTarget && {alive _realTarget} && {_realTarget != _unit}}
                            && {!(_realTarget isKindOf "A3C_Invisible_Man_F")}
                            && {!(_realTarget isKindOf "A3C_Supression_Target_F")}
                            && {!(_realTarget isKindOf "LaserTarget")};
                        private _nativeStatus = "ineligible";
                        if (_nativeEligible) then {
                            // One synchronous attempt, with no worker or trajectory writes.
                            private _assigned = _missile setMissileTarget [_realTarget, true];
                            _nativeAccepted = _assigned && {!isNull _realTarget}
                                && {(missileTarget _missile) isEqualTo _realTarget};
                            _nativeStatus = if (_nativeAccepted) then {"accepted"} else {"rejected"};
                        };
                        if (missionNamespace getVariable ["A3C_DEBUG", false]) then {
                            diag_log format [
                                "[A3C] ATSHOT %1: native targeting %2; %3 (ammo=%4, target=%5)",
                                _context select 0, _nativeStatus,
                                if (_nativeAccepted) then {"engine guidance owns projectile"} else {"A3C fallback used"},
                                _ammo, _realTarget
                            ];
                        };
                    };

                    if (!_nativeAccepted) then {
                        private _policy = "MISSILE";
                        private _aimObject = attachedTo _target;
                        private _attackProfile = getText (
                            configFile >> "CfgWeapons" >> (_this select 1) >> (_this select 3)
                            >> "ace_missileguidance_attackProfile"
                        );
                        if (
                            _attackProfile == "ace_nlaw_overflyTopAttack"
                            && {{_aimObject isKindOf _x} count ["Tank", "Car", "Air"] > 0}
                        ) then {
                            _policy = "OVERFLY";
                        };

                        [_missile, _target, _policy] call A3C_ai_shared_fnc_guideProjectileMissile;
                    };
                };

                // Protection and proxy lifetime belong to this projectile. Neither
                // worker restores unit AI, so an old missile cannot alter a new order.
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

                        waitUntil {sleep 0.01; isNull _missile || {!alive _missile}};

                        _unit removeEventHandler ["HandleDamage", _hitHandle];
                    };
                };

                [_missile, _target, _target1] spawn {
                    params ["_missile", "_target", "_target1"];
                    waitUntil {sleep 0.01; isNull _missile || {!alive _missile}};
                    {if (!isNull _x) then {deleteVehicle _x;};} forEach [_target, _target1];
                };
            };

            // Bind this order's token into the installed code, rather than letting an
            // old handler read a later order's context after cancellation/reentrancy.
            _handlerFunc = compile format [
                "if ((((_this select 0) getVariable ['A3C_AT_SHOT', []]) param [0, '']) != %1) exitWith {}; _this call %2;",
                str _token, _handlerFunc
            ];
            // Synchronous capture must be ready before the only firing invocation.
            isNil {
                if !(call _valid) exitWith {};
                [_unit, _handlerFunc, _target, _target1, _snapObjectStored, false] call _addEHFunc;
                _atRemoteHandle = +(_unit getVariable ["A3C_REMOTE_HANDLE", []]);
                _atHandle = _atRemoteHandle param [0, -1];
            };

            // Retain the second tested 2-second hold; do not gate on currentWeapon:
            // successful tests still reported the rifle immediately before firing.
            sleep 2;

            if !(call _valid) exitWith {};
            private _vari = _unit getVariable ["A3C_REMOTE_HANDLE", []];
            if !(_vari isEqualTo _atRemoteHandle) exitWith {};
            if (_atHandle < 0) exitWith {};
            private _weaponCfg = _cfgWeapons >> _launcher;
            private _modes = getArray (_weaponCfg >> "modes");
            if (_modes isEqualTo [] || {_unit ammo _launcher <= 0}) exitWith {};
            private _fireMode = _modes select 0;
            private _aimObject = attachedTo _target;
            if ({_aimObject isKindOf _x} count ["Tank", "Car", "Air"] > 0) then {
                private _overflyIndex = _modes findIf {
                    getText (_weaponCfg >> _x >> "ace_missileguidance_attackProfile")
                    == "ace_nlaw_overflyTopAttack"
                };
                if (_overflyIndex >= 0) then {
                    _fireMode = _modes select _overflyIndex;
                };
            };

            if (_fireMode == "this") then {_fireMode = _launcher;};
            if (_fireMode != _launcher && {!isClass (_weaponCfg >> _fireMode)}) exitWith {};
            // Open the capture window and issue the command without a scheduler yield.
            isNil {
                if !(call _valid) exitWith {};
                if !((_unit getVariable ["A3C_REMOTE_HANDLE", []]) isEqualTo _atRemoteHandle) exitWith {};
                // Query the loaded launcher, even when currentWeapon reports a rifle.
                private _launcherState = _unit weaponState _launcher;
                private _magazine = _launcherState param [3, ""];
                private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
                private _ammoCfg = _cfgAmmo >> _ammo;
                private _guidanceCfg = _ammoCfg >> "ace_missileguidance";
                _aceTarget = attachedTo _target;
                private _aceGuidance = !isNil "ace_missileguidance_fnc_onFired"
                    && {!isNil "ace_missileguidance_fnc_onFiredGetArgs"}
                    && {!isNil "ace_missileguidance_fnc_guidancePFH"}
                    && {!isNil "CBA_fnc_addPerFrameHandler"}
                    && {(missionNamespace getVariable ["ace_missileguidance_enabled", 0]) == 2}
                    && {(_launcherState param [0, ""]) == _launcher}
                    && {(_launcherState param [4, 0]) > 0}
                    && {isClass _guidanceCfg}
                    && {getNumber (_guidanceCfg >> "enabled") == 1}
                    // ACE onFired requires an explicit subclass, not just inheritance.
                    && {!(("configName _x == 'ace_missileguidance'" configClasses _ammoCfg) isEqualTo [])}
                    // Do not promote the legacy nearby-object search to an ACE lock.
                    && {!isNull _snapObjectStored && {_aceTarget isEqualTo _snapObjectStored}}
                    && {!isNull _aceTarget && {alive _aceTarget} && {_aceTarget != _unit}}
                    && {_aceTarget isKindOf "AllVehicles"}
                    && {!(_aceTarget isKindOf "A3C_Invisible_Man_F")}
                    && {!(_aceTarget isKindOf "A3C_Supression_Target_F")}
                    && {!(_aceTarget isKindOf "LaserTarget")};
                if (_aceGuidance) then {
                    // Honor configured target restrictions and the effective seeker.
                    // Laser, GPS and sight/manual seekers need a different workflow;
                    // ATSHOT recovers the shooter before a long missile flight ends.
                    private _lockableTypes = getArray (_guidanceCfg >> "lockableTypes");
                    private _seeker = _unit getVariable ["ace_missileguidance_seekerType", ""];
                    if !(_seeker in getArray (_guidanceCfg >> "seekerTypes")) then {
                        _seeker = getText (_guidanceCfg >> "defaultSeekerType");
                    };
                    _aceGuidance = _seeker != "" && {!(_seeker in ["SALH", "GPS", "SACLOS", "MCLOS"])}
                        && {_lockableTypes isEqualTo [] || {{_aceTarget isKindOf _x} count _lockableTypes > 0}};
                };
                if (_aceGuidance) then {
                    if (getNumber (_guidanceCfg >> "useModeForAttackProfile") == 1
                        && {"JAV_TOP" in getArray (_guidanceCfg >> "attackProfiles")}
                        && {{_aceTarget isKindOf _x} count ["Tank", "Wheeled_APC_F"] > 0}) then {
                        private _topDownIndex = _modes findIf {
                            isClass (_weaponCfg >> _x)
                            && {getText (_weaponCfg >> _x >> "ace_missileguidance_attackProfile") == "JAV_TOP"}
                        };
                        if (_topDownIndex >= 0) then {_fireMode = _modes select _topDownIndex;};
                    };
                    _aceTargetDefined = !isNil {_unit getVariable "ace_missileguidance_target"};
                    if (_aceTargetDefined) then {
                        _aceTargetPrevious = _unit getVariable "ace_missileguidance_target";
                    };
                    _aceTargetChanged = true;
                    _unit setVariable ["ace_missileguidance_target", _aceTarget, false];
                };
                // Native mode selection is predictive only. Fired still validates
                // the actual projectile and lock, and owns the unchanged fallback.
                private _aceLoaded = isClass (configFile >> "CfgPatches" >> "ace_main")
                    || {isClass (configFile >> "CfgPatches" >> "ace_missileguidance")}
                    || {!isNil "ace_missileguidance_fnc_onFired"};
                if (!_aceLoaded && {!_aceGuidance}) then {
                    private _realTarget = attachedTo _target;
                    private _nativeSnapObject = _atRemoteHandle select 3;
                    // Mirror Fired's config/target checks without moving its logic:
                    // no projectile exists yet to check its identity or locality.
                    private _sensors = _ammoCfg >> "Components" >> "SensorsManagerComponent" >> "Components";
                    private _objectSensor = (configProperties [_sensors, "isClass _x", true]) findIf {
                        getText (_x >> "componentType") in [
                            "IRSensorComponent", "VisualSensorComponent",
                            "ActiveRadarSensorComponent", "PassiveRadarSensorComponent"
                        ]
                    };
                    private _objectGuidance = if (isClass _sensors) then {
                        _objectSensor >= 0
                    } else {getNumber (_ammoCfg >> "irLock") == 1};
                    private _nativePrefireEligible = (_launcherState param [0, ""]) == _launcher
                        && {(_launcherState param [4, 0]) > 0}
                        && {isClass _ammoCfg}
                        && {toLower getText (_ammoCfg >> "simulation") == "shotmissile"}
                        && {getNumber (_ammoCfg >> "maneuvrability") > 0}
                        && {_objectGuidance}
                        && {!isNull _nativeSnapObject && {_realTarget isEqualTo _nativeSnapObject}}
                        && {!isNull _realTarget && {alive _realTarget} && {_realTarget != _unit}}
                        && {!(_realTarget isKindOf "A3C_Invisible_Man_F")}
                        && {!(_realTarget isKindOf "A3C_Supression_Target_F")}
                        && {!(_realTarget isKindOf "LaserTarget")};
                    private _profiles = getArray (_ammoCfg >> "flightProfiles");
                    private _topDownCfg = _ammoCfg >> "TopDown";
                    private _topDownMin = if (isNumber (_topDownCfg >> "minDistance")) then {
                        getNumber (_topDownCfg >> "minDistance")
                    } else {-1};
                    private _engagementDistance = if (!isNull _realTarget
                        && {_realTarget isEqualTo _nativeSnapObject}) then {_unit distance _realTarget} else {-1};
                    private _automaticApplied = false;
                    // Only the established Single/default-Direct and named Direct
                    // pairs are mapped. Additional modes/profiles or ACE profile
                    // annotations may have special semantics: preserve those choices.
                    if (_nativePrefireEligible
                        && {_modes isEqualTo ["Single", "TopDown"] || {_modes isEqualTo ["Direct", "TopDown"]}}
                        && {_fireMode == (_modes select 0)}
                        && {isClass (_weaponCfg >> (_modes select 0)) && {isClass (_weaponCfg >> "TopDown")}}
                        && {getText (_weaponCfg >> (_modes select 0) >> "ace_missileguidance_attackProfile") == ""}
                        && {getText (_weaponCfg >> "TopDown" >> "ace_missileguidance_attackProfile") == ""}
                        && {count _profiles == 2 && {"Direct" in _profiles} && {"TopDown" in _profiles}}
                        && {isClass _topDownCfg && {_topDownMin > 0}}) then {
                        _automaticApplied = true;
                        if (_engagementDistance >= _topDownMin + 50) then {_fireMode = _modes select 1;};
                    };
                    if (missionNamespace getVariable ["A3C_DEBUG", false]) then {
                        diag_log format [
                            "[A3C] ATSHOT %1: mode=%2, distance=%3 m, TopDown.minDistance=%4 m, margin=50 m, automatic=%5, nativePrefireEligible=%6",
                            _token, _fireMode, _engagementDistance, _topDownMin, _automaticApplied, _nativePrefireEligible
                        ];
                    };
                };
                _target setVariable ["A3C_AT_SHOT_ACE_GUIDANCE", _aceGuidance];
                private _context = _unit getVariable ["A3C_AT_SHOT", []];
                _context set [2, true];
                _unit setVariable ["A3C_AT_SHOT", _context, true];
                _unit forceWeaponFire [_launcher, _fireMode];
            };
            // Issuing a command is not success. Only our matching Fired event is.
            private _shotDeadline = time + 10;
            waitUntil {
                sleep 0.1;
                (_unit getVariable ["A3C_AT_SHOT", []]) param [3, false]
                    || {!(call _valid)} || {time >= _shotDeadline}
            };
        };
        call _prepare;

        private _fired = false;
        // Close the capture window atomically before deciding whether proxies
        // belong to a projectile or to an unsuccessful order.
        isNil {
            _fired = _unit getVariable [_firedKey, false];
            private _context = _unit getVariable ["A3C_AT_SHOT", []];
            if ((_context param [0, ""]) == _token) then {
                _context set [2, false];
                _unit setVariable ["A3C_AT_SHOT", _context, true];
            };
            // IDs belong to the installing machine. Never forward this removal
            // with recovery, and never remove twice after the handler ran.
            if (!_fired && {_atHandle >= 0}) then {_unit removeEventHandler ["Fired", _atHandle];};
            _unit setVariable [_firedKey, nil];
            // Preparation always yields in the Fired wait before reaching cleanup.
            // All synchronous Fired initializers, including ACE's, have returned.
            // Restore on the installing machine even after locality loss: the ACE
            // designation was local, so forwarding this write would affect another
            // machine's independent designation. Preserve intervening replacements.
            if (_aceTargetChanged && {!isNull _unit}
                && {!isNil {_unit getVariable "ace_missileguidance_target"}}
                && {(_unit getVariable ["ace_missileguidance_target", objNull]) isEqualTo _aceTarget}) then {
                if (_aceTargetDefined) then {
                    _unit setVariable ["ace_missileguidance_target", _aceTargetPrevious, false];
                } else {
                    _unit setVariable ["ace_missileguidance_target", nil, false];
                };
            };
            if (!isNull _target) then {_target setVariable ["A3C_AT_SHOT_ACE_GUIDANCE", nil];};
        };
        if (_fired) then {sleep 1;}; // Short recovery, independent of missile impact.
        if (!_fired) then {
            {if (!isNull _x) then {deleteVehicle _x;};} forEach [_target, _target1];
        };

        private _restore = {
            params ["_unit", "_token", "_aiState", "_stance", "_unitPos", "_pause", "_destinationSaved", "_stanceChanged", "_savedDestination", "_remoteHandle", "_targetingChanged", "_restoreFunc"];
            // A spawned/remote worker has no access to the caller's private scope.
            // Keep explicit arguments for further ownership transfers.
            private _restoreArgs = +_this;
            private _ownsOrder = {
                !isNull _unit
                && {((_unit getVariable ["A3C_AT_SHOT", []]) param [0, ""]) == _token}
            };
            if (isNull _unit) exitWith {
                A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
                publicVariable "A3C_REMFIRE_UNITS_ACTIVE";
            };
            if !(call _ownsOrder) exitWith {};
            if (!local _unit) exitWith {
                [_restoreArgs, _restoreFunc] remoteExec ["BIS_fnc_spawn", _unit];
            };
            // ANIM must be enabled before setUnitPos; disabling it prevented
            // stance transitions in tests. Previously disabled ANIM never enters prep.
            isNil {
                if (!(call _ownsOrder) || {!local _unit}) exitWith {};
                if (_aiState select 2) then {_unit enableAI "ANIM";};
            };
            if (alive _unit && {_destinationSaved} && {_aiState select 0} && {_aiState select 1}
                && {(_unit getVariable ["A3C_DEST", []]) isEqualTo _savedDestination}) then {
                // Resume locally: the general helper can queue unguarded movement,
                // lookAt and AUTO stance writes after this order has released the unit.
                private _expected = expectedDestination _unit;
                if (!((_expected param [1, ""]) in ["DoNotPlanFormation", "FORMATION PLANNED"])
                    && {currentCommand _unit != "STOP"}) then {
                    if ((_savedDestination select 1) in ["DoNotPlanFormation", "FORMATION PLANNED"]) then {
                        isNil {
                            if (!(call _ownsOrder) || {!local _unit}) exitWith {};
                            if !((_unit getVariable ["A3C_DEST", []]) isEqualTo _savedDestination) exitWith {};
                            _restoreArgs set [6, false];
                            _unit doFollow leader group _unit;
                        };
                    } else {
                        private _position = _savedDestination select 0;
                        private _customFormation = player == leader group _unit
                            && {missionNamespace getVariable ["A3C_UI_CustomFormation_BOOL_formationActive", false]};
                        if (_customFormation) then {
                            isNil {
                                if (!(call _ownsOrder) || {!local _unit}) exitWith {};
                                if !((_unit getVariable ["A3C_DEST", []]) isEqualTo _savedDestination) exitWith {};
                                doStop _unit;
                            };
                            sleep 0.2;
                        };
                        isNil {
                            if (!(call _ownsOrder) || {!local _unit}
                                || {!((_unit getVariable ["A3C_DEST", []]) isEqualTo _savedDestination)}) exitWith {};
                            private _formationData = _unit getVariable ["A3C_FORM", []];
                            if (_customFormation && {count _formationData < 2}) exitWith {};
                            if (_customFormation) then {
                                _position = player getPos [
                                    _formationData select 0,
                                    getDir player + (_formationData select 1)
                                ];
                                _unit setVariable ["A3C_FORM_MEMBER", true, false];
                            };
                            _restoreArgs set [6, false];
                            if (_position distance2D [0, 0, 0] > 0) then {
                                [_unit, _position] call A3C_ai_shared_fnc_doMove;
                                if (_customFormation && {!isMultiplayer}) then {
                                    _unit doFSM ["A3C_CORE\fsm\doFormation.fsm", position _unit, _unit];
                                };
                            };
                        };
                    };
                };
            };
            if !(call _ownsOrder) exitWith {};
            if (!local _unit) exitWith {
                [_restoreArgs, _restoreFunc] remoteExec ["BIS_fnc_spawn", _unit];
            };
            isNil {
                if (!(call _ownsOrder) || {!local _unit}) exitWith {};
                if (_targetingChanged) then {
                    _unit doTarget objNull;
                    _unit lookAt objNull;
                };
            };
            if (alive _unit && {_aiState select 2}) then {
                if (_stance == "PRONE" && {_stanceChanged}) then {
                    isNil {
                        if (!(call _ownsOrder) || {!local _unit}) exitWith {};
                        _unit setUnitPos "DOWN";
                    };
                    private _deadline = time + 10;
                    waitUntil {sleep 0.1; stance _unit == "PRONE" || {!alive _unit} || {!local _unit} || {!(call _ownsOrder)} || {time >= _deadline}};
                };
            };
            if !(call _ownsOrder) exitWith {};
            if (!local _unit && {!isNull _unit}) exitWith {
                [_restoreArgs, _restoreFunc] remoteExec ["BIS_fnc_spawn", _unit];
            };
            isNil {
                if !(call _ownsOrder) exitWith {};
                if (!local _unit) exitWith {
                    [_restoreArgs, _restoreFunc] remoteExec ["BIS_fnc_spawn", _unit];
                };
                // AUTO remains AUTO, even if the unit originally happened to be prone.
                if (alive _unit && {_aiState select 2}) then {_unit setUnitPos _unitPos;};
                {
                    if (_aiState select _forEachIndex) then {_unit enableAI _x;} else {_unit disableAI _x;};
                } forEach ["MOVE", "PATH", "ANIM", "AUTOTARGET"];
                _unit setVariable ["A3C_PAUSE_PLAN", _pause, true];
                _unit setVariable ["A3C_unit_is_Remote_Firing", false, true];
                if ((_unit getVariable ["A3C_REMOTE_HANDLE", []]) isEqualTo _remoteHandle) then {
                    _unit setVariable ["A3C_REMOTE_HANDLE", [], true];
                };
                _unit setVariable ["A3C_AT_SHOT", [], true];
                A3C_REMFIRE_UNITS_ACTIVE = A3C_REMFIRE_UNITS_ACTIVE - [_unit];
                publicVariable "A3C_REMFIRE_UNITS_ACTIVE";
            };
        };
        private _restoreArgs = [_unit, _token, _atAIState, _originalStance, _originalUnitPos, _originalPause, _destinationSaved, _stanceChanged, _savedDestination, _atRemoteHandle, _targetingChanged, _restore];
        // Also call for a deleted unit so recovery can release its active-list entry.
        // The worker forwards live nonlocal units to their current owner itself.
        _restoreArgs call _restore;
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

if (_weaponGroup == "UGLSHOT") then {
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

if (_weaponGroup != "ATSHOT") then {_unit enableAI "AUTOTARGET";};

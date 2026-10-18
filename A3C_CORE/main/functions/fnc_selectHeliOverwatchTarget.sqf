// A3C_main_fnc_selectHeliOverwatchTarget

/*
    Shared discovery, feasibility, threat tiers and hysteresis; no firing commands.
    missiles: [weapon,targetTypes,rounds,maxRange,minRange,fireSpec].
    guns: [weapon,muzzle,magazine,maxRange,fireSpec].
    fireSpec: [weapon,muzzle,magazine,turret,operator,mode,reloadTime,minRange,maxRange].
    state: worker-private HashMap, retained/acquired/priority plus stable object IDs.
    Returns [selected candidate HashMap (empty if none), diagnostic snapshot].
    Only installed, live, locally executable firing options compete for priority.
*/
params ["_heli", "_direction", "_missiles", "_guns", "_state", "_cache", ["_missileUnavailable", []], ["_engagementRejections", []]];
private _knowledgeGroup = group (driver _heli);
private _debug = _heli getVariable ["A3C_OW_Debug", false];

private _retained = _state getOrDefault ["retained", objNull];
private _rows = [];
private _ranked = [];
private _ids = _state getOrDefault ["ids", []];
// Keep live identities only; entries survive nearEntities ordering changes.
_ids = _ids select {!isNull (_x select 0)};
private _nextId = _state getOrDefault ["nextId", 0];
private _selfTargets = [_heli] + crew _heli;
private _stock = magazinesAllTurrets [_heli,true];
private _executable = {
    params ["_option"];
    private _spec = _option select (count _option - 1);
    _spec params ["_weapon","_muzzle","_magazine","_turret","_operator","_mode"];
    !isNull _operator && {alive _operator} && {!isPlayer _operator}
        && {lifeState _operator != "INCAPACITATED"} && {local _operator} && {local _heli}
        && {_heli turretLocal _turret} && {_heli turretUnit _turret == _operator}
        && {(_heli unitTurret _operator) isEqualTo _turret}
        && {toLower _weapon in ((_heli weaponsTurret _turret) apply {toLower _x})}
        && {_mode != ""} && {_muzzle != ""}
        && {_stock findIf {(_x select 1) isEqualTo _turret && {(_x select 2) > 0}
            && {toLower (_x select 0) == toLower _magazine}} >= 0}
};
_missiles = _missiles select {[_x] call _executable};
_guns = _guns select {[_x] call _executable};

// Bound all acquisition paths by the live executable options, before optical LOS.
private _radius = 0;
{_radius = _radius max (_x select 3);} forEach (_missiles + _guns);
private _nearby = if (_radius > 0) then {
    [side _heli, _radius, "ENEMY", position _heli,
        ["AIR", "TANK", "CAR", "SHIP", "MAN", "STATICWEAPON"]] call MCSS_fnc_nearEntities
} else {[]};
private _sensorContacts = getSensorTargets _heli; // One engine snapshot, including reported datalink contacts.
private _sensorObjects = _sensorContacts apply {_x select 0};
private _candidates = [];
private _acquisitions = []; // Aligned with candidates, never a persistent target history.
private _detectionRejected = [];
{
    private _target = _x;
    if !(_target in _candidates) then {
        private _knowledge = _knowledgeGroup knowsAbout _target;
        private _known = _knowledge > 1; // Preserve the existing knowledge threshold exactly.
        private _sensorIndex = _sensorObjects find _target;
        private _sensed = _sensorIndex >= 0; // Contact identity, not its reported relationship, establishes detection.
        private _distance = _heli distance _target;
        private _angle = (((_heli getDir _target) - _direction) % 360 + 540) % 360 - 180;
        private _visualRange = _radius min (if (_target isKindOf "Man") then {1000} else {3000});
        private _visualHalfAngle = if (_target isKindOf "Air") then {120} else {60};
        private _visual = false;
        private _visualEvaluated = false;
        private _visualStatus = "NOT_REQUIRED";
        if (!_known && {!_sensed}) then {
            _visualStatus = "OUT_OF_RANGE";
            if (_distance <= _visualRange) then {
                _visualStatus = "OUT_OF_CONE";
                if ([_heli, _direction, _visualHalfAngle, _target] call MCSS_fnc_isInAngleSector) then {
                    _visualEvaluated = true;
                    // ASL eye-to-aim ray tests terrain and view geometry (GEOM fallback).
                    // Both endpoint objects are ignored; neither hull can self-occlude the ray.
                    _visual = [_heli, _target] call A3C_main_fnc_hasHeliOverwatchLOS;
                    _visualStatus = if (_visual) then {"CLEAR"} else {"BLOCKED"};
                };
            };
        };
        private _detected = _known || {_sensed} || {_visual};
        if (_detected || {_debug}) then {
            private _paths = [];
            if (_known) then {_paths pushBack "KNOWLEDGE";};
            if (_sensed) then {_paths pushBack "SENSOR";};
            if (_visual) then {_paths pushBack "VISUAL";};
            private _detection = createHashMapFromArray [
                ["target", _target], ["distance", _distance], ["angle", _angle], ["paths", _paths],
                ["knowledge", _known], ["knowsAbout", _knowledge], ["sensor", _sensed],
                ["sensorContact", if (_sensed) then {_sensorContacts select _sensorIndex} else {[]}],
                ["visual", _visual], ["visualEvaluated", _visualEvaluated], ["visualLOS", _visual],
                ["visualStatus", _visualStatus], ["visualRange", _visualRange], ["visualHalfAngle", _visualHalfAngle]
            ];
            if (_detected) then {
                _candidates pushBack _target;
                _acquisitions pushBack _detection;
            } else {
                _detection set ["reason", "Insufficient detection: knowledge <= 1, no sensor contact; optical " + _visualStatus];
                _detectionRejected pushBack _detection;
            };
        };
    };
} forEach _nearby;

// Live threat readiness. Cached weapon/mag config; stock, crew and range are live.
private _threat = {
    params ["_target", "_distance", "_isMan", "_isAir"];
    private _grade = 0;
    private _notes = [];
    private _stock = if (_isMan) then {magazinesAmmoFull _target} else {magazinesAllTurrets [_target, true]};
    private _stations = if (_isMan) then {[[]]} else {[[-1]]};
    if (!_isMan) then {
        {_stations pushBackUnique _x;} forEach allTurrets [_target, true];
        // Some modded dedicated stations are absent from allTurrets. Inventory
        // supplies candidate paths only: config, installed weapons and matching stock still have to qualify.
        {if ((_x select 2) > 0) then {_stations pushBackUnique (_x select 1);};} forEach _stock;
        private _crewSeats = fullCrew [_target, "", true]; // Include empty seats; occupancy is checked by live readiness below.
        _stations = _stations select {
            private _path = _x;
            private _dedicated = _path isEqualTo [-1]; // Driver-operated weapons remain supported.
            if (!_dedicated) then {
                // Engine seat identity is direct evidence; config proxy/FFV metadata
                // can disagree with a modded vehicle's actual mounted gunner seat.
                private _matchingSeats = _crewSeats select {(_x select 3) isEqualTo _path};
                private _seatCount = count _matchingSeats;
                private _seat = _matchingSeats param [0, []];
                private _role = toLower (_seat param [1, ""]);
                private _personTurret = _seat param [4, true]; // Missing evidence fails closed.
                private _pathNonempty = _path isNotEqualTo [];
                private _weaponRole = _role in ["gunner", "commander", "turret"];
                _dedicated = _pathNonempty && {_seatCount == 1} && {_weaponRole} && {!_personTurret};
                if (!_dedicated && {_debug}) then {
                    _notes pushBack format ["turret=%1 excluded: pathNonempty=%2 seatCount=%3 role=%4 weaponRole=%5 personTurret=%6",
                        _path,_pathNonempty,_seatCount,_role,_weaponRole,_personTurret];
                };
            };
            _dedicated
        };
    };
    private _canFire = _isMan || {canFire _target};
    {
        private _path = _x;
        private _operator = if (_isMan) then {_target} else {
            if (_path isEqualTo [-1]) then {driver _target} else {_target turretUnit _path}
        };
        private _operatorReady = !isNull _operator && {alive _operator}
            && {lifeState _operator != "INCAPACITATED"}
            && {_isMan || {vehicle _operator == _target && {(_target unitTurret _operator) isEqualTo _path}}};
        private _weapons = if (_isMan) then {[secondaryWeapon _target]} else {_target weaponsTurret _path};
        if (_debug) then {_notes pushBack format ["turret=%1 installed=%2 operator=%3 operatorReady=%4 canFire=%5",_path,_weapons,_operator,_operatorReady,_canFire];};
        {
            private _weapon = _x;
            if (_weapon != "") then {
                private _compatKey = "compatible:" + toLower _weapon;
                if !(_compatKey in _cache) then {
                    private _cfg = configFile >> "CfgWeapons" >> _weapon;
                    private _muzzles = getArray (_cfg >> "muzzles");
                    if (_muzzles isEqualTo []) then {_muzzles = ["this"];};
                    _cache set [_compatKey, _muzzles apply {[_x, (compatibleMagazines [_weapon, _x]) apply {toLower _x}]}];
                };
                {
                    _x params ["_muzzle", "_compatible"];
                    {
                        private _mag = _x select 0;
                        private _stockHere = if (_isMan) then {
                            (_x select 1) > 0 && {!(_x select 2) || {(_x select 3) == 4}}
                        } else {(_x select 1) isEqualTo _path && {(_x select 2) > 0}};
                        private _pylonMatch = !_isMan && {_muzzle == "this"}
                            && {toLower getText (configFile >> "CfgMagazines" >> _mag >> "pylonWeapon") == toLower _weapon};
                        if (_stockHere && {toLower _mag in _compatible || {_pylonMatch}}) then {
                            private _info = [_weapon, _muzzle, _mag, _cache] call A3C_main_fnc_getHeliOverwatchAmmoInfo;
                            private _aa = _info get "aa";
                            // Enemy threat evidence does not establish our AA compatibility.
                            if (_isAir && {_info get "damaging"}
                                && {(_info get "simulation") in ["shotbullet", "shotshell", "shotmissile", "shotrocket"]}) then {_aa = 1;};
                            if (_aa > 0) then {
                                private _inRange = (_info get "range") > 0 && {_distance <= (_info get "range")}
                                    && {_distance >= (_info get "minRange")};
                                // Infantry can be holding a rifle while carrying a live
                                // AA launcher. canFire then tests the wrong current weapon.
                                private _ready = alive _target && {_operatorReady} && {_canFire} && {_inRange};
                                private _liveGrade = if (_aa == 1 && {_ready}) then {1} else {2};
                                if (_grade == 0 || {_liveGrade < _grade}) then {_grade = _liveGrade;};
                                _notes pushBackUnique format ["%1; turret=%2 rounds=%3 operator=%4 operatorReady=%5 canFire=%6 inRange=%7 ready=%8 liveGrade=%9",
                                    _info get "evidence", _path, _x select (if (_isMan) then {1} else {2}),
                                    _operator, _operatorReady, _canFire, _inRange, _ready, _liveGrade];
                            } else {
                                // Also explain conservative rejection, when diagnostics are on.
                                if (_debug) then {_notes pushBackUnique format ["%1; turret=%2: no credible AA ammunition evidence.",_info get "evidence",_path];};
                            };
                        };
                    } forEach _stock;
                } forEach (_cache get _compatKey);
            };
        } forEach _weapons;
    } forEach _stations;
    if (_notes isEqualTo []) then {_notes pushBack "No compatible live AA rounds / qualified AA system.";};
    [_grade, _notes]
};

{
    private _target = _x;
    private _detection = _acquisitions select _forEachIndex;
    private _isMan = _target isKindOf "Man";
    private _isAir = _target isKindOf "Air";
    private _distance = _detection get "distance";
    private _angle = _detection get "angle";
    private _sector = abs _angle <= 60;
    private _valid = alive _target && {side _target != civilian} && {(side _target) getFriend (side _heli) < 0.6};
    private _reason = "";
    if (_isMan) then {
        _valid = _valid && {vehicle _target == _target};
        if (!_valid) then {_reason = "Dead, nonhostile or embarked infantry.";};
    } else {
        _valid = _valid && {{alive _x} count crew _target > 0}
            // Detection alone never establishes fireability; all paths use the same
            // elevated observation geometry as the final firing check. Reuse a just-tested optical ray.
            && {(_detection get "visual") || {[_heli, _target] call A3C_main_fnc_hasHeliOverwatchLOS}};
        // Hostile live crew identifies the vehicle. A disabled gun, removed
        // armament or speed changes threat readiness, not target validity.
        if (!_valid) then {_reason = "Vehicle failed alive/hostility/live-crew/LOS checks.";};
    };
    private _missileHeld = _target in _missileUnavailable;
    private _groundNeutralized = false;
    if (!_isMan && {!_isAir} && {!(_target isKindOf "StaticWeapon")}
        && {!canMove _target} && {!canFire _target}) then {
        // Positive mounted damaging-ammunition evidence avoids treating an unarmed/modded vehicle's canFire=false as gun failure.
        _groundNeutralized = (magazinesAllTurrets [_target, true]) findIf {
            private _ammoCfg = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> (_x select 0) >> "ammo");
            getNumber (_ammoCfg >> "hit") > 0
                || {getNumber (_ammoCfg >> "indirectHit") > 0 && {getNumber (_ammoCfg >> "indirectHitRange") > 0}}
        } >= 0;
    };
    private _missileReason = if (_missileHeld) then {"Missile target reserved: launch/flight or damage assessment outstanding."} else {
        if (_groundNeutralized) then {"Armed ground target can neither move nor fire."} else {""}
    };
    private _method = "";
    private _option = [];
    if (_valid && {_isMan}) then {
        private _index = _guns findIf {
            _distance <= (_x select 3) && {_distance >= ((_x select 4) select 7)}
        };
        if (_index >= 0) then {_method = "GUN"; _option = _guns select _index;};
        if (_method == "") then {_reason = "No usable classified primary-gunner gun in range.";};
    };
    if (_valid && {!_isMan}) then {
        private _type = switch (true) do {
            case (_isAir): {"AIR"};
            case (_target isKindOf "Tank"): {"TANK"};
            case (_target isKindOf "Ship"): {"SHIP"};
            default {"CAR"};
        };
        private _index = _missiles findIf {
            !_missileHeld && {!_groundNeutralized} && {_type in (_x select 1)} && {(_x select 2) > 0}
                && {_distance <= (_x select 3)} && {_distance >= (_x select 4)}
        };
        if (_index >= 0) then {_method = "MISSILE"; _option = _missiles select _index;};
        if (_method == "" && {!_isAir}) then {
            _index = _guns findIf {
                _distance <= (_x select 3) && {_distance >= ((_x select 4) select 7)}
            };
            if (_index >= 0) then {_method = "GUN"; _option = _guns select _index;};
        };
        if (_method == "") then {
            _reason = if (_missileReason != "") then {_missileReason} else {
                if (_isAir) then {"No executable compatible AA missile in range."}
                    else {"No executable ground missile or classified primary-gunner gun in range."}
            };
        };
    };
    // Detection is unchanged; only AIR missile eligibility requires mobility.
    private _airCanMove = !_isAir || {canMove _target};
    private _airDisabled = _isAir && {_method == "MISSILE"} && {!_airCanMove};
    if (_airDisabled) then {
        _valid = false;
        _reason = "Aircraft operationally disabled (canMove=false); AA missile engagement rejected.";
    };
    private _assessment = [_target, _distance, _isMan, _isAir] call _threat;
    _assessment params ["_aa", "_evidence"];
    // Attack orders are evidence only for candidates returned by nearEntities.
    private _actors = if (_isMan) then {[_target]} else {[_target] + (crew _target select {alive _x})};
    private _attacking = _actors findIf {
        (getAttackTarget _x) in _selfTargets || {(assignedTarget _x) in _selfTargets}
    } >= 0;
    private _tier = switch (true) do {
        case (_aa == 1): {1};
        case (_aa == 2): {2};
        case (_attacking): {3};
        case (_sector): {4};
        default {5};
    };
    private _label = ["Ordinary", "Operational immediate air threat", "Credible/uncertain air defense"] select _aa;
    if (_attacking) then {_evidence pushBack "Candidate or live crew getAttackTarget/assignedTarget points at helicopter/crew.";};
    private _idIndex = _ids findIf {(_x select 0) isEqualTo _target};
    if (_idIndex < 0) then {
        _ids pushBack [_target, _nextId]; _nextId = _nextId + 1; _idIndex = count _ids - 1;
    };
    private _identity = netId _target;
    if (_identity in ["", "0:0"]) then {_identity = str _target;};
    // Temporary authorization failures stay visible, but never enter ranking or retention.
    // Entries are worker-local [target, until, cause], independent of missile reservations.
    private _rejectionIndex = _engagementRejections findIf {(_x select 0) isEqualTo _target && {time < (_x select 1)}};
    private _temporarilyExcluded = _rejectionIndex >= 0;
    private _rejection = if (_temporarilyExcluded) then {_engagementRejections select _rejectionIndex} else {[_target,0,""]};
    if (_temporarilyExcluded) then {_reason = "TARGET_TEMPORARILY_UNAVAILABLE: " + (_rejection select 2);};
    private _eligible = _valid && {_method != ""} && {!_temporarilyExcluded};
    private _row = createHashMapFromArray [
        ["target", _target], ["type", typeOf _target], ["distance", _distance],
        ["acquisition", _detection],
        ["temporarilyExcluded", _temporarilyExcluded], ["rejectedUntil", _rejection select 1], ["rejectionCause", _rejection select 2],
        ["missileWithheld", _missileHeld || {_groundNeutralized}], ["missileReason", _missileReason],
        ["threat", _label], ["evidence", _evidence], ["tier", _tier],
        ["sector", _sector], ["angle", _angle], ["method", _method], ["option", _option],
        ["eligible", _eligible], ["reason", _reason]
    ];
    if (_debug && {_isAir}) then {
        _row set ["airOperational", createHashMapFromArray [
            ["alive", alive _target], ["canMove", _airCanMove], ["canFire", canFire _target],
            ["damage", damage _target], ["speed", speed _target], ["distance", _distance],
            ["liveCrew", {alive _x} count crew _target], ["rejectedDisabled", _airDisabled]
        ]];
    };
    _rows pushBack _row;
    if (_eligible) then {
        // Lexicographic tuple, not a damage/armor multiplier. Stable ID is final.
        _ranked pushBack [_tier, if (_attacking) then {0} else {1}, if (_sector) then {0} else {1},
            _distance, _identity, (_ids select _idIndex) select 1, count _rows - 1];
    };
} forEach _candidates;
_state set ["ids", _ids];
_state set ["nextId", _nextId];
// Explicit tuple comparison avoids depending on nested-array sort behavior.
// Only the final identity field is text; sort a pair of strings for that tie.
private _betterTuple = {
    params ["_left", "_right"];
    private _better = false;
    for "_i" from 0 to 5 do {
        private _a = _left select _i;
        private _b = _right select _i;
        if !(_a isEqualTo _b) exitWith {
            if (_a isEqualType "") then {
                private _pair = [_a, _b];
                _pair sort true;
                _better = (_pair select 0) isEqualTo _a;
            } else {
                _better = _a < _b;
            };
        };
    };
    _better
};
private _best = [];
{
    if (_best isEqualTo [] || {[_x, _best] call _betterTuple}) then {_best = _x;};
} forEach _ranked;
private _selected = createHashMap;
if (_best isNotEqualTo []) then {_selected = _rows select (_best select 6);};
private _currentIndex = _rows findIf {(_x get "target") isEqualTo _retained && {_x get "eligible"}};
private _decision = "No executable candidates; release retained target.";
private _age = time - (_state getOrDefault ["acquired", time]);
if (_currentIndex >= 0) then {
    private _current = _rows select _currentIndex;
    if ((_selected get "tier") < (_current get "tier")) then {
        _decision = "Higher priority tier preempts immediately at evaluation.";
    } else {
        private _meaningful = (_selected get "tier") == (_current get "tier") && {
            (!(_current get "sector") && {_selected get "sector"})
            || {(_selected get "distance") < (_current get "distance") * 0.65
                && {(_current get "distance") - (_selected get "distance") >= 150}}
        };
        if (_age >= 12 && {_meaningful}) then {
            _decision = "12 s elapsed; same-tier sector or substantial distance advantage.";
        } else {
            _selected = _current;
            _decision = if (_age < 12) then {"Retain viable target: 12 s hysteresis (higher tiers may preempt)."}
                else {"Retain viable target: no meaningful same-tier improvement."};
        };
    };
} else {
    if (count _selected > 0) then {_decision = "Acquire best feasible tuple; previous target absent or unengageable.";};
};
private _newTarget = _selected getOrDefault ["target", objNull];
if !(_newTarget isEqualTo _retained) then {_state set ["acquired", time];};
_state set ["retained", _newTarget];
_state set ["priority", _selected getOrDefault ["tier", 0]];
private _snapshot = createHashMapFromArray [
    ["time", time], ["helicopter", _heli], ["direction", _direction], ["radius", _radius],
    ["candidates", _rows], ["selected", _newTarget], ["previous", _retained],
    ["detectionRejected", _detectionRejected],
    ["retained", _newTarget], ["age", _age], ["decision", _decision],
    ["priority", _state get "priority"]
];
[_selected, _snapshot]

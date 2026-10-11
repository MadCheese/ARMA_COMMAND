/*
    Shared discovery, feasibility, threat tiers and hysteresis; no firing commands.
    missiles: [weapon,targetTypes,rounds,maxRange,minRange,fireSpec].
    guns: [weapon,muzzle,magazine,maxRange,fireSpec].
    fireSpec: [weapon,muzzle,magazine,turret,operator,mode,reloadTime,minRange,maxRange].
    state: worker-private HashMap, retained/acquired/priority plus stable object IDs.
    Returns [selected candidate HashMap (empty if none), diagnostic snapshot].
    Only installed, live, locally executable firing options compete for priority.
*/
params ["_heli", "_direction", "_missiles", "_guns", "_state", "_cache"];
private _radius = 0;
{_radius = _radius max (_x select 3);} forEach (_missiles + _guns);
private _candidates = if (_radius > 0) then {
    [side _heli, _radius, "ENEMY", position _heli, ["AIR", "TANK", "CAR", "SHIP", "MAN"]] call MCSS_fnc_nearEntities
} else {[]};
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

// Live threat readiness. Cached weapon/mag config; stock, crew and range are live.
private _threat = {
    params ["_target", "_distance", "_isMan", "_isAir"];
    private _grade = 0;
    private _notes = [];
    private _stations = if (_isMan) then {[[]]} else {[[-1]] + allTurrets [_target, false]};
    private _stock = if (_isMan) then {magazinesAmmoFull _target} else {magazinesAllTurrets [_target, true]};
    {
        private _path = _x;
        private _operator = if (_isMan) then {_target} else {
            if (_path isEqualTo [-1]) then {driver _target} else {_target turretUnit _path}
        };
        private _operatorReady = !isNull _operator && {alive _operator}
            && {lifeState _operator != "INCAPACITATED"};
        private _weapons = if (_isMan) then {[secondaryWeapon _target]} else {_target weaponsTurret _path};
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
                                private _ready = _operatorReady && {canFire _target} && {_inRange};
                                private _liveGrade = if (_aa == 1 && {_ready}) then {1} else {2};
                                if (_grade == 0 || {_liveGrade < _grade}) then {_grade = _liveGrade;};
                                _notes pushBackUnique format ["%1; rounds present, operator=%2 ready=%3 inRange=%4",
                                    _info get "evidence", _operator, _ready, _inRange];
                            } else {
                                // Also explain conservative rejection, when diagnostics are on.
                                if (_heli getVariable ["A3C_OW_Debug", false]) then {_notes pushBackUnique (_info get "evidence");};
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
    private _isMan = _target isKindOf "Man";
    private _isAir = _target isKindOf "Air";
    private _distance = _heli distance _target;
    private _angle = (((_heli getDir _target) - _direction) % 360 + 540) % 360 - 180;
    private _sector = abs _angle <= 60;
    private _valid = alive _target && {side _target != civilian} && {(side _target) getFriend (side _heli) < 0.6};
    private _reason = "";
    if (_isMan) then {
        _valid = _valid && {vehicle _target == _target};
        if (!_valid) then {_reason = "Dead, nonhostile or embarked infantry.";};
    } else {
        _valid = _valid && {{alive _x} count crew _target > 0}
            && {!(lineIntersects [getPosASL _heli, getPosASL _target, _heli, _target])};
        if (!_isAir) then {
            _valid = _valid && {canFire _target} && {speed _target < 100}
                && {(weapons _target) findIf {
                    private _name = toLower _x;
                    ["horn", "smoke"] findIf {_x in _name} < 0
                } >= 0};
        };
        if (!_valid) then {_reason = "Vehicle failed alive/crew/LOS or legacy ground validity checks.";};
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
            _type in (_x select 1) && {(_x select 2) > 0}
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
            _reason = if (_isAir) then {"No executable compatible AA missile in range."}
                else {"No executable ground missile or classified primary-gunner gun in range."};
        };
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
    private _eligible = _valid && {_method != ""};
    private _row = createHashMapFromArray [
        ["target", _target], ["type", typeOf _target], ["distance", _distance],
        ["threat", _label], ["evidence", _evidence], ["tier", _tier],
        ["sector", _sector], ["angle", _angle], ["method", _method], ["option", _option],
        ["eligible", _eligible], ["reason", _reason]
    ];
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
    ["retained", _newTarget], ["age", _age], ["decision", _decision],
    ["priority", _state get "priority"]
];
[_selected, _snapshot]

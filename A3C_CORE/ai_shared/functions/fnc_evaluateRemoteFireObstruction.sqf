// A3C_ai_shared_fnc_evaluateRemoteFireObstruction
// Read-only, weapon-independent ASL ray analysis. No scene changes or caching.
// Returns [CLEAR/SOFT/HARD/UNCERTAIN, softCount, hardCount, uncertainCount, details].
// Detail: [posASL, hitObject, parentObject, terrain, class, reason, effectiveObject,
//          configClass, modelPath, hitModelPath, selections, surfacePath].
params [
    ["_originASL", [], [[]]], ["_targetASL", [], [[]]],
    ["_unit", objNull, [objNull]], ["_vehicle", objNull, [objNull]],
    ["_targetObject", objNull, [objNull]]
];
private _uncertainResult = {
    params ["_reason"];
    ["UNCERTAIN", 0, 0, 1, [[[], objNull, objNull, false, "UNCERTAIN", _reason, objNull, "", "", "", [], ""]]]
};
if (!(_originASL isEqualTypeArray [0, 0, 0]) || {!(_targetASL isEqualTypeArray [0, 0, 0])}
    || {{finite _x} count _originASL != 3} || {{finite _x} count _targetASL != 3})
    exitWith {["invalid ASL coordinates"] call _uncertainResult};
private _length = _originASL vectorDistance _targetASL;
// Respect the engine's 5000 m surface-ray limit rather than claiming clear.
if (_length <= 0.25 || {_length > 5000}) exitWith {["degenerate ray or beyond 5000 m surface-query limit"] call _uncertainResult};
if ((_originASL select 2) < getTerrainHeightASL [_originASL select 0, _originASL select 1])
    exitWith {["approximate firing origin is below terrain; surface query is incomplete"] call _uncertainResult};

private _endpointTolerance = 0.25;
private _maxHits = 64;
private _hits = lineIntersectsSurfaces [_originASL, _targetASL, _unit, _vehicle, true, _maxHits, "FIRE", "GEOM", true];
private _details = [];
private _soft = 0;
private _hard = 0;
private _uncertain = 0;
private _seen = [];
private _terrainSeen = false;
{
    _x params ["_pos", "_normal", "_hit", "_parent", ["_selections", []], ["_surface", ""]];
    private _terrain = isNull _hit && {isNull _parent};
    // Proxy geometry belongs to its parent; do not classify a child in isolation.
    private _object = if (!isNull _parent) then {_parent} else {_hit};
    private _model = if (isNull _object) then {""} else {(getModelInfo _object) param [1, ""]};
    private _hitModel = if (isNull _hit) then {""} else {(getModelInfo _hit) param [1, ""]};
    private _class = "UNCERTAIN";
    private _reason = "unrecognized object; no reliable solid/vegetation classification";
    private _ignored = (!isNull _object && {_object in [_unit, _vehicle]})
        || {!isNull _hit && {_hit in [_unit, _vehicle]}};
    if (!_ignored && {!isNull _targetObject}) then {
        _ignored = _object isEqualTo _targetObject || {_hit isEqualTo _targetObject};
        if (_ignored) then {_reason = "designated target's own surface";};
    } else {if (_ignored) then {_reason = "firing unit/vehicle or its proxy";};};
    if (!_ignored && {_pos vectorDistance _targetASL <= _endpointTolerance}) then {
        _ignored = true;
        _reason = "surface within 0.25 m of designated endpoint";
    };
    if (!_ignored && {!isNull _object}
        && {{_object isKindOf _x} count ["A3C_Invisible_Man_F", "A3C_Supression_Target_F", "LaserTarget"] > 0}) then {
        _ignored = true;
        _reason = "remote-fire targeting proxy";
    };
    if (_ignored) then {_class = "IGNORED";} else {
        if (_terrain) then {
            _class = "HARD";
            _reason = "intervening terrain surface";
        } else {
            // Exact membership at the hit object's own location. A nearby tree
            // must never promote an unrelated intersected rock/wall to vegetation.
            private _box = boundingBoxReal _object;
            private _terrainRadius = 2 max (50 min ((_box param [2, 1]) + 2));
            private _vegetation = nearestTerrainObjects [_object, ["TREE", "SMALL TREE", "BUSH"], _terrainRadius, false, true];
            private _fences = nearestTerrainObjects [_object, ["FENCE"], _terrainRadius, false, true];
            private _solids = nearestTerrainObjects [_object, ["BUILDING", "HOUSE", "CHURCH", "CHAPEL", "BUNKER", "FORTRESS", "RUIN", "WALL", "ROCK", "ROCKS"], _terrainRadius, false, true];
            if (_object in _vegetation) then {
                _class = "SOFT";
                _reason = "exact terrain TREE/SMALL TREE/BUSH match (vegetation-permissive)";
            } else {
                if (_object in _fences || {_object isKindOf "Fence"}) then {
                    private _height = abs (((_box select 1) select 2) - ((_box select 0) select 2));
                    private _modelName = toLower ((getModelInfo _object) param [0, ""]);
                    // Only an explicitly fence-classified, small wire/mesh model
                    // is softened. Size alone cannot prove a concrete fence soft.
                    if (_height > 0 && {_height <= 1.5}
                        && {["wire", "mesh", "chainlink"] findIf {_modelName find _x >= 0} >= 0}) then {
                        _class = "SOFT";
                        _reason = "small fence with wire/mesh model naming";
                    } else {_reason = "fence material/solidity uncertain; not assumed foliage";};
                } else {
                    if (_object in _solids
                        || {{_object isKindOf _x} count ["LandVehicle", "Air", "Ship", "Wall", "Wall_F", "Rock"] > 0}
                        || {_object isKindOf "House" && {getNumber (configOf _object >> "numberOfDoors") > 0}}) then {
                        _class = "HARD";
                        _reason = "confirmed terrain structure/rock, vehicle, wall or building with doors";
                    };
                };
            };
        };
        // Count obstacles, not separate child proxies belonging to one parent.
        private _new = if (_terrain) then {!_terrainSeen} else {!(_object in _seen)};
        if (_new) then {
            if (_terrain) then {_terrainSeen = true;} else {_seen pushBack _object;};
            switch (_class) do {
                case "SOFT": {_soft = _soft + 1;};
                case "HARD": {_hard = _hard + 1;};
                default {_uncertain = _uncertain + 1;};
            };
        };
    };
    _details pushBack [_pos, _hit, _parent, _terrain, _class, _reason, _object, typeOf _object, _model, _hitModel, _selections, _surface];
} forEach _hits;
// Terrain must still be checked behind foliage or after a capped object query.
// Trim only the intended endpoint contact, not intervening terrain crests.
private _trimmedEnd = _targetASL vectorDiff ((_targetASL vectorDiff _originASL) vectorMultiply (_endpointTolerance / _length));
if (!_terrainSeen && {terrainIntersectASL [_originASL, _trimmedEnd]}) then {
    _hard = _hard + 1;
    _details pushBack [[], objNull, objNull, true, "HARD", "intervening terrain confirmed by trimmed terrainIntersectASL", objNull, "", "", "", [], ""];
};
if (count _hits >= _maxHits) then {
    _uncertain = _uncertain + 1;
    _details pushBack [[], objNull, objNull, false, "UNCERTAIN", "64-surface limit reached; later objects may be uninspected", objNull, "", "", "", [], ""];
};
private _status = switch (true) do {
    case (_hard > 0): {"HARD"};
    case (_uncertain > 0): {"UNCERTAIN"};
    case (_soft > 0): {"SOFT"};
    default {"CLEAR"};
};
[_status, _soft, _hard, _uncertain, _details]

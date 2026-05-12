// A3C_main_fnc_getBoardableVehicles
//
// Finds nearby vehicles that can be boarded by the given groups.
// A vehicle is considered boardable if:
// - it is alive,
// - it has at least one empty position,
// - and it is either empty or has no alive hostile crew.

params [
    ["_groups", [], [[]]],
    ["_radius", 500, [0]]
];

private _playerSide = side player;

private _units = [];

{
    if (!isNull _x) then {
        _units append ((units _x) select { alive _x });
    };
} forEach _groups;

private _vehicleTypes = [
    "Car",
    "Tank",
    "Air",
    "StaticWeapon",
    "Ship"
];

private _allVics = [];

{
    {
        _allVics pushBackUnique _x;
    } forEach (_x nearEntities [_vehicleTypes, _radius]);
} forEach _units;

private _isBoardable = {
    params ["_vic", "_playerSide"];

    if (!alive _vic) exitWith { false };

    private _hasEmptySeat =
        {
            (_vic emptyPositions _x) > 0
        } count [
            "driver",
            "gunner",
            "commander",
            "cargo"
        ] > 0;

    if (!_hasEmptySeat) exitWith { false };

    private _aliveCrew = (crew _vic) select { alive _x };

    if (_aliveCrew isEqualTo []) exitWith { true };

    private _hasHostileCrew = {
        (side _x) getFriend _playerSide < 0.6
    } count _aliveCrew > 0;

    !_hasHostileCrew
};

_allVics = _allVics select {
    [_x, _playerSide] call _isBoardable
};

private _return = _allVics apply {
    [_x, [25, 25], getPos _x]
};

_return
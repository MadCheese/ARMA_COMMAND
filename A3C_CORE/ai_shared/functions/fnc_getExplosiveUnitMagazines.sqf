/*
    Returns unique unit magazines that are placeable explosives.

    Criteria:
    1. Magazine is compatible with weapon "Put"
       OR
    2. Magazine uses nameSound "satchelcharge" or "mine" as fallback

    This includes remote charges, AT mines, APERS mines, etc.
*/

params ["_unit"];

private _result = [];
private _unitMags = magazines _unit arrayIntersect magazines _unit;

// Prefer engine/helper compatibility result over manually reading Put config.
private _putCompatibleMags = compatibleMagazines "Put";

{
    private _mag = _x;
    private _magCfg = configFile >> "CfgMagazines" >> _mag;

    private _isPutCompatible = _mag in _putCompatibleMags;

    // Fallback / compatibility heuristic for vanilla-ish and modded explosives.
    private _nameSound = toLowerANSI getText (_magCfg >> "nameSound");
    private _looksLikePlaceableExplosive = _nameSound in ["satchelcharge", "mine"];

    if (_isPutCompatible || {_looksLikePlaceableExplosive}) then {
        _result pushBack _mag;
    };
} forEach _unitMags;

_result
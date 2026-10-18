// Vehicle observation/aim geometry shared by selection and firing authorization.
// Both positions are ASL; ignore both endpoint vehicles, but test terrain/VIEW
// geometry (GEOM fallback). Never infer long-range clearance from a limited ray.
params ["_heli", "_target"];
if (isNull _heli || {isNull _target}) exitWith {false};
private _start = eyePos _heli;
private _end = aimPos _target;
private _delta = _end vectorDiff _start;
// Stay comfortably below lineIntersectsSurfaces' hardcoded 5000 m limit.
private _segments = (ceil ((_start vectorDistance _end) / 4000)) max 1;
private _clear = true;
for "_i" from 0 to (_segments - 1) do {
    // One metre of overlap at internal seams avoids leaving a boundary untested.
    private _from = _start vectorAdd (_delta vectorMultiply (_i / _segments));
    if (_i > 0) then {_from = _from vectorDiff ((vectorNormalized _delta) vectorMultiply 1);};
    private _to = _start vectorAdd (_delta vectorMultiply ((_i + 1) / _segments));
    if ((lineIntersectsSurfaces [_from, _to, _heli, _target, true, 1, "VIEW", "GEOM"]) isNotEqualTo []) exitWith {
        _clear = false;
    };
};
_clear

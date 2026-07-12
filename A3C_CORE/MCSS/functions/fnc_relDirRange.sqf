// MCSS_fnc_relDirRange

params ["_objectFrom","_objectTo","_range"];
private _relDir = _objectFrom getRelDir _objectTo;
private _return = _relDir < _range OR {_relDir > (360 - _range)};
_return
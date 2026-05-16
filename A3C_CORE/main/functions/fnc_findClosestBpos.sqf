// A3C_main_fnc_findClosestBpos

//-- find closest building position

//-- inputs: 0: positionATL or object, 1: enterable object, 2: bool: ignore elevated positions


params ["_refPos", "_building"];

private _refObject = objNull;

if (_refPos isEqualType objNull) then {
	_refObject = _refPos;
	_refPos = getPosATL _refObject;
};

private _closestBposATL = _building buildingPos 0;
private _closestBposID = 0;
private _distance = _refPos distance _closestBposATL;
private _buildingPosCount = [_building] call MCSS_fnc_countBPos;

for "_i" from 0 to _buildingPosCount do {
	private _checkPos = _building buildingPos _i;
	private _refDist = _checkPos distance _refPos;

	if !(!isNull _refObject && { _refObject distance _checkPos < 2 }) then {
		if (_refDist < _distance) then {
			_distance = _refDist;
			_closestBposATL = _checkPos;
			_closestBposID = _i;
		};
	};
};

[_closestBposID, _closestBposATL]
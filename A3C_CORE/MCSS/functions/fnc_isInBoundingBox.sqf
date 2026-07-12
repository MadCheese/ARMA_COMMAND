// MCSS_fnc_isInBoundingBox

params ["_objectCheck", "_objectBB"];

private _relPos = _objectBB worldToModel (getPosATL _objectCheck);
private _boundingBox = boundingBox _objectBB;

private _min = _boundingBox select 0;
private _max = _boundingBox select 1;

private _myX = _relPos select 0;
private _myY = _relPos select 1;
private _myZ = _relPos select 2;

private _inside = false;

if ((_myX > (_min select 0)) and { _myX < (_max select 0) }) then {
	if ((_myY > (_min select 1)) and { _myY < (_max select 1) }) then {
		if ((_myZ > (_min select 2)) and { _myZ < (_max select 2) }) then {
			_inside = true;
		};
	};
};

_inside
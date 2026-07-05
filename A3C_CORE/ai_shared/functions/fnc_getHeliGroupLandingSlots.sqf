// A3C_ai_shared_fnc_getHeliGroupLandingSlots

params [
	"_group",
	"_centerPos",
	["_spacing", 30],
	["_referenceVehicle", objNull],
	["_referenceDir", -1]
];

private _groupVehicles = [_group] call A3C_main_fnc_getGroupDrivenVehicles;

private _helicopters = _groupVehicles select {
	alive _x &&
	{canMove _x} &&
	{_x isKindOf "HELICOPTER"}
};

if (isNull _referenceVehicle) then {
	_referenceVehicle = vehicle leader _group;
};

//-- Leader / reference vehicle gets the center slot if it is part of the helicopter set.
if (!isNull _referenceVehicle && {_referenceVehicle in _helicopters}) then {
	_helicopters = [_referenceVehicle] + (_helicopters - [_referenceVehicle]);
};

if (_referenceDir < 0) then {
	_referenceDir = if (!isNull _referenceVehicle) then {
		_referenceVehicle getDir _centerPos
	} else {
		0
	};
};

private _fnc_getOffsetIndex = {
	params ["_index"];

	if (_index == 0) exitWith {
		0
	};

	private _n = ceil (_index / 2);

	if (_index % 2 == 1) then {
		-_n	//-- left
	} else {
		_n	//-- right
	};
};

private _landingSlots = [];

{
	private _offsetIndex = [_forEachIndex] call _fnc_getOffsetIndex;
	private _offsetDistance = _offsetIndex * _spacing;

	private _slotPos = if (_offsetDistance == 0) then {
		+_centerPos
	} else {
		_centerPos getPos [
			abs _offsetDistance,
			_referenceDir + (if (_offsetDistance < 0) then {270} else {90})
		]
	};

	if ((count _centerPos) > 2) then {
		_slotPos set [2, _centerPos select 2];
	};

	_landingSlots pushBack [_x, _slotPos];
} forEach _helicopters;

_landingSlots
// A3C_ai_shared_fnc_getHeliGroupLandingSlots

params [
	"_group",
	"_centerPos",
	["_spacing", 30],
	["_referenceVehicle", objNull],
	["_referenceDir", -1],
	["_safeSearchRadius", -1]
];

if (_safeSearchRadius < 0) then {
	_safeSearchRadius = _group getVariable ["A3C_HELI_LANDING_SAFE_RADIUS", 25];
};

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

private _referenceDriver = driver _referenceVehicle;
private _referenceFormationPos = if (!isNull _referenceDriver) then {
	formationPosition _referenceDriver
} else {
	[]
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

private _fnc_getFallbackSlotPos = {
	params ["_index", "_centerPos", "_referenceDir", "_spacing"];

	private _offsetIndex = [_index] call _fnc_getOffsetIndex;
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

	_slotPos
};

private _fnc_getSafeSlotPos = {
	params ["_slotPos", "_centerPos", "_safeSearchRadius"];

	private _safeSlotPos = +_slotPos;

	if (_safeSearchRadius > 0 && {!(isNil "MCSS_fnc_getSafePos")}) then {
		private _foundPos = [_slotPos, _safeSearchRadius] call MCSS_fnc_getSafePos;

		if (_foundPos isNotEqualTo []) then {
			_safeSlotPos = +_foundPos;
		};
	};

	if ((count _centerPos) > 2) then {
		_safeSlotPos set [2, _centerPos select 2];
	};

	_safeSlotPos
};

private _landingSlots = [];

{
	private _vehicle = _x;
	private _slotPos = [];

	if (_forEachIndex == 0) then {
		_slotPos = +_centerPos;
	} else {
		private _driver = driver _vehicle;

		if (
			!isNull _driver &&
			{_referenceFormationPos isNotEqualTo []}
		) then {
			private _formationPos = formationPosition _driver;

			private _offset = [
				(_formationPos select 0) - (_referenceFormationPos select 0),
				(_formationPos select 1) - (_referenceFormationPos select 1),
				0
			];

			private _offsetDistance = vectorMagnitude _offset;

			if (_offsetDistance > 5) then {
				private _scale = (_offsetDistance max _spacing) / _offsetDistance;

				_slotPos = [
					(_centerPos select 0) + ((_offset select 0) * _scale),
					(_centerPos select 1) + ((_offset select 1) * _scale),
					if ((count _centerPos) > 2) then {_centerPos select 2} else {0}
				];
			};
		};

		if (_slotPos isEqualTo []) then {
			_slotPos = [
				_forEachIndex,
				_centerPos,
				_referenceDir,
				_spacing
			] call _fnc_getFallbackSlotPos;
		};
	};

	if ((count _centerPos) > 2) then {
		_slotPos set [2, _centerPos select 2];
	};

	_slotPos = [
		_slotPos,
		_centerPos,
		_safeSearchRadius
	] call _fnc_getSafeSlotPos;

	_landingSlots pushBack [_vehicle, _slotPos];
} forEach _helicopters;

_landingSlots
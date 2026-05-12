// A3C_ai_shared_fnc_actionIrStrobeLoop

params [
	["_unit", objNull, [objNull]],
	["_strobeObject", objNull, [objNull]]
];

if (isNull _unit || {isNull _strobeObject}) exitWith {};

private _currentMode = "NONE";
private _deadPickupBlocked = false;

private _fnc_detach = {
	params ["_strobeObject"];

	if (!isNull _strobeObject) then {
		detach _strobeObject;
	};
};

private _fnc_cleanup = {
	params ["_unit", "_strobeObject"];

	if (!isNull _strobeObject) then {
		deleteVehicle _strobeObject;
	};

	if (!isNull _unit) then {
		_unit setVariable ["A3C_STROBE", [], true];
	};
};

while {!isNull _strobeObject} do {
	if (isNull _unit) exitWith {
		[_unit, _strobeObject] call _fnc_cleanup;
	};

	private _vehicle = vehicle _unit;

	if (!alive _unit) exitWith {
		[_unit, _strobeObject] call _fnc_cleanup;
	};

	/*
		Passenger / cargo / non-driver case:
		hide the strobe while the unit is inside a vehicle but not driving.
	*/
	if (!isNull objectParent _unit && {_unit != driver _vehicle}) then {
		if (_currentMode != "HIDDEN") then {
			_currentMode = "HIDDEN";
			[_strobeObject, true] remoteExecCall ["hideObjectGlobal", 2];
			[_strobeObject] call _fnc_detach;
		};

		waitUntil {
			sleep 1;
			isNull _strobeObject ||
			{!alive _unit} ||
			{isNull objectParent _unit} ||
			{_unit == driver vehicle _unit}
		};

		if (!isNull _strobeObject) then {
			[_strobeObject, false] remoteExecCall ["hideObjectGlobal", 2];
		};

		_currentMode = "NONE";
	};

	if (isNull _strobeObject || {!alive _unit}) exitWith {
		[_unit, _strobeObject] call _fnc_cleanup;
	};

	_vehicle = vehicle _unit;

	/*
		Driver case:
		attach the strobe to the vehicle.
	*/
	if (!isNull objectParent _unit && {_unit == driver _vehicle}) then {
		if (_currentMode != "VEHICLE") then {
			_currentMode = "VEHICLE";

			[_strobeObject] call _fnc_detach;

			private _vehicleLength = ((boundingBoxReal _vehicle) select 1) select 1;
			private _targetPos = [];
			private _attachPosFound = false;

			for "_i" from 1.5 to 3 step 0.5 do {
				private _tries = 0;

				while {alive _vehicle && {_tries <= 20}} do {
					private _aslVehiclePos = getPosASL _vehicle;
					private _height = _aslVehiclePos select 2;

					private _candidatePos = _aslVehiclePos getPos [
						_vehicleLength / _i,
						(getDir _vehicle) + 180
					];

					_candidatePos set [2, _height];

					private _refPos = +_candidatePos;
					_refPos set [
						2,
						(_candidatePos select 2) + ((((boundingBoxReal _vehicle) select 1) select 2) * 2)
					];

					private _hits = lineIntersectsSurfaces [
						_refPos,
						_candidatePos,
						objNull,
						objNull,
						true,
						1,
						"GEOM",
						"NONE"
					];

					if (
						count _hits > 0 &&
						{((_hits select 0) select 2) == _vehicle}
					) exitWith {
						_targetPos = ASLToATL ((_hits select 0) select 0);
						_attachPosFound = true;
					};

					_tries = _tries + 1;
					sleep 0.1;
				};

				if (_attachPosFound || {isNull _strobeObject}) exitWith {};
			};

			if (_attachPosFound && {!isNull _strobeObject}) then {
				private _modelPos = _vehicle worldToModel _targetPos;
				_strobeObject attachTo [_vehicle, _modelPos];
			};
		};
	} else {
		/*
			On-foot case:
			attach the strobe to the unit.
		*/
		if (_currentMode != "UNIT") then {
			_currentMode = "UNIT";

			[_strobeObject] call _fnc_detach;

			private _attachPos = if (isPlayer _unit) then {
				[0.034, -0.2, 0.02]
			} else {
				[0.094, -0.1, 0.02]
			};

			_strobeObject attachTo [_unit, _attachPos, "neck"];
		};
	};

	sleep 1;
};
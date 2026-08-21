// A3C_ai_squad_fnc_boarding_finishUnitAssignment

/*
	Finishes or cancels one unit assignment if the request ID is still current.
	Stale trackers must never remove the state belonging to a newer request.
*/

params [
	["_unit", objNull, [objNull]],
	["_requestId", -1, [0]],
	["_unassign", false, [false]],
	["_buttonColor", [], [[]]],
	["_fallbackAssignment", [], [[]]]
];

private _unitIsNull = isNull _unit;
private _assignmentData = if (_unitIsNull) then {
	[]
} else {
	_unit getVariable [
		"A3C_assignedVehicleSeat",
		[]
	]
};

private _requestIsCurrent =
	!_unitIsNull
	&& {_assignmentData isNotEqualTo []}
	&& {_assignmentData param [3, -1] == _requestId};

private _cleaningDeletedUnit =
	_unitIsNull
	&& {count _fallbackAssignment >= 4};

if (!_requestIsCurrent && {!_cleaningDeletedUnit}) exitWith {
	false
};

private _vehicle = objNull;
private _role = "";
private _seatIndexPath = -2;
private _buttonImageControl = controlNull;

if (_requestIsCurrent) then {
	_assignmentData params [
		"_storedVehicle",
		"_storedRole",
		"_storedSeatIndexPath",
		"_storedRequestId",
		"_storedButtonImageControl"
	];

	_vehicle = _storedVehicle;
	_role = _storedRole;
	_seatIndexPath = _storedSeatIndexPath;
	_buttonImageControl = _storedButtonImageControl;

	_unit setVariable [
		"A3C_assignedVehicleSeat",
		nil
	];

	_unit setVariable [
		"A3C_boardingRequestId",
		nil,
		true
	];

	_unit setVariable [
		"A3C_boardingScript",
		nil
	];
} else {
	_fallbackAssignment params [
		"_fallbackVehicle",
		"_fallbackRole",
		"_fallbackSeatIndexPath",
		"_fallbackButtonImageControl"
	];

	_vehicle = _fallbackVehicle;
	_role = _fallbackRole;
	_seatIndexPath = _fallbackSeatIndexPath;
	_buttonImageControl = _fallbackButtonImageControl;
};

_role = toLower _role;

A3C_BOARD_UNITS_ACTIVE = A3C_BOARD_UNITS_ACTIVE select {
	!isNull _x
	&& {_x != _unit}
};

if (!isNull _vehicle) then {
	private _assignedVehicleCrew = _vehicle getVariable [
		"A3C_AssignedVehicleCrew",
		[]
	];

	_assignedVehicleCrew = _assignedVehicleCrew select {
		private _row = _x;
		private _rowUnit = _row param [0, objNull];

		!(
			(
				(_requestIsCurrent && {_rowUnit == _unit})
				|| {_cleaningDeletedUnit && {isNull _rowUnit}}
			)
			&& {toLower (_row param [1, ""]) == _role}
			&& {(_row param [2, -2]) isEqualTo _seatIndexPath}
		)
	};

	_vehicle setVariable [
		"A3C_AssignedVehicleCrew",
		_assignedVehicleCrew,
		true
	];
};

if (
	_unassign
	&& {_requestIsCurrent}
	&& {alive _unit}
	&& {!isNull _vehicle}
) then {
	if (objectParent _unit == _vehicle) then {
		[_unit] spawn A3C_ai_shared_fnc_unitGetOut;
	} else {
		if (assignedVehicle _unit == _vehicle) then {
			private _wasStillGettingIn =
				currentCommand _unit == "GET IN";

			_unit remoteExecCall [
				"unassignVehicle",
				_unit
			];

			if (_wasStillGettingIn) then {
				[
					_unit,
					position _unit
				] call A3C_ai_shared_fnc_doMove;
			};
		};
	};
};

if (
	_buttonColor isNotEqualTo []
	&& {!isNull _buttonImageControl}
) then {
	_buttonImageControl ctrlSetTextColor _buttonColor;
};

true

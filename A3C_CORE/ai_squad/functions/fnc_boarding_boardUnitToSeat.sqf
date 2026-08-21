// A3C_ai_squad_fnc_boarding_boardUnitToSeat

/*
	Owns one unit's boarding lifecycle. The engine-order transaction itself is
	serialized by the shared boardUnitsToVehicle queue.
*/

params [
	"_unit",
	"_vehicle",
	"_role",
	"_seatIndexPath",
	"_buttonImageControl",
	"_requestId",
	["_queueCompletionState", [], [[]]]
];

private _fnc_requestIsCurrent = {
	if (isNull _unit) exitWith {
		false
	};

	private _assignmentData = _unit getVariable [
		"A3C_assignedVehicleSeat",
		[]
	];

	_assignmentData param [3, -1] == _requestId
};

private _fallbackAssignment = [
	_vehicle,
	_role,
	if (_seatIndexPath isEqualType []) then {
		+_seatIndexPath
	} else {
		_seatIndexPath
	},
	_buttonImageControl
];

private _fnc_finishDeletedUnit = {
	[
		_unit,
		_requestId,
		false,
		[1, 1, 1, 1],
		_fallbackAssignment
	] call A3C_ai_squad_fnc_boarding_finishUnitAssignment;
};

if (isNull _unit) exitWith {
	call _fnc_finishDeletedUnit;
};

if !(call _fnc_requestIsCurrent) exitWith {};

//-- Abort the complete plot and let its owner perform its own cleanup.
if ((_unit getVariable ["A3C_PLOT", []]) isNotEqualTo []) then {
	[
		[_unit],
		true,
		false
	] call A3C_ai_shared_fnc_cancelUnitPlot;

	private _plotAbortTimeoutAt = diag_tickTime + 10;

	waitUntil {
		!(call _fnc_requestIsCurrent)
		|| {(_unit getVariable ["A3C_PLOT", []]) isEqualTo []}
		|| {diag_tickTime >= _plotAbortTimeoutAt}
	};

	if (isNull _unit) exitWith {
		call _fnc_finishDeletedUnit;
	};

	if !(call _fnc_requestIsCurrent) exitWith {};

	if ((_unit getVariable ["A3C_PLOT", []]) isNotEqualTo []) exitWith {
		[
			_unit,
			_requestId,
			true,
			[1, 1, 1, 1]
		] call A3C_ai_squad_fnc_boarding_finishUnitAssignment;
	};
};

if !(call _fnc_requestIsCurrent) exitWith {};

if (_queueCompletionState isEqualTo []) then {
	_queueCompletionState = [
		[
			[
				_unit,
				_role,
				_seatIndexPath,
				_requestId
			]
		],
		_vehicle
	] call A3C_ai_squad_fnc_boarding_queueBoardUnitsToVehicle;
};

waitUntil {
	!(call _fnc_requestIsCurrent)
	|| {_queueCompletionState param [0, false]}
	|| {isNull _unit}
	|| {!alive _unit}
	|| {isNull _vehicle}
	|| {!alive _vehicle}
};

if (isNull _unit) exitWith {
	call _fnc_finishDeletedUnit;
};

if !(call _fnc_requestIsCurrent) exitWith {};

if (
	!alive _unit
	|| {isNull _vehicle}
	|| {!alive _vehicle}
) exitWith {
	[
		_unit,
		_requestId,
		true,
		[1, 1, 1, 1]
	] call A3C_ai_squad_fnc_boarding_finishUnitAssignment;
};

private _queueResult = _queueCompletionState param [1, [[], []]];
private _failedUnits = _queueResult param [1, []];

if (_unit in _failedUnits) exitWith {
	[
		_unit,
		_requestId,
		true,
		[1, 1, 1, 1]
	] call A3C_ai_squad_fnc_boarding_finishUnitAssignment;
};

//-- The protected transaction is complete. Track this unit's engine-owned
//-- boarding process independently of the serialization queue.
//
//-- The grace period prevents a brief command-state transition immediately
//-- before entering the vehicle from being interpreted as cancellation.
private _getInCommandLostAt = -1;
private _getInCommandLossGrace = 0.75;
private _boardingCommandCancelled = false;

waitUntil {
	private _requestIsStillCurrent =
		call _fnc_requestIsCurrent;

	private _unitInvalid =
		isNull _unit
		|| {!alive _unit};

	private _vehicleInvalid =
		isNull _vehicle
		|| {!alive _vehicle};

	if (
		_requestIsStillCurrent
		&& {!_unitInvalid}
		&& {!_vehicleInvalid}
	) then {
		private _boardedTargetVehicle =
			vehicle _unit == _vehicle;

		private _assignedToTargetVehicle =
			assignedVehicle _unit == _vehicle;

		private _hasGetInCommand =
			currentCommand _unit == "GET IN";

		if (
			!_boardedTargetVehicle
			&& {_assignedToTargetVehicle}
			&& {!_hasGetInCommand}
		) then {
			if (_getInCommandLostAt < 0) then {
				_getInCommandLostAt = diag_tickTime;
			};

			if (
				diag_tickTime - _getInCommandLostAt
				>= _getInCommandLossGrace
			) then {
				_boardingCommandCancelled = true;
			};
		} else {
			_getInCommandLostAt = -1;
		};
	};

	!_requestIsStillCurrent
	|| {_unitInvalid}
	|| {_vehicleInvalid}
	|| {vehicle _unit == _vehicle}
	|| {assignedVehicle _unit != _vehicle}
	|| {_boardingCommandCancelled}
};

if (isNull _unit) exitWith {
	call _fnc_finishDeletedUnit;
};

if !(call _fnc_requestIsCurrent) exitWith {};

if (
	!alive _unit
	|| {isNull _vehicle}
	|| {!alive _vehicle}
) exitWith {
	[
		_unit,
		_requestId,
		true,
		[1, 1, 1, 1]
	] call A3C_ai_squad_fnc_boarding_finishUnitAssignment;
};

private _boardedTargetVehicle =
	vehicle _unit == _vehicle;

private _shouldUnassign =
	!_boardedTargetVehicle
	&& {assignedVehicle _unit == _vehicle};

private _buttonColor = if (_boardedTargetVehicle) then {
	[
		A3C_UI_COLOR_BLUE,
		0.7
	] call A3C_ui_shared_fnc_getColorArrayWithOpacity
} else {
	[1, 1, 1, 1]
};

[
	_unit,
	_requestId,
	_shouldUnassign,
	_buttonColor
] call A3C_ai_squad_fnc_boarding_finishUnitAssignment;
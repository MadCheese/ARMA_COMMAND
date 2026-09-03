// A3C_ai_squad_fnc_boarding_queueBoardUnitsToVehicle

/*
	Queues one protected boarding transaction.

	A queue entry is complete when
	A3C_ai_squad_fnc_boarding_boardUnitsToVehicle returns, which means the
	player has been restored to the original group. Physical vehicle entry is
	not part of this queue's completion contract.

	Returns a mutable completion array:
	[
		_done,
		_result
	]

	_result is the value returned by
	A3C_ai_squad_fnc_boarding_boardUnitsToVehicle.
*/

params [
	["_unitsAndRoles", [], [[]]],
	["_vehicle", objNull, [objNull]]
];

//-- Take a real snapshot. Callers, especially the radial menu, may clear or
//-- reuse their source arrays immediately after submitting the request.
private _unitsAndRolesSnapshot = _unitsAndRoles apply {
	if (_x isEqualType []) then {
		private _rowSnapshot = +_x;

		if (
			count _rowSnapshot > 2
			&& {(_rowSnapshot select 2) isEqualType []}
		) then {
			_rowSnapshot set [2, +(_rowSnapshot select 2)];
		};

		_rowSnapshot
	} else {
		_x
	}
};

private _completionState = [false, []];

A3C_BOARDING_QUEUE pushBack [
	_unitsAndRolesSnapshot,
	_vehicle,
	_completionState
];

if (!A3C_BOARDING_QUEUE_ACTIVE) then {
	A3C_BOARDING_QUEUE_ACTIVE = true;

	if (sentencesEnabled) then {
		player groupRadio "SentCmdGetIn";
	};

	[] spawn A3C_ai_squad_fnc_boarding_processBoardUnitsToVehicleQueue;
};

_completionState

// A3C_ai_squad_fnc_boarding_processBoardUnitsToVehicleQueue

/*
	Serial queue worker for the player-group boarding hack.

	There must never be more than one active instance of
	A3C_ai_squad_fnc_boarding_boardUnitsToVehicle. Calling it here rather than
	spawning it makes its return the exact serialization barrier.
*/

while {A3C_BOARDING_QUEUE isNotEqualTo []} do {
	private _task = A3C_BOARDING_QUEUE deleteAt 0;

	_task params [
		"_unitsAndRoles",
		"_vehicle",
		"_completionState"
	];

	private _result = [
		_unitsAndRoles,
		_vehicle
	] call A3C_ai_squad_fnc_boarding_boardUnitsToVehicle;

	if !(
		_result isEqualType []
		&& {count _result >= 2}
	) then {
		_result = [
			[],
			_unitsAndRoles apply {
				_x param [0, objNull]
			}
		];
	};

	_completionState set [1, _result];
	_completionState set [0, true];
};

A3C_BOARDING_QUEUE_ACTIVE = false;

/*
	A request can arrive after the while-condition sees an empty queue but
	before the active flag is cleared. Recheck after releasing the worker so
	that such a request cannot be stranded.
*/
if (
	A3C_BOARDING_QUEUE isNotEqualTo []
	&& {!A3C_BOARDING_QUEUE_ACTIVE}
) then {
	A3C_BOARDING_QUEUE_ACTIVE = true;

	[] spawn A3C_ai_squad_fnc_boarding_processBoardUnitsToVehicleQueue;
};

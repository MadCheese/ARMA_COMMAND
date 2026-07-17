// A3C_ai_squad_fnc_assignPlayerToVehicleCargo

// Assigns the player to vehicle cargo.
// Used by the action menu/FSM for self-assignment to a squad-level landing helicopter.
params ["_mode"];

private _vehicle = cursorTarget;

if (isNull cursorTarget) exitWith {};

player removeAction A3C_assign_action_playerToVehicle;

switch (_mode) do {
	case 0: {
		player remoteExec ["unassignVehicle", 0];
	};

	case 1: {
		private _cargoCrew = fullCrew [
			_vehicle,
			"cargo",
			true
		];

		private _cargoIndex = 0;

		{
			private _crewData = _x;
			private _occupant = _crewData select 0;

			if (
				isNull _occupant
				|| {!alive _occupant}
			) then {
				_cargoIndex = _crewData select 2;
			};
		} forEach _cargoCrew;

		player assignAsCargoIndex [
			_vehicle,
			_cargoIndex
		];
	};
};
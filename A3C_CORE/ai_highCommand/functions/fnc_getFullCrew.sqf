// A3C_ai_highCommand_fnc_getFullCrew

params ["_vehicle"];

private _assignedCrew = _vehicle getVariable ["A3C_AssignedVehicleCrew", []];

private _emptyPositions = (
	(fullCrew [_vehicle, "driver", true]) +
	(fullCrew [_vehicle, "gunner", true]) +
	(fullCrew [_vehicle, "commander", true]) +
	(fullCrew [_vehicle, "turret", true]) +
	(fullCrew [_vehicle, "cargo", true])
);

_emptyPositions = _emptyPositions select {
	_x params ["_occupyingUnit", "_role", "_cargoIndex", "_turretPath"];

	private _seatIndexPath = if (toLower _role == "turret") then {
		_turretPath
	} else {
		_cargoIndex
	};

	(isNull _occupyingUnit || {!alive _occupyingUnit}) &&
	{
		({
			_x params ["_refUnit", "_refRole", "_refSeatIndex"];

			!(_refUnit in _boardUnits) &&
			{
				[_role, _seatIndexPath] isEqualTo [_refRole, _refSeatIndex]
			}
		} count _assignedCrew) == 0
	}
};

_emptyPositions
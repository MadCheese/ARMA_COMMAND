// A3C_ai_highCommand_fnc_assignGroupToVehicle

params ["_boardGroups", "_selectedVehicle"];

private _vehicleDriver = driver _selectedVehicle;

_boardGroups = if (_boardGroups isEqualType []) then {
	_boardGroups
} else {
	[_boardGroups]
};

private _successfulBoardGroups = [];

{
	private _boardGroup = _x;
	private _boardGroupLeader = leader _boardGroup;

	private _assignedVehicleCrew = _selectedVehicle getVariable ["A3C_AssignedVehicleCrew", []];
	private _boardUnits = (units _boardGroup) select {isNull objectParent _x};

	private _emptyPositions = [_selectedVehicle] call A3C_HC_getFullCrew;

	if (count _boardUnits > 0 && {count _boardUnits <= count _emptyPositions}) then {
		{
			private _unit = _x;
			private _seatData = _emptyPositions select _forEachIndex;

			_seatData params ["_occupyingUnit", "_role", "_cargoIndex", "_turretPath"];

			private _roleLower = toLower _role;
			private _seatValue = if (_roleLower == "cargo") then {
				_cargoIndex
			} else {
				_turretPath
			};

			private _command = "";
			private _commandParams = "";

			switch (_roleLower) do {
				case "driver": {
					_command = "assignAsDriver";
					_commandParams = _selectedVehicle;
				}; //-- assignAsX commands are global

				case "gunner": {
					_command = "assignAsGunner";
					_commandParams = _selectedVehicle;
				};

				case "commander": {
					_command = "assignAsCommander";
					_commandParams = _selectedVehicle;
				};

				case "turret": {
					_command = "assignAsTurret";
					_commandParams = [_selectedVehicle, _seatValue];
				};

				case "cargo": {
					_command = "assignAsCargoIndex";
					_commandParams = [_selectedVehicle, _seatValue];
				};
			};

			[_unit, _commandParams] remoteExec [_command, _unit];

			_assignedVehicleCrew pushBack [_unit, _role, _seatValue];

			[_unit, _selectedVehicle] spawn {
				params ["_unit", "_selectedVehicle"];

				while {alive _unit} do {
					if (assignedVehicle _unit != _selectedVehicle || {_unit in _selectedVehicle}) exitWith {};
					sleep 1;
				};

				private _assignedVehicleCrew = _selectedVehicle getVariable ["A3C_AssignedVehicleCrew", []];

				{
					if (_x select 0 == _unit) exitWith {
						_assignedVehicleCrew deleteAt _forEachIndex;
					};
				} forEach _assignedVehicleCrew;

				_selectedVehicle setVariable ["A3C_AssignedVehicleCrew", _assignedVehicleCrew, true];
			};
		} forEach _boardUnits;

		_selectedVehicle setVariable ["A3C_AssignedVehicleCrew", _assignedVehicleCrew, true];
		_boardGroup setVariable ["A3C_AssignedGroupVehicle", _selectedVehicle, true];

		[_boardUnits, true] remoteExec ["allowGetIn", _boardGroupLeader];
		[_boardUnits, true] remoteExec ["orderGetIn", _boardGroupLeader];

		_successfulBoardGroups pushBack _boardGroup;
	} else {
		systemChat format [
			"A3C: %1 does not have space for %2",
			groupID (group _vehicleDriver),
			groupID _boardGroup
		];

		_boardGroup setVariable ["A3C_AssignedGroupVehicle", nil, true];
	};
} forEach _boardGroups;

private _successfulBoardCount = count _successfulBoardGroups;

if (_successfulBoardCount > 0) then {
	private _groupString = "";

	{
		private _preString = "";
		private _postString = "";

		if (_forEachIndex == (_successfulBoardCount - 1)) then {
			if (_successfulBoardCount > 1) then {
				_preString = " and ";
			};
		} else {
			if (_forEachIndex < (_successfulBoardCount - 2)) then {
				_postString = ", ";
			};
		};

		_groupString = _groupString + _preString + groupID _x + _postString;
	} forEach _successfulBoardGroups;

	if (!isNull _vehicleDriver) then {
		systemChat format [
			"A3C: %1 is boarding %2",
			_groupString,
			groupID (group _vehicleDriver)
		];
	} else {
		systemChat format [
			"A3C: %1 %2 boarding a %3",
			_groupString,
			if (_successfulBoardCount == 1) then {"is"} else {"are"},
			getText (configFile >> "CfgVehicles" >> typeOf _selectedVehicle >> "displayName")
		];
	};
};

A3C_Boarding_ACTIVE = false;
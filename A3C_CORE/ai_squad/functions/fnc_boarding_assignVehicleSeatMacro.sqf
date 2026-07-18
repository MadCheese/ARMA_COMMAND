// A3C_ai_squad_fnc_boarding_assignVehicleSeatMacro

//-- macro button fnc: mount/dismount multiple units at once

params ["_vehicle", "_boardingType", "_btn", "_refUnits"];

_refUnits = +_refUnits;

private _vehicleSeatData = [];

//-- re-arrange
{
	private _testedRole = _x;

	{
		if ((_x select 1) == _testedRole) then {
			_vehicleSeatData pushBackUnique _x;
		};
	} forEach (fullCrew [_vehicle, "", true]);
} forEach ["driver", "gunner", "commander", "Turret", "cargo"];

private _suitableUnits = _refUnits select {
	isNull objectParent _x
};

if (_btn == 0) then {
	_suitableUnits = _suitableUnits select {
		count (_x getVariable ["A3C_assignedVehicleSeat", []]) == 0
	};
};

private _currentBtnImage = 10101;
private _assignedVehicleCrew = _vehicle getVariable ["A3C_AssignedVehicleCrew", []];

{
	private _roleData = _x;

	if (count _suitableUnits == 0) exitWith {};

	_roleData params ["_occupyingUnit", "_role", "_cargoIndex", "_turretPath", "_isFFV"];

	if (_boardingType == "all" OR {_role == "cargo" || {_boardingType == "cargoFFV" && _isFFV}}) then {
		if (isNull _occupyingUnit OR {!alive _occupyingUnit}) then {
			private _refArray = _roleData select [1, 3];

			{
				private _boardingData = _x;

				if ({_x in _boardingData} count _refArray >= 2) exitWith {
					_occupyingUnit = _x select 0;

					private _buttonColor = if (group _occupyingUnit == group player) then {
						[A3C_UI_COLOR_BLUE, 0.3] call A3C_ui_shared_fnc_getColorArrayWithOpacity
					} else {
						[A3C_UI_COLOR_RED, 0.3] call A3C_ui_shared_fnc_getColorArrayWithOpacity
					};
				};
			} forEach _assignedVehicleCrew;
		};

		if (_btn == 0) then {
			if (isNull _occupyingUnit OR {!alive _occupyingUnit}) then {
				private _boardUnit = _suitableUnits select 0;

				[_roleData, _btn, _currentBtnImage, _boardUnit, _refUnits, _vehicle] call A3C_ai_squad_fnc_boarding_assignVehicleSeatSingle;
				_suitableUnits = _suitableUnits - [_boardUnit];

				sleep 0.3;
			};
		} else {
			if (_occupyingUnit in units player) then {
				[_roleData, _btn, _currentBtnImage, _occupyingUnit, _refUnits, _vehicle] call A3C_ai_squad_fnc_boarding_assignVehicleSeatSingle;
			};
		};
	};

	sleep 0.1;

	_currentBtnImage = _currentBtnImage + 2;
} forEach _vehicleSeatData;
#include "..\..\ui\radial\radialMenu\dialog_defines.hpp"

// A3C_ai_squad_fnc_boarding_assignVehicleSeatSingle

// Assigns an individual vehicle seat. Called from a seat button or board-all logic.
params [
	"_roleData",
	"_mouseButton",
	"_buttonImageIdc",
	"_specifiedUnit",
	"_referenceUnits",
	"_vehicle"
];

_roleData params [
	"_occupyingUnit",
	"_role",
	"_cargoIndex",
	"_turretPath",
	"_isFFV"
];

private _buttonImageControl = (findDisplay IDD_RADIAL_MENU) displayCtrl _buttonImageIdc;

if (isNil "_vehicle") then {
	_vehicle = A3C_TARGETVEH;
};

if (isNil "_referenceUnits") then {
	_referenceUnits = A3C_RD_UNITS;
};

if (count _referenceUnits == 0) exitWith {};

private _fnc_unassignSeat = {
	params [
		"_unit",
		"_buttonImageControl",
		"_assignmentData"
	];

	_assignmentData params [
		"_vehicle",
		"_role",
		"_seatIndexPath",
		"_boardingScript",
		"_image"
	];

	if (count _assignmentData > 0) then {
		if (typeName _boardingScript != "STRING") then {
			terminate _boardingScript;
		};

		[
			[_unit],
			A3C_ai_shared_fnc_unitGetOut
		] remoteExec ["BIS_fnc_call", _unit];

		if (
			A3C_RADIALMODE == "VEHS"
			&& {A3C_TARGETVEH == _vehicle}
		) then {
			_buttonImageControl ctrlSetTextColor [1, 1, 1, 1];
		};

		_unit setVariable ["A3C_assignedVehicleSeat", nil];

		waitUntil {
			isNull objectParent _unit
		};

		_unit doMove position _unit;
	};
};

// Right mouse button: dismount a unit from the player's group.
if (_mouseButton == 1) exitWith {
	if (_occupyingUnit in units player) then {
		if (_occupyingUnit in _vehicle) then {
			_occupyingUnit remoteExec ["unassignVehicle", 0];
			doGetOut _occupyingUnit;

			_buttonImageControl ctrlSetTextColor [1, 1, 1, 1];
		} else {
			if (typeName _occupyingUnit == "OBJECT") then {
				// The unit belongs to the player's group but has not boarded yet.
				private _assignmentData = _occupyingUnit getVariable [
					"A3C_assignedVehicleSeat",
					[]
				];

				[
					_occupyingUnit,
					_buttonImageControl,
					_assignmentData
				] spawn _fnc_unassignSeat;
			};
		};
	} else {
		{
			private _candidateUnit = _x;
			private _assignmentData = _candidateUnit getVariable [
				"A3C_assignedVehicleSeat",
				[]
			];

			private _matchesSeat = (
				count _assignmentData > 0
				&& {(_assignmentData select 0) == _vehicle}
				&& {
					{
						_x in _roleData
					} count (_assignmentData select [1, 2]) == 2
				}
			) || {
				// The unit entered the selected seat while the menu remained open.
				switch (_role) do {
					case "driver": {
						_candidateUnit == driver _vehicle
					};
					case "gunner": {
						_candidateUnit == gunner _vehicle
					};
					case "commander": {
						_candidateUnit == commander _vehicle
					};
					case "Turret": {
						_candidateUnit == (_vehicle turretUnit _turretPath)
					};
					case "cargo": {
						_cargoIndex == (_vehicle getCargoIndex _candidateUnit)
					};
				};
			};

			if (_matchesSeat) exitWith {
				if (_assignmentData isEqualTo []) then {
					_assignmentData = [
						_vehicle,
						_role,
						-1,
						"",
						""
					];
				};

				[
					_candidateUnit,
					_buttonImageControl,
					_assignmentData
				] spawn _fnc_unassignSeat;
			};
		} forEach units player;
	};
};

_buttonImageControl ctrlSetTextColor (
	[
		A3C_UI_COLOR_BLUE,
		0.3
	] call A3C_ui_shared_fnc_getColorArrayWithOpacity
);

private _assignedVehicleCrew = _vehicle getVariable [
	"A3C_AssignedVehicleCrew",
	[]
];

private _isSeatOccupied = (
	typeName _occupyingUnit == "OBJECT"
	&& {!isNull _occupyingUnit}
	&& {alive _occupyingUnit}
) || {
	typeName _occupyingUnit == "SCALAR"
	&& {_occupyingUnit == 1}
};

{
	private _boardingData = _x;

	if (
		{
			_x in _boardingData
		} count [
			_role,
			_cargoIndex,
			_turretPath
		] >= 2
	) then {
		_isSeatOccupied = true;
	};
} forEach _assignedVehicleCrew;

if (_isSeatOccupied) exitWith {};

private _seatIndexPath = if (_role in ["driver", "cargo"]) then {
	_cargoIndex
} else {
	_turretPath
};

if (!isNull _specifiedUnit) then {
	// A particular unit was supplied.
	if (isPlayer _specifiedUnit) then {
		// Players cannot be automatically assigned.
		_specifiedUnit = objNull;
	} else {
		private _unitBoardingData = _specifiedUnit getVariable [
			"A3C_assignedVehicleSeat",
			[]
		];

		// Override an existing assignment that has not yet boarded.
		if (
			isNull objectParent _specifiedUnit
			&& {count _unitBoardingData > 0}
		) then {
			_x remoteExec ["unassignVehicle", 0];

			terminate (_unitBoardingData select 3);

			_specifiedUnit setVariable [
				"A3C_assignedVehicleSeat",
				nil,
				true
			];

			_specifiedUnit setVariable [
				"A3C_PLOT_TEMP",
				[],
				false
			];

			_specifiedUnit setVariable [
				"A3C_PLOT",
				[],
				true
			];
		};
	};
} else {
	// Filter suitable units for both single-unit and multi-unit selections.
	private _suitableUnits = _referenceUnits select {
		!isPlayer _x
		&& {isNull objectParent _x}
		&& {
			count (
				_x getVariable [
					"A3C_assignedVehicleSeat",
					[]
				]
			) == 0
		}
	};

	if (count _suitableUnits > 0) then {
		_specifiedUnit = _suitableUnits select 0;
	} else {
		_specifiedUnit = _referenceUnits select 0;
	};
};

if (isNull _specifiedUnit) exitWith {};

// Override the unit's previous seat assignment.
private _previousAssignment = _specifiedUnit getVariable [
	"A3C_assignedVehicleSeat",
	[]
];

if (count _previousAssignment > 0) then {
	_previousAssignment params [
		"_previousVehicle",
		"_previousRole",
		"_previousSeatIndexPath",
		"_previousBoardingScript",
		"_previousButtonImageControl"
	];

	_specifiedUnit doMove position _specifiedUnit;

	terminate _previousBoardingScript;

	private _runningBoardingScripts = _specifiedUnit getVariable [
		"A3C_boardingScript",
		[]
	];

	if (count _runningBoardingScripts > 0) then {
		terminate (_runningBoardingScripts select 0);
	};

	if (
		A3C_RADIALMODE == "VEHS"
		&& {A3C_TARGETVEH == _previousVehicle}
	) then {
		_previousButtonImageControl ctrlSetTextColor [1, 1, 1, 1];
	};

	_specifiedUnit setVariable ["A3C_boardingScript", nil];
	_specifiedUnit setVariable ["A3C_assignedVehicleSeat", nil];

	{
		private _assignedCrewData = _x;

		if (_specifiedUnit == (_assignedCrewData select 0)) then {
			_assignedVehicleCrew = _assignedVehicleCrew - [_assignedCrewData];
		};
	} forEach _assignedVehicleCrew;

	_vehicle setVariable [
		"A3C_AssignedVehicleCrew",
		_assignedVehicleCrew,
		true
	];
};

private _boardingScript = [
	_specifiedUnit,
	_vehicle,
	_role,
	_seatIndexPath,
	_buttonImageControl
] spawn A3C_ai_squad_fnc_boarding_boardUnitToSeat;

_specifiedUnit setVariable [
	"A3C_boardingScript",
	[_boardingScript]
];
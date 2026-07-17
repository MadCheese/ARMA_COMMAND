// A3C_ai_squad_fnc_boarding_boardUnitToSeat

params [
	"_unit",
	"_vehicle",
	"_role",
	"_seatIndexPath",
	"_buttonImageControl"
];

private _playerAssignedToVehicle = assignedVehicle player == _vehicle;

[
	[_unit],
	false,
	true,
	true
] spawn A3C_ai_shared_fnc_cancelUnitPlot;

// Register the unit as having an active boarding order.
A3C_BOARD_UNITS_ACTIVE pushBackUnique _unit;

private _assignedVehicleCrew = _vehicle getVariable [
	"A3C_AssignedVehicleCrew",
	[]
];

_assignedVehicleCrew pushBack [
	_unit,
	_role,
	_seatIndexPath
];

_vehicle setVariable [
	"A3C_AssignedVehicleCrew",
	_assignedVehicleCrew,
	true
];

_unit setVariable [
	"A3C_assignedVehicleSeat",
	nil,
	true
];

_unit setVariable [
	"A3C_PLOT",
	[],
	true
];

if (
	isNull _unit
	|| {!alive _unit}
) exitWith {
	if (_unit in A3C_RD_UNITS) then {
		A3C_BOARD_UNITS pushBackUnique _unit;
	};

	_unit setVariable ["A3C_boardingScript", nil];

	{
		private _assignedCrewData = _x;

		if (_unit == (_assignedCrewData select 0)) exitWith {
			_assignedVehicleCrew =
				_assignedVehicleCrew - [_assignedCrewData];
		};
	} forEach _assignedVehicleCrew;

	_vehicle setVariable [
		"A3C_AssignedVehicleCrew",
		_assignedVehicleCrew,
		true
	];
};

sleep 0.5;

// Wait for the unit's boarding process to finish.
private _boardingScript = [
	_unit,
	_vehicle,
	[
		_role,
		_seatIndexPath
	]
] spawn A3C_ai_squad_fnc_boarding_boardingHack;

_unit setVariable [
	"A3C_assignedVehicleSeat",
	[
		_vehicle,
		_role,
		_seatIndexPath,
		_boardingScript,
		_buttonImageControl
	],
	true
];

waitUntil {
	scriptDone _boardingScript
};

_unit setVariable ["A3C_boardingScript", nil];

_assignedVehicleCrew = _vehicle getVariable [
	"A3C_AssignedVehicleCrew",
	[]
];

{
	private _assignedCrewData = _x;

	if (_unit == (_assignedCrewData select 0)) exitWith {
		_assignedVehicleCrew =
			_assignedVehicleCrew - [_assignedCrewData];
	};
} forEach _assignedVehicleCrew;

_vehicle setVariable [
	"A3C_AssignedVehicleCrew",
	_assignedVehicleCrew,
	true
];

if (
	A3C_RADIALMODE == "VEHS"
	&& {_vehicle == A3C_TARGETVEH}
) then {
	_buttonImageControl ctrlSetTextColor (
		[
			A3C_UI_COLOR_BLUE,
			0.7
		] call A3C_UI_fnc_setOpacity
	);
};

if (_playerAssignedToVehicle) then {
	player assignAsCargo _vehicle;
};

sleep 1; //-- #Unclear - why is this necessary?
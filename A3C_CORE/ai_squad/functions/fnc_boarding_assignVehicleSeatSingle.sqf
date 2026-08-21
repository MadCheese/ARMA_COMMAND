#include "..\..\ui\radial\radialMenu\dialog_defines.hpp"

// A3C_ai_squad_fnc_boarding_assignVehicleSeatSingle

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

private _roleEngine = _role;
_role = toLower _role;

private _buttonImageControl = (findDisplay IDD_RADIAL_MENU) displayCtrl _buttonImageIdc;

if (isNil "_vehicle") then {
	_vehicle = A3C_TARGETVEH;
};

if (isNil "_referenceUnits") then {
	_referenceUnits = +A3C_RD_UNITS;
} else {
	_referenceUnits = +_referenceUnits;
};

if (_referenceUnits isEqualTo [] || {isNull _vehicle}) exitWith {};

//-- Dynamically compiled seat buttons use scalar 0/1 sentinels for an empty
//-- seat or a seat occupied outside the player squad.
if !(_specifiedUnit isEqualType objNull) then {
	_specifiedUnit = objNull;
};

private _playerGroup = missionNamespace getVariable [
	"A3C_BOARDING_PLAYER_GROUP",
	grpNull
];

if (isNull _playerGroup) then {
	_playerGroup = group player;
};

private _playerGroupUnits = units _playerGroup;

private _seatIndexPath = if (_role in ["driver", "cargo"]) then {
	_cargoIndex
} else {
	+_turretPath
};

private _fnc_canonicalRole = {
	params ["_testedRole"];

	if (toLower _testedRole in ["gunner", "commander", "turret"]) then {
		"turret"
	} else {
		toLower _testedRole
	}
};

private _canonicalRole = [_role] call _fnc_canonicalRole;

private _fnc_matchesSeat = {
	params [
		"_testedRole",
		"_testedSeatIndexPath"
	];

	([_testedRole] call _fnc_canonicalRole) == _canonicalRole
	&& {_testedSeatIndexPath isEqualTo _seatIndexPath}
};

if (_mouseButton == 1) exitWith {
	private _unitToCancel = objNull;

	if (
		!isNull _specifiedUnit
		&& {_specifiedUnit in _playerGroupUnits}
		&& {!isPlayer _specifiedUnit}
	) then {
		_unitToCancel = _specifiedUnit;
	} else {
		if (
			_occupyingUnit isEqualType objNull
			&& {!isNull _occupyingUnit}
			&& {_occupyingUnit in _playerGroupUnits}
			&& {!isPlayer _occupyingUnit}
		) then {
			_unitToCancel = _occupyingUnit;
		} else {
			{
				private _candidateUnit = _x;
				private _assignmentData = _candidateUnit getVariable [
					"A3C_assignedVehicleSeat",
					[]
				];

				private _matchesPendingAssignment = false;

				if (_assignmentData isNotEqualTo []) then {
					_matchesPendingAssignment =
						(_assignmentData select 0) == _vehicle
						&& {
							[
								_assignmentData select 1,
								_assignmentData select 2
							] call _fnc_matchesSeat
						};
				};

				private _matchesOccupiedSeat = switch (_canonicalRole) do {
					case "driver": {
						_candidateUnit == driver _vehicle
					};

					case "cargo": {
						_candidateUnit in _vehicle
						&& {_vehicle getCargoIndex _candidateUnit == _seatIndexPath}
					};

					case "turret": {
						_candidateUnit == (_vehicle turretUnit _seatIndexPath)
					};

					default {
						false
					};
				};

				if (_matchesPendingAssignment || {_matchesOccupiedSeat}) exitWith {
					_unitToCancel = _candidateUnit;
				};
			} forEach _playerGroupUnits;
		};
	};

	if (!isNull _unitToCancel) then {
		private _assignmentData = _unitToCancel getVariable [
			"A3C_assignedVehicleSeat",
			[]
		];

		if (_assignmentData isNotEqualTo []) then {
			[
				_unitToCancel,
				[1, 1, 1, 1]
			] call A3C_ai_squad_fnc_boarding_cancelUnitAssignment;
		} else {
			[_unitToCancel] spawn A3C_ai_shared_fnc_unitGetOut;

			if (!isNull _buttonImageControl) then {
				_buttonImageControl ctrlSetTextColor [1, 1, 1, 1];
			};
		};
	};
};

private _assignedVehicleCrew = _vehicle getVariable [
	"A3C_AssignedVehicleCrew",
	[]
];

private _seatReserved = _assignedVehicleCrew findIf {
	[
		_x param [1, ""],
		_x param [2, -2]
	] call _fnc_matchesSeat
} != -1;

private _seatOccupied = (
	_occupyingUnit isEqualType objNull
	&& {!isNull _occupyingUnit}
	&& {alive _occupyingUnit}
) || {
	_occupyingUnit isEqualType 0
	&& {_occupyingUnit == 1}
};

if (_seatOccupied || {_seatReserved}) exitWith {};

if (!isNull _specifiedUnit) then {
	if (isPlayer _specifiedUnit) then {
		_specifiedUnit = objNull;
	};
} else {
	private _suitableUnits = _referenceUnits select {
		!isNull _x
		&& {alive _x}
		&& {!isPlayer _x}
		&& {isNull objectParent _x}
		&& {
			(_x getVariable ["A3C_assignedVehicleSeat", []]) isEqualTo []
		}
	};

	if (_suitableUnits isNotEqualTo []) then {
		_specifiedUnit = _suitableUnits select 0;
	} else {
		//-- Preserve the existing individual-seat behavior: when every
		//-- selected unit already has a pending seat, replace the first
		//-- selected unit's previous assignment.
		_specifiedUnit = _referenceUnits select 0;
	};
};

if (
	isNull _specifiedUnit
	|| {!alive _specifiedUnit}
	|| {isPlayer _specifiedUnit}
	|| {!isNull objectParent _specifiedUnit}
) exitWith {};

if ((_specifiedUnit getVariable ["A3C_assignedVehicleSeat", []]) isNotEqualTo []) then {
	[_specifiedUnit] call A3C_ai_squad_fnc_boarding_cancelUnitAssignment;
};

private _requestId = [
	_specifiedUnit,
	_vehicle,
	_roleEngine,
	_seatIndexPath,
	_buttonImageControl
] call A3C_ai_squad_fnc_boarding_registerUnitAssignment;

if (_requestId < 0) exitWith {};

if (!isNull _buttonImageControl) then {
	_buttonImageControl ctrlSetTextColor (
		[
			A3C_UI_COLOR_BLUE,
			0.3
		] call A3C_ui_shared_fnc_getColorArrayWithOpacity
	);
};

private _boardingScript = [
	_specifiedUnit,
	_vehicle,
	_roleEngine,
	_seatIndexPath,
	_buttonImageControl,
	_requestId
] spawn A3C_ai_squad_fnc_boarding_boardUnitToSeat;

_specifiedUnit setVariable [
	"A3C_boardingScript",
	[_boardingScript]
];

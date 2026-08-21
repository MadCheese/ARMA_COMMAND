#include "..\..\ui\radial\radialMenu\dialog_defines.hpp"

// A3C_ai_squad_fnc_boarding_assignVehicleSeatMacro

//-- Mount or dismount multiple units. A mount macro submits exactly one
//-- boardUnitsToVehicle queue task.

params [
	"_vehicle",
	"_boardingType",
	"_mouseButton",
	"_referenceUnits"
];

_referenceUnits = +_referenceUnits;

if (isNull _vehicle || {_referenceUnits isEqualTo []}) exitWith {};

private _playerGroup = missionNamespace getVariable [
	"A3C_BOARDING_PLAYER_GROUP",
	grpNull
];

if (isNull _playerGroup) then {
	_playerGroup = group player;
};

private _playerGroupUnits = units _playerGroup;
private _vehicleSeatData = [];

private _fnc_roleIncluded = {
	params [
		"_testedRole",
		"_isFFV"
	];

	_boardingType == "all"
	|| {
		_boardingType == "cargoFFV"
		&& {
			toLower _testedRole == "cargo"
			|| {_isFFV}
		}
	}
};

{
	private _testedRole = _x;

	{
		if (toLower (_x select 1) == _testedRole) then {
			if (
				_testedRole != "driver"
				|| {!(_vehicle isKindOf "STATICWEAPON")}
			) then {
				_vehicleSeatData pushBack _x;
			};
		};
	} forEach (fullCrew [_vehicle, "", true]);
} forEach [
	"driver",
	"gunner",
	"commander",
	"turret",
	"cargo"
];

if (_mouseButton == 1) exitWith {
	private _currentButtonImageIdc = 10101;

	{
		private _roleData = _x;
		private _occupyingUnit = _roleData select 0;
		private _role = toLower (_roleData select 1);
		private _cargoIndex = _roleData select 2;
		private _turretPath = _roleData select 3;
		private _isFFV = _roleData select 4;

		if !([_role, _isFFV] call _fnc_roleIncluded) then {
			_currentButtonImageIdc = _currentButtonImageIdc + 2;
			continue;
		};

		private _seatIndexPath = if (_role in ["driver", "cargo"]) then {
			_cargoIndex
		} else {
			_turretPath
		};
		private _canonicalRole = if (_role in ["gunner", "commander", "turret"]) then {
			"turret"
		} else {
			_role
		};

		if (isNull _occupyingUnit || {!alive _occupyingUnit}) then {
			private _engineAssignedUnit = _roleData param [5, objNull];

			if (!isNull _engineAssignedUnit && {alive _engineAssignedUnit}) then {
				_occupyingUnit = _engineAssignedUnit;
			} else {
				private _assignedVehicleCrew = _vehicle getVariable [
					"A3C_AssignedVehicleCrew",
					[]
				];

				private _reservationIndex = _assignedVehicleCrew findIf {
					private _registeredRole = toLower (_x param [1, ""]);
					private _registeredCanonicalRole = if (
						_registeredRole in ["gunner", "commander", "turret"]
					) then {
						"turret"
					} else {
						_registeredRole
					};

					_registeredCanonicalRole == _canonicalRole
					&& {(_x param [2, -2]) isEqualTo _seatIndexPath}
				};

				if (_reservationIndex >= 0) then {
					_occupyingUnit = (
						_assignedVehicleCrew select _reservationIndex
					) select 0;
				};
			};
		};

		if (
			_occupyingUnit in _playerGroupUnits
			&& {!isPlayer _occupyingUnit}
		) then {
			private _singleRoleData = +_roleData;
			_singleRoleData set [0, _occupyingUnit];

			[
				_singleRoleData,
				1,
				_currentButtonImageIdc,
				_occupyingUnit,
				_referenceUnits,
				_vehicle
			] call A3C_ai_squad_fnc_boarding_assignVehicleSeatSingle;
		};

		_currentButtonImageIdc = _currentButtonImageIdc + 2;
	} forEach _vehicleSeatData;
};

private _suitableUnits = _referenceUnits select {
	!isNull _x
	&& {alive _x}
	&& {!isPlayer _x}
	&& {isNull objectParent _x}
	&& {
		(_x getVariable ["A3C_assignedVehicleSeat", []]) isEqualTo []
	}
};

private _fnc_canonicalRole = {
	params ["_testedRole"];

	if (toLower _testedRole in ["gunner", "commander", "turret"]) then {
		"turret"
	} else {
		toLower _testedRole
	}
};

private _queueAssignments = [];
private _trackerData = [];
private _currentButtonImageIdc = 10101;

{
	if (_suitableUnits isEqualTo []) exitWith {};

	_x params [
		"_occupyingUnit",
		"_role",
		"_cargoIndex",
		"_turretPath",
		"_isFFV"
	];

	private _roleEngine = _role;
	_role = toLower _role;

	private _roleIncluded = [_role, _isFFV] call _fnc_roleIncluded;

	if (_roleIncluded) then {
		private _engineAssignedUnit = _x param [5, objNull];
		private _seatIndexPath = if (_role in ["driver", "cargo"]) then {
			_cargoIndex
		} else {
			+_turretPath
		};

		private _canonicalRole = [_role] call _fnc_canonicalRole;
		private _assignedVehicleCrew = _vehicle getVariable [
			"A3C_AssignedVehicleCrew",
			[]
		];

		private _seatReserved = _assignedVehicleCrew findIf {
			private _registeredRole = [
				_x param [1, ""]
			] call _fnc_canonicalRole;

			_registeredRole == _canonicalRole
			&& {(_x param [2, -2]) isEqualTo _seatIndexPath}
		} != -1;

		private _seatAvailable =
			(isNull _occupyingUnit || {!alive _occupyingUnit})
			&& {isNull _engineAssignedUnit || {!alive _engineAssignedUnit}}
			&& {!_seatReserved};

		if (_seatAvailable) then {
			private _unit = _suitableUnits deleteAt 0;
			private _buttonImageControl = (
				findDisplay IDD_RADIAL_MENU
			) displayCtrl _currentButtonImageIdc;

			private _requestId = [
				_unit,
				_vehicle,
				_roleEngine,
				_seatIndexPath,
				_buttonImageControl
			] call A3C_ai_squad_fnc_boarding_registerUnitAssignment;

			if (_requestId >= 0) then {
				if (!isNull _buttonImageControl) then {
					_buttonImageControl ctrlSetTextColor (
						[
							A3C_UI_COLOR_BLUE,
							0.3
						] call A3C_ui_shared_fnc_getColorArrayWithOpacity
					);
				};

				_queueAssignments pushBack [
					_unit,
					_roleEngine,
					_seatIndexPath,
					_requestId
				];

				_trackerData pushBack [
					_unit,
					_roleEngine,
					_seatIndexPath,
					_buttonImageControl,
					_requestId
				];
			} else {
				if ((_unit getVariable ["A3C_assignedVehicleSeat", []]) isEqualTo []) then {
					_suitableUnits pushBackUnique _unit;
				};
			};
		};
	};

	_currentButtonImageIdc = _currentButtonImageIdc + 2;
} forEach _vehicleSeatData;

if (_queueAssignments isEqualTo []) exitWith {};

//-- Prepare every unit before allowing the one shared batch to enter the
//-- protected player-group transaction.
{
	private _unit = _x select 0;

	if ((_unit getVariable ["A3C_PLOT", []]) isNotEqualTo []) then {
		[
			[_unit],
			true,
			false
		] call A3C_ai_shared_fnc_cancelUnitPlot;
	};
} forEach _queueAssignments;

private _plotAbortTimeoutAt = diag_tickTime + 10;

waitUntil {
	(
		_queueAssignments findIf {
			private _unit = _x select 0;
			private _requestId = _x select 3;
			private _assignmentData = _unit getVariable [
				"A3C_assignedVehicleSeat",
				[]
			];

			_assignmentData param [3, -1] == _requestId
			&& {(_unit getVariable ["A3C_PLOT", []]) isNotEqualTo []}
		} == -1
	)
	|| {diag_tickTime >= _plotAbortTimeoutAt}
};

//-- Fail only the units whose plot owner did not acknowledge the abort.
{
	private _unit = _x select 0;
	private _requestId = _x select 3;

	if ((_unit getVariable ["A3C_PLOT", []]) isNotEqualTo []) then {
		[
			_unit,
			_requestId,
			true,
			[1, 1, 1, 1]
		] call A3C_ai_squad_fnc_boarding_finishUnitAssignment;
	};
} forEach _queueAssignments;

_queueAssignments = _queueAssignments select {
	private _unit = _x select 0;
	private _requestId = _x select 3;
	private _assignmentData = _unit getVariable [
		"A3C_assignedVehicleSeat",
		[]
	];

	_assignmentData param [3, -1] == _requestId
};

if (_queueAssignments isEqualTo []) exitWith {};

_trackerData = _trackerData select {
	private _unit = _x select 0;
	private _requestId = _x select 4;
	private _assignmentData = _unit getVariable [
		"A3C_assignedVehicleSeat",
		[]
	];

	_assignmentData param [3, -1] == _requestId
};

private _queueCompletionState = [
	_queueAssignments,
	_vehicle
] call A3C_ai_squad_fnc_boarding_queueBoardUnitsToVehicle;

{
	_x params [
		"_unit",
		"_role",
		"_seatIndexPath",
		"_buttonImageControl",
		"_requestId"
	];

	private _boardingScript = [
		_unit,
		_vehicle,
		_role,
		_seatIndexPath,
		_buttonImageControl,
		_requestId,
		_queueCompletionState
	] spawn A3C_ai_squad_fnc_boarding_boardUnitToSeat;

	_unit setVariable [
		"A3C_boardingScript",
		[_boardingScript]
	];
} forEach _trackerData;

//-- actionExecuteUnitPlot waits for this macro script. Return only after the
//-- protected transaction has restored the player group.
waitUntil {
	_queueCompletionState param [0, false]
};

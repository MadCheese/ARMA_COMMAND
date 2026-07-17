// A3C_ai_squad_fnc_boarding_boardingHack

params [
	"_unit",
	"_vehicle",
	"_role"
];

_role params [
	"_roleId",
	"_roleIndex"
];

private _temporaryGroup = createGroup [side player, true];
private _wasSelected = _unit in groupSelectedUnits player;

[_unit] joinSilent _temporaryGroup;

private _logic = (group player) createUnit [
	"LOGIC",
	(position player) vectorAdd [0, 0, 50],
	[],
	0,
	""
];

if (_wasSelected) then {
	player groupSelectUnit [_logic, true];
};

_logic hideObjectGlobal true;
_logic enableSimulation false;

switch (_roleId) do {
	case "driver": {
		_unit assignAsDriver _vehicle;
	};
	case "gunner": {
		_unit assignAsTurret [_vehicle, _roleIndex];
	};
	case "commander": {
		_unit assignAsTurret [_vehicle, _roleIndex];
	};
	case "turret": {
		_unit assignAsTurret [_vehicle, _roleIndex];
	};
	case "cargo": {
		_unit assignAsCargoIndex [_vehicle, _roleIndex];
	};
};

[_unit] orderGetIn true;

private _originalLogicDestination = (position _logic) vectorAdd [0, 20, 0];

[
	_logic,
	_originalLogicDestination
] call A3C_ai_shared_fnc_doMove;

private _unitNameParts = (name _unit) splitString " ";
private _firstName = _unitNameParts deleteAt 0;
private _lastName = _unitNameParts joinString " ";

private _logicName = [
	_firstName + " " + _lastName,
	_firstName,
	_lastName
];

sleep 0.1;

_logic setName _logicName;

while {alive _unit} do {
	private _expectedLogicDestination = expectedDestination _logic;

	if (
		currentCommand _logic isEqualTo "STOP"
		|| {
			(
				(_expectedLogicDestination select 0)
				distance2D _originalLogicDestination
			) > 1
		}
	) exitWith {
		_unit remoteExec ["unassignVehicle", 0];

		sleep 1;

		[
			_unit,
			_expectedLogicDestination select 0
		] call A3C_ai_shared_fnc_doMove;
	};

	if (!isNull objectParent _unit) exitWith {};
};

_wasSelected = _logic in groupSelectedUnits player;

[_logic] join grpNull;
[_unit] joinSilent group player;

if (_wasSelected) then {
	player groupSelectUnit [_unit, true];
};

deleteVehicle _logic;

private _assignedVehicleCrew = _vehicle getVariable [
	"A3C_AssignedVehicleCrew",
	[]
];

_assignedVehicleCrew = _assignedVehicleCrew select {
	(_x select 0) != _unit
};

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
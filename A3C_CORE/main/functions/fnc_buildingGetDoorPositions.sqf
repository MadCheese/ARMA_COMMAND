// A3C_main_fnc_buildingGetDoorPositions

//-- Get door positions of a building

params ["_building"];

private _doorPositions = [];
private _doorCount = getNumber (configFile >> "CfgVehicles" >> typeOf _building >> "numberOfDoors");

for "_doorIndex" from 1 to _doorCount do {
	private _doorSelectionPosition = _building selectionPosition format ["Door_%1_trigger", _doorIndex];

	if (_doorSelectionPosition isEqualTo [0, 0, 0]) exitWith {};

	_doorPositions pushBack (_building modelToWorld _doorSelectionPosition);
};

_doorPositions
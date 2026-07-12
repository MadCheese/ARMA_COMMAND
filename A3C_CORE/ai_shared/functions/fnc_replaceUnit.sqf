// A3C_ai_shared_fnc_replaceUnit

// -- Purpose: completely replace a soldier that is in STOP mode.

//-- NOTES:
//-- does not transfer eventhandlers

params ["_unit"];

if !(_unit == driver vehicle _unit) exitWith {};

private _unitArray = +(profileNamespace getVariable "A3C_GROUPUNITS");
private _unitIndex = [_unit, _unitArray] call MCSS_fnc_getArrayIndex;

private _vehicle = vehicle _unit;
private _hasParent = !isNull objectParent _unit;

// -- retrieve unit data
private _type = typeOf _unit;
private _name = name _unit;
private _direction = getDir _unit;
private _animation = animationState _unit;
private _face = face _unit;
private _positionASL = getPosASL _unit;
private _stance = stance _unit;
private _vehicleVarName = vehicleVarName _unit;
private _group = group _unit;

private _teamColor = if (player == cameraOn) then {
	assignedTeam _unit
} else {
	_unit getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
};

private _fatigue = getFatigue _unit;
private _stamina = getStamina _unit;
private _isStaminaEnabled = isStaminaEnabled _unit;

private _destination = expectedDestination _unit;
private _plot = _unit getVariable ["A3C_PLOT", []];
private _currentWaypointIndex = _unit getVariable ["A3C_CURRENTWAYPOINT_INDEX", 1];
private _formationIndex = _unit getVariable ["A3C_FORMATION_INDEX", [_unit] call A3C_main_fnc_getUnitIndex];
private _vehicleVarNameIndex = _unit getVariable ["A3C_VVNI", A3C_VARNAME_INDEX];

private _inHud = _unit in A3C_UI_squadPlacement_units;
private _rdIndex = [_unit, A3C_RD_UNITS] call MCSS_fnc_getArrayIndex;
private _tabletIndex = [_unit, A3C_SELECTED_UNITS] call MCSS_fnc_getArrayIndex;

private _damage = [];

{
	_damage pushBack [_x, _unit getHitPointDamage _x];
} forEach A3C_HUMAN_HITPOINTS;

private _loadout = getUnitLoadout _unit;

private _allVariables = [];

{
	private _variableValue = _unit getVariable [_x, nil];
	if (!isNil '_variableValue') then {
		_allVariables pushBack [_x, _variableValue];
	};
} forEach allVariables _unit;

// -- delete unit, spawn logics until unit's formationIndex is reached, then spawn new unit and delete logics
deleteVehicle _unit;

private _newUnit = objNull;
private _logics = [];

for "_i" from 1 to (_formationIndex - 2) do {
	private _referenceUnit = _unitArray select _i;

	if !(_referenceUnit in units player) then {
		private _logic = group player createUnit ["LOGIC", [0,0,0], [], 0, ""];
		_logics pushBackUnique _logic;
	};
};

call compile format [
	"%1 = _group createUnit [""%3"", %4, [], 0, ""FORM""]; _newUnit = %1;",
	parseText _vehicleVarName,
	_group,
	_type,
	[0,0,0]
];

{
	deleteVehicle _x;
} forEach _logics;

// -- re-establish damage
for "_i" from 0 to 9 do {
	private _hitPointData = _damage select _i;

	_newUnit setHitPointDamage [
		_hitPointData select 0,
		_hitPointData select 1
	];
};

if (_hasParent) then {
	_newUnit moveInDriver _vehicle;
} else {
	_newUnit setDir _direction;
	_newUnit setPosASL _positionASL;
	_newUnit switchMove _animation;
};

// -- reset fatigue / stamina
_newUnit setFatigue _fatigue;
_newUnit setStamina _stamina;
_newUnit enableStamina _isStaminaEnabled;

if (_inHud) then {
	A3C_UI_squadPlacement_units pushBackUnique _newUnit;
};

if (_rdIndex != -1) then {
	A3C_RD_UNITS set [_rdIndex, _newUnit];
};

if (_tabletIndex != -1) then {
	A3C_SELECTED_UNITS set [_tabletIndex, _newUnit];
};

switch (_stance) do {
	case "STAND": {
		_newUnit setUnitPos "UP";
	};

	case "CROUCH": {
		_newUnit setUnitPos "MIDDLE";
	};

	case "PRONE": {
		_newUnit setUnitPos "DOWN";
	};
};

[_newUnit, 0] call A3C_ai_squad_fnc_initializeUnit;

// -- reset variables
{
	_x params ["_variableName", "_variableValue"];

	private _isPublicVariable = _variableName in ["A3C_unit_polys", "A3C_poly_active"];

	_newUnit setVariable [_variableName, _variableValue, _isPublicVariable];
} forEach _allVariables;

_unitArray set [_unitIndex, _newUnit];

_newUnit assignTeam _teamColor;
_newUnit setVariable ["A3C_ASSIGNEDTEAM", _teamColor];

private _nameStringArray = _name splitString " ";
private _firstName = _nameStringArray deleteAt 0;
private _lastName = _nameStringArray joinString " ";
private _nameArray = [_firstName + " " + _lastName, _firstName, _lastName];

profileNamespace setVariable ["A3C_GROUPUNITS", _unitArray];

[
	_newUnit,
	_vehicleVarName,
	_nameArray,
	_loadout,
	_face,
	_destination
] spawn {
	params ["_unit", "_vehicleVarName", "_nameArray", "_loadout", "_face", "_destination"];

	_unit setVehicleVarName _vehicleVarName;
	_unit setName _nameArray;
	_unit setUnitLoadout _loadout;
	_unit setFace _face;
	_unit setDestination _destination;
};

_newUnit
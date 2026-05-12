// A3C_ai_shared_fnc_actionIrStrobeSet
// Runs where _unit is local.
//
// HC usage:
// [_unit, "ON", "NVG_TargetC", 0, _requestId] spawn A3C_ai_shared_fnc_actionIrStrobeSet;
//
// Player-squad usage:
// [_unit, "ON", "NVG_TargetC", 0, _requestId, _magazineClass, true] spawn A3C_ai_shared_fnc_actionIrStrobeSet;

params [
	["_unit", objNull, [objNull]],
	["_mode", "", [""]],
	["_strobeObjectType", "", [""]],
	["_delay", 0, [0]],
	["_requestId", "", [""]],
	["_magazineClass", "", [""]],
	["_consumeMagazine", false, [false]]
];

if (isNull _unit) exitWith {};
if !(_mode in ["ON", "OFF"]) exitWith {};

sleep (_delay + random 1);

// Abort stale delayed requests.
private _currentRequest = _unit getVariable ["A3C_IR_STROBE_REQUEST", ["", ""]];
_currentRequest params [
	["_currentMode", "", [""]],
	["_currentRequestId", "", [""]]
];

if (_currentMode != _mode || {_currentRequestId != _requestId}) exitWith {};

private _irData = _unit getVariable ["A3C_STROBE", []];

if (_mode == "ON") exitWith {
	// Already has a valid strobe.
	if (
		count _irData > 0 &&
		{!isNull (_irData select 0)}
	) exitWith {};

	if (_strobeObjectType == "") exitWith {};

	if (_consumeMagazine && {_magazineClass != ""}) then {
		if !(_magazineClass in magazines _unit) exitWith {};
		_unit removeMagazine _magazineClass;
	};

	_unit setVariable ["A3C_STROBE", [objNull, _magazineClass], true];

	private _strobeObject = _strobeObjectType createVehicle getPosATL _unit;

	/*
		Stored format:
		[
			strobe object,
			magazine class or strobe object type
		]

		For HC units, the second value is usually the object type.
		For player squads, the second value is the consumed magazine class.
	*/
	private _storedClass = if (_magazineClass != "") then {
		_magazineClass
	} else {
		_strobeObjectType
	};

	_unit setVariable ["A3C_STROBE", [_strobeObject, _storedClass], true];

	[_unit, _strobeObject] spawn A3C_ai_shared_fnc_actionIrStrobeLoop;
};

if (_mode == "OFF") exitWith {
	if (count _irData > 0) then {
		_irData params [
			["_strobeObject", objNull, [objNull]],
			["_storedClass", "", [""]]
		];

		if (!isNull _strobeObject) then {
			deleteVehicle _strobeObject;
		};

		// Restore consumed player-squad magazine.
		if (_storedClass != "" && {_storedClass isKindOf ["", configFile >> "CfgMagazines"]}) then {
			_unit addMagazine _storedClass;
		};
	};

	_unit setVariable ["A3C_STROBE", [], true];
};
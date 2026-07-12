// A3C_ai_shared_fnc_actionWeaponAttachmentSet
// Runs where _unit is local.
//
// HC usage:
// [_unit, "LASER", "ON", _delay, _requestId] spawn A3C_ai_shared_fnc_actionWeaponAttachmentSet;
//
// Squad usage:
// [_unit, "LASER", "ON", _delay, _requestId, true] spawn A3C_ai_shared_fnc_actionWeaponAttachmentSet;

params [
	["_unit", objNull, [objNull]],
	["_type", "", [""]],
	["_mode", "", [""]],
	["_delay", 0, [0]],
	["_requestId", "", [""]],
	["_useSquadGestureFlow", false, [false]]
];

if (isNull _unit) exitWith {};
if !(_type in ["LASER", "FLASHLIGHT"]) exitWith {};
if !(_mode in ["ON", "OFF"]) exitWith {};

sleep _delay;

// Abort stale delayed requests.
private _requestVar = format ["A3C_ATTACHMENT_REQUEST_%1", _type];
private _currentRequest = _unit getVariable [_requestVar, ["", ""]];
_currentRequest params [
	["_currentMode", "", [""]],
	["_currentRequestId", "", [""]]
];

if (_currentMode != _mode || {_currentRequestId != _requestId}) exitWith {};
if (!alive _unit) exitWith {};

if (_useSquadGestureFlow) then {
	_unit playActionNow "GestureHiC";
	sleep 1.2;

	// Check again after the gesture delay.
	private _currentRequestPostGesture = _unit getVariable [_requestVar, ["", ""]];
	_currentRequestPostGesture params [
		["_postGestureMode", "", [""]],
		["_postGestureRequestId", "", [""]]
	];

	if (_postGestureMode != _mode || {_postGestureRequestId != _requestId}) exitWith {};
	if (!alive _unit) exitWith {};
};

if (_mode == "ON") then {
	if (_useSquadGestureFlow) then {
		[_unit, ["BEHAVIOUR", "COMBAT"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
	} else {
		_unit setBehaviourStrong "COMBAT";
	};

	switch (_type) do {
		case "LASER": {
			_unit enableIRLasers true;
		};

		case "FLASHLIGHT": {
			_unit enableGunLights "ForceOn";
		};
	};

	_unit setUnitPos (["Middle", "UP"] call BIS_fnc_selectRandom);
	_unit setVariable ["A3C_isGunPoiterSlotOn", _type, true];
} else {
	if (_useSquadGestureFlow) then {
		[_unit, ["BEHAVIOUR", "AWARE"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
	} else {
		_unit setBehaviourStrong "AWARE";
	};

	switch (_type) do {
		case "LASER": {
			_unit enableIRLasers false;
		};

		case "FLASHLIGHT": {
			_unit enableGunLights "ForceOff";
		};
	};

	_unit setUnitPos "AUTO";
	_unit setVariable ["A3C_isGunPoiterSlotOn", "", true];
};
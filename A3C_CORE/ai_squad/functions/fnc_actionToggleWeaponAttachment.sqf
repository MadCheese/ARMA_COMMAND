// A3C_ai_squad_fnc_actionToggleWeaponAttachment
// Local per-unit squad action.


params [
	["_unit", objNull, [objNull]],
	["_type", "", [""]],
	["_mode", "", [""]],
	["_delay", 0, [0]],
	["_requestId", "", [""]]
];

if (isNull _unit) exitWith {};
if !(_type in ["LASER", "FLASHLIGHT"]) exitWith {};
if !(_mode in ["ON", "OFF"]) exitWith {};

sleep _delay;

private _requestVar = format ["A3C_ATTACHMENT_REQUEST_%1", _type];

private _currentRequest = _unit getVariable [_requestVar, ["", ""]];
_currentRequest params [
	["_currentMode", "", [""]],
	["_currentRequestId", "", [""]]
];

if (_currentMode != _mode || {_currentRequestId != _requestId}) exitWith {};
if (!alive _unit) exitWith {};

_unit playActionNow "GestureHiC";

sleep 1.2;

_currentRequest = _unit getVariable [_requestVar, ["", ""]];
_currentRequest params [
	["_postGestureMode", "", [""]],
	["_postGestureRequestId", "", [""]]
];

if (_postGestureMode != _mode || {_postGestureRequestId != _requestId}) exitWith {};
if (!alive _unit) exitWith {};

if (_mode == "ON") then {
	[_unit, ["BEHAVIOUR", "COMBAT"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;

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
	[_unit, ["BEHAVIOUR", "AWARE"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;

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
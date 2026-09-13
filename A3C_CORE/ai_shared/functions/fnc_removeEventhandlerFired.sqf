// A3C_ai_shared_fnc_removeEventhandlerFired

params [
	["_vehicle", objNull, [objNull]],
	["_cycleToken", "", [""]]
];

if (isNull _vehicle) exitWith {};

if (!local _vehicle) exitWith {};

private _handlerData =
	_vehicle getVariable [
		"A3C_SUPPRESSION_FIRED_EH",
		[]
	];

if (_handlerData isEqualTo []) exitWith {};

private _handlerId =
	_handlerData param [
		0,
		-1,
		[0]
	];

private _storedCycleToken =
	_handlerData param [
		4,
		"",
		[""]
	];

/*
	A completed older cycle must not remove a handler belonging to a
	newer suppression cycle.
*/
if (
	_cycleToken != ""
	&& {_storedCycleToken != _cycleToken}
) exitWith {};

if (_handlerId >= 0) then {
	_vehicle removeEventHandler [
		"Fired",
		_handlerId
	];
};

_vehicle setVariable [
	"A3C_SUPPRESSION_FIRED_EH",
	[],
	false
];
// A3C_ai_shared_fnc_removeEventhandlerFired

params ["_vehicle"];

if !(local _vehicle) exitWith {};

private _handlerData = _vehicle getvariable ["A3C_REMOTE_HANDLE",[-1,objNull]];

if (
	count _handlerData == 0
	|| {_handlerData select 0 == -1}
) exitWith {};

_vehicle removeEventhandler ["FIRED",_handlerData select 0];
_vehicle setvariable ["A3C_REMOTE_HANDLE",[-1,objNull]];

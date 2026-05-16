// A3C_ai_shared_fnc_addEventhandlerFired

params ["_vehicle","_target"];
if !(local _vehicle) exitWith {};
if (!isNull ((_vehicle getvariable ["A3C_REMOTE_HANDLE",[-1,objNull]]) select 1)) exitWith {};

private _handle = _vehicle addEventHandler
[
	"Fired",
	{
		_this spawn A3C_ai_shared_fnc_guideProjectileBullet
	}

];

_vehicle setvariable ["A3C_REMOTE_HANDLE",[_handle,_target]];

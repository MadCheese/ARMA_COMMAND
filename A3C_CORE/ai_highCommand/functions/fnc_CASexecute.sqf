// A3C_ai_highCommand_fnc_CASexecute

params ["_plane","_CASpos","_type","_caller"];



if !(_plane isKindOf "PLANE") exitWith {};
if (_plane distance2D _CASpos < 1000) exitWith {};

private _casTargetPos = +_CASpos;
_casTargetPos set [2,0];

private _attackDirection = (getDir _plane) + 180;

private _dummyTarget = "LaserTargetCBase" createVehicle _casTargetPos;
_dummyTarget enableSimulation false;
_dummyTarget hideObject true;

_dummyTarget setVariable ["vehicle",typeOf _plane];
_dummyTarget setVariable ["type",_type];
_dummyTarget setDir _attackDirection;

[_dummyTarget,nil,true,_plane,_caller] remoteExec ["A3C_ai_highCommand_fnc_moduleCAS", _plane];

_dummyTarget spawn {
	sleep 120;
	deleteVehicle _this;
};
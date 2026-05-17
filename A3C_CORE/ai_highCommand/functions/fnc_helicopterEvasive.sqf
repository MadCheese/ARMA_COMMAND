// A3C_ai_highCommand_fnc_helicopterEvasive

params ["_vehicle"];

private _currentVelocity = velocity _vehicle;
private _evasiveAngleOffset = [90,-90] call BIS_fnc_selectRandom;
private _evasiveDirection = (direction _vehicle) + _evasiveAngleOffset;
private _evasiveSpeed = 10;

private _newVelocity = [
	(_currentVelocity select 0) + (sin _evasiveDirection * _evasiveSpeed),
	(_currentVelocity select 1) + (cos _evasiveDirection * _evasiveSpeed),
	_currentVelocity select 2
];

[_vehicle,_newVelocity] remoteExec ["setVelocity",_vehicle];
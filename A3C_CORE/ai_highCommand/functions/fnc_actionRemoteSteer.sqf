// A3C_ai_highCommand_fnc_actionRemoteSteer

params ["_vehicle", "_angleDiff"];

if !(isEngineOn _vehicle) exitWith {
	_vehicle engineOn true;
};

if (
	!(_vehicle isKindOf "TANK") &&
	{abs ((velocityModelSpace _vehicle) select 1) < 4}
) exitWith {}; // Only tracked vehicles can rotate while stationary.

private _currentVelocity = velocity _vehicle;
private _newDir = [getDir _vehicle + _angleDiff] call MCSS_fnc_CorrectDir;
private _terrainVectors = [getPos _vehicle, _newDir] call MCSS_fnc_TerrainTilt;

// Calculate new velocity components after rotation.
private _angleCos = cos _angleDiff;
private _angleSin = sin _angleDiff;

private _newVelocity = [
	(_currentVelocity select 0) * _angleCos - (_currentVelocity select 1) * _angleSin,
	(_currentVelocity select 0) * _angleSin + (_currentVelocity select 1) * _angleCos,
	_currentVelocity select 2
];

_vehicle setVectorDirAndUp _terrainVectors;
_vehicle setVectorUp surfaceNormal getPos _vehicle;
_vehicle setVelocity _newVelocity;
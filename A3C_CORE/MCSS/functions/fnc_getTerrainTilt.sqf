// MCSS_fnc_getTerrainTilt
// Gets [vectorDir, vectorUp] to align an object to terrain slope while preserving a given direction.

params ["_positionOrObject"];

private _direction = if ((count _this) > 1) then {
	_this select 1
} else {
	if (_positionOrObject isEqualType objNull) then {
		getDir _positionOrObject
	} else {
		0
	}
};

private _position = if (_positionOrObject isEqualType []) then {
	_positionOrObject
} else {
	position _positionOrObject
};

private _terrainPitch = [_position, _direction] call BIS_fnc_terrainGradAngle;
private _roll = 0;

private _vectorDir = [
	sin _direction * cos _terrainPitch,
	cos _direction * cos _terrainPitch,
	sin _terrainPitch
];

private _vectorUp = [
	[sin _roll, -sin _terrainPitch, cos _roll * cos _terrainPitch],
	-_direction
] call BIS_fnc_rotateVector2D;

[
	_vectorDir,
	_vectorUp
]
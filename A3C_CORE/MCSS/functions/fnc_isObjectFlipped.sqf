// MCSS_fnc_isObjectFlipped
// Checks whether an object's current vectorDir/vectorUp deviates from its expected terrain-aligned vectors.

params ["_object"];

private _terrainVectors = [_object, getDir _object] call MCSS_fnc_getTerrainTilt;
private _objectVectors = [vectorDir _object, vectorUp _object];

private _isFlipped = false;
private _exitSearch = false;

for "_vectorIndex" from 0 to 1 do {
	for "_componentIndex" from 0 to 2 do {
		private _componentDifference = abs (
			((_terrainVectors select _vectorIndex) select _componentIndex) -
			((_objectVectors select _vectorIndex) select _componentIndex)
		);

		if (_componentDifference > 0.2) exitWith {
			_isFlipped = true;
			_exitSearch = true;
		};
	};

	if (_exitSearch) exitWith {};
};

_isFlipped
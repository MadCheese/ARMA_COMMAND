// A3C_main_fnc_getAirFieldRunwayAreas
// Creates runway/connection exclusion areas and one main airfield area.
// Return: [_mainArea, _subAreas]

params [
	"_airportID",
	"_airportName",
	"_airportTaxiIn",
	"_airportTaxiOff",
	"_airportIlsDir",
	"_taxiInPoses",
	"_taxiOffPoses"
];

_airportIlsDir = [_airportIlsDir] call MCSS_fnc_correctDir;

private _runwayPositions = _taxiInPoses + _taxiOffPoses;

// Fallback for airports without detailed taxi arrays.
if ((count _runwayPositions) < 2) then {
	_runwayPositions = [_airportTaxiIn, _airportTaxiOff] select {
		_x isEqualType [] &&
		{ (count _x) >= 2 }
	};
};

if ((count _runwayPositions) < 2) exitWith {
	[
		[_airportTaxiIn, 50, 50, _airportIlsDir, true],
		[]
	]
};

private _markerIndex = if (A3C_Debug) then {
	missionNamespace getVariable ["markerCount", 0]
} else {
	0
};

private _subAreas = [];
private _runwayWidth = 30;

for "_i" from 0 to ((count _runwayPositions) - 2) do {
	private _startPos = _runwayPositions select _i;
	private _endPos = _runwayPositions select (_i + 1);

	private _length = _startPos distance2D _endPos;

	if (_length > 0) then {
		private _areaDir = _startPos getDir _endPos;
		private _areaLength = (_length / 2) max 50;
		private _areaCenter = _startPos getPos [_areaLength, _areaDir];

		private _area = [_areaCenter, _runwayWidth, _areaLength, _areaDir, true];
		_subAreas pushBack _area;

		if (A3C_Debug) then {
			private _marker = [
				format ["A3C_Mark_P%1", _markerIndex],
				_areaCenter,
				"RECTANGLE",
				"RECTANGLE",
				[_runwayWidth, _areaLength],
				"",
				"ColorOrange",
				1
			] call MCSS_fnc_createMarker;

			_marker setMarkerDir _areaDir;
			_markerIndex = _markerIndex + 1;
		};
	};
};

// Create main airfield area from runway-position extents.
private _firstPos = _runwayPositions select 0;

private _lowestX = _firstPos select 0;
private _highestX = _lowestX;
private _lowestY = _firstPos select 1;
private _highestY = _lowestY;

{
	private _posX = _x select 0;
	private _posY = _x select 1;

	if (_posX < _lowestX) then {
		_lowestX = _posX;
	};

	if (_posX > _highestX) then {
		_highestX = _posX;
	};

	if (_posY < _lowestY) then {
		_lowestY = _posY;
	};

	if (_posY > _highestY) then {
		_highestY = _posY;
	};
} forEach _runwayPositions;

private _airportCenter = [
	_lowestX + ((_highestX - _lowestX) / 2),
	_lowestY + ((_highestY - _lowestY) / 2),
	0
];

private _airportWidth = (_highestX - _lowestX) / 4;
private _airportLength = (_highestY - _lowestY) / 2;

private _mainArea = [
	_airportCenter,
	_airportWidth,
	_airportLength,
	_airportIlsDir,
	true
];

if (A3C_Debug) then {
	private _marker = [
		format ["A3C_Mark_P%1", _markerIndex],
		_airportCenter,
		"RECTANGLE",
		"RECTANGLE",
		[_airportWidth, _airportLength],
		"",
		"ColorBlufor",
		0.5
	] call MCSS_fnc_createMarker;

	_marker setMarkerDir _airportIlsDir;
	_markerIndex = _markerIndex + 1;

	missionNamespace setVariable ["markerCount", _markerIndex];
};

[_mainArea, _subAreas]
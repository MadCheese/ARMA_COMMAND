// MCSS_fnc_getSafePos
// Get position that meets safety requirements.

params ["_centerPos", "_rangeInput"];

private _waterMode = 0;
private _maxGradient = 0.1;

private _minDist = -1;
private _maxDist = -1;

switch (typeName _rangeInput) do {
	case (typeName []): {
		_minDist = _rangeInput select 0;
		_maxDist = _rangeInput select 1;
	};
	case (typeName 0): {
		_minDist = 0;
		_maxDist = _rangeInput;
	};
	default {
		_minDist = 0;
		_maxDist = getNumber (configFile >> "CfgWorlds" >> worldName >> "safePositionRadius");
	};
};

private _safePos = [];
private _centerX = _centerPos select 0;
private _centerY = _centerPos select 1;
private _attempts = 0;
private _exit = false;

private _flatEmptyParams = [10, 1, _maxGradient, 20, _waterMode, false];

while { _attempts < 1000 } do {
	private _candidateX = _centerX + (_maxDist - (random (_maxDist * 2)));
	private _candidateY = _centerY + (_maxDist - (random (_maxDist * 2)));

	if (_attempts == 0) then {
		_candidateX = _centerX;
		_candidateY = _centerY;
	};

	private _candidatePos = [_candidateX, _candidateY];

	if ((_centerPos distance _candidatePos) >= _minDist) then {
		if ((count (_candidatePos isFlatEmpty _flatEmptyParams)) > 0) then {
			_safePos = _candidatePos;
			_exit = true;
		};
	};

	if (_exit) exitWith {};

	_attempts = _attempts + 1;
};

if ((count _safePos) > 0) then {
	_safePos = [_safePos select 0, _safePos select 1, 0];
};

_safePos
// A3C_main_fnc_getNearestAirportData

params ["_inputPos"];

private _worldConfig = configFile >> "CfgWorlds" >> worldName;
private _secondaryAirportsConfig = _worldConfig >> "SecondaryAirports";

private _airportNames = ["MAIN"];

{
	_airportNames pushBack (configName _x);
} forEach ("true" configClasses _secondaryAirportsConfig);

private _airportNamesOriginal = +_airportNames;

_airportNames = [
	_airportNames,
	[],
	{
		private _ilsPosition = if (_x == "MAIN") then {
			getArray (_worldConfig >> "ilsPosition")
		} else {
			getArray (_secondaryAirportsConfig >> _x >> "ilsPosition")
		};

		if (_ilsPosition isEqualTo []) then {
			1e10
		} else {
			_inputPos distance2D _ilsPosition
		}
	},
	"ASCEND"
] call BIS_fnc_sortBy;

private _selection = _airportNames select 0;

private _taxiIn = if (_selection == "MAIN") then {
	getArray (_worldConfig >> "ilsTaxiIn")
} else {
	getArray (_secondaryAirportsConfig >> _selection >> "ilsTaxiIn")
};

private _taxiOff = if (_selection == "MAIN") then {
	getArray (_worldConfig >> "ilsTaxiOff")
} else {
	getArray (_secondaryAirportsConfig >> _selection >> "ilsTaxiOff")
};

private _ilsDirection = if (_selection == "MAIN") then {
	getArray (_worldConfig >> "ilsDirection")
} else {
	getArray (_secondaryAirportsConfig >> _selection >> "ilsDirection")
};

private _startPos = +_inputPos;
private _touchDownPos = +_inputPos;

if ((count _taxiOff) >= 2) then {
	private _lastIndex = (count _taxiOff) - 2;
	_startPos = [
		_taxiOff select _lastIndex,
		_taxiOff select (_lastIndex + 1)
	];
};

if ((count _taxiIn) >= 2) then {
	private _lastIndex = (count _taxiIn) - 2;
	_touchDownPos = [
		_taxiIn select _lastIndex,
		_taxiIn select (_lastIndex + 1)
	];
};

private _ilsDir = if ((count _ilsDirection) > 2) then {
	(_ilsDirection select 0) atan2 (_ilsDirection select 2)
} else {
	0
};

private _airportIndex = _airportNamesOriginal find _selection;

private _dynamicAirports = allAirports select 1;

if !(_dynamicAirports isEqualTo []) then {
	private _closestDynamicAirport = ([
		_dynamicAirports,
		[],
		{ _x distance2D _inputPos },
		"ASCEND"
	] call BIS_fnc_sortBy) select 0;

	if ((_startPos distance2D _inputPos) > (_closestDynamicAirport distance2D _inputPos)) then {
		_selection = _closestDynamicAirport;
		_airportIndex = -1;
		_startPos = position _closestDynamicAirport;
		_ilsDir = 0;
	};
};

private _taxiInPosArray = [];

for "_i" from 0 to ((count _taxiIn) - 2) step 2 do {
	_taxiInPosArray pushBack [
		_taxiIn select _i,
		_taxiIn select (_i + 1)
	];
};

private _taxiOffPosArray = [];

for "_i" from 0 to ((count _taxiOff) - 2) step 2 do {
	_taxiOffPosArray pushBack [
		_taxiOff select _i,
		_taxiOff select (_i + 1)
	];
};

[
	_airportIndex,
	_selection,
	_touchDownPos,
	_startPos,
	_ilsDir,
	_taxiInPosArray,
	_taxiOffPosArray
]
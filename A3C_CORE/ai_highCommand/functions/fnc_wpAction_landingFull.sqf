if (isNil "A3C_IsA3CServer") exitWith {};

params ["_leader", "_waypointPos", "_caller", "_vectorDir", "_forceDefaultLanding"];

//-- #WIP Note: it seems that _forceDefaultLanding is never false, railed landing is handled through it's own wpScript??

private _group = group _leader;
private _leaderVehicle = vehicle _leader;
private _scripts = [];

if (isPlayer driver _leaderVehicle) exitWith {};

_vectorDir = if (!isNil "_vectorDir") then {
	_vectorDir
} else {
	[_leaderVehicle getDir _waypointPos] call MCSS_fnc_DegreeToVector
};

if (!local _group) exitWith {};
if (_group getVariable ["A3C_ISwpLANDING", false]) exitWith {};

_group setVariable ["A3C_ISwpLANDING", true, true];

private _registerLandingScript = {
	params ["_group", "_actionID", "_script"];

	private _currentActions = _group getVariable ["A3C_SCRIPTS", []];
	_currentActions pushBackUnique [_actionID, _script];
	_group setVariable ["A3C_SCRIPTS", _currentActions, true];
};

private _landHelicopterControlled = {
	params ["_pilot", "_vehicle", "_landingPos"];

	private _group = group _pilot;

	private _landingPosATL = +_landingPos;
	_landingPosATL set [2, 0];

	private _helipad = "Land_HelipadEmpty_F" createVehicle _landingPosATL;
	private _landCommandIssued = false;

	waitUntil {
		if (!alive _vehicle || {!canMove _vehicle}) exitWith {
			true
		};

		private _distance2D = _vehicle distance2D _landingPosATL;

		// private _finalAltitude = switch (true) do {
		// 	case (_distance2D > 150): {20};
		// 	case (_distance2D > 75): {12};
		// 	case (_distance2D > 35): {7};
		// 	default {4};
		// };

		// private _finalSpeed = switch (true) do {
		// 	case (_distance2D > 150): {35};
		// 	case (_distance2D > 75): {25};
		// 	case (_distance2D > 35): {15};
		// 	default {8};
		// };

		// [
		// 	_group,
		// 	_landingPosATL,
		// 	_finalSpeed,
		// 	_finalAltitude,
		// 	500,
		// 	150
		// ] call A3C_ai_shared_fnc_approachWaypointHelicopter;

		if (!_landCommandIssued && {_distance2D < 120}) then {
			_vehicle land "LAND";
			_landCommandIssued = true;
		};

		sleep 0.5;

		isTouchingGround _vehicle
	};

	deleteVehicle _helipad;

	if (alive _vehicle) then {
		_vehicle engineOn false;
	};

	_vehicle limitSpeed 5000;
	_vehicle flyInHeight 100;
};

private _units = units _group;

private _driverUnits = _units select {
	private _vehicle = vehicle _x;
	_x == driver _vehicle
};

//-- Move runway-capable planes toward their ILS approach vector first.
{
	private _vehicle = vehicle _x;
	private _runwayLanding = (getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "landingSpeed")) > 10;

	if (_vehicle isKindOf "PLANE" && {_runwayLanding}) then {
		private _airportData = [_waypointPos] call MCSS_fnc_getNearestAirportData;

		_airportData params [
			"_airportID",
			"_airportName",
			"_airportTaxiIn",
			"_airportTaxiOff",
			"_airportIlsDir",
			"_taxiInPoses",
			"_taxiOffPoses"
		];

		[_x, _vehicle getPos [10000, _airportIlsDir]] call A3C_ai_shared_fnc_doMove;
	};
} forEach _driverUnits;

{
	private _vehicle = vehicle _x;
	private _runwayLanding = (getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "landingSpeed")) > 10;

	if (_runwayLanding && {_vehicle isKindOf "PLANE"}) then {
		private _script = [_x, _waypointPos] spawn A3C_ai_shared_fnc_planeLanding;

		_scripts pushBack _script;
		[_group, "landing_full_2", _script] call _registerLandingScript;

		sleep 20;
	} else {
		
		if ([_vehicle] call A3C_main_fnc_canHoverAircraft) then {
			private _script = [_x, _vehicle, _waypointPos] spawn _landHelicopterControlled;

			_scripts pushBack _script;
			[_group, "landing_full_2", _script] call _registerLandingScript;
		} else {
			if (_forceDefaultLanding) then {
				private _script = [_group, _waypointPos] spawn {
					params ["_group", "_waypointPos"];

					private _vehiclesMoved = [];
					private _vehiclesLanding = [];

					waitUntil {
						private _readyCount = 0;
						private _groupVehicles = [];

						{
							private _vehicle = vehicle _x;

							if (_x == effectiveCommander _vehicle) then {
								if (!(_vehicle in _vehiclesMoved)) then {
									[effectiveCommander _x, _waypointPos] call A3C_ai_shared_fnc_doMove;
									_vehiclesMoved pushBack _vehicle;
								} else {
									if !(isTouchingGround _vehicle) then {
										if (unitReady _vehicle && {!(_vehicle in _vehiclesLanding)}) then {
											_vehicle land "LAND";
											_vehiclesLanding pushBack _vehicle;
										};
									} else {
										_vehicle engineOn false;
										_readyCount = _readyCount + 1;
									};
								};

								_groupVehicles pushBack _vehicle;
							};
						} forEach units _group;

						_vehiclesMoved = _vehiclesMoved arrayIntersect _groupVehicles;
						_vehiclesLanding = _vehiclesLanding arrayIntersect _groupVehicles;

						sleep 1;

						count _groupVehicles == _readyCount
					};
				};

				_scripts pushBack _script;
				[_group, "landing_full_2", _script] call _registerLandingScript;
			} else {
				//-- rail landing is specific to radial - not used by waypointscript
				if (_vehicle == _leaderVehicle) then {
					private _script = [_vehicle, _waypointPos, _vectorDir] spawn {
						params ["_vehicle", "_waypointPos", "_vectorDir"];

						private _exit = false;

						while {alive _vehicle} do {
							if (_vehicle distance2D _waypointPos < 500) then {
								[_vehicle, _waypointPos, _vectorDir] spawn A3C_ai_rail_fnc_helicopterLanding;
								_exit = true;
							};

							if (_exit) exitWith {};

							sleep 1;
						};
					};

					_scripts pushBack _script;
					[_group, "landing_full_2", _script] call _registerLandingScript;
				} else {
					_vehicle land "LAND";
				};
			};
		};

		sleep 10;
	};
} forEach _driverUnits;

waitUntil {
	sleep 1;
	{!scriptDone _x} count _scripts == 0
};

_group setVariable ["A3C_ISwpLANDING", false, true];

true
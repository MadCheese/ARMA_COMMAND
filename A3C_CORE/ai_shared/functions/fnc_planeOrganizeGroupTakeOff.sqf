// A3C_ai_shared_fnc_planeOrganizeGroupTakeOff

params ["_leader"];

private _leaderVehicle = vehicle _leader;

private _airportData = [getPosATL _leaderVehicle] call A3C_main_fnc_getNearestAirportData;
_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];

private _maxConcurrentTakeoffs = if (_airportID > -1) then {1} else {2};
private _cfgVehicles = configFile >> "CfgVehicles";
private _doorSources = ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];

{
	private _pilot = _x;
	private _aircraft = vehicle _pilot;
	private _shouldExecuteTakeoff = true;

	if (_aircraft isKindOf "PLANE" && {_pilot == driver _aircraft}) then {
		if (isTouchingGround _aircraft) then { //-- only schedule takeoff for non airborne plane
			private _aircraftType = typeOf _aircraft;

			if ((getNumber (_cfgVehicles >> _aircraftType >> "landingSpeed")) > 10) then { //-- prevent runway takeoff for VTOLS
				{
					_aircraft animateDoor [_x, 0];
				} forEach _doorSources;

				while {alive _aircraft} do {
					sleep 1 + (random 1);

					private _activeTakeoffCount = {
						alive _x && {
							_x getVariable ["A3C_TAKING_OFF",false]
						}
					} count units _pilot;

					if (_activeTakeoffCount <= _maxConcurrentTakeoffs) exitWith {};

					sleep 1 + (random 1);

					if (_aircraft != vehicle _pilot) exitWith {
						_shouldExecuteTakeoff = false;
					};

					if (!alive _aircraft) exitWith {
						_shouldExecuteTakeoff = false;
					};
				};

				if (_shouldExecuteTakeoff) then {
					[_pilot] spawn A3C_ai_shared_fnc_planeTakeOff;

					waitUntil {
						speed _aircraft > 15 &&
						{_aircraft distance2D _airportTaxiOff > ((sizeOf _aircraftType) * 2)}
					};

					sleep 5;

					_pilot setVariable ["A3C_TAKING_OFF",false,true];
				};
			} else {
				[_aircraft,1] remoteExec ["setFuel",_aircraft];
			};
		};
	};
} forEach units _leader;
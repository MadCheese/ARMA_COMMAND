// A3C_ai_shared_fnc_planeTakeOff

private _unit = _this select 0;

if (isPlayer _unit) exitWith {};

private _vehicle = vehicle _unit;

if !(_vehicle isKindOf "PLANE") exitWith {};
if !(isTouchingGround _vehicle) exitWith {};

[_vehicle,1] remoteExec ["setVehicleAmmo", _vehicle];

private _airportData = [getPosATL _vehicle] call A3C_main_fnc_getNearestAirportData;
_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];

private _planeDir = if (count _taxiInPoses > 1) then {(_taxiInPoses select 0) getDir _airportTaxiIn} else {0};
_unit setVariable ["A3C_TAKING_OFF",true,true];

//-- weird workaround to see if the vehicle can move
private _canMove = false;
while {alive _vehicle && {!isNull driver _vehicle}} do {
	[_vehicle,1] remoteExec ["setFuel",_vehicle];
	sleep 0.2;
	if (canMove _vehicle) then {
		_canMove = true;
	};
	[_vehicle,0] remoteExec ["setFuel",_vehicle];
	if (_canMove) exitWith {};
	sleep 3;
};

if !(_canMove) exitWith {};

if (_airportID >= 0) then {
	//-- Airfield TakeOff

	for "_i" from 1 to 5 do { //-- why the loop you aks? - Because some weird thing kept teleporting the planes back to their parking position
		[_vehicle,_planeDir] remoteExec ["setDir",_vehicle];
		[_vehicle,_airportTaxiOff] remoteExec ["setPos",_vehicle];
		sleep 0.05;
	};
	[_vehicle,1] remoteExec ["setFuel",_vehicle];
	sleep 0.5; // -- security for refuel
	if (_unit != leader (group _unit)) then {

		while {((getPosATL _vehicle) select 2) < 10} do {
			private _movePos = waypointPosition [group _unit, currentWaypoint (group _unit)];

			[_unit,_movePos] remoteExec ["doMove",_unit];
			if (!alive _vehicle) exitWith {deleteVehicle _vehicle}; //~~ CHANGE THIS TO MOVE THE WRECK TO AN EMPTY POSITION
			if (!alive _unit) exitWith {}; //-- ~~ADD VEHICLE PARKING HERE!! ILSPOSITIONS NEED TO BE CLEAR!
			if (!canMove _vehicle) exitWith {}; //-- ~~ADD VEHICLE PARKING HERE!! ILSPOSITIONS NEED TO BE CLEAR!
			sleep 2;
		};
		[_unit, leader (group _unit)] remoteExec ["commandFollow",_unit];
	};


} else { //-- _airportID < 0 == dynamic airfield
	//-- CARRIER TAKEOFF
	[_vehicle,A3C_ai_shared_fnc_planeCatapultLaunch] remoteExec ["bis_fnc_spawn", _vehicle];
};
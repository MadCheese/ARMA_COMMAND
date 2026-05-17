// A3C_ai_shared_fnc_planeCatapultLaunch

params ["_vehicle"];

if (!local _vehicle) exitWith {};

private _launchHeight = (getPosWorld _vehicle) select 2;

private _carrierObjects = _vehicle nearObjects ["Land_Carrier_01_base_F", 200];
if (count _carrierObjects == 0) exitWith {};

private _carrier = _carrierObjects select 0;

private _busyCatapults = _carrier getVariable ["A3C_BUSYCATAPULTS",[]];
private _availableCatapults = ["Catapult1","Catapult2","Catapult3","Catapult4"] - _busyCatapults;

if (count _availableCatapults == 0) exitWith {
	systemChat "A3C: All catapults are occupied at the moment";
};

private _catapult = _availableCatapults select 0;

private _partClass = if ((_catapult == "Catapult1") || {_catapult == "Catapult2"}) then {
	"Land_Carrier_01_hull_04_1_F"
} else {
	"Land_Carrier_01_hull_07_1_F"
};

private _carrierParts = _vehicle nearObjects [_partClass, 400];
private _part = _carrierParts param [0, objNull];

private _busyCatapultsUpdated = _carrier getVariable ["A3C_BUSYCATAPULTS",[]];
_busyCatapultsUpdated pushBackUnique _catapult;
_carrier setVariable ["A3C_BUSYCATAPULTS",_busyCatapultsUpdated,true];

private _configPath = configFile >> "CfgVehicles" >> _partClass >> "Catapults" >> _catapult;
private _carrierAnims = getArray (_configPath >> "animations");
private _memPoint = getText (_configPath >> "memoryPoint");
private _dirOffset = getNumber (_configPath >> "dirOffset");

private _posCatapult = _part modelToWorld (_part selectionPosition _memPoint);
_posCatapult set [2, _launchHeight];

private _dirCatapult = (getDir _part - _dirOffset - 180) % 360;

private _configPlane = configFile >> "CfgVehicles" >> typeOf _vehicle;
private _velocityLaunch = getNumber (_configPlane >> "CarrierOpsCompatability" >> "LaunchVelocity") max 210;
private _velocityIncrease = getNumber (_configPlane >> "CarrierOpsCompatability" >> "LaunchVelocityIncrease") max 75;
private _accelerationStep = getNumber (_configPlane >> "CarrierOpsCompatability" >> "LaunchAccelerationStep") max 0.025;
private _launchBar = getText (_configPlane >> "CarrierOpsCompatability" >> "LaunchBarMemoryPoint");

private _driver = driver _vehicle;
_driver disableAI "ALL";


//-- teleport aircraft to starting position and start procedure
_vehicle setPosWorld _posCatapult;
_vehicle setDir _dirCatapult;
_vehicle setAirplaneThrottle 1;
[_part, _carrierAnims, 10] spawn BIS_fnc_Carrier01AnimateDeflectors;

_vehicle allowDamage false;
_vehicle setFuel 1;
_vehicle engineOn true;

//-- make sure the plane does not move until deflectors are up
private _timer = time;
while {canMove _vehicle} do {
	if (time > _timer + 13) exitWith {};
	_vehicle setVelocity [0,0,0];
	_vehicle setDir _dirCatapult;
	sleep 0.1;
};

//-- add push to vehicle
private _currentVelocity = velocity _vehicle;
private _launchDirection = direction _vehicle;
private _launchPushSpeed = 100;

private _newVelocity = [
	(_currentVelocity select 0) + (sin _launchDirection * _launchPushSpeed),
	(_currentVelocity select 1) + (cos _launchDirection * _launchPushSpeed),
	12 //-- a little 'up' does not hurt. lower value becomes risky.
];

_vehicle setVelocity _newVelocity;
_vehicle setAirplaneThrottle 1;


//-- wait until plance has taken off, then reset catapult
sleep 5;

_vehicle allowDamage true;
[_part, _carrierAnims, 0] spawn BIS_fnc_Carrier01AnimateDeflectors;

_driver enableAI "ALL";

private _busyCatapultsFinal = _carrier getVariable ["A3C_BUSYCATAPULTS",[]];
_busyCatapultsFinal = _busyCatapultsFinal - [_catapult];
_carrier setVariable ["A3C_BUSYCATAPULTS",_busyCatapultsFinal,true];

_driver setVariable ["A3C_TAKING_OFF",false,true];
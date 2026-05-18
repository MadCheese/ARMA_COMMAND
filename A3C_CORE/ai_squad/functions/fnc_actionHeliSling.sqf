// A3C_ai_squad_fnc_actionHeliSling

params ["_mode","_vehicle","_cargo"];

//~~ might wanna ask underneath surface check

private _fnc_heliFreeze = {
	params ["_vehicle"];

	private _vectorDir = vectorDir _vehicle;
	private _timer = time + 2;

	while {time < _timer} do {
		_vehicle setVelocity [0,0,0];
		_vehicle setVectorDir _vectorDir;
	};
};

if (_cargo isEqualType []) then {
	if (surfaceIsWater _cargo) then {
		_cargo set [2,10];
	};
};

private _height = 15;

if (_mode == 0) then {
	private _cargoLocation = getPosATL _cargo;
	private _cargoHeight = (_cargoLocation select 2) + ((((boundingBoxReal _cargo) select 1) select 2) + 10);

	_cargoLocation set [2,_cargoHeight];

	_vehicle flyInHeight _cargoHeight;

	private _subBehaviour = [
		_vehicle,
		getPosASL _vehicle,
		ATLtoASL ((_cargoLocation select [0,2]) + [_height]),
		50
	] spawn A3C_ai_rail_fnc_helicopter;

	waitUntil {scriptDone _subBehaviour};

	_vehicle spawn _fnc_heliFreeze;

	private _slingAttachMemPoints = getArray (configFile >> "CfgVehicles" >> typeOf _vehicle >> "slingCargoAttach");

	_cargo enableRopeAttach true;
	_vehicle enableRopeAttach true;

	private _helperObjects = [];

	{
		private _helperObject = "Land_Can_V1_F" createVehicleLocal (_vehicle modelToWorldVisual [0,0,-1]);

		_helperObject setPos (_vehicle modelToWorldVisual [0,0,-4]);
		_helperObject hideObject true;
		_helperObject enableRopeAttach true;

		private _rope = ropeCreate [_vehicle, _x, _helperObject, [0, 0, -1], 100];

		_helperObjects pushBack _helperObject;

		sleep 1;
	} forEach _slingAttachMemPoints;

	{
		ropeDestroy _x;
	} forEach ropes _vehicle;

	{
		deleteVehicle _x;
	} forEach _helperObjects;

	while {isNull getSlingLoad _vehicle} do {
		_vehicle setSlingLoad _cargo;
		sleep 1;
	};

} else {
	//-- _cargo is _movePos here!! not the cargo itself
	//-- Note:  freezes the attached vehicle unnaturally

	private _subBehaviour = [_vehicle,ATLtoASL ((_cargo select [0,2]) + [_height]),false] spawn A3C_ai_rail_fnc_hoverApproach;

	waitUntil {scriptDone _subBehaviour};

	_vehicle spawn _fnc_heliFreeze;
	_vehicle setSlingLoad objNull;
};
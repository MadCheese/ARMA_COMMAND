// A3C_main_fnc_getVehicleBodyDimensions

params ["_vehicleType"];

private _measures = [];

private _dataBase = profileNamespace getVariable ["A3C_VehicleBodyDimensions", []];

{
	if ((_x select 0) == _vehicleType) exitWith {
		_measures = _x select 1;
	};
} forEach _dataBase;

if (count _measures > 0) exitWith {_measures}; //-- measures in database >> no need to do the costly checks


//-- create static measurement model
private _refVehicle = _vehicleType createVehicleLocal [100,100,1000];
_refVehicle enableSimulation false;
_refVehicle setPosASL (ATLtoASL [100,100,1000]);

private _vehicleHeight = _refVehicle call BIS_fnc_objectHeight;

private _refBbox = [_refVehicle,0] call MCSS_fnc_BBOX;
{
	_x set [2,1000];
} forEach _refBbox;

private _testPosRoot = ATLtoASL (_refBbox select 0);
private _testPosZ = _testPosRoot select 2;

private _reference_L1 = ((_refBbox select 1) distance2D (_refBbox select 2)); //   WIDTH    7;
private _reference_L2 = ((_refBbox select 0) distance2D (_refBbox select 1)); //   LENGHT   3;


private _rotorWidth = if (_refVehicle isKindOf "HELICOPTER") then {_reference_L2} else {0};



private _maxWidth = 0;
private _length = 0;

private _bodyStartY = [0,0,0];
private _isBodyY = false;

//-- take body measures

private _scanLimitL1 = [_reference_L1,1] call BIS_fnc_cutDecimals;
private _scanLimitL2 = [_reference_L2,1] call BIS_fnc_cutDecimals;

//-- the following assumes a vehicle with a orientation of 0 deg
for "_i" from 0 to _scanLimitL1 step 0.1 do {
	private _subRoot = _testPosRoot getPos [_i, 0];
	_subRoot set [2,_testPosZ];

	private _isBodyX = false;
	private _exit = false;
	private _bodyStartX = [0,0,0];
	private _intsCount = 0;

	//-- width checks
	for "_t" from 0 to _scanLimitL2 step 0.1 do {
		private _refpos2 = _subRoot getPos [_t, 90];
		_refpos2 set [2,_testPosZ];

		private _refpos3 = [_refpos2 select 0,_refpos2 select 1,(_refpos2 select 2) + _vehicleHeight];
		private _ints = lineIntersects [_refpos3,_refpos2];

		if (_ints) then {
			_intsCount = _intsCount + 1;
			if !(_isBodyX) then {
				_bodyStartX = +(_refpos3);
			};
			_isBodyX = true;
		} else {
			if (_isBodyX) then {
				_exit = true;
				private _width = _refpos3 distance2D _bodyStartX;
				if (_width > _maxWidth) then {
					_maxWidth = _width;
				};
			};
		};
		if (_exit) exitWith {};
	};

	//-- legth checks
	if (_intsCount > 0) then {
		if !(_isBodyY) then {
			_bodyStartY = +(_subRoot);
		};
		_isBodyY = true;
	} else {
		if (_isBodyY) then {
			_length = _subRoot distance2D _bodyStartY;
			_isBodyY = false;
		};
	};
};

deleteVehicle _refVehicle;

_measures = [_maxWidth - 1,_length - 1,_vehicleHeight,_rotorWidth];
_dataBase pushBack [_vehicleType,_measures];
profileNamespace setVariable ["A3C_VehicleBodyDimensions",_dataBase];

_measures
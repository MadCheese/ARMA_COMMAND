// A3C_ai_squad_fnc_actionHeliLandFinal

params ["_unit","_playerUnit","_movePos"];

private _vehicle = vehicle _unit;
private _abort = false;

if (_vehicle isKindOf "PLANE") then {
	[_unit,position _vehicle] spawn A3C_ai_shared_fnc_planeLanding;
} else {
	_unit setVariable ["A3C_WAITCARGO",true,true];

	private _maxDist = 20;
	private _landingPos = [];

	while {count _landingPos == 0} do {
		if ({_x} count (_unit getVariable ["A3C_ABORT_Data",[]]) > 0) then {
			_abort = true;
		};

		_landingPos = [_movePos,[0,_maxDist]] call MCSS_fnc_getSafePos;
		_maxDist = _maxDist + 20;
	};

	private _pad = "Land_HelipadEmpty_F" createVehicle _landingPos;

	if !(_abort) then {sleep 2};
	if !(_abort) then {sleep 1};

	_vehicle land "LAND";

	sleep 1;

	{
		private _cargoUnit = _x;

		if ([_cargoUnit] call A3C_main_fnc_shouldEjectFromHeli) then {
			[_cargoUnit] spawn MCSS_fnc_GetOut;
		};

		if ((group _cargoUnit != group _playerUnit) && {_cargoUnit == leader group _cargoUnit}) then {
			private _cargoGroup = group _cargoUnit;
			[_cargoGroup,_vehicle] remoteExec ["leaveVehicle", leader _cargoGroup];
		};
	} forEach ((crew _vehicle) - [_unit]);

	private _doorSources = [
		"door_R",
		"door_L",
		"door_rear",
		"door_rear_source",
		"Door_L_source",
		"Door_R_source",
		"DoorL_Front_Open",
		"DoorR_Front_Open",
		"DoorL_Back_Open",
		"DoorR_Back_Open",
		"Door_1_source"
	];

	while {alive _unit} do {
		if (isNull _unit) exitWith {
			_abort = true;
		};

		{
			_unit disableAI _x;
		} forEach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"THREAT_PATH","PATHPLAN",

		_unit doTarget _vehicle;
		_unit doWatch objNull;

		{
			_unit setSkill [_x,0];
		} forEach ["commanding","spotTime","spotDistance"];

		if (((position _vehicle) select 2) < 2) exitWith {
			_vehicle land "LAND";
			_vehicle flyInHeight 0;

			{
				_vehicle animateDoor [_x, 1];
			} forEach _doorSources;

			sleep 3;

			if (_playerUnit in _vehicle) then {
				[_playerUnit,["eject",_vehicle]] remoteExec ["action",_playerUnit];
			};

			[_vehicle,_pad,_unit] spawn {
				params ["_chopper","_pad","_unit"];

				while {((position _chopper) select 2) < 2} do {
					if (isNull _unit) exitWith {};

					if ({isPlayer _x} count (crew _chopper) == 0) exitWith {
						sleep 2;

						[_chopper,["engineOff", _chopper]] remoteExec ["action",_chopper];

						deleteVehicle _pad;

						_chopper setVelocity [0,0,0];
						_chopper flyInHeight 50;
					};

					if ({_x} count (_unit getVariable ["A3C_ABORT_Data",[]]) > 0) exitWith {};

					sleep 0.1;
				};
			};
		};

		if ({_x} count (_unit getVariable ["A3C_ABORT_Data",[]]) > 0) exitWith {
			_abort = true;
			_vehicle land "NONE";
		};

		if !(_vehicle isKindOf "AIR") then {
			_abort = true;
		};

		if (currentCommand _unit == "STOP") then {
			if !(((expectedDestination _unit) select 1) == "LEADER PLANNED") then {
				if !((effectiveCommander _vehicle) == _unit) then {
					if !(((expectedDestination (effectiveCommander _vehicle)) select 1) == "LEADER PLANNED") then {
						_abort = true;
					};
				} else {
					_abort = true;
				};
			};
		};

		if !(canMove _vehicle) then {
			_abort = true;
		};

		if !(alive _unit) then {
			_abort = true;
		};

		if ({_x} count (_unit getVariable ["A3C_ABORT_Data",[]]) > 0) then {
			_abort = true;
		};

		if (((expectedDestination _unit) select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
			_abort = true;
		};

		if (_abort) exitWith {};

		sleep 1;
	};
};

if !(_abort) then {
	while {alive driver _vehicle} do {
		if ({[_x] call A3C_main_fnc_shouldEjectFromHeli} count (crew _vehicle) == 0) exitWith {
			doStop _unit;

			sleep 1;

			[_vehicle,["engineOff", _vehicle]] remoteExec ["action",_vehicle];

			_vehicle spawn {
				sleep 8;
				_this flyInHeight (_this getVariable ["A3C_FLYINHEIGHT",25]);
			};
		};

		sleep 1;
	};
};
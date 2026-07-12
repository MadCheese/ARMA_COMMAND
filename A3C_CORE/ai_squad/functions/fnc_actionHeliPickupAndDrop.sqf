// A3C_ai_squad_fnc_actionHeliPickupAndDrop

params ["_unit","_playerUnit","_movePos","_wtf","_landingdata"];

private _vehicle = vehicle _unit;

if (_vehicle isKindOf "PLANE") then {
	[_unit,position _vehicle] spawn A3C_ai_shared_fnc_planeLanding;
} else {
	_unit setVariable ["A3C_WAITCARGO",true,true];

	private _abort = false;
	private _maxDist = 20;
	private _landingPos = [];
	private _pad = objNull;
	private _shell = objNull;

	while {count _landingPos == 0} do {
		if (isNull _unit) exitWith {
			_abort = true;
		};

		_landingPos = [_movePos,[0,_maxDist]] call MCSS_fnc_getSafePos;
		_maxDist = _maxDist + 20;

		if ({_x} count (_unit getVariable ["A3C_ABORT_Data",[]]) > 0) exitWith {
			_abort = true;
		};
	};

	if (_abort) exitWith {};

	_pad = "Land_HelipadEmpty_F" createVehicle _landingPos;

	[_unit,_landingPos] call A3C_ai_shared_fnc_doMove;

	if (_landingdata == "PICKUP") then {
		_shell = "Smokeshellgreen" createVehicle _landingPos;
	};

	sleep 2;

	if (_landingdata == "PICKUP") then {
		[_vehicle, _playerUnit] execFSM "A3C_CORE\FSM\A3C_AssignPlayerToVehicleCargo.fsm";
		_vehicle land "GET IN";
	} else {
		_vehicle land "GET OUT";
	};

	[_unit,_vehicle,_landingdata,_wtf,_landingPos,_playerUnit] spawn { //~~ should this not be the same? landingdata == 14
		params ["_unit","_vehicle","_type","_position","_landingPos","_playerUnit"];

		private _vehicleDisplayName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");

		_unit groupChat format [
			"This is %1-%2, my %3 is approaching the %4 LZ at %5, over",
			groupID group _playerUnit,
			_unit getVariable "A3C_FORMATION_INDEX",
			parseText _vehicleDisplayName,
			parseText _type,
			mapGridPosition _landingPos
		];

		if (
			{
				(((_x select 2) getFriend (side _unit)) < 0.6) &&
				{_unit knowsAbout (_x select 4) > 1.5} &&
				{((_x select 4) distance _landingPos) < 300}
			} count (_unit nearTargets viewDistance) > 0
		) then {
			_unit groupChat "Caution, LZ is hot!";
		};
	};

	sleep 2;

	if (_landingdata == "DROPOFF") then {
		{
			private _cargoUnit = _x;

			if ([_cargoUnit] call A3C_main_fnc_shouldEjectFromHeli) then {
				[_cargoUnit] spawn A3C_ai_shared_fnc_getOut;
			};

			if ((group _cargoUnit != group _playerUnit) && {_cargoUnit == leader group _cargoUnit}) then {
				private _cargoGroup = group _cargoUnit;
				[_cargoGroup,_vehicle] remoteExec ["leaveVehicle", leader _cargoGroup];
			};
		} forEach ((crew _vehicle) - [_unit]);
	};

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

		if (_vehicle isKindOf "AIR") then {
			{
				_unit disableAI _x;
			} forEach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"THREAT_PATH","PATHPLAN",

			_unit doTarget _vehicle;
			_unit doWatch objNull;

			{
				_unit setSkill [_x,0];
			} forEach ["commanding","spotTime","spotDistance"];
		};

		if ({_x} count (_unit getVariable ["A3C_ABORT_Data",[]]) > 0) exitWith {
			_vehicle land "NONE";

			{
				//- unassign all units outside of chopper. necessary?
				if ((assignedVehicle _x) == _vehicle) then {
					if !(_x in _vehicle) then {
						_x remoteExec ["unAssignVehicle",0];
					};
				};
			} forEach (allUnits - [_unit]);

			[_unit,[(position _vehicle),1000,(random 360)] call BIS_fnc_RelPos] call A3C_ai_shared_fnc_doMove;

			_vehicle flyInHeight 25;

			_abort = true;
		};

		if (((position _vehicle) select 2) < 2) exitWith {
			deleteVehicle _pad;

			[_unit,position _vehicle] call A3C_ai_shared_fnc_doMove;

			_vehicle flyInHeight 2;

			{
				_vehicle animateDoor [_x, 1];
			} forEach _doorSources;

			sleep 2;

			if (_landingdata == "DROPOFF") then {
				if (_playerUnit in _vehicle) then {
					[_playerUnit,["eject",_vehicle]] remoteExec ["action",_playerUnit];
				};
			};
		};

		if !(canMove _vehicle) exitWith {};

		sleep 1;
	};
};
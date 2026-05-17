




























































//
A3C_CAS_PreventAction = {
	params ["_group","_wpIndex","_wpPosition"];
	private _lastWpPosition = [];
	private _leaderVehicle = vehicle (leader _group);
	private _activeWaypoints = [];
	private _lastWpPosition = [0,0,0];
	private _lastWpIndex = -1;
	//systemchat 'ayoyo';
	_activeWaypoints = waypoints _group;
	{
		if (_x select 1 < _wpIndex) then {
			_activeWaypoints = _activeWaypoints - [_x];
		};
	} foreach _activeWaypoints;
	// systemchat str [_wpIndex, (_activeWaypoints select 0) select 1];
	if ( (count _activeWaypoints == 0) OR {(_wpIndex == ((_activeWaypoints select 0) select 1) ) && {position (vehicle leader _group) distance2D (waypointPosition [_group, currentWaypoint _group]) < 200}}  )then {
		_lastWpPosition = position (_leaderVehicle);
	} else {
		{

			if (_x select 1 == _wpIndex) exitWith {
				_lastWpIndex = _wpIndex -1; //-- here we can use the actual waypointIndex as the sequence is assured
				_lastWpPosition = waypointPosition [_group,_lastWpIndex];
			};
		} foreach _activeWaypoints;
	};
	//player commandchat str [(_lastWpPosition distance2D _wpPosition)];
	private _return = if (_lastWpPosition distance2D _wpPosition < 3000) then {true} else {false};
	_return
};

//publicVariable 'A3C_ai_highCommand_fnc_moduleCAS';

if (isDedicated) exitWith {};

//-- SQUAD LEVEL / CLIENT ONLY
A3C_BEHAVIOUR_SQ_HELI_PICKANDDROP = {
	params ["_unit","_playerUnit","_movePos","_wtf","_landingdata"];
	private ["_landingpos","_maxdist","_pad","_shell"];
	_vehicle = vehicle _unit;
	if (_vehicle isKindOf "PLANE") then {
		[_unit,position _vehicle] spawn A3C_ai_shared_fnc_planeLanding;
	} else {
		_unit Setvariable ["A3C_WAITCARGO",true,true];
		_maxdist = 20;
		_landingpos = [];
		while {count _landingpos == 0} do {
			if (isNull _unit) exitWith {_abort = true};
			_landingpos = ([_movePos,[0,_maxdist]] call MCSS_fnc_getSafePos);
			_maxdist = _maxdist + 20;
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true};
		};
		_pad = "Land_HelipadEmpty_F" createvehicle _landingpos;
		[_unit,_landingpos] call A3C_ai_shared_fnc_doMove;
		if (_landingdata == "PICKUP") then {
			_shell = "Smokeshellgreen" createVehicle _landingpos;
		};
		sleep 2;
		//_vehicle land "_pad";
		if (_landingdata == "PICKUP") then {
			[_vehicle, _playerUnit] execFSM "A3C_CORE\FSM\A3C_AssignPlayerToVehicleCargo.fsm";
			_vehicle land "GET IN";
		} else {
			_vehicle land "GET OUT";
		};
		[_unit,_vehicle,_landingdata,_wtf,_landingpos,_playerUnit] spawn { //~~ should this not be the same? landingdata == 14
			params ["_unit","_vehicle","_type","_position","_landingpos","_playerUnit"];
			_unit groupchat format ["This is %1-%2, my %3 is approaching the %4 LZ at %5, over",(groupID group _playerUnit),(_unit getvariable "A3C_FORMATION_INDEX"),(parsetext  (getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"))),(parsetext _type),(mapgridposition _landingpos)];
			if (({(( ((_x select 2) getfriend (side _unit)) < 0.6)) && (_unit knowsabout (_x select 4) > 1.5) && (((_x select 4) distance _landingpos) < 300)} count (_unit neartargets viewdistance)) > 0) then {
				_unit groupchat "Caution, LZ is hot!";
			};
		};
		sleep 2;
		if (_landingdata == "DROPOFF") then {
			{
				//if !( (typeof _x) in ["B_Helipilot_F","B_Pilot_F","B_Helicrew_F","I_Helipilot_F","I_Helicrew_F","I_Pilot_F","O_Helipilot_F","O_Helicrew_F","O_Pilot_F"] ) then {
				if ([_x] call A3C_main_fnc_shouldEjectFromHeli) then {
					//unassignvehicle _x;
					[_x] spawn MCSS_fnc_GetOut;
					//-- loop
				};
				if ( (group _x != group _playerUnit) && (_x == leader group _x)) then {
					private _cargoGP = group _x;
					[_cargoGP,_vehicle] remoteExec ["leaveVehicle", leader _cargoGP];
				};
			} foreach (crew _vehicle) - [_unit]; //
		};

		while {(alive _unit)} do {
			if (isNull _unit) exitWith {_abort = true};
			if (_vehicle iskindof "AIR") then {
				{_unit disableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"THREAT_PATH","PATHPLAN",
				_unit dotarget _vehicle; _unit dowatch objnull;
				{_unit setskill [_x,0]} foreach ["commanding","spotTime","spotDistance"];
			};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {
				_vehicle land "NONE";

				{
					//- unassign all units outside of chopper. necessary?
					if ((assignedvehicle _x) == _vehicle) then {
						if !(_x in _vehicle) then {
							_x remoteExec ["unAssignVehicle",0];
						};
					};
				} foreach allunits - [_unit];
				[_unit,([(position _vehicle),1000,(random 360)] call BIS_fnc_Relpos)] call A3C_ai_shared_fnc_doMove;
				_vehicle flyinheight 25;
				_abort = true;
			};
			if ( ((position _vehicle) select 2) < 2) exitWith {
				deletevehicle _pad;
				[_unit,(position _vehicle)] call A3C_ai_shared_fnc_doMove;
				_vehicle flyinheight 2;
				{_vehicle animateDoor [_x, 1]} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
				sleep 2;
				if (_landingdata == "DROPOFF") then {
					if (_playerUnit in _vehicle) then {
						//_playerUnit action ["eject",_vehicle];
						[_playerUnit,["eject",_vehicle]] remoteExec ["action",_playerUnit];
					};
				};
			};
			if !(canmove _vehicle) exitWith {};
			sleep 1;
		};
	};
};



A3C_BEHAVIOUR_SQ_HELI_LANDFINAL = {
	params ["_unit","_playerUnit","_movePos"];
	private ["_vehicle","_maxdist","_landingpos","_pad","_abort"];
	_vehicle = vehicle _unit;
	_abort = false;
	if (_vehicle isKindOf "PLANE") then {
		[_unit,position _vehicle] spawn A3C_ai_shared_fnc_planeLanding;
	} else {
		_unit Setvariable ["A3C_WAITCARGO",true,true];
		_maxdist = 20;
		_landingpos = [];
		while {count _landingpos == 0} do {
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) then {_abort = true};
			_landingpos = ([_movePos,[0,_maxdist]] call MCSS_fnc_getSafePos);
			_maxdist = _maxdist + 20;
		};

		_pad = "Land_HelipadEmpty_F" createvehicle _landingpos;
//		[_unit,_landingpos] call A3C_ai_shared_fnc_doMove;
		if !(_abort) then {sleep 2};
		//_vehicle land "_pad";
		if !(_abort) then {sleep 1};
		_vehicle land "LAND";
		sleep 1;
		{
			//if !( (typeof _x) in ["B_Helipilot_F","B_Pilot_F","B_Helicrew_F","I_Helipilot_F","I_Helicrew_F","I_Pilot_F","O_Helipilot_F","O_Helicrew_F","O_Pilot_F"] ) then {
			if ([_x] call A3C_main_fnc_shouldEjectFromHeli) then {
				[_x] spawn MCSS_fnc_GetOut;
			};
			if ( (group _x != group _playerUnit) && (_x == leader group _x)) then {
				private _cargoGP = group _x;
				[_cargoGP,_vehicle] remoteExec ["leaveVehicle", leader _cargoGP];
			};
		} foreach (crew _vehicle) - [_unit];

		while {(alive _unit)} do {
			if (isNull _unit) exitWith {_abort = true};
			{_unit disableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //"THREAT_PATH","PATHPLAN",
			_unit dotarget _vehicle; _unit dowatch objnull;
			{_unit setskill [_x,0]} foreach ["commanding","spotTime","spotDistance"];


			if ( ((position _vehicle) select 2) < 2) exitWith {
				_vehicle land "LAND";
				_vehicle flyinheight 0;
				{_vehicle animateDoor [_x, 1]} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
				sleep 3;
				if (_playerUnit in _vehicle) then {
					//_playerUnit action ["eject",_vehicle];
					[_playerUnit,["eject",_vehicle]] remoteExec ["action",_playerUnit];
				};
				[_vehicle,_pad,_unit] spawn {
					params ["_chopper","_pad","_unit"];
					_chopper = _this select 0;
					while {(((position _chopper) select 2) < 2)} do {
						if (isNull _unit) exitWith {_abort = true};
						if ( {isPlayer _x} count (crew _chopper) == 0 ) exitWith {
							sleep 2;
							//_chopper action ["engineOff", _chopper];
							[_chopper,["engineOff", _chopper]] remoteExec ["action",_chopper];
							deletevehicle _pad;
							_chopper setvelocity [0,0,0];
							_chopper flyInHeight 50;
						};
						if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {};
						sleep 0.1;
					};
				};
			};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {
				_abort = true;
				_vehicle land "NONE";
			};
			if !(_vehicle iskindof "AIR") then {_abort = true};
			if (currentcommand _unit == "STOP") then {
				if !( ((expectedDestination _unit ) select 1) == "LEADER PLANNED") then {
					if !( (effectivecommander _vehicle) == _unit) then {
						if !( ((expectedDestination (effectivecommander _vehicle)) select 1) == "LEADER PLANNED") then {
							_abort = true;
						};
					} else {
						_abort = true;
					};
				};
			};
			if !(canmove _vehicle) then {_abort = true};
			if !(alive _unit) then {_abort = true};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) then {_abort = true};
			if (((expectedDestination _unit) select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {_abort = true;};
			if (_abort) exitWith {};
			sleep 1;
		};
	};
	if !(_abort) then {
		while {alive driver _vehicle} do {
			if ( {[_x] call A3C_main_fnc_shouldEjectFromHeli} count (crew _vehicle) == 0 ) exitWith {
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
};


A3C_BEHAVIOUR_SQ_HELI_Sling = {
	params ["_mode","_veh","_cargo"];
	private ["_cargoLocation","_subBehaviour","_memPoints","_turnVeh","_cargoHeight"];

	//~~ might wanna ask underneath surface check

	_heliFreeze = {
		params ["_veh"];
		private _vectorDir = vectorDir _veh;
		_timer = time + 2;
		while {time < _timer} do {
			_veh setVelocity [0,0,0];
			_veh setVectorDir _vectorDir;
		};

	};

	if (_cargo isEqualType []) then {
		if (surfaceIsWater _cargo) then {
			_cargo set [2,10];
			//_cargo = ASLtoATL _cargo;
		};
	};


	_height = 15;

	if (_mode == 0) then {
		_cargoLocation = getPosATL _cargo;
		_cargoHeight = (_cargoLocation select 2) + ((((boundingBoxreal _cargo) select 1) select 2) + 10);
		_cargoLocation set [2,_cargoHeight];
		_veh flyInHeight _cargoHeight;

		//while {canMove _veh} do {
		//	if (speed _veh < 60) exitWith {};
		//	sleep 1;
		//};
		//_turnVeh = [_veh,_cargoLocation] spawn A3C_FORCEORIENT;
		//waitUntil {scriptDone _turnVeh};
		_subBehaviour =
		[
			_veh,
			getPosASL _veh,
			ATLtoASL ((_cargoLocation select [0,2]) + [_height]),
			50
		] spawn A3C_ai_rail_fnc_helicopter;
		waituntil {scriptDone _subBehaviour};
		_veh spawn _heliFreeze;
		_memPoints = getArray (configfile >> "CfgVehicles" >> typeOf _veh >> "slingCargoAttach");
		_cargo enableRopeAttach true;
		_veh enableRopeAttach true;
		_cans = [];
		{
			_veh1 = "Land_Can_V1_F" createVehicleLocal (_veh modelToWorldVisual [0,0,-1]);
			_veh1 setpos (_veh modelToWorldVisual [0,0,-4]);
			_veh1 hideObject true;
			_veh1 enableRopeAttach true;
			_rope = ropeCreate [_veh, _x, _veh1, [0, 0, -1], 100];
			_cans pushback _veh1;
			sleep 1;
		} foreach _memPoints;
		{ropedestroy _x} foreach ropes _veh;
		{deleteVehicle _x} foreach _cans;
		while {isNull getSlingLoad _veh} do {
			_veh setSlingLoad _cargo;
			sleep 1;
		};

	} else {
		//-- _cargo is _movePos here!! not the cargo itself
		//-- Note:  freezes the attached vehicle unnaturally
		//_subBehaviour = [_veh,_cargo,_height] spawn A3C_ai_rail_fnc_helicopterDuda; //-- leave in place as option
		_subBehaviour = [_veh,ATLtoASL ((_cargo select [0,2]) + [_height]),false] spawn A3C_ai_rail_fnc_hoverApproach;
		waituntil {scriptDone _subBehaviour};
		_veh spawn _heliFreeze;
		_veh setSlingLoad objNull;
	};
};



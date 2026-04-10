
A3C_RESET_PLANE = {	
	if (!isNil 'plane1') then {
		{
			deletevehicle _x;
		} foreach ( (crew plane1) + [plane1]);
		{deletegroup _x} foreach [pilotgroup];
	};
	A3C_TEST_UNITS = [];	

	plane1 = createVehicle ["RHS_A10", [0,0,100], [], 0, "NONE"];
	plane1 setposASL [11609.1,2259.07,23.4016];
	plane1 setfuel 0;
	plane1 setdir 50.5528;
	publicvariable 'plane1';
	pilotgroup = createGroup WEST;
	publicvariable 'pilotgroup';
	_crew = [plane1,pilotgroup ] call BIS_fnc_spawnCrew;
	{
		if (_foreachIndex > 3) then {
			deletevehicle _x;
		};
	} foreach units A3C_TEST_CREWGROUP;
};

[] spawn A3C_RESET_PLANE;





A3C_RESET = {	
	if (!isNil 'A3C_TEST_UNITS') then {
		{
			deletevehicle _x;
		} foreach ( (crew heli) + A3C_TEST_UNITS + [heli]);
		{deletegroup _x} foreach [A3C_TEST_CREWGROUP,gp1];
	};
	A3C_TEST_UNITS = [];	
	_pos = screentoworld [0.5,0.5];
	heli = createVehicle ["RHS_CH_47F_10", _pos, [], 0, "NONE"];
	publicvariable 'heli';
	A3C_TEST_CREWGROUP = createGroup WEST;
	_crew = [heli,A3C_TEST_CREWGROUP] call BIS_fnc_spawnCrew;
	{
		if (_foreachIndex > 3) then {
			deletevehicle _x;
		};
	} foreach units A3C_TEST_CREWGROUP;
	_pos = _pos getpos [20,340];	
	gp1 = creategroup WEST;	
	for "_i" from 1 to 7 do {
		_unit = gp1 createUnit ["B_SOLDIER_F", _pos, [], 0, "FORM"];
		A3C_TEST_UNITS pushback _unit;
	};
	gp1 setGroupID ['FS'];
	publicVariable 'gp1';
};

[] spawn A3C_RESET;







A3C_getDismountData_OLD = { //-- not 100% role proof it seems, also a more complex attempt then the above (would prevent turret desertion from other groups)
	params ["_vehicle1","_pilot"];
	private _list = [];
	private _nonDismountAIgroups = [];
	{
		_addToList = false;
		
		if !(group _x == group _pilot) then {(str _x) remoteExec ["systemChat",0]};
		if (isPlayer (leader group _x) && !(group _x == group _pilot)) then { //-- always drop unit if his leader is a player and pilot is NOT in his group
			_addToList = true;
		} else {
			private _aVr = (assignedVehicleRole _x);
			if (count _aVr > 0) then {
				if (_aVr select 0 == "CARGO") then {
					_addToList = true;
				};
				if (_aVr select 0 == "Turret") then {
					private _turret = (assignedVehicleRole _x) select 1;
					if (count (_vehicle1 weaponsTurret _turret) == 0 ) then {//-- FFV positions
						_addToList = true; 
					};
					if (_x call MCSS_fnc_isUnitCopilot) then { //-- coPilot position
						_addToList = true;
					} else {
						if (!_addToList && group _x != group _pilot) then {
							(str _x) remoteExec ["systemchat",0];
						};
					};		
				};
			} else {
				//-- no role assigned: treated as ejectable
				_addToList = true;
			};
		};
		if (_addToList) then {
			_list pushBackUnique _x;
		} else {
			if !(isPlayer (leader group _x)) then {
				_nonDismountAIgroups pushBack (group _x);
			};
		};
		
	} foreach ((crew _vehicle1) - [_pilot]);
	
	{
		if (!isPlayer (leader group _x) ) then { 
			if (group _x == group _pilot) then { //-- do not dismount pilot-group members unless leader is a player
				_list = _list - [_x];
			};
			if ((group _x) in _nonDismountAIgroups) then { //-- do not dismount group members of turret units unless leader is a player
				_list = _list - [_x];
			};
		};
	} foreach _list;
	
	
//	_removeSquadUnits = if (group player == group _pilot) then {true} else {false};
//	
//	{
//		if ( [_x] call A3C_HELI_DISCHARGE) then {
//			//if () then {
//				_list pushBackUnique _x;
//			//};
//		};
//	} foreach crew _vehicle1;
//	if !(_removeSquadUnits) then {
//		{
//			if (group _x == group _pilot) then {
//				_list = _list - [_x];
//			};
//		} foreach _list;
//	};
	_list = [_list,[],{if (_x == leader group _x) then {1} else {0}},"DESCEND"] call BIS_fnc_sortBy;
	[_list,_nonDismountAIgroups]	
};






TFUNC = {
	params ["_unit","_vehicle","_group"];
	private _nextWpPos = [0,0,0];
	if (A3C_isAICommand) then {
		private _AICwaypoints = ([_group] call AIC_fnc_getAllActiveWaypoints) select 1;
		if (count _AICwaypoints > 0) then {
			//private _cwp = [_group] call A3C_AIC_currentWaypoint; 
			//_nextWpPos = [_group,((_AICwaypoints select 0) select 0),"ACTIVE","Position"] call A3C_AIC_returnWaypointData;
			_nextWpPos = (_AICwaypoints select 0) select 1;
			
		};
	} else {
		_nextWpPos = waypointposition [_group, currentWaypoint _group];
	};
	//{_x setpos _nextWpPos} foreach allPlayers;
	if (_nextWpPos distance2D [0,0,0] > 0) then {
		//for "_i" from 1 to 3 do {
		while {alive _vehicle && speed _vehicle < 1} do {
			[_unit,_nextWpPos] remoteExec ["doMove",_unit];
			[_vehicle,1500] remoteExec ["limitSpeed",_vehicle];
			sleep 3;
		};	
	};  
};
[driver heli,heli, group driver heli] spawn TFUNC;
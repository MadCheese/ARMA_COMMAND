
//-- THIS FUNCTION IS REQUIRED REGARDLESS OF AIC!!
A3C_AIC_fnc_rappelActionHandler = {
	params ["_group","_cargoGroups","_selectedPosition","_inside"];
	_vehicle = (vehicle leader _group);
	if(count _selectedPosition > 0) then {
		[_vehicle,25, _selectedPosition] call AR_Rappel_All_Cargo; //-- AGLtoASL   //ATLtoASL _selectedPosition
		{
			[_x,_vehicle] spawn {
				params ["_groupRappelling","_vehicle"];
				_unitsInVehicle = true;
				while {_unitsInVehicle} do {
					_unitsInVehicle = false;
					{
						if(vehicle _x != _x) then {
							_unitsInVehicle = true;
						};
					} forEach (units _groupRappelling);
					sleep 1;
				};
				[_groupRappelling,_vehicle] remoteExec ["leaveVehicle", leader _groupRappelling]; //~~ _x
			};
		} foreach _cargoGroups;
	};
};

A3C_AIC_DRAGPOS = [];


////---- RAPPELL HERE
A3C_BEHAVIOUR_HELI_RAPPEL = {
	params ["_unit","_caller","_movePos"];
	private ["_intS","_bdg","_aircraft","_dirTo","_step","_hoverHeight","_nB","_inside","_refpos","_intS","_ch","_bdg","_group"];

	_group = group _unit;
	private _aircraft = vehicle _unit;
	_dirTo = [_aircraft,_movePos] call BIS_fnc_relativedirTo;
	_step = if (_dirTo > 180) then {-1} else {1};

	_nB = (nearestBuilding _movePos);
	_inside = false;
	_refPos = +(_movePos);
	_refpos = ATLtoASL _refpos; _refPos set [2,(_refpos select 2) + 100];
	_intS = lineintersectsSurfaces [_refPos,(ATLtoASL ((_movePos select [0,2]) + [0])),_aircraft, objnull];
	_bdg = objNull;
	private _isHeli = _aircraft isKindOf "HELICOPTER";



	private _dismountData = [_aircraft,_unit] call A3C_getDismountData;
	_dismountData params ["_rapUnits","_nonDismountAIgroups"];


	private _bPosRail = {
		params ["_u","_roofPoses","_bdg"];
		sleep 2;
		while {alive _u} do {
			if (isTouchingGround _u) exitWith {
				private _dest = [0,0,0];
				_roofPoses = [_roofPoses,[],{_u distance2D (_x select 1)},"ASCEND"] call BIS_fnc_sortBy;
				{
					if !((_x select 1) in A3C_OCC_BPOSES) exitWith {
						_dest = _x select 1;
						A3C_OCC_BPOSES pushbackUnique _dest;
					};
				} foreach _roofPoses;
				if (_dest isEqualTo [0,0,0] && {count _roofPoses > 0}) then {
					_dest = _roofPoses select 0;
				};
				if !(_dest isEqualTo [0,0,0]) then {
					[_u,_dest,_bdg] spawn A3C_RAIL_INF;
				};
			};
			if !(isNull objectParent _u) exitWith {};
			sleep 0.5;
		};
	};

	private _exit = false;
	while {(getPos _aircraft select 2) < 15} do {
		if (!alive _unit OR !alive _aircraft) exitWith {_exit = true};
		sleep 1;
	};

	if (_exit) exitWith {};



	//-- AI heli slow down
	if (!isPlayer leader _group && {_isHeli}) then {
		while {true} do {
			_speed = switch (true) do {
				case (_aircraft distance2D _movePos < 200) : {40};
				case (_aircraft distance2D _movePos < 1000) : {100};
				default {150};
			};
			[_aircraft,_speed] remoteExec ["limitSpeed",_aircraft];
			if (!alive _aircraft) exitWith {};
			if (speed _aircraft < 10) exitWith {}; //-- security measue if heli comes to a premature halt

			if (_aircraft distance2D _movePos <= 300) exitWith {};
			sleep 1;
		};
	};
	if (!alive _aircraft) exitWith {};

	//-- determine approach type
	[_aircraft,0] remoteExec ["limitSpeed",_aircraft];
	private _rappelPos = ((_movePos select [0,2]) + [0]); //-- base for _rappelPos (ATL)
	private _railPos = [];
	private _roofPoses = [];
	// if (true) then { 
		//--  Guide chopper towards exact position


		{
			//systemchat str (_x select 2);
			if ((_x select 2) iskindOf "BUILDING") exitWith {
				_bdg = (_x select 2);
				//_hoverHeight = ((ASLtoATL (_x select 0)) select 2) + 30;
				_rappelPos set [2,((ASLtoATL (_x select 0)) select 2)]; //-- changed height (pos now snapped to roof (ATL)
				_inside = true;
				_roofPoses = [_bdg] call MCSS_fnc_get_buildingPoses_roof;

			};
		} foreach _ints;

		//-- SQUAD LEVEL: WAIT UNTIL VEHICLE STOPS OR REACHES WAYPOINT
		if (isPlayer leader _group && {_isHeli}) then {
			while {_aircraft distance2d _movePos > 300} do {
				if (!alive _unit) exitWith {};
				if !(canMove _aircraft) exitWith {};
				if (speed _aircraft < 20) exitWith {};
				//systemchat 'loop';
				sleep 0.1;
			};
		};
		_hoverHeight = (_rappelPos select 2) + 155;

		[_unit,(getposASL _aircraft)] remoteExec ["domove",_unit];   //-- ASL used for speed i assume since aircraft moves in 2d
		[_aircraft,_hoverHeight] remoteExec ["flyInHeight",_aircraft];

		_railPos = ATLtoASL _rappelPos;
		_railPos set [2,(_railPos select 2) + 25];

		//-- Spawn DUDA's CHOPPER RAIL
		if (alive _unit) then {
			_subBehaviour = {};
			if (_isHeli) then {

				_subBehaviour =
				[
					_aircraft,
					getPosASL _aircraft,
					_railPos,
					50
				] spawn A3C_AI_RAIL_HELI;
			} else {
				_subBehaviour = [_aircraft, _railPos,_inside] spawn A3C_AI_RAIL_VTOL;
			};
			waituntil {scriptDone _subBehaviour};

		};
	// } else {
	// 	//-- waypoint is in the open. Simply wait for it to come to a halt NOT USED CURRENTLY. ABOVE BOOL IS TRUE, RAIL IS ALWAYS USED
	// 	while {speed _aircraft > 0} do {
	// 		if (!alive _unit) exitWith {};
	// 		if !(canMove _aircraft) exitWith {};
	// 		sleep 0.1;
	// 	};

	// 	while {((getPosATL _aircraft) select 2) > (_hoverHeight + 5)} do {
	// 		sleep 3;
	// 	};


	// };

	if (!alive _unit) exitWith {};
	//-- prepare rappel
	//'prepare rappell' remoteExec ["systemchat",0];
	[_aircraft,[0,0,0]] remoteExec ["setVelocity",_aircraft];

	{
		[_aircraft,[_x, 1]] remoteExec ["animateDoor",_aircraft];
	} foreach ['door_R','door_L','Door_L_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];



	_aircraft setVariable ["A3C_PLAYER_RAPPEL",true,true];
	//-- if a player is rappelling, freeze the chopper (maybe do it anyways)

	//-- FIX AIRCRAFT IN PLACE (~~ really only necessary until ADVNACED RAPPEL functions take over
	private _standbyHandler = _aircraft spawn {
		private _aircraft = _this;
		private _vectorDir = vectorDir _aircraft;
		while {_aircraft getVariable "A3C_PLAYER_RAPPEL"} do {
			[_aircraft,[0,0,0]] remoteExec ["setVelocity",_aircraft];
			[_aircraft,[0,0,1]] remoteExec ["setVectorUp",_aircraft];
			[_aircraft,_vectorDir] remoteExec ["setVectorDir",_aircraft];
			sleep 0.01;
		};

	};

	if (_isHeli) then {
		sleep 3; //-- HELIS are already levelled. Still wait 3s so the rappel is not too immediate
	} else {
		//-- level VTOL.
		_subBehaviour =
		[
			_aircraft,
			getPosASL _aircraft,
			_railPos,
			vectorDirVisual _aircraft,
			[getDir _aircraft] call MCSS_fnc_DegreeToVector,
			vectorUpVisual _aircraft,
			[0,0,1],
			3 //-- duration
		] spawn A3C_AI_AIRCRAFT_LOOKAT;
		waituntil {scriptDone _subBehaviour};
	};




	private _rapGroups = [];
	private _rapUnitsAll = +(_rapUnits);

	{
		if (group _x != group _unit) then { //-- unit is not in pilot group: remove from rapunits, add group to rapGroups
			_rapGroups pushBackUnique (group _x);
			_rapUnits = _rapUnits - [_x];
		};
	} foreach _rapUnits; //-- we have now seperated the rappel into _rapUnits (from player controlled squad (_unit/driver is in same group) and _rapGroups (other groups to rappel fully)




	//-- commence rappel
	//-- _rapUnits now only consists of units that are in pilots group. That means that pilot leader is a player. Dismount those first

	{
		//~~ TO DO: unify the rail between squad and HC, clean that up :S

		
		[_x,_inside,_bdg,_aircraft,_unit,_roofPoses,_bPosRail] spawn {
			params ["_u","_inside","_bdg","_v","_p","_roofPoses","_bPosRail"];

			waituntil {[_u, _v] call AR_Rappel_From_Heli_Action_Check};

			[_u, _v] call AR_Rappel_From_Heli;

			waitUntil {!(_u in _v)};

			

			[[_u], A3C_AIGetOut] remoteExec ['bis_fnc_call', _u];


			//-- rooftop landing: rail AI to closest building positions to snap them into path lod
			if (!isNil 'A3C_RAIL_INF') then { //-- exit if A3C is not running on client
				if (_inside && !(isPlayer _u)) then {
					[_u,_roofPoses,_bdg] spawn _bposRail;
					sleep 2;
				};
			};
		};
		sleep 2;

		
		if ((_foreachindex + 1) %4 == 0) then {
			waituntil {{animationstate _x in ["ar_01_idle","ar_01_aim"]} count _rapUnits < 3};
		};
	} forEach _rapUnits;

	//-- dismount other groups
	//(str [_group,_rapGroups, _rappelPos,_inside]) remoteExec ["systemchat",0];
	_rappelPos = getPosASL _aircraft;
	_rappelPos set [2, (_rappelPos select 2) - 25];
	[_group,_rapGroups, _rappelPos,_inside] call A3C_AIC_fnc_rappelActionHandler; //_rappelPos

	{
		_gp = _x;
		{
			_u = _x;
			[_u,_bdg,_inside,_roofPoses,_bPosRail] spawn {
				params ["_u","_bdg","_inside","_roofPoses","_bPosRail"];

				if (!isNil 'A3C_RAIL_INF') then { //-- exit if A3C is not running on client
					if (_inside && !(isPlayer _u)) then {
						waitUntil {!alive _u OR isNull objectParent _u};
						[_u,_roofPoses,_bdg] spawn _bposRail;
					};
				};
			};
		} foreach units _gp;
	} foreach _rapGroups;
	sleep 1;
	//'pre loop'  remoteExec ["systemchat",0];
	if (count _rapUnitsAll > 0) then {
		waituntil {{vehicle _x != _aircraft} count _rapUnitsAll > 0};

	};


	//-- wait until units have rappelled
	while {alive _unit} do {
		private _rappelComplete = true;

		{
			if (alive _x && {!isTouchingGround _x}) exitWith {
				_rappelComplete = false;

			};
		} foreach _rapUnitsAll;
	
		sleep 1;
		_Rapgps = [];
		{
			_Rapgps pushBackUnique (group _x);
		} foreach _rapUnitsAll;
		_multiples = _rapUnitsAll select {_u = _x; {_u == _x} count _rapUnitsAll > 1};
		private _tt = [_Rapgps,_multiples,_rapUnitsAll,{ alive _x && {!isTouchingGround _x} } count _rapUnitsAll];

		if (_rappelComplete) exitWith {};

	};


	_group setvariable ['A3C_RAPPELL_COMPLETED',true,true];
	_aircraft setVariable ["A3C_PLAYER_RAPPEL",false,true];


	//-- done. close doors and continue
	{
		[_aircraft,[_x, 0]] remoteExec ["animateDoor",_aircraft];
	} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];

	//-- create radio message (squad level only)
	_ch = (["Roger that, I'm off","Roger","Got It","Good luck out there","Catch you later"] call BIS_fnc_SelectRandom);
	if !(( floor random 2.9) == 2) then {

		_ch = _ch + (format [" %1", toLower (Rank _caller)]);
	};
	if (isPLayer _caller) then {
		player groupchat "We're out";
		sleep 2;
		_unit groupchat _ch;
	};

	waituntil {scriptDone _standbyHandler};

	sleep 1;
	[_aircraft,1500] remoteExec ["limitSpeed",_aircraft];



	private _nextWpPos = waypointposition [_group, currentWaypoint _group];


	if (_nextWpPos distance2D [0,0,0] > 0) then {

		while {alive _aircraft && speed _aircraft < 30} do {
			[_unit,_nextWpPos] remoteExec ["doMove",_unit];
			[_aircraft,1500] remoteExec ["limitSpeed",_aircraft];
			sleep 3;
		};
	};
};
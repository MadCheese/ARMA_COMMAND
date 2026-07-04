
//-- CONVOY PID FUNCTION
A3C_CONVOY_fncPID = {
	params ["_group","_allVehicles","_leaders","_vehicleCountAhead","_isLastVehicle"];

	


	//-- TO DO: EXIT IF GROUPLEADER IS ON FOOT
	
	_fnc_standby = {
		params ["_vic"];

		diag_log format ["%1, STANDBY 2 %2", group driver _vic, time];
		if !((driver _vic) checkAIFeature "MOVE") exitWith {};
		
		{
			[_x,"MOVE"] remoteExec ["disableAI",_x];
			[_x,"PATH"] remoteExec ["disableAI",_x];
		} foreach [_vic, driver _vic, effectiveCommander _vic];

		if (speed _vic > 1) then {
			_vel = velocity _vic;
			_dir = direction _vic;
			_speed = -1; //-- reduce speed
			_vic setVelocity [
				(_vel select 0) + (sin _dir * _speed),
				(_vel select 1) + (cos _dir * _speed),
				(_vel select 2)
			];
		};
	};

	_fnc_resume = {
		params ["_vic"];
		if ((driver _vic) checkAIFeature "MOVE") exitWith {};
		diag_log format ["%1, RESUME 2 %2", group driver _vic, time];
		{
			[_x,"MOVE"] remoteExec ["enableAI",_x];
			[_x,"PATH"] remoteExec ["enableAI",_x];
		} foreach [_vic, driver _vic, effectiveCommander _vic];
	};


	//systemChat str (_leaders select 0);
	
	_leaders params ["_leaderGroups","_convoyLeader"];

	_isSecondVehicle = (count _leaderGroups) == 1;

	if (_leaderGroups isEqualTo []) exitWith {};

	_leadByGroup = _leaderGroups select ((count _leaderGroups) - 1);

	//player sidechat format ["%1 is now following %2",groupID _group, groupID _leadByGroup];
	//player sidechat str [_group,_leaderGroups];

	private _vic = vehicle leader _group;
	[_vic] call _fnc_standby; //-- initial standby to prevent movement before leadervic has paths calculated

	//-- START CONVOY LOOP
	while {!isNull _group} do {
		//waituntil {vehicle};

		// if (leader _group in BT3) then  {
		// 	systemchat format ["BT3 TICKTIME %1", time];
		// };

		if (isNull _leadByGroup OR { {alive _x} count (units _leadByGroup) == 0}) then {
			//-- leadervehicle out of action
			systemchat format ["%1 has no leader, find new leader",groupID _group];
			_leaderGroups = _leaderGroups - [_leadByGroup];
			_leadByGroup = grpNull;
			while {!(_leaderGroups isEqualTo [])} do {
				// if (leader _group in BT3) then  {
				// 	systemchat "BT3 LOOP TICK 1";
				// };

				private _rGroup = _leaderGroups select ((count _leaderGroups) - 1);
				if (isNull _rGroup OR { {alive _x} count (units _rGroup) == 0}) then {
					//-- group no longer active >> remove
					_leaderGroups = _leaderGroups - [_rGroup];
				} else {
					//-- suitable leaderGroup
					_leadByGroup = _rGroup;
				};
				if (!isNull _leadByGroup) exitWith {
					systemchat format ["%1 is now following %2",groupID _group, groupID _leadByGroup];
				}; //-- leaderGroup was found >> exit
			};
		};

		if (isNull _leadByGroup) exitWith {
			systemchat format ["%1 found no leader, exit",groupID _group];
		};

		//-- determine vehicle to follow
		private _driversleadByGroup = (units _leadByGroup) select {private _v = objectParent _x; !isNull _v && {_x == driver _v}};
		if (_driversleadByGroup isEqualTo []) exitWith {
			systemchat format ["%1 lost it's leader. sadge", _group];
		};
		_leaderVic = vehicle ( _driversleadByGroup select ((count _driversleadByGroup)-1) ); //-- leading vehicle is last driver in group
		_followingVic = vehicle leader _group;

		private _leaderSpeed = ((speed _leaderVic) * 0.75) max 0.0001;
		private _leaderDestination = waypointPosition [_leadByGroup, currentWaypoint _leadByGroup];
		private _leaderDistanceToTravel = (getPosASL _leaderVic) distance2d _leaderDestination;
		private _relDir = _followingVic getRelDir _leaderVic;
		//private _precision = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.3);


		private _followerDestination = waypointPosition [_group, currentWaypoint _group];
		private _followerDistanceToTravel = (getPosASL _followingVic) distance2d _leaderDestination; //_followerDestination; //-- eh! might have to use this one as a reference for both
		// private _followerDistanceToTravel = (getPosASL _followingVic) distance2d _leaderDestination; //-- eh! might have to use this one as a reference for both

		private _followerHasOverTaken = _followerDistanceToTravel < _leaderDistanceToTravel; // _followDistanceToTravel < _leaderDistanceToTravel;//
		//-- IDEA: try if follower is closer to both positions?

		// if (_followerHasOverTaken && {speed _leaderVic > 5}) then { //-- note : revisit why this was a good thing to do
		// 	_abs = abs((getDir _leaderVic) - (getDir _followingVic));
		// 	if (_abs > 180) then {
		// 		_abs = 360 - _abs;
		// 	};
		// 	if (_abs > 90) then {
		// 		_followerHasOverTaken = false;
		// 	} else {
		// 		// private _referencePos = _followingVic getPos [5000,getDir _followingVic]; //-- this was not dumb at all lol
		// 		// _followerHasOverTaken = ((_followingVic distance2D _referencePos) + 20) <= (_leaderVic distance2D _referencePos);

		// 		_followerHasOverTaken = ((_followingVic distance2D _referencePos) + 20) <= _leaderDestination;
		// 	};
		// };

		private _doStandBy = false;
		private _mustCatchUp = false;


		private _leaderUnits = (units _leadByGroup) select {_x == driver vehicle _x}; //-- allowing infantry for now (confirm accuracy?)
		_leaderUnits = [_leaderUnits,[],{_followingVic distance2D _x},"ASCEND"] call BIS_fnc_sortBy;
		private _closestLeaderVehicle = vehicle (_leaderUnits select 0);
		private _closestDistance = _followingVic distance2D _closestLeaderVehicle;





		///////////////
		// diag_log format ["%1 _leaderDistanceToTravel %2", _group, _leaderDistanceToTravel];
		if (_leaderDistanceToTravel > 100) then { //_closestDistance < 50 && 

			_paths = []; //if (_isSecondVehicle) then {[]} else {[(leader _leadByGroup) getVariable ["A3C_VEHICLE_PATH",[[],0]]]};
			

			private _testUnits = [leader _leadByGroup, leader _group]; //if (_isSecondVehicle) then {[leader _leadByGroup, leader _group]} else {[leader _group]};

			{
				private _scr = [_x, _leaderDestination ] spawn A3C_ai_shared_fnc_calculatePath;
				// if (leader _group in BT3) then {
				// 	systemchat "BT3 waituntil Path";
				// };
				waitUntil{scriptDone _scr};
				// systemchat "BT3 Path Created";
				private _pathData = _x getVariable ["A3C_VEHICLE_PATH",[[],0]]; //-- #TODO add error handling?
				// if (_x in BT3 && {(_x in units _group)}) then {
				// 	_markers = _x getVariable ["A3C_VEHICLE_PATH_MARKERS",[]];
				// 	{deleteMarker _x} foreach _markers;
				// 	_markers = [];
				// 	_color = selectRandom ["ColorYellow","ColorGreen","ColorRed","ColorBlue"];
				// 	{
				// 		_marker = [format ["M_%1",_foreachIndex],_x,"ICON","mil_dot",[1,1],"",_color] call MCSS_fnc_createMarker;
				// 		_markers set [count _markers, _marker];
				// 	} foreach (_pathData select 0);
				// 	_x setVariable ['A3C_VEHICLE_PATH_MARKERS',_markers];
				// };
				_paths set [count _paths, _pathData];
				diag_log format ["%1 test unit %2, %3", _x, _group, _leaderDestination];
			} foreach _testUnits;

			// hintsilent format ["Paths: %1",count _paths];

			// if (_isSecondVehicle) then {
			// 	hintsilent str [(_paths select 1) select 1, (_paths select 0) select 1];
			// };



			// systemchat str [_paths];
			_pathDistFollower = (_paths select 1) select 1;
			_pathDistLeader = (_paths select 0) select 1;
			if (_pathDistFollower <  _pathDistLeader) then {
				diag_log format ["%1 _pathDistFollower: %2 | %3 _pathDistLeader %4 | _leaderDistanceToTravel: %5", _group, _pathDistFollower , _leadByGroup,  _pathDistLeader, _leaderDistanceToTravel];
				// if (vehicle leader _group == BT3) then {
				// 	player setpos _leaderDestination;
				// };
				_doStandBy = true;

				// if (leader _group in BT3) then {
				// 	systemchat "BT3 standby";
				// };
				// diag_log format ["%1,  STANDBY DETERMINED time: %2", _group, time];
			};

		} else {
			_markers = (leader _leadByGroup) getVariable ["A3C_VEHICLE_PATH_MARKERS",[]];
			{deleteMarker _x} foreach _markers;
		};

		///////////////








		
		// if (_relDir > 45 OR {_relDir < 320}) then {
		// 	//-- relDir is off - forbid following if following vic is closer to destination  ||| Not sure about that. It's true but is it otherwise not relevant if follwer is closer to dest??
		// 	if (_followerHasOverTaken && (_leaderVic distance2D _leaderDestination > 30)) then {
		// 		_doStandBy = true;
		// 		if ((vehicle leader _group) == BT1) then {
		// 			systemchat "break BT1-1";
		// 			hint (format
		// 			[
		// 				"
		// 					_followerHasOverTaken\n%1 \n 
		// 					_followerDistanceToTravel\n%2 \n 
		// 					_leaderDistanceToTravel\n%3 \n   
		// 				", _followerHasOverTaken , _followerDistanceToTravel , _leaderDistanceToTravel]);
		// 		};
		// 		if ((vehicle leader _group) == BT2) then {systemchat "break BT2-1"};
		// 		if ((vehicle leader _group) == BT3) then {systemchat "break BT3-1"};
		// 		//systemchat format ["%1 , leadergroup dist to wp: %2 V1 OVT",groupID _group, (_leaderVic distance2D _leaderDestination > 30)];
		// 	};
		// } else {
		// 	//-- relDir is on point: following only forbidden if .... ? >> following vic is closer to any leadgroup vehicles than.. 50m?

		// 	//-- find shortest distance to any vehicle of leaderGroup. if that distance is below 30, limitSpeed to 0.01. if that distance is > 100 and that vehicle is closer to dest, allow free speed
		// 	//-- >> make _mustCatchUp Variable



			
		// 	if (_closestDistance < 30 ) then { 
		// 		_doStandBy = true;
		// 		//systemchat format ["%1 , leadergroup dist to wp: %2 V2",groupID _group, (_leaderVic distance2D _leaderDestination > 30)];
		// 		if ((vehicle leader _group) == BT1)  then {systemchat "break BT2-2"};
		// 		if ((vehicle leader _group) == BT2) then {systemchat "break BT2-2"};
		// 		if ((vehicle leader _group) == BT3) then {systemchat "break BT3-2"};
		// 	} else {
		// 		if (_closestDistance > 100 ) then {
		// 			if !(_followerHasOverTaken) then {
		// 				_mustCatchUp = true;
		// 			};
		// 		};
		// 	};
		
		// };



		





		//-- exit conditions
		_doExit = false;

		if (currentWaypoint _group >= count waypoints _group) then {
			_doExit = true;
			// systemchat format ["%1 ended follow reason 1",_group];
		};


		_finalConvoyLeaderWaypoint = (waypoints _leadByGroup) select ((count (waypoints _leadByGroup)) - 1 );
		//-- exit if leadervic has reached waypoint or has no destination. this is flawed because we sync the waypoints
		// if ({waypointposition [_leadByGroup, currentWaypoint _leadByGroup] distance2d _x < 5} count [[0,0,0], getPosASL _leaderVic] > 0) then { //
		if ({waypointposition _finalConvoyLeaderWaypoint distance2d _x < 5} count [[0,0,0], getPosASL _leaderVic] > 0) then { //
			// systemchat format ["%1 ended follow reason 2",_group];
			_doExit = true;
		};

		_maxSpeed = if (_doExit) then {
				1000
		} else {
			if (_doStandBy) then {
				diag_log format ["%1 STANDBY 0.0001", _group];
				0.0001
			} else {
				if (_mustCatchUp) then {
					1000
				} else {
					// if (_leaderSpeed < 10 && {_closestDistance < 30 && {(_leaderVic distance2D _leaderDestination > 30)}}) then { // 
					// 	if ((vehicle leader _group) == BT1) then {systemchat "break BT1-3"};
					// 	if ((vehicle leader _group) == BT2) then {systemchat "break BT2-3"};
					// 	if ((vehicle leader _group) == BT3) then {systemchat "break BT3-3"};
					// 	0.0001
						
					// } else {
						if (_closestDistance < 50 && _leaderDistanceToTravel > 100) then {
							// systemchat format ["%1 _leaderSpeed",_group];
							if (_leaderSpeed == 0.0001) then {
								diag_log format ["%1 LEADERSPEED 0.0001", _group];
								// if (leader _group in BT3) then  {
								// 	systemchat "BT3 leader speed";
								// };
							};
							_leaderSpeed
						} else {
							1000
						};
						
					// };
					
				}	
			}
		};
		_group setVariable 
		[
			"A3C_UI_Group_Speed",
			_maxSpeed,
			true
		];
		if (_maxSpeed == 0.0001) then {
			// systemchat format ["%1 HALT, %2",_group, time];
			_group setVariable 
			[
				"A3C_UI_Group_Status",
				[
					format ["WAITING FOR %1",groupID _leadByGroup],
					[1,0.25,0.3,1]
				],
				true
			];
			_vic = vehicle leader _group;
			[_vic] call _fnc_standby;

			// systemchat format ["%1 breaking hard",groupID _group ];
			

		} else {
			if (round _maxSpeed == round _leaderSpeed) then {
				/*
				if (!isNull gDude && {driver _followingVic == Gdude}) then {
					systemchat str time;
				};
				*/
				_group setVariable 
				[
					"A3C_UI_Group_Status",
					[
						format ["SPEED LIMIT: %1",round _leaderSpeed],
						A3C_UI_COLOR_YELLOW
					],
					true
				];
			} else {
				/*
				if (!isNull gDude && {driver _followingVic == Gdude}) then {
					player groupchat str time;
				};
				*/
				_d = _group getVariable ["A3C_UI_Group_Status",["",[]]];
				if ({_x in (_d select 0)} count ["WAITING","LIMIT"] > 0) then {
					_group setVariable ["A3C_UI_Group_Status",["",[]],true];
				};
			};
			
		};

		

		/*
		if (!isNull gDude && {driver _followingVic == Gdude}) then {
			_hint  = composeText 
			[
				format ["relDir: %1",_relDir], 
				lineBreak, 
				format ["in Range: %1",_relDir < 45 OR {_relDir > 320}],
				lineBreak,
				format ["Closest Vic: %1m",round _closestDistance],
				lineBreak,  
				
				format ["doExit: %1",_doExit],
				lineBreak, 
				format ["doStandBy: %1",_doStandBy],
				lineBreak, 
				format ["maxSpeed: %1",_maxSpeed],
				lineBreak, 
				format ["leading vehicle speed: %1",round (speed _leaderVic)]

			];
			hintSilent _hint; //!!!!!!!!!!!!!!!!!!!!!!!!!!
		};
		*/




		
		if (_doExit) exitWith {
			
		};

		diag_log format ["%1 _maxSpeed %2", _group, _maxSpeed];
			
		{
			_vic = _x;
			[_x,_maxSpeed] remoteExec ["limitSpeed",_x];

			if (_maxSpeed != 1000) then {
				//-- vehicle is not allowed to move freely
				
				if (_maxSpeed == 0.0001) then {
					//-- vehicle needs to stop
					
					if (!(_vic in A3C_CONVOY_SLOWDOWN_VICS) && {speed _vic > 10}) then {
						//-- dirty method: idea is to slow down vehicle, but it halts abruptly in current state. therefore currently only use when forcing halt :S
						// [_vic] spawn {
						// 	params ["_vic"];
						// 	A3C_CONVOY_SLOWDOWN_VICS set [count A3C_CONVOY_SLOWDOWN_VICS,_vic];
						// 	//systemchat str ["slowdown",time];
						// 	while {speed _vic > 10} do {
						// 		// if ((leader (group driver _vic)) in BT3) then  {
						// 		// 	systemchat "BT3 LOOP TICK 3";
						// 		// };
						// 		[_vic, (VelocityModelSpace _vic) vectorAdd [0,-5,-0]] remoteExec ["setVelocityModelSpace",_vic];
						// 	};
						// 	A3C_CONVOY_SLOWDOWN_VICS = A3C_CONVOY_SLOWDOWN_VICS - [_vic];

						// };
						while {speed _vic > 5} do {
							_vic setVelocityModelSpace ((velocityModelSpace _vic) vectorAdd [0,-2,0]);
							sleep 0.2;
						};
					};

					

				} else {
					//-- vehicle can move
					[_vic] call _fnc_resume;
					
					// systemchat format ["%1 re-enable move",groupID _group ];
				};
			} else {
				[_vic] call _fnc_resume;

			};
			
			
			

		} foreach _allVehicles; //10} foreach _allVehicles;


		
		if (_isLastVehicle) then {
			//-- limit leading vehicle speed if distance gets too big
			if (_convoyLeader distance2D _followingVic > (_vehicleCountAhead * 75)) then {
				[_convoyLeader,20] remoteExec ["limitSpeed",_convoyLeader];
				// [_convoyLeader,"MOVE"] remoteExec ["disableAI",_convoyLeader];
				(group driver _convoyLeader) setVariable ["A3C_UI_Group_Status",["REGROUP",[1,0,0,1]],true];
			} else {
				[_convoyLeader,"MOVE"] remoteExec ["enableAI",_convoyLeader];
				[_convoyLeader,1000] remoteExec ["limitSpeed",_convoyLeader];
				(group driver _convoyLeader) setVariable ["A3C_UI_Group_Status",["",[]],true];
			};
		};
		
		


		

		//if ({_u = _x; { vehicle _u distance _x < 50} count _allVehicles == 0 } count (units _leadByGroup) == 0) exitWith {};
		sleep 1;
	};

	// if (leader _this in BT3) then  {
	// 	systemchat "BT3 LOOP FINISHED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
	// };
	//-- CONVOY LOOP FINISHED

	if (!isNull _group) then {
		//-- manage A3C_GROUP_CONVOYS
		{
			private _groupArray = _x;
			if (_group in _groupArray) then {
				_newArray = _groupArray - [_group];
				if (count _newArray == 1) then {
					A3C_GROUP_CONVOYS = A3C_GROUP_CONVOYS - [_groupArray];
				} else {
					A3C_GROUP_CONVOYS set [_foreachIndex, _newArray];
				};
			};
		} foreach A3C_GROUP_CONVOYS;
		publicVariable "A3C_GROUP_CONVOYS";

		//-- reset group data
		{
			_vic = _x;
			[_x,1000] remoteExec ["limitSpeed",_x];
			[_vic] call _fnc_resume;
		} foreach _allVehicles;
		_group setVariable ["A3C_UI_Group_Status",["FOLLOW COMPLETE",[1,1,1,1]],true];
		sleep 3;
		{
			_x setVariable ["A3C_UI_Group_Status",nil]; //["",[]],true];
		} foreach [_group,_leadByGroup]; //-- executing on both groups to reset "REGROUP" status of convoy-leader

		{
			[_x,"AUTOCOMBAT"] remoteExec ["enableAI",_x];
		} foreach (units _group);
	};
};	



A3C_ai_highCommand_fnc_convoyMultigroup = {
	params ["_inputUnits","_refPos"];

	private _wpPositions =  [_refPos,_inputUnits,count _inputUnits, (_refPos getDir (leader (_inputUnits select 0))) + 180,20 ] call A3C_fnc_generateWpWedgePositions;


	private _lastUnit = grpNull; 
	private _convoyArrayIndex = -1;
	private _convoyArraySorted = -1;

	private _infantryOnly = true;
	{
		if ({!isNull objectParent _x && {_x == driver (objectParent _x)}} count (units _x) > 0 ) exitWith { //
			_infantryOnly = false;
		};
	} foreach _inputUnits;
	private _leaderWP = [];
	private _followerWps = [];
	if (_infantryOnly) exitWith {
		{
			private _gp = _x;
			private _wpPos = _wpPositions select _foreachIndex;
			private _wpParams = [_gp,_wpPos];
			
			_wp = _wpParams call A3C_ai_highCommand_fnc_addWaypoint;
			if (_foreachIndex == 0) then {
				_leaderWP = _wp;
			} else {
				_followerWps set [count _followerWps,_wp];
			};
		} foreach _inputUnits;
	};
	if !(_leaderWP isEqualTo []) then {
		// systemchat str [_leaderWP,_followerWps];
		_leaderWP synchronizeWaypoint _followerWps;
	};

	_inputUnits = _inputUnits select {
		private _lVIc = objectParent (leader _x); !isNull _lVIc && {driver _lVIc in (units _x)}
	};


	_convoyGoupsActive = _inputUnits select {_gp = _x; {_gp in _x} count A3C_GROUP_CONVOYS > 0};
	private _exit = false;
	if !(_convoyGoupsActive isEqualTo []) then {
		private _refGroup = _convoyGoupsActive select 0;
		{
			private _testedGroup = _x;
			{
				if (_testedGroup in _x && {!(_refGroup in _x)}) exitWith {
					_exit = true;
				};
			} foreach A3C_GROUP_CONVOYS;
			if (_exit) exitWith {};
		} foreach (_convoyGoupsActive - [_refGroup]);
		if !(_exit) then { //-- it's convenient to fetch _lastUnit here but we can skip if exiting
			{
				if ((_convoyGoupsActive select 0) in _x) exitWith {
					_lastUnit = _x select ((count _x) - 1);
					_convoyArrayIndex = _foreachIndex;
					_convoyArraySorted = _x;
				};
			} foreach A3C_GROUP_CONVOYS;
		};
	};
	if (_exit) exitWith {
		systemchat "A3C: CAN NOT ADD WAYPOINTS TO MULTIPLE CONVOYS";
	};
	
	_convoyGoupsActive =
	[
		_convoyGoupsActive,
		[],
		{
			[_x,_convoyArraySorted] call MCSS_fnc_GetArrayIndex
		},
		"ASCEND"
	] call BIS_fnc_sortBy;

	_freeGroups = _inputUnits - _convoyGoupsActive;

	/*
	////////////////////////////////////////////////////////////////////////////////--
	//////////-- EXPERIMENTAL: CALCULATE PATHLENGTH INSTEAD OF USING DISTANCE. Purpose: prevent bad wp-distribution resulting in crashes
	hint "A3C: Calculating Convoy";
	{
		private _fG = _x;
		private _wpArray = [_fG, currentWaypoint _fG];
		private _root = if (waypointType _wpArray == "") then {getPosASL (vehicle leader _fG)} else {waypointPosition _wpArray};

		_fG setVariable ["A3C_CONVOY_CALCULATING",nil];

		//systemchat str _fG;


		A3C_CONVOY_TOTALPATHLENGTH = -1; //-- create dirty globalvar :)
		(calculatePath ["wheeled_APC","careless",_root,_refPos]) addEventHandler //currently using MAN, belived to use roads in careless. man wheeled_APC works inconsistently, "car" gets stuck because of obstructing vehicles
		[
			"PathCalculated",
			{
				params ["_unit", "_path"];
				//systemchat 'fired';
				if (_path isEqualTo []) then {
					systemchat "NO PATH CONV";
				};
				private _totalPathLength = 0;
				private _lastPosition = position _unit;
				{
					private _pos = _x;
					private _lengthSeg = _lastPosition distance2D _pos;
					_totalPathLength = _totalPathLength + _lengthSeg;
					_lastPosition = _pos;
				} forEach _path;
				A3C_CONVOY_TOTALPATHLENGTH = _totalPathLength;
			}
		];
		waitUntil { A3C_CONVOY_TOTALPATHLENGTH != -1 };
		_fG setVariable ["A3C_CONVOY_CALCULATING",A3C_CONVOY_TOTALPATHLENGTH];
		//systemchat 'moving on calc';
	} foreach _freeGroups;
	A3C_CONVOY_TOTALPATHLENGTH = nil; //-- remove dirty globalvar :)
	hintSilent "";
	//////////--
	////////////////////////////////////////////////////////////////////////////////--
	*/



	_freeGroups =
	[
		_freeGroups,
		[],
		{
			private _wpArray = [_x, currentWaypoint _x];
			private _root = if (waypointType _wpArray == "") then {getPosASL (vehicle leader _x)} else {waypointPosition _wpArray};
			_refPos distance2D _root //_refPos
			//_x getVariable ["A3C_CONVOY_CALCULATING",0]
		},
		"ASCEND"
	] call BIS_fnc_sortBy;
	
	
	
	
	//systemchat str _freeGroups;
	_leaderWP = [];
	_followerWps = [];
	{
		private _gp = _x;
		private _wpPos = _wpPositions select _foreachIndex;
		private _wpParams = [_gp,_wpPos];
		_wp = _wpParams call A3C_ai_highCommand_fnc_addWaypoint;
		if (_foreachIndex == 0) then {
			_leaderWP = _wp;
		} else {
			_followerWps set [count _followerWps,_wp];
		};
	} foreach (_convoyGoupsActive + _freeGroups);
	if !(_leaderWP isEqualTo []) then {
		// systemchat str [_leaderWP,_followerWps];
		// _leaderWP synchronizeWaypoint _followerWps;
		// {
		// 	_testedFWP = _x;

		// 	_testedFwps = _followerWps select {_x select 0 != _testedFWP select 0};
		// 	//_testedFWP synchronizeWaypoint _testedFwps;
		// 	systemchat str [_testedFwp,_testedFwps];
		// 	// {
		// 	// 	// _testedFWP synchronizeWaypoint _testedFwps;
		// 	// 	systemchat str [_testedFwp,_testedFwps];
		// 	// } foreach _testedFwps;
		// } foreach _followerWps;
		private _wps = ([_leaderWP] + _followerWps); // #TODO - replace the leaderWP setup if this works
		{
			if (_foreachIndex > 0 && (_foreachIndex < ((count _wps) - 1 ))) then {
				_x synchronizeWaypoint [_wps select (_foreachIndex - 1), _wps select (_foreachIndex + 1)];
			};
		} foreach _wps;
	};

	private _doConvoyBehaviour = count _freeGroups > 0 && {{isNull objectParent (leader _x)} count _freeGroups == 0}; 

	if (_doConvoyBehaviour) then {

		if (isNull _lastUnit) then {
			A3C_GROUP_CONVOYS pushBack _freeGroups;
		} else {
			private _convoyGroupArray = A3C_GROUP_CONVOYS select _convoyArrayIndex;
			_convoyGroupArray = _convoyGroupArray + _freeGroups;
			A3C_GROUP_CONVOYS set [_convoyArrayIndex,_convoyGroupArray];	
		};

		publicVariable "A3C_GROUP_CONVOYS";

		//[_freeGroups,_lastUnit] spawn { //~~ why is this step necessary? loop is spawned after. 
		//	params ["_freeGroups","_lastUnit"];

			private _addingToConvoy = !isNull _lastUnit;

			

			//-- ORGANIZE AND INITIATE CONVOY PID

			private _convoyLeader = objNull;
			private _allVehicleCount = 0;
			private _leaderGroups = [];
			
			{
				private _group = _x;
				private _leaderVic = vehicle leader _group;

				_group setFormation "COLUMN";

				{
					[_x,"AUTOCOMBAT"] remoteExec ["disableAI",_x];
					[_x,"SAFE"] remoteExec ["setBehaviour",_x];
					//_x setBehaviour _pidBehaviour;
				} foreach (units _group);
				_refIndex = _forEachIndex - 1;

				_leadByGroup = if (_refIndex >= 0) then {_freeGroups select _refIndex} else {_lastUnit}; //~~ dirty leftover. find clean way to work with leadbygroup
				

				//~~ TO DO: FIND CLEAN METHOD FOR _addingToConvoy functionality

				if (_foreachIndex > 0 OR {_addingToConvoy && {_leadByGroup == _lastUnit}}) then {
					_isLastVehicle = _foreachIndex == (count _freeGroups) - 1;
					private _allVehicles = [];
					{
						private _v = vehicle _x;
						if (!isNull objectParent _x && {_x == driver _v}) then {
							//_allVehicles pushBackUnique _v;
							if !(_v in _allVehicles) then {
								_allVehicles pushBackUnique _v;
								_allVehicleCount = _allVehicleCount + 1;
								
								//~~aiai
								/*
								//-- what was this for?
								//_v disableAI "MOVE";
								[_v,(speed vehicle leader _leadByGroup)] remoteExec ["limitSpeed",_v]; 

								if (speed _v > (speed vehicle leader _leadByGroup) ) then {
									[_v, (VelocityModelSpace _v) vectorAdd [0,-5,-0]] remoteExec ["setVelocityModelSpace",_v];
								};
								*/
							};
						};
					} foreach (units _x);
					//player commandchat str _leaderGroups;
					[
						[
							_group,
							_allVehicles,
							[+(_leaderGroups),_convoyLeader],
							_allVehicleCount,
							_isLastVehicle
						],
						A3C_CONVOY_fncPID
					] remoteExec ["bis_fnc_spawn", leader _group]; 
				} else {
					_convoyLeader = vehicle leader _group;
					_group setVariable ["A3C_UI_Group_Status",["STARTING ENGINE",A3C_UI_COLOR_RED],true];
					//private _allVehicles = [];
					{
						private _v = vehicle _x;
						if (!isNull objectParent _x && {_x == driver _v}) then {
								_allVehicleCount = _allVehicleCount + 1;
						};
					} foreach (units _x);
					_group spawn {
						waituntil {
							// if (leader _this in BT3) then  {
							// 	systemchat "BT3 LOOP TICK 2";
							// };
							_l = vehicle leader _this; //-- better to keep fetching leading vic, just in case unit dismounts 
							_d = _this getVariable ["A3C_UI_Group_Status",["",[]]];
							_d select 0 != "STARTING ENGINE" OR {speed _l > 1}
						};
						_this setVariable ["A3C_UI_Group_Status",["",[]],true];
					};
				};
				_leaderGroups set [count _leaderGroups,_group]; //-- add group to leadingVic array
				//systemchat str _leaderGroups;
			} foreach _freeGroups;
		//};
	};						
};

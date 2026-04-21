A3C_FNCS_CONVOY_MULTIGROUP = {
	params ["_inputUnits","_refPos"];

	private _wpPositions = [_refPos,_inputUnits,count _inputUnits, (_refPos getDir (leader (_inputUnits select 0))) + 180,20 ] call A3C_fnc_generateWpWedgePositions;
	//systemchat str (_inputUnits);

	private _lastUnit = grpNull;
	private _convoyArrayIndex = -1;
	private _convoyArraySorted = -1;

	private _infantryOnly = true;

	{
		if ({!isNull objectParent _x && {_x == driver (objectParent _x)}} count (units _x) > 0) exitWith {
			_infantryOnly = false;
		};
	} forEach _inputUnits;

	if (_infantryOnly) exitWith {
		{
			private _gp = _x;
			private _wpPos = _wpPositions select _forEachIndex;
			private _wpParams = [_gp,_wpPos];
			_wpParams call A3C_HC_ADD_WP;
		} forEach _inputUnits;
	};

	_inputUnits = _inputUnits select {
		private _lVic = objectParent (leader _x);
		!isNull _lVic && {driver _lVic in (units _x)}
	};

	private _isAirOnly = true;

	{
		private _lVic = objectParent (leader _x);
		if !(_lVic isKindOf "AIR") exitWith {
			_isAirOnly = false;
		};
	} forEach _inputUnits;

	private _convoyGroupsActive = _inputUnits select {
		private _gp = _x;
		{_gp in _x} count A3C_GROUP_CONVOYS > 0
	};

	private _exit = false;
	if !(_convoyGroupsActive isEqualTo []) then {
		private _refGroup = _convoyGroupsActive select 0;
		{
			private _testedGroup = _x;
			{
				if (_testedGroup in _x && {!(_refGroup in _x)}) exitWith {
					_exit = true;
				};
			} forEach A3C_GROUP_CONVOYS;
			if (_exit) exitWith {};
		} forEach (_convoyGroupsActive - [_refGroup]);

		if !(_exit) then {
			{
				if ((_convoyGroupsActive select 0) in _x) exitWith {
					_lastUnit = _x select ((count _x) - 1);
					_convoyArrayIndex = _forEachIndex;
					_convoyArraySorted = _x;
				};
			} forEach A3C_GROUP_CONVOYS;
		};
	};

	if (_exit) exitWith {
		systemchat "A3C: CAN NOT ADD WAYPOINTS TO MULTIPLE CONVOYS";
	};

	_convoyGroupsActive =
	[
		_convoyGroupsActive,
		[],
		{
			[_x,_convoyArraySorted] call MCSS_fnc_GetArrayIndex
		},
		"ASCEND"
	] call BIS_fnc_sortBy;

	private _freeGroups = _inputUnits - _convoyGroupsActive;
	_freeGroups =
	[
		_freeGroups,
		[],
		{
			private _wpArray = [_x, currentWaypoint _x];
			private _root = if (waypointType _wpArray == "") then {
				getPosASL (vehicle leader _x)
			} else {
				waypointPosition _wpArray
			};
			_refPos distance2D _root
		},
		"ASCEND"
	] call BIS_fnc_sortBy;

	{
		private _gp = _x;
		private _wpPos = _wpPositions select _forEachIndex;
		private _wpParams = [_gp,_wpPos];
		_wpParams call A3C_HC_ADD_WP;
	} forEach (_convoyGroupsActive + _freeGroups);

	if (_isAirOnly) exitWith {
		[] spawn {
			hint "All selected group leading vehicles are aircraft - aborting convoy PID";
			sleep 3;
			hintSilent "";
		};
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

		private _managedGroups = if (isNull _lastUnit) then {
			+_freeGroups
		} else {
			+(A3C_GROUP_CONVOYS select _convoyArrayIndex)
		};

		[_freeGroups,_lastUnit,_managedGroups] spawn {
			params ["_freeGroups","_lastUnit","_managedGroups"];
			private _addingToConvoy = !isNull _lastUnit;

			private _convoyGetDesiredBehaviour = {
				params ["_group"];

				private _leaderVehicle = vehicle leader _group;
				if (isNull _leaderVehicle) exitWith {"SAFE"};

				if (!([_leaderVehicle] call A3C_fnc_isArmedVehicle)) exitWith {"CARELESS"};
				"SAFE"
			};

			private _convoyApplyBehaviour = {
				params ["_group"];

				private _desiredBehaviour = [_group] call _convoyGetDesiredBehaviour;
				private _leader = leader _group;
				private _isManaged = _group getVariable ["A3C_Convoy_BehaviourManaged", false];

				if (!_isManaged) then {
					if (_desiredBehaviour == "SAFE") then {
						_group setVariable ["A3C_Convoy_OriginalBehaviour", behaviour _leader, true];
					} else {
						_group setVariable ["A3C_Convoy_OriginalBehaviour", "", true];
					};
				};

				_group setVariable ["A3C_Convoy_BehaviourManaged", true, true];
				_group setVariable ["A3C_Convoy_ForcedBehaviour", _desiredBehaviour, true];

				{
					[_x,"AUTOCOMBAT"] remoteExec ["disableAI", _x];
					[_x,_desiredBehaviour] remoteExec ["setBehaviourStrong", _x];
				} forEach (units _group);
			};

			

			

			{
				[_x] call _convoyApplyBehaviour;
			} forEach _managedGroups;

			private _pidFnc = {
				params ["_group","_allVehicles","_leaders","_vehicleCountAhead","_isLastVehicle"];

				private _groupStillInAnyConvoy = {
					params ["_group"];
					private _found = false;
					{
						if (_group in _x) exitWith {
							_found = true;
						};
					} forEach A3C_GROUP_CONVOYS;
					_found
				};

				private _convoyRestoreBehaviour = {
					params ["_group"];

					private _isManaged = _group getVariable ["A3C_Convoy_BehaviourManaged", false];
					if (!_isManaged) exitWith {};

					private _forcedBehaviour = _group getVariable ["A3C_Convoy_ForcedBehaviour", ""];
					private _originalBehaviour = _group getVariable ["A3C_Convoy_OriginalBehaviour", ""];
					private _currentBehaviour = behaviour (leader _group);

					{
						[_x,"AUTOCOMBAT"] remoteExec ["enableAI", _x];
					} forEach (units _group);

					if (_forcedBehaviour == "CARELESS") exitWith {
						_group setVariable ["A3C_Convoy_BehaviourManaged", nil, true];
						_group setVariable ["A3C_Convoy_ForcedBehaviour", nil, true];
						_group setVariable ["A3C_Convoy_OriginalBehaviour", nil, true];
					};

					if (_originalBehaviour != "" && {_currentBehaviour == _forcedBehaviour}) then {
						{
							[_x,_originalBehaviour] remoteExec ["setBehaviourStrong", _x];
						} forEach (units _group);
					};

					_group setVariable ["A3C_Convoy_BehaviourManaged", nil, true];
					_group setVariable ["A3C_Convoy_ForcedBehaviour", nil, true];
					_group setVariable ["A3C_Convoy_OriginalBehaviour", nil, true];
				};

				_leaders params ["_leadByGroup","_convoyLeader"];

				private _stopSpeed = 0.001;

				private _abilityFnc = {
					params ["_group","_commandString"];
					private _drivers = (units _group) select {
						private _op = objectParent _x;
						!isNull _op && {_x == driver _op}
					};
					{
						private _u = _x;
						{
							[_u,_x] remoteExec [_commandString,_u];
						} forEach ["AUTOCOMBAT","MOVE","PATH"];
					} forEach _drivers;
				};

				private _aliveFnc = {
					params ["_group"];
					private _return = false;
					{
						if (alive _x) exitWith {
							_return = true;
						};
					} forEach (units _group);
					_return
				};

				while {[_group] call _aliveFnc} do {

					if (isNull _leadByGroup) exitWith {};

					if ({alive _x} count (units _leadByGroup) == 0) exitWith {
						{
							private _convoySubArray = _x;
							private _indexMain = _forEachIndex;
							if (_group in _convoySubArray) exitWith {
								{
									if (_x == _leadByGroup) exitWith {
										private _newIndex = _forEachIndex - 1;
										if (_newIndex < 0) then {
											_leadByGroup = _group;
										} else {
											_leadByGroup = _convoySubArray select _newIndex;
										};
										_convoySubArray = _convoySubArray - [_x];
										A3C_GROUP_CONVOYS set [_indexMain, _convoySubArray];
									};
									if (_x == _group) exitWith {
										private _newIndex = _forEachIndex - 1;
										if (_newIndex < 0) then {
											_leadByGroup = _group;
										} else {
											_leadByGroup = _convoySubArray select _newIndex;
										};
									};
								} forEach _convoySubArray;
							};
						} forEach A3C_GROUP_CONVOYS;
					};

					private _leaderVic = vehicle leader _leadByGroup;
					private _followingVic = vehicle leader _group;
					private _leaderSpeed = ((speed _leaderVic) * 0.75) max _stopSpeed;

					private _precision = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.3);
					private _leaderDestination = waypointPosition [_leadByGroup, currentWaypoint _leadByGroup];
					private _leaderDistanceToTravel = (getPosASL _leaderVic) distance2d _leaderDestination;

					private _relDir = _followingVic getRelDir _leaderVic;

					private _followerHasOverTaken = (_followingVic distance2D _leaderDestination) < _leaderDistanceToTravel;

					if (_followerHasOverTaken && {speed _leaderVic > 5}) then {
						private _abs = abs((getDir _leaderVic) - (getDir _followingVic));
						if (_abs > 180) then {
							_abs = 360 - _abs;
						};
						if (_abs > 90) then {
							_followerHasOverTaken = false;
						} else {
							private _referencePos = _followingVic getPos [5000,getDir _followingVic];
							_followerHasOverTaken = ((_followingVic distance2D _referencePos) + 20) <= (_leaderVic distance2D _referencePos);
						};
					};

					private _doStandBy = false;
					private _mustCatchUp = false;

					private _leaderUnits = (units _leadByGroup) select {_x == driver vehicle _x};
					_leaderUnits = [_leaderUnits,[],{_followingVic distance2D _x},"ASCEND"] call BIS_fnc_sortBy;
					private _closestLeaderVehicle = vehicle (_leaderUnits select 0);
					private _closestDistance = _followingVic distance2D _closestLeaderVehicle;

					if (_relDir > 45 OR {_relDir < 320}) then {
						if (_followerHasOverTaken) then {
							_doStandBy = true;
						};
					} else {
						if (_closestDistance < 30) then {
							_doStandBy = true;
						} else {
							if (_closestDistance > 100) then {
								if !(_followerHasOverTaken) then {
									_mustCatchUp = true;
								};
							};
						};
					};

					private _doExit = false;

					if (_group == _leadByGroup) then {
						_doExit = true;
					};

					if (currentWaypoint _group >= count waypoints _group) then {
						_doExit = true;
					};

					if ({waypointposition [_leadByGroup, currentWaypoint _leadByGroup] distance2d _x < 5} count [[0,0,0], getPosASL _leaderVic] > 0) then {
						_doExit = true;
					};

					private _maxSpeed = if (_doExit) then {
						1000
					} else {
						if (_doStandBy) then {
							_stopSpeed
						} else {
							if (_mustCatchUp) then {
								1000
							} else {
								if (_leaderSpeed < 10 && {_closestDistance < 30}) then {
									_stopSpeed
								} else {
									if (_closestDistance < 50) then {
										_leaderSpeed
									} else {
										1000
									};
								};
							};
						}
					};

					if (_maxSpeed == _stopSpeed) then {
						_group setVariable
						[
							"A3C_UI_Group_Status",
							[
								format ["WAITING FOR %1",groupID _leadByGroup],
								[1,0.25,0.3,1]
							],
							true
						];
						[_group, "disableAI"] call _abilityFnc;
					} else {
						[_group, "enableAI"] call _abilityFnc;
						if (round _maxSpeed == round _leaderSpeed) then {
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
							private _d = _group getVariable ["A3C_UI_Group_Status",["",[]]];
							if ({_x in (_d select 0)} count ["WAITING","LIMIT"] > 0) then {
								_group setVariable ["A3C_UI_Group_Status",["",[]],true];
							};
						};
					};

					if (_doExit) exitWith {
						[_group, "enableAI"] call _abilityFnc;
						_group setVariable ["A3C_UI_Group_Status",["FOLLOW COMPLETE",[1,1,1,1]],true];
						sleep 3;
					};

					{
						private _vic = _x;
						[_x,_maxSpeed] remoteExec ["limitSpeed",_x];

						if (_maxSpeed == _stopSpeed) then {
							if (!(_vic in A3C_CONVOY_SLOWDOWN_VICS) && {speed _vic > 10}) then {
								[_vic] spawn {
									params ["_vic"];
									A3C_CONVOY_SLOWDOWN_VICS set [count A3C_CONVOY_SLOWDOWN_VICS,_vic];

									while {speed _vic > 10} do {
										private _vlm = velocityModelSpace _vic;
										private _frontalSpeed = ((_vlm select 1) - 1) max 0;
										_vlm set [1, _frontalSpeed];
										[_vic, _vlm] remoteExec ["setVelocityModelSpace",_vic];
										sleep 0.05;
									};
									A3C_CONVOY_SLOWDOWN_VICS = A3C_CONVOY_SLOWDOWN_VICS - [_vic];
								};
							};
						};
					} forEach _allVehicles;

					if (_maxSpeed == _stopSpeed) then {
						[_group, "disableAI"] call _abilityFnc;
					} else {
						[_group, "enableAI"] call _abilityFnc;
					};

					if (_isLastVehicle) then {
						if (_convoyLeader distance2D _followingVic > (_vehicleCountAhead * 75)) then {
							[_convoyLeader,20] remoteExec ["limitSpeed",_convoyLeader];
							(group driver _convoyLeader) setVariable ["A3C_UI_Group_Status",["REGROUP",[1,0,0,1]],true];
						} else {
							[_convoyLeader,1000] remoteExec ["limitSpeed",_convoyLeader];
							(group driver _convoyLeader) setVariable ["A3C_UI_Group_Status",["",[]],true];
						};
					};

					sleep 1;
				};

				private _checkGroups = if (_leadByGroup == _group) then {[_group]} else {[_leadByGroup,_group]};

				if ({alive _x} count (units _group) == 0) then {
					_checkGroups = [_group];
				};

				if (_leadByGroup == _group) then {
					// diag_log format ["%1 is now the new convoy leader",_group];
				} else {
					{
						private _gp = _x;

						{
							private _convoyIndex = _forEachIndex;
							private _groupArray = _x;
							if (_gp in _groupArray) exitWith {
								private _newArray = _groupArray - [_gp];
								if (count _newArray <= 1) then {
									A3C_GROUP_CONVOYS = A3C_GROUP_CONVOYS - [_groupArray];
								} else {
									A3C_GROUP_CONVOYS set [_convoyIndex, _newArray];
								};
							};
						} forEach A3C_GROUP_CONVOYS;

					} forEach _checkGroups;
					publicVariable "A3C_GROUP_CONVOYS";
				};

				{
					private _gp = _x;

					if !([_gp] call _groupStillInAnyConvoy) then {
						_gp setVariable ["A3C_UI_Group_Status",nil,true];
						[[_gp], A3C_HC_ReInitGroupMovement] remoteExec ["bis_fnc_call", leader _gp];
						[_gp] call _convoyRestoreBehaviour;
					};
				} forEach _checkGroups;
			};

			private _convoyLeader = objNull;
			private _allVehicleCount = 0;

			{
				private _group = _x;
				private _leaderVic = vehicle leader _group;

				private _refIndex = _forEachIndex - 1;
				private _leadByGroup = if (_refIndex >= 0) then {_freeGroups select _refIndex} else {_lastUnit};

				if (_forEachIndex > 0 OR {_addingToConvoy && {_leadByGroup == _lastUnit}}) then {
					private _isLastVehicle = _forEachIndex == (count _freeGroups) - 1;
					private _allVehicles = [];

					{
						private _v = vehicle _x;
						if (!isNull objectParent _x && {_x == driver _v}) then {
							if !(_v in _allVehicles) then {
								_allVehicles pushBackUnique _v;
								_allVehicleCount = _allVehicleCount + 1;

								[_v,(speed vehicle leader _leadByGroup)] remoteExec ["limitSpeed",_v];
							};
						};
					} forEach (units _x);

					[[_group,_allVehicles,[_leadByGroup,_convoyLeader],_allVehicleCount,_isLastVehicle],_pidFnc] remoteExec ["bis_fnc_spawn", leader _group];
				} else {
					_convoyLeader = vehicle leader _group;
					_group setVariable ["A3C_UI_Group_Status",["STARTING ENGINE",A3C_UI_COLOR_RED],true];

					{
						private _v = vehicle _x;
						if (!isNull objectParent _x && {_x == driver _v}) then {
							_allVehicleCount = _allVehicleCount + 1;
						};
					} forEach (units _x);

					_group spawn {
						waitUntil {
							private _l = vehicle leader _this;
							private _d = _this getVariable ["A3C_UI_Group_Status",["",[]]];
							_d select 0 != "STARTING ENGINE" OR {speed _l > 1}
						};
						_this setVariable ["A3C_UI_Group_Status",["",[]],true];
					};
				};
			} forEach _freeGroups;
		};
	};
};
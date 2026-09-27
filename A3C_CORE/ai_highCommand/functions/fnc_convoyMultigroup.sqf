// A3C_ai_highCommand_fnc_convoyMultigroup


/*
	#TODO:
	Unify naming so that every function starts with 'convoy' or 'roadRoute' or at least 'road'
*/

params ["_inputUnits","_refPos"];

private _showWaypointDistributionFailure = {
	params [
		"_resultCode"
	];

	private _message =
		switch (true) do {
			case (
				_resultCode
					== "ROAD_CORRIDOR_INSUFFICIENT"
			): {
				"Convoy waypoint not created: there is not enough connected road behind this destination to place every group. Move the waypoint farther forward along the road."
			};

			case (
				_resultCode in [
					"ROUTE_INVALID",
					"ROUTE_ROAD_OBJECTS_EMPTY",
					"ROUTE_COMPILE_FAILED",
					"ROUTE_POSITIONS_EMPTY",
					"ROUTE_BUILD_FAILED",
					"ROAD_ALIGNMENT_FAILED"
				]
			): {
				"Convoy waypoint not created: no continuous road route could be found between the convoy and this destination. Move the waypoint farther along the intended connected road."
			};

			case (
				_resultCode in [
					"NO_GROUPS",
					"NO_REFERENCE_GROUPS"
				]
			): {
				"Convoy waypoint not created: no valid reference groups were available for road alignment."
			};

			case (
				_resultCode in [
					"ROAD_POSITION_COUNT_MISMATCH",
					"WEDGE_POSITION_COUNT_MISMATCH"
				]
			): {
				"Convoy waypoint not created: positions could not be generated for every selected group. Try placing the waypoint again."
			};

			default {
				"Convoy waypoint not created because a complete waypoint formation could not be generated. Try moving the destination and placing it again."
			};
		};

	hintSilent _message;

	diag_log format [
		"[A3C CONVOY WAYPOINT] Operation rejected | Reason: %1",
		_resultCode
	];
};

private _validateWaypointPositions = {
	params [
		"_positions",
		"_expectedCount"
	];

	private _resultState =
		missionNamespace getVariable [
			"A3C_CONVOY_WP_POSITION_RESULT_LOCAL",
			createHashMap
		];

	private _hasResultState =
		_resultState isEqualType
			createHashMap;

	private _resultCode =
		if (_hasResultState) then {
			_resultState getOrDefault [
				"result",
				"RESULT_STATE_MISSING"
			]
		} else {
			"RESULT_STATE_MISSING"
		};

	private _valid =
		_hasResultState
		&& {
			_resultState getOrDefault [
				"valid",
				false
			]
		}
		&& {
			_positions isEqualType []
		}
		&& {
			count _positions
				== _expectedCount
		}
		&& {
			_resultState getOrDefault [
				"generatedPositionCount",
				-1
			] == count _positions
		}
		&& {
			_resultState getOrDefault [
				"expectedPositionCount",
				-1
			] == _expectedCount
		};

	if (!_valid) then {
		[
			_resultCode
		] call _showWaypointDistributionFailure;
	};

	_valid
};


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
	private _wpPositions = [
		_refPos,
		_inputUnits,
		count _inputUnits,
		(
			_refPos getDir
				leader (_inputUnits select 0)
		) + 180,
		20
	] call A3C_main_fnc_generateWpWedgePositions;

	if !(
		[
			_wpPositions,
			count _inputUnits
		] call _validateWaypointPositions
	) exitWith {};

	{
		private _group = _x;

		private _waypointPosition =
			_wpPositions select _forEachIndex;

		[
			_group,
			_waypointPosition
		] call A3C_ai_highCommand_fnc_addWaypoint;
	} forEach _inputUnits;
};

_inputUnits = _inputUnits select {
	private _lVic = objectParent (leader _x);
	!isNull _lVic && {driver _lVic in (units _x)}
};

private _isAirOnly = true;

//-- to do: plane check here, as cheap as possible. one plane should disqualify the entire array for convoy as plane will crash when limiting speed

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
		[_x,_convoyArraySorted] call MCSS_fnc_getArrayIndex
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

/*
 * This is the permanent convoy order used for position generation,
 * waypoint assignment and waypoint-bundle registration.
 *
 * Existing convoy groups retain their stored order. Newly added
 * groups are appended in their newly established order.
 */
private _orderedGroups =
	_convoyGroupsActive + _freeGroups;

if (_orderedGroups isEqualTo []) exitWith {};

private _wpPositions = [
	_refPos,
	_orderedGroups,
	count _orderedGroups,
	(
		_refPos getDir
			leader (_orderedGroups select 0)
	) + 180,
	20
] call A3C_main_fnc_generateWpWedgePositions;

if !(
	[
		_wpPositions,
		count _orderedGroups
	] call _validateWaypointPositions
) exitWith {};

private _waypointBundle = [];

private _createWaypointBundle =
	!_isAirOnly
	&& {count _orderedGroups > 1};

{
	private _gp = _x;

	private _wpPos =
		_wpPositions select _forEachIndex;

	private _waypointUID = "";

	if (_createWaypointBundle) then {
		_waypointUID = format [
			"A3C_CONVOY_WP_%1_%2",
			clientOwner,
			A3C_WAYPOINT_UID_COUNTER_LOCAL
		];

		A3C_WAYPOINT_UID_COUNTER_LOCAL =
			A3C_WAYPOINT_UID_COUNTER_LOCAL + 1;
	};

	private _wpParams = [
		_gp,
		_wpPos,
		[],
		"MOVE",
		nil,
		false,
		-1,
		_waypointUID
	];

	private _wp =
		_wpParams call A3C_ai_highCommand_fnc_addWaypoint;

	if (
		_createWaypointBundle
		&& {!isNil "_wp"}
		&& {_wp isEqualType []}
		&& {count _wp == 2}
	) then {
		_waypointBundle pushBack [
			_wp select 0,
			_waypointUID
		];
	};
} forEach _orderedGroups;

if (_isAirOnly) exitWith {
	[] spawn {
		hint "All selected group leading vehicles are aircraft - aborting convoy PID";
		sleep 3;
		hintSilent "";
	};
};

if (count _waypointBundle > 1) then {
	[_waypointBundle] remoteExecCall [
		"A3C_server_fnc_registerWaypointBundle",
		2
	];
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

	/*
		Register or extend the server-authoritative convoy runtime.
		_managedGroups is the complete permanent group order.
		_freeGroups contains only newly added groups.
	*/
	[
		_managedGroups,
		_freeGroups
	] remoteExecCall [
		"A3C_server_fnc_registerConvoyRuntime",
		2
	];

	

	[_freeGroups,_lastUnit,_managedGroups] spawn {
		params ["_freeGroups","_lastUnit","_managedGroups"];

		
		private _addingToConvoy = !isNull _lastUnit;

		private _convoyGetDesiredBehaviour = {
			params ["_group"];

			private _leaderVehicle = vehicle leader _group;
			if (isNull _leaderVehicle) exitWith {"SAFE"};

			if (!([_leaderVehicle] call A3C_main_fnc_isArmedVehicle)) exitWith {"CARELESS"};
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

				private _useRuntimeControl =
					missionNamespace getVariable [
						"A3C_USE_RUNTIME_CONVOY_CONTROL",
						false
					];

				if (isNull _leadByGroup) exitWith {};

				/*
				* A dead predecessor must not alter the permanent convoy order.
				* Find the nearest preceding living group locally instead.
				*/
				if ({alive _x} count (units _leadByGroup) == 0) then {
					private _convoyIndex =
						A3C_GROUP_CONVOYS findIf {
							_group in _x
						};

					if (_convoyIndex >= 0) then {
						private _registeredGroups =
							A3C_GROUP_CONVOYS select _convoyIndex;

						private _groupIndex =
							_registeredGroups find _group;

						private _replacementGroup =
							grpNull;

						if (_groupIndex > 0) then {
							for "_i" from (_groupIndex - 1) to 0 step -1 do {
								private _candidateGroup =
									_registeredGroups select _i;

								if (
									!isNull _candidateGroup
									&& {
										{alive _x} count
											(units _candidateGroup) > 0
									}
								) exitWith {
									_replacementGroup =
										_candidateGroup;
								};
							};
						};

						_leadByGroup =
							if (isNull _replacementGroup) then {
								_group
							} else {
								_replacementGroup
							};
					} else {
						_leadByGroup =
							_group;
					};
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
					false
				} else {
					if (_doStandBy) then {
						_stopSpeed
					} else {
						if (_mustCatchUp) then {
							false
						} else {
							if (_leaderSpeed < 10 && {_closestDistance < 30}) then {
								_stopSpeed
							} else {
								if (_closestDistance < 50) then {
									_leaderSpeed
								} else {
									false
								};
							};
						};
					}
				};

				private _hasSpeedLimit =
					_maxSpeed isEqualType 0;

				private _isStopped =
					_hasSpeedLimit
					&& {
						_maxSpeed == _stopSpeed
					};

				private _isFollowingLeaderSpeed =
					_hasSpeedLimit
					&& {
						round _maxSpeed
							== round _leaderSpeed
					};

				if (!_useRuntimeControl) then {
					if (_isStopped) then {
						_group setVariable
							[
								"A3C_UI_Group_Status",
								[
									format [
										"WAITING FOR %1",
										groupID _leadByGroup
									],
									[1,0.25,0.3,1]
								],
								true
							];
					} else {
						if (_isFollowingLeaderSpeed) then {
							_group setVariable
								[
									"A3C_UI_Group_Status",
									[
										format [
											"SPEED LIMIT: %1",
											round _leaderSpeed
										],
										A3C_UI_COLOR_YELLOW
									],
									true
								];
						} else {
							private _d =
								_group getVariable [
									"A3C_UI_Group_Status",
									["",[]]
								];

							if (
								{
									_x in (_d select 0)
								} count [
									"WAITING",
									"LIMIT"
								] > 0
							) then {
								_group setVariable [
									"A3C_UI_Group_Status",
									["",[]],
									true
								];
							};
						};
					};
				};

				if (_doExit) exitWith {
					/*
					 * Runtime control owns speed commands, movement
					 * suppression and convoy UI while active.
					 */
					if (!_useRuntimeControl) then {
						{
							private _vic = _x;

							if (!isNull _vic) then {
								[
									_vic,
									false
								] remoteExec [
									"limitSpeed",
									_vic
								];
							};
						} forEach _allVehicles;

						[
							_group,
							"enableAI"
						] call _abilityFnc;

						private _followCompleteStatus = [
							"FOLLOW COMPLETE",
							[1, 1, 1, 1]
						];

						_group setVariable [
							"A3C_UI_Group_Status",
							_followCompleteStatus,
							true
						];

						sleep 3;

						if (
							(
								_group getVariable [
									"A3C_UI_Group_Status",
									["", []]
								]
							) isEqualTo
								_followCompleteStatus
							&& {
								(
									_group getVariable [
										"A3C_RuntimeConvoyUIOwner",
										""
									]
								) == ""
							}
						) then {
							_group setVariable [
								"A3C_UI_Group_Status",
								["", []],
								true
							];
						};
					};
				};

				/*
					* Stored vehicle references can become null if a vehicle is deleted,
					* or if an invalid vehicle reference entered the initial snapshot.
				*/
				_allVehicles =
					_allVehicles select {
						!isNull _x
					};

				if (!_useRuntimeControl) then {
					{
						private _vic = _x;

						[
							_vic,
							_maxSpeed
						] remoteExec [
							"limitSpeed",
							_vic
						];

						if (_isStopped) then {
							if (
								!(_vic in A3C_CONVOY_SLOWDOWN_VICS)
								&& {speed _vic > 10}
							) then {
								[_vic] spawn {
									params ["_vic"];

									A3C_CONVOY_SLOWDOWN_VICS pushBackUnique
										_vic;

									while {
										!isNull _vic
										&& {speed _vic > 10}
									} do {
										private _vlm =
											velocityModelSpace _vic;

										private _frontalSpeed =
											((_vlm select 1) - 1) max 0;

										_vlm set [
											1,
											_frontalSpeed
										];

										[
											_vic,
											_vlm
										] remoteExec [
											"setVelocityModelSpace",
											_vic
										];

										sleep 0.05;
									};

									A3C_CONVOY_SLOWDOWN_VICS =
										A3C_CONVOY_SLOWDOWN_VICS
											- [_vic];
								};
							};
						};
					} forEach _allVehicles;

					if (_isStopped) then {
						[_group, "disableAI"] call _abilityFnc;
					} else {
						[_group, "enableAI"] call _abilityFnc;
					};

					if (
						_isLastVehicle
						&& {!isNull _convoyLeader}
						&& {!isNull _followingVic}
					) then {
						private _convoyLeaderGroup =
							group driver _convoyLeader;

						if (
							_convoyLeader distance2D _followingVic
								> (_vehicleCountAhead * 75)
						) then {
							[
								_convoyLeader,
								20
							] remoteExec [
								"limitSpeed",
								_convoyLeader
							];

							if (!isNull _convoyLeaderGroup) then {
								_convoyLeaderGroup setVariable [
									"A3C_UI_Group_Status",
									[
										"REGROUP",
										[1,0,0,1]
									],
									true
								];
							};
						} else {
							[
								_convoyLeader,
								false
							] remoteExec [
								"limitSpeed",
								_convoyLeader
							];

							if (!isNull _convoyLeaderGroup) then {
								_convoyLeaderGroup setVariable [
									"A3C_UI_Group_Status",
									["",[]],
									true
								];
							};
						};
					};
				};

				sleep 1;
			};

			/*
			* Individual follower workers must never remove themselves or their
			* predecessors from the permanent convoy order.
			*
			* Only the group currently occupying the final convoy position may
			* retire the convoy. If its worker stopped because the predecessor
			* completed first, wait until the final group itself completes.
			*/
			private _cleanupGroups = [];

			private _convoyIndex =
				A3C_GROUP_CONVOYS findIf {
					_group in _x
				};

			private _isCurrentTail = false;

			if (_convoyIndex >= 0) then {
				private _registeredGroups =
					A3C_GROUP_CONVOYS select _convoyIndex;

				_isCurrentTail =
					!(_registeredGroups isEqualTo [])
					&& {
						(
							_registeredGroups select (
								(count _registeredGroups) - 1
							)
						) isEqualTo _group
					};
			};

			if (_isCurrentTail) then {
				/*
				* The PID may have stopped because the preceding group reached
				* its destination. That is not sufficient to retire the convoy.
				*/
				waitUntil {
					sleep 0.5;

					private _currentConvoyIndex =
						A3C_GROUP_CONVOYS findIf {
							_group in _x
						};

					if (_currentConvoyIndex < 0) then {
						true
					} else {
						private _currentGroups =
							A3C_GROUP_CONVOYS select
								_currentConvoyIndex;

						private _stillCurrentTail =
							!(_currentGroups isEqualTo [])
							&& {
								(
									_currentGroups select (
										(count _currentGroups) - 1
									)
								) isEqualTo _group
							};

						private _groupAlive =
							{alive _x} count
								(units _group) > 0;

						private _groupFinished =
							currentWaypoint _group
								>= count waypoints _group;

						!_stillCurrentTail
						|| {!_groupAlive}
						|| {_groupFinished}
					}
				};

				/*
				* Re-read the registration after waiting. A new group may have
				* been appended, in which case this group is no longer allowed
				* to perform cleanup.
				*/
				_convoyIndex =
					A3C_GROUP_CONVOYS findIf {
						_group in _x
					};

				if (_convoyIndex >= 0) then {
					private _registeredGroups =
						A3C_GROUP_CONVOYS select
							_convoyIndex;

					private _stillCurrentTail =
						!(_registeredGroups isEqualTo [])
						&& {
							(
								_registeredGroups select (
									(count _registeredGroups) - 1
								)
							) isEqualTo _group
						};

					private _groupAlive =
						{alive _x} count
							(units _group) > 0;

					private _groupFinished =
						currentWaypoint _group
							>= count waypoints _group;

					if (
						_stillCurrentTail
						&& {
							!_groupAlive
							|| {_groupFinished}
						}
					) then {
						_cleanupGroups =
							+_registeredGroups;

						A3C_GROUP_CONVOYS deleteAt
							_convoyIndex;

						publicVariable
							"A3C_GROUP_CONVOYS";
					};
				};
			};

			/*
			* Cleanup applies to the complete convoy only after its registration
			* has been removed atomically.
			*/
			private _runtimeControlActive =
				missionNamespace getVariable [
					"A3C_USE_RUNTIME_CONVOY_CONTROL",
					false
				];

			{
				private _cleanupGroup = _x;

				if (!isNull _cleanupGroup) then {
					/*
					 * Runtime control releases its own limits,
					 * movement suppression and UI ownership when
					 * the runtime terminates.
					 */
					if (!_runtimeControlActive) then {
						private _cleanupVehicles = [];

						{
							private _vehicle =
								vehicle _x;

							if (
								!isNull objectParent _x
								&& {
									_x == driver _vehicle
								}
							) then {
								_cleanupVehicles pushBackUnique
									_vehicle;
							};
						} forEach units _cleanupGroup;

						{
							[
								_x,
								false
							] remoteExec [
								"limitSpeed",
								_x
							];
						} forEach _cleanupVehicles;

						[
							_cleanupGroup,
							"enableAI"
						] call _abilityFnc;

						if (
							(
								_cleanupGroup getVariable [
									"A3C_RuntimeConvoyUIOwner",
									""
								]
							) == ""
						) then {
							_cleanupGroup setVariable [
								"A3C_UI_Group_Status",
								["", []],
								true
							];
						};
					};

					private _cleanupLeader =
						leader _cleanupGroup;

					if (!isNull _cleanupLeader) then {
						[
							[_cleanupGroup],
							A3C_ai_highCommand_fnc_reInitGroupMovement
						] remoteExec [
							"bis_fnc_call",
							_cleanupLeader
						];
					};

					[
						_cleanupGroup
					] call _convoyRestoreBehaviour;
				};
			} forEach _cleanupGroups;
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

							if !(
								missionNamespace getVariable [
									"A3C_USE_RUNTIME_CONVOY_CONTROL",
									false
								]
							) then {
								[
									_v,
									speed vehicle leader _leadByGroup
								] remoteExec [
									"limitSpeed",
									_v
								];
							};
						};
					};
				} forEach (units _x);

				[[_group,_allVehicles,[_leadByGroup,_convoyLeader],_allVehicleCount,_isLastVehicle],_pidFnc] remoteExec ["bis_fnc_spawn", leader _group];
			} else {
				_convoyLeader =
					vehicle leader _group;

				private _runtimeControlActive =
					missionNamespace getVariable [
						"A3C_USE_RUNTIME_CONVOY_CONTROL",
						false
					];

				if (!_runtimeControlActive) then {
					private _startingStatus = [
						"STARTING ENGINE",
						A3C_UI_COLOR_RED
					];

					_group setVariable [
						"A3C_UI_Group_Status",
						_startingStatus,
						true
					];

					[
						_group,
						_startingStatus
					] spawn {
						params [
							"_group",
							"_startingStatus"
						];

						waitUntil {
							sleep 0.1;

							private _currentStatus =
								_group getVariable [
									"A3C_UI_Group_Status",
									["", []]
								];

							!(
								_currentStatus
									isEqualTo
								_startingStatus
							)
							|| {
								speed vehicle leader _group
									> 1
							}
							|| {
								missionNamespace getVariable [
									"A3C_USE_RUNTIME_CONVOY_CONTROL",
									false
								]
							}
						};

						if (
							(
								_group getVariable [
									"A3C_UI_Group_Status",
									["", []]
								]
							) isEqualTo
								_startingStatus
							&& {
								(
									_group getVariable [
										"A3C_RuntimeConvoyUIOwner",
										""
									]
								) == ""
							}
						) then {
							_group setVariable [
								"A3C_UI_Group_Status",
								["", []],
								true
							];
						};
					};
				};

				{
					private _v =
						vehicle _x;

					if (
						!isNull objectParent _x
						&& {_x == driver _v}
					) then {
						_allVehicleCount =
							_allVehicleCount + 1;
					};
				} forEach units _group;
			};
		} forEach _freeGroups;
	};
};

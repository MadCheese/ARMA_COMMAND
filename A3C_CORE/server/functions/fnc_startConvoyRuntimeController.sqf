// A3C_server_fnc_startConvoyRuntimeController

/*
 * Starts one persistent server-authoritative controller for a convoy
 * runtime.
 *
 * The controller always evaluates the runtime once per second. When
 * A3C_USE_RUNTIME_CONVOY_CONTROL is true on the server it also applies
 * the evaluated speed limits, hard anti-overtake holds and convoy UI
 * statuses. When the flag is false it remains a shadow evaluator and
 * leaves vehicle control to the legacy convoy workers.
 *
 * Returns the existing or newly created controller handle.
 */

params [
	["_runtimeID", "", [""]]
];

if (
	!isServer
	|| {_runtimeID == ""}
	|| {isNil "A3C_CONVOY_RUNTIME_STATES"}
) exitWith {
	scriptNull
};

private _runtimeState =
	A3C_CONVOY_RUNTIME_STATES getOrDefault [
		_runtimeID,
		createHashMap
	];

if (count _runtimeState == 0) exitWith {
	scriptNull
};

private _existingController =
	_runtimeState getOrDefault [
		"controllerHandle",
		scriptNull
	];

if (
	!isNull _existingController
	&& {
		!scriptDone _existingController
	}
) exitWith {
	_existingController
};

private _controllerHandle = [
	_runtimeID
] spawn {
	params [
		"_runtimeID"
	];

	private _lastModes = [];
	private _lastHardHolds = [];
	private _lastRouteGeneration = -1;
	private _lastVehicleCount = -1;
	private _nextHeartbeat = 0;
	private _missingConvoySince = -1;
	private _stopReason = "";
	private _runtimeControlWasActive = false;
	private _knownGroups = [];
	private _controlledVehicles = [];
	private _suppressedDrivers = [];
	private _followerSpeedControlEngageGap = 40;
	private _followerSpeedControlReleaseGap = 50;

	private _setVehicleLimit = {
		params [
			"_vehicle",
			"_limit"
		];

		if (isNull _vehicle) exitWith {};

		if (local _vehicle) then {
			_vehicle limitSpeed _limit;
		} else {
			[
				_vehicle,
				_limit
			] remoteExecCall [
				"limitSpeed",
				_vehicle
			];
		};
	};

	private _setDriverMovement = {
		params [
			"_driver",
			"_enabled"
		];

		if (isNull _driver) exitWith {};

		if (local _driver) then {
			if (_enabled) then {
				_driver enableAI "MOVE";
				_driver enableAI "PATH";
			} else {
				_driver disableAI "MOVE";
				_driver disableAI "PATH";
			};
		} else {
			private _command =
				if (_enabled) then {
					"enableAI"
				} else {
					"disableAI"
				};

			[
				_driver,
				"MOVE"
			] remoteExecCall [
				_command,
				_driver
			];

			[
				_driver,
				"PATH"
			] remoteExecCall [
				_command,
				_driver
			];
		};
	};

	private _releaseVehicleState = {
		params [
			"_vehicleState"
		];

		private _vehicle =
			_vehicleState getOrDefault [
				"vehicle",
				objNull
			];

		private _lastLimitSpeed =
			_vehicleState getOrDefault [
				"lastLimitSpeed",
				-1
			];

		private _appliedSpeedLimit =
			_vehicleState getOrDefault [
				"appliedSpeedLimit",
				-1
			];

		if (
			!isNull _vehicle
			&& {
				_lastLimitSpeed >= 0
				|| {_appliedSpeedLimit >= 0}
			}
		) then {
			[
				_vehicle,
				-1
			] call _setVehicleLimit;
		};

		private _suppressedDriver =
			_vehicleState getOrDefault [
				"movementSuppressedDriver",
				objNull
			];

		if (
			_vehicleState getOrDefault [
				"movementSuppressed",
				false
			]
			&& {!isNull _suppressedDriver}
		) then {
			[
				_suppressedDriver,
				true
			] call _setDriverMovement;
		};

		if (!isNull _vehicle) then {
			_vehicle setVariable [
				"A3C_RuntimeConvoyHardHold",
				nil
			];
		};

		_vehicleState set [
			"lastLimitSpeed",
			-1
		];

		_vehicleState set [
			"appliedSpeedLimit",
			-1
		];

		_vehicleState set [
			"requestedSpeedLimit",
			-1
		];

		_vehicleState set [
			"hardHoldActive",
			false
		];

		_vehicleState set [
			"hardHoldReason",
			""
		];

		_vehicleState set [
			"speedControlActive",
			false
		];

		_vehicleState set [
			"movementSuppressed",
			false
		];

		_vehicleState set [
			"movementSuppressedDriver",
			objNull
		];
	};

	private _clearRuntimeUI = {
		params [
			"_groups"
		];

		{
			private _group = _x;

			if (
				!isNull _group
				&& {
					(
						_group getVariable [
							"A3C_RuntimeConvoyUIOwner",
							""
						]
					) == _runtimeID
				}
			) then {
				_group setVariable [
					"A3C_UI_Group_Status",
					["", []],
					true
				];

				_group setVariable [
					"A3C_RuntimeConvoyUIOwner",
					nil
				];
			};
		} forEach _groups;
	};

	while {
		_stopReason == ""
	} do {
		private _runtimeState =
			A3C_CONVOY_RUNTIME_STATES getOrDefault [
				_runtimeID,
				createHashMap
			];

		if (count _runtimeState == 0) exitWith {
			_stopReason =
				"RUNTIME_REMOVED";
		};

		private _runtimeGroups =
			_runtimeState getOrDefault [
				"groups",
				[]
			];

		_knownGroups = +_runtimeGroups;

		private _hasLivingGroup =
			_runtimeGroups findIf {
				!isNull _x
				&& {
					{alive _x} count (units _x)
						> 0
				}
			} >= 0;

		if (!_hasLivingGroup) exitWith {
			_stopReason =
				"NO_LIVING_GROUPS";
		};

		private _isRegisteredConvoy =
			if (
				isNil "A3C_GROUP_CONVOYS"
			) then {
				false
			} else {
				A3C_GROUP_CONVOYS findIf {
					private _convoyGroups =
						_x;

					_runtimeGroups findIf {
						_x in _convoyGroups
					} >= 0
				} >= 0
			};

		if (_isRegisteredConvoy) then {
			_missingConvoySince = -1;
		} else {
			if (_missingConvoySince < 0) then {
				_missingConvoySince =
					diag_tickTime;
			};

			if (
				diag_tickTime
					- _missingConvoySince
					>= 10
			) then {
				_stopReason =
					"NO_CONVOY_REGISTRATION";
			};
		};

		if (_stopReason != "") exitWith {};

		private _evaluations = [
			_runtimeID
		] call A3C_server_fnc_evaluateConvoyRuntime;

		_runtimeState =
			A3C_CONVOY_RUNTIME_STATES getOrDefault [
				_runtimeID,
				createHashMap
			];

		if (count _runtimeState == 0) exitWith {
			_stopReason =
				"RUNTIME_REMOVED";
		};

		_runtimeGroups =
			_runtimeState getOrDefault [
				"groups",
				[]
			];

		_knownGroups = +_runtimeGroups;

		private _routeGeneration =
			_runtimeState getOrDefault [
				"routeGeneration",
				-1
			];

		private _vehicleStates =
			_runtimeState getOrDefault [
				"vehicleStates",
				[]
			];

		private _vehicleCount =
			count _vehicleStates;

		private _useRuntimeControl =
			missionNamespace getVariable [
				"A3C_USE_RUNTIME_CONVOY_CONTROL",
				false
			];

		private _regroupActive = false;
		private _regroupDistance = -1;
		private _regroupThreshold = -1;
		private _activeVehicleEntries = [];

		if (_useRuntimeControl) then {
			{
				private _vehicleState = _x;

				private _vehicle =
					_vehicleState getOrDefault [
						"vehicle",
						objNull
					];

				private _retired =
					_vehicleState getOrDefault [
						"retired",
						false
					];

				if (
					!_retired
					&& {!isNull _vehicle}
					&& {alive _vehicle}
				) then {
					_activeVehicleEntries pushBack [
						_forEachIndex,
						_vehicleState,
						_vehicle
					];
				};
			} forEach _vehicleStates;

			private _activeVehicleCount =
				count _activeVehicleEntries;

			if (_activeVehicleCount >= 2) then {
				private _firstEntry =
					_activeVehicleEntries select 0;

				private _lastEntry =
					_activeVehicleEntries select (
						_activeVehicleCount - 1
					);

				private _firstVehicle =
					_firstEntry select 2;

				private _lastVehicle =
					_lastEntry select 2;

				_regroupDistance =
					_firstVehicle distance2D
						_lastVehicle;

				_regroupThreshold =
					_activeVehicleCount * 75;

				private _wasRegrouping =
					_runtimeState getOrDefault [
						"regroupActive",
						false
					];

				_regroupActive =
					if (_wasRegrouping) then {
						_regroupDistance
							> (_regroupThreshold * 0.8)
					} else {
						_regroupDistance
							> _regroupThreshold
					};
			};
		};

		private _groupStatusProposals = [];

		private _proposeGroupStatus = {
			params [
				"_group",
				"_priority",
				"_status"
			];

			if (isNull _group) exitWith {};

			private _proposalIndex =
				_groupStatusProposals findIf {
					(_x select 0) isEqualTo _group
				};

			if (_proposalIndex < 0) then {
				_groupStatusProposals pushBack [
					_group,
					_priority,
					_status
				];
			} else {
				private _existingProposal =
					_groupStatusProposals select
						_proposalIndex;

				if (
					_priority
						> (_existingProposal select 1)
				) then {
					_groupStatusProposals set [
						_proposalIndex,
						[
							_group,
							_priority,
							_status
						]
					];
				};
			};
		};

		if (_useRuntimeControl) then {
			private _yellow =
				missionNamespace getVariable [
					"A3C_UI_COLOR_YELLOW",
					[1, 1, 0, 1]
				];

			private _firstActiveIndex =
				if (_activeVehicleEntries isEqualTo []) then {
					-1
				} else {
					(_activeVehicleEntries select 0)
						select 0
				};

			{
				private _vehicleState = _x;

				private _vehicle =
					_vehicleState getOrDefault [
						"vehicle",
						objNull
					];

				private _group =
					_vehicleState getOrDefault [
						"group",
						grpNull
					];

				private _retired =
					_vehicleState getOrDefault [
						"retired",
						false
					];

				private _trackingMode =
					_vehicleState getOrDefault [
						"mode",
						"INITIALIZING"
					];

				private _controlMode =
					_vehicleState getOrDefault [
						"controlMode",
						"INITIALIZING"
					];

				private _recommendedSpeed =
					_vehicleState getOrDefault [
						"recommendedSpeed",
						-1
					];

				private _bumperGap =
					_vehicleState getOrDefault [
						"bumperGapToVehicleAhead",
						-1
					];

				private _desiredGap =
					_vehicleState getOrDefault [
						"desiredGap",
						-1
					];

				private _freeSpeedTarget =
					_vehicleState getOrDefault [
						"freeSpeedTarget",
						-1
					];

				private _speedAhead =
					_vehicleState getOrDefault [
						"speedAhead",
						-1
					];

				private _timeToCollision =
					_vehicleState getOrDefault [
						"timeToCollision",
						-1
					];

				private _isActiveVehicle =
					!_retired
					&& {!isNull _vehicle}
					&& {alive _vehicle};

				private _isLeader =
					_isActiveVehicle
					&& {
						_forEachIndex
							== _firstActiveIndex
					};

				private _isFollower =
					_isActiveVehicle
					&& {!_isLeader};

				private _hasValidRecommendation =
					_isActiveVehicle
					&& {_trackingMode == "TRACKED"}
					&& {_recommendedSpeed >= 0};

				private _hardHoldWasActive =
					_vehicleState getOrDefault [
						"hardHoldActive",
						false
					];

				private _hardHoldActive = false;
				private _hardHoldReason = "";

				if (
					_isFollower
					&& {_hasValidRecommendation}
				) then {
					private _criticalGap =
						_bumperGap >= 0
						&& {_bumperGap <= 4};

					private _stoppedAheadHold =
						_speedAhead >= 0
						&& {_speedAhead <= 5}
						&& {_bumperGap >= 0}
						&& {_bumperGap <= 25};

					private _imminentCollision =
						_timeToCollision >= 0
						&& {_timeToCollision < 3};

					private _hardHoldRequested =
						_controlMode == "STOPPED"
						|| {_recommendedSpeed <= 0.001}
						|| {_criticalGap}
						|| {_stoppedAheadHold}
						|| {_imminentCollision};

					if (_hardHoldRequested) then {
						_hardHoldReason =
							if (_controlMode == "STOPPED") then {
								"MODEL_STOPPED"
							} else {
								if (_stoppedAheadHold) then {
									"STOPPED_AHEAD"
								} else {
									if (_imminentCollision) then {
										"TTC"
									} else {
										if (_criticalGap) then {
											"CRITICAL_GAP"
										} else {
											"ZERO_TARGET"
										}
									}
								}
							};
					};

					if (_hardHoldWasActive) then {
						if (_hardHoldRequested) then {
							_hardHoldActive = true;
						} else {
							private _releaseGap =
								12 max (
									_desiredGap * 1.15
								);

							private _aheadMovingOrGapLarge =
								_speedAhead > 5
								|| {_bumperGap > 30};

							_hardHoldActive = !(
								_recommendedSpeed > 2
								&& {_bumperGap > _releaseGap}
								&& {_aheadMovingOrGapLarge}
							);

							if (_hardHoldActive) then {
								_hardHoldReason =
									"HYSTERESIS";
							};
						};
					} else {
						_hardHoldActive =
							_hardHoldRequested;
					};
				};

				private _speedControlWasActive =
					_vehicleState getOrDefault [
						"speedControlActive",
						false
					];

				private _speedControlActive = false;

				if (
					_isFollower
					&& {_hasValidRecommendation}
					&& {_bumperGap >= 0}
				) then {
					_speedControlActive =
						if (_speedControlWasActive) then {
							_bumperGap
								< _followerSpeedControlReleaseGap
						} else {
							_bumperGap
								<= _followerSpeedControlEngageGap
						};
				};

				if (_hardHoldActive) then {
					_speedControlActive = true;
				};

				_vehicleState set [
					"speedControlActive",
					_speedControlActive
				];

				private _targetSpeed = -1;

				if (_hasValidRecommendation) then {
					if (_isLeader) then {
						_targetSpeed =
							0.001 max _recommendedSpeed;

						if (_regroupActive) then {
							_targetSpeed =
								_targetSpeed min 20;
						};
					} else {
						if (_hardHoldActive) then {
							_targetSpeed = 0.001;
						} else {
							if (_speedControlActive) then {
								_targetSpeed =
									if (
										_controlMode == "CATCHUP"
										&& {_freeSpeedTarget > 0}
									) then {
										private _aheadReferenceSpeed =
											0 max _speedAhead;

										private _excessGap =
											0 max (
												_bumperGap
													- (0 max _desiredGap)
											);

										private _gapBasedCatchupSpeed =
											_aheadReferenceSpeed
												+ (_excessGap * 0.5);

										(
											_recommendedSpeed max
												_gapBasedCatchupSpeed
										) min _freeSpeedTarget
									} else {
										0.001 max _recommendedSpeed
									};
							};
						};
					};
				};

				private _movementSuppressed =
					_vehicleState getOrDefault [
						"movementSuppressed",
						false
					];

				private _suppressedDriver =
					_vehicleState getOrDefault [
						"movementSuppressedDriver",
						objNull
					];

				if (_hardHoldActive) then {
					private _currentDriver =
						driver _vehicle;

					if (
						_movementSuppressed
						&& {
							!isNull _suppressedDriver
						}
						&& {
							_suppressedDriver
								isNotEqualTo _currentDriver
						}
					) then {
						[
							_suppressedDriver,
							true
						] call _setDriverMovement;

						_movementSuppressed = false;
						_suppressedDriver = objNull;
					};

					if (
						!isNull _currentDriver
						&& {
							!_movementSuppressed
						}
					) then {
						[
							_currentDriver,
							false
						] call _setDriverMovement;

						_movementSuppressed = true;
						_suppressedDriver =
							_currentDriver;

						_suppressedDrivers pushBackUnique
							_currentDriver;
					};

					_vehicle setVariable [
						"A3C_RuntimeConvoyHardHold",
						true
					];
				} else {
					if (
						_movementSuppressed
						&& {
							!isNull _suppressedDriver
						}
					) then {
						[
							_suppressedDriver,
							true
						] call _setDriverMovement;
					};

					_movementSuppressed = false;
					_suppressedDriver = objNull;

					if (!isNull _vehicle) then {
						_vehicle setVariable [
							"A3C_RuntimeConvoyHardHold",
							nil
						];
					};
				};

				_vehicleState set [
					"hardHoldActive",
					_hardHoldActive
				];

				_vehicleState set [
					"hardHoldReason",
					if (_hardHoldActive) then {
						_hardHoldReason
					} else {
						""
					}
				];

				_vehicleState set [
					"movementSuppressed",
					_movementSuppressed
				];

				_vehicleState set [
					"movementSuppressedDriver",
					_suppressedDriver
				];

				if (
					_hardHoldActive
					&& {speed _vehicle > 10}
				) then {
					if (
						isNil "A3C_CONVOY_SLOWDOWN_VICS"
					) then {
						A3C_CONVOY_SLOWDOWN_VICS = [];
					};

					if !(
						_vehicle in
							A3C_CONVOY_SLOWDOWN_VICS
					) then {
						A3C_CONVOY_SLOWDOWN_VICS
							pushBackUnique _vehicle;

						[_vehicle] spawn {
							params [
								"_vehicle"
							];

							while {
								!isNull _vehicle
								&& {alive _vehicle}
								&& {
									_vehicle getVariable [
										"A3C_RuntimeConvoyHardHold",
										false
									]
								}
								&& {
									missionNamespace getVariable [
										"A3C_USE_RUNTIME_CONVOY_CONTROL",
										false
									]
								}
								&& {speed _vehicle > 10}
							} do {
								private _velocity =
									velocityModelSpace _vehicle;

								_velocity set [
									1,
									(
										(_velocity select 1) - 1
									) max 0
								];

								if (local _vehicle) then {
									_vehicle setVelocityModelSpace
										_velocity;
								} else {
									[
										_vehicle,
										_velocity
									] remoteExecCall [
										"setVelocityModelSpace",
										_vehicle
									];
								};

								sleep 0.05;
							};

							if (
								!isNil "A3C_CONVOY_SLOWDOWN_VICS"
							) then {
								A3C_CONVOY_SLOWDOWN_VICS =
									A3C_CONVOY_SLOWDOWN_VICS
										- [_vehicle];
							};
						};
					};
				};

				private _lastLimitSpeed =
					_vehicleState getOrDefault [
						"lastLimitSpeed",
						-1
					];

				private _lastLimitCommandTime =
					_vehicleState getOrDefault [
						"lastLimitCommandTime",
						-1
					];

				private _appliedSpeedLimit =
					_vehicleState getOrDefault [
						"appliedSpeedLimit",
						-1
					];

				if (_targetSpeed >= 0) then {
					private _limitChanged =
						_lastLimitSpeed < 0
						|| {
							abs (
								_targetSpeed
									- _lastLimitSpeed
							) >= 1
						};

					private _limitRefreshDue =
						serverTime
							- _lastLimitCommandTime
							>= 5;

					if (
						_limitChanged
						|| {_limitRefreshDue}
					) then {
						[
							_vehicle,
							_targetSpeed
						] call _setVehicleLimit;

						_vehicleState set [
							"lastLimitSpeed",
							_targetSpeed
						];

						_vehicleState set [
							"appliedSpeedLimit",
							_targetSpeed
						];

						_vehicleState set [
							"lastLimitCommandTime",
							serverTime
						];
					};

					_vehicleState set [
						"requestedSpeedLimit",
						_targetSpeed
					];

					_controlledVehicles pushBackUnique
						_vehicle;
				} else {
					if (
						!isNull _vehicle
						&& {
							_lastLimitSpeed >= 0
							|| {_appliedSpeedLimit >= 0}
						}
					) then {
						[
							_vehicle,
							-1
						] call _setVehicleLimit;
					};

					_vehicleState set [
						"lastLimitSpeed",
						-1
					];

					_vehicleState set [
						"appliedSpeedLimit",
						-1
					];

					_vehicleState set [
						"requestedSpeedLimit",
						-1
					];
				};

				if (_hardHoldActive) then {
					private _referenceGroup = grpNull;

					for "_i" from (
						_forEachIndex - 1
					) to 0 step -1 do {
						private _candidateState =
							_vehicleStates select _i;

						private _candidateGroup =
							_candidateState getOrDefault [
								"group",
								grpNull
							];

						if (
							!isNull _candidateGroup
							&& {
								_candidateGroup
									isNotEqualTo _group
							}
						) exitWith {
							_referenceGroup =
								_candidateGroup;
						};
					};

					private _waitingText =
						if (isNull _referenceGroup) then {
							"WAITING"
						} else {
							format [
								"WAITING FOR %1",
								groupID _referenceGroup
							]
						};

					[
						_group,
						20,
						[
							_waitingText,
							[1, 0.25, 0.3, 1]
						]
					] call _proposeGroupStatus;
				} else {
					if (
						_isFollower
						&& {_targetSpeed >= 0}
						&& {_freeSpeedTarget > 0}
						&& {
							_targetSpeed
								< (_freeSpeedTarget - 1)
						}
					) then {
						[
							_group,
							10,
							[
								format [
									"SPEED LIMIT: %1",
									round _targetSpeed
								],
								_yellow
							]
						] call _proposeGroupStatus;
					};
				};
			} forEach _vehicleStates;

			if (
				_regroupActive
				&& {
					!(_activeVehicleEntries isEqualTo [])
				}
			) then {
				private _leaderState =
					(_activeVehicleEntries select 0)
						select 1;

				private _leaderGroup =
					_leaderState getOrDefault [
						"group",
						grpNull
					];

				[
					_leaderGroup,
					30,
					[
						"REGROUP",
						[1, 0, 0, 1]
					]
				] call _proposeGroupStatus;
			};

			{
				private _group = _x;

				if (!isNull _group) then {
					private _proposalIndex =
						_groupStatusProposals findIf {
							(_x select 0)
								isEqualTo _group
						};

					if (_proposalIndex >= 0) then {
						private _desiredStatus =
							(
								_groupStatusProposals
									select _proposalIndex
							) select 2;

						private _currentStatus =
							_group getVariable [
								"A3C_UI_Group_Status",
								["", []]
							];

						_group setVariable [
							"A3C_RuntimeConvoyUIOwner",
							_runtimeID
						];

						if !(
							_currentStatus
								isEqualTo _desiredStatus
						) then {
							_group setVariable [
								"A3C_UI_Group_Status",
								_desiredStatus,
								true
							];
						};
					} else {
						if (
							(
								_group getVariable [
									"A3C_RuntimeConvoyUIOwner",
									""
								]
							) == _runtimeID
						) then {
							_group setVariable [
								"A3C_UI_Group_Status",
								["", []],
								true
							];

							_group setVariable [
								"A3C_RuntimeConvoyUIOwner",
								nil
							];
						};
					};
				};
			} forEach _runtimeGroups;
		} else {
			if (_runtimeControlWasActive) then {
				{
					[_x] call _releaseVehicleState;
				} forEach _vehicleStates;

				[_runtimeGroups] call _clearRuntimeUI;
			};
		};

		_runtimeState set [
			"vehicleStates",
			_vehicleStates
		];

		_runtimeState set [
			"runtimeControlActive",
			_useRuntimeControl
		];

		_runtimeState set [
			"controllerMode",
			if (_useRuntimeControl) then {
				"ACTIVE"
			} else {
				"SHADOW"
			}
		];

		_runtimeState set [
			"regroupActive",
			_regroupActive
		];

		_runtimeState set [
			"regroupDistance",
			_regroupDistance
		];

		_runtimeState set [
			"regroupThreshold",
			_regroupThreshold
		];

		_runtimeState set [
			"lastControllerTick",
			serverTime
		];

		_runtimeState set [
			"updatedAt",
			serverTime
		];

		A3C_CONVOY_RUNTIME_STATES set [
			_runtimeID,
			_runtimeState
		];

		private _routeGenerationChanged =
			_routeGeneration
				!= _lastRouteGeneration;

		private _vehicleCountChanged =
			_vehicleCount
				!= _lastVehicleCount;

		private _heartbeat =
			diag_tickTime
				>= _nextHeartbeat;

		private _debugEnabled =
			missionNamespace getVariable [
				"A3C_DEBUG_CONVOY_CONTROLLER",
				false
			];

		if (_debugEnabled) then {
			{
				private _controlMode =
					_x param [
						3,
						""
					];

				private _previousMode =
					_lastModes param [
						_forEachIndex,
						""
					];

				private _controlModeChanged =
					_controlMode
						isNotEqualTo
					_previousMode;

				private _vehicleState =
					_vehicleStates param [
						_forEachIndex,
						createHashMap
					];

				private _hardHoldActive =
					_vehicleState getOrDefault [
						"hardHoldActive",
						false
					];

				private _hardHoldChanged =
					_hardHoldActive
						isNotEqualTo
					(
						_lastHardHolds param [
							_forEachIndex,
							false
						]
					);

				if (
					_controlModeChanged
					|| {_hardHoldChanged}
					|| {_routeGenerationChanged}
					|| {_vehicleCountChanged}
					|| {_heartbeat}
				) then {
					diag_log format [
						"[A3C CONVOY CONTROLLER] Runtime: %1 | Mode: %2 | Order: %3 | Vehicle: %4 | Tracking: %5 | Control: %6 | Progress: %7 | Bumper gap: %8 | Desired gap: %9 | Speed: %10 | Ahead speed: %11 | Recommended: %12 | Applied: %13 | Free target: %14 | Hard hold: %15 | Hold reason: %16 | TTC: %17 | Regroup: %18 | Route generation: %19",
						_runtimeID,
						if (_useRuntimeControl) then {
							"ACTIVE"
						} else {
							"SHADOW"
						},
						_forEachIndex,
						_x param [0, objNull],
						_x param [2, ""],
						_controlMode,
						_x param [4, -1],
						_x param [6, -1],
						_x param [7, -1],
						_x param [8, -1],
						_x param [9, -1],
						_x param [10, -1],
						_vehicleState getOrDefault [
							"appliedSpeedLimit",
							-1
						],
						_x param [14, -1],
						_hardHoldActive,
						_vehicleState getOrDefault [
							"hardHoldReason",
							""
						],
						_x param [11, -1],
						_regroupActive,
						_routeGeneration
					];
				};

				_lastModes set [
					_forEachIndex,
					_controlMode
				];

				_lastHardHolds set [
					_forEachIndex,
					_hardHoldActive
				];
			} forEach _evaluations;
		};

		_lastRouteGeneration =
			_routeGeneration;

		_lastVehicleCount =
			_vehicleCount;

		_runtimeControlWasActive =
			_useRuntimeControl;

		if (_heartbeat) then {
			_nextHeartbeat =
				diag_tickTime + 15;
		};

		sleep 1;
	};

	private _runtimeState =
		if (
			isNil "A3C_CONVOY_RUNTIME_STATES"
		) then {
			createHashMap
		} else {
			A3C_CONVOY_RUNTIME_STATES getOrDefault [
				_runtimeID,
				createHashMap
			]
		};

	if (count _runtimeState > 0) then {
		private _vehicleStates =
			_runtimeState getOrDefault [
				"vehicleStates",
				[]
			];

		{
			[_x] call _releaseVehicleState;
		} forEach _vehicleStates;

		private _runtimeGroups =
			_runtimeState getOrDefault [
				"groups",
				[]
			];

		_knownGroups = +_runtimeGroups;
	};

	{
		if (!isNull _x) then {
			[
				_x,
				-1
			] call _setVehicleLimit;

			_x setVariable [
				"A3C_RuntimeConvoyHardHold",
				nil
			];
		};
	} forEach _controlledVehicles;

	{
		if (!isNull _x) then {
			[
				_x,
				true
			] call _setDriverMovement;
		};
	} forEach _suppressedDrivers;

	[_knownGroups] call _clearRuntimeUI;

	{
		if (
			!isNull _x
			&& {
				(
					_x getVariable [
						"A3C_Convoy_RuntimeID",
						""
					]
				) == _runtimeID
			}
		) then {
			_x setVariable [
				"A3C_Convoy_RuntimeID",
				nil
			];
		};
	} forEach _knownGroups;

	if (
		!isNil "A3C_CONVOY_RUNTIME_STATES"
	) then {
		A3C_CONVOY_RUNTIME_STATES deleteAt
			_runtimeID;
	};

	if (
		missionNamespace getVariable [
			"A3C_DEBUG_CONVOY_CONTROLLER",
			false
		]
	) then {
		diag_log format [
			"[A3C CONVOY CONTROLLER] Controller stopped | Runtime: %1 | Reason: %2",
			_runtimeID,
			_stopReason
		];
	};
};

_runtimeState set [
	"controllerHandle",
	_controllerHandle
];

_runtimeState set [
	"controllerMode",
	if (
		missionNamespace getVariable [
			"A3C_USE_RUNTIME_CONVOY_CONTROL",
			false
		]
	) then {
		"ACTIVE"
	} else {
		"SHADOW"
	}
];

_runtimeState set [
	"runtimeControlActive",
	missionNamespace getVariable [
		"A3C_USE_RUNTIME_CONVOY_CONTROL",
		false
	]
];

_runtimeState set [
	"controllerStartedAt",
	serverTime
];

_runtimeState set [
	"updatedAt",
	serverTime
];

A3C_CONVOY_RUNTIME_STATES set [
	_runtimeID,
	_runtimeState
];

if (
	missionNamespace getVariable [
		"A3C_DEBUG_CONVOY_CONTROLLER",
		false
	]
) then {
	diag_log format [
		"[A3C CONVOY CONTROLLER] Controller started | Runtime: %1 | Mode: %2",
		_runtimeID,
		_runtimeState getOrDefault [
			"controllerMode",
			"SHADOW"
		]
	];
};

_controllerHandle

// A3C repair waypoint
//
// This script intentionally owns the complete repair operation. Do not spawn
// per-unit workers from here: Arma terminates the waypoint script when the
// waypoint is moved/deleted, but independently spawned scripts would survive.

params [
	["_group", grpNull, [grpNull]],
	["_pos", [0, 0, 0], [[]], [2, 3]],
	["_target", objNull, [objNull]],
	["_callerUID", "", [""]],
	["_preCondition", ["ARRIVAL", 0], [[]], [2]]
];


if (isNull _group) exitWith {
	true
};

private _isBlocked = [_callerUID, _group]
	call A3C_ai_highCommand_fnc_isWpScriptBlocked;


if (_isBlocked) exitWith {
	true
};

private _wpIndex = currentWaypoint _group;

// A new invocation invalidates any older invocation which might still receive
// scheduler time during a rapid waypoint edit/retrigger.
private _runID = (_group getVariable ["A3C_REPAIR_WP_RUN_ID", 0]) + 1;
_group setVariable ["A3C_REPAIR_WP_RUN_ID", _runID];

private _fnc_isRepairRunCurrent = {
	if (isNull _group) exitWith {
		false
	};

	if !(local _group) exitWith {
		false
	};

	if ((_group getVariable ["A3C_REPAIR_WP_RUN_ID", -1]) != _runID) exitWith {
		false
	};

	if ((currentWaypoint _group) != _wpIndex) exitWith {
		false
	};

	private _wp = [_group, _wpIndex];
	if ((waypointType _wp) != "SCRIPTED") exitWith {
		false
	};

	if (
		!(
			[
				"wpscript_repair.sqf",
				toLower (waypointScript _wp)
			] call BIS_fnc_inString
		)
	) exitWith {
		false
	};

	private _positionDistance = _pos distance2D (waypointPosition _wp);
	if (_positionDistance > 3) exitWith {
		false
	};

	true
};

// Recover units which may still contain state left by the legacy repair
// script or by an earlier build. The replacement below uses a tightly owned
// AnimDone handler only as a completion signal; it never starts another
// animation from inside the handler.
private _legacyPatients = [];
{
	private _unit = _x;

	private _ownedAnimationControl = _unit getVariable [
		"A3C_REPAIR_ANIMATION_CONTROL",
		[]
	];
	if (
		_ownedAnimationControl isEqualType []
		&& {count _ownedAnimationControl > 1}
	) then {
		private _ownedAnimHandler = _ownedAnimationControl param [1, -1];
		if (_ownedAnimHandler >= 0) then {
			_unit removeEventHandler ["AnimDone", _ownedAnimHandler];
		};
	};
	_unit setVariable ["A3C_REPAIR_ANIMATION_CONTROL", nil];

	private _repairData = _unit getVariable [
		"A3C_isRepairing",
		[false, objNull]
	];

	if (
		_repairData isEqualType []
		&& {count _repairData > 1}
		&& {_repairData param [0, false]}
	) then {
		private _legacyPatient = _repairData param [1, objNull];
		if (!isNull _legacyPatient) then {
			_legacyPatients pushBackUnique _legacyPatient;
		};
	};

	private _animData = _unit getVariable [
		"A3C_HandlerID_AnimDone",
		[false, -1]
	];
	private _animHandler = if (
		_animData isEqualType []
		&& {count _animData > 1}
	) then {
		_animData param [1, -1]
	} else {
		-1
	};

	_unit setVariable ["A3C_HandlerID_AnimDone", nil, true];
	if (_animHandler >= 0) then {
		_unit removeEventHandler ["AnimDone", _animHandler];
	};

	_unit setVariable [
		"A3C_isRepairing",
		[false, objNull],
		true
	];

	_unit enableAI "MOVE";
	_unit enableAI "AUTOCOMBAT";
	(vehicle _unit) enableAI "MOVE";

	private _currentAnimation = toLower (animationState _unit);

	if (
		_currentAnimation in [
			"inbasemoves_assemblingvehicleerc",
			"inbasemoves_repairvehicleknl"
		]
	) then {
		private _resetAnimation = if (
			_currentAnimation == "inbasemoves_repairvehicleknl"
		) then {
			"AmovPknlMstpSnonWnonDnon"
		} else {
			"AmovPercMstpSnonWnonDnon"
		};

		_unit playMoveNow _resetAnimation;
		_unit enableAI "ANIM";
	};

	_unit setUnitPos "AUTO";
	_unit lookAt objNull;
} forEach units _group;

{
	_x setVariable [
		"A3C_isBeingRepaired",
		[false, 0, []],
		true
	];
} forEach _legacyPatients;

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

private _fnc_sendFeedback = {
	params ["_message"];

	[
		[_callerUID, _message],
		{
			params ["_callerUID", "_message"];

			if (
				!isNull player
				&& {getPlayerUID player == _callerUID}
			) then {
				systemChat _message;
			};
		}
	] remoteExecCall ["BIS_fnc_call", 0];
};

private _fnc_playRepairSound = {
	params ["_source", "_sound"];

	if (isNull _source || {_sound == ""}) exitWith {
	};


	// say3D has local effects, so execute it once on every machine. No JIP call
	// is stored and no scheduled sound loop survives waypoint cancellation.
	[
		[_source, _sound],
		{
			params ["_source", "_sound"];
			if (!isNull _source) then {
				_source say3D _sound;
			};
		}
	] remoteExecCall ["BIS_fnc_call", 0];
};

private _fnc_applyHitPointRepairs = {
	params ["_patient", "_repairs"];

	if (isNull _patient || {_repairs isEqualTo []}) exitWith {
	};


	private _code = {
		params ["_patient", "_repairs"];

		if (isNull _patient || {!local _patient}) exitWith {};


		{
			_x params ["_hitPoint", "_damage"];
			if (_hitPoint != "") then {
				_patient setHitPointDamage [
					_hitPoint,
					_damage
				];
			};
		} forEach _repairs;
	};

	if (local _patient) then {
		[[_patient, _repairs], _code] call BIS_fnc_call;
	} else {
		[[_patient, _repairs], _code]
			remoteExecCall ["BIS_fnc_call", _patient];
	};
};

private _fnc_finalizePatient = {
	params [
		"_patient",
		"_overallDamage",
		"_hitPointRepairs",
		"_unflip"
	];

	if (isNull _patient) exitWith {
	};


	private _code = {
		params [
			"_patient",
			"_overallDamage",
			"_hitPointRepairs",
			"_unflip"
		];

		if (isNull _patient || {!local _patient}) exitWith {};


		_patient setDamage _overallDamage;

		{
			_x params ["_hitPoint", "_damage"];
			if (_hitPoint != "") then {
				_patient setHitPointDamage [
					_hitPoint,
					_damage
				];
			};
		} forEach _hitPointRepairs;

		if (_unflip) then {
			_patient setVectorUp [0, 0, 1];
			_patient setPosATL (getPosATL _patient);
			_patient setVelocity [0, 0, 0];
		};
	};

	private _arguments = [
		_patient,
		_overallDamage,
		_hitPointRepairs,
		_unflip
	];

	if (local _patient) then {
		[_arguments, _code] call BIS_fnc_call;
	} else {
		[_arguments, _code]
			remoteExecCall ["BIS_fnc_call", _patient];
	};
};

private _fnc_releaseMovers = {
	params ["_movers"];

	{
		private _moverGroup = group _x;
		if (
			alive _x
			&& {!isPlayer _x}
			&& {!isNull _moverGroup}
		) then {
			_x doFollow (leader _moverGroup);
		};
	} forEach _movers;
};

// Explicitly reset every locally owned on-foot actor at patient/script
// boundaries so even a normally completed animation cannot leave the unit in
// a non-movement state.
private _fnc_resetRepairActors = {
	params ["_actors", ["_reason", "unspecified"]];
	private _uniqueActors = [];
	{
		_uniqueActors pushBackUnique _x;
	} forEach _actors;


	{
		private _actor = _x;
		if (
			!isNull _actor
			&& {alive _actor}
			&& {local _actor}
			&& {!isPlayer _actor}
			&& {isNull objectParent _actor}
		) then {
			private _resetAnimation = if (
				(toLower (animationState _actor)) find "repairvehicleknl" >= 0
			) then {
				"AmovPknlMstpSnonWnonDnon"
			} else {
				"AmovPercMstpSnonWnonDnon"
			};

			_actor playMoveNow _resetAnimation;
			_actor enableAI "ANIM";
			_actor setUnitPos "AUTO";
			_actor lookAt objNull;
		};
	} forEach _uniqueActors;

};

// A waypoint script is terminated by the engine when its waypoint is deleted.
// The terminated scope cannot run its own cleanup. This tiny unscheduled
// monitor is therefore the only state allowed to outlive the scheduled script:
// it owns only active animation cleanup entries, checks the waypoint every frame,
// resets the actors when the run becomes invalid, and removes itself in that
// same frame. It neither repairs anything nor starts repair animations.
private _animationCleanupEntries = [];
private _animationCleanupMonitorState = [
	_group,
	_wpIndex,
	_runID,
	+_pos,
	_animationCleanupEntries
];
private _animationCleanupMonitorKey = "";

private _animationCleanupMonitorID = addMissionEventHandler [
	"EachFrame",
	{
		private _monitorKey = format [
			"A3C_REPAIR_ANIMATION_MONITOR_%1",
			_thisEventHandler
		];
		private _monitorState = missionNamespace getVariable [
			_monitorKey,
			[]
		];
		if !(
			_monitorState isEqualType []
			&& {count _monitorState > 4}
		) exitWith {
			removeMissionEventHandler ["EachFrame", _thisEventHandler];
		};

		_monitorState params [
			"_monitoredGroup",
			"_monitoredWpIndex",
			"_monitoredRunID",
			"_monitoredPosition",
			"_ownedEntries"
		];

		private _monitoredWp = [
			_monitoredGroup,
			_monitoredWpIndex
		];
		private _wpExists = !isNull _monitoredGroup
			&& {_monitoredWp in (waypoints _monitoredGroup)};
		private _scriptPath = if (!_wpExists) then {
			""
		} else {
			waypointScript _monitoredWp
		};
		private _positionDistance = if (!_wpExists) then {
			1e10
		} else {
			_monitoredPosition distance2D (waypointPosition _monitoredWp)
		};

		private _runStillCurrent = !isNull _monitoredGroup
			&& {local _monitoredGroup}
			&& {_wpExists}
			&& {
				(_monitoredGroup getVariable [
					"A3C_REPAIR_WP_RUN_ID",
					-1
				]) == _monitoredRunID
			}
			&& {(currentWaypoint _monitoredGroup) == _monitoredWpIndex}
			&& {(waypointType _monitoredWp) == "SCRIPTED"}
			&& {
				(toLower _scriptPath) find "wpscript_repair.sqf" >= 0
			}
			&& {_positionDistance <= 3};

		if (!_runStillCurrent) then {

			{
				_x params ["_actor", "_animHandlerID"];
				if (!isNull _actor) then {
					if (_animHandlerID >= 0) then {
						_actor removeEventHandler [
							"AnimDone",
							_animHandlerID
						];
					};

					private _control = _actor getVariable [
						"A3C_REPAIR_ANIMATION_CONTROL",
						[]
					];
					if (
						_control isEqualType []
						&& {(_control param [1, -2]) == _animHandlerID}
					) then {
						_actor setVariable [
							"A3C_REPAIR_ANIMATION_CONTROL",
							nil
						];
					};

					if (
						alive _actor
						&& {local _actor}
						&& {!isPlayer _actor}
						&& {isNull objectParent _actor}
					) then {
						private _resetAnimation = if (
							(toLower (animationState _actor)) find "repairvehicleknl" >= 0
						) then {
							"AmovPknlMstpSnonWnonDnon"
						} else {
							"AmovPercMstpSnonWnonDnon"
						};

						_actor playMoveNow _resetAnimation;
						_actor enableAI "ANIM";
						_actor setUnitPos "AUTO";
						_actor lookAt objNull;

						private _actorGroup = group _actor;
						if (!isNull _actorGroup) then {
							_actor doFollow (leader _actorGroup);
						};
					};
				};
			} forEach (+_ownedEntries);

			_ownedEntries resize 0;
			missionNamespace setVariable [_monitorKey, nil];
			removeMissionEventHandler ["EachFrame", _thisEventHandler];
		};
	}
];

_animationCleanupMonitorKey = format [
	"A3C_REPAIR_ANIMATION_MONITOR_%1",
	_animationCleanupMonitorID
];
missionNamespace setVariable [
	_animationCleanupMonitorKey,
	_animationCleanupMonitorState
];


private _fnc_stopAnimationCleanupMonitor = {
	params [["_reason", "normal script exit"]];
	removeMissionEventHandler [
		"EachFrame",
		_animationCleanupMonitorID
	];
	missionNamespace setVariable [
		_animationCleanupMonitorKey,
		nil
	];
};

// A short, self-expiring lease keeps two independently local repair groups
// from working on the same patient. If this script is killed without cleanup,
// the lease becomes invalid by itself after five seconds.
private _fnc_hasPatientLease = {
	params ["_patient"];

	private _lease = _patient getVariable [
		"A3C_REPAIR_WP_LEASE",
		[grpNull, -1, -1]
	];

	(_lease param [0, grpNull]) isEqualTo _group
	&& {(_lease param [1, -1]) == _runID}
	&& {(_lease param [2, -1]) > serverTime}
};

private _fnc_renewPatientLease = {
	params ["_patient"];

	_patient setVariable [
		"A3C_REPAIR_WP_LEASE",
		[_group, _runID, serverTime + 5],
		true
	];
};

private _fnc_releasePatientLease = {
	params ["_patient"];

	if (!isNull _patient && {[_patient] call _fnc_hasPatientLease}) then {
		_patient setVariable [
			"A3C_REPAIR_WP_LEASE",
			[grpNull, -1, -1],
			true
		];
	};
};

// Wait for the group leader/platform to reach the repair waypoint. The leader
// and its current vehicle are resolved on every check instead of being cached.
private _arrivalCancelled = false;
private _arrived = false;
private _nextApproachOrder = 0;


waitUntil {
	sleep 0.25;

	if !(call _fnc_isRepairRunCurrent) exitWith {
		_arrivalCancelled = true;
		true
	};

	private _aliveUnits = units _group select {alive _x};
	if (_aliveUnits isEqualTo []) exitWith {
		_arrivalCancelled = true;
		true
	};

	private _currentLeader = leader _group;
	if (!alive _currentLeader) then {
		_currentLeader = _aliveUnits select 0;
	};

	private _leaderPlatform = vehicle _currentLeader;
	private _precision = (
		getNumber (
			configFile
			>> "CfgVehicles"
			>> typeOf _leaderPlatform
			>> "precision"
		)
	) * 1.3 + 20;
	private _leaderDistance = _leaderPlatform distance2D _pos;

	if (_leaderDistance < _precision) exitWith {
		_arrived = true;
		true
	};

	if (time >= _nextApproachOrder) then {
		[_group, _pos]
			call A3C_ai_shared_fnc_approachWaypointRegular;
		_nextApproachOrder = time + 5;
	};

	false
};

if (_arrivalCancelled || {!_arrived}) exitWith {
	true
};

// Resolve the waypoint precondition after arrival, in this waypoint script's
// own scheduled scope. Every wait also observes the current repair-run identity.
_preCondition params ["_conditionType", "_conditionValue"];

private _preConditionCode = {true};
switch (toUpper _conditionType) do {
	case "TIMEOUT": {
		private _completionTime = time + _conditionValue;
		_preConditionCode = compile format [
			"time >= %1",
			_completionTime
		];
	};

	case "GOCODE": {
		private _activationVariable = [
			_conditionValue,
			side _group
		] call A3C_main_fnc_getGoCodeActivationVariableName;

		_preConditionCode = compile format [
			"missionNamespace getVariable [%1, false]",
			str _activationVariable
		];
	};

	case "DAYTIME": {
		private _daytimeArguments = [];
		{
			_daytimeArguments pushBack (parseNumber _x);
		} forEach (_conditionValue splitString ":");

		_preConditionCode = compile format [
			"%1 call A3C_main_fnc_isDaytimeCompleted",
			_daytimeArguments
		];
	};
};


waitUntil {
	sleep 0.25;
	private _isCurrent = call _fnc_isRepairRunCurrent;
	private _isComplete = call _preConditionCode;

	!_isCurrent || {_isComplete}
};

if !(call _fnc_isRepairRunCurrent) exitWith {
	true
};


if !((toUpper _conditionType) in ["ARRIVAL", ""]) then {
	private _wp = [_group, _wpIndex];

	_wp setWaypointScript format [
		"A3C_CORE\waypointScripts\wpScript_repair.sqf [%1,%2]",
		str _callerUID,
		["ARRIVAL", 0]
	];
	_wp setWaypointPosition [_pos, 0];

	private _statements = waypointStatements _wp;
	_statements set [0, "true"];
	_wp setWaypointStatements _statements;
};

private _visualRepairKeywords = [
	"hull",
	"glass",
	"track",
	"wheel",
	"engine",
	"turret",
	"gun",
	"light",
	"body",
	"rotor",
	"transmission"
];

// These repair states require animation AI to be disabled and must be started
// with switchMove. Cleanup always requests a normal standing/kneeling state
// with playMoveNow before re-enabling animation AI.
private _repairAnimations = [
	"inbasemoves_assemblingvehicleerc",
	"inbasemoves_repairvehicleknl"
];

private _fnc_getRepairAnimationTiming = {
	params ["_animation"];
	private _state = configFile
		>> "CfgMovesMaleSdr"
		>> "States"
		>> _animation;
	private _speed = getNumber (_state >> "speed");
	// In CfgMoves a negative speed is the requested duration in seconds,
	// multiplied by -1. A positive speed is a playback multiplier and does not
	// expose the source RTM's duration, so the fallback timer remains authoritative
	// if the state does not emit AnimDone.
	private _configuredDuration = if (_speed < 0) then {
		abs _speed
	} else {
		-1
	};

	[_speed, _configuredDuration]
};


private _fnc_updateRepairAnimations = {
	params ["_actors", "_patient", "_controllers", ["_reason", "tick"]];

	{
		private _actor = _x;
		if (
			!isNull _actor
			&& {alive _actor}
			&& {local _actor}
			&& {!isPlayer _actor}
			&& {isNull objectParent _actor}
		) then {
			private _controllerIndex = _controllers findIf {
				(_x select 0) isEqualTo _actor
			};

			if (_controllerIndex < 0) then {
				private _handlerID = _actor addEventHandler [
					"AnimDone",
					{
						params ["_unit", "_completedAnimation"];
						private _control = _unit getVariable [
							"A3C_REPAIR_ANIMATION_CONTROL",
							[]
						];

						if (
							_control isEqualType []
							&& {count _control > 5}
							&& {
								(_control param [1, -2])
									== _thisEventHandler
							}
							&& {
								(toLower (_control param [2, ""]))
									isEqualTo (toLower _completedAnimation)
							}
						) then {
							_control set [3, true];
							_unit setVariable [
								"A3C_REPAIR_ANIMATION_CONTROL",
								_control
							];
						};
					}
				];

				private _control = [
					_runID,
					_handlerID,
					"",
					true,
					0,
					0
				];
				_actor setVariable [
					"A3C_REPAIR_ANIMATION_CONTROL",
					_control
				];
				_controllers pushBack [_actor, _handlerID];
				_animationCleanupEntries pushBack [
					_actor,
					_handlerID
				];
				missionNamespace setVariable [
					_animationCleanupMonitorKey,
					_animationCleanupMonitorState
				];
				_controllerIndex = (count _controllers) - 1;

			};

			private _controller = _controllers select _controllerIndex;
			private _handlerID = _controller select 1;
			private _control = _actor getVariable [
				"A3C_REPAIR_ANIMATION_CONTROL",
				[]
			];

			if (
				_control isEqualType []
				&& {count _control > 5}
				&& {(_control param [0, -1]) == _runID}
				&& {(_control param [1, -2]) == _handlerID}
			) then {
				private _currentAnimation = _control param [2, ""];
				private _animationFinished = _control param [3, true];
				private _nextAnimationAt = _control param [5, 0];

				if (
					_animationFinished
					|| {time >= _nextAnimationAt}
				) then {
					private _candidates = _repairAnimations select {
						(toLower _x) != (toLower _currentAnimation)
					};
					if (_candidates isEqualTo []) then {
						_candidates = +_repairAnimations;
					};

					private _nextAnimation = selectRandom _candidates;
					private _timing = [
						_nextAnimation
					] call _fnc_getRepairAnimationTiming;
					private _configSpeed = _timing select 0;
					private _configuredDuration = _timing select 1;
					private _scheduledAdvance = if (
						_configuredDuration > 0
					) then {
						time + (0.75 max (_configuredDuration - 0.15))
					} else {
						// Positive config speed is a multiplier. AnimDone normally
						// advances the sequence; this is only a stuck-state watchdog.
						time + 8
					};

					_control set [2, _nextAnimation];
					_control set [3, false];
					_control set [4, time];
					_control set [5, _scheduledAdvance];
					_actor setVariable [
						"A3C_REPAIR_ANIMATION_CONTROL",
						_control
					];

					[_actor, position _patient] spawn A3C_ai_shared_fnc_rotateVehicleTowardsPos;
					_actor disableAI "ANIM";
					[_actor, _nextAnimation] remoteExec ["switchMove", 0]; //-- switchmove needs to be executed globally

				};
			};
		};
	} forEach _actors;
};

private _fnc_stopRepairAnimationControllers = {
	params ["_controllers", ["_reason", "unspecified"]];
	private _actorsToReset = [];


	{
		_x params ["_actor", "_handlerID"];
		if (!isNull _actor) then {
			if (_handlerID >= 0) then {
				_actor removeEventHandler ["AnimDone", _handlerID];
			};

			private _control = _actor getVariable [
				"A3C_REPAIR_ANIMATION_CONTROL",
				[]
			];
			if (
				_control isEqualType []
				&& {(_control param [1, -2]) == _handlerID}
			) then {
				_actor setVariable [
					"A3C_REPAIR_ANIMATION_CONTROL",
					nil
				];
			};

			_actorsToReset pushBackUnique _actor;
		};

		private _cleanupIndex = _animationCleanupEntries findIf {
			(_x select 0) isEqualTo _actor
			&& {(_x select 1) == _handlerID}
		};
		if (_cleanupIndex >= 0) then {
			_animationCleanupEntries deleteAt _cleanupIndex;
		};
	} forEach (+_controllers);

	_controllers resize 0;
	missionNamespace setVariable [
		_animationCleanupMonitorKey,
		_animationCleanupMonitorState
	];
	[_actorsToReset, _reason] call _fnc_resetRepairActors;

};

// Only one-shot sounds are used. A sound which has already started may finish
// after cancellation, but no loop or helper object remains alive.
private _repairSounds = [
	"assemble_target",
	"Land_Carrier_01_wire_snap_sound",
	"UAV_05_tailhook_down_sound",
	"vr_goggles",
	"electricity_loop"
];
private _wheelSounds = [
	"assemble_target",
	"Land_Carrier_01_wire_snap_sound"
];

// Enemy suppression of an on-foot actor who is actively repairing aborts the
// complete repair waypoint. Vehicle-borne repair actors intentionally do not
// trigger this.
private _fnc_isRepairActorSuppressed = {
	params ["_actors"];

	{
		!isNull _x
		&& {alive _x}
		&& {local _x}
		&& {!isPlayer _x}
		&& {isNull objectParent _x}
		&& {getSuppression _x > 0.1}
	} count _actors > 0
};

private _cancelled = false;
private _finished = false;
private _processedPatients = [];
private _movementUnitsUsed = [];

while {!_cancelled && {!_finished}} do {
	if !(call _fnc_isRepairRunCurrent) then {
		_cancelled = true;
	} else {
		private _repairUnits = units _group select {
			alive _x
			&& {[_x] call A3C_main_fnc_canRepair}
		};


		// One repair actor per occupied platform prevents several eligible crew
		// members from issuing competing movement orders to the same vehicle.
		private _repairActors = [];
		private _usedPlatforms = [];
		{
			private _platform = vehicle _x;
			private _onFoot = isNull objectParent _x;

			if (_onFoot || {!(_platform in _usedPlatforms)}) then {
				_repairActors pushBack _x;
				if (!_onFoot) then {
					_usedPlatforms pushBack _platform;
				};
			};
		} forEach _repairUnits;


		if (_repairActors isEqualTo []) then {
			_finished = true;
		} else {
			private _nearbyVehicles = (
				_pos nearEntities [
					["Car", "Motorcycle", "Tank", "Air"],
					100
				]
			);


			private _patients = _nearbyVehicles select {
				alive _x
				&& {!(_x in _processedPatients)}
				&& {
					private _lease = _x getVariable [
						"A3C_REPAIR_WP_LEASE",
						[grpNull, -1, -1]
					];
					(_lease param [0, grpNull]) isEqualTo _group
					|| {(_lease param [2, -1]) <= serverTime}
				}
				&& {
					[side _group, _x]
						call A3C_main_fnc_isVehicleDamaged
				}
			};


			_patients = [
				_patients,
				[],
				{_x distance2D _pos},
				"ASCEND"
			] call BIS_fnc_sortBy;

			if (_patients isEqualTo []) then {
				_finished = true;
			} else {
				private _patient = _patients select 0;
				_processedPatients pushBack _patient;
				[_patient] call _fnc_renewPatientLease;

				_repairActors = [
					_repairActors,
					[],
					{(vehicle _x) distance2D _patient},
					"ASCEND"
				] call BIS_fnc_sortBy;


				private _allHitPoints = getAllHitPointsDamage _patient;
				private _hitPointNames = _allHitPoints param [0, []];
				private _selectionNames = _allHitPoints param [1, []];
				private _hitPointValues = _allHitPoints param [2, []];

				private _visualTasks = [];
				private _finalHitPointRepairs = [];
				private _completedHitPointRepairs = [];


				{
					private _hitPoint = _x;
					private _selection = _selectionNames param [_forEachIndex, ""];
					private _damage = _hitPointValues param [_forEachIndex, 0];

					if (_damage > 0.15) then {
						private _hitPointLower = toLower _hitPoint;
						private _isVisual = {
							_x in _hitPointLower
						} count _visualRepairKeywords > 0;

						if (_isVisual) then {
							_visualTasks pushBack [
								_hitPoint,
								_selection,
								_damage,
								("wheel" in _hitPointLower)
							];
						} else {
							_finalHitPointRepairs pushBack [
								_hitPoint,
								0
							];
						};
					};
				} forEach _hitPointNames;


				// Always show at least one visible repair action for an object which
				// the damage predicate selected, even if it has no visual hitpoint
				// above the long-repair threshold.
				if (_visualTasks isEqualTo []) then {
					_visualTasks pushBack [
						"",
						"",
						damage _patient,
						false
					];
				};

				// Send every eligible repair actor toward this patient together. The
				// leader reaching the waypoint does not allow trailing engineers to
				// repair remotely; only actors which physically arrive are retained.
				private _approachEntries = [];
				private _patientRadius = 2 max (
					0.5 * (sizeOf (typeOf _patient))
				);
				{
					private _actor = _x;
					private _platform = vehicle _actor;
					private _onFoot = isNull objectParent _actor;
					private _mover = if (_onFoot) then {
						_actor
					} else {
						driver _platform
					};


					if (
						!isNull _mover
						&& {alive _mover}
						&& {!isPlayer _mover}
						&& {group _mover isEqualTo _group}
					) then {
						private _platformRadius = if (_onFoot) then {
							0
						} else {
							1 max (0.5 * (sizeOf (typeOf _platform)))
						};
						private _arrivalMargin = if (_onFoot) then {3} else {8};
						private _destinationMargin = if (_onFoot) then {1.5} else {5};
						private _arrivalDistance = _patientRadius
							+ _platformRadius
							+ _arrivalMargin;
						private _destinationDistance = _patientRadius
							+ _platformRadius
							+ _destinationMargin;
						private _destination = _patient getPos [
							_destinationDistance,
							_patient getDir _platform
						];


						_mover doMove _destination;
						_mover moveTo _destination;
						_movementUnitsUsed pushBackUnique _mover;

						_approachEntries pushBack [
							_actor,
							_mover,
							_platform,
							_arrivalDistance,
							_destination
						];
					};
				} forEach _repairActors;


				// Do not let one pathfinding failure suppress every repairer. Once the
				// first actor arrives, allow a short assembly window for stragglers.
				// Non-arrived actors remain ineligible and keep their approach order.
				private _approachDeadline = time + 60;
				private _firstArrivalTime = -1;
				private _nextApproachRefresh = 0;
				private _approachExitReason = "";
				private _patientUnavailable = false;
				private _arrivedActors = [];
				// Once an actor has genuinely entered the arrival radius, keep that
				// fact latched. A few metres of AI stance/formation jitter must not
				// remove the actor again. The larger distance below is still enforced
				// before assignment and commit, so nobody repairs remotely.
				private _arrivalHysteresis = 4;


				waitUntil {
					sleep 0.25;

					if !(call _fnc_isRepairRunCurrent) exitWith {
						_approachExitReason = "repair run invalidated";
						_cancelled = true;
						true
					};

					if (
						isNull _patient
						|| {!alive _patient}
						|| {speed _patient > 2}
						|| {!([_patient] call _fnc_hasPatientLease)}
					) exitWith {
						_approachExitReason = format [
							"patient unavailable: null=%1 alive=%2 speed=%3 leaseOwned=%4 lease=%5",
							isNull _patient,
							if (isNull _patient) then {false} else {alive _patient},
							if (isNull _patient) then {-1} else {speed _patient},
							if (isNull _patient) then {false} else {[_patient] call _fnc_hasPatientLease},
							if (isNull _patient) then {[]} else {_patient getVariable ["A3C_REPAIR_WP_LEASE", []]}
						];
						_patientUnavailable = true;
						true
					};

					[_patient] call _fnc_renewPatientLease;

					{
						_x params [
							"_actor",
							"_mover",
							"_platform",
							"_arrivalDistance"
						];

						if (
							alive _actor
							&& {alive _mover}
							&& {
								(_platform distance2D _patient)
									<= _arrivalDistance
							}
							&& {!(_actor in _arrivedActors)}
						) then {
							_arrivedActors pushBackUnique _actor;
						};
					} forEach _approachEntries;

					private _arrivedCount = {
						_x params [
							"_actor",
							"_mover",
							"_platform",
							"_arrivalDistance"
						];

						alive _actor
							&& {alive _mover}
							&& {_actor in _arrivedActors}
					} count _approachEntries;

					if (_arrivedCount > 0 && {_firstArrivalTime < 0}) then {
						_firstArrivalTime = time;
					};

					if (time >= _nextApproachRefresh) then {
						{
							_x params [
								"_actor",
								"_mover",
								"_platform",
								"_arrivalDistance",
								"_destination"
							];

							if (
								alive _actor
								&& {alive _mover}
								&& {
									!(_actor in _arrivedActors)
									|| {
										(_platform distance2D _patient)
											> (_arrivalDistance + _arrivalHysteresis)
									}
								}
							) then {
								_mover doMove _destination;
								_mover moveTo _destination;
							};
						} forEach _approachEntries;

						_nextApproachRefresh = time + 3;
					};

					private _unresolvedCount = {
						_x params [
							"_actor",
							"_mover",
							"_platform",
							"_arrivalDistance"
						];

						alive _actor
							&& {alive _mover}
							&& {!(_actor in _arrivedActors)}
					} count _approachEntries;

					if (_unresolvedCount == 0) exitWith {
						_approachExitReason = "all living repair entries arrived or resolved";
						true
					};

					if (time >= _approachDeadline) exitWith {
						_approachExitReason = "60-second approach deadline reached";
						true
					};

					if (
						_firstArrivalTime >= 0
						&& {time >= (_firstArrivalTime + 5)}
					) exitWith {
						_approachExitReason = "five-second assembly window completed";
						true
					};

					false
				};


				private _patientAnimationControllers = [];

				if (!_cancelled && {!_patientUnavailable}) then {
					private _activeEntries = _approachEntries select {
						_x params [
							"_actor",
							"_mover",
							"_platform",
							"_arrivalDistance"
						];

						alive _actor
							&& {alive _mover}
							&& {_actor in _arrivedActors}
							&& {
								(_platform distance2D _patient)
									<= (_arrivalDistance + _arrivalHysteresis)
							}
					};


					if !(_activeEntries isEqualTo []) then {
						// Give every admitted repairer one last second to close on its
						// already calculated near-surface destination. Then stop its
						// mover so group formation updates do not drag an animating unit
						// around the patient. Patient/script cleanup restores doFollow.
						{
							_x params [
								"_actor",
								"_mover",
								"_platform",
								"_arrivalDistance",
								"_destination"
							];
							_mover doMove _destination;
							_mover moveTo _destination;
						} forEach _activeEntries;

						sleep 1;
						if !(call _fnc_isRepairRunCurrent) then {
							_cancelled = true;
						};

						{
							_x params [
								"_actor",
								"_mover",
								"_platform",
								"_arrivalDistance",
								"_destination"
							];
							if (
								alive _mover
								&& {!isPlayer _mover}
								&& {isNull objectParent _actor}
								&& {
									(_platform distance2D _patient)
										<= (_arrivalDistance + _arrivalHysteresis)
								}
							) then {
								doStop _mover;
							};
						} forEach _activeEntries;

						private _repairerNames = (
							_activeEntries apply {
								name (_x select 0)
							}
						) joinString ", ";
						private _patientName = getText (
							configFile
							>> "CfgVehicles"
							>> typeOf _patient
							>> "displayName"
						);

						[
							format [
								"A3C: %1 (%2) started repairing a %3.",
								_repairerNames,
								groupID _group,
								_patientName
							]
						] call _fnc_sendFeedback;

						private _tasks = +_visualTasks;
						private _repairInterrupted = false;
						private _repairRound = 0;

						while {
							!_cancelled
							&& {!_repairInterrupted}
							&& {!(_tasks isEqualTo [])}
						} do {
							_repairRound = _repairRound + 1;
							// Actors which arrive during the repair can join subsequent
							// rounds, but proximity is checked before every assignment.
							{
								_x params [
									"_actor",
									"_mover",
									"_platform",
									"_arrivalDistance",
									"_destination"
								];

								if (
									alive _actor
									&& {alive _mover}
									&& {
										(_platform distance2D _patient)
											<= _arrivalDistance
									}
									&& {!(_actor in _arrivedActors)}
								) then {
									_arrivedActors pushBackUnique _actor;
								};

								if (
									alive _actor
									&& {alive _mover}
									&& {_actor in _arrivedActors}
									&& {
										(_platform distance2D _patient)
											> (_arrivalDistance + _arrivalHysteresis)
									}
								) then {
									_mover doMove _destination;
									_mover moveTo _destination;
								};
							} forEach _approachEntries;

							_activeEntries = _approachEntries select {
								_x params [
									"_actor",
									"_mover",
									"_platform",
									"_arrivalDistance"
								];

								alive _actor
									&& {alive _mover}
									&& {_actor in _arrivedActors}
									&& {
										(_platform distance2D _patient)
											<= (_arrivalDistance + _arrivalHysteresis)
									}
							};


							[
								_activeEntries apply {_x select 0},
								_patient,
								_patientAnimationControllers,
								format ["round %1 start", _repairRound]
							] call _fnc_updateRepairAnimations;

							private _roundAssignments = [];
							private _roundDuration = 0;

							{
								if (_tasks isEqualTo []) exitWith {};

								_x params [
									"_actor",
									"_mover",
									"_platform",
									"_arrivalDistance"
								];

								if (
									alive _actor
									&& {alive _mover}
									&& {
										(_platform distance2D _patient)
											<= (_arrivalDistance + _arrivalHysteresis)
									}
								) then {
									private _task = _tasks deleteAt 0;
									private _isWheel = _task select 3;
									private _duration = if (_isWheel) then {
										5
									} else {
										2
									};

									private _sound = selectRandom (
										if (_isWheel) then {
											_wheelSounds
										} else {
											_repairSounds
										}
									);
									[
										_platform,
										_sound
									] call _fnc_playRepairSound;


									_roundDuration = _roundDuration max _duration;
									_roundAssignments pushBack [
										_actor,
										_platform,
										_arrivalDistance,
										_task
									];
								};
							} forEach _activeEntries;


							if (_roundAssignments isEqualTo []) then {
								_repairInterrupted = true;
							} else {
								private _roundEnd = time + _roundDuration;
								private _roundExitReason = "duration completed";

								waitUntil {
									sleep 0.1;

									if !(call _fnc_isRepairRunCurrent) exitWith {
										_roundExitReason = "repair run invalidated";
										_cancelled = true;
										true
									};

									if (
										[
											_activeEntries apply {_x select 0}
										] call _fnc_isRepairActorSuppressed
									) exitWith {
										_roundExitReason = "on-foot repair actor suppressed";
										_cancelled = true;

										private _wp = [_group, _wpIndex];
										if (_wp in (waypoints _group)) then {
											deleteWaypoint _wp;
										};

										true
									};

									if (
										isNull _patient
										|| {!alive _patient}
										|| {speed _patient > 2}
										|| {!([_patient] call _fnc_hasPatientLease)}
									) exitWith {
										_roundExitReason = format [
											"patient invalid: null=%1 alive=%2 speed=%3 leaseOwned=%4 lease=%5",
											isNull _patient,
											if (isNull _patient) then {false} else {alive _patient},
											if (isNull _patient) then {-1} else {speed _patient},
											if (isNull _patient) then {false} else {[_patient] call _fnc_hasPatientLease},
											if (isNull _patient) then {[]} else {_patient getVariable ["A3C_REPAIR_WP_LEASE", []]}
										];
										_repairInterrupted = true;
										true
									};

									[_patient] call _fnc_renewPatientLease;
									[
										_activeEntries apply {_x select 0},
										_patient,
										_patientAnimationControllers,
										format ["round %1 wait", _repairRound]
									] call _fnc_updateRepairAnimations;

									time >= _roundEnd
								};


								if (!_cancelled && {!_repairInterrupted}) then {
									private _roundRepairs = [];
									{
										_x params [
											"_actor",
											"_platform",
											"_arrivalDistance",
											"_task"
										];

										if (
											alive _actor
											&& {
												(_platform distance2D _patient)
													<= (_arrivalDistance + _arrivalHysteresis)
											}
										) then {
											private _hitPoint = _task select 0;
											if (_hitPoint != "") then {
												_roundRepairs pushBack [
													_hitPoint,
													0.1
												];
												_completedHitPointRepairs pushBackUnique [
													_hitPoint,
													0.1
												];
											};
										} else {
											_tasks pushBack (_task);
										};
									} forEach _roundAssignments;

									[
										_patient,
										_roundRepairs
									] call _fnc_applyHitPointRepairs;
								};
							};
						};

						if (
							!_cancelled
							&& {!_repairInterrupted}
							&& {!isNull _patient}
							&& {alive _patient}
							&& {[_patient] call _fnc_hasPatientLease}
						) then {
							private _overallDamage = 0.1 min (damage _patient);
								private _wasFlipped = [_patient]
									call MCSS_fnc_isObjectFlipped;

							[
								_patient,
								_overallDamage,
								_completedHitPointRepairs
									+ _finalHitPointRepairs,
								_wasFlipped
							] call _fnc_finalizePatient;

							[
								format [
									"A3C: %1 (%2) finished repairing a %3.",
									_repairerNames,
									groupID _group,
									_patientName
								]
							] call _fnc_sendFeedback;
						};
					};
				};

				[
					_patientAnimationControllers,
					format ["patient cleanup: %1", _patient]
				] call _fnc_stopRepairAnimationControllers;
				[
					_approachEntries apply {_x select 0},
					format ["patient cleanup: %1", _patient]
				] call _fnc_resetRepairActors;
				[
					_approachEntries apply {_x select 1}
				] call _fnc_releaseMovers;
				[_patient] call _fnc_releasePatientLease;
			};
		};
	};
};


// This runs for normal completion and explicit cancellation checks. If the
// engine terminates the waypoint script itself, the self-removing EachFrame
// monitor above owns these same handler IDs and performs this reset instead.
[
	_animationCleanupEntries,
	"script boundary cleanup"
] call _fnc_stopRepairAnimationControllers;
["script boundary cleanup"] call _fnc_stopAnimationCleanupMonitor;
[_movementUnitsUsed] call _fnc_releaseMovers;


true

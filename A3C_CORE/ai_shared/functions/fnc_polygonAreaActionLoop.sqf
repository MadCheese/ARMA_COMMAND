// A3C_ai_shared_fnc_polygonAreaActionLoop
// Note/trick: in order to make the unit fire no matter what, set the height to 1000.

params ["_unit"];

private _vehicle = vehicle _unit;

if (isPlayer _unit) exitWith {};

private _exit = false;

while {
	alive _unit
	&& {_unit getVariable ["A3C_POLY_ACTION_ACTIVE", false]}
} do {
	if (!isNull objectParent _unit) then {
		_exit = true;
	} else {
		if (!isPlayer leader group _unit) then {
			if (_unit distance formationPosition _unit < 3) then {
				_exit = true;
			};
		} else {
			_exit = true;
		};
	};

	if (_exit) exitWith {};

	sleep 0.1;
};

/*
	The action may have been cancelled while an infantry unit was waiting
	to reach its formation position.
*/
if !(_unit getVariable ["A3C_POLY_ACTION_ACTIVE", false]) exitWith {};

if (_vehicle isKindOf "PLANE") exitWith {
	_unit setVariable [
		"A3C_POLY_ACTION_ACTIVE",
		false,
		true
	];
};

if !(alive _unit) exitWith {
	_unit setVariable [
		"A3C_POLY_ACTION_ACTIVE",
		false,
		true
	];
};

private _mode = _this select 1;
private _polyMarker = _this select 2;
private _target = if ((count _this) > 3) then {
	_this select 3
} else {
	objNull
};

private _groupPlayer = _unit in (units player);
private _actual = if (_groupPlayer) then {
	_unit
} else {
	group _unit
};

private _getCurrentPolygon = {
	params [
		"_polygonOwner",
		"_polygonMarkerId"
	];

	private _currentPolygons =
		_polygonOwner getVariable [
			"A3C_UNIT_POLYS",
			[]
		];

	private _polygonIndex =
		_currentPolygons findIf {
			((_x select 0) select 1)
				== _polygonMarkerId
		};

	if (_polygonIndex == -1) exitWith {
		[]
	};

	+(_currentPolygons select _polygonIndex)
};

private _getPolygonGeometrySignature = {
	params [
		["_polygon", [], [[]]]
	];

	if ((count _polygon) < 2) exitWith {
		""
	};

	private _metadata = _polygon select 0;
	private _corners = _polygon select 1;

	if (
		_metadata isEqualTo []
		|| {_corners isEqualTo []}
	) exitWith {
		""
	};

	str [
		+(_metadata select 0),
		_corners apply {
			+_x
		}
	]
};

private _polys = [];
private _polyID = -1;
private _exitMain = true;

private _restrictiveArray = profileNamespace getVariable ["A3C_SUP_RESTRICTIVE", ["UNLIMITED", 0]];
private _restrictiveType = _restrictiveArray select 0;
private _restrictiveValue = _restrictiveArray select 1;

private _usedMagazine = currentMagazine _unit;

private _restrictiveOrigin = switch (_restrictiveType) do {
	case "UNLIMITED": {
		0
	};

	case "MAGAZINE": {
		{ _x == _usedMagazine } count magazines _unit
	};

	case "PERCENTAGE": {
		round (({ _x == _usedMagazine } count magazines _unit) * (_restrictiveValue / 100))
	};

	case "TIME": {
		time
	};
};

private _restrictiveFnc = switch (_restrictiveType) do {
	case "UNLIMITED": {
		{ false }
	};

	case "MAGAZINE": {
		{
			params ["_usedMagazine", "_restrictiveOrigin", "_restrictiveValue"];

			private _magCount = { _x == _usedMagazine } count magazines _unit;

			_magCount <= ((_restrictiveOrigin - _restrictiveValue) max 1)
		}
	};

	case "PERCENTAGE": {
		{
			params ["_usedMagazine", "_restrictiveOrigin", "_restrictiveValue"];

			private _magCount = { _x == _usedMagazine } count magazines _unit;

			_magCount <= (_restrictiveOrigin max 1)
		}
	};

	case "TIME": {
		{
			params ["_usedMagazine", "_restrictiveOrigin", "_restrictiveValue"];

			time > _restrictiveOrigin + _restrictiveValue
		}
	};
};

// If unit has AI leader and waypoints, waypoint conditions override restrictions.
if !(isPlayer leader group _unit) then {
	if ((count waypoints group _unit) > 0) then {
		_restrictiveFnc = { false };
	};
};

// If unit has squad-level waypoints assigned, waypoint conditions override restrictions.
if ((count (_unit getVariable ["A3C_PLOT", []])) > 0) then {
	_restrictiveFnc = { false };
};

private _exitRestrictive = false;

switch (_mode) do {
	case "SUPPRESSION": {
		private _suppressionDisabledAI = [];
		private _suppressionOwnsSpeedLimit = false;

		private _disableSuppressionAIFeature = {
			params ["_entity", "_feature"];

			if (isNull _entity) exitWith {};

			/*
				Record only features that suppression actually disables.
				Pre-existing disabled states must remain disabled afterward.
			*/
			if (_entity checkAIFeature _feature) then {
				[
					_entity,
					_feature
				] remoteExecCall ["disableAI", _entity];

				_suppressionDisabledAI pushBackUnique [
					_entity,
					_feature
				];
			};
		};

		// Put in AWARE.
		if !(isPlayer leader group _unit) then {
			if !(behaviour _unit in ["AWARE", "COMBAT"]) then {
				[leader group _unit, "AWARE"] remoteExec ["setBehaviour", leader group _unit];
			};
		};

		(vehicle _unit) setVariable ["A3C_AIM_ADJUST", 0, true];

		private _targetFnc = {
			params ["_unit", "_target"];

			if (
				isNull _unit
				|| {isNull _target}
			) exitWith {};

			private _targetPos = position _target;

			[
				[
					_unit,
					_target,
					_targetPos
				],
				{
					params [
						"_unit",
						"_target",
						"_targetPos"
					];

					if (
						isNull _unit
						|| {isNull _target}
					) exitWith {};

					_unit reveal [_target, 4];
					_unit doTarget _target;

					if (isNull objectParent _unit) then {
						_unit doWatch _target;
					} else {
						_unit lookAt objNull;
						_unit lookAt _targetPos;
					};
				}
			] remoteExecCall [
				"BIS_fnc_call",
				_unit
			];
		};

		private _canContinueSuppression = {
			!_exitRestrictive
			&& {!isNull _target}
			&& {alive _unit}
			&& {
				_unit getVariable [
					"A3C_POLY_ACTION_ACTIVE",
					false
				]
			}
			&& {
				(
					[
						_actual,
						_polyMarker
					] call _getCurrentPolygon
				) isNotEqualTo []
			}
		};

		private _lastAcceptedPolygonGeometrySignature = "";

		while {
			!isNull _target
			&& {alive _unit}
			&& {_unit getVariable ["A3C_POLY_ACTION_ACTIVE", false]}
		} do {
			if (isNull _unit) exitWith {};
			if (!alive _unit) exitWith {};

			private _currentPolygon = [
				_actual,
				_polyMarker
			] call _getCurrentPolygon;

			if (_currentPolygon isEqualTo []) exitWith {};

			if (_exitRestrictive) exitWith {
				[[_unit], "SUPPRESSION"] call A3C_ai_shared_fnc_polygonAreaActionOff;

				_unit groupChat (
					[
						"SUPPRESSION COMPLETE!",
						"SUPPRESSION COMPLETE!",
						"I'M DONE SUPPRESSING",
						"I'M NO LONGER SUPPRESSING!"
					] call BIS_fnc_selectRandom
				);
			};

			private _pos = [];
			private _cycle = 0;

			_polys = _actual getVariable ["A3C_UNIT_POLYS", []];

			private _polygon = [];
			_exitMain = true;

			{
				if (((_x select 0) select 1) == _polyMarker) exitWith {
					_polygon = +_x;
					_exitMain = false;
				};
			} forEach _polys;

			if (_exitMain) exitWith {};

			private _polygonGeometrySignature = [_polygon] call _getPolygonGeometrySignature;

			private _center = (_polygon select 0) select 0;
			_polyID = if ((count (_polygon select 0)) > 2) then {
				(_polygon select 0) select 2
			} else {
				-1
			};

			private _polygonData = _polygon select 1;
			private _height = _center select 2;

			_center = ATLToASL _center;

			private _heightASL = ((ATLToASL _center) select 2) + 0.7;
			private _radius = 0;

			{
				private _distance = _x distance2D _center;

				if (_distance > _radius) then {
					_radius = _distance;
				};
			} forEach _polygonData;

			if (!isPlayer leader group _unit) then {
				if (isNull objectParent _unit) then {
					_unit setUnitPos "MIDDLE";
				};
			};

			while {
				!isNull _target
				&& {alive _unit}
				&& {_unit getVariable ["A3C_POLY_ACTION_ACTIVE", false]}
			} do {
				if ([_usedMagazine, _restrictiveOrigin, _restrictiveValue] call _restrictiveFnc) exitWith {
					_exitRestrictive = true;
				};

				private _currentPolygon = [
					_actual,
					_polyMarker
				] call _getCurrentPolygon;

				if (_currentPolygon isEqualTo []) exitWith {};

				_exit = false;
				_cycle = _cycle + 1;

				if (_cycle > 300) exitWith {};

				_polys = _actual getVariable ["A3C_UNIT_POLYS", []];

				if !(_polygon in _polys) exitWith {
					if ({ ((_x select 0) select 1) == _polyMarker } count _polys == 0) then {
						_exitMain = true;
					};
				};

				_pos = [_center, _radius] call BIS_fnc_randomPosTrigger;

				if (_pos inPolygon _polygonData) then {
					_pos set [2, (_pos select 2) + 0.7];

					if ([vehicle _unit, _pos, _target, false] call MCSS_fnc_lineOfSightSimple) then {
						private _dir = [_pos, _unit] call BIS_fnc_dirTo;

						_pos = [_pos, 5, _dir] call BIS_fnc_relPos;
						_exit = true;

						if (_height >= 1) then {
							_target setPosASL _pos;
						} else {
							_target setPos ((_pos select [0, 2]) + [0]);
						};
					} else {
						private _lineIntersections = lineIntersectsSurfaces [
							[_unit] call MCSS_fnc_getViewPosASL,
							_pos,
							vehicle _unit,
							objNull
						];

						if ((count _lineIntersections) > 0) then {
							_pos = (_lineIntersections select 0) select 0;

							if (_pos inPolygon _polygonData) then {
								_exit = true;
								_height = (ASLToATL _pos) select 2;

								if (_height >= 1) then {
									_target setPosASL _pos;
								} else {
									_target setPos ((_pos select [0, 2]) + [0]);
								};
							};
						};
					};
				};

				if (_exit) exitWith {};
			};

			/*
				Arma can retain the original targeting solution when the same invisible
				target object is teleported. Give every suppressor a fresh target identity
				when a new polygon geometry is accepted.
			*/
			if (
				_exit
				&& {call _canContinueSuppression}
			) then {
				if (
					_polygonGeometrySignature
						isNotEqualTo
					_lastAcceptedPolygonGeometrySignature
				) then {
					private _oldTarget = _target;
					private _targetPositionASL = getPosASL _oldTarget;

					private _newTarget =
						"A3C_Supression_Target_F"
							createVehicle
						(ASLToAGL _targetPositionASL);

					_newTarget setPosASL _targetPositionASL;
					_newTarget enableSimulation false;

					private _targetData = +(
						_unit getVariable [
							"A3C_SUPPRESSION_TARGET",
							[
								_oldTarget,
								true,
								_polyMarker,
								-1
							]
						]
					);

					_targetData set [0, _newTarget];
					_targetData set [1, true];

					_unit setVariable [
						"A3C_SUPPRESSION_TARGET",
						_targetData,
						true
					];

					_target = _newTarget;

					deleteVehicle _oldTarget;
				};

				_lastAcceptedPolygonGeometrySignature =
					_polygonGeometrySignature;
			};

			if (
				!_exitMain
				&& {_exit}
				&& {call _canContinueSuppression}
				&& {_vehicle isKindOf "HELICOPTER"}
			) then {
				private _driver = driver _vehicle;

				if (
					!isNull _driver
					&& {!isPlayer _driver}
				) then {
					/*
						Do not overwrite a speed limit assigned through A3C.
						If no such limit exists, suppression temporarily owns
						the zero-speed limit.
					*/
					if (
						!_suppressionOwnsSpeedLimit
						&& {
							!(_vehicle getVariable [
								"A3C_LIMIT_SPEED",
								false
							])
						}
					) then {
						[
							_vehicle,
							0
						] remoteExecCall ["limitSpeed", _vehicle];

						_suppressionOwnsSpeedLimit = true;
					};

					/*
						Prevent autonomous combat decisions from competing
						with the scripted orientation and target orders.

						TARGET, MOVE, PATH, FSM and ANIM remain available.
					*/
					[
						_vehicle,
						"AUTOCOMBAT"
					] call _disableSuppressionAIFeature;

					[
						_vehicle,
						"AUTOTARGET"
					] call _disableSuppressionAIFeature;

					[
						_driver,
						"AUTOCOMBAT"
					] call _disableSuppressionAIFeature;

					

					private _currentPolygon = [
						_actual,
						_polyMarker
					] call _getCurrentPolygon;

					if (
						isNull _target
						|| {!alive _unit}
						|| {_currentPolygon isEqualTo []}
						|| {
							!(_unit getVariable [
								"A3C_POLY_ACTION_ACTIVE",
								false
							])
						}
					) then {
						_exitMain = true;
					} else {
						private _orientPos = position _target;

						private _rotateScript = [
							_vehicle,
							_orientPos,
							true
						] spawn A3C_ai_shared_fnc_rotateVehicleTowardsPos;

						waitUntil {
							sleep 0.05;

							scriptDone _rotateScript
							|| {!canMove _vehicle}
							|| {isNull _target}
							|| {!alive _unit}
							|| {
								!(_unit getVariable [
									"A3C_POLY_ACTION_ACTIVE",
									false
								])
							}
							|| {
								([
									_actual,
									_polyMarker
								] call _getCurrentPolygon) isEqualTo []
							}
						};

						if (
							isNull _target
							|| {
								([
									_actual,
									_polyMarker
								] call _getCurrentPolygon) isEqualTo []
							}
							|| {
								!(_unit getVariable [
									"A3C_POLY_ACTION_ACTIVE",
									false
								])
							}
						) then {
							_exitMain = true;
						};
					};
				};
			};

			if (_exitMain && { _groupPlayer }) exitWith {
				_unit groupChat (
					[
						"Can not comply",
						"I can't see the target",
						"Target out of sight"
					] call BIS_fnc_selectRandom
				);

				[[_unit], "SUPPRESSION"] call A3C_ai_shared_fnc_polygonAreaActionOff;
			};

			if (
				!_exitMain
				&& {!_exit}
				&& {call _canContinueSuppression}
			) then {
				sleep 0.1;
			};

			if (
				!_exitMain
				&& {_exit}
				&& {call _canContinueSuppression}
			) then {
				private _isMounted = !isNull objectParent _unit;

				// The target has a fresh identity after polygon relocation.
				[_unit, _target] call _targetFnc;

				sleep 1;

				private _firingObject = if (_isMounted) then {
					vehicle _unit
				} else {
					_unit
				};

				private _fireWeapon = "";
				private _fireMuzzle = "";
				private _fireMode = "";
				private _fireMagazine = "";
				private _fireAmmoCount = 0;
				private _turretPath = [];
				private _canFireCycle = false;

				/*
					Accept a weapon state only when it has loaded, damaging,
					non-locking ammunition.

					A3C_SUPPRESSION_FORBIDDEN remains deliberately unused.
				*/
				private _tryUseWeaponState = {
					params ["_weaponState"];

					if ((count _weaponState) < 5) exitWith {
						false
					};

					_weaponState params [
						["_stateWeapon", "", [""]],
						["_stateMuzzle", "", [""]],
						["_stateMode", "", [""]],
						["_stateMagazine", "", [""]],
						["_stateAmmoCount", 0, [0]]
					];

					if (
						_stateWeapon isEqualTo ""
						|| {_stateMuzzle isEqualTo ""}
						|| {_stateMagazine isEqualTo ""}
						|| {_stateAmmoCount <= 0}
					) exitWith {
						false
					};

					private _stateAmmoType = getText (
						configFile
						>> "CfgMagazines"
						>> _stateMagazine
						>> "ammo"
					);

					if (_stateAmmoType isEqualTo "") exitWith {
						false
					};

					private _ammoConfig =
						configFile >> "CfgAmmo" >> _stateAmmoType;

					private _lockSystem = getNumber (
						_ammoConfig >> "weaponLockSystem"
					);

					private _damageValue =
						(getNumber (_ammoConfig >> "hit"))
						max
						(getNumber (_ammoConfig >> "indirectHit"));

					if (
						_lockSystem != 0
						|| {_damageValue <= 0}
					) exitWith {
						false
					};

					_fireWeapon = _stateWeapon;
					_fireMuzzle = _stateMuzzle;
					_fireMode = _stateMode;
					_fireMagazine = _stateMagazine;
					_fireAmmoCount = _stateAmmoCount;
					_canFireCycle = true;

					true
				};

				if (_isMounted) then {
					/*
						ActionOn currently accepts only the vehicle's primary
						gunner. unitTurret nevertheless obtains the actual
						turret path instead of assuming [0].
					*/
					_turretPath = _firingObject unitTurret _unit;

					private _candidateWeapons = [];
					private _currentTurretWeapon = _firingObject currentWeaponTurret _turretPath;

					if (_currentTurretWeapon isNotEqualTo "") then {
						_candidateWeapons pushBack _currentTurretWeapon;
					};

					{
						if (_x isNotEqualTo "") then {
							_candidateWeapons pushBackUnique _x;
						};
					} forEach (
						_firingObject weaponsTurret _turretPath
					);

					/*
						Prefer the selected weapon if suitable. If the selected
						weapon is a guided missile, continue through the same
						turret's weapons until an unlocked weapon with live
						ammunition is found.
					*/
					{
						private _candidateState = weaponState [
							_firingObject,
							_turretPath,
							_x
						];

						if (
							[_candidateState]
								call _tryUseWeaponState
						) exitWith {};
					} forEach _candidateWeapons;
				} else {
					/*
						Infantry suppression uses only the primary weapon or
						handgun. Launchers, throwables and binocular-type
						weapons are not suppression candidates.
					*/
					private _candidateWeapons = [];
					private _primaryWeapon = primaryWeapon _unit;
					private _handgunWeapon = handgunWeapon _unit;
					private _currentInfantryWeapon = currentWeapon _unit;

					if (
						_currentInfantryWeapon in [
							_primaryWeapon,
							_handgunWeapon
						]
						&& {
							_currentInfantryWeapon isNotEqualTo ""
						}
					) then {
						_candidateWeapons pushBack
							_currentInfantryWeapon;
					};

					{
						if (_x isNotEqualTo "") then {
							_candidateWeapons pushBackUnique _x;
						};
					} forEach [
						_primaryWeapon,
						_handgunWeapon
					];

					{
						private _candidateWeapon = _x;
						private _weaponConfig =
							configFile
							>> "CfgWeapons"
							>> _candidateWeapon;

						private _weaponMuzzles = getArray (
							_weaponConfig >> "muzzles"
						);

						private _queryMuzzle =
							_weaponMuzzles param [
								0,
								_candidateWeapon
							];

						if (_queryMuzzle isEqualTo "this") then {
							_queryMuzzle = _candidateWeapon;
						};

						private _candidateState =
							_unit weaponState _queryMuzzle;

						if (
							[_candidateState]
								call _tryUseWeaponState
						) exitWith {};
					} forEach _candidateWeapons;
				};

				/*
					Some modded weapons return an empty fire mode even though
					the weapon and magazine state are otherwise usable.
				*/
				if (
					_canFireCycle
					&& {_fireMode isEqualTo ""}
				) then {
					private _weaponConfig =
						configFile >> "CfgWeapons" >> _fireWeapon;

					private _muzzleConfig = _weaponConfig;

					if (
						_fireMuzzle isNotEqualTo _fireWeapon
						&& {
							isClass (
								_weaponConfig >> _fireMuzzle
							)
						}
					) then {
						_muzzleConfig =
							_weaponConfig >> _fireMuzzle;
					};

					private _modes =
						getArray (_muzzleConfig >> "modes");

					_fireMode = _modes param [0, "Single"];

					if (_fireMode isEqualTo "this") then {
						_fireMode = _fireWeapon;
					};
				};

				private _aimReady = true;

				private _polygonChangedWhileAiming = false;

				if (
					_canFireCycle
					&& {!_isMounted}
				) then {
					private _isWeaponPointedAtTarget = {
						if (isNull _target) exitWith {
							false
						};

						private _weaponVector =
							_unit weaponDirection _fireWeapon;

						private _targetVector =
							(getPosASL _target) vectorDiff (eyePos _unit);

						if (
							vectorMagnitude _weaponVector <= 0
							|| {vectorMagnitude _targetVector <= 0}
						) exitWith {
							false
						};

						_weaponVector = vectorNormalized _weaponVector;
						_targetVector = vectorNormalized _targetVector;

						/*
							0.8 corresponds to approximately 37 degrees.
							This confirms broad suppression aim rather than precision aim.
						*/
						(_weaponVector vectorDotProduct _targetVector) >= 0.8
					};

					private _aimTimeout = time + 5;

					waitUntil {
						sleep 0.05;

						private _latestPolygon = [
							_actual,
							_polyMarker
						] call _getCurrentPolygon;

						_polygonChangedWhileAiming =
							_latestPolygon isNotEqualTo []
							&& {
								(
									[_latestPolygon]
										call _getPolygonGeometrySignature
								) isNotEqualTo
								_polygonGeometrySignature
							};

						!call _canContinueSuppression
						|| {_polygonChangedWhileAiming}
						|| {call _isWeaponPointedAtTarget}
						|| {time >= _aimTimeout}
					};

					_aimReady =
						!_polygonChangedWhileAiming
						&& {call _canContinueSuppression}
						&& {call _isWeaponPointedAtTarget};
				};

				if (
					_canFireCycle
					&& {_aimReady}
					&& {call _canContinueSuppression}
				) then {
					private _cycleToken = format [
						"%1_%2_%3",
						netId _unit,
						diag_tickTime,
						_cycle
					];

					/*
						For infantry the handler is attached directly to the
						shooter, so no gunner filter is necessary.

						For vehicles it is essential to filter for the selected
						primary gunner. Otherwise shots from another turret could
						be redirected into this suppression area.
					*/
					private _expectedGunner = if (_isMounted) then {
						_unit
					} else {
						objNull
					};

					[
						[
							_firingObject,
							_target,
							_expectedGunner,
							_fireWeapon,
							_cycleToken
						],
						A3C_ai_shared_fnc_addEventhandlerFired
					] remoteExecCall ["BIS_fnc_call", _firingObject];

					// Allow the handler installation to reach the object's owner.
					sleep 0.1;

					private _abortFireCycle = false;

					for "_burst" from 1 to 3 do {
						for "_shot" from 1 to 10 do {
							if (
								isNull _target
								|| {!alive _unit}
								|| {
									!(_unit getVariable [
										"A3C_POLY_ACTION_ACTIVE",
										false
									])
								}
							) exitWith {
								_abortFireCycle = true;
							};

							if (
								[
									_usedMagazine,
									_restrictiveOrigin,
									_restrictiveValue
								] call _restrictiveFnc
							) exitWith {
								_exitRestrictive = true;
								_abortFireCycle = true;
							};

							private _cyclePolygon = [
								_actual,
								_polyMarker
							] call _getCurrentPolygon;

							if (_cyclePolygon isEqualTo []) exitWith {
								_abortFireCycle = true;
							};

							/*
								Dragging the polygon ends only this firing cycle.
								The outer loop will obtain the new polygon and
								select a new target position.
							*/
							private _cyclePolygonGeometrySignature =
								[_cyclePolygon] call _getPolygonGeometrySignature;

							if (
								_cyclePolygonGeometrySignature
									isNotEqualTo
								_polygonGeometrySignature
							) exitWith {
								_abortFireCycle = true;
							};

							if (_isMounted) then {
								if (
									(_firingObject isKindOf "HELICOPTER")
									|| {
										[
											position _target,
											_unit,
											10
										] call MCSS_fnc_lineOfSightVehicle
									}
								) then {
									[
										_firingObject,
										[
											_target,
											_fireWeapon
										]
									] remoteExecCall [
										"fireAtTarget",
										_firingObject
									];
								};
							} else {
								[
									_unit,
									[_fireMuzzle, _fireMode]
								] remoteExecCall [
									"forceWeaponFire",
									_unit
								];
							};

							sleep 0.1;
						};

						// End an automatic infantry burst explicitly.
						if (!_isMounted) then {
							[
								_unit,
								["", ""]
							] remoteExecCall [
								"forceWeaponFire",
								_unit
							];
						};

						if (_abortFireCycle) exitWith {};

						if (_burst < 3) then {
							sleep 2;
						};
					};

					// Ensure no forced firing remains active after cancellation.
					if (_isMounted) then {
						[
							_firingObject,
							[objNull]
						] remoteExecCall [
							"fireAtTarget",
							_firingObject
						];
					} else {
						[
							_unit,
							["", ""]
						] remoteExecCall [
							"forceWeaponFire",
							_unit
						];
					};

					/*
						The token prevents an older cycle from removing a handler
						that belongs to a newer cycle.
					*/
					[
						[
							_firingObject,
							_cycleToken
						],
						A3C_ai_shared_fnc_removeEventhandlerFired
					] remoteExecCall ["BIS_fnc_call", _firingObject];
				} else {
					/*
						If suppression remains active but no suitable weapon is available
						or infantry aim is not ready, wait before trying again.
					*/
					if (call _canContinueSuppression) then {
						sleep 1;
					};
				};
			};

			if (_exitMain && { _groupPlayer }) exitWith {
				if !(isNull _target) then {
					[_unit, _polygon] call A3C_ai_shared_fnc_polygonAreaRemove;
				};
			};
		};

		

		if (!isPlayer _unit) then {
			if !(isPlayer leader group _unit) then {
				// Preserved original condition, even though objectParent is null in this branch.
				if (isNull objectParent _unit && { _unit == driver objectParent _unit }) then {
					[_unit, formationPosition _unit] remoteExec ["doMove", _unit];
					[_unit, formationPosition _unit] remoteExec ["moveTo", _unit];
				};
			};
		};

		if (!isPlayer leader group _unit) then {
			if (isNull objectParent _unit) then {
				_unit setUnitPos "AUTO";
			};
		};

		_unit setVariable ["A3C_POLY_ACTION_ACTIVE", false, true];

		/*
			Restore only AI features that this suppression controller disabled.
		*/
		{
			_x params ["_entity", "_feature"];

			if (!isNull _entity) then {
				[
					_entity,
					_feature
				] remoteExecCall ["enableAI", _entity];
			};
		} forEach _suppressionDisabledAI;

		if (
			_suppressionOwnsSpeedLimit
			&& {
				!(_vehicle getVariable [
					"A3C_LIMIT_SPEED",
					false
				])
			}
		) then {
			[
				_vehicle,
				false
			] remoteExecCall ["limitSpeed", _vehicle];
		};
	};

	case "AMBUSH": {
		while { alive _unit } do {
			_polys = _actual getVariable ["A3C_UNIT_POLYS", []];

			if ({ ((_x select 0) select 1) == _polyMarker } count _polys == 0) then {
				_exitMain = true;
			};

			private _polygon = [];
			_exitMain = true;

			{
				if (((_x select 0) select 1) == _polyMarker) exitWith {
					_polygon = +_x;
					_exitMain = false;
				};
			} forEach _polys;

			if !(_unit getVariable "A3C_POLY_ACTION_ACTIVE") exitWith {
				_exitMain = true;
			};

			if (_exitMain) exitWith {};

			private _center = (_polygon select 0) select 0;
			_polyID = (_polygon select 0) select 2;

			private _polygonData = _polygon select 1;
			private _radius = 0;
			private _origPos = position _unit;

			{
				private _distance = _x distance2D _center;

				if (_distance > _radius) then {
					_radius = _distance;
				};
			} forEach _polygonData;

			if !(_polygon in _polys) then {
				systemChat "turns out this COULD happen";
			};

			private _expectedDestination = expectedDestination _unit;
			private _mainDest = _expectedDestination select 0;

			if ((_mainDest distance2D (_expectedDestination select 0)) > 5) then {
				if (_unit distance2D _origPos > 2) then {
					_exitMain = true;
				};
			};

			if (_exitMain) exitWith {};

			private _targets = [
				side _unit,
				_radius,
				"ENEMY",
				_center,
				["MAN", "CAR", "TANK"]
			] call MCSS_fnc_nearEntities;

			private _pause = if ((count _targets) > 0) then {
				0.1
			} else {
				1
			};

			if ({ (getPosASL vehicle _x) inPolygon _polygonData } count _targets > 0) exitWith {
				[_unit, "RED"] remoteExec ["setCombatMode", _unit];
				[_unit, "COMBAT"] remoteExec ["setBehaviour", _unit];

				{
					[_unit, [_x, 4]] remoteExec ["reveal", _unit];
				} forEach _targets;

				[
					_unit,
					_targets call BIS_fnc_selectRandom
				] remoteExec ["doSuppressiveFire", _unit];
			};

			sleep _pause;
		};

		[_unit, "YELLOW"] remoteExec ["setCombatMode", _unit];
		[_unit, "AWARE"] remoteExec ["setBehaviour", _unit];
		[_unit, "AUTO"] remoteExec ["setUnitPos", _unit];
	};
};

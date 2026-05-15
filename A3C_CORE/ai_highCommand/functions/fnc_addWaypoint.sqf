//-- A3C_ai_highCommand_fnc_addWaypoint
//-- Add Waypoint to HC-Group

params [
	"_group",
	"_waypointPosition",
	["_synchronizedWaypoints", []],
	["_waypointType", "MOVE"],
	[
		"_waypointStatements",
		[
			0,
			0,
			A3C_STANCE1_TEMP,
			A3C_STANCE2_TEMP,
			A3C_WP_SPEED_TEMP,
			if ((A3C_TEMP_ACTION select 0) == "FULL LANDING") then {
				A3C_TEMP_ACTION select 1
			} else {
				"NONE"
			}
		]
	],
	["_isLoopWaypoint", false],
	["_waypointIndex", -1]
];

private _groupLeader = leader _group;
private _leaderVehicle = vehicle _groupLeader;
private _existingWaypoints = waypoints _group;
private _isFirstWaypoint = currentWaypoint _group > selectMax (_existingWaypoints apply {_x # 1});

if (A3C_Debug) then {
	if (!isNil "_isFirstWaypoint") then {
		diag_log format ["%1 _isFirstWaypoint %2", groupID _group, _isFirstWaypoint];
	} else {
		private _groupUnits = units _group;
		diag_log [_group, count _groupUnits, _existingWaypoints apply {_x select 1}, currentWaypoint _group];
	};
};

if (_isFirstWaypoint) then {
	private _groupUnits = units _group;

	if ({canMove vehicle _x && {_x getVariable ["A3C_VAR_LANDING", false]}} count _groupUnits > 0) exitWith {
		systemChat format ["A3C: Waypoint can not be given until %1 has landed all of it's aircraft", groupID _group];
	};
};

if (_isFirstWaypoint) then {
	private _groupUnits = units _group;

	if (driver _leaderVehicle in _groupUnits) then {
		_waypointIndex = 1;

		[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;
		_group setVariable ["A3C_UNIT_POLYS", [], true];

		private _requiresJetTakeoff = false;

		{
			private _unit = _x;
			private _unitVehicle = vehicle _unit;

			if (_unit == driver _unitVehicle) then {
				if (_unitVehicle isKindOf "PLANE") then {
					if (isTouchingGround _unitVehicle) then {
						_requiresJetTakeoff = true;
					};
				};

				if (_unitVehicle isKindOf "SHIP") then {
					private _vehiclePosition = getPos _unitVehicle;
					private _surfaceReferencePosition = ATLToASL ((_vehiclePosition select [0, 2]) + [0]);

					private _shouldStartNearShore = false;

					if (surfaceIsWater _surfaceReferencePosition) then {
						private _waterDepth = _surfaceReferencePosition select 2;

						if (_waterDepth >= -3) then {
							_shouldStartNearShore = true;
						};
					} else {
						_shouldStartNearShore = true;
					};

					if (_shouldStartNearShore) then {
						if (abs speed _unitVehicle < 2) then {
							[_unitVehicle] call A3C_SHIP_startBoat;
						};
					};
				};
			};
		} forEach _groupUnits;

		if (_requiresJetTakeoff) then {
			private _currentGroupLeader = leader _group;
			[_currentGroupLeader] spawn A3C_JET_organizeGroupTakeOff;
		};
	};
};

private _groupWaypointPair = if (_waypointIndex == -1 || {_isFirstWaypoint}) then {
	[_group, _group addWaypoint [_waypointPosition, 0]]
} else {
	[_group, _group addWaypoint [_waypointPosition, 0, _waypointIndex]]
};

private _waypoint = _groupWaypointPair select 1;

_waypoint setWaypointType _waypointType;
_waypoint setWaypointSpeed "UNCHANGED";
_waypoint showWaypoint "NEVER";

// ~~ what's happening here, cycles?
if (_waypointStatements isEqualType []) then {
	_waypointStatements pushBack _isLoopWaypoint;
	_waypointStatements set [0, [_group, _waypoint]];
	_waypointStatements call A3C_ai_highCommand_fnc_setWaypointStatements;
};

private _currentGroupLeader = leader _group;

if (_isFirstWaypoint && {!isPlayer _currentGroupLeader}) then {
	_group move _waypointPosition;

	private _effectiveCommander = effectiveCommander vehicle _currentGroupLeader;
	private _groupUnits = units _group;

	if (_effectiveCommander in _groupUnits) then {
		[_effectiveCommander, _waypointPosition] call A3C_ai_shared_fnc_doMove;
	};
};

//-- SHIPS: dynamically set swimInDepth for each waypoint. Has no effect on non-submersible vehicles
{
	private _unit = _x;
	private _unitVehicle = vehicle _unit;

	if (_unit == driver _unitVehicle) then {
		if (_unitVehicle isKindOf "SHIP") then {
			//-- next line, pay attention: the true/false may seem counter intuitive. We are looking for ZERO units WITHOUT rebreathers (meaning all have one)
			_unitVehicle spawn {
				private _vehicle = _this;

				sleep 5;

				if ({
					private _hiddenUnderwaterSelectionCount = count getArray (configFile >> "CfgWeapons" >> vest _x >> "hiddenUnderwaterSelections");
					_hiddenUnderwaterSelectionCount == 0
				} count crew _vehicle == 0) then {
					[_vehicle, -30] remoteExec ["swimInDepth", _vehicle];
				} else {
					[_vehicle, 0] remoteExec ["swimInDepth", _vehicle];
				};
			};
		};
	};
} forEach units _group;

if !(_synchronizedWaypoints isEqualTo []) then {
	_waypoint synchronizeWaypoint _synchronizedWaypoints;
};

_waypoint
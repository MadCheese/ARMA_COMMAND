// A3C_ai_highCommand_fnc_insertActionWaypoint

if (isNil "A3C_IsA3CServer") exitWith {};

params [
	"_callerUID",
	"_caller",
	"_data",
	"_formation",
	["_wpI", -1],
	["_subType", nil],
	["_leaderOnly", false]
];

private _group = group _caller;
private _leadVic = vehicle leader _group;

// keep in mind: all_polys is an array local to the client. the 'base' of polygons is in the unit's namespace variable ('unit_polys'), which is PUBLIC so that adjustments are still broadcasted while each client forms their own all_polys array
// -- this means that the wpi index is passed into this script, but when the SERVER triggers the poly_action_on func the

if !([_callerUID, _group] call A3C_ai_highCommand_fnc_findExecutingMachine) exitWith {};

_data params ["_condition", "_actionType"]; // array: [[condType,condVal],actionType]

{
	[_x] call A3C_main_fnc_setVehicleVarname;

	private _veh = objectParent _x;
	if (!isNull _veh && {_x == driver _veh}) then {
		[_veh] call A3C_main_fnc_setVehicleVarname;
	};
} forEach units _group;

private _wp = [];
private _wpPos = waypointPosition [_group, _wpI];
private _syncWps = synchronizedWaypoints [_group, currentWaypoint _group];

if (_wpPos isEqualTo [0,0,0]) then {
	_wpPos = position _leadVic;
};

if (_actionType == "FULL LANDING" && {_leadVic getVariable ["alive_combatsupport", false]}) exitWith {
	systemChat "A3C: You are trying to land ALIVE helicopters with A3C. Please use ALIVE-RTB to land this vehicle";
};

private _heliPad = if (_actionType in ["FULL LANDING", "COMBATLANDING", "TRANSPORT UNLOAD"]) then {
	"Land_HelipadEmpty_F" createVehicle _wpPos
} else {
	objNull
};

if (_actionType == "TRANSPORT UNLOAD") exitWith {
	waitUntil {
		{
			private _vic = vehicle _x;
			_x == driver _vic && {_vic isKindOf "HELICOPTER" && {isTouchingGround _vic}}
		} count units _group > 0
	};

	deleteVehicle _heliPad;
};

if (_actionType == "SYNCBOARD_VIV") then {
	[_leadVic, "GET IN"] remoteExec ["land", _leadVic];
};

private _specialCondition = {};
private _insCondition = "";

_condition params ["_conditionType", "_conditionValue"];

if (_conditionType == "GoCode") then {
	A3C_GOCODES_HC pushBackUnique _conditionValue;
	publicVariable "A3C_GOCODES_HC";
	[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls", 0];

	_insCondition = format ["A3C_GoCode_Activate_%1", _conditionValue];
} else {
	if (_conditionType == "NONE") then {
		_insCondition = "";
		_specialCondition = {true};
	} else {
		_insCondition = "time > time"; // can never return true on purpose, just needs to be a valid condition for the icon to be drawn // why not just use "false"?
	};
};

if (_actionType == "CAS-STRIKE") then {
	_specialCondition = {
		params ["_gp"];
		_gp getVariable ["CAS_COMPLETED", true] || {{alive _x} count units _gp == 0}
	};

	_condition = ["NONE", "NONE"];
	_insCondition = "false && false";
	_group setVariable ["CAS_COMPLETED", false, true];
};

if (_actionType == "RAPPELL") then {
	_specialCondition = {
		params ["_gp"];
		_gp getVariable ["A3C_RAPPELL_COMPLETED", true] || {{alive _x} count units _gp == 0}
	};

	_condition = ["NONE", "NONE"];
	_insCondition = "false && false";
	_group setVariable ["A3C_RAPPELL_COMPLETED", false, true];

	_wpPos set [2, 25];

	[
		[driver _leadVic, leader _group, _wpPos],
		A3C_ai_shared_fnc_actionAircraftRappell
	] remoteExec ["BIS_fnc_spawn", leader _group];
};

if (_actionType in ["SUPPRESSION", "AMBUSH"]) then {
	_condition params ["_conditionType", "_conditionValue"];

	_specialCondition = switch (_conditionType) do {
		case "GOCODE": {
			compile format ["%1", _insCondition]
		};

		case "TIMEOUT": {
			private _timeAtCompletion = time + _conditionValue;
			compile format ["time > %1", _timeAtCompletion]
		};

		case "DAYTIME": {
			private _timeParts = _conditionValue splitString ":";
			private _checkParams = [];

			{
				_checkParams pushBack parseNumber _x;
			} forEach _timeParts;

			compile format ["%1 call A3C_main_fnc_isDaytimeCompleted", _checkParams]
		};
	};
};

if (_actionType == "COMBATLANDING") then {
	{
		private _vic = vehicle _x;

		if (_vic isKindOf "HELICOPTER") then {
			if (_x == driver _vic) then {
				[_vic, "GET IN"] remoteExec ["land", _vic];

				[_vic, _x] spawn {
					params ["_vic", "_pilot"];

					waitUntil {
						((getPosATL _vic) select 2) < 0.5 ||
						{!alive _pilot} ||
						{!canMove _vic}
					};

					[_vic, 0] remoteExec ["flyInHeight", _vic];
				};
			};
		};
	} forEach units _group;
};

if (_actionType == "ASSEMBLE WEAPON") then {
	[leader _group, _caller] call A3C_ai_highCommand_fnc_staticAssembleWpAction;
};

private _statements = switch (_actionType) do {
	case "SUPPRESSION": {
		{
			[_this, "SUPPRESSION"] call A3C_ai_shared_fnc_polygonAreaActionOff;
		}
	};

	case "AMBUSH": {
		{
			[_this, "AMBUSH"] call A3C_ai_shared_fnc_polygonAreaActionOff;
		}
	};

	case "COMBATLANDING": {
		if (_leadVic isKindOf "HELICOPTER") then {
			{
				{
					[vehicle _x, "NONE"] remoteExec ["land", vehicle _x];
				} forEach units _this;

				{
					[vehicle _x, _x getVariable ["A3C_FLYINHEIGHT", 100]] remoteExec ["flyInHeight", vehicle _x];
				} forEach units _this;
			}
		} else {
			{}
		}
	};

	case "CAS-STRIKE": {
		{}
	};

	case "RAPPELL": {
		{}
	};

	case "CLEARBUILDING": {
		{}
	};

	default {
		{}
	};
};

private _fakeStatements = switch (_actionType) do {
	// -- 'fake' statements are just used to be able to identify the action for UI purposes (fnc_drawMapUI)
	case "SUPPRESSION": {
		"nul = 'SUPPRESSION_ACTIVE'; "
	};

	case "AMBUSH": {
		"nul = 'AMBUSH_ACTIVE'; "
	};

	case "COMBATLANDING": {
		"nul = 'COMBATLANDING_ACTIVE'; "
	};

	case "CAS-STRIKE": {
		"nul = 'CAS-STRIKE_ACTIVE'; "
	};

	case "RAPPELL": {
		"nul = 'RAPPELL_ACTIVE_ACTIVE'; "
	};

	default {
		""
	};
};

_wpPos = if (!isNil "_wpPos" && {!(_wpPos isEqualTo [])}) then {
	_wpPos
} else {
	position leader _group
}; // ~~ this is a sloppy temp fix. Instead, make sure that _wpPos is always passed.

private _wpCurr = -1;
private _var = _group getVariable ["A3C_UNIT_POLYS", []];

// -- INSERT ACTUAL WP

if (!(_actionType == "FULL LANDING") || {count waypoints _group > 0}) then {
	// ~~ is this supposed to mean active waypoints? why would there be 0 waypoints to begin with?? Like ever?
	_wp = [
		_group,
		_wpPos,
		[],
		"HOLD",
		[0, 1000, "AUTO", "AUTO", -1, "NONE"],
		false,
		_wpI + 1
	] call A3C_ai_highCommand_fnc_addWaypoint;

	// -- adjust polygon data
	{
		private _polyData = _x select 0;
		_polyData params ["_polyType", "_polyDataValue", "_wpIndex"];

		_polyData set [2, _wpIndex + 1]; // ~~ Add 1 to polygon ID to match added waypoint index
	} forEach _var;

	// -- adjust waypoint actionScripts
	{
		_x params ["_wpGroup", "_wpIndex"];

		// adjust postAction poly-Waypoints
		if (_wpIndex > currentWaypoint _group + 1) then {
			// -- add 1 because suppression poly is already assigned
			private _wpAdjust = waypoints _group select _wpIndex;
			private _actionScript = waypointStatements _wpAdjust select 1;

			if ({[_x, _actionScript] call BIS_fnc_inString} count ["suppression", "ambush"] > 0) then {
				_actionScript = _actionScript splitString ";"; // -- actionscript is broken down from string to array

				{
					private _scriptLine = _x;

					if ({[_x, _scriptLine] call BIS_fnc_inString} count ["SUPPRESSION", "AMBUSH"] > 0) then {
						private _scriptLineParts = _scriptLine splitString "]"; // -- convert string to array
						private _subString = _scriptLineParts select 2;
						private _subStringArray = _subString splitString ",";
						private _id = parseNumber (_subStringArray select 1) + 1; // -- add 1 for wpi/poly sync

						_subStringArray set [1, str _id];

						_subString = "," + (_subStringArray joinString ",");
						_scriptLineParts set [2, _subString];

						_scriptLine = (_scriptLineParts joinString "]") + "]"; // -- re-convert poly-scriptline array to string
						_actionScript set [_forEachIndex, _scriptLine];
					};
				} forEach _actionScript;

				_actionScript = _actionScript joinString ";"; // -- re-convert scriptlineS array to string
			};
		};
	} forEach waypoints _group;

	_wp setWaypointStatements [_insCondition, _fakeStatements];
	_group setCurrentWaypoint _wp;
};

[leader _group, _wpPos] spawn {
	params ["_leader", "_wpPos"];

	for "_i" from 0 to 1 do {
		[_leader, _wpPos] call A3C_ai_shared_fnc_doMove;
		sleep 1;
	};
};

// -- assign new polygon data
_group setVariable ["A3C_UNIT_POLYS", _var, true];

// -- poly Actions
if (_actionType in ["SUPPRESSION", "AMBUSH"]) then {
	[_group, _actionType, _wpI, _var] spawn {
		params ["_group", "_actionType", "_wpI", "_var"];

		waitUntil {
			_var isEqualTo (_group getVariable ["A3C_UNIT_POLYS", []])
		};

		sleep 0.2;

		[units _group, ["A3C_HC_POLY", 0], _actionType, false, _wpI + 1] spawn A3C_ai_shared_fnc_polygonAreaActionOn;
	};
};

// -- adjust editing wp-index for clients who may be editing a waypoint of this group
[
	[_group, _wpI],
	A3C_ai_highCommand_fnc_onWaypointInsertedClient
] remoteExec ["BIS_fnc_call", 0];

// -- spawn 'real' condition. Shared by all HighCommand Modes.

[_group, _wpCurr, _wpPos, _condition, _statements, _actionType, _wp, _specialCondition, _var, _heliPad] spawn {
	params ["_group", "_wpCurr", "_wpPos", "_condition", "_statements", "_actionType", "_wp", "_specialCondition", "_var", "_heliPad"];

	waitUntil {
		_var isEqualTo (_group getVariable ["A3C_UNIT_POLYS", []])
	};

	private _formation = formation _group;
	private _timeInit = time;

	private _check = switch (toUpper (_condition select 0)) do {
		case "TIMEOUT": {
			{
				params ["_gp", "_timeInit", "_condition"];

				_condition params ["_conditionType", "_conditionValue"];

				time > (_timeInit + _conditionValue)
			}
		};

		case "DAYTIME": {
			{
				params ["_gp", "_timeInit", "_condition"];

				_condition params ["_conditionType", "_conditionValue"];

				private _timeParts = _conditionValue splitString ":";
				private _checkParams = [];

				{
					_checkParams pushBack parseNumber _x;
				} forEach _timeParts;

				private _return = _checkParams call A3C_main_fnc_isDaytimeCompleted;
				// systemchat str [_return, _checkParams];

				_return
			}
		};

		case "GOCODE": {
			_condition params ["_conditionType", "_conditionValue"];

			switch (_conditionValue) do {
				case "A": {{A3C_GoCode_Activate_A}};
				case "B": {{A3C_GoCode_Activate_B}};
				case "C": {{A3C_GoCode_Activate_C}};
				case "D": {{A3C_GoCode_Activate_D}};
			}
		};

		default {
			_specialCondition
		};
	};

	// systemchat str _check;

	if (_actionType in ["SUPPRESSION", "AMBUSH"]) then {
		// -- wait for polyUnits to get ready
		sleep 1;
	};

	private _leaderDest = expectedDestination leader _group select 0;

	while {true} do {
		private _exit = false;

		if ([_group, _timeInit, _condition] call _check) then {
			_exit = true;
		};

		if (_actionType in ["SUPPRESSION", "AMBUSH"]) then {
			if ({_x getVariable "A3C_POLY_ACTION_ACTIVE"} count units _group == 0) then {
				_exit = true;
			};
		};

		if (_actionType in ["COMBATLANDING"]) then {
			{
				private _unitGroup = group _x;
				private _unitVehicle = vehicle _x;

				if (_x == driver _unitVehicle) then {
					if (_unitVehicle isKindOf "HELICOPTER") then {
						private _height = getPosATL _unitVehicle select 2;

						if (_height < 2 && {((expectedDestination leader _unitGroup select 0) distance _leaderDest) < 10}) then {
							[_unitVehicle, 1] remoteExec ["flyInHeight", _unitVehicle];
						};
					};
				};
			} forEach units _group;

			private _expD = expectedDestination leader _group select 0;

			if (_expD distance2D [0,0,0] > 0 && {_expD distance _leaderDest > 10}) then {
				_exit = true;
			};
		};

		if (_exit) exitWith {
			if (!isNull _heliPad) then {
				// -- this will be executed too early!
				deleteVehicle _heliPad;

				{
					private _unitVehicle = vehicle _x;

					if (_x == driver _unitVehicle) then {
						if (_unitVehicle isKindOf "HELICOPTER") then {
							[_unitVehicle, _x getVariable ["A3C_FLYINHEIGHT", 100]] remoteExec ["flyInHeight", _unitVehicle];
						};
					};
				} forEach units _group;
			};

			private _prms = switch _actionType do {
				case "SUPPRESSION": {
					units _group
				};

				case "AMBUSH": {
					units _group
				};

				case "COMBATLANDING": {
					leader _group
				};

				case "FULL LANDING": {
					leader _group
				};

				case "CAS-STRIKE": {
					leader _group
				};
			};

			_prms call _statements;

			if (count waypoints _group - 1 > currentWaypoint _group) then {
				private _wpc = currentWaypoint _group;
				[_group, currentWaypoint _group] call A3C_ai_highCommand_fnc_removeWaypoint;
			} else {
				deleteWaypoint [_group, currentWaypoint _group];
			};

			private _leader = leader _group;

			sleep 2;

			{
				if (!isPlayer _x) then {
					private _pos = if (_x == leader group _x) then {
						waypointPosition [_group, currentWaypoint _group]
					} else {
						formationPosition _x
					};

					[_x, _pos] call A3C_ai_shared_fnc_doMove;
				};
			} forEach units _group; // - [_leader]

			units _group commandFollow _leader;
		};

		sleep 0.1;
	};

	_group setFormation _formation;
};
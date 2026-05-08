params ["_unit", "_caller", "_movePos"];

private _group = group _unit;
private _aircraft = vehicle _unit;

private _inside = false;

//-- lineIntersectsSurfaces works with ASL positions; _movePos itself is kept as provided.
private _referencePos = +_movePos;
_referencePos = ATLToASL _referencePos;
_referencePos set [2, (_referencePos select 2) + 100];

private _intersections = lineIntersectsSurfaces [
	_referencePos,
	ATLToASL ((_movePos select [0, 2]) + [0]),
	_aircraft,
	objNull
];

private _building = objNull;
private _isHelicopter = _aircraft isKindOf "HELICOPTER";

private _dismountData = [_aircraft, _unit] call A3C_getDismountData;
_dismountData params ["_rappellUnits", "_nonDismountAIgroups"];

private _buildingPositionRailCode = {
	params ["_unit", "_roofPositions", "_building"];

	sleep 2;

	while {alive _unit} do {
		if (isTouchingGround _unit) exitWith {
			private _destination = [0, 0, 0];

			_roofPositions = [
				_roofPositions,
				[],
				{_unit distance2D (_x select 1)},
				"ASCEND"
			] call BIS_fnc_sortBy;

			{
				if !((_x select 1) in A3C_OCC_BPOSES) exitWith {
					_destination = _x select 1;
					A3C_OCC_BPOSES pushBackUnique _destination;
				};
			} forEach _roofPositions;

			if (_destination isEqualTo [0, 0, 0] && {count _roofPositions > 0}) then {
				_destination = _roofPositions select 0;
			};

			if !(_destination isEqualTo [0, 0, 0]) then {
				[_unit, _destination, _building] spawn A3C_RAIL_INF;
			};
		};

		if !(isNull objectParent _unit) exitWith {};

		sleep 0.5;
	};
};

private _abortRappel = false;

//-- Wait until aircraft has lifted off high enough before taking over approach logic.
while {(getPos _aircraft select 2) < 15} do {
	if (!alive _unit || {!alive _aircraft}) exitWith {
		_abortRappel = true;
	};

	sleep 1;
};

if (_abortRappel) exitWith {};

//-- AI heli slow down
if (!isPlayer leader _group && {_isHelicopter}) then {
	while {true} do {
		private _speedLimit = switch (true) do {
			case (_aircraft distance2D _movePos < 200): {40};
			case (_aircraft distance2D _movePos < 1000): {100};
			default {150};
		};

		[_aircraft, _speedLimit] remoteExec ["limitSpeed", _aircraft];

		if (!alive _aircraft) exitWith {};
		if (speed _aircraft < 10) exitWith {}; //-- security measure if heli comes to a premature halt
		if (_aircraft distance2D _movePos <= 300) exitWith {};

		sleep 1;
	};
};

if (!alive _aircraft) exitWith {};

//-- determine approach type
[_aircraft, 0] remoteExec ["limitSpeed", _aircraft];

private _rappelPos = (_movePos select [0, 2]) + [0]; //-- ATL base position used for hover height / rappel point
private _railPos = [];
private _roofPositions = [];

//-- Guide chopper towards exact position
{
	if ((_x select 2) isKindOf "BUILDING") exitWith {
		_building = _x select 2;

		//-- Intersection hit is ASL; convert roof height back to ATL because _rappelPos is ATL.
		_rappelPos set [2, (ASLToATL (_x select 0)) select 2];
		_inside = true;
		_roofPositions = [_building] call MCSS_fnc_get_buildingPoses_roof;
	};
} forEach _intersections;

//-- SQUAD LEVEL: WAIT UNTIL VEHICLE STOPS OR REACHES WAYPOINT
if (isPlayer leader _group && {_isHelicopter}) then {
	while {_aircraft distance2D _movePos > 300} do {
		if (!alive _unit) exitWith {};
		if !(canMove _aircraft) exitWith {};
		if (speed _aircraft < 20) exitWith {};

		sleep 0.1;
	};
};

private _hoverHeight = (_rappelPos select 2) + 155;

[_unit, getPosASL _aircraft] remoteExec ["doMove", _unit]; //-- ASL used for speed, likely because aircraft moves in 2D
[_aircraft, _hoverHeight] remoteExec ["flyInHeight", _aircraft];

//-- Rail functions expect ASL target positions.
_railPos = ATLToASL _rappelPos;
_railPos set [2, (_railPos select 2) + 25];

//-- Spawn CHOPPER RAIL
if (alive _unit) then {
	private _subBehaviour = scriptNull;

	if (_isHelicopter) then {
		_subBehaviour = [
			_aircraft,
			getPosASL _aircraft,
			_railPos,
			50
		] spawn A3C_ai_rail_fnc_helicopter;
	} else {
		_subBehaviour = [
			_aircraft,
			_railPos,
			_inside
		] spawn A3C_ai_rail_fnc_hoverApproach;
	};

	waitUntil {
		scriptDone _subBehaviour
	};
};

if (!alive _unit) exitWith {};

//-- prepare rappel
[_aircraft, [0, 0, 0]] remoteExec ["setVelocity", _aircraft];

{
	[_aircraft, [_x, 1]] remoteExec ["animateDoor", _aircraft];
} forEach [
	"door_R",
	"door_L",
	"Door_L_source",
	"DoorL_Front_Open",
	"DoorR_Front_Open",
	"DoorL_Back_Open",
	"DoorR_Back_Open",
	"Door_1_source"
];

_aircraft setVariable ["A3C_PLAYER_RAPPEL", true, true];

//-- if a player is rappelling, freeze the chopper; maybe do it anyway

//-- FIX AIRCRAFT IN PLACE; really only necessary until Advanced Rappel functions take over
private _standbyHandler = _aircraft spawn {
	private _aircraft = _this;
	private _vectorDir = vectorDir _aircraft;

	while {_aircraft getVariable "A3C_PLAYER_RAPPEL"} do {
		[_aircraft, [0, 0, 0]] remoteExec ["setVelocity", _aircraft];
		[_aircraft, [0, 0, 1]] remoteExec ["setVectorUp", _aircraft];
		[_aircraft, _vectorDir] remoteExec ["setVectorDir", _aircraft];

		sleep 0.01;
	};
};

if (_isHelicopter) then {
	sleep 3; //-- HELIS are already levelled. Still wait 3s so the rappel is not too immediate
} else {
	//-- Level non-heli hover-capable vehicles before rappelling.
	private _subBehaviour = [
		_aircraft,
		getPosASL _aircraft,
		_railPos,
		vectorDirVisual _aircraft,
		[getDir _aircraft] call MCSS_fnc_DegreeToVector,
		vectorUpVisual _aircraft,
		[0, 0, 1],
		3 //-- duration
	] spawn A3C_ai_rail_fnc_vehicleOrient;

	waitUntil {
		scriptDone _subBehaviour
	};
};

private _rappellGroups = [];
private _rappellUnitsAll = +_rappellUnits;

{
	if (group _x != group _unit) then { //-- unit is not in pilot group: remove from rapunits, add group to rapGroups
		_rappellGroups pushBackUnique group _x;
		_rappellUnits = _rappellUnits - [_x];
	};
} forEach _rappellUnits;

//-- commence rappel
//-- _rappellUnits now only consists of units that are in pilot's group. That means that pilot leader is a player. Dismount those first.
{
	//~~ TO DO: unify the rail between squad and HC, clean that up :S

	[
		_x,
		_inside,
		_building,
		_aircraft,
		_unit,
		_roofPositions,
		_buildingPositionRailCode
	] spawn {
		params [
			"_unit",
			"_inside",
			"_building",
			"_vehicle",
			"_pilotUnit",
			"_roofPositions",
			"_buildingPositionRailCode"
		];

		waitUntil {
			[_unit, _vehicle] call AR_Rappel_From_Heli_Action_Check
		};

		[_unit, _vehicle] call AR_Rappel_From_Heli;

		waitUntil {
			!(_unit in _vehicle)
		};

		

		[[_unit], A3C_AIGetOut] remoteExec ["BIS_fnc_call", _unit];

		//-- rooftop landing: rail AI to closest building positions to snap them into path LOD
		if (!isNil "A3C_RAIL_INF") then { //-- exit if A3C is not running on client
			if (_inside && {!(isPlayer _unit)}) then {
				[_unit, _roofPositions, _building] spawn _buildingPositionRailCode;
				sleep 2;
			};
		};
	};

	sleep 2;

	if ((_forEachIndex + 1) % 4 == 0) then {
		waitUntil {
			{animationState _x in ["ar_01_idle", "ar_01_aim"]} count _rappellUnits < 3
		};
	};
} forEach _rappellUnits;




//-- dismount other groups
_rappelPos = getPosASL _aircraft;
_rappelPos set [2, (_rappelPos select 2) - 25];

[_group, _rappellGroups, _rappelPos, _inside] call A3C_AIC_fnc_rappelActionHandler;

{
	private _rapGroup = _x;

	{
		[
			_x,
			_building,
			_inside,
			_roofPositions,
			_buildingPositionRailCode
		] spawn {
			params [
				"_unit",
				"_building",
				"_inside",
				"_roofPositions",
				"_buildingPositionRailCode"
			];

			if (!isNil "A3C_RAIL_INF") then { //-- exit if A3C is not running on client
				if (_inside && {!(isPlayer _unit)}) then {
					waitUntil {
						!alive _unit || {isNull objectParent _unit}
					};

					[_unit, _roofPositions, _building] spawn _buildingPositionRailCode;
				};
			};
		};
	} forEach units _rapGroup;
} forEach _rappellGroups;

sleep 1;

if (count _rappellUnitsAll > 0) then {
	waitUntil {
		{vehicle _x != _aircraft} count _rappellUnitsAll > 0
	};
};

//-- wait until units have rappelled
while {alive _unit} do {
	private _rappelComplete = true;

	{
		if (alive _x && {!isTouchingGround _x}) exitWith {
			_rappelComplete = false;
		};
	} forEach _rappellUnitsAll;

	sleep 1;

	if (_rappelComplete) exitWith {};
};

_group setVariable ["A3C_RAPPELL_COMPLETED", true, true];
_aircraft setVariable ["A3C_PLAYER_RAPPEL", false, true];

//-- done. close doors and continue
{
	[_aircraft, [_x, 0]] remoteExec ["animateDoor", _aircraft];
} forEach [
	"door_R",
	"door_L",
	"door_rear",
	"door_rear_source",
	"Door_L_source",
	"Door_R_source",
	"DoorL_Front_Open",
	"DoorR_Front_Open",
	"DoorL_Back_Open",
	"DoorR_Back_Open",
	"Door_1_source"
];

//-- create radio message; squad level only
private _radioReply = ["Roger that, I'm off", "Roger", "Got It", "Good luck out there", "Catch you later"] call BIS_fnc_selectRandom;

if !((floor random 2.9) == 2) then {
	_radioReply = _radioReply + format [" %1", toLower rank _caller];
};

if (isPlayer _caller) then {
	player groupChat "We're out";
	sleep 2;
	_unit groupChat _radioReply;
};

waitUntil {
	scriptDone _standbyHandler
};

sleep 1;

{
	_x leaveVehicle _aircraft;
	{unAssignVehicle _x} foreach (units _x);
} foreach _rappellGroups;

[_aircraft, 1500] remoteExec ["limitSpeed", _aircraft];

private _nextWpPos = waypointPosition [_group, currentWaypoint _group];

if (_nextWpPos distance2D [0, 0, 0] > 0) then {
	while {alive _aircraft && {speed _aircraft < 30}} do {
		//-- Nudge pilot/controller unit back toward the group's next waypoint after the rappel hold.
		[_unit, _nextWpPos] remoteExec ["doMove", _unit];
		[_aircraft, 1500] remoteExec ["limitSpeed", _aircraft];

		sleep 3;
	};
};


params ["_group", "_pos", "_target","_playerUID","_direction","_overwatch_height","_condition","_formation"];




_condition params ["_condType","_condVal"];

if (!local _group) exitWith {};

if !(_condType in ["GoCode","TIMEOUT"]) then {//-- change when you find time to include daytime
	_condType = "GoCode";
	_condVal = "C";
};

//systemchat str _condition;

_group setFormation _formation;


private _timer = time;

_exitCondition = switch (_condType) do {
	case ("TIMEOUT") : {
		_timeAtCompletion = time + _condVal;
		compile format ["time > %1",_timeAtCompletion];
	};
	case ("GoCode") : {
		compile format ["A3C_GoCode_Activate_%1",_condVal];
	};
};





private _wpIndex = currentWaypoint _group;

private _waypointPositions =  [_pos,count units _group, (_pos getDir (leader _group)) + 180,100 ] call A3C_fnc_generateWpWedgePositions;

private _assignedIndex = 0;


private _leader = leader _group;
private _leaderVic = vehicle _leader;
private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.3;
private _groupPilots = (units _group) select {private _v = vehicle _x; _x == driver _v && {[_v] call A3C_fnc_isAttackHelicopter}};

if (count _groupPilots == 0) exitWith {true};

while {_leaderVic distance2d _pos >= _precision} do {
	_leader domove _pos; 
	(units _group - [_leader]) doFollow _leader;
	sleep 2;
};

{
	[_x,_pos,_direction,_overwatch_height] spawn {
		params ["_pilot","_waypointPos","_direction","_overwatch_height"];
		_waypointPos set [2,0];
		private _vehicle = vehicle _pilot;
		private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "precision")) * 1.3;
		private _doExit = false;
		private _exitFnc = {
			params ["_vehicle","_pilot","_waypointPos"];
			
			private _exit = 
			(
				{!alive _x} count [_vehicle,_pilot] > 0 OR 
				{
					//_isWaypointCancelled
					(_waypointPos distance2D (waypointPosition [group _pilot, currentWaypoint group _pilot])) > 1
				}
			);
			_exit
		};

		while {true} do {
			_doExit = [_vehicle,_pilot,_waypointPos] call _exitFnc;

			if (_vehicle distance2D (formationposition _vehicle) < (_precision * 1.3)) exitWith {};
			if (_doExit) exitWith {};
		};
		if (_doExit) exitWith {};

		//00 disable movement
		 //,  ["ALL"] ,,"AUTOTARGET","FSM","SUPPRESSION","COVER","AUTOCOMBAT","MOVE"
		//-- rotate chopper
		private _targetPos = _vehicle getPos [1000,_direction];
		_vehicle domove _targetPos;
		_vehicle setVariable ["A3C_Freeze_helicopter",[true,_direction],true];
		_heliHeight = (getPosVisual _vehicle) select 2;

		_adjustZvelocity = if (_heliHeight < _overwatch_height) then {7} else {-7};
		//-- adjust altitude
		//[_vehicle,_overwatch_height,_adjustZvelocity] spawn {
		//	params ["_vehicle","_overwatch_height","_adjustZvelocity"];
			while {abs ((getposATL _vehicle select 2) - _overwatch_height) > 20} do {
				bf1 setVelocity [0,0,_adjustZvelocity];
				private _var = _vehicle getVariable ["A3C_Freeze_helicopter",[false,0]];
				if !(_var select 0) exitWith {};
			};
		//}; //-- after action is done, heli automatically adjusts altitude
	};
} foreach _groupPilots;


sleep 1;
waitUntil {
	_isCompleted = [] call _exitCondition;
	_var = _leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]];
	_isCompleted OR {!(_var select 0) OR {(_pos distance (waypointPosition [_group, currentWaypoint _group])) > 1}}
};

{
	private _vehicle = vehicle _x;
	{_vehicle enableAI _x; } foreach ["TARGET","PATH"];
	_vehicle  setVariable ["A3C_Freeze_helicopter",[false,0],true];
	_vehicle  setVariable ["A3C_Freeze_helicopter",[false,0],true];
} foreach _groupPilots;

true;




